% Transform normally distributed terms into coefficients

% Input R is N_RDxNP. Contains normally distributed random parameters.
% Output C is N_RDxNP.
% I_RV.log_normal contains the indexes of the parameters that are
% log-normally distributed and should be transformed.

% Oskar Västberg 2013-08-28
function C=trans(R)
global I_BETA_RD USE_TRANS
C = R;
if USE_TRANS == 1
      C(I_BETA_RD.log_normal,:,:)= exp(C(I_BETA_RD.log_normal,:,:));
end