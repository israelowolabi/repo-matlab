
%Define an operating point for the model 
u0= [103.41 100]';
x0= [0.1 436]';
% Defining the Three tank model we are working with
y0 =x0;

[A,B,C,D] = linmod('cstr_open',x0,u0);

cstr_mimo = ss(A,B,C,D);


cstr_mimo.InputName = {'qc','q'};
cstr_mimo.OutputName = {'Ca','T'};
cstr_mimo.StateName = {'x_1','x_2'};
cstr_mimo.InputGroup.MV = (1:2);
cstr_mimo.OutputGroup.MO = (1:2);


Ts = 0.3; %0.3

mpcobj_lmpc = mpc(cstr_mimo, Ts);
%% sprediction horizon
mpcobj_lmpc.PredictionHorizon = 100; %100
%%  control horizon
mpcobj_lmpc.ControlHorizon = 25; %2
mpc1.Model.Nominal.U = [103.4;100];
mpc1.Model.Nominal.Y = [0.1;436];
mpcobj_lmpc.Model.Nominal = struct ('X',x0 , 'U' , u0, 'Y', y0, 'DX', [0 0]);
mpcobj_lmpc.Model.Plant.OutputUnit = {'mol/L','K'};
%% To specify the constraints of the manipulated variable

%% To specify the constraints of the manipulated variable
% Weight on output variable is defined
mpcobj_lmpc.Weights.OV(1) = 1;
mpcobj_lmpc.Weights.OV(2) = 10;
mpcobj_lmpc.Weights.MV(1) = 0;
mpcobj_lmpc.Weights.MV(2) = 0;
mpcobj_lmpc.Weights.MVRate(1) = 0.02; %1
mpcobj_lmpc.Weights.MVRate(2) = 0.02; %1


mpcobj_lmpc.MV(1).Min = 60;
mpcobj_lmpc.MV(1).Max = 120;

mpcobj_lmpc.MV(2).Min = 95;
mpcobj_lmpc.MV(2).Max = 150;

mpcobj_lmpc.OutputVariables(1).Min = 0.02;
mpcobj_lmpc.OutputVariables(1).Max = 0.15;

mpcobj_lmpc.OutputVariables(2).Min = 430;
mpcobj_lmpc.OutputVariables(2).Max = 490;

mpcobj_lmpc.MV(1).RateMin = -10;
mpcobj_lmpc.MV(1).RateMax = 10;
% 
mpcobj_lmpc.MV(2).RateMin = -10;
mpcobj_lmpc.MV(2).RateMax = 10;
