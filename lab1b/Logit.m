%-------------------------------------------------------
function [P , V_walk , V_bike , V_car , V_PT  ] =Logit(F , R)
% LOGIT(F) returns the likelihood and log-likelihood of the observaitions
% in VAR_FX for the fixed parameters F
% F is N_RD x NP

global VAR_FX I_DATA_FX I_BETA_FX;
global REP_VAR_RD I_DATA_RD I_BETA_RD
global N_RD NP NDRAWS
[V_walk , V_bike , V_car , V_PT]=Utilities(F , R);

 maxV = max([V_walk ; V_bike ; V_car ; V_PT],[],1); 

log_s2 = log(exp(V_walk-maxV) + exp(V_bike-maxV) + exp(V_car-maxV) + exp(V_PT-maxV))+maxV;
log_p_walk = V_walk - log_s2;
log_p_bike = V_bike - log_s2;
log_p_car = V_car - log_s2;
log_p_PT = V_PT - log_s2;

logP = [log_p_walk ; log_p_bike ; log_p_car ; log_p_PT];
P = exp(logP);

      function [V_walk , V_bike , V_car , V_PT] = Utilities(F , R)
            % Calculate the utilites for the different modes.
            % F is N_FX x 1 and contains the fixed parameters
                        
            V_walk_fix = (VAR_FX(I_DATA_FX.walk,:)'*F(I_BETA_FX.walk))';
            V_bike_fix = (VAR_FX(I_DATA_FX.bike,:)'*F(I_BETA_FX.bike))';
            V_car_fix = (VAR_FX(I_DATA_FX.car,:)'*F(I_BETA_FX.car))';
            V_PT_fix =(VAR_FX(I_DATA_FX.PT,:)'*F(I_BETA_FX.PT))';
            
            R = reshape(R,[N_RD,NP*NDRAWS]);
            V_walk_rd = sum(REP_VAR_RD(I_DATA_RD.walk,:).*R(I_BETA_RD.walk,:),1);
            V_bike_rd = sum(REP_VAR_RD(I_DATA_RD.bike,:).*R(I_BETA_RD.bike,:),1);
            V_car_rd = sum(REP_VAR_RD(I_DATA_RD.car,:).*R(I_BETA_RD.car,:),1);
            V_PT_rd = sum(REP_VAR_RD(I_DATA_RD.PT,:).*R(I_BETA_RD.PT,:),1);
            
            V_walk_rd = reshape(V_walk_rd,[1,NP,NDRAWS]);
            V_bike_rd = reshape(V_bike_rd,[1,NP,NDRAWS]);
            V_car_rd = reshape(V_car_rd,[1,NP,NDRAWS]);
            V_PT_rd = reshape(V_PT_rd,[1,NP,NDRAWS]);
            
            V_walk = V_walk_fix(1,:,ones(NDRAWS,1)) + V_walk_rd;
            V_bike = V_bike_fix(1,:,ones(NDRAWS,1)) + V_bike_rd;
            V_car = V_car_fix(1,:,ones(NDRAWS,1)) + V_car_rd;
            V_PT = V_PT_fix(1,:,ones(NDRAWS,1)) + V_PT_rd;

      end
end
