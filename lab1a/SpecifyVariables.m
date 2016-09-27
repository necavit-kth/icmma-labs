
function SpecifyVariables(fid)
% CHOOSEVARIABLES structure and transforms the data in file 'filename' to a
% more usable form. Here, is where you specify the variables to be included
% in the model and whether they are fixed or random and whether thet are
% normal or log-normal.
% NOTE: you can add more variables from the original data by adding them in
% LoadData below.

% Global variables that are used by other functions. we recommend that you
% don't change this.
global CHOICEIDX CHOICE
global VAR_FX VAR_RD REP_VAR_RD N_FX N_RD LAB_RD LAB_FX
global NP SQRTNP NDRAWS
global I_BETA_FX I_BETA_RD I_DATA_FX I_DATA_RD

%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the data from 'filename' and save it to the structure D.
%
filename = 'rvu_data_workNH.csv';
D = LoadData(filename);

% Remove missing observations, mode choice 5 ('other') and year 2006
% You can prepare a short dataset for test purposes by using:
% DATA = RemoveObservations(DATA,{'short','20'});
D = RemoveObservations(D, {'mode','5','year','2006'} );

% Calculate choice vector.
[CHOICE , CHOICEIDX] = CalculateChoice(D);

D_IDX = D.Name;
DATA = D.Data;
NP = size(DATA,1);
SQRTNP = sqrt(NP);

%%%%%%%%%% Transform and Create Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples of transformed/created variable
% Some more alternatives can be found in the bottom of the file. If you
% want to add more, look in LoadData.
%

% General
ASC = ones(NP,1);% ASC = alternative specific constant
year=DATA(:,D_IDX.('year'));

dist=DATA(:, D_IDX.('dist_OK_m'))/10000; %distance (10km)
dlt1km   = logical(dist < 0.1);
dlt2km   = logical(dist < 0.2);
dgt20km  = logical(dist > 2.0);
dst25km  = logical(dist >=0.2 & dist < 0.5);
dst510km = logical(dist >=0.5 & dist < 1.0); 
inncity = DATA(:, D_IDX.('orig_area3')) == 1; % dummy for origin inside the toll ring, regardless of destination

age = DATA(:,D_IDX.('age_grp04'));
age_teen = logical(age == 1);
age_young = logical(age == 2);
age_adult = logical(age == 3);
age_senior = logical(age == 4);
age_retired = logical(age == 5);
male = DATA(:, D_IDX.('male'));

occup = DATA(:, D_IDX.('occup'));
occup_wage = logical(occup == 1);
occup_nowage = logical(occup > 1);

self_empl = DATA(:, D_IDX.('self_empl'));
flext = DATA(:, D_IDX.('flext'));
income = DATA(:, D_IDX.('hh_income_grp'));
income_low = logical(income < 5); %dummy for low income (< 25000 SEK/month)
income_high = logical(income >= 5); %dummy for high income (> 25000 SEK/month)
cons_cap = DATA(:, D_IDX.('cons_cap'));
cons_cap_low = logical(cons_cap < 4); %dummy for low consumption capacity (<= average)
cons_cap_high = logical(cons_cap >= 4); %dummy for high consumption capacity (> average)
single_househ = DATA(:, D_IDX.('single_househ'));
househ_w_kids =  DATA(:, D_IDX.('househ_w_kids'));
no_child = DATA(:, D_IDX.('no_children'));

nohhdl = DATA(:, D_IDX.('no_househ_drv_lic'));
own_drv_lic =  DATA(:, D_IDX.('own_drv_lic'));
onlydrive = (nohhdl == 1).*(own_drv_lic==1);
caracc =  DATA(:, D_IDX.('caracc'));

% Car
cartime=(1 - DATA(:, D_IDX.caracc))*4 ...
      + (year==2004).*DATA(:, D_IDX.('car_time_hi'))/60; %if no car, add 4h to car time
carcost=(16*(year==2004)).*dist; % distance-dependent cost, e.g. fuel
compcar = DATA(:, D_IDX.('company_car'));
envcar = DATA(:, D_IDX.('envcar'));
parkposs = DATA(:, D_IDX.('park_poss_wp'));
cheappark = DATA(:, D_IDX.('cheap_parking_wp'));
car_md = DATA(:, D_IDX.('car_md'));

% Public Transport
PTcard = DATA(:, D_IDX.('pt_card_md'));
PTcost=((1-PTcard).*DATA(:, D_IDX.('pt_cash'))) +  15*PTcard;
PTauxt = DATA(:, D_IDX.('pt_aux_time_hi'))/60;   % access/egress time
PTfwt  = DATA(:, D_IDX.('pt_fstwait_hi'))/60;    % first waiting time
PTinvt = DATA(:, D_IDX.('pt_invt_hi'))/60;       % in-vehicle time
PTtotwt = DATA(:, D_IDX.('pt_totwait_hi'))/60;   % total waiting time
PTtime = PTauxt + PTinvt + PTtotwt; % total travel time by public transport
PTnoboard = DATA(:, D_IDX.('pt_noboard_hi'));
PTsubs = DATA(:, D_IDX.('pt_subs_wp')); % public transport subsidies at workplace



%%%%%%%%%% Specify model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify which variables that should influence which mode
% Add more from the transformed variables above.
%
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
  ASC,...
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
  'car_ASC',...
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


fprintf(fid, '\n\n----------------- MODEL VARIABLES ---------------------');
% Display the used variables in the model, specifying which are fixed and
%  which are mixed (correlated in Mixed Logit)
fprintf(fid, '\nWALK variables: %s', strjoin(walk_name_fix));
fprintf(fid, '\nBIKE variables: %s', strjoin(bike_name_fix));
fprintf(fid, '\nCAR  variables: %s', strjoin(car_name_fix));
fprintf(fid, '\nPT   variables: %s', strjoin(PT_name_fix));

fprintf(fid, '\n\nNOTE: model with all the variables factored in');

% Specify when working with Mixed logit. Don't work for lab 1.
walk_data_rd = [];
walk_name_rd = {};
bike_data_rd = [];
bike_name_rd = {};
car_data_rd = [];
car_name_rd = {};
PT_data_rd = [];
PT_name_rd = {};
log_normal_var = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save index of variables for respectively mode and sort into fixed
% and random parameters.

name_fix = {walk_name_fix{:} , bike_name_fix{:} , car_name_fix{:} , PT_name_fix{:}};
VAR_FX = [walk_data_fix , bike_data_fix , car_data_fix , PT_data_fix]';

nwf = size(walk_data_fix,2); Iwf_data = 1:nwf;
nbf = size(bike_data_fix,2); Ibf_data = nwf + (1:nbf);
ncf = size(car_data_fix,2); Icf_data = nwf + nbf + (1:ncf);
npf = size(PT_data_fix,2); Ipf_data = nwf + nbf + ncf + (1:npf);

[LAB_FX , IA_fix , IC_fix] = unique(name_fix,'stable');
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
VAR_RD = [walk_data_rd , bike_data_rd , car_data_rd , PT_data_rd];
REP_VAR_RD = repmat(VAR_RD,1,NDRAWS);

nwr = size(walk_data_rd,2); Iwr_data = 1:nwr;
nbr = size(bike_data_rd,2); Ibr_data = nwr + (1:nbr);
ncr = size(car_data_rd,2); Icr_data = nwr + nbr + (1:ncr);
npr = size(PT_data_rd,2); Ipr_data = nwr + nbr + ncr + (1:npr);

[LAB_RD , IA_rd , IC_rd] = unique(name_rd,'stable');
N_RD = length(IA_rd);
I_BETA_RD.walk = IC_rd(Iwr_data);
I_BETA_RD.bike= IC_rd(Ibr_data);
I_BETA_RD.car = IC_rd(Icr_data);
I_BETA_RD.PT = IC_rd(Ipr_data);
I_DATA_RD.walk = Iwr_data;
I_DATA_RD.bike = Ibr_data;
I_DATA_RD.car = Icr_data;
I_DATA_RD.PT = Ipr_data;


end

function D = LoadData(filename)
% LOADDATA Loads the dataset from filename
%   D is a structure with the two fields 'Name' and 'Data'
%   D.Data is a matrix where the columns gives the different variables and
%   each person has a row.
%   D.Name is a structure with the fields 'var_name' such that
%   D.Name.var1 gives the column-index of var1 in the matrix D.Data
%   D.Data(D.Name.var1,:) thus gives the data for var1 for all individuals

DATA=load(filename);
[Nob, NV] = size(DATA);

