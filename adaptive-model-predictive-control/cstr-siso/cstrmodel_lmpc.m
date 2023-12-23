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
plant_mdl = 'cstr_open';
op = operspec(plant_mdl);

%Input value at initial condition

%Feed Flowrate of coolant
op.Inputs(1).u = 103.41;
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
Ts = 1;
plant = c2d(sys,Ts);

% Specify signal types used in MPC.
plant.InputGroup.ManipulatedVariables = 1;
plant.OutputGroup.Measured = 1;
plant.InputName = {'qc'};
plant.OutputName = {'Ca'};
plant.InputUnit = {'L/min'};

% Create MPC controller with default prediction and control horizons
mpcobj_cstr = mpc(plant);
mpcobj_cstr.PredictionHorizon = 100;
mpcobj_cstr.ControlHorizon = 25;

% Set nominal values in the controller
mpcobj_cstr.Model.Nominal = struct('X', x0, 'U', u0, 'Y', y0, 'DX', [0 0]);

% Weight on output variable is defined
mpcobj_cstr.Weights.OV = 1;
mpcobj_cstr.Weights.MV = 0;
mpcobj_cstr.Weights.MVRate = 0.02;

% Constraint on manipulated variable is defined.
mpcobj_cstr.MV.RateMin = -10;
mpcobj_cstr.MV.RateMax = 10;
mpcobj_cstr.MV.Min = 60;
mpcobj_cstr.MV.MinECR = 0;
mpcobj_cstr.MV.Max = 120;
mpcobj_cstr.OV(1).Min = 0;
mpcobj_cstr.OV(1).Max = 0.15;

% setEstimator(mpcobj,'custom');
[num, den] = tfdata(plant);
Aq = den{1};
Bq = num;


