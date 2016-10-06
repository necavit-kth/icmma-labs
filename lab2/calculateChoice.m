function [CHOICE, CHOICEIDX] = calculateChoice(D)
  % CALCULATECHOICE Calculates the vector of CHOICEIDX such that
  % P(CHOICEIDX(k)) is the probability of the observed choice for observation
  % k in the likelihood-function.
  
  % alias the DataStruct variables
  dataLabels = D.Name;
  data = D.Data;
  
  % calculate the chosen mode (select) and its index
  CHOICE = data(:,dataLabels.('mode')); % chosen mode
  r = length(CHOICE);
  rows=(1:r)';
  CHOICEIDX = (CHOICE - 1) * r + rows;
end