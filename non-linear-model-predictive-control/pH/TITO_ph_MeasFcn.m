function y = TITO_ph_MeasFcn(x)
pH  = 7.01;
kx = 10^-7;
kw = 10^-14;
y = 1e15*( 10^(-pH) + x(2) + x(3) - x(1) - (kw/(10^(-pH))) -(x(3)/(1+((10^(-pH))*(kx/kw)))));
%y = fsolve(opeqn, 7.01);
%y = x(1);

