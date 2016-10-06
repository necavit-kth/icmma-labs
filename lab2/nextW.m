function W_new = nextW(B,R)
%NEXTW Updates the covariance matrix of the random parameters (betas)
% of the Mixed Logit model, drawing from an inverted gamma distribution
% with parameters:
%  - v_1 = 1 + N_obs
%  - s_1 = (1 + N_obs*s_bar)/v_1
% where s_bar is the variance of the beta params (R) around their mean B

% useful variables
[N_rand,N_obs] = size(R);

% **** **** Inverted Gamma parameters calculation **** ****
% calculate parameter v_1 of the inverted gamma distribution
v_1 = 1 + N_obs;

% calculate s_bar (the variance of betas around their mean)
s_bar = mean((R - repmat(B,1,N_obs)).^2,2);

% calculate parameter s_1 of the inverted gamma distribution
s_1 = (1 + N_obs*s_bar) / v_1;

% **** **** Inverted Gamma draw **** ****
% take v_1 draws from a standard normal distribution for each of the
%  beta parameters (each inverted gamma draw will be the beta covariance
%  element in the W_new matrix)
mu = randn(N_rand,v_1);

% calculate sample variance of a normal distribution with variance s_1
r = 1/v_1 * sum(mu.^2./repmat(s_1,1,length(mu)),2);

% **** **** Create the covariance matrix **** ****
W_new = diag(1./r);

end