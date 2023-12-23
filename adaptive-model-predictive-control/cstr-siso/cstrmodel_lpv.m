% Specify sample time used by plant models and MPC controller
Ts = 0.3;
% Create operating point specification.
plant_mdl = 'cstr_open';
op = operspec(plant_mdl);
%%
% Feed concentration is known at the initial condition.

op.Outputs(1).y = 0.1; %0.04;
op.Outputs(1).Known = true;

%% 
% Compute initial condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.

% x0_initial = [op_report.States(1).x ; op_report.States(2).x  ; op_report.States(3).x];
x0_initial = [op_report.States(1).x ];
y0_initial = [op_report.Outputs(1).y];
u0_initial = [op_report.Inputs(1).u];
%%
% Obtain linear model at the initial condition.
plant_initial = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_initial = c2d(plant_initial,Ts);
%%
% Specify signal types and names used in MPC.
plant_initial.InputGroup.ManipulatedVariables = 1;
plant_initial.OutputGroup.Measured = 1;
plant_initial.InputName = {'qc'};
plant_initial.OutputName = {'Ca'};

%% Obtain Linear Plant Model at Intermediate Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

%%
% pH is known
op.Outputs(1).y = 0.08;
op.Outputs(1).Known = true;
%%
% Find steady state operating condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
% x0_intermediate = [op_report.States(1).x ; op_report.States(2).x  ; op_report.States(3).x];
x0_intermediate = [op_report.States(1).x ];
y0_intermediate = [op_report.Outputs(1).y];
u0_intermediate = [op_report.Inputs(1).u];
%%
% Obtain linear model at the initial condition.
plant_intermediate = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_intermediate = c2d(plant_intermediate,Ts);
%%
% Specify signal types and names used in MPC.
plant_intermediate.InputGroup.ManipulatedVariables = 1;
plant_intermediate.OutputGroup.Measured = 1;
plant_intermediate.InputName = {'qc'};
plant_intermediate.OutputName = {'Ca'};

%% Obtain Linear Plant Model at Final Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

% %%
% % pH is known
op.Outputs(1).y = 0.1;
op.Outputs(1).Known = true;

op.Inputs(1).u = 103.4 ;
op.Inputs(1).Known = true  ;

%%
% Find steady state operating condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
% x0_final = [op_report.States(1).x ; op_report.States(2).x  ; op_report.States(3).x];
x0_final = [op_report.States(1).x ];
y0_final = [op_report.Outputs(1).y];
u0_final = [op_report.Inputs(1).u];
%%
% Obtain linear model at the initial condition.
plant_final = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_final = c2d(plant_final,Ts);
%%
% Specify signal types and names used in MPC.
plant_final.InputGroup.ManipulatedVariables = 1;
plant_final.OutputGroup.Measured = 1;
plant_final.InputName = {'qc'};
plant_final.OutputName = {'Ca'};

%% Construct Linear Parameter Varying System
% You can use an LTI array to store the three linear plant models obtained
% in previous sections.
lpv(:,:,1) = plant_initial;
lpv(:,:,2) = plant_intermediate;
lpv(:,:,3) = plant_final;
%%
% Specify pH as the scheduling parameter. 
lpv.SamplingGrid = struct('Ca',[y0_initial(1); y0_intermediate(1); y0_final(1)]);
%%
% Specify nominal values of plant inputs, outputs and states at each steady
% state operating point.
lpv_u0(:,:,1) = u0_initial;
lpv_u0(:,:,2) = u0_intermediate;
lpv_u0(:,:,3) = u0_final;
lpv_y0(:,:,1) = y0_initial;
lpv_y0(:,:,2) = y0_intermediate;
lpv_y0(:,:,3) = y0_final;
lpv_x0(:,:,1) = x0_initial;
lpv_x0(:,:,2) = x0_intermediate;
lpv_x0(:,:,3) = x0_final;

%% Design MPC Controller at Initial Operating Condition
% You design a MPC controller at the initial operating condition but the
% controller settings such as horizons and tuning weights should be chosen
% such that they apply to the whole operating range.
%%
% Create MPC controller with default prediction and control horizons
% mpcobj = mpc(plant_initial,Ts);

% Create MPC controller with default prediction and control horizons
Np = 100;
Nu = 25;

mpcobj_lpv = mpc(plant_initial, Ts, Np, Nu);
mpcobj_lpv.Model.Plant.OutputUnit = {'pH'};
% Set nominal values in the controller
%mpcobj_lpv.Model.Nominal = struct('X', x0, 'U', u0, 'Y', y0, 'DX', [0 0]);
mpcobj_lpv.Model.Nominal = struct('X',x0_final,'U',[u0_final],'Y',y0_final,'DX',[0  0]);

% Weight on output variable is defined
mpcobj_lpv.Weights.OV = 1;
mpcobj_lpv.Weights.MV = 0;
mpcobj_lpv.Weights.MVRate = 0.02;

% Constraint on manipulated variable is defined.
mpcobj_lpv.MV.RateMin = -10;
mpcobj_lpv.MV.RateMax = 10;
mpcobj_lpv.MV.Min = 60;
mpcobj_lpv.MV.MinECR = 0;
mpcobj_lpv.MV.Max = 120;
mpcobj_lpv.OV(1).Min = 0;
mpcobj_lpv.OV(1).Max = 0.15;

%% specify overall adjustment factor applied to weights
beta = 1.6;
%% specify weights
mpcobj_sl.Weights.MV = 0*beta;
mpcobj_sl.Weights.MVRate = 0.02/beta;
mpcobj_sl.Weights.OV = 1*beta;
mpcobj_sl.Weights.ECR = 100000;