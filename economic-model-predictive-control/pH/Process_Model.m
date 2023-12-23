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
plant_mdl = 'Sim_pH1';
op = operspec(plant_mdl);

%Input value at initial condition
op.Inputs(1).u = 15.6;
op.Inputs(1).Known = true;

%Compute initial condition
[op_point, op_report] = findop(plant_mdl,op);

% Obtain nominal values of x, y and u.
x0 = [op_report.States(1).x;op_report.States(2).x];
y0 = [op_report.Outputs(1).y];
u0 = [op_report.Inputs(1).u]; 

% Obtain linear plant model at the initial condition.
sys = linearize(plant_mdl, op_point);

% Discretize the plant model because Adaptive MPC controller only accepts a
% discrete-time plant model.
Ts = 1;
plant = c2d(sys,Ts);

%Design MPC Controller
% You design an MPC at the initial operating condition.  When running in
% the adaptive mode, the plant model is updated at run time.

% Specify signal types used in MPC.
plant.InputGroup.ManipulatedVariables = 1;
plant.OutputGroup.Measured = 1;
plant.InputName = {'Q3'};
plant.OutputName = {'pH'};
plant.InputUnit = {'cm^3/s'};

% Create MPC controller with default prediction and control horizons
mpcobj_pH = mpc(plant);
mpcobj_pH.PredictionHorizon = 3;
mpcobj_pH.ControlHorizon = 1;


% Set nominal values in the controller
mpcobj_pH.Model.Nominal = struct('X', x0, 'U', u0, 'Y', y0, 'DX', [0 0]);

% Set scale factors because plant input and output signals have different
% orders of magnitude

% Weight on output variable is defined
mpcobj_pH.Weights.OV = 10;
mpcobj_pH.Weights.MV = 0;
mpcobj_pH.Weights.MVRate = 1;

% Constraint on manipulated variable is defined.
mpcobj_pH.MV.RateMin = -1;
mpcobj_pH.MV.RateMax = 1;
mpcobj_pH.MV.Min = 0;
mpcobj_pH.MV.MinECR = 0;
mpcobj_pH.MV.Max = 30;
mpcobj_pH.OV(1).Min = 1;
mpcobj_pH.OV(1).Max = 14;
%% specify overall adjustment factor applied to weights
beta = 1.8965;
%% specify weights
mpcobj_pH.Weights.MV = 0*beta;
mpcobj_pH.Weights.MVRate = 1/beta;
mpcobj_pH.Weights.OV = 10*beta;
mpcobj_pH.Weights.ECR = 100000;

[num, den] = tfdata(plant);
Aq = den{1};
Bq = num;
