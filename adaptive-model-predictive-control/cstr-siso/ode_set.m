 function dxdt = ode_set(x,u,d)   
      x_1 = x(1);
      x_2 = x(2);

      qc = u(1);
      q = d(1);
      
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
      
      dx_1dt = ((q/v)*(Ca0 - x_1)) - (k*x_1*exp(-E_R/x_2)); 
      dx_2dt = ((q/v)*(T0 - x_2)) - (((deltaH*k*x_1)/(rho*cp))*exp(-E_R/x_2)) + ((rho_c*cpc)/(rho*cp*v))*qc*(1- exp(-HA/(qc*rho*cp)))*(Tc0-x_2);
      %dx_2dt = (q/v)*(T0 - x_2) - ((deltaH*k*x_1)/(rho*cp))*exp((-E_R)*(1/x_2))+((rho_c*cpc)/(rho*cp*v))*qc*(1-exp((-HA)/(qc*rho*cp)))*(Tc0-x_2);
      
      dxdt = [dx_1dt; dx_2dt];
 end