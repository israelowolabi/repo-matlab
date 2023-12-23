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
plant_mdl = 'openloopPH';
op = operspec(plant_mdl);

%Input value at initial condition

%Feed Flowrate of Base N+
op.Inputs(1).u = 0.8; %0.13
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

%Design MPC Controller
% You design an MPC at the initial operating condition.  When running in
% the adaptive mode, the plant model is updated at run time.

% Specify signal types used in MPC.
plant.InputGroup.ManipulatedVariables = 1;
plant.OutputGroup.Measured = 1;
plant.InputName = {'u1'};
plant.OutputName = {'pH'};
plant.InputUnit = {'L/min'};


% Create MPC controller with default prediction and control horizons
mpcobj_sl = mpc(plant);
mpcobj_sl.PredictionHorizon = 8;
mpcobj_sl.ControlHorizon = 2;


% Set nominal values in the controller
mpcobj_sl.Model.Nominal = struct('X', x0, 'U', u0, 'Y', y0, 'DX', [0 0]);

% Set scale factors because plant input and output signals have different
% orders of magnitude

% Weight on output variable is defined
mpcobj_sl.Weights.OV = 1.25;
mpcobj_sl.Weights.MV = 0;
mpcobj_sl.Weights.MVRate = 92.5;

% Constraint on manipulated variable is defined.
mpcobj_sl.MV.RateMin = -0.5;
mpcobj_sl.MV.RateMax = 0.5;
mpcobj_sl.MV.Min = 0;
mpcobj_sl.MV.MinECR = 0;
mpcobj_sl.MV.Max = 3;
mpcobj_sl.OV(1).Min = 0;
mpcobj_sl.OV(1).Max = 14;
