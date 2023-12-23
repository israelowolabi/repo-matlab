function [y_pred,x_pred,Ec] = state_predictor(x,dec_var,d,Nu,Np,ts)
    Ec = zeros(Np, 1);

    %u = cell((dim(dec_var)/2),1);
    u = num2cell(dec_var);
    
    %u{1} = [u(1),u(Nu+1)];
    x_pred(1,:) = get_next_state(x,u{1},d,ts);
    [~,y,c] = ode_set(x_pred(1,:),u{1},d);
    y_pred(1,:) = y;
    Ec(1) = c;
  
    for i = 2:Nu
        %u{i} = [u(i),u(Nu+i)];
        x_pred(i,:) = get_next_state(x_pred(i-1,:),u{i},d,ts);
        [~,y,c] = ode_set(x_pred(i,:),u{i},d);
        y_pred(i,:) = y;
        Ec(i) = c;
    end
    
    if (Np > Nu)
        for i = Nu+1:Np
            %u{i} = [u(Nu),u(2*Nu)];
            x_pred(i,:) = get_next_state(x_pred(i-1,:),u{Nu},d,ts);
            [~,y,c] = ode_set(x_pred(i,:),u{Nu},d);
            y_pred(i,:) = y;
            Ec(i) = c;
        end
    end
end

function x_pred = get_next_state(x,u,d,ts)
    % x must be a row vector, if its not, it will be transposed.
    % get_next_state will always return the predicted state as a row vector
    dim_x = size(x);
    if ((numel(x) > 1) && (dim_x(1) ~= 1))
        x = x';
    end
    
    %Note that ts must be a multiple of h
    h = 10;
    steps = ts/h;
    x_estim = zeros(steps+1,numel(x));
    x_estim(1,:) = x;
    
    for i = 2:steps+1
        k1 = h*ode_set(x_estim(i-1,:),u,d);
        k2 = h*ode_set(x_estim(i-1,:)'+(k1/2),u,d);
        k3 = h*ode_set(x_estim(i-1,:)'+(k2/2),u,d);
        k4 = h*ode_set(x_estim(i-1,:)'+k3,u,d);
        x_estim(i,:) = x_estim(i-1,:)' + (1/6)*(k1 + (2*k2) + (2*k3) + k4); 
    end
    
    x_pred = x_estim(end,:);
end