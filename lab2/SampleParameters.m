function [B,W,R,F,P,RhoR,acceptR,acceptF] = SampleParameters(B,W,R,F,P,RhoR)
%SAMPLEPARAMETERS Gibbs sampler to estimate Mixed Logit models

% i)   update mean of random parameters (b)
B = nextB(W,R);

% ii)  update covariance matrix of random parameters (W)
W = nextW(B,R);

% iii) update vector of individual specific coefficients (R) and Rho
[R,P,RhoR,acceptR] = nextR(B,W,R,F,P,RhoR);

% iv)  update fixed parameters (alphas)
[F,P,acceptF] = nextF(R,F,P);

end

