%-------------------------------------------------------
% Individual Choice Modelling - Autum 2013
% MNLogit
% Tom Petersen, 2008
% Kandice Kreamer Fults, 2009
% Jonas Westin, 2009, 2010
% Daniel Jonsson, 2010
% Vivian Wang, 2012
% Shiva Habibi, 2013 ; inspired by Matlab code to estimate a mixed logit model with maximum simulated likelihood
% Written by Kenneth Train, August 9, 2006.
% Oskar V�stberg 2013
%-------------------------------------------------------
global N_FX LAB_FX CHOICE CHOICEMAT N_RD N_COV LAB_RD DIST_RD
global I_F I_R I_W I_BETA_RD
global NP NDRAWS DR 
global USE_TRANS
diary off 
run_name = 'Many mixed'; % Name that will be displayed 

% Since evaluating the simulated log-likelihood is computationally
% demanding, especially when the number of draws NDRAWS is high, the
% estimation is done in three steps. A) the MNL-version of the model is
% estimated. B) The mixed model is estimated, but with only 10 draws.
% C) the model is estimated with 100 draws.

% A) Estimate model with fixed parameters only, i.e, the MNL-version of the model

NDRAWS = 1; % Number of random draws used for SML
randn('seed',12)
rand('seed',12)
SpecifyVariables(0); 
DR = 0*randn(N_RD,NP*NDRAWS); % Random draws 

% Initial parameter values
beta_start = zeros(N_FX + N_RD + N_COV,1); 
beta_start(I_W) = 0.1;

fprintf('\n\nRUN MNL MODEL TO GET GOOD START POINT')
options = optimset('GradObj','off','LargeScale','off','Display','off','TolFun',1e-10,'TolX',1e-12','MaxFunEvals',10000,'MaxIter',1000);
USE_TRANS = 0;
beta_MNL= fminunc(@SimulatedLogLikelihood,beta_start,options);

[LL_MNL,g_MNL] = SimulatedLogLikelihood(beta_MNL);
LL_MNL = -LL_MNL;
fprintf('\nLog-likelihood with MNL-specification: %10.3f', LL_MNL);
% Save solution to use in B)
B = beta_MNL(I_R);
idx_cov = sub2ind([N_RD , N_RD] , I_BETA_RD.cov(:,1) , I_BETA_RD.cov(:,2));
cholW = zeros(N_RD);
cholW(idx_cov) = 0.1;
[B_trans,~] = transBW(B,cholW*cholW');
beta_start(I_F) = beta_MNL(I_F);
beta_start(I_R) = B_trans;
beta_start(I_W) = 0.1;

% B) Use 10 draws, and start from the parameter estimates in A)

fprintf('\n\n RUN WITH NDRAWS = 10\n')
 NDRAWS = 10; % Number of random draws used for SML
randn('seed',12)
rand('seed',12)
SpecifyVariables(1); 
DR = randn(N_RD,NP*NDRAWS); % Random draws 

