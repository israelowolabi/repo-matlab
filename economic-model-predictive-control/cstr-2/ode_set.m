function dxdt = ode_set(x, u)
    a1 = 1e4;
    a2 = 400;
    delta = 0.55;
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    dx1dt = -a1*exp(-1/x3)*(x1^2) - (a2*exp(-delta/x3)*x1) - x1 + 1;
    dx2dt = a1*exp(-1/x3)*(x1^2) - x2;
    dx3dt = -x3 + u;
    dxdt = [dx1dt; dx2dt; dx3dt];
end

