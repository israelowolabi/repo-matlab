function dxdt = TITO_CSTR_StateFcnCT(x,u)
% Continuous-time state equations for the exothermic CSTR
%
% The states of the CSTR model are:
%
%   x(1) = T        Reactor temperature [K]
%   x(2) = CA       Concentration of A in reactor tank [kgmol/m^3]
%   x(3) = Dist     State of unmeasured output disturbance
%
% The inputs of the CSTR model are:
%
%   u(1) = CA_i     Concentration of A in inlet feed stream [kgmol/m^3]
%   u(2) = T_i      Inlet feed stream temperature [K]
%   u(3) = T_c      Jacket coolant temperature [K]
%   u(4) = WN       White noise

% Copyright 1990-2018 The MathWorks, Inc.

% states
% Parameters

Ca0 = 1;
      T0 = 350;
      Tc0 = 350;
      v = 100;
      HA = 7e5;
      k = 7.2e10;
      E_R = 1e4;
      deltaH = -2e5;
      rho = 1e3;
      rho_c = 1e3;
      cp = 1;
      cpc = 1;


 
 
 %%% OUTPUT PARAMETERS
 x_1=x(1);
 x_2=x(2);


 %%% input parameters
 q=u(1);
 qc=u(2);


% Define input values at operating point:
    dxdt = zeros(2,1);
    
    dxdt(1) = ((q/v)*(Ca0 - x_1)) - (k*x_1*exp(-E_R/x_2)); 
    dxdt(2) = ((q/v)*(T0 - x_2)) - (((deltaH*k*x_1)/(rho*cp))*exp(-E_R/x_2)) + ((rho_c*cpc)/(rho*cp*v))*qc*(1- exp(-HA/(qc*rho*cp)))*(Tc0-x_2);
    

    
    

    
    



