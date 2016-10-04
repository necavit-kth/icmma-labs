function [F_new,P_new,acceptF] = nextF(R,F,P)
%NEXTF Updates fixed parameters of the Mixed Logit model, by using
% a Metropolis-Hastings sampler solution

% initialization
global N_FX CHOICEIDX % TODO: consider refactoring the freaking code
RhoFx = 0.1; % TODO: pass as parameter

% create vector of candidates for the new fixed parameters
F_cand = F + RhoFx * randn(N_FX, 1);

% calculate logit probabilities with the new fixed parameters and the
%  current estimated random parameters
P_all_alternatives = Logit_HB(F_cand,R);

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
F_new = F * (1 - acceptF) + F_cand * acceptF;
P_new = P * (1 - acceptF) + P_cand * acceptF;

end

