function [R_new,P_new,RhoR_new,accShare] = nextR(B,W,R,F,P,RhoR,MODEL_FX,MODEL_RD,CHOICEIDX)
%NEXTR Updates the matrix of random parameters (betas)
% of the Mixed Logit model, by using a Metropolis-Hastings sampler

% useful variables
[N_rand,N_obs] = size(R);

% create vector of candidates for the new random parameters
R_cand = R + RhoR * chol(W)' * randn(N_rand,N_obs);

% calculate logit probabilities with the current fixed parameters and the
%  new, candidate, random parameters
P_all_alternatives = logitHB(F,R_cand,MODEL_FX,MODEL_RD);

% select the probabilities of the observed choices
P_cand = P_all_alternatives(CHOICEIDX);

% calculate the acceptance probability (Metropolis-Hastings)
%   i) calculate differences between betas and their mean, for both the
%      current and the candidate parameters
d_R_cand = R_cand - repmat(B,1,N_obs);
d_R = R - repmat(B,1,N_obs);

%   ii) calculate the phi quotient of the candidate over the current betas
phi_quotient = exp(-0.5 * ...
  (sum(d_R_cand .* (W \ d_R_cand),1) - sum(d_R .* (W \ d_R),1)));

%   iii) calculate the acceptance probability
P_accept = phi_quotient' .* P_cand ./ P;

% accept or reject the candidate parameters and update the step parameter
%  RhoR dynamically
r = rand(N_obs,1); % uniformly distributed in the (0,1) range
accept = r < P_accept;
accShare = sum(accept)/N_obs;

RhoR_new = RhoR - 0.001 .* (accShare < 0.3)...
                + 0.001 .* (accShare > 0.3);

% update the probabilites and parameters
P_new = P_cand .* accept + P .* (1-accept);
R_new = R_cand .* repmat(accept',N_rand,1)...
           + R .* repmat((1-accept'),N_rand,1);
         
end

