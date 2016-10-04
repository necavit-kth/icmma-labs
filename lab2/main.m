% ICMMA - Lab 2 - Hierarchical Bayes Mixed Logit modelling
% Author: David Martinez Rodriguez


%%%% %%%% %%%% Environment and data init %%%% %%%% %%%%
% initialize globals
global NDRAWS N_RD N_FX CHOICEIDX LAB_RD LAB_FX

% runtime parameters
NDRAWS = 1; % number of draws in the HB sampler
isMixed = 0; % whether to allow for mixed variables

% load the dataset and select the variables to include in the model
SpecifyVariables(isMixed);


%%%% %%%% %%%% Model initialization %%%% %%%% %%%%
% fixed parameters initialization: a vector of zeros
F = zeros(N_FX,1);

% initialize the means of the random parameters
B = zeros(N_RD,1);

% initialize covariance matrix for the random parameters
W = N_RD * eye(N_RD);

% initialize random parameters
R = repmat(B,1,NP) + chol(W)' * randn(N_RD,NP);


%%%% %%%% %%%% Model estimation %%%% %%%% %%%%
% 1. Perform an initial model
  % estimate the logit probabilities for all alternatives
P = Logit_HB(F,R);

  % select the observed alternatives probabilities
P = P(CHOICEIDX);

% 2. Sample the parameters using the Gibbs-MH hierarchical sampler
RhoR = 0.01;
Nburnin = 60000;
fSaved = [];
acceptF_total = 0;

for k = 1 : Nburnin
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,acceptF] = SampleParameters(B,W,R,F,P,RhoR);
  
  % update acceptance rates and plot them to visualize convergence
  acceptF_total = acceptF_total + acceptF;
  if mod(k,100) == 1
    fprintf('Acceptance rate for F: %2.3f\n', acceptF_total/100);
    acceptF_total = 0;
    fSaved = [fSaved,F];
    nSaved = size(fSaved,2);
  end
  if mod(k,1000) == 1
    for i = 1 : N_FX
      subplot(ceil(N_FX/2),2,i);
      plot([1:nSaved*100,fSaved(i,:)]);
      ylabel(LAB_FX{i});
    end
    drawnow;
  end
  
end
