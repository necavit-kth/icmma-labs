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
diary off;
filename = 'rvu_data_workNH.csv';
D = removeObservations(...
  loadData(filename),...
  {'mode','5','year','2006'});

% calculate the choices vectors
[CHOICE,CHOICEIDX] = calculateChoice(D);

% select the variables to include in the model and initialize useful
%  variables
[MODEL_FX, MODEL_RD] = specifyModel(D);
N_fx = MODEL_FX.n;
N_rd = MODEL_RD.n;
Labels_fx = MODEL_FX.labels;
Labels_rd = MODEL_RD.labels;
Dist_rd = MODEL_RD.dist;
N_obs = size(D.Data,1);


%%%% %%%% %%%% Model estimation initialization %%%% %%%% %%%%
% basically, allocate and resize the matrices accordingly
RhoR = 0.01;             % random parameters noise scale
RhoF = 0.005;            % fixed parameters noise scale
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
  % burn-in params
Nburnin = 80 * 1000;    % ***************************************************************** BURN IN SAMPLES
burnInSaveStep = 100;
burnInPlotStep = 500;
legends = 0; % boolean indicating whether to display the legends
  
  % fire up the burn-in!!
[B,W,R,F,P,RhoR,RhoF] = gibbsSampler_burnIn(...
                          Nburnin,burnInSaveStep,burnInPlotStep,legends,...
                          B,W,R,F,P,RhoR,RhoF,...
                          MODEL_FX,MODEL_RD,CHOICEIDX);

  % Gibbs sampling
samplesToSave = 2 * 100; % **************************************************************** SAMPLES TO SAVE
samplingSaveStep = 100;
[samplesB,samplesW,samplesR,samplesF,samplesP] = gibbsSampler(...
                          samplingSaveStep,samplesToSave,...
                          N_obs,...
                          B,W,R,F,P,RhoR,RhoF,...
                          MODEL_FX,MODEL_RD,CHOICEIDX);

% 3. Calculate means and variances of the posterior distributions
%     and print the resulting model
diary(sprintf('results/mixed_%s.txt',datestr(now,'HH-MM-SS')));
diary on;
fprintf('\n\nBurn-in draws: %6d\n',Nburnin);
fprintf('Samples: %5d\n',samplesToSave);
fprintf('Sample step: %5d\n',samplingSaveStep);
fprintf('\n**** **** **** **** MODEL SPECIFICATION **** **** **** ****\n');

% fixed parameters
Fmean = mean(samplesF,2); % average by row
Fcovar = cov(samplesF'); % transposed to make observations into rows

fprintf('Fixed parameters\n');
fprintf('-------------------------------------------------\n');
fprintf('%-20s : %8s %8s %8s\n','parameter','mean','stdev','t-test');
fprintf('-------------------------------------------------\n');
for i = 1 : N_fx
  fprintf('%-20s : %8.2f %8.2f %8.2f\n',...
    Labels_fx{i},...
    Fmean(i),...
    sqrt(Fcovar(i,i)),...
    Fmean(i)/sqrt(Fcovar(i,i)));
end
fprintf('-------------------------------------------------\n');

% random parameters - population params
Bmean = mean(samplesB,2);
Bcovar = cov(samplesB');
Wmean = mean(samplesW,2);
Wcovar = cov(samplesW');

fprintf('\nRandom parameters - population parameters\n');
fprintf('-------------------------------------------------------------------\n');
fprintf('%-20s : %10s %6s %9s %6s %9s\n',...
  'parameter','dist.','b','t-value','W','t-value');
fprintf('-------------------------------------------------------------------\n');
for i = 1 : N_rd
  fprintf('%-20s : %10s %6.2f %9.2f %6.2f %9.2f\n',...
    Labels_rd{i},...
    Dist_rd{i},...
    Bmean(i),...
    Bmean(i)/sqrt(Bcovar(i,i)),...
    Wmean(i),...
    Wmean(i)/sqrt(Wcovar(i,i))...
  );
end
fprintf('-------------------------------------------------------------------\n');

  % VoT calculation
% CAR
if sum(ismember(Labels_fx,'car_time')) && ...
    sum(ismember(Labels_fx,'car_cost'))
  cartime = Fmean(ismember(Labels_fx,'car_time')); 
  carcost = Fmean(ismember(Labels_fx,'car_cost'));
elseif sum(ismember(Labels_rd,'car_time')) && ...
    sum(ismember(Labels_rd,'car_cost'))
  cartime = Bmean(ismember(Labels_rd,'car_time')); 
  carcost = Bmean(ismember(Labels_rd,'car_cost'));
else
  fprintf('VoT calculation for CAR could not be performed.\nVariables%s',...
    ' for cost and time are not both random or both fixed');
end
% PT
if sum(ismember(Labels_fx,'PT_time')) && ...
    sum(ismember(Labels_fx,'PT_cost'))
  PTtime = Fmean(ismember(Labels_fx,'PT_time')); 
  PTcost = Fmean(ismember(Labels_fx,'PT_cost'));
elseif sum(ismember(Labels_rd,'PT_time')) && ...
    sum(ismember(Labels_rd,'PT_cost'))
  PTtime = Bmean(ismember(Labels_rd,'PT_time')); 
  PTcost = Bmean(ismember(Labels_rd,'PT_cost'));
else
  fprintf('VoT calculation for PT could not be performed.\nVariables%s',...
    ' for cost and time are not both random or both fixed');
end

cVoT = cartime/carcost; %VoT for car
pVoT = PTtime/PTcost; %VoT for PT
fprintf('\n(mean) Value of Time (VoT) for CAR: %4.1f (SEK/h)', cVoT);   
fprintf('\n(mean) Value of Time (VoT) for PT: %4.1f (SEK/h)\n', pVoT);

diary off;