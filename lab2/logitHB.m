function P = logitHB(F,R,MODEL_FX,MODEL_RD)
%   LOGITHB(F,R) calculates the probability of all alternatives
% and the utility of each mode.  
%   F is a vector of the fixed parameters. The size is N_FX x 1, where N_FX is the number
% of fixed parameters.
%   R is a vector with individual specific parameters. Its size is N_RD x 1

% calculate logit probability
U = utilities(F,R,MODEL_FX,MODEL_RD);
maxU = max(U,[],2);
U = U - maxU(:,[1,1,1,1]);
expU = exp(U);
sum_exp = sum(expU,2); 

P = expU./sum_exp(:,[1,1,1,1]);

end