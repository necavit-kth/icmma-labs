% ICMMA - Lab 2 - Hierarchical Bayes Mixed Logit modelling
% Author: David Martinez Rodriguez


%%%% %%%% %%%% Environment and data init %%%% %%%% %%%%
% initialize globals
global NDRAWS N_RD N_FX NP CHOICEIDX LAB_RD LAB_FX

% runtime parameters
NDRAWS = 1; 
updateDraws = 0; % whether to allow for mixed variables

% load the dataset and select the variables to include in the model
SpecifyVariables(updateDraws);


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
% 1. Estimate an initial model to get an initial set of parameters
  % estimate the logit probabilities for all alternatives
P = Logit_HB(F,R);

  % select the observed alternatives probabilities
P = P(CHOICEIDX);

% 2. Sample the parameters using the Gibbs-MH hierarchical sampler
RhoR = 0.01;

  % burn-in
fprintf('\nGibbs/MH sampler burn-in... \n');
Nburnin = 20000;
burnInSaveStep = 100;
burnInPlotStep = 500;
burnInFSaved = [];
acceptF_total = 0;
for k = 1 : Nburnin
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,acceptF] = SampleParameters(B,W,R,F,P,RhoR);
  
  % update acceptance rates and plot them to visualize convergence
  acceptF_total = acceptF_total + acceptF;
  if mod(k,burnInSaveStep) == 1
    fprintf('Acceptance rate for F: %2.3f\n', acceptF_total/100);
    acceptF_total = 0;
    burnInFSaved = [burnInFSaved,F];
    nSaved = size(burnInFSaved,2);
  end
  if mod(k,burnInPlotStep) == 1
    for i = 1 : N_FX
      subplot(ceil(N_FX/2),2,i);
      plot([1:nSaved]*100,burnInFSaved(i,:));
      ylabel(LAB_FX{i});
    end
    drawnow;
  end
end

  % Gibbs sampling
fprintf('\nGibbs-sampling the posterior, after burn-in... ');
samplesToSave = 200;
samplingSaveStep = 100;
Nsampling = samplesToSave * samplingSaveStep;
fixedSaved = zeros(N_FX,samplesToSave);
for k = 1 : Nsampling
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,acceptF] = SampleParameters(B,W,R,F,P,RhoR);
  
  % save sampled parameters
  if mod(k,samplingSaveStep) == 1
    fixedSaved(:,ceil(k/samplingSaveStep)) = F;
    if mod(k,samplingSaveStep*10) == 1
      fprintf('. ');
    end
  end
end

% 3. Calculate means and variances of the posterior distributions
%     and print the resulting model
fprintf('\n\n**** **** **** **** MODEL SPECIFICATION **** **** **** ****\n');

  % fixed parameters
Fmean = mean(fixedSaved,2); % average by row
Fcovar = cov(fixedSaved'); % transposed to make observations into rows
fprintf('Fixed parameters\n');
fprintf('%-20s : %6s %6s\n','Parameter','EST','T-test');
for i = 1 : N_FX
  fprintf('%-20s : %6.2f %6.2f\n',LAB_FX{i},Fmean(i),Fmean(i)/sqrt(Fcovar(i,i)));
end