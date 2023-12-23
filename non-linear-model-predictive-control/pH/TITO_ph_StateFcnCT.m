function [dxdt, varargout] = TITO_ph_StateFcnCT(x, u)
 
    qb = u(1);
    qa = u(2);
    
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    
    x1i = 0.0012;
    x2i = 0.002;
    x3i = 0.0025;
    kx = 10^-7;
    kw = 10^-14;
    v = 2500e-3;
    %qa = 1;
    
    
    dx1dt = (qa *(x1i - x1) - qb * x1)/v;
    dx2dt = (-qa*x2 + qb*(x2i - x2))/v;
    dx3dt = (-qa*x3 + qb*(x3i - x3))/v;
    
    dxdt = [dx1dt;dx2dt;dx3dt];
    if (nargout == 2)
        opeqn = @(pH) 1e15*( 10^(-pH) + x2 + x3 - x1 - (kw/(10^(-pH))) -(x3/(1+((10^(-pH))*(kx/kw)))));
        varargout{1} = fsolve(opeqn, 7.01);
    end
 end
 
%  10^(-pH) + x2 + x3 - x1 - (kw/(10^(-pH))) -(x3/(1+(10^(-pH))*(kx/kw)))
 



