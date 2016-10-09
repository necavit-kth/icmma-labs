function [B,W,R,F,P,RhoR,RhoF] = gibbsSampler_burnIn...
  (draws,saveStep,plotStep,legends,...
   B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX)
%GIBBSSAMPLER_BURNIN performs Gibbs sampling for a predefined number of
% draws, given as a parameter. Returns the posterior sets of parameters.
fprintf('\nGibbs/MH sampler burn-in...\n');

  % clear the previous figure, if any, in order to get a new plot
clf;

  % useful variables
N_fx = MODEL_FX.n;
N_rd = MODEL_RD.n;
Labels_fx = MODEL_FX.labels;
Labels_rd = MODEL_RD.labels;

  % for plotting purposes: fixed params saved data
Fsaved = []; % the saved parameters to plot
accFtotal = 0; % the acceptance rate total
accFsaved = []; % the acceptance rate saved to plot

  % for plotting purposes: random params saved data
Bsaved = []; % saved population means
Wsaved = []; % saved population variances
accRtotal = 0; % acceptance rate total
accRsaved = []; % acceptance rate to plot

for k = 1 : draws
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,RhoF,acceptR,acceptF] = ...
    sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);
  
  % update acceptance rates
  accFtotal = accFtotal + acceptF;
  accRtotal = accRtotal + acceptR;
  
  % save the parameters
  if mod(k,saveStep) == 1
    fprintf('draws: %5d\taccFX: %2.3f\taccRD: %2.3f\n',...
      k,...
      accFtotal/saveStep,...
      accRtotal/saveStep);
    accFsaved= [accFsaved,(accFtotal/saveStep)];
    accRsaved= [accRsaved,(accRtotal/saveStep)];
    
    % update fixed Rho
    if accFtotal/saveStep < 0.3
      RhoF = 0.9*RhoF;
    end
    if accFtotal/saveStep > 0.3
      RhoF = 1.1*RhoF;
    end
    
    accFtotal = 0;
    accRtotal = 0;
    Fsaved = [Fsaved,F];
    Bsaved = [Bsaved,B];
    Wsaved = [Wsaved,diag(W)];
    nSaved = size(Fsaved,2);
  end
  
  % plot!!
  if mod(k,plotStep) == 1
% FIXED PARAMETERS *******************************************************
      % fixed acceptance rate
    axAccFX = subplot(4,3,1);
    plot([1:nSaved]*100,accFsaved);
    hline = refline(axAccFX,0,mean(accFsaved,2));
    hline.Color = 'r';
    ylabel('FX acc. rate','Interpreter','none');
      % all fixed params
    axParamsFX = subplot(4,3,[4,7,10]);
    hold(axParamsFX,'on');
    axParamsFX.ColorOrderIndex = 1;
    for i = 1 : N_fx
      plot(axParamsFX,[1:nSaved]*100,Fsaved(i,:));
    end
    ylabel('FX parameters','Interpreter','none');
    if legends
      legend(Labels_fx,...
      'Interpreter','none','FontSize',6,'Location','bestoutside');
    end
    hold(axParamsFX,'off');
% RANDOM PARAMETERS ******************************************************
      % random params acceptance rate
    axAccRD = subplot(4,3,[2,3]);
    plot([1:nSaved]*100,accRsaved);
    hline = refline(axAccRD,0,mean(accRsaved,2));
    hline.Color = 'r';
    ylabel('RD acc. rate','Interpreter','none');
      % population params means
    axB = subplot(4,3,[5,8,11]);
    hold(axB,'on');
    axB.ColorOrderIndex = 1;
    for i = 1 : N_rd
      plot(axB,[1:nSaved]*100,Bsaved(i,:));
    end
    ylabel('RD parameters means (B)','Interpreter','none');
    hold(axB,'off');
        % population params variances
    axW = subplot(4,3,[6,9,12]);
    hold(axW,'on');
    axW.ColorOrderIndex = 1;
    for i = 1 : N_rd
      plot(axW,[1:nSaved]*100,Wsaved(i,:));
    end
    ylabel('RD parameters variances (W)','Interpreter','none');
    if legends
      legend(Labels_rd,...
        'Interpreter','none','FontSize',6,'Location','bestoutside');  
    end
    hold(axW,'off');
% DRAWNOW ******************************************************
    drawnow;
  end
end

end

