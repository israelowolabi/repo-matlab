%Just to check if the requirements for the simulation are met by system.
if ~mpcchecktoolboxinstalled('simulink')
    disp('Simulink(R) is required to run this example.')
    return
end
if ~mpcchecktoolboxinstalled('slcontrol')
    disp('Simulink Control Design(R) is required to run this example.')
    return
end

%Define an operating point for the model 
plant_mdl = 'cstr_open';
op = operspec(plant_mdl);

op.Inputs(1).u = 103.41; %102.5
op.Inputs(1).Known = true;
op.Inputs(2).u = 100; %95
op.Inputs(2).Known = true;

% Compute the value of the initial state.
[op_point, op_report] = findop(plant_mdl,op);

% Obtain nominal values of x, y and u.
x0 = [op_report.States(1).x];
y0 = [op_report.Outputs(1).y;op_report.Outputs(2).y];
u0 = [op_report.Inputs(1).u;op_report.Inputs(2).u]; 

% Obtain linear plant model at the initial condition.
cstr_mimo = linearize(plant_mdl, op_point);

% Discretize the plant model because Adaptive MPC controller only accepts a
% discrete-time plant model.
Ts = 0.05; %0.05
cstr_mimo = c2d(cstr_mimo,Ts);
% Design MPC Controller
% You design an MPC at the initial operating condition.  When running in
% the adaptive mode, the plant model is updated at run time.

% Specify signal types used in MPC.
cstr_mimo.InputName = {'qc','q'};
cstr_mimo.OutputName = {'Ca','T'};
cstr_mimo.StateName = {'x_1','x_2'};
cstr_mimo.InputGroup.MV = (1:2);
cstr_mimo.OutputGroup.MO = (1:2);

% Create MPC controller with default prediction and control horizons
p = 100; %10 %25
m = 25; %2 %2
mpcobj_L = mpc(cstr_mimo, Ts, p, m);
% mpcobj = mpc(plant);
mpcobj_L.Model.Plant.OutputUnit = {'mol/L','k'};
mpcobj_L.Model.Nominal.U = [103.41 100]';
mpcobj_L.Model.Nominal.Y = [0.1 438.51]';
% Set nominal values in the controller
mpcobj_L.Model.Nominal = struct ('X',x0 , 'U' , u0, 'Y', y0, 'DX', [0 0]);

% Set scale factors because plant input and output signals have different
% orders of magnitude


%% To specify the constraints of the manipulated variable

%% specify overall adjustment factor applied to weights
beta = 1.6;%1.0
%% specify weights
mpcobj_L.Weights.MV = [0 0]*beta;
mpcobj_L.Weights.MVRate = [0.02 0.02]/beta;
mpcobj_L.Weights.OV = [1 10]*beta;
mpcobj_L.Weights.ECR = 100000;

%% To specify the constraints of the manipulated variable

mpcobj_L.MV(1).Min = 60; %
mpcobj_L.MV(1).Max = 120; %110

mpcobj_L.MV(2).Min = 95; %95
mpcobj_L.MV(2).Max = 150; %

mpcobj_L.OutputVariables(1).Min = 0.02;
mpcobj_L.OutputVariables(1).Max = 0.15;

mpcobj_L.OutputVariables(2).Min = 430;
mpcobj_L.OutputVariables(2).Max = 490;

mpcobj_L.MV(1).RateMin = -10; %-2
mpcobj_L.MV(1).RateMax = 10; %2
% 
mpcobj_L.MV(2).RateMin = -10; %-2
mpcobj_L.MV(2).RateMax = 10; %2
