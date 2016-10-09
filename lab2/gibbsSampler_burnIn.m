function [B,W,R,F,P,RhoR,RhoF] = gibbsSampler_burnIn...
  (draws,saveStep,plotStep,...
   B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX)
%GIBBSSAMPLER_BURNIN performs Gibbs sampling for a predefined number of
% draws, given as a parameter. Returns the posterior sets of parameters.
fprintf('\nGibbs/MH sampler burn-in...\n');

  % useful variables
N_fx = MODEL_FX.n;
N_rd = MODEL_RD.n;
Labels_fx = MODEL_FX.labels;
Labels_rd = MODEL_RD.labels;

  % plot tiling params
plotCols = 7;
plotRows = 4;
totalSubplots = 1 + N_fx + N_rd; % +2 because of the acceptance rates

  % for plotting purposes: fixed params saved data
FSaved = []; % the saved parameters to plot
accFtotal = 0; % the acceptance rate total
accFsaved = []; % the acceptance rate saved to plot

  % for plotting purposes: random params saved data
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
    FSaved = [FSaved,F];
    nSaved = size(FSaved,2);
  end
  
  % plot!!
  if mod(k,plotStep) == 1
      % fixed acceptance rate
    ax1 = subplot(4,1,1);
    plot([1:nSaved]*100,accFsaved);
    hline = refline(ax1,0,mean(accFsaved,2));
    hline.Color = 'r';
    ylabel('FX acc. rate','Interpreter','none');
      % all fixed params
    ax2 = subplot(4,1,[2,3,4]);
    hold(ax2,'on');
    ax2.ColorOrderIndex = 1;
    for i = 1 : N_fx
      plot(ax2,[1:nSaved]*100,FSaved(i,:));
    end
    ylabel('FX parameters','Interpreter','none');
    legend(Labels_fx,...
      'Interpreter','none','FontSize',6,'Location','bestoutside');
    hold(ax2,'off');
    drawnow;
    
%       % plot fixed params acceptance rate
%     fRateAx = subplot(plotRows,plotCols,1);
%     plot([1:nSaved]*100,accFsaved);
%     ylabel('accept F rate','Interpreter','none');
%       % also plot the mean
%     acceptFmean = mean(accFsaved,2);
%     hline = refline(fRateAx,0,acceptFmean);
%     hline.Color = 'r';
%       % plot the rest of the fixed parameters
%     for i = 2 : totalSubplots
%       subplot(plotRows,plotCols,i);
%       plot([1:nSaved]*100,FSaved(i-1,:));
%       ylabel(Labels_fx{i-1},'Interpreter','none');
%     end
%     drawnow;
  end
end

end

