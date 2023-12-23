function xk1 = TITO_ph_StateFcnDT(xk,uk)

Ts = 0.5;
xk1 = xk(:);
N = 2;  % Number of integration time steps for Euler method
dt = Ts/N;
uk1 = [uk(:);0;0];  % The manipulated input + white noise of size 2
for i = 1:N
    xk1 = xk1 + dt*TITO_ph_StateFcnCT(xk1,uk1);
end