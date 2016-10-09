function [MODEL_FX, MODEL_RD] = specifyModel(D_in)
% SPECIFYVARIABLES structure and transforms the data passed-in in a
% more usable form. Here, is where you specify the variables to be included
% in the model and whether they are fixed or random and whether thet are
% normal or log-normal.
% NOTE: you can add more variables from the original data by adding them in
% loadData below.

% useful aliases and variables
D_idx = D_in.Name;
D = D_in.Data;
N_obs = size(D,1);

%%%%%%%%%% Transform and Create Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples of transformed/created variable
% Some more alternatives can be found in the bottom of the file. If you
% want to add more, look in loadData.

% General
ASC = ones(N_obs,1);% ASC = alternative specific constant
year=D(:,D_idx.('year'));

dist=D(:, D_idx.('dist_OK_m'))/10000; %distance (10km)
dlt1km   = logical(dist < 0.1);
dlt2km   = logical(dist < 0.2);
dgt20km  = logical(dist > 2.0);
dst25km  = logical(dist >=0.2 & dist < 0.5);
dst510km = logical(dist >=0.5 & dist < 1.0); 
inncity = D(:, D_idx.('orig_area3')) == 1; % dummy for origin inside the toll ring, regardless of destination

age = D(:,D_idx.('age_grp04'));
age_teen = logical(age == 1);
age_young = logical(age == 2);
age_adult = logical(age == 3);
age_senior = logical(age == 4);
age_retired = logical(age == 5);
male = D(:, D_idx.('male'));

occup = D(:, D_idx.('occup'));
occup_wage = logical(occup == 1);
occup_nowage = logical(occup > 1);

self_empl = D(:, D_idx.('self_empl'));
flext = D(:, D_idx.('flext'));
income = D(:, D_idx.('hh_income_grp'));
income_low = logical(income < 5); %dummy for low income (< 25000 SEK/month)
income_high = logical(income >= 5); %dummy for high income (> 25000 SEK/month)
cons_cap = D(:, D_idx.('cons_cap'));
cons_cap_low = logical(cons_cap < 4); %dummy for low consumption capacity (<= average)
cons_cap_high = logical(cons_cap >= 4); %dummy for high consumption capacity (> average)
single_househ = D(:, D_idx.('single_househ'));
househ_w_kids =  D(:, D_idx.('househ_w_kids'));
no_child = D(:, D_idx.('no_children'));

nohhdl = D(:, D_idx.('no_househ_drv_lic'));
own_drv_lic =  D(:, D_idx.('own_drv_lic'));
onlydrive = (nohhdl == 1).*(own_drv_lic==1);
caracc =  D(:, D_idx.('caracc'));

% Car
cartime=(1 - D(:, D_idx.caracc))*4 ...
      + (year==2004).*D(:, D_idx.('car_time_hi'))/60; %if no car, add 4h to car time
carcost=(16*(year==2004)).*dist; % distance-dependent cost, e.g. fuel
compcar = D(:, D_idx.('company_car'));
envcar = D(:, D_idx.('envcar'));
parkposs = D(:, D_idx.('park_poss_wp'));
cheappark = D(:, D_idx.('cheap_parking_wp'));
car_md = D(:, D_idx.('car_md'));

% Public Transport
PTcard = D(:, D_idx.('pt_card_md'));
PTcost=((1-PTcard).*D(:, D_idx.('pt_cash'))) +  15*PTcard;
PTauxt = D(:, D_idx.('pt_aux_time_hi'))/60;   % access/egress time
PTfwt  = D(:, D_idx.('pt_fstwait_hi'))/60;    % first waiting time
PTinvt = D(:, D_idx.('pt_invt_hi'))/60;       % in-vehicle time
PTtotwt = D(:, D_idx.('pt_totwait_hi'))/60;   % total waiting time
PTtime = PTauxt + PTinvt + PTtotwt; % total travel time by public transport
PTnoboard = D(:, D_idx.('pt_noboard_hi'));
PTsubs = D(:, D_idx.('pt_subs_wp')); % public transport subsidies at workplace

%%%%%%%%%% Specify model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify which variables that should influence which mode
% Add more from the transformed variables above.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   WALK
walk_data_fix = [...
  ASC,...
  dist,...
  dlt1km...
];
walk_name_fix = {...
  'walk_ASC',...
  'walk_dist'...
  'walk_dlt1km'...
};
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   BIKE
bike_data_fix = [...
  ASC,...
  dist,...
  male,...
  flext,...
  nohhdl,...
  own_drv_lic...
];
bike_name_fix = {...
  'bike_ASC',...
  'bike_dist',...
  'bike_male',...
  'bike_flext',...
  'bike_nohhdl',...
  'bike_own_drv_lic'...
};
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   CAR
car_data_fix = [...
  cartime,...
  carcost,...
  parkposs,...
  cheappark,...
  compcar,...
  car_md,...
  male,...
  self_empl,...
  flext,...
  own_drv_lic...
];
car_name_fix = {...
  'car_time',...
  'car_cost',...
  'car_parkposs',...
  'car_cheappark',...
  'car_compcar',...
  'car_md',...
  'car_male',...
  'car_self_empl',...
  'car_flext',...
  'car_own_drv_lic'...
};
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PUBLIC TRANSPORT
PT_data_fix = [...
  PTtime,...
  PTcost,...
  PTfwt,...
  PTsubs,...
  flext,...
  nohhdl,...
  own_drv_lic...
];
PT_name_fix = {...
  'PT_time',...
  'PT_cost',...
  'PT_fwt',...
  'PT_subs',...
  'PT_flext',...
  'PT_nohhdl',...
  'PT_own_drv_lic'...
};

