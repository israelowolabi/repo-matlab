% Specify sample time used by plant models and MPC controller
Ts = 0.5;
% Create operating point specification.
plant_mdl = 'openloopPH';
op = operspec(plant_mdl);
%%
% Feed concentration is known at the initial condition.
op.Inputs(1).u = 3;
op.Inputs(1).Known = true;

%% 
% Compute initial condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
x0_initial = [op_report.States(1).x];
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
plant_initial.InputName = {'u'};
plant_initial.OutputName = {'pH'};

%% Obtain Linear Plant Model at Intermediate Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

%%
% pH is known
op.Outputs(1).y = 3.5;
op.Outputs(1).Known = true;
%%
% Find steady state operating condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
x0_intermediate = [op_report.States(1).x];
y0_intermediate = [op_report.Outputs(1).y];
u0_intermediate = [op_report.Inputs(1).u];
%%
% Obtain linear model at the initial condition.
plant_intermediate = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_intermediate = c2d(plant_intermediate,Ts);
%%
% Specify signal types and names used in MPC.
plant_initial.InputGroup.ManipulatedVariables = 1;
plant_initial.OutputGroup.Measured = 1;
plant_initial.InputName = {'u'};
plant_initial.OutputName = {'pH'};

%% Obtain Linear Plant Model at Final Operating Condition
% Create operating point specification.
op = operspec(plant_mdl);

%%
% pH is known
op.Outputs(1).y = 0.5;
op.Outputs(1).Known = true;
%%
% Find steady state operating condition.
[op_point,op_report] = findop(plant_mdl,op); 
% Obtain nominal values of x, y and u.
x0_final = [op_report.States(1).x];
y0_final = [op_report.Outputs(1).y];
u0_final = [op_report.Inputs(1).u];
%%
% Obtain linear model at the initial condition.
plant_final = linearize(plant_mdl,op_point); 
% Discretize the plant model
plant_final = c2d(plant_final,Ts);
%%
% Specify signal types and names used in MPC.
plant_initial.InputGroup.ManipulatedVariables = 1;
plant_initial.OutputGroup.Measured = 1;
plant_initial.InputName = {'u'};
plant_initial.OutputName = {'pH'};

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
Np = 10;
Nu = 2;

mpcobj = mpc(plant_initial, Ts, Np, Nu);
mpcobj.Model.Plant.OutputUnit = {'cm'};

% Weight on variables is defined
mpcobj.Weights.OV = 1;
mpcobj.Weights.MV = 0;
mpcobj.Weights.MVRate = 100;

% Constraint on variables is defined.
mpcobj.MV.RateMin = -0.5;
mpcobj.MV.RateMax = 0.5;

mpcobj.MV.Min = 0;
mpcobj.MV.Max = 3;

mpcobj.OV(1).Min =1;
mpcobj.OV(1).Max = 14;




