function [A_d, B_d, C_d, D_d] = get_discrete_model(y, x, u, d, Ts)

    m = u(1);
      F = d(1);
      N = x(1);
       pH = y(1);
      p2 = 0.001;
      p3 = 0.13;
      A = - (111*F)/10000 - (111*m)/10000;
    B = 111/10000 - (111*N)/10000;
    C = (p2/10^pH + 1/10^(2*pH))/(3/10^(3*pH)*log(10) - (log(10)*(p2*p3 - N*p2 + 1/100000000000000))/10^pH + 2/10^(2*pH)*log(10)*(N + p2));
    D = 0;


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
