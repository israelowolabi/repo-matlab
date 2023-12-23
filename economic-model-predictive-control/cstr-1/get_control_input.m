function [u, u_integral, cost] = get_control_input(x_present, u_past, tp, u_integral, t_now, MPC_type, ts)
    t_step = ceil((t_now + 0.05*ts)/ts);
    n_op = 5;
    op_step = rem(t_step, n_op);
    if (op_step == 0)
       op_step = 5; 
    end
    if (op_step == 1)
       u_integral = 0; 
    end
    data = struct();
    data.n_op = n_op;
    data.Nu = n_op - op_step + 1;
    disp('t_step');
    disp(t_step);
    disp('Nu');
    disp(data.Nu);
    data.u_integral = u_integral;
    data.u_past = u_past;
    data.x_present = x_present;
    data.MPC_type = MPC_type;
    data.ts = ts;
    data.Np = data.Nu;
    data.W_stage = tp(1);
    data.W_du1 = tp(2);
    data.W_du2 = tp(3);
    data.x1_min = 0; data.x2_min = 0; data.x3_min = 0; data.x4_min = 0;
    data.x1_max = 10; data.x2_max = 10; data.x3_max = 10; data.x4_max = 10;
    data.du1_min = -0.1; data.du2_min = -0.1;
    data.du1_max = 0.1; data.du2_max = 0.1;
    data.u1_min = 0.0704; data.u2_min = 0.2465;
    data.u1_max = 0.7043; data.u2_max = 2.4648;

    %Converts u_min and u_max to a column vector with a dimension equal
    %to the magnitude of the control horizon. These vectors will be used
    %by the optimization function
    data.u_min_colvector = [data.u1_min*ones(data.Nu,1);data.u2_min*ones(data.Nu,1)];
    data.u_max_colvector = [data.u1_max*ones(data.Nu,1);data.u2_max*ones(data.Nu,1)];
    
    data.u_initial_colvector = [u_past(1)*ones(data.Nu,1);u_past(2)*ones(data.Nu,1)];

    OPTIONS = optimset('Algorithm','sqp','Display','final');
    [u_k, fval] = fmincon(@(u)compute_cost(u,data),data.u_initial_colvector,[],[],[],[],data.u_min_colvector,data.u_max_colvector,@(u)nlcf(u,data),OPTIONS);
    u  = [u_k(1); u_k(data.Nu + 1)];
    cost = fval;
    [~,~,du_integraldt] = ode_set(x_present, u);
    u_integral = u_integral + du_integraldt*ts;
end

function cost = compute_cost(u,data)
    %This function returns the cost or performance index, J of implementing a
    %vector u of control moves on the plant.
    Nu = data.Nu;
    Np = data.Np;
    
    u1 = zeros(Nu,1); u2 = zeros(Nu,1);
    for i = 1:Nu
        u1(i,:) = u(i);
    end
    for i = 1:Nu
        u2(i,:) = u(Nu+i);
    end
    
    %Input rate vector with a dimension of Nu
    du1 = zeros(Nu,1); du2 = zeros(Nu,1);
    du1(1) = u1(1) - data.u_past(1);
    du2(1) = u2(1) - data.u_past(2);
    for i = 2:Nu
        du1(i) = u1(i) - u1(i-1);
    end
    for i = 2:Nu
        du2(i) = u2(i) - u2(i-1);
    end
    
    cost_du = du1'*data.W_du1*du1 + du2'*data.W_du2*du2;
    [x_k, stage_cost] = state_predictor(data.x_present,u,Nu,Np,data.ts,data.u_integral);
    
    if (data.MPC_type == 1)
        cost = cost_du + (1/sum(stage_cost));
        return
    end
    cost = cost_du + data.W_stage*sum((x_k(:,1) - 0.998).^2 + (x_k(:,2) - 0.424).^2 + (x_k(:,3) - 0.032).^2 + (x_k(:,4) - 1.002).^2);
end
function [c,ceq] = nlcf(u,data)
    %This evaluates the nonlinear inequality constraints which are bound
    %to the problem. nlcf returns two major parameters: c and ceq. c is the nonlinear
    %inequality constraint function while ceq is the nonlinear equality constraint
    %function.

    Nu = data.Nu;
    Np = data.Np;
    
    u1 = zeros(Nu,1); u2 = zeros(Nu,1);
    for i = 1:Nu
        u1(i) = u(i);
    end
    for i = 1:Nu
        u2(i) = u(Nu+i);
    end
    
    %Input rate vector with a dimension of Nu
    du1 = zeros(Nu,1); du2 = zeros(Nu,1);
    du1(1) = u1(1) - data.u_past(1);
    du2(1) = u2(1) - data.u_past(2);
    for i = 2:Nu
        du1(i) = u1(i) - u1(i-1);
    end
    for i = 2:Nu
        du2(i) = u2(i) - u2(i-1);
    end
    
    [x_k,~,u_integral]  = state_predictor(data.x_present,u,Nu,Np,data.ts,data.u_integral);
    
    ineq_du1_min = data.du1_min*ones(Nu,1) - du1;
    ineq_du2_min = data.du2_min*ones(Nu,1) - du2;
    ineq_du1_max = du1 - data.du1_max*ones(Nu,1);
    ineq_du2_max = du2 - data.du2_max*ones(Nu,1);
    ineq_x1_min = data.x1_min*ones(Np,1) - x_k(:,1);
    ineq_x2_min = data.x2_min*ones(Np,1) - x_k(:,2);
    ineq_x3_min = data.x3_min*ones(Np,1) - x_k(:,3);
    ineq_x4_min = data.x4_min*ones(Np,1) - x_k(:,4);
    ineq_x1_max = x_k(:,1) - data.x1_max*ones(Np,1);
    ineq_x2_max = x_k(:,2) - data.x2_max*ones(Np,1);
    ineq_x3_max = x_k(:,3) - data.x3_max*ones(Np,1);
    ineq_x4_max = x_k(:,4) - data.x4_max*ones(Np,1);
    ineq_u1_min = data.u_min_colvector(1:Nu) - u1;
    ineq_u2_min = data.u_min_colvector(Nu+1:end) - u2;
    ineq_u1_max = u1 - data.u_max_colvector(1:Nu);
    ineq_u2_max = u2 - data.u_max_colvector(Nu+1:end);
%     disp('u_integral');
%     disp(u_integral);
    eq_u = (u_integral - 0.175*data.ts*data.n_op)*1;
    
    ceq = eq_u;
    
    c = [ineq_du1_min(1:end); ineq_du2_min(1:end); ineq_du1_max(1:end); ineq_du2_max(1:end);...
        ineq_x1_min(1:end); ineq_x1_max(1:end); ineq_x2_min(1:end); ineq_x2_max(1:end);...
        ineq_x3_min(1:end); ineq_x3_max(1:end); ineq_x4_min(1:end); ineq_x4_max(1:end);...
        ineq_u1_min(1:end); ineq_u2_min(1:end); ineq_u1_max(1:end); ineq_u2_max(1:end)];
    
    for i = 1:numel(c)
        if (c(i) == inf)
            c(i) = 1e23;
        end
        if (c(i) == -inf)
            c(i) = -1e23;
        end
    end
end