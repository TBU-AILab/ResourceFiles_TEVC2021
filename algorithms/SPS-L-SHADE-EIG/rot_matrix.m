
 
function M=rot_matrix(D,c)
if D>1
A=normrnd(0,1,D,D);
P=cGram_Schmidt(A);
A=normrnd(0,1,D,D);
Q=cGram_Schmidt(A);
u=rand(1,D);
D=c.^((u-min(u))./(max(u)-min(u)));
D=diag(D);
M=P*D*Q;
else
    M=1;
end
% classical Gram Schmid 
 function [q,r] = cGram_Schmidt (A)
% computes the QR factorization of $A$ via
% classical Gram Schmid 
% 
 [n,m] = size(A); 
 q = A;    
 for j=1:m
     for i=1:j-1 
         r(i,j) = q(:,j)'*q(:,i);
     end
     for i=1:j-1   
       q(:,j) = q(:,j) -  r(i,j)*q(:,i);
     end
     t =  norm(q(:,j),2 ) ;
     q(:,j) = q(:,j) / t ;
     r(j,j) = t  ;
 end 