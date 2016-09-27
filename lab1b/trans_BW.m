function [ B_new , W_new ] = transBW( B , W )
%UNTITLED2 transform mean and variance so that the 
%   
global I_BETA_RD
B_new = B; 
W_new = diag(W);

[B_new(I_BETA_RD.log_normal) , W_new(I_BETA_RD.log_normal)] = ...
n2logn_BW(B_new(I_BETA_RD.log_normal) , W_new(I_BETA_RD.log_normal));
end

