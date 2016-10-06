%%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%%
% ICMMA - Lab 2 - Hierarchical Bayes Mixed Logit modelling
% (Co-)Author: David Martinez Rodriguez
%%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%%


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

% calculate the choices vectors
[CHOICE,CHOICEIDX] = calculateChoice(D);

% select the variables to include in the model and initialize useful
%  variables
[MODEL_FX, MODEL_RD] = specifyVariables(D);
N_fx = MODEL_FX.n;
N_rd = MODEL_RD.n;
Labels_fx = MODEL_FX.labels;
Labels_rd = MODEL_RD.labels;
N_obs = size(D.Data,1);


%%%% %%%% %%%% Model estimation initialization %%%% %%%% %%%%
% basically, allocate and resize the matrices accordingly
F = zeros(N_fx,1);       % fixed parameters
B = zeros(N_rd,1);       % means of the random parameters
W = N_rd * eye(N_rd);    % covariance matrix for the random parameters
R = repmat(B,1,N_obs)... % random parameters matrix
  + chol(W)'...
  * randn(N_rd,N_obs);


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
fprintf('\nGibbs/MH sampler burn-in...\n');
Nburnin = 20000;
burnInSaveStep = 100;
burnInPlotStep = 500;
burnInFSaved = [];
acceptF_total = 0;
acceptFSaved = [];
acceptR_total = 0;
acceptRSaved = [];
for k = 1 : Nburnin
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,RhoF,acceptR,acceptF] = ...
    sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);
  
  % update acceptance rates and plot them to visualize convergence
  acceptF_total = acceptF_total + acceptF;
  acceptR_total = acceptR_total + acceptR;
  if mod(k,burnInSaveStep) == 1
    fprintf('accept_F: %2.3f\taccept_R: %2.3f\n',...
      acceptF_total/burnInSaveStep,acceptR_total/burnInSaveStep);
    acceptFSaved= [acceptFSaved,(acceptF_total/burnInSaveStep)];
    acceptRSaved= [acceptRSaved,(acceptR_total/burnInSaveStep)];
    acceptF_total = 0;
    acceptR_total = 0;
    burnInFSaved = [burnInFSaved,F];
    nSaved = size(burnInFSaved,2);
  end
  if mod(k,burnInPlotStep) == 1
    subplot(ceil((N_fx + 1)/2),2,1);
    plot([1:nSaved]*100,acceptFSaved);
    ylabel('accept F rate','Interpreter','none');
    for i = 2 : (N_fx + 1)
      subplot(ceil((N_fx + 1)/2),2,i);
      plot([1:nSaved]*100,burnInFSaved(i-1,:));
      ylabel(Labels_fx{i-1},'Interpreter','none');
      xlabel('N_draws','Interpreter','none');
    end
    drawnow;
  end
end

  % Gibbs sampling
fprintf('\n\nGibbs/MH-sampling the posterior, after burn-in...\nProgress: ');
samplesToSave = 200;
samplingSaveStep = 100;
Nsampling = samplesToSave * samplingSaveStep;
fixedSaved = zeros(N_fx,samplesToSave);
for k = 1 : Nsampling
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,RhoF,acceptR,acceptF] = ...
    sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);
  
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
for i = 1 : N_fx
  fprintf('%-20s : %6.2f %6.2f\n',Labels_fx{i},Fmean(i),Fmean(i)/sqrt(Fcovar(i,i)));
end