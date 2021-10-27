function subjectReportRRS(filepath, desiredOutputDir)
% function subjectReportRRS(filepath, desiredOutputDir)
%
% Make a single subject analysis report. Works with either Psi or Quest
%   - check functionality with Ndown, MCS
%
% Project: Respiratory resistance sensitivity task
%
% Niia Nikolova
% Last edit: 08/01/2021

showPlot    = 0;            % Optional flag, set to 1 to display a summary figure for each subject (session)
savePlot    = 0;            % Optional flag to save plot output (as pdf & png)

%% Setup
% Check input args & load file
if nargin < 1
    disp('No file name was passed. Please select a raw ''RRS_SUBID_'' data file.');
    % Select a file & load
    [file, path]    = uigetfile('*.mat', 'Select a subject results file.');
    filepath        = [path, file];
elseif nargin == 1
   % Do nothing
end

load(filepath);
disp(['Preprocessing data file: ', filepath])

%% Define plotting variables
plotColours = {[0.00,0.45,0.74], [0.85,0.33,0.10], [], []};
lineWidth   = 2;
fontSize    = 10;
fontName    = 'Helvetica';
% fontSize    = 18;

%% Check which procedure was run
% 1 Psi, 2 Ndown, 3 MCS, 4 QUEST
procedure       = vars.Procedure;

% Determine number of staircases
origStairs = stair;
nStaircases = size(stair,2);

%% Check for metacog data & set up subplot figure
existMcgnData   = any(~isnan(Results.ConfResp));

if showPlot
    figure; hold on;
    set(gcf,'color','w');
    if procedure == 1       % Psi
        sgt = sgtitle(['Sub ',num2str(vars.subNo),', Psi']); else
        sgt = sgtitle(['Sub ',num2str(vars.subNo),', QUEST']);
    end
    sgt.FontSize = 14;
    spCols = 3;
    if existMcgnData
        spRows = 2;
    else
        spRows = 2;
    end
    

    %% Threshold estimate by trial
    subplot(spRows,spCols,[1,2]); hold on;
end

    % Loop over the staircases
    for thisStair = 1 : nStaircases
        
        stair = origStairs(thisStair);
        
        if procedure == 1       % Psi
            t = 1:length(stair.PM.x)-1;               % trial #
            stimByTrial     = stair.PM.threshold;
        else
            t = 1:length(stair.PM.x);
            stimByTrial     = stair.PM.x;
        end
        
        if showPlot
            % Plot line
            plot(1:length(t),stimByTrial,'Color',plotColours{thisStair},'LineWidth',lineWidth); hold on
            
            % Plot correct responses
            plot(t(stair.PM.response == 1),stair.PM.x(stair.PM.response == 1),'wo',...
                'MarkerSize',8,...
                'MarkerEdgeColor',plotColours{thisStair},...
                'MarkerFaceColor',plotColours{thisStair});
            hold on
            
            % Plot incorrect responses
            plot(t(stair.PM.response == 0),stair.PM.x(stair.PM.response == 0),'wo',...
                'MarkerSize',8,...
                'MarkerEdgeColor',plotColours{thisStair},...
                'MarkerFaceColor',[1 1 1]);
            % plot(t,stair.PM.x(1:length(t)),'wo',...
            %     'MarkerSize',8,...
            %     'MarkerEdgeColor','r',...
            %     'MarkerFaceColor',[1 1 1]);
            hold on
        end
    end
    
    if showPlot
        % Add axis labels
        hold on
        title('Presented Stimuli & Threshold Estimate by Trial','FontWeight','Normal');
        axis([0 (length(stair.PM.x)+5) 3.6 19]);
        yticks([3.6, 7.2, 10.8, 14.4, 18]);
        yticklabels({'20', '40', '60', '80', '100'});
        xlabel('Trial number','fontsize',fontSize);
        ylabel('% Obstruction','fontsize',fontSize);
        set(gca,'FontName',fontName,'fontsize',fontSize)
        grid on
        grid minor
        hold on
    end



%% PMF
if showPlot
    % Plot pmf
    subplot(spRows,spCols,3); hold on;
    title('PMF fit');
    xlabel('% Obstruction','fontsize',fontSize);
    ylabel('\psi(\itx\rm; \alpha, \beta, \gamma, \lambda)','fontsize',fontSize);
    xticks([3.4, 6.8, 10.2, 13.6, 17]);
    xticklabels({'20', '40', '60', '80', '100'});
    hold on
