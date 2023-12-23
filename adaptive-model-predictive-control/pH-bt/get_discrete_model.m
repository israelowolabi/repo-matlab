function [A_d, B_d, C_d, D_d] = get_discrete_model(y, x, u, d, Ts)

    qb = u(1);
    qa = d(1);
    kx = 10^-7;
    kw = 10^-14;
    
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    

    pH = y(1);   
    
    A = [ - (2*qa)/5 - (2*qb)/5,       0,         0;
                    0, - (2*qa)/5 - (2*qb)/5,     0;
                    0,        0, - (2*qa)/5 - (2*qb)/5 ];
          
    B = [ -(2*x1)/5 ; 1/1250 - (2*x2)/5 ; 1/1000 - (2*x3)/5];
    
    C = [-1/(log(10)/10^pH + 10^pH*kw*log(10) + (kx*x3*log(10))/(10^pH*kw*(kx/(10^pH*kw) + 1)^2)),...
         1/(log(10)/10^pH + 10^pH*kw*log(10) + (kx*x3*log(10))/(10^pH*kw*(kx/(10^pH*kw) + 1)^2)),...
         -(1/(kx/(10^pH*kw) + 1) - 1)/(log(10)/10^pH + 10^pH*kw*log(10) + (kx*x3*log(10))/(10^pH*kw*(kx/(10^pH*kw) + 1)^2))];
    
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
