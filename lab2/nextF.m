function [F_new,P_new,RhoF_new,acceptF] = nextF(R,F,P,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX)
%NEXTF Updates fixed parameters of the Mixed Logit model, by using
% a Metropolis-Hastings sampler solution

% create vector of candidates for the new fixed parameters
F_cand = F + RhoF * randn(length(F), 1);

% calculate logit probabilities with the new fixed parameters and the
%  current estimated random parameters
P_all_alternatives = logitHB(F_cand,R,MODEL_FX,MODEL_RD);

% select the probabilities of the observed choices estimated with
%  the candidate fixed parameters
P_cand = P_all_alternatives(CHOICEIDX);

% calculate the acceptance probability (Metropolis-Hastings)
P_accept = prod(P_cand./P);

% accept or reject the candidate parameters
r = rand; % uniformly distributed in the (0,1) range
% NOTE: to avoid using conditional statements (¬¬') do the following
%  trickery and consequently low-legible code:
acceptF = r < P_accept;

% TODO: update RhoF
RhoF_new = RhoF;

F_new = F * (1 - acceptF) + F_cand * acceptF;
P_new = P * (1 - acceptF) + P_cand * acceptF;

end

