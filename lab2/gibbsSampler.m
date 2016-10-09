function [samplesB,samplesW,samplesR,samplesF,samplesP] = gibbsSampler...
  (sampleSaveStep,samples,...
   N_obs,...
   B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX)
 %GIBBSSAMPLER performs Gibbs sampling to obtain a series of
 % samples to estimate the parameters. Used when burn-in has
 % proved that the parameters have converged.
fprintf('\n\nGibbs/MH-sampling the posterior, after burn-in...\nProgress: ');

% useful variables
N_fx = MODEL_FX.n;
N_rd = MODEL_RD.n;

% calculate the amount of draws to make
draws = sampleSaveStep * samples;

% init samples containers (efficient memory allocation)
samplesP = zeros(N_obs,samples);
samplesF = zeros(N_fx,samples);
samplesB = zeros(N_rd,samples);
samplesW = zeros(N_rd,samples);
samplesR = zeros(N_rd,N_obs,samples);

% sample and save!!
for k = 1 : draws
  % perform a Gibbs sampler round
  [B,W,R,F,P,RhoR,RhoF] = ...
    sampleParameters(B,W,R,F,P,RhoR,RhoF,MODEL_FX,MODEL_RD,CHOICEIDX);
  
  % save sampled parameters
  if mod(k,sampleSaveStep) == 1
    samplesP(:,ceil(k/sampleSaveStep)) = P;
    samplesF(:,ceil(k/sampleSaveStep)) = F;
    samplesB(:,ceil(k/sampleSaveStep)) = B;
    samplesW(:,ceil(k/sampleSaveStep)) = diag(W); % we only need the variance
    samplesR(:,:,ceil(k/sampleSaveStep)) = R;
    if mod(k,sampleSaveStep*10) == 1
      fprintf('. '); % progress update
    end
  end
end

end

