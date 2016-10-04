function [B,W,R,F,P,RhoR,acceptF] = SampleParameters(B,W,R,F,P,RhoR)
%SAMPLEPARAMETERS Gibbs sampler to estimate Mixed Logit models

% i)   update mean of random parameters (b)
% ii)  update covariance matrix of random parameters (W)
% iii) update vector of individual specific coefficients (R) and Rho
% iv)  update fixed parameters (alphas)
[F,P,acceptF] = nextF(R,F,P);

end

