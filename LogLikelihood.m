%-------------------------------------------------------
% Function negLL = LogLikelihood(beta)
%-------------------------------------------------------
function negLL = LogLikelihood(beta)
global CHOICEIDX;
% Calculates the log-likelihood given the parameters beta. 
%   CHOICEIDX is the index of the choosen alternatives.   

F = beta; % Fixed parameters 
R = []; % Random parameters, use in mixed

P=Logit(F , R);
% P is a matrix containing the probability of all alternatives for all
% individuals. Its size is N_Obs x N_Alt. The index in the matrix corresponding to the
% choosen alternative for observation 'i' is CHOICEIDX(i).

P_choosen = P(CHOICEIDX);


% Observe that we wan't to maximize the likelihood, but matlab only
% provides minimization routines. Therefore you should write the negative
% log-likelihood here.
negLL = [];

%LL=[]; % WRITE YOUR LOG-LIKELIHOOD FUNCTION HERE


end


