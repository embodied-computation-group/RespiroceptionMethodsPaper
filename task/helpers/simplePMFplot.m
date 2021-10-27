function simplePMFplot()
% function simplePMFplot()
%
% Make a single subject analysis report, Psi  
%
% Project: Respiratory resistance sensitivity task
%
% Niia Nikolova
% Last edit: 08/01/2021

%% Define plotting variables
plotColours = {[0.85,0.33,0.10], [0.00,0.45,0.74], [], []};
lineWidth   = 2;
fontSize    = 10;

%% Select a file & load
[file, path]    = uigetfile('*.mat', 'Select a subject results file.');
load([path, file]);

%% Check for metacog data & set up subplot figure
existMcgnData   = any(~isnan(Results.ConfResp));
figure; hold on;
set(gcf,'color','w');
spCols = 3;
if existMcgnData
    spRows = 3;
else
    spRows = 2;
end


%% Threshold estimate by trial
subplot(spRows,spCols,[1,2]); hold on;
t = 1:length(stair.PM.x)-1;               % trial #
% Plot line
plot(1:length(t),stair.PM.threshold,'Color',plotColours{2},'LineWidth',lineWidth); hold on

% Plot correct responses
plot(t(stair.PM.response == 1),stair.PM.x(stair.PM.response == 1),'wo',...
    'MarkerSize',8,...
    'MarkerEdgeColor',plotColours{2},...
    'MarkerFaceColor',plotColours{2});
hold on

% Plot incorrect responses
plot(t(stair.PM.response == 0),stair.PM.x(stair.PM.response == 0),'wo',...
    'MarkerSize',8,...
    'MarkerEdgeColor',plotColours{1},...
    'MarkerFaceColor',plotColours{1});
% plot(t,stair.PM.x(1:length(t)),'wo',...
%     'MarkerSize',8,...
%     'MarkerEdgeColor','r',...
%     'MarkerFaceColor',[1 1 1]);
hold on

% Add axis labels
hold on
title('Presented Stimuli & Threshold Estimate by Trial');
axis([0 (length(stair.PM.x)+5) 0 17]);
xlabel('Trial number','fontsize',fontSize);
ylabel('Resistance (mm)','fontsize',fontSize);

%% PMF
% Calculate Threshold and Slope
estA = stair.PM.threshold(t(end));
estB = 10.^stair.PM.slope(t(end)); % slope is in log10 units of beta parameter
Results.estA        = estA;
Results.estB        = estB;
disp(['Threshold estimate: ', num2str(estA)]);
disp(['Slope estimate: ', num2str(estB)]);         

% Plot pmf
subplot(spRows,spCols,3); hold on;
% subplot(2,1,2,'align');
title('Psi PMF fit');
hold on

% SL stim levels, NP num positive, OON out of num
[SL, NP, OON] = PAL_PFML_GroupTrialsbyX(stair.PM.x(1:length(stair.PM.x)-1),stair.PM.response,ones(size(stair.PM.response)));
for SR = 1:length(SL(OON~=0))
    plot(SL(SR),NP(SR)/OON(SR),'wo','markerfacecolor',plotColours{2},'markersize',20*sqrt(OON(SR)./sum(OON)))
end
axis([0 20 0.5 1]);

% plot
plot([min(stair.stimRange):.01:max(stair.stimRange)], stair.PF([stair.PM.threshold(length(stair.PM.threshold)) 10.^stair.PM.slope(length(stair.PM.threshold)) stair.priorGammaRange stair.PM.lapse(length(stair.PM.threshold))],min(stair.stimRange):.01:max(stair.stimRange)),'Color',plotColours{2},'linewidth',lineWidth)

xlabel('Resistance (mm)','fontsize',fontSize);
ylabel('\psi(\itx\rm; \alpha, \beta, \gamma, \lambda)','fontsize',fontSize);
text(min(stair.stimRange)+(max(stair.stimRange)-min(stair.stimRange))/1.3, .70,['\alpha ', num2str(estA)],'color',[0 0 0],'Fontsize',fontSize)
text(min(stair.stimRange)+(max(stair.stimRange)-min(stair.stimRange))/1.3, .60,['\beta ', num2str(estB)],'color',[0 0 0],'Fontsize',fontSize)
% text(min(stair.stimRange)+(max(stair.stimRange)-min(stair.stimRange))/4, .75,'Bayes fit','color',[0 0 0],'Fontsize',fontSize)
% set(gca,'ytick',[0:.25:1]);

drawnow

% Get the stim levels at which participant performane is .3 .5 and .7
pptPMFvals = [stair.PM.threshold(length(stair.PM.threshold)) 10.^stair.PM.slope(length(stair.PM.threshold)) 0 stair.PM.lapse(length(stair.PM.threshold))];
inversePMFvals = [0.3, 0.5, 0.7];
inversePMFstims = stair.PF(pptPMFvals, inversePMFvals, 'inverse');
inversePMFstims = round(inversePMFstims,2);

%% Calculate overall accuracy
validTrials     = ~isnan(Results.Resp);
nValidTrials    = sum(validTrials);
nCorrectTrials  = sum(Results.Resp(validTrials));
accuracy        = nCorrectTrials./nValidTrials; 

disp(['Session accuracy: ', num2str(accuracy)]);
Results.acc     = accuracy;

%% Plot accuracy x RT
RT              = Results.RT;
correctTrials   = nanmean(RT(Results.Resp == 1));
incorrectTrials = nanmean(RT(Results.Resp == 0));

subplot(spRows,spCols,4); hold on;
title('RT x accuracy');
set(gcf,'color','w');
X = categorical({'Correct','Incorrect'});
Y = [correctTrials, incorrectTrials];
bar(X,Y, 0.5, 'FaceColor',plotColours{2},'LineWidth',0.1)
set(gca,'yLim',[0, 1]);
ylabel('RT (s)','fontsize',fontSize);


%% Plot accuracy x confidence
if existMcgnData        % If confidence ratings were collected
    Conf            = Results.ConfResp;
    correctTrials   = nanmean(Conf(Results.Resp == 1));
    incorrectTrials = nanmean(Conf(Results.Resp == 0));
    
    subplot(spRows,spCols,6); hold on;
    title('Confidence x accuracy');
    set(gcf,'color','w');
    X = categorical({'Correct','Incorrect'});
    Y = [correctTrials, incorrectTrials];
    bar(X,Y, 0.5, 'FaceColor',plotColours{2},'LineWidth',0.1)
    set(gca,'yLim',[0, 100]);
    ylabel('Confidence ratings','fontsize',fontSize);
end

%% Plot unpleasantness rating x break #
blahRateMat    	= Results.ExpRateTask;
nRatigs         = size(blahRateMat,2);
blahRateVals    = blahRateMat(1, :);

subplot(spRows,spCols,(spCols+spRows)); hold on;
title('Task unpleasantness');
set(gcf,'color','w');
bar(1:nRatigs, blahRateVals, 0.5, 'FaceColor',plotColours{2},'LineWidth',0.1)
set(gca,'yLim',[0, 100]);
ylabel('Unpleasantness rating','fontsize',fontSize);
xlabel('Timepoint','fontsize',fontSize);

%% Save updated results file
vars.DataFileName = ['a', vars.DataFileName];
save(strcat(vars.OutputFolder, vars.DataFileName), 'stair', 'Results', 'vars', 'scr', 'keys' );


end