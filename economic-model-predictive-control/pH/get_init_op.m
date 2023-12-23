function [x_0, varargout] = get_init_op()
   x_0 = [-4.32e-4; 5.28e-4];
   u_0 = 15.6;
   d_0 = 0.55;
   if (nargout > 1)
       varargout{1} = u_0;
   end
   if (nargout > 2)
       varargout{2} = d_0;
   end
end