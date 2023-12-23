function [u,cost] = get_control_input(y_set,x_present,u_past,d,tp,MPC_type,ts)
    data = struct();
    data.u_past = u_past;
    data.x_present = x_present;
    data.MPC_type = MPC_type;
    data.ts = ts;
    data.d = d;
    data.y_set = y_set;
    data.Nu = tp(1);
    data.Np = tp(2);
    data.W_stage = tp(3);
    data.W_terminal = tp(4);
    data.W_du = tp(5);
    data.y_min = 1;
    data.y_max = 14;
    data.du_min = -15;
    data.du_max = 15;
    data.u_min = 0;
    data.u_max = 100;
    
    %Converts u_min and u_max to a column vector with a dimension equal
    %to the magnitude of the control horizon. These vectors will be used
    %by the optimization function
    data.u_min_colvector = data.u_min*ones(data.Nu,1);
    data.u_max_colvector = data.u_max*ones(data.Nu,1);

    data.u_initial_colvector = data.u_past*ones(data.Nu,1);
    
    OPTIONS = optimset('Algorithm','sqp','Display','final');
    [u_k,fval] = fmincon(@(u)compute_cost(u,data),data.u_initial_colvector,[],[],[],[],data.u_min_colvector,data.u_max_colvector,@(u)nlcf(u,data),OPTIONS);
    %disp(num2str(u_k(1)));
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
    
    [y_k, ~, E_c] = state_predictor(data.x_present,u,data.d,Nu,Np,data.ts);
    
    cost_terminal = data.W_terminal*(y_k(end) - data.y_set)^2;
    
    if (data.MPC_type == 1) %ENMPC
        cost_stage = E_c'*data.W_stage*E_c;
        %Comment the remaining code under this block to disable terminal  
        %constraints for ENMPC
        offset_terminal = abs(y_k(end) - data.y_set);
        [~,y_now] = ode_set(data.x_present, data.u_past, data.d);
        offset_now = abs(y_now - data.y_set);
        ineq_terminal = offset_terminal - 0.2*offset_now;
        if (ineq_terminal >= 0)
            cost_terminal = cost_terminal*1e15;
        end
    else
        cost_stage = (y_k' - data.y_set*ones(1,Np))*data.W_stage*(y_k - data.y_set*ones(Np,1));
    end
    
    cost = cost_du + cost_stage + cost_terminal;
end

function [c,ceq,x_k] = nlcf(u,data)
    %This evaluates the nonlinear inequality constraints which are bound
    %to the problem. nlcf returns two major parameters: c and ceq. c is the nonlinear
    %inequality constraint function while ceq is the nonlinear equality constraint
    %function.

    Nu = data.Nu;
    Np = data.Np;

    y_min_colvector = data.y_min*ones(Np,1);
    y_max_colvector = data.y_max*ones(Np,1);
    du_min_colvector = data.du_min*ones(Nu,1);
    du_max_colvector = data.du_max*ones(Nu,1);
    u_min_colvector = data.u_min_colvector(1:Nu);
    u_max_colvector = data.u_max_colvector(1:Nu);

    [y_k,x_k]  = state_predictor(data.x_present,u,data.d,Nu,Np,data.ts);
    
    %Input rate vector with a dimension of Nu
    du = zeros(Nu,1);
    du(1) = u(1) - data.u_past;
    for i = 2:Nu
        du(i) = u(i) - u(i-1);
    end
    
    ineq_du_min = du_min_colvector - du;
    ineq_du_max = du - du_max_colvector;
    ineq_y_min = y_min_colvector - y_k;
    ineq_y_max = y_k - y_max_colvector;
    ineq_u_min = u_min_colvector - u;
    ineq_u_max = u - u_max_colvector;
    
    ceq = [];
    
    c = [ineq_du_min; ineq_du_max; ineq_y_min; ineq_y_max; ineq_u_min; ineq_u_max];
    
    for i = 1:numel(c)
        if (c(i) == inf)
            c(i) = 1e23;
        end
        if (c(i) == -inf)
            c(i) = -1e23;
        end
    end
end