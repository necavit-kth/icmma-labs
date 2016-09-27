%-------------------------------------------------------
% Function LL = LogLikelihood(beta)
%-------------------------------------------------------
function LL = LogLikelihood(beta)
global CHOICEIDX CHOICE  ;
F = beta; % Fixed parameters
R = []; % Random parameters

P=Logit(F , R);
P_choosen = P(CHOICEIDX);

LL = [];
%LL=[]; % WRITE YOUR LOG-LIKELIHOOD FUNCTION HERE

end


