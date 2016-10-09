function [B,W,R,F,P,RhoR,RhoF,acceptR,acceptF] = sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX)
%SAMPLEPARAMETERS Gibbs sampler to estimate Mixed Logit models

% i)   update mean of random parameters (b)
% B = nextB(W,R);

% ii)  update covariance matrix of random parameters (W)
% W = nextW(B,R);

% iii) update vector of individual specific coefficients (R) and Rho
% [R,P,RhoR,acceptR] = nextR(B,W,R,F,P,RhoR,MODEL_FX,MODEL_RD,CHOICEIDX);

% iv)  update fixed parameters (alphas)
acceptR = 0;
[F,P,RhoF,acceptF] = nextF(R,F,P,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);

end

