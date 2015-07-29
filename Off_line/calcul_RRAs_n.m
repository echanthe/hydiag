%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Mehdi Bayoudh, LAAS-CNRS, bayoudh@laas.fr%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%all rights reserved , Febrary 2010 (modified) %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% Function that computes the Analytic Redanduncy relations (ARRs) in case 
% of linear systems modelized by the following state and observation
% equations.

% X(n+1)=A.X(n)+B.U(n)
% Y(n)=C.X(n)+D.U(n)

% avec: 

% X: the state vector, it belongs to R^n
% Y: the vector of meseared output, it belongs to R^m
% U: the vector of inputs, it belongs to R^l
% A: a system dynamic matrix, sizeof(A)= n*n
% B: maatrix, sizes(B)= n*l
% C: mztrix sizeof(C)=m*n
% D: matrix, sizeof(D)=m*l

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

function [Wc_u,Wc_y,Op,Dp]=calcul_RRAs_n(A,B,C,D,n)

%Computation of Op
Op=C;
for j=1:n
Op=[Op;C*A^j];
end
%end of Op computation

%Computation of Dp
Dp=D;
[l_D,c_D]=size(D);
ZERO=zeros(l_D,c_D);
derniere_ligne=[];
derniere_colonne=[D];

for i=1:n
    derniere_ligne=[C*A^(i-1)*B,derniere_ligne];
    derniere_colonne=[ZERO;derniere_colonne];
    
    Dp=[Dp;derniere_ligne];
    Dp=[Dp,derniere_colonne];
end
%end of Dp computation

Op_t=Op.';      %the Op transpose
W_t=null(Op_t); %the W transpose
W=W_t.';

Wc_y=W;     %The calculation of the computation form,(le terme en Y(t,t-p))
Wc_u=-W*Dp; %The calculation of the computation form,(le terme en U(t,t-p))

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
