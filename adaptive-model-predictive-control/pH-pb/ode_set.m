 function [dxdt, varargout] = ode_set(x, u, d)
      m = u(1);
      F = d(1);
      N = x(1);
      
      p2 = 0.001;
      p3 = 0.13;
%    
      dNdt = 0.0111*(m-(F+m)*N);
%     
      dxdt = dNdt;
     if (nargout == 2)
        x1 = N;
        f = [1,(p2 + x1),(x1*p2 -10^(-14) -p2*p3),-(10^(-14)*p2)]  ;
        x2 = max(roots(f)) ;
        varargout{1} = -log10(x2);

     end
  end
 
