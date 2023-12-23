pH_const = struct();
pH_const.ts = 10;
[x_0, u_0, d_0] = get_init_op();
pH_const.x_0 = x_0;
pH_const.d_0 = d_0;
pH_const.u_0 = u_0;
% sim('pH_control_loops');