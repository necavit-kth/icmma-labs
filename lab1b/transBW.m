function [ B_new , W_new ] = transBW( B , W )
%UNTITLED2 transform mean and variance so that the 
%   
global I_BETA_RD
B_new = B; 
W_new = W;
W_diag = diag(W);

[B_new(I_BETA_RD.log_normal) , W_diag(I_BETA_RD.log_normal)] = ...
logn2n_BW(B_new(I_BETA_RD.log_normal) , W_diag(I_BETA_RD.log_normal));
W_new = setdiag(W_new,W_diag);
end