end

% Loop over the staircases
for thisStair = 1 : nStaircases
    
    stair = origStairs(thisStair);
    
    % Calculate Threshold and Slope
    if procedure == 1   % Psi
        estA = stair.PM.threshold(t(end));
        estB = 10.^stair.PM.slope(t(end)); % slope is in log10 units of beta parameter
        [SL, NP, OON] = PAL_PFML_GroupTrialsbyX(stair.PM.x(1:length(stair.PM.x)),stair.PM.response,ones(size(stair.PM.response)));
    else
        estA = stair.PM.mean;
        estB = stair.beta;
        [SL, NP, OON] = PAL_PFML_GroupTrialsbyX(round(stair.PM.x(1:length(stair.PM.x))),stair.PM.response,ones(size(stair.PM.response)));
    end
    
    Results.estA(thisStair)        = estA;
    Results.estB(thisStair)        = estB;
    estA_obst                      = estA * (100/17);
    disp(['Threshold estimate: ', num2str(estA_obst)]);
    disp(['Slope estimate: ', num2str(estB)]);
    
    estA_pcnt = estA * (100/17);
    
    if showPlot
        % SL stim levels, NP num positive, OON out of num
        for SR = 1:length(SL(OON~=0))
            plot(SL(SR),NP(SR)/OON(SR),'wo','markerfacecolor',plotColours{thisStair},'markersize',20*sqrt(OON(SR)./sum(OON)));
            hold on
        end
        axis([0 20 0.5 1]);
        
        % plot
        if procedure == 1   % Psi
            plot([min(stair.stimRange):.01:max(stair.stimRange)], stair.PF([stair.PM.threshold(length(stair.PM.threshold)) 10.^stair.PM.slope(length(stair.PM.threshold)) stair.priorGammaRange stair.PM.lapse(length(stair.PM.threshold))],min(stair.stimRange):.01:max(stair.stimRange)),'Color',plotColours{thisStair},'linewidth',lineWidth)
            %         plot([min(SL):.01:max(SL)], stair.PF([stair.PM.threshold(end) 10.^stair.PM.slope(end) stair.priorGammaRange stair.PM.lapse(end)],min(stair.stimRange):.01:max(stair.stimRange)),'Color',plotColours{thisStair},'linewidth',lineWidth)
            text(min(stair.stimRange)+(max(stair.stimRange)-min(stair.stimRange))/1.3, .70,['\alpha ', num2str(estA_pcnt)],'color',[0 0 0],'Fontsize',fontSize)
%             text(min(stair.stimRange)+(max(stair.stimRange)-min(stair.stimRange))/1.3, .60,['\beta ', num2str(estB)],'color',[0 0 0],'Fontsize',fontSize)
        else
            plot([min(SL):.01:max(SL)], stair.PM.PF([stair.PM.xStaircase(end) 10.^(stair.beta) stair.PM.gamma stair.PM.lambda],min(SL):.01:max(SL)),'Color', plotColours{thisStair},'LineWidth',lineWidth)
            text(min(SL)+(max(SL)-min(SL))/1.3, (.5 + (thisStair*.1)),['\alpha ', num2str(estA_pcnt)],'color',[0 0 0],'Fontsize',fontSize)
        end
        
        % set(gca,'ytick',[0:.25:1]);
        set(gca,'yLim',[.5, 1]);
        drawnow
    end
end

% Get the stim levels at which participant performane is .3 .5 and .7
if procedure == 1
    pptPMFvals = [stair.PM.threshold(length(stair.PM.threshold)) 10.^stair.PM.slope(length(stair.PM.threshold)) 0 stair.PM.lapse(length(stair.PM.threshold))];
    inversePMFvals = [0.3, 0.5, 0.7];
    inversePMFstims = stair.PF(pptPMFvals, inversePMFvals, 'inverse');
    inversePMFstims = round(inversePMFstims,2);
end


%% Calculate overall accuracy
validTrials     = ~isnan(Results.Resp);  %Resp, 1 correct, 0 incorrect
nValidTrials    = sum(validTrials);
nCorrectTrials  = sum(Results.Resp(validTrials));
accuracy        = nCorrectTrials./nValidTrials; 