% Specify when working with Mixed logit
walk_data_rd = [];
walk_name_rd = {};
bike_data_rd = [];
bike_name_rd = {};
car_data_rd = [];
car_name_rd = {};
PT_data_rd = [ASC];
PT_name_rd = {'PT_ASC'};

% Define log-normally distributed variables, must be specified in the
% among the random parameters above. 
% 
% Make sure that the sign of the data is such that the expected sign of the
% parameters is positive. E.g, since we expect that b_cartime < 0 we must
% use -cartime in the data-vector.
log_normal_var =  {};%{'Car_time','PT_time'}; 

% Define correlation among parameters
% Each row should have two parameters that are correlated
% Ex: %cov_var{'Walk_ASC', 'Bike_ASC'
%              'PT_time' , 'Car_time'};
% correlates walk_asc with bike_asc and PT_time with Car_time
cov_var = {};% {'Car_time','PT_time'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save index of variables for respectively mode and sort into fixed
% and random parameters.

name_fix = {walk_name_fix{:},bike_name_fix{:},car_name_fix{:},PT_name_fix{:}};
VAR_FX = [walk_data_fix,bike_data_fix,car_data_fix,PT_data_fix]';

nwf = size(walk_data_fix,2); Iwf_data = 1:nwf;
nbf = size(bike_data_fix,2); Ibf_data = nwf + (1:nbf);
ncf = size(car_data_fix,2); Icf_data = nwf + nbf + (1:ncf);
npf = size(PT_data_fix,2); Ipf_data = nwf + nbf + ncf + (1:npf);

[LAB_FX,IA_fix,IC_fix] = unique(name_fix,'stable');
N_FX = length(IA_fix);

I_BETA_FX.walk = IC_fix(Iwf_data);
I_BETA_FX.bike= IC_fix(Ibf_data);
I_BETA_FX.car = IC_fix(Icf_data);
I_BETA_FX.PT = IC_fix(Ipf_data);

I_DATA_FX.walk = Iwf_data;
I_DATA_FX.bike = Ibf_data;
I_DATA_FX.car = Icf_data;
I_DATA_FX.PT = Ipf_data;


name_rd = {walk_name_rd{:} , bike_name_rd{:} , car_name_rd{:} , PT_name_rd{:}};
VAR_RD = [walk_data_rd,bike_data_rd,car_data_rd,PT_data_rd]';

nwr = size(walk_data_rd,2); Iwr_data = 1:nwr;
nbr = size(bike_data_rd,2); Ibr_data = nwr + (1:nbr);
ncr = size(car_data_rd,2); Icr_data = nwr + nbr + (1:ncr);
npr = size(PT_data_rd,2); Ipr_data = nwr + nbr + ncr + (1:npr);

[LAB_RD,IA_rd,IC_rd] = unique(name_rd,'stable');
N_RD = length(IA_rd);

I_BETA_RD.log_normal = ismember(LAB_RD,log_normal_var);
I_BETA_RD.normal = ~I_BETA_RD.log_normal;
I_BETA_RD.walk = IC_rd(Iwr_data);
I_BETA_RD.bike= IC_rd(Ibr_data);
I_BETA_RD.car = IC_rd(Icr_data);
I_BETA_RD.PT = IC_rd(Ipr_data);

var_idx = [IC_rd,IC_rd];
cov_idx = zeros(size(cov_var));

for k = 1:length(LAB_RD)
  for l = 1:length(cov_idx(:));
    if ismember(cov_var{l},LAB_RD{k})
      cov_idx(l) = k;
    end
  end
end
cov_idx = sort(cov_idx,2,'descend');

I_BETA_RD.cov = [var_idx;cov_idx];

I_DATA_RD.walk = Iwr_data;
I_DATA_RD.bike = Ibr_data;
I_DATA_RD.car = Icr_data;
I_DATA_RD.PT = Ipr_data;

DIST_RD = {};
for k = 1:length(LAB_RD)
  if ismember(LAB_RD{k},log_normal_var)
    DIST_RD{k} = 'Log-normal';
  else
    DIST_RD{k} = 'Normal';
  end
end


% build the data structures needed for the model
%  estimation and execution
% fixed
MODEL_FX.var = VAR_FX;
MODEL_FX.beta_idx = I_BETA_FX;
MODEL_FX.data_idx = I_DATA_FX;
MODEL_FX.labels = LAB_FX;
MODEL_FX.n = N_FX;
% random
MODEL_RD.var = VAR_RD;
MODEL_RD.beta_idx = I_BETA_RD;
MODEL_RD.data_idx = I_DATA_RD;
MODEL_RD.labels = LAB_RD;
MODEL_RD.n = N_RD;
MODEL_RD.dist = DIST_RD;

end