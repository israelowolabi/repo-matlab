function [u,cost] = get_control_input(x_present,u_past,tp,MPC_type,ts)
    data = struct();
    data.u_past = u_past;
    data.x_present = x_present;
    data.MPC_type = MPC_type;
    data.ts = ts;
    data.Nu = tp(1);
    data.Np = tp(2);
    data.W_stage = tp(3);
    data.W_du = tp(4);
    data.x1_min = 0; data.x2_min = 0; data.x3_min = 0;
    data.x1_max = 10; data.x2_max = 10; data.x3_max = 10;
    data.du_min = -0.5;
    data.du_max = 0.5;
    data.u_min = 0.049;
    data.u_max = 0.449;
    
    %Converts u_min and u_max to a column vector with a dimension equal
    %to the magnitude of the control horizon. These vectors will be used
    %by the optimization function
    data.u_min_colvector = data.u_min*ones(data.Nu,1);
    data.u_max_colvector = data.u_max*ones(data.Nu,1);

    data.u_initial_colvector = data.u_past*ones(data.Nu,1);
    
    OPTIONS = optimset('Algorithm','sqp','Display','final');
    [u_k,fval] = fmincon(@(u)compute_cost(u,data),data.u_initial_colvector,[],[],[],[],data.u_min_colvector,data.u_max_colvector,@(u)nlcf(u,data),OPTIONS);
    
    u  = u_k(1);
    cost = fval;
end

function cost = compute_cost(u,data)
    %This function returns the cost or performance index, J of implementing a
    %vector u of control moves on the plant.
    Nu = data.Nu;
    Np = data.Np;
    
    %Input rate vector with a dimension of Nu
    du = zeros(Nu,1);
    du(1) = u(1) - data.u_past;
    for i = 2:Nu
        du(i) = u(i) - u(i-1);
    end
    
    cost_du = du'*data.W_du*du;
    
    x_k = state_predictor(data.x_present,u,Nu,Np,data.ts);
    
    if (data.MPC_type == 1)
        cost_stage = data.W_stage/sum(x_k(:,2));
        cost = cost_du + cost_stage;
        return;
    end
    cost = sum(data.W_stage*((x_k(:,2) - 0.0846).^2));
end

function [c,ceq] = nlcf(u,data)
    %This evaluates the nonlinear inequality constraints which are bound
    %to the problem. nlcf returns two major parameters: c and ceq. c is the nonlinear
    %inequality constraint function while ceq is the nonlinear equality constraint
    %function.

    Nu = data.Nu;
    Np = data.Np;

    x_k  = state_predictor(data.x_present,u,Nu,Np,data.ts);
    
    %Input rate vector with a dimension of Nu
    du = zeros(Nu,1);
    du(1) = u(1) - data.u_past;
    for i = 2:Nu
        du(i) = u(i) - u(i-1);
    end
    
    ineq_du_min = data.du_min*ones(Nu,1) - du;
    ineq_du_max = du - data.du_max*ones(Nu,1);
    ineq_x1_min = data.x1_min*ones(Np,1) - x_k(:,1);
    ineq_x2_min = data.x2_min*ones(Np,1) - x_k(:,2);
    ineq_x3_min = data.x3_min*ones(Np,1) - x_k(:,3);
    ineq_x1_max = x_k(:,1) - data.x1_max*ones(Np,1);
    ineq_x2_max = x_k(:,2) - data.x2_max*ones(Np,1);
    ineq_x3_max = x_k(:,3) - data.x3_max*ones(Np,1); 
    ineq_u_min = data.u_min_colvector(1:Nu) - u;
    ineq_u_max = u - data.u_max_colvector(1:Nu);
    
    ceq = [];
    
    c = [ineq_du_min; ineq_du_max; ineq_x3_min(1:end); ineq_x3_max(1:end); ineq_u_min; ineq_u_max;...
        ineq_x1_min(1:end); ineq_x1_max(1:end); ineq_x2_min(1:end); ineq_x2_max(1:end)];
    
    for i = 1:numel(c)
        if (c(i) == inf)
            c(i) = 1e23;
        end
        if (c(i) == -inf)
            c(i) = -1e23;
        end
    end
end