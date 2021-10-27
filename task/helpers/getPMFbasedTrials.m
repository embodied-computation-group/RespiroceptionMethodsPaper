function trialsList = getPMFbasedTrials(vars, stair)
%% function trialsList = getPMFbasedTrials(vars, stair)
% Create a list of trials based on a PMF (Psi method, stored in stair [structure])
%
% Niia Nikolova 2020

% Get the stim levels at which participant performance is
% .75 +/- jitter (.05)
pptPMFvals = [stair.PM.threshold(length(stair.PM.threshold)) 10.^stair.PM.slope(length(stair.PM.threshold)) 0 stair.PM.lapse(length(stair.PM.threshold))];
invPMFvals = [vars.MC.threshLevel-vars.MC.jitter, vars.MC.threshLevel, vars.MC.threshLevel+vars.MC.jitter ];

inversePMFstims = stair.PF(pptPMFvals, invPMFvals, 'inverse');
pptThreshLevels =  round(inversePMFstims);

% Generate repeating list & randomize order of stimuli
nReps = ceil(vars.NMetacogTrials / 3);
StimTrialList = repmat(pptThreshLevels', nReps, 1);
randomorder = randperm(length(StimTrialList));
trialsList = StimTrialList(randomorder);

trialsList(trialsList > 100) = 100; % No greater than 100

end



