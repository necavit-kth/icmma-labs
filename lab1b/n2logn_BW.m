function [B_log, W_log]=n2logn_BW(B,W)
% N2LOGN_BW calculates the mean B_log and W_log of an log-normal
% distribution that is obtained using exp(N(B,W.^2))
% B is the mean and W.^2 the variance, and W is the standard
% deviation.
%    
% Oskar Västberg 2013-09-23
B_log = exp( B + (W.^2)/2 );
W_log = sqrt( exp( W.^2 ) - 1 ) .* B_log;

end