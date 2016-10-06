% ICMMA - Lab 2 - Hierarchical Bayes Mixed Logit modelling
% Author: David Martinez Rodriguez


%%%% %%%% %%%% Environment and data init %%%% %%%% %%%%
% prepare the data:
%   - load the data from 'filename' and remove missing observations,
%     mode choice 5 ('other') and year 2006.
%     NOTE: you can prepare a short dataset for test purposes by using:
%        DATA = RemoveObservations(DATA,{'short','20'});
filename = 'rvu_data_workNH.csv';
D = removeObservations(...
  loadData(filename),...
  {'mode','5','year','2006'});

% Calculate choice vector.
[CHOICE,CHOICEIDX] = calculateChoice(D);

% select the variables to include in the model and initialize useful
%  variables
[MODEL_FX, MODEL_RD] = specifyVariables(D);
N_FX = MODEL_FX.n;
N_RD = MODEL_RD.n;
LAB_FX = MODEL_FX.labels;
LAB_RD = MODEL_RD.labels;

%%%% %%%% %%%% Model initialization %%%% %%%% %%%%
N_obs = size(D,1);

% fixed parameters initialization: a vector of zeros
F = zeros(N_FX,1);

% initialize the means of the random parameters
B = zeros(N_RD,1);

% initialize covariance matrix for the random parameters
W = N_RD * eye(N_RD);

% initialize random parameters
R = repmat(B,1,N_obs) + chol(W)' * randn(N_RD,N_obs);


%%%% %%%% %%%% Model estimation %%%% %%%% %%%%
% 1. Estimate an initial model to get an initial set of parameters
  % estimate the logit probabilities for all alternatives
P = logitHB(F,R,MODEL_FX,MODEL_RD);

  % select the observed alternatives probabilities
P = P(CHOICEIDX);

% 2. Sample the parameters using the Gibbs-MH hierarchical sampler
RhoR = 0.01;
RhoF = 0.1;

  % burn-in
fprintf('\nGibbs/MH sampler burn-in... \n');
Nburnin = 20000;
burnInSaveStep = 100;
burnInPlotStep = 500;
burnInFSaved = [];
acceptF_total = 0;
for k = 1 : Nburnin
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,RhoF,acceptF] = sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);
  
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
  [B,W,R,F,P,RhoR,RhoF,acceptF] = sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);
  
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