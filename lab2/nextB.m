function B_new = nextB(W,R)
%NEXTB Updates the vector of means of the random parameters (betas) of the
% Mixed Logit model, drawing from a normal distribution with parameters:
% - mean = mean(betas)
% - cov  = W/N

% useful variables
[N_rand,N_obs] = size(R);

% draw from a standard normal distribution the N_RD (number of beta params)
r = randn(N_rand,1);

% calculate the betas' means (column-wise)
R_mean = mean(R,2);

% calculate the correct covariance structure
rvar = chol(W)' * r;

% scale the covariance matrix
rvar = rvar./N_obs;

% return the new Bs (means)
B_new = R_mean + rvar;

end

