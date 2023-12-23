function [dxdt, varargout] = ode_set(x, u)
    u1 = u(1);
    u2 = u(2);
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    x4 = x(4);
    
    gamma1 = -8.13;
    gamma2 = -7.12;
    gamma3 = -11.07;
    A1 = 92.80;
    A2 = 12.66;
    A3 = 2412.71;
    B1 = 7.32;
    B2 = 10.39;
    B3 = 2170.57;
    B4 = 7.02;
    Tc = 1.0;
    
    dx1dt = u1*(1 - x1*x4);
    dx2dt = u1*(u2 - x2*x4) - A1*exp(gamma1/x4)*((x2*x4)^0.5) - A2*exp(gamma2/x4)*((x2*x4)^0.25);
    dx3dt = (-u1*x3*x4) + (A1*exp(gamma1/x4)*((x2*x4)^0.5)) - (A3*exp(gamma3/x4)*((x3*x4)^0.5));
    dx4dt = (u1*(1 - x4)/x1) + ((B1/x1)*exp(gamma1/x4)*((x2*x4)^0.5)) + ((B2/x1)*exp(gamma2/x4)*((x2*x4)^0.25)) + ((B3/x1)*exp(gamma3/x4)*((x3*x4)^0.5)) - ((B4/x1)*(x4 - Tc));
    
    if (nargout > 1)
       varargout{1} = u1*x3*x4;
    end
    if (nargout > 2)
       varargout{2} = u1*u2;
    end
    
    dxdt = [dx1dt; dx2dt; dx3dt; dx4dt];
end

