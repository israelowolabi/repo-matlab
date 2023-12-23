% Specify sample time used by plant models and MPC controller
Ts = 0.05;
% Create operating point specification.
plant_mdl = 'cstr_open';
op = operspec(plant_mdl);
%%
% qc
op.Inputs(1).u = 103.41; %102.5
op.Inputs(1).Known = true;
% q
op.Inputs(2).u = 100; %95
op.Inputs(2).Known = true;

% Ca
%op.Outputs(1).y = 0.1; %0.106
%op.Outputs(1).Known = true;
% T
%op.Outputs(2).y = 440; %436.388
%op.Outputs(2).Known = true;

%% 
% Compute initial condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.

% x0_initial = [op_report.States(1).x ; op_report.States(2).x  ; op_report.States(3).x];
x0_initial = [op_report.States(1).x ];
y0_initial = [op_report.Outputs(1).y;op_report.Outputs(2).y];
u0_initial = [op_report.Inputs(1).u;op_report.Inputs(2).u];
%%
% Obtain linear model at the initial condition.
plant_initial = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_initial = c2d(plant_initial,Ts);
%%
% Specify signal types and names used in MPC.
plant_initial.InputGroup.ManipulatedVariables = 2;
plant_initial.OutputGroup.Measured = 2;
plant_initial.InputName = {'qc','q'};
plant_initial.OutputName = {'Ca','T'};

%% Obtain Linear Plant Model at Intermediate Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

%%
% qc
op.Inputs(1).u = 102.5; %102.5
op.Inputs(1).Known = true;
% q
op.Inputs(2).u = 105.3125; %105.3125
op.Inputs(2).Known = true;

% Ca
op.Outputs(1).y = 0.0866; %0.07
op.Outputs(1).Known = true;
% T
op.Outputs(2).y = 442.623; %450
op.Outputs(2).Known = true;
%%
% Find steady state operating condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
% x0_intermediate = [op_report.States(1).x ; op_report.States(2).x  ; op_report.States(3).x];
x0_intermediate = [op_report.States(1).x ];
y0_intermediate = [op_report.Outputs(1).y;op_report.Outputs(2).y];
u0_intermediate = [op_report.Inputs(1).u;op_report.Inputs(2).u];
%%
% Obtain linear model at the initial condition.
plant_intermediate = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_intermediate = c2d(plant_intermediate,Ts);
%%
% Specify signal types and names used in MPC.
plant_intermediate.InputGroup.ManipulatedVariables = 2;
plant_intermediate.OutputGroup.Measured = 2;
plant_intermediate.InputName = {'qc','q'};
plant_intermediate.OutputName = {'Ca','T'};

%% Obtain Linear Plant Model at Final Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

% %%
% qc is known at the initial condition.
%op.Inputs(1).u = 108.125; %108.125
%op.Inputs(1).Known = true;
% q
%op.Inputs(2).u = 100.1563; %100.1563
%op.Inputs(2).Known = true;

% Ca
op.Outputs(1).y = 0.1196; %0.02
op.Outputs(1).Known = true;
% T
op.Outputs(2).y = 434.737; %480
op.Outputs(2).Known = true;

%%
% Find steady state operating condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
% x0_final = [op_report.States(1).x ; op_report.States(2).x  ; op_report.States(3).x];
x0_final = [op_report.States(1).x ];
y0_final = [op_report.Outputs(1).y;op_report.Outputs(2).y];
u0_final = [op_report.Inputs(1).u;op_report.Inputs(2).u];
%%
% Obtain linear model at the initial condition.
plant_final = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_final = c2d(plant_final,Ts);
%%
% Specify signal types and names used in MPC.
plant_final.InputGroup.ManipulatedVariables = 2;
plant_final.OutputGroup.Measured = 2;
plant_final.InputName = {'qc','q'};
plant_final.OutputName = {'Ca','T'};

%% Construct Linear Parameter Varying System
% You can use an LTI array to store the three linear plant models obtained
% in previous sections.
lpv(:,:,1) = plant_initial;
lpv(:,:,2) = plant_intermediate;
lpv(:,:,3) = plant_final;
%%
% Specify T as the scheduling parameter. 
lpv.SamplingGrid = struct('T',[y0_initial(1); y0_intermediate(1); y0_final(1)]);
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
Np = 100; %30
Nu = 25; %2

mpcobj_lpv= mpc(plant_initial, Ts, Np, Nu);
mpcobj_lpv.Model.Nominal = struct('X',x0_initial,'U',u0_initial,'Y',y0_initial,'DX', [0 0]);


%% specify overall adjustment factor applied to weights
beta = 1.6;%1.0
%% specify weights
mpcobj_lpv.Weights.MV = [0 0]*beta;
mpcobj_lpv.Weights.MVRate = [0.02 0.02]/beta;
mpcobj_lpv.Weights.OV = [1 10]*beta;
mpcobj_lpv.Weights.ECR = 100000;


mpcobj_lpv.MV(1).Min = 60;
mpcobj_lpv.MV(1).Max = 120;

mpcobj_lpv.MV(2).Min = 95;
mpcobj_lpv.MV(2).Max = 150;

mpcobj_lpv.OutputVariables(1).Min = 0.02;
mpcobj_lpv.OutputVariables(1).Max = 0.15;

mpcobj_lpv.OutputVariables(2).Min = 430;
mpcobj_lpv.OutputVariables(2).Max = 490;

mpcobj_lpv.MV(1).RateMin = -10;
mpcobj_lpv.MV(1).RateMax = 10;
% 
mpcobj_lpv.MV(2).RateMin = -10;
mpcobj_lpv.MV(2).RateMax = 10;
