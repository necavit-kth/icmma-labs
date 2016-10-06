function D = loadData(filename)
  % LOADDATA Loads the dataset from filename
  %   D is a structure with the two fields 'Name' and 'Data'
  %   D.Data is a matrix where the columns gives the different variables and
  %   each person has a row.
  %   D.Name is a structure with the fields 'var_name' such that
  %   D.Name.var1 gives the column-index of var1 in the matrix D.Data
  %   D.Data(D.Name.var1,:) thus gives the data for var1 for all individuals

  DATA = load(filename);
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