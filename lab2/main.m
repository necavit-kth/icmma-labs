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
[MODEL_FX, MODEL_RD] = specifyModel(D);
N_fx = MODEL_FX.n;
N_rd = MODEL_RD.n;
Labels_fx = MODEL_FX.labels;
Labels_rd = MODEL_RD.labels;
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
Nburnin = 100000;
burnInSaveStep = 100;
burnInPlotStep = 500;
  
  % fire up the burn-in!!
[B,W,R,F,P,RhoR,RhoF] = gibbsSampler_burnIn(...
                          Nburnin,burnInSaveStep,burnInPlotStep,...
                          B,W,R,F,P,RhoR,RhoF,...
                          MODEL_FX,MODEL_RD,CHOICEIDX);

  % Gibbs sampling
samplesToSave = 200;
samplingSaveStep = 100;
[samplesB,samplesW,samplesR,samplesF,samplesP] = gibbsSampler(...
                          samplingSaveStep,samplesToSave,...
                          N_obs,...
                          B,W,R,F,P,RhoR,RhoF,...
                          MODEL_FX,MODEL_RD,CHOICEIDX);

% 3. Calculate means and variances of the posterior distributions
%     and print the resulting model
fprintf('\n\n**** **** **** **** MODEL SPECIFICATION **** **** **** ****\n');

  % fixed parameters
Fmean = mean(samplesF,2); % average by row
Fcovar = cov(samplesF'); % transposed to make observations into rows
fprintf('Fixed parameters\n');
fprintf('%-20s : %8s %8s %8s\n','parameter','mean','stdev','t-test');
fprintf('-------------------------------------------------\n');
for i = 1 : N_fx
  fprintf('%-20s : %8.2f %8.2f %8.2f\n',...
    Labels_fx{i},...
    Fmean(i),...
    sqrt(Fcovar(i,i)),...
    Fmean(i)/sqrt(Fcovar(i,i)));
end

  % log-likelihood estimation
LL = sum(log(mean(samplesP,2)));
fprintf('\nLog-likelihood: %8.2f\n',LL);

if N_rd == 0
  % VoT calculation for an MNL
  alpha_cartime = Fmean(ismember(Labels_fx,'car_time')); 
  alpha_carcost = Fmean(ismember(Labels_fx,'car_cost'));
  alpha_PTtime = Fmean(ismember(Labels_fx,'PT_time'));
  alpha_PTcost = Fmean(ismember(Labels_fx,'PT_cost'));

  cVoT = alpha_cartime/alpha_carcost; %VoT for car
  pVoT = alpha_PTtime/alpha_PTcost; %VoT for PT
  
  fprintf('\n(mean) Value of Time (VoT) for CAR: %4.1f (SEK/h)', cVoT);   
  fprintf('\n(mean) Value of Time (VoT) for PT: %4.1f (SEK/h)\n', pVoT);
end

  % random parameters - population params


  
  
  
  % **************+ TODO *****************


  
  



% sigma=sqrt(diag(W));
% tvalues = beta./sigma;  % Calculate t-values
% 
% F = beta(I_F); % Fixed parameters
% tval_F = tvalues(I_F); % t-values for fixed parameters
% B = beta(I_R);
% tval_B = tvalues(I_R);
% 
% cholW = zeros(N_RD);
% tvalues_W = zeros(N_RD);
% 
% cholW(idx_cov) = beta(I_W);
% tvalues_W(idx_cov) = tvalues(I_W);
% W = cholW*cholW';

% fprintf('Random parameters - population parameters\n');
% fprintf('%-20s : %10s %8s %14s %8s %14s\n',...
%   'parameter','dist.','mean','t-test (mean)','stdev','t-test (stdev)');
% for i = 1 : length(B)
%   fprintf('%-20s : %10s %8.2f %14.2f %8.2f 14.2f\n',...
%     Labels_rd{i},...
%     B(i),...
%     B(i)/sqrt(Fcovar(i,i))...
%   );
% end


% fprintf('\n%-10s : %-10s %-8s %-8s %-8s %-8s \n' , ['Parameter'],['Dist.'],['Mean'],['t_mean'],['Std.'],['t_std'] );
% for k = 1:N_RD
%       fprintf('%-10s : %-10s %+-8.2g %-8.2g %-8.2g %-8.2g \n', LAB_RD{k} ,DIST_RD{k}, B_t(k) ,tval_B(k), sqrt(diagW(k)),diagT(k) )
% end
% 
% fprintf('\n\nValue of time (VoT) for car: %4.1f (SEK/h)', cVoT);   
% fprintf('\nValue of time (VoT) for public transit: %4.1f (SEK/h)', pVoT);