disp(['Session accuracy: ', num2str(accuracy)]);
Results.acc     = accuracy;

%% Print dissy, breathless & asthma ratings
dizzyR          = Results.ExpRareEnd(1,2);
breathlessR     = Results.ExpRareEnd(1,3);
asthmaR         = Results.ExpRareEnd(1,4);

disp(['Dizzy rating: ', num2str(round(dizzyR))]);
disp(['Breathless rating: ', num2str(round(breathlessR))]);
disp(['Asthma rating: ', num2str(round(asthmaR))]);

%% Plot accuracy x RT
RT              = Results.RT;
correctTrials   = nanmean(RT(Results.Resp == 1));
incorrectTrials = nanmean(RT(Results.Resp == 0));

if showPlot
    subplot(spRows,spCols,4); hold on;
    title('RT x accuracy');
    set(gcf,'color','w');
    X = categorical({'Correct','Incorrect'});
    Y = [correctTrials, incorrectTrials];
    bar(X,Y, 0.5, 'FaceColor',plotColours{1},'LineWidth',0.1)
    set(gca,'yLim',[0, 3]);
    ylabel('RT (s)','fontsize',fontSize);
    
    
    %% Plot accuracy x confidence
    if existMcgnData        % If confidence ratings were collected
        Conf            = Results.ConfResp;
        correctTrials   = nanmean(Conf(Results.Resp == 1));
        incorrectTrials = nanmean(Conf(Results.Resp == 0));
        
        subplot(spRows,spCols,5); hold on;
        title('Confidence x accuracy');
        set(gcf,'color','w');
        X = categorical({'Correct','Incorrect'});
        Y = [correctTrials, incorrectTrials];
        bar(X,Y, 0.5, 'FaceColor',plotColours{1},'LineWidth',0.1)
        set(gca,'yLim',[0, 100]);
        ylabel('Confidence ratings','fontsize',fontSize);
    end
    
    %% Plot unpleasantness rating x break #
    blahRateMat    	= Results.ExpRateTask;
    nRatigs         = size(blahRateMat,2);
    blahRateVals    = blahRateMat(1, :);
    
    subplot(spRows,spCols,(spCols*spRows)); hold on;
    title('Task unpleasantness');
    set(gcf,'color','w');
    X = categorical(1:nRatigs);
    bar(X, blahRateVals, 0.5, 'FaceColor',plotColours{2},'LineWidth',0.1)
    set(gca,'yLim',[0, 100]);
    ylabel('Unpleasantness rating','fontsize',fontSize);
    xlabel('Timepoint','fontsize',fontSize);
    
    
end


%% Save updated results file
vars.DataFileName = ['a', vars.DataFileName];
% save(strcat(vars.OutputFolder, vars.DataFileName), 'stair', 'Results', 'vars', 'scr', 'keys' );

% Will save to current directory
% save(vars.DataFileName, 'stair', 'Results', 'vars', 'scr', 'keys' );

% Save in /github/Respiroception/data/raw
if exist('desiredOutputDir','var')
    outputFolder        = fullfile(desiredOutputDir,vars.DataFileName);
else
    outputFolder        = fullfile(filesep,'Users', 'au657961','github','Respiroception','data','raw',vars.DataFileName);
end

save(outputFolder, 'stair', 'Results', 'vars', 'scr', 'keys' );
disp(['Preprocessed file saved as: ', vars.DataFileName])

%% Save figure
if savePlot
    % PDF
%     figFilename    = fullfile(filesep,'Users', 'au657961','github','Respiroception','data','subjectReports',[vars.DataFileName(2:end),'.pdf']);
%     saveas(gcf, figFilename)

    % PNG
    % In Git folder
%     figFilename    = fullfile(filesep,'Users', 'au657961','github','Respiroception','data','subjectReports',[vars.DataFileName(2:end),'.png']);
     % In /aux/
    figFilename    = fullfile(filesep,'Volumes','aux', 'MINDLAB2019_Visceral-Mind','6_reports','RRST','VMP2',[vars.DataFileName(2:end),'.png']);   
    saveas(gcf, figFilename)
    
    
    % Print outputccccc
    disp('Figures saved.')
end