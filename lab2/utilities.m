function [V_walk,V_bike,V_car,V_PT] = utilities(F,R,MODEL_FX,MODEL_RD)
  % UTILITIES Calculate the utilites for the different modes.
  % V_in = sum_k x_k F_k + sum_l x_l * R_ln
  %
  % F is N_FX x 1 and contains the fixed parameters
  % R is N_RD x N_RP and contains individual specific parameters

  % variables aliases
  VAR_FX = MODEL_FX.var;
  I_BETA_FX = MODEL_FX.beta_idx;
  I_DATA_FX = MODEL_FX.data_idx;

  VAR_RD = MODEL_RD.var;
  I_BETA_RD = MODEL_RD.beta_idx;
  I_DATA_RD = MODEL_RD.data_idx;
  N_RD = MODEL_RD.n;

  % representative utility calculation
  V_walk = VAR_FX(I_DATA_FX.walk,:)'*F(I_BETA_FX.walk);
  V_bike = (VAR_FX(I_DATA_FX.bike,:)'*F(I_BETA_FX.bike));
  V_car = (VAR_FX(I_DATA_FX.car,:)'*F(I_BETA_FX.car));
  V_PT =(VAR_FX(I_DATA_FX.PT,:)'*F(I_BETA_FX.PT));

  if (N_RD > 0)
    aux1 = VAR_RD(I_DATA_RD.walk,:);
    aux2 = R(I_BETA_RD.walk,:);
    whos aux1;
    whos aux2;
    V_walk = V_walk + sum(aux1 .* aux2,1)';
    V_bike = V_bike + sum(VAR_RD(I_DATA_RD.bike,:).*R(I_BETA_RD.bike,:),1)';
    V_car = V_car + sum(VAR_RD(I_DATA_RD.car,:).*R(I_BETA_RD.car,:),1)';
    V_PT = V_PT + sum(VAR_RD(I_DATA_RD.PT,:).*R(I_BETA_RD.PT,:),1)';
  end
end