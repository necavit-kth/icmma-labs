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
global N_FX LAB_FX CHOICE

% Open results file
fid=fopen('results_v2.txt','a'); % open file descriptor
% WARNING!! remember that all results will be written to the same file!
fprintf(fid, '\nDate: %s', datestr(datetime('now')));

% Load, selected and transform data from file 'rvu_data_workNH.csv'
SpecifyVariables(fid);

% Initial parameter values
beta_start = zeros(N_FX,1); 

% Specifies optimization options. Read the output from the unconstrained
% minimization solver 'fminunc' to make sure that the algorithm converges
% to an optimal solution.
% Make sure that the program converges. Start with 'MaxFunEvals' 100 and
% increase until it converges. Read the output and look at the predictions.

 options = optimset('Display','iter-detailed','TolFun',1e-6,'TolX',1e-10','MaxFunEvals',100000,'MaxIter',1000);
 [beta,fval,exitflag,output,grad,hessian]= fminunc(@LogLikelihood,beta_start,options); % '@' is a handle for the LogLikelihood below
 
 % Calculate t-values
 sigma=sqrt(diag(inv(hessian)));
 tvalues = beta./sigma; 
 
%%%%%%%% Display Result  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(fid, '\n\n----------------- DISPLAY RESULTS ---------------------');
% Here are some examples of result that might be interesting to analyze.
% 1: Parameter estimates and t-values
% 2: Loglikelihood (LL) values
% 3: Null loglikelihood LL_0
% 4: Mcfadden rho
% 5: Value of Time for car and PT
% 6: Real and predicted choice probabilities

% 1: display parameter estimates and t-statistics

fprintf(fid, '\n%-15s : %8s %8s \n' , ['Parameter'],['Estimate'],['t-value']);
for k = 1:length(beta)
      fprintf(fid, '%-15s : %+8.2f %+8.2f \n', LAB_FX{k} , beta(k) , tvalues(k));
end


% 2: Log Likelihood values
LL_B = -LogLikelihood(beta);
fprintf(fid, '\nLog-likelihood: %10.3f', LL_B);

% 3: (change the value if needed in calculating the null loglikelihood LL_0) 
LL_0 = -LogLikelihood(0*beta); % LL for zero model 
fprintf(fid, '\nLog-likelihood for zero beta: %10.3f', LL_0);

% 4: Goodness-of-fit
fprintf(fid, '\nMcFadden rho: %5.3f', 1-LL_B/LL_0); 

% 5: VoT for car and PT
% Observe that the cost-parameter is the same for car and PT in the initial
% specification, but actual cost is different.
I_Carcost = ismember(LAB_FX,'car_cost'); % Change here if name is changed in Specify Variables
I_PTcost = ismember(LAB_FX,'PT_cost');
I_Cartime = ismember(LAB_FX,'car_time');
I_PTtime = ismember(LAB_FX,'PT_time');

beta_cartime = beta(I_Cartime); 
beta_carcost = beta(I_Carcost);
beta_PTtime = beta(I_PTtime);
beta_PTcost = beta(I_PTcost);

cVoT = beta_cartime/beta_carcost; %VoT for car
pVoT = beta_PTtime/beta_PTcost; %VoT for PT

fprintf(fid, '\n\nValue of time (VoT) for car: %4.1f (SEK/h)', cVoT);   
fprintf(fid, '\nValue of time (VoT) for public transit: %4.1f (SEK/h)', pVoT);


% 6: Real and predicted choices
% Real choices
I_walk = (CHOICE == 1); N_walk = sum(I_walk);
I_bike = (CHOICE == 2); N_bike = sum(I_bike); 
I_car = (CHOICE == 3); N_car = sum(I_car);
I_PT = (CHOICE == 4); N_PT = sum(I_PT);

sum_choices = [N_walk , N_bike , N_car , N_PT];
N_tot = sum(sum_choices);
fprintf(fid, '\n\n Real Choices:');
fprintf(fid, '\n%8s %8s %8s %8s \n' , ['N_walk'],['N_bike'],['N_car'], ['N_PT']);
fprintf(fid, '%8.0f %8.0f %8.0f %8.0f ', sum_choices);
fprintf(fid, '\n%7.1f%% %7.1f%% %7.1f%% %7.1f%% ', 100*sum_choices/N_tot);

% Predicted choices 
fprintf(fid, '\nPredicted choices:');
ChoiceProb = Logit(beta , []);

sum_predchoice = sum(ChoiceProb, 1);
fprintf(fid, '\n%8s %8s %8s %8s \n' , ['N_walk'],['N_bike'],['N_car'], ['N_PT']);
fprintf(fid, '%8.0f %8.0f %8.0f %8.0f ', sum_predchoice);
fprintf(fid, '\n%7.1f%% %7.1f%% %7.1f%% %7.1f%% ', 100*sum_predchoice/N_tot);

walk_cp = sum(ChoiceProb(I_walk,:),1)/N_walk*100; % Predicted choice probability for individuals that walked
bike_cp = sum(ChoiceProb(I_bike,:),1)/N_bike*100;
car_cp = sum(ChoiceProb(I_car,:),1)/N_car*100;
PT_cp = sum(ChoiceProb(I_PT,:),1)/N_PT*100;

fprintf(fid, '\n\n Predicted choice probability splitted by real choice:');
fprintf(fid, '\n%8s %8s %8s %8s %8s' , [''] , ['p_walk'],['p_bike'],['p_car'], ['p_PT']);
fprintf(fid, '\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['walk'], walk_cp);
fprintf(fid, '\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['bike'], bike_cp );
fprintf(fid, '\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['car'], car_cp);
fprintf(fid, '\n%8s %7.1f%% %7.1f%% %7.1f%% %7.1f%% ', ['PT'], PT_cp);

fprintf(fid, '\n\n*******************************************************\n');
fclose(fid); % close file descriptor