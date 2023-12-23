function x_pred = state_predictor(x,dec_var,Nu,Np,ts)
    u = num2cell(dec_var);
    x_pred(1,:) = get_next_state(x,u{1},ts);
    for i = 2:Nu
        x_pred(i,:) = get_next_state(x_pred(i-1,:),u{i},ts);
    end
    if (Np > Nu)
        for i = Nu+1:Np
            x_pred(i,:) = get_next_state(x_pred(i-1,:),u{Nu},ts);
        end
    end
end

function x_pred = get_next_state(x,u,ts)
    % x must be a row vector, if its not, it will be transposed.
    % get_next_state will always return the predicted state as a row vector
    dim_x = size(x);
    if ((numel(x) > 1) && (dim_x(1) ~= 1))
        x = x';
    end
    
    %Note that ts must be a multiple of h
    steps = 100;
    h = ts/steps;
    x_estim = zeros(steps+1,numel(x));
    x_estim(1,:) = x;
    
    for i = 2:steps+1
        k1 = h*ode_set(x_estim(i-1,:),u);
        k2 = h*ode_set(x_estim(i-1,:)'+(k1/2),u);
        k3 = h*ode_set(x_estim(i-1,:)'+(k2/2),u);
        k4 = h*ode_set(x_estim(i-1,:)'+k3,u);
        x_estim(i,:) = x_estim(i-1,:)' + (1/6)*(k1 + (2*k2) + (2*k3) + k4); 
    end
    
    x_pred = x_estim(end,:);
end