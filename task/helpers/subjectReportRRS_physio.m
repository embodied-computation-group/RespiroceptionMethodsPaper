function subjectReportRRS_physio(filepath)
% function subjectReportRRS_physio(filepath)
%
% Arguments:
%   filepath    RRS data log path
%
% Make a single subject analysis report. Works with either Psi or Quest
%   - check functionality with Ndown, MCS
%   - includes physio (pressure & flow) plot
%
% Project: Respiratory resistance sensitivity task
%
% Niia Nikolova
% Last edit: 05/06/2021

showPlot    = 1;            % Optional flag, set to 1 to display a summary figure for each subject (session)
savePlot    = 0;            % Optional flag to save plot output (as pdf & png)

%% Setup
% Check input args & load file
if nargin < 1
    disp('No file name was passed. Please select a raw ''RRS_SUBID_'' data file.');
    % Select a file & load
    [file, path]    = uigetfile('*.mat', 'Select a subject RRS results file.');
    filepath        = [path, file];
    subID           = file(5:8);
    
elseif nargin == 1
   % Do nothing
end

% Load RRS data log
load(filepath);
disp(['Processing data file: ', filepath])

% Load presure & flow logs
pressureFile    = strcat('p_',subID,'.csv');

filesInSubDir   = dir(path);
flowFile        = 0;
for thisFile = 3:size(filesInSubDir,1)
    fName       = filesInSubDir(thisFile).name;
    flowFileTF 	= contains(fName,'SFM3019');
    if flowFileTF
        flowFile    = fName;
    end
end

pData   = readtable([path, pressureFile]);

if sum(flowFile) ~= 0       % if there is a flow file for this subject
    % Make a copy of the flow file as csv
    flowFileCSV     = [flowFile(1:end-4), '.csv'];
    copyfile([path, flowFile], [path, flowFileCSV])
    fData   = readtable([path, flowFileCSV]);
end

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
    spCols = 2;
    spRows = 3;

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


%% Plot pressure data
xVar    = pData.Sample_(:,1);
yVar    = pData.FlowLinearized_Pa_(:,1);
if iscell(yVar)     % in some cases this var is imported as a cell, convert
    yVar    = str2double(yVar);             
end

% Remove yVar values between some range
zeroVals = yVar < -150 | yVar > 150;
yVar = yVar(zeroVals);
xVar = xVar(zeroVals);

%yVar( yVar < 0 ) = 0;           % remove negative values
xVar2 = str2double(xVar);       % convert cell to double

if showPlot
    % Plot pressure
    subplot(spRows,spCols,3:4); hold on;
    title('Pressure','FontWeight','Normal');
    xlabel('Sample #','fontsize',fontSize);
    ylabel('Pa','fontsize',fontSize);
    hold on
    
    plot(xVar2, yVar)
end



%% Import & plot flow
xVar    = 1: size(fData,1);
yVar    = fData(:,3);
yVar    = table2array(yVar);             

% % Remove yVar values between some range
% zeroVals = yVar < -150 | yVar > 150;
% yVar = yVar(zeroVals);
% xVar = xVar(zeroVals);

yVar2 = str2double(yVar);       % convert cell to double

if showPlot
    % Plot flow
    subplot(spRows,spCols,5:6); hold on;
    title('Flow','FontWeight','Normal');
    xlabel('Sample #','fontsize',fontSize);
    ylabel('Flow (cms)','fontsize',fontSize);
    hold on
    
    plot(xVar, yVar2)
end


%% Save figure
if savePlot
%     % PDF
%     figFilename    = fullfile(filesep,'Users', 'au657961','github','Respiroception','data','subjectReports',[vars.DataFileName(2:end),'.pdf']);
%     saveas(gcf, figFilename)

    % PNG
    figFilename    = fullfile(filesep,'Users', 'au657961','github','Respiroception','data','subjectReports',[vars.DataFileName(2:end),'.png']);
    saveas(gcf, figFilename)
    
    % Print output
    disp('Figures saved.')
end