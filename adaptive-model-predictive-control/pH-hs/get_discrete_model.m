function [A_d, B_d, C_d, D_d] = get_discrete_model(y, x, u, d, Ts)

    q3 = u(1);
    q2 = d(1);
    
    Wa4 = x(1);
    Wb4 = x(2);

    pH = y(1);   
    
    A = [ - q2/2898 - q3/2898 - 83/14490,  0;
         0, - q2/2898 - q3/2898 - 83/14490];
    B = [- Wa4/2898 - 61/57960000;
           1/57960000 - Wb4/2898];
    C = [-1/(log(10)/10^pH + 10^(pH - 14)*log(10) + (Wb4*(2*10^(pH - pK2) + 1)*(10^(pK1 - pH)*log(10) - 10^(pH - pK2)*log(10)))/(10^(pK1 - pH) + 10^(pH - pK2) + 1)^2 + (2*10^(pH - pK2)*Wb4*log(10))/(10^(pK1 - pH) + 10^(pH - pK2) + 1)),...
        -(2*10^(pH - pK2) + 1)/((10^(pK1 - pH) + 10^(pH - pK2) + 1)*(log(10)/10^pH + 10^(pH - 14)*log(10) + (Wb4*(2*10^(pH - pK2) + 1)*(10^(pK1 - pH)*log(10) - 10^(pH - pK2)*log(10)))/(10^(pK1 - pH) + 10^(pH - pK2) + 1)^2 + (2*10^(pH - pK2)*Wb4*log(10))/(10^(pK1 - pH) + 10^(pH - pK2) + 1)))
        ];
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
