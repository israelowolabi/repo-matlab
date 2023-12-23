%Linearize Non-Linear Plant
if ~mpcchecktoolboxinstalled('simulink')
    disp('Simulink(R) is required to run this example.')
    return
end
if ~mpcchecktoolboxinstalled('slcontrol')
    disp('Simulink Control Design(R) is required to run this example.')
    return
end

%Create operating point specification
plant_mdl = 'phBopen';
op = operspec(plant_mdl);

%Input value at initial condition

%Feed Flowrate of alkaline
op.Inputs(1).u = 0.01;
op.Inputs(1).Known = true;

%Compute initial condition
[op_point, op_report] = findop(plant_mdl,op);

% Obtain nominal values of x, y and u.
x0 = [op_report.States(1).x];
y0 = [op_report.Outputs(1).y];
u0 = [op_report.Inputs(1).u]; 

% Obtain linear plant model at the initial condition.
sys = linearize(plant_mdl, op_point);

% Discretize the plant model because Adaptive MPC controller only accepts a
% discrete-time plant model.
Ts = 0.1;
plant = c2d(sys,Ts);
% plant=sys ;

% Specify signal types used in MPC.
plant.InputGroup.ManipulatedVariables = 1;
plant.OutputGroup.Measured = 1;
plant.InputName = {'qb'};
plant.OutputName = {'pH'};
plant.InputUnit = {'L/min'};

% Create MPC controller with default prediction and control horizons
mpcobj_L = mpc(plant,Ts);
mpcobj_L.PredictionHorizon = 100;
mpcobj_L.ControlHorizon = 2;

% Set nominal values in the controller
mpcobj_L.Model.Nominal = struct('X', x0, 'U', u0, 'Y', y0, 'DX', [0 0]);

% Weight on output variable is defined
mpcobj_L.Weights.OV = 1;
mpcobj_L.Weights.MV = 0;
mpcobj_L.Weights.MVRate = 5; %1

% Constraint on manipulated variable is defined.
mpcobj_L.MV.RateMin = -10;
mpcobj_L.MV.RateMax = 10;
mpcobj_L.MV.Min = 0;
mpcobj_L.MV.MinECR = 0;
mpcobj_L.MV.Max = 1000;
mpcobj_L.OV(1).Min = 0;
mpcobj_L.OV(1).Max = 14;
