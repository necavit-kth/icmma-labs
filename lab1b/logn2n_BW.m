function [ B , W ] =logn2n_BW( B_log , W_log )
% LOGN2N_BW calculates the mean B and variance W of a normal
% distribution such that exp(N(B,W.^2)) is distributed with mean B_log and
% variance W_log.^2
% 
% The inverse of n2logn_BW: [B_log,W_log] = n2logn_BW(B,W)
% 
% Oskar Västberg 2013-09-23
 
W = sqrt(log(W_log.^2 ./B_log.^2+1));
B = log(B_log) - (W.^2)/2; 

end

