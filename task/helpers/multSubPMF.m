%
% Project: Respiratory Resistance Sensitivity (RRS) Task. Respiratory
% interoception
%
% simple PF fitting (multiple subjects/runs) using
% Palamedes 
%
% Niia Nikolova
% Last edit: 03/10/2020
%


% Define where key data are in the results matrix (i.e. 'outputExcl'), by
% column #
stimIntensity = 2;
responsesAccuracy = 4;
subjectIDs = 8;

%% Load file
loadFile = uigetfile('*.mat', 'Select a .mat file to load.');
load(loadFile);
ResultsArray = outputExcl;


%% Emot Discrim
% col_trialN = 1;
% col_EmoResp = 2;
% col_ConfResp = 3;
% col_EmoRT = 4;
% col_ConfRT = 5;
% col_trialSuccess = 6;
% col_MorphLevel = 7;
% col_Indiv = 8;
% col_subID = 9;

%% Resp
% col_trialN = 1;
% col_Stim = 2;
% col_Resp = 4;
% col_RespLR = 5;
% col_RT = 6;
% col_trialSuccess = 7;
% col_subID = 8;


%% Palamedes setup
ParOrNonPar = 1;    % parametric (1), non-parametric (2)
PF = @PAL_Weibull;  %Alternatives: PAL_Gumbel, PAL_Weibull, PAL_Logistic
                     %PAL_Quick, PAL_logQuick,
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
%Number of simulations to perform to determine standard error
B=400;

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = linspace(0,100,201);
searchGrid.beta = linspace(log10(1),log10(16),201);
searchGrid.gamma = 0.5;     %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.05;    %ditto

% Plotting settings
colours = [.08 .44 .35; .3 .89 .75; %teal
    .25 .12 .47; .57 .37 .90;       %purple
    .68 .62 .13; 1 .92 .51;         %yellow
    .68 .33 .13; 1 .59 .35];        %orange
markerShape = ['ko'; 'ks'; 'k<'; 'k>'; 'k+'; 'ko'; 'k.'; 'kx'; 'kp'; 'kh'];

% open a figure
figure('name','Respiratory Resistance Sensitivity');
axes
hold on

% Define stimulus levels
StimLevels = unique(ResultsArray(:,stimIntensity))';
StimLevelsFineGrain = [min(StimLevels):max(StimLevels)./1000:max(StimLevels)];


%% Subject - level
% loop over subjects
subIds = unique(ResultsArray(:,subjectIDs));
nSubjects = length(subIds);

disp(['Number of subjects: ' num2str(nSubjects)]);

for subLoop = 1:nSubjects
    
    % Define inputs
    thisSub = subIds(subLoop);
    OutOfNum = hist(ResultsArray((ResultsArray(:,subjectIDs)==thisSub), stimIntensity), StimLevels);
    NumPos = hist( ResultsArray(((ResultsArray(:,responsesAccuracy)==1) & (ResultsArray(:,subjectIDs)==thisSub)),stimIntensity), StimLevels );
    
    % Fit PMFs
    disp(['Fitting function: subject ', num2str(subLoop), '....']);
    [paramsValues, LL, exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
        OutOfNum,searchGrid,paramsFree,PF);
    
    disp('done:')
    message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
    disp(message);
    message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
    disp(message);
    
   
    disp('Determining standard errors.....');
    if ParOrNonPar == 1
        [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapParametric(...
            StimLevels, OutOfNum, paramsValues, paramsFree, B, PF, ...
            'searchGrid', searchGrid);
    else
        [SD(subLoop,:), paramsSim(subLoop,:), LLSim(subLoop,:), converged] = PAL_PFML_BootstrapNonParametric(...
            StimLevels(subLoop,:), NumPos(subLoop,:), OutOfNum(subLoop,:), [], paramsFree, B, PF,...
            'searchGrid',searchGrid);
    end
    
    disp('done:');
    message = sprintf('Standard error of Threshold: %6.4f',SD(1));
    disp(message);
    message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
    disp(message);
    
    
    % Determine Goodness-of-Fit
    B=200;%1000;                    % Number of simulation to perform
    
    disp('Determining Goodness-of-fit.....');
    [Dev, pDev] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
        paramsValues, paramsFree, B, PF, 'searchGrid', searchGrid);
    
    disp('done:');
    % Display summary of results
    message = sprintf('Deviance: %6.4f',Dev);
    disp(message);
    message = sprintf('p-value: %6.4f',pDev);
    disp(message);
    
    % Proportion correct
    ProportionCorrectObserved = NumPos./OutOfNum;
    ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
    
    % Plot
    XaxisTicks = 0:20:100;
    XaxisLabels = {'0', '20', '40', '60', '80', '100'};
    plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color', colours(subLoop, :),'linewidth',2);
    plot(StimLevels,ProportionCorrectObserved, markerShape(subLoop,:),'markersize',6, 'MarkerEdgeColor', colours(subLoop, :));
    set(gca, 'fontsize',16);
    set(gca, 'Xtick', XaxisTicks, 'XtickLabels', XaxisLabels);
    axis([min(StimLevels) max(StimLevels)+2 0 1]);
    xlabel('Respiratory Resistance');
    ylabel('Percent Correct');
    hold on
end


%% Inputs - sub. avg. 
StimLevels = unique(ResultsArray(:,stimIntensity))';
OutOfNum = hist(ResultsArray(:,stimIntensity), StimLevels);
NumPos = hist( ResultsArray(logical(ResultsArray(:,responsesAccuracy)==1),stimIntensity), StimLevels );      


%% Fit PMF
disp('Fitting function.....');
[paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);

disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);

%Number of simulations to perform to determine standard error
B=400;                  

disp('Determining standard errors.....');

if ParOrNonPar == 1
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(...
        StimLevels, OutOfNum, paramsValues, paramsFree, B, PF, ...
        'searchGrid', searchGrid);
else
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapNonParametric(...
        StimLevels, NumPos, OutOfNum, [], paramsFree, B, PF,...
        'searchGrid',searchGrid);
end

disp('done:');
message = sprintf('Standard error of Threshold: %6.4f',SD(1));
disp(message);
message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
disp(message);

%Distribution of estimated slope parameters for simulations will be skewed
%(type: hist(paramsSim(:,2),40) to see this). However, distribution of
%log-transformed slope estimates will be approximately symmetric
%[type: hist(log10(paramsSim(:,2),40)]. This might motivate using 
%log-scale for slope values (uncomment next three lines to put on screen):
% SElog10slope = std(log10(paramsSim(:,2)));
% message = ['Estimate for log10(slope): ' num2str(log10(paramsValues(2))) ' +/- ' num2str(SElog10slope)];
% disp(message);

%% determine Goodness-of-Fit
B=200;%1000;                    % Number of simulation to perform

disp('Determining Goodness-of-fit.....');

[Dev pDev] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
    paramsValues, paramsFree, B, PF, 'searchGrid', searchGrid);

disp('done:');

% Display summary of results
message = sprintf('Deviance: %6.4f',Dev);
disp(message);
message = sprintf('p-value: %6.4f',pDev);
disp(message);


%% Add avg to plot
ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
 
% figure('name','Emotion Discrimination');
% axes
% hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0.93 .0 0.28],'linewidth',4);
plot(StimLevels,ProportionCorrectObserved,'k.','markersize',20);
set(gca, 'fontsize',16);
% set(gca, 'Xtick',StimLevels);
% axis([min(StimLevels) max(StimLevels) 0 1]);
% xlabel('Stimulus Intensity');
% ylabel('Proportion ''Angry'' ');