USE_TRANS = 1; % use log-normal transformations, if there are such parameters
options = optimset('GradObj','on','LargeScale','off','Display','off','TolFun',1e-10,'TolX',1e-12','MaxFunEvals',10000,'MaxIter',1000);
[beta,fval,exitflag,output,grad,hessian]= fminunc(@SimulatedLogLikelihood,beta_start,options);

% C) Use 100 draws and start with the parameter estimates in B)
fprintf('\n\n RUN WITH NDRAWS = 100\n')
NDRAWS = 100; % Number of random draws used for SML
SpecifyVariables(1); 
DR = randn(N_RD,NP*NDRAWS); % Random draws 
beta_start = beta/10; % initial beta
options = optimset('GradObj','on','LargeScale','off','Display','iter-detailed','TolFun',1e-10,'TolX',1e-12','MaxFunEvals',10000,'MaxIter',1000);
[beta,fval,exitflag,output,grad,hessian]= fminunc(@SimulatedLogLikelihood,beta,options); % '@' is a handle for the LogLikelihood below

cov_mat = inv(hessian);
sigma=sqrt(diag(cov_mat)); 
tvalues = beta./sigma;  % Calculate t-values

F = beta(I_F); % Fixed parameters
tval_F = tvalues(I_F); % t-values for fixed parameters
B = beta(I_R);
tval_B = tvalues(I_R);

cholW = zeros(N_RD);
tvalues_W = zeros(N_RD);

cholW(idx_cov) = beta(I_W);
tvalues_W(idx_cov) = tvalues(I_W);
W = cholW*cholW';

[B_t , W_t] = transBWn2logn(B,W);

diagT = real(diag(tvalues_W));
diagW = diag(W_t); 

R = repmat(B,[1,NP,NDRAWS]) + reshape(cholW*DR,[N_RD,NP,NDRAWS]);

% Display Result  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Here are some examples of result that might be interesting to analyze.
% 1: Parameter estimates and t-values
% 2: Loglikelihood (LL) values
% 3: Null loglikelihood LL_0
% 4: Mcfadden rho
% 5: LL for alternative specific constants only
% 6: Value of Time for car and PT
% 7: Real and predicted choice probabilities
%
diary Result.out % save the result to the file Result.out
fprintf('\n\n\n----------------- RESULTS -------- %10s',run_name)

% 1: display parameter estimates and t-statistics

fprintf('\nFixed parameters: ')
fprintf('\n%-15s : %8s %8s \n' , ['Parameter'],['Estimate'],['t-value']);
for k = 1:N_FX
      fprintf('%-15s : %+8.2f %+8.2f \n', LAB_FX{k} , F(k) , tval_F(k))
end
fprintf('\nRandom parameters: ')
fprintf('\n%-10s : %-10s %-8s %-8s %-8s %-8s \n' , ['Parameter'],['Dist.'],['Mean'],['t_mean'],['Std.'],['t_std'] );
for k = 1:N_RD
      fprintf('%-10s : %-10s %+-8.2g %-8.2g %-8.2g %-8.2g \n', LAB_RD{k} ,DIST_RD{k}, B_t(k) ,tval_B(k), sqrt(diagW(k)),diagT(k) )
end

fprintf('\nCovariance Matrix:')
s_str = repmat('%-10s',1,N_RD);
n_str = repmat('%-10.2g',1,N_RD);
fprintf(['\n%9s ' ,s_str], [''],LAB_RD{:});
for k = 1:N_RD
      fprintf(['\n%9s ',n_str], LAB_RD{k} , W(k,:) )
end


% 2: Log Likelihood values
LL_B = -SimulatedLogLikelihood(beta);

fprintf('\nLog-likelihood: %10.3f', LL_B);

% 3: (change the value if needed in calculating the null loglikelihood LL_0) 
LL_0 = -SimulatedLogLikelihood(0*beta); % LL for zero model 
fprintf('\nLog-likelihood for zero beta: %10.3f', LL_0);
fprintf('\nLog-likelihood with MNL-specification: %10.3f', LL_MNL);
% 4: Goodness-of-fit
fprintf('\nMcFadden rho: %5.3f', 1-LL_B/LL_0); 

% 5: LL for alternative-specific constants only
% (according to first-order condition, compare sum_predchoice below)

I_walk = (CHOICE == 1); N_walk = sum(I_walk);
I_bike = (CHOICE == 2); N_bike = sum(I_bike); 
I_car = (CHOICE == 3); N_car = sum(I_car);
I_PT = (CHOICE == 4); N_PT = sum(I_PT);

sum_choices = [N_walk , N_bike , N_car , N_PT];
N_tot = sum(sum_choices);

LL_C = sum_choices*log(sum_choices/N_tot)'; 
fprintf('\nLog-likelihood for constants only: %6.2f', LL_C);

% 5: VoT for car and PT
I_Carcost = ismember(LAB_FX,'cost'); % Change here if name is changed in Specify Variables
I_PTcost = ismember(LAB_FX,'cost');
I_PTtime = ismember(LAB_FX,'PT_time');
I_Cartime = ismember(LAB_FX,'Car_time');

beta_cartime = beta(I_Cartime); 
beta_carcost = beta(I_Carcost);
beta_PTtime = beta(I_PTtime);
beta_PTcost = beta(I_PTcost);

cVoT = []; %WRITE YOUR OWN VoT
pVoT = [];

fprintf('\n\nValue of time (VoT) for car: %4.1f (SEK/h)', cVoT);   
fprintf('\nValue of time (VoT) for public transit: %4.1f (SEK/h)', pVoT);


% 7: Real and predicted choices
% Real choices
fprintf('\n\n Real Choices:')
fprintf('\n%8s %8s %8s %8s \n' , ['N_walk'],['N_bike'],['N_car'], ['N_PT']);
fprintf('%8.0f %8.0f %8.0f %8.0f ', sum_choices)
fprintf('\n%7.1f%% %7.1f%% %7.1f%% %7.1f%% ', 100*sum_choices/N_tot)

% Predicted choices 
fprintf('\nPredicted choices:')
ChoiceProb = Logit(F , trans(R));
ChoiceProb = mean(ChoiceProb,3)';

sum_predchoice = sum(ChoiceProb, 1);
fprintf('\n%8s %8s %8s %8s \n' , ['N_walk'],['N_bike'],['N_car'], ['N_PT']);
fprintf('%8.0f %8.0f %8.0f %8.0f ', sum_predchoice)
fprintf('\n%7.1f%% %7.1f%% %7.1f%% %7.1f%% ', 100*sum_predchoice/N_tot);

walk_cp = sum(ChoiceProb(I_walk,:),1)/N_walk*100; % Predicted choice probability for individuals that walked
bike_cp = sum(ChoiceProb(I_bike,:),1)/N_bike*100;
car_cp = sum(ChoiceProb(I_car,:),1)/N_car*100;
PT_cp = sum(ChoiceProb(I_PT,:),1)/N_PT*100;

fprintf('\n\n Predicted choice probability :')
fprintf('\n%8s %8s %8s %8s %8s' , [''] , ['p_walk'],['p_bike'],['p_car'], ['p_PT']);
fprintf('\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['walk'], walk_cp);
fprintf('\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['bike'], bike_cp );
fprintf('\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['car'], car_cp);
fprintf('\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['PT'], PT_cp);

diary off

