% Specify sample time used by plant models and MPC controller
Ts = 0.5; %0.4
% Create operating point specification.
plant_mdl = 'ph_openloop';
op = operspec(plant_mdl);
%%
% Feed concentration is known at the initial condition.

op.Outputs(1).y = 7;
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
plant_initial.InputName = {'qb'};
plant_initial.OutputName = {'pH'};

%% Obtain Linear Plant Model at Intermediate Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

%%
% pH is known
op.Outputs(1).y = 10; %7.01
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
plant_intermediate.InputName = {'qb'};
plant_intermediate.OutputName = {'pH'};

%% Obtain Linear Plant Model at Final Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

% %%
op.Inputs(1).u = 15.5497;
op.Inputs(1).Known = true;
% % pH is known
op.Outputs(1).y = 7;
op.Outputs(1).Known = true;

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
plant_final.InputName = {'q3'};
plant_final.OutputName = {'pH'};

%% Construct Linear Parameter Varying System
% You can use an LTI array to store the three linear plant models obtained
% in previous sections.
lpv(:,:,1) = plant_initial;
lpv(:,:,2) = plant_intermediate;
lpv(:,:,3) = plant_final;
%%
% Specify pH as the scheduling parameter. 
lpv.SamplingGrid = struct('pH',[y0_initial(1); y0_intermediate(1); y0_final(1)]);
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
Nu = 30;

mpcobj_lpv = mpc(plant_initial, Ts, Np, Nu);
mpcobj_lpv.Model.Plant.OutputUnit = {'pH'};
% Set nominal values in the controller
%mpcobj_lpv.Model.Nominal = struct('X', x0, 'U', u0, 'Y', y0, 'DX', [0 0]);
mpcobj_lpv.Model.Nominal = struct('X',x0_initial,'U',[u0_initial],'Y',y0_initial,'DX',[0  0  0]);

% Weight on output variable is defined
mpcobj_lpv.Weights.OV = 1;
mpcobj_lpv.Weights.MV = 0;
mpcobj_lpv.Weights.MVRate = 0.4;

% Constraint on manipulated variable is defined.
mpcobj_lpv.MV.RateMin = -2;
mpcobj_lpv.MV.RateMax = 2;
mpcobj_lpv.MV.Min = 0;
mpcobj_lpv.MV.MinECR = 0;
mpcobj_lpv.MV.Max = 30;
mpcobj_lpv.OV(1).Min = 1;
mpcobj_lpv.OV(1).Max = 14;
