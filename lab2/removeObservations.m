function D_out = removeObservations(D_in,options)
  %-------------------------------------------------------
  % Function removeObservations(D,options)
  % Remove missing observations; year, sex, mode alternatives etc. (if needed)  
  % options={'mode',5,'year' '2006' 'sex' '0' 'short' '20'}
  % mode = 5 removes mode "other"
  % year = 2006 removes observations from the year 2006
  % sex = 0 removes females; 1 is for males
  % short = 20 keeps every 20 observation in the dataset
  %-------------------------------------------------------    
  
  % alias for the data structure
  D_IDX = D_in.Name;
  DATA = D_in.Data;
  
  fprintf('\nInitial number of observations: %4i \n',length(DATA(:,end)));  

  % This part finds all rows in the matrix DATA (trip observations)
  % containing missing values. Missing values are defined as -1 in the data set.
  miss_idx = logical(sum(DATA==-1,2));
  DATA(miss_idx, :) = [];

  % finding all rows containing missing values, those rows are deleted.   
  fprintf('Number of removed observations (Missing Values): %5i\n', sum(miss_idx));

  % Remove Mode Choice
    % This part removes all data observations in DATA relating to
    % mode choice i. The function presupposes that the mode choice is
    % stored in the last column of DATA.  
  k = strmatch('mode',options);
  if k > 0
    i = str2double(options{k+1});
    mcrmv_idx = logical(DATA(:,D_IDX.('mode'))==i);
    DATA(mcrmv_idx,:)=[];
    fprintf('Number of removed observations (Mode Choice %1i): %5i\n',[i sum(mcrmv_idx)]);
  end
  %
  % Remove Year  
    % This part removes all data observations in DATA relating to
    % year i. The function presupposes that the year of the observation
    % is stored in the next to last column of DATA.
  k = strmatch('year',options);
  if k > 0
    i = str2double(options{k+1});
    yrmv_idx = logical(DATA(:,D_IDX.('year')) == i);
    DATA(yrmv_idx, :) = [];
    fprintf('Number of removed observations (Year %4i): %5i\n',[i sum(yrmv_idx)]);
  end
  %
  % Remove Sex
    % This part removes all data observations in DATA relating to
    % sex i. The function presupposes that the sex variable is stored
    % in the second from last column of DATA.
    % i=1 removes males, i=0 removes women.
  k = strmatch('sex',options);
  if k>0
    i = str2num(options{k+1});
    srmv_idx = logical(DATA(:,D_IDX.('male')==i));
    DATA(srmv_idx,:)=[];
    fprintf('Number of removed observations (Sex %1i): %5i\n',[i sum(srmv_idx)]);
  end
  %
  % Short dataset
   % This function creates a short dataset for test purposes
   % Redifines the choices and the choice set, which is neccessary after
   % having removed choices. 
  k = strmatch('short',options);
  if k>0
    i = str2num(options{k+1});
    DATA=DATA(1:i:end,:);
    fprintf('Removing observations (Short dataset) \n');
  end
  %
  choice=unique(DATA(:,end));
  for i=1:length(choice)
    DATA(DATA(:,end)==choice(i),end)=i;
  end
  fprintf('\nOBSERVE: Choices have been redefined!\n');
  nind = length(unique(DATA(:, end-3)));  %  number of unique individuals
  Nob = size(DATA);
  fprintf('\nRemaining number of observations: %4i \n', Nob);
  fprintf('Number of individuals: %4i \n', nind);
  fprintf('Number of observations per person: %4.2f \n', Nob/nind);

  %Store modified observations in structure
  D_out = struct('Name',D_IDX,'Data',DATA);
end



