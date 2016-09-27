%-------------------------------------------------------
% Function LL = SimulatedLogLikelihood(beta)
%-------------------------------------------------------
function [ LL , g] = SimulatedLogLikelihood(beta)
global CHOICEIDX CHOICE N_FX N_RD NP N_COV CHOICEMAT
global DR NDRAWS
global I_F I_R I_W
global I_BETA_RD I_BETA_FX I_DATA_FX I_DATA_RD
global VAR_FX VAR_RD

F = beta(I_F);
B = beta(I_R);
cholW = zeros(N_RD);
idx_cov = sub2ind([N_RD , N_RD] , I_BETA_RD.cov(:,1) , I_BETA_RD.cov(:,2));
cholW(idx_cov) = beta(I_W);
cholWdiag = diag(cholW)';
sgnW = repmat(2*(cholWdiag >= 0)-1,N_RD,1); % sgnW = 1 for collumns where cholWdiag >= 0, -1 else
cholW = sgnW.*cholW;
sgnW = sgnW(idx_cov);

R = repmat(B,[1,NP,NDRAWS]) + reshape(cholW*DR,[N_RD,NP,NDRAWS]);

C = trans(R);

P = Logit(F, C); % P : N_mode x NP x NDRAWS
P = permute(P,[2 1 3]); % P : NP x N_mode x NDRAWS

P_choice = sum(repmat(CHOICEMAT,[1 1 NDRAWS]).*P,2); 
P_allIndAllDraws = reshape(P_choice,NP,NDRAWS);
% Use P_allIndAllDraws to calculate the simulated log-likelihood. Each row
% is one observation and each column is one draw, so that
% P_allIndAllDraws(i,j) gives probabiltiy that individual i choose the
% observed alternative given draw j.
LL = -sum(log(mean(P_allIndAllDraws,2))); % WRITE YOUR LOG-LIKELIHOOD FUNCTION HERE

mode = {'walk','bike','car','PT'};
N_mode = length(mode);

if nargout == 2
% Calculates gradient of Simulated LL
% For expressions see : Brownstone, D and Train, K (1996), "Forecasting New 
% Product Penetration with Flexible Substitution Patterns". 

      g_f = zeros(N_FX,1); % gradeient wrt fixed parameters
      g_b = zeros(N_RD,1); % gradient wrt mean for random parameters
      g_w = zeros(N_COV,1); % gradient wrt covariance parameters
      
      
      % Calculates gradient for fixed parameters
      negP = (repmat(CHOICEMAT,[1 1 NDRAWS])-P); % -P if not choosen mode and 1-P if choosen mode
      P_F_X = zeros(NP,N_mode,NDRAWS,N_FX); % negP times X for each mode probability
      
      
      X_FX = VAR_FX'; % Transform data
      X_FX = repmat(X_FX,[1 1 NDRAWS]);
      for k = 1:N_FX % for each parameter
            for j = 1:4; %for each mode
                  m_j = mode{j}; 
                  i_use = I_BETA_FX.(m_j) == k; % if parameter k influences utility of mode m_j
                  if sum(i_use) > 0 % Otherwise, the probability change is zero
                        P_F_X(:,j,:,k) = negP(:,j,:).*X_FX(:,I_DATA_FX.(m_j)(i_use),:); 
                  end
            end
      end
      P_all = sum(P_F_X,2); % Sum over modes
      P_all = permute(P_all,[1,4,3,2]); % P_all : N_P x N_RD x NDRAWS
      P_mean = mean(P_allIndAllDraws,2)';
      for k =1:N_FX
           ellasticity_f = sum(P_all(:,k,:).*P_choice,3); % ellasticity 
           g_f(k) = -1./P_mean*ellasticity_f/NDRAWS;
      end
      
      % Calculates gradient for mean and variances for random parameters
      DR_g = reshape(DR,[N_RD,NP,NDRAWS]); % Reshape the random draws
      DR_g = permute(DR_g,[2,1,3]);
      
      P_RD_X = zeros(NP,N_mode,NDRAWS,N_RD); % negP times X for each mode probability
      
      X_RD = VAR_RD';
      X_RD = repmat(X_RD,[1 1 NDRAWS]);
      for k = 1:N_RD
            for j = 1:4;
                  m_j = mode{j};
                  i_use = I_BETA_RD.(m_j) == k;
                  if sum(i_use) > 0                   
                        P_RD_X(:,j,:,k) = negP(:,j,:).*X_RD(:,I_DATA_RD.(m_j)(i_use),:); %(repmat(CHOICEMAT(:,j),[1 1 NDRAWS])-P(:,j,:)).*repmat(VAR_RD(I_DATA_RD.(m_j)(i_use),:)',[1,1,NDRAWS]);
                  end
            end
      end
      P_all = sum(P_RD_X,2); 
      P_all = permute(P_all,[1,4,3,2]); % P_all : N_P x N_RD x NDRAWS

      [d_b , d_w] = der(); % Calculates derivates dBeta_r/dB and dBeta_r/dW
      
      for k =1:N_RD
           a_rd = P_all(:,k,:).*d_b(:,k,:); % Multiply  dBeta_RD/db_RD
           ellasticity_B = sum(a_rd.*P_choice,3);
           g_b(k) = -1./P_mean*ellasticity_B/NDRAWS;
      end
         
      for k = 1:N_COV 
             a_w = P_all(:,I_BETA_RD.cov(k,1),:).*d_w(:,k,:);
             ellasticity_W = sum(a_w.*P_choice,3);
             g_w(k) = sgnW(k)*(-1)./P_mean*ellasticity_W/NDRAWS; 
       end
      
      g = [g_f ; g_b ; g_w];
end

      function [d_b, d_w] = der()
            d_b=ones(NP,N_RD,NDRAWS);
            d_w=ones(NP,N_COV,NDRAWS); %START HERE!!!
            C_p = permute(C,[2,1,3]);
            d_b(:,I_BETA_RD.log_normal,:) = C_p(:,I_BETA_RD.log_normal,:);
            
            for m = 1:length(idx_cov);
                  d_w(:,m,:) = d_b(:,I_BETA_RD.cov(m,1),:).*DR_g(:,I_BETA_RD.cov(m,2),:);
            end
      end
end


