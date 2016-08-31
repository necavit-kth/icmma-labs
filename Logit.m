%-------------------------------------------------------
function [P , V_walk , V_bike , V_car , V_PT ] =Logit(F , R)
%   LOGIT(F , R) calculates the probability of all alternatives
% and the utility of each mode.  
%   F is a vector of the fixed parameters. The size is N_FX x 1, where N_FX is the number
% of fixed parameters.
%   R will be used later in the Mixed logit.

global VAR_FX I_DATA_FX I_BETA_FX;
% VAR_FX 

[V_walk , V_bike , V_car , V_PT]=Utilities(F , R);


sum_exp = []; % FILL IN 

% OBS! Remember that element-by-element operations must be precided by . in
% matlab, ex V_walk./V_bike.
P_walk = [];
P_bike = [];
P_car = [];
P_PT = [];

P = [P_walk' , P_bike' , P_car' , P_PT'];

      function [V_walk , V_bike , V_car , V_PT] = Utilities(F , R)
            % Calculate the utilites for the different modes.
            % F is N_FX x 1 and contains the fixed parameters
                        
            V_walk = (VAR_FX(I_DATA_FX.walk,:)'*F(I_BETA_FX.walk))';
            V_bike = (VAR_FX(I_DATA_FX.bike,:)'*F(I_BETA_FX.bike))';
            V_car = (VAR_FX(I_DATA_FX.car,:)'*F(I_BETA_FX.car))';
            V_PT =(VAR_FX(I_DATA_FX.PT,:)'*F(I_BETA_FX.PT))';

      end
end
