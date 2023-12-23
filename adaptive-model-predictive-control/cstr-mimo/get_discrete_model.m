function [A_d, B_d, C_d, D_d] = get_discrete_model(y, x, u, d, Ts)

qc = u(1);
q = d(1);

x_1 = x(1);
x_2 = x(2);


Ca = y(1);
T = y(2);

A = [ - q/100 - 72000000000*exp(-10000/x_2),  -(720000000000000*x_1*exp(-10000/x_2))/x_2^2;
     14400000000000*exp(-10000/x_2),        (qc*(exp(-700/qc) - 1))/100 - q/100 + (144000000000000000*x_1*exp(-10000/x_2))/x_2^2];

%A = [ - q/100 - 72000000000*exp(-10000/x_2),  (720000000000000*x_1*exp(-10000/x_2))/x_2^2;
%    -144000000000*exp(-10000/x_2),        (qc*(exp(-7/qc) - 1))/100 - q/100 - (1440000000000000*x_1*exp(-10000/x_2))/x_2^2];

 
B = [                                                                      0,         1/100 - x_1/100;
     ((x_2 - 350)*(exp(-700/qc) - 1))/100 + (7*exp(-700/qc)*(x_2 - 350))/qc,        7/2 - x_2/100];

%B = [                                                                      0,         1/100 - x_1/100;
%     ((x_2 - 350)*(exp(-7/qc) - 1))/100 + (7*exp(-7/qc)*(x_2 - 350))/(100*qc),        7/2 - x_2/100];


C = [1,0; 0,1];

D = [0, 0; 0, 0];

[dim_A, ~] = size(A);
%We have to use forward Euler discretization as an approximation  
%here because computing the inverse of A "destroys" the system
%The only consequence is a little loss in accuracy
    
    
%     A_d = eye(dim_A) + A*Ts ;
%     B_d = B*Ts ;
%     C_d = C ;
%     D_d = D ;

sysc = ss(A,B,C,D)  ;
sysd = c2d(sysc,Ts)  ;
[A_d, B_d , C_d, D_d] = ssdata(sysd) ;



end
