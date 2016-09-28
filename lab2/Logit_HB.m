%-------------------------------------------------------
function [P , V_walk , V_bike , V_car , V_PT ] =Logit_HB(F , R)
%   LOGIT_HB(F , R) calculates the probability of all alternatives
% and the utility of each mode.  
%   F is a vector of the fixed parameters. The size is N_FX x 1, where N_FX is the number
% of fixed parameters.
%   R is a vector with individual specific parameters. Its size is N_RD x 1

global VAR_FX I_DATA_FX I_BETA_FX N_FX
global VAR_RD I_DATA_RD I_BETA_RD N_RD
% VAR_FX 

[V_walk , V_bike , V_car , V_PT]=Utilities(F , R);

U = [V_walk , V_bike , V_car , V_PT];
maxU = max(U,[],2);
U = U - maxU(:,[1,1,1,1]);
expU = exp(U);
sum_exp = sum(expU,2); 

P = expU./sum_exp(:,[1,1,1,1]);

      function [V_walk , V_bike , V_car , V_PT] = Utilities(F , R)
            % UTILITIES Calculate the utilites for the different modes.
            % V_in = sum_k x_k F_k + sum_l x_l * R_ln
            %
            % F is N_FX x 1 and contains the fixed parameters
            % R is N_RD x N_RP and contains individual specific parameters
            
                        
            V_walk = VAR_FX(I_DATA_FX.walk,:)'*F(I_BETA_FX.walk);
            V_bike = (VAR_FX(I_DATA_FX.bike,:)'*F(I_BETA_FX.bike));
            V_car = (VAR_FX(I_DATA_FX.car,:)'*F(I_BETA_FX.car));
            V_PT =(VAR_FX(I_DATA_FX.PT,:)'*F(I_BETA_FX.PT));
            
            if(N_RD>0)
                V_walk = V_walk + sum(VAR_RD(I_DATA_RD.walk,:).*R(I_BETA_RD.walk,:),1)';
                V_bike = V_bike + sum(VAR_RD(I_DATA_RD.bike,:).*R(I_BETA_RD.bike,:),1)';
                V_car = V_car + sum(VAR_RD(I_DATA_RD.car,:).*R(I_BETA_RD.car,:),1)';
                V_PT = V_PT + sum(VAR_RD(I_DATA_RD.PT,:).*R(I_BETA_RD.PT,:),1)';
            end
            
            
      end
end