% Field names of all variables in the data set
FIELD={'trip_id','indiv_id','ind_weight','trip_weight','year','mode',... % 1-6
      'toll_resp','toll_calc','toll_period','congest_categ',...   % 7-10
      'startt_halfh','orig_area3','dest_area3','Essinge_bypass',... % 11-14
      'age_grp06','age_grp04','foreign','male','single_househ',... % 15-19
      'househ_w_kids','no_children','own_drv_lic','no_househ_drv_lic',... % 20-23
      'caracc','no_hh_cars','no_emp_cars','envcar','car_md',... % 24-28
      'pt_card_md','hh_income_grp','cons_cap','occup','self_empl',... % 29-33
      'flext','park_poss_wp','cheap_parking_wp','company_car',... % 34-37
      'pt_subs_wp','dist_OK_m','car_time_hi','car_time_low',... % 38-41
      'pt_aux_time_hi','pt_fstwait_hi','pt_invt_hi','pt_cash',... % 42-45
      'pt_noboard_hi','pt_totwait_hi'}; % 46-47

% Create data structure to find a specific variable in FIELD using its name
for k = 1:NV;
      D_IDX.(FIELD{k}) = k;
end

% Define variables that are saved to the structure D. Observe that since only
% observations without missing values for any of these variables
% are used for estimation (see RemoveObservations), you should not add
% more variables than you want to use.
USE_VAR = {'age_grp04','no_househ_drv_lic','cons_cap','hh_income_grp','occup','car_md',...
      'cheap_parking_wp','self_empl','pt_noboard_hi','flext','househ_w_kids',...
      'no_children','own_drv_lic','single_househ','envcar','toll_calc','pt_card_md',...
      'dist_OK_m','car_time_hi','car_time_low','pt_invt_hi','pt_cash','park_poss_wp',...
      'caracc','company_car','orig_area3','pt_aux_time_hi','pt_fstwait_hi',...
      'pt_totwait_hi','pt_subs_wp','indiv_id','male','year','mode'};

NV_USE = length(USE_VAR);

DATA_OUT = zeros(Nob, NV_USE);
for k = 1:NV_USE
      DATA_OUT(: , k) = DATA(: , D_IDX.(USE_VAR{k}));
      D_IDX_OUT.(USE_VAR{k}) = k;
end

D = struct('Name',D_IDX_OUT,'Data',DATA_OUT);
end

function [CHOICE ,  CHOICEIDX] = CalculateChoice(D)
% CALCULATECHOICE Calculates the vector of CHOICEIDX such that
% P(CHOICEIDX(k)) is the probability of the observed choice for observation
% k in the likelihood-function.
D_IDX = D.Name;
DATA = D.Data;
CHOICE=DATA(:, D_IDX.('mode') ); % chosen mode
r=length(CHOICE);
rows=(1:r)';
CHOICEIDX=(CHOICE-1)*r + rows;
end


%%% EXAMPLE OF VARIABLES TO INCLUDE:
%     dlt2km   = logical(dist < 0.2);
%     dgt20km  = logical(dist > 2.0);
%     PTnoboard = DATA(:, D_IDX.('pt_noboard_hi'));
%     male = DATA(:, D_IDX.('male'));
%     inncity = DATA(:, D_IDX.('orig_area3')) == 1; % dummy for origin inside the toll ring, regardless of destination
%     parkposs = DATA(:, D_IDX.('park_poss_wp'));
%     compcar = DATA(:, D_IDX.('company_car'));
%     dst25km  = logical(dist >=0.2 & dist < 0.5);
%     dst510km = logical(dist >=0.5 & dist < 1.0); 
%     indiv_id = DATA(:, D_IDX.('indiv_id'));
%     age = DATA(:,D_IDX.('age_grp04'));
%     no_child = DATA(:, D_IDX.('no_children'));
%     income = DATA(:, D_IDX.('hh_income_grp'));
%     cons_cap = DATA(:, D_IDX.('cons_cap'));
%     occup = DATA(:, D_IDX.('occup'));
%     single_househ = DATA(:, D_IDX.('single_househ'));
%     househ_w_kids =  DATA(:, D_IDX.('househ_w_kids'));
%     caracc =  DATA(:, D_IDX.('caracc'));
%     self_empl = DATA(:, D_IDX.('self_empl'));
%     flext = DATA(:, D_IDX.('flext'));
%     cheappark = DATA(:, D_IDX.('cheap_parking_wp'));
%     PTsubs = DATA(:, D_IDX.('pt_subs_wp')); % public transport subsidies at workplace
%     envcar = DATA(:, D_IDX.('envcar'));
%     car_md = DATA(:, D_IDX.('car_md'));    
%     onlydrive = (nohhdl == 1).*(own_drv_lic==1);
%     nohhdl = DATA(:, D_IDX.('no_househ_drv_lic'));
%     own_drv_lic =  DATA(:, D_IDX.('own_drv_lic'));
%     mode = DATA(:, D_IDX.('mode')); %Chosen mode
