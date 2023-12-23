function [x_0, varargout] = get_init_op()
   x_0 = [0.0832; 0.0846; 0.149];
   u_0 = 0.149;
   % Replace x_0 and u_0 with this if you don't want to start from the optimal
   % point
   % x_0 = [0.3575; 0.05803; 0.1];
   % u_0 = 0.149;
   if (nargout > 1)
       varargout{1} = u_0;
   end
end