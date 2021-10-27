%% Define parameters
%
% Project: Respiratory Resistance Sensitivity (RRS) Task, version 2-2
%
% Sets key parameters, called by main.m
%
%
% Niia Nikolova
% Last edit: 08/06/2021

%% RRST device port
% To determine which serial port the device is connected on,
% Unplug device USB cable from stim PC, then type 'serialportlist' 
% in the Matlab command window (& Enter). Then plug in the USB cable, 
% and repeat the command. Note which port is new, eg, ?COM5?. 
% Enter this below.
sPort = "COM7";

%% Key flags
vars.runTutorial    = 1;        % Run through tutorial?
vars.ConfRating     = 1;        % Collect confidence ratings? (1 yes, 0 no)
vars.Procedure      = 1;      	% 1 Psi, 2 N-down, 3 MCS, 4 QUEST, NB. only Psi and QUEST have been tested recently!
vars.InputDevice    = 2;        % 1 Keyboard, 2 Mouse (Keyboard not tested recently)
vars.playNoiseSound = 1;        % Play white noise to mask motor sound (1 yes, 0 no)
if strcmp(vars.languageIn, 'e')
   vars.language       = 1;
elseif strcmp(vars.languageIn, 'd')
   vars.language       = 2; 
end
% vars.language       = 1;        % 1 English, 2 Danish
vars.probeTaskSatisfaction = 1;         % In breaks, ask how unpleasant participants find the task
vars.collectExperienceRatings = 1;      % Collect subjective dizzy, breathless, and asthma symptoms ratings at end of session
vars.pluxSynch      = 0;
vars.RRSTdevice     = 1;        % Are we running with an RRST device? Can set to 0 for testing other parts of the experiment

% Get current timestamp & set filename
startTime = clock;
saveTime = [num2str(startTime(4)), '-', num2str(startTime(5))];
vars.DataFileName = strcat(vars.DataFileName, num2str(vars.Procedure), '_', date, '_', saveTime);



%% Procedure
%Set up psi
if vars.Procedure == 1              % Single staircase for Psi, 2 for N-down and Quest
    vars.Nstaircases    = 1; 
    vars.NumTrials      = 100;       % Number of trials in EACH staircase (in case of interleaved staircases)
else
    vars.Nstaircases    = 2;
    vars.NumTrials      = 30;       % Number of trials in EACH staircase (in case of interleaved staircases)
end
vars.NMetacogTrials     = 0;%40;    % Number of extra metacognition trials (near threshold level) to add at end
vars.NTrialsTotal       = (vars.NumTrials * vars.Nstaircases) + vars.NMetacogTrials;  % Total N trials differs from vars.NumTrials when we have multiple staircases

% Setup metacog trials
if vars.NMetacogTrials ~= 0
    vars.MC.threshLevel = 0.75;        % Performance level to use as threshold
    vars.MC.jitter      = 0.05;        % Jitter to add (percent performance)
end

% Setup staircase
if vars.Procedure == 1      % Psi-method
   
    vars.RDunitscale = 1;                       % Units for Resp device commands, 0 percent (0-100), or 1 mm (0-17)
    
    stair.grain             = 72;%50;               % Grain of posterior, high numbers make method more precise at the cost of RAM and time to compute.
    %Always check posterior after method completes [using e.g., :
    %image(PAL_Scale0to1(PM.pdf)*64)] to check whether appropriate
    %grain and parameter ranges were used.
    
    stair.PF                = @PAL_Weibull;    	% Assumed psychometric function, e.g. @PAL_Gumbel, @PAL_Logistic, @PAL_Weibull;
    
    %Stimulus values the method can select from
%     stair.stimRange         = (linspace(stair.PF([6 2 0 0],.1,'inverse'),stair.PF([6 2 0 0],.9999,'inverse'),17));  % mm obstruction
    stair.stimRange         = (linspace(0,17,36)); 
    
    %Define parameter ranges to be included in posterior
%     stair.priorAlphaRange   = linspace(stair.PF([6 2 0 0],.1,'inverse'),stair.PF([6 2 0 0],.9999,'inverse'),stair.grain); 
%     stair.priorBetaRange    = linspace(log10(1),log10(16),stair.grain); 	% Use log10 transformed values of beta (slope) parameter in PF
    stair.priorAlphaRange   = linspace(0,17,stair.grain); 
    stair.priorBetaRange    = linspace(0,7,stair.grain);
    stair.priorGammaRange   = 0.5;                                         
    stair.priorLambdaRange  = .03;
    
    %Initialize PM structure
    stair.PM = PAL_AMPM_setupPM('priorAlphaRange',stair.priorAlphaRange,...
        'priorBetaRange',stair.priorBetaRange,...
        'priorGammaRange',stair.priorGammaRange,...
        'priorLambdaRange',stair.priorLambdaRange,...
        'numtrials',vars.NumTrials,...
        'PF' , stair.PF,...
        'stimRange',stair.stimRange);
    
elseif vars.Procedure == 2      % N-down
    
    vars.RDunitscale = 0;                       % Units for Resp device commands, 0 percent (0-100), or 1 mm (0-17)

    for thisStair = 1:vars.Nstaircases
        % Define the parameters of the staircase
        stair(thisStair).up = 1;
        stair(thisStair).down = 1;
        stair(thisStair).stepSizeUp = [40 40 20 20 20 20 10 10 10 10 5 5 5 5 2.5];
        stair(thisStair).stepSizeDown = [40 40 20 20 20 20 10 10 10 10 5 5 5 5 2.5];
        stair(thisStair).stopCriterion = 'trials';
        stair(thisStair).stopRule = vars.NumTrials;
        if thisStair == 1
            stair(thisStair).startValue = 97;
        elseif thisStair == 2
            stair(thisStair).startValue = 5;
        end
        
        %Initialize PM structure
        stair(thisStair).PM = PAL_AMUD_setupUD('up',stair(thisStair).up,...
            'down',stair(thisStair).down,...
            'stepSizeUp',stair(thisStair).stepSizeUp,...
            'stepSizeDown',stair(thisStair).stepSizeDown,...
            'stopCriterion',stair(thisStair).stopCriterion,...
            'stopRule' , stair(thisStair).stopRule,...
            'startValue',stair(thisStair).startValue,...
            'xMax', 100,...
            'xMin', 5);
    end
    
    
elseif vars.Procedure == 3      % MCS

    vars.RDunitscale = 0;                       % Units for Resp device commands, 0 percent (0-100), or 1 mm (0-17)
    
    vars.NLevels        = 10;     	% N stimulus levels
    vars.NTrials        = 6;        % N reps / level
    vars.NTrialsTotal   = vars.NTrials * vars.NLevels;
    vars.stimRange    	= round(linspace(50, 100, vars.NLevels));    % Stimulus values the method can select from
    
    % Generate repeating list & randomize order of stimuli
    StimTrialList = repmat(vars.stimRange', vars.NTrials, 1);
    ntrials = length(StimTrialList);
    randomorder = randperm(length(StimTrialList));
    vars.StimTrialList = StimTrialList(randomorder);
    
    
elseif vars.Procedure == 4      % Running fit method
    
    vars.RDunitscale = 1;       % Units for Resp device commands, 0 percent (0-100), or 1 mm (0-17)
    
    for thisStair = 1:vars.Nstaircases
        % Define the priors
        stair(thisStair).alphas = [0:01:17];
        stair(thisStair).xMin = 1;                 % Min value of stim magnitude
        stair(thisStair).xMax = 17;                % Max value of stim magnitude
%        % Gaussian prior
%         stair(thisStair).prior = PAL_pdfNormal(stair(thisStair).alphas,0,2); 
        % Uniform prior
        stair(thisStair).prior = ones(size(stair(thisStair).alphas));
        stair(thisStair).prior = stair(thisStair).prior./sum(stair(thisStair).prior);
        % Termination rule
        stair(thisStair).stopCriterion = 'trials';  
        stair(thisStair).stopRule = vars.NumTrials; 
        
        
        % Function to be fitted during procedure
        stair(thisStair).PFfit = @PAL_Weibull;      % Shape to be assumed
        stair(thisStair).beta = 1.5;                % Slope to be assumed
        stair(thisStair).lambda  = 0.02;            % Lapse rate to be assumed
        stair(thisStair).meanmode = 'mean';         % Use mean of posterior as placement rule
        
        %Initialize PM structure
        stair(thisStair).PM = PAL_AMRF_setupRF('priorAlphaRange', stair(thisStair).alphas, ...
            'stopcriterion',stair(thisStair).stopCriterion,'stoprule',stair(thisStair).stopRule,'beta',stair(thisStair).beta,...
            'lambda',stair(thisStair).lambda,'PF',stair(thisStair).PFfit,'meanmode',stair(thisStair).meanmode,...
            'xMax', stair(thisStair).xMax,...
            'xMin', stair(thisStair).xMin);
        
    end
    
end % procedure




%% Task timing
% All in seconds
vars.fixedTiming = 0;                       % Switch, 0 self-paced, 1 fixed timing (e.g. will wait for full response time)
vars.PrepareT   = 1.5;                      % Cue trial start
vars.inhaleT    = 0.8;                      % Inhalation time
vars.breathPauseT = 0.5;                    % Pause before inhale & at peak inhalation
vars.RespT      = 3;                        % Response time 
vars.ConfT      = 5;                        % Confidence rating time 
vars.ISI        = 2;                        % Inter stimulus interval (exhale)
vars.ITI_min    = 2;                        % Inter trial interval (variable)
vars.ITI_max    = 4;
vars.ITI        = randInRange(vars.ITI_min, vars.ITI_max, [vars.NTrialsTotal,1]);

% Setup 2AFC signal intervals
vars.wheresTheSignal    = [ones(vars.NTrialsTotal/2, 1); ones(vars.NTrialsTotal/2, 1).*2];
randomorder             = randperm(length(vars.wheresTheSignal));
vars.wheresTheSignal    = vars.wheresTheSignal(randomorder);

% Setup which staircase a trial is pulled from, for N-down and Quest
if (vars.Procedure == 2) ||  (vars.Procedure == 4)
    vars.whichStair         = [ones(vars.NTrialsTotal/2, 1); ones(vars.NTrialsTotal/2, 1).*2];
    randomorder             = randperm(length(vars.whichStair));
    vars.whichStair         = vars.whichStair(randomorder);
else
    vars.whichStair         = [ones((vars.NTrialsTotal), 1)];       
end

% Breaks
vars.pauseT     = 120;              % Break duration, in seconds
if vars.ConfRating
    vars.PauseFreq = 20;
else
    vars.PauseFreq = 30;
end
vars.nBreaks    = floor((vars.NTrialsTotal/vars.PauseFreq));
vars.eqT        = 10;               % Response time for experience questions


%% Plux synch variables
% Colours: White, Black
scr.pluxWhite     = [1 1 1];
scr.pluxBlack     = [0, 0, 0];

% Duration
scr.pluxDur         = [2; 25];% [2;4]       % 2 frames - stim, 4 frames - response

% Size
% rows: x y width height
% provide size in cm and convert to pix
pluxRectTemp        = [0; 0; 0.5; 0.5];
multFactorW         = scr.resolution.width ./ scr.MonitorWidth;
multFactorH         = scr.resolution.height ./ scr.MonitorHeight;
scr.pluxRect(3)     = pluxRectTemp(3) .* multFactorW;
scr.pluxRect(4)     = pluxRectTemp(4) .* multFactorH;
scr.pluxRect = CenterRectOnPoint(scr.pluxRect,scr.pluxRect(3),scr.resolution.height - scr.pluxRect(4));


%% Instructions

% Main task instructions / Welcome
%% English
if vars.language == 1
    switch vars.ConfRating
        case 1
            
            if vars.runTutorial == 0
                vars.InstructionTask = 'WELCOME TO THE BREATH SENSITIVITY TASK! \n \n \n \n \n \n On each trial, you will take two breaths (inhalations).  \n \n Breathe shallowly and pace your inhalations with the expanding circle. \n \n \n \n Then, decide which of the two breaths was more difficult. \n \n First breath - Left mouse button             or            Second breath - Right mouse button \n \n \n \n Then, rate how confident you are in your choice using the slider. \n \n Press ''SPACE'' to start...';
            else
                vars.InstructionTask = 'WELCOME TO THE BREATH SENSITIVITY TASK! \n \n \n \n Press ''SPACE'' to continue to the tutorial. ';
            end
            
            vars.InstructionConf = 'How confident are you in your choice?';
            vars.ConfEndPoins    = {'Guess', 'Certain'};
        case 0
            if vars.runTutorial == 0
                vars.InstructionTask = 'WELCOME TO THE BREATH SENSITIVITY TASK! \n \n \n \n \n \n On each trial, you will take two breaths (inhalations).  \n \n Breathe shallowly and pace your inhalations with the expanding circle. \n \n \n \n Then, decide which of the two breaths was more difficult. \n \n First breath - Left mouse button             or            Second breath - Right mouse button \n \n \n \n Press ''SPACE'' to start...';
            else
                vars.InstructionTask = 'WELCOME TO THE BREATH SENSITIVITY TASK! \n \n \n \n Press ''SPACE'' to continue to the tutorial. ';
            end
            vars.InstructionConf = 'How confident are you in your choice?';
            vars.ConfEndPoins    = {'Guess', 'Certain'};
    end
    
    % Experiment text
    vars.InstructionStart       = 'The experiment will start now. Press ''SPACE'' to start.';
    vars.InstructionPrepare     = 'Breathe naturally...  \n \n Get ready to inhale in \n \n';
    vars.InstructionGetReady     = 'Get ready';
    vars.InstructionPrepareFirstTrial     = 'Get ready to inhale in \n \n';
    vars.InstructionInhale1     = 'Take the first inhale...';
    vars.InstructionInhale2     = 'Take the second inhale...';
    vars.InstructionISI         = 'Exhale... \n \n Get ready to inhale in \n \n';
    vars.InstructionQ           = 'Which breath was harder? \n \n First breath (L)     or     Second breath (R)';
    vars.InstructionPause       = 'Take a short break. Please stand up and move around. \n \n Remember to take sharp and shallow breaths during the task. \n \n \n \n You can continue in \n \n';
    vars.InstructionPauseStart  = 'You can continue now. \n \n When you are ready to continue, press ''SPACE''... ';
    vars.InstructionEnd         = 'You have completed the session. Thank you!';
    
    
    % Experience ratings
    vars.InstructionEQ      = 'Please answer a few quick questions about how you felt during the Breath Sensitivity Task. \n \n Press ''SPACE'' to continue...';
    vars.QuestionsAsthma    = 'Do you have asthma or another respiratory condition? \n \n No (L)     or     Yes (R)';
    
    % 1 Label, 2 Question, 3 Scale
    vars.Questions{1,1} = 'TaskGeneral';
    vars.Questions{1,2} = 'I find the task';
    vars.Questions{1,3} = {'Not unpleasant', 'Very unpleasant'};
    
    vars.Questions{2,1} = 'Dizzy';
    vars.Questions{2,2} = 'I feel dizzy / lightheaded.';
    vars.Questions{2,3} = {'Not at all', 'Completely'};
    
    vars.Questions{3,1} = 'Breathless';
    vars.Questions{3,2} = 'I feel breathless / have trouble breathing.';
    vars.Questions{3,3} = {'Not at all', 'Completely'};
    
    vars.Questions{4,1} = 'Asthma';
    vars.Questions{4,2} = 'If you have asthma, rate the severity of your symptoms in the last week.';
    vars.Questions{4,3} = {'No asthma / none', 'Very severe'};
    
    %% Danish
elseif vars.language == 2
    switch vars.ConfRating
        case 1
            
            if vars.runTutorial == 0
                vars.InstructionTask = 'VELKOMMEN TIL VEJRTRÆKNINGSFØLSOMHEDSOPGAVEN! \n \n \n \n \n \n I hver runde skal du tage to åndedrag (indåndinger). \n\n Tag skarpe og overfladiske åndedrag og forsøg at indånde jævnt, mens cirklen på skærmen udvider sig. \n \n \n \n  Efterfølgende vil du blive spurgt om, hvilken af de to indåndinger, der var mest udfordrende. \n \n Første åndedrag - tryk VENSTRE museknap       eller         Andet åndedrag - tryk på HØJRE museknap \n \n \n \n Bagefter skal du vurdere, hvor sikker du var på dit valg ved at bruge markøren på skalaen. \n \n Tryk på “MELLEMRUMSTASTEN” for at fortsætte…';
            else
                vars.InstructionTask = 'VELKOMMEN TIL VEJRTRÆKNINGSFØLSOMHEDSOPGAVEN!  \n \n Tryk på “MELLEMRUMSTASTEN” for at fortsætte til vejledningen.';
            end
            
            vars.InstructionConf = 'Hvor sikker var du på dit valg?';
            vars.ConfEndPoins    = {'Gæt', 'Helt sikker'};
        case 0
            if vars.runTutorial == 0
                vars.InstructionTask = 'VELKOMMEN TIL VEJRTRÆKNINGSFØLSOMHEDSOPGAVEN! \n \n \n \n \n \n I hver runde skal du tage to åndedrag (indåndinger). \n\n Tag skarpe og overfladiske åndedrag og forsøg at indånde jævnt, mens cirklen på skærmen udvider sig. \n \n \n \n  Efterfølgende vil du blive spurgt om, hvilken af de to indåndinger, der var mest udfordrende. \n \n Første åndedrag - tryk VENSTRE museknap       eller         Andet åndedrag - tryk på HØJRE museknap \n \n \n \n Tryk på “MELLEMRUMSTASTEN” for at fortsætte…';
            else
                vars.InstructionTask = 'VELKOMMEN TIL VEJRTRÆKNINGSFØLSOMHEDSOPGAVEN!  \n \n Tryk på “MELLEMRUMSTASTEN” for at fortsætte til vejledningen.';
            end
            
            vars.InstructionConf = 'Hvor sikker var du på dit valg?';
            vars.ConfEndPoins    = {'Gæt', 'Helt sikker'};
    end
    
    % Experiment text
    vars.InstructionStart       = 'Eksperimentet starter nu. Tryk på MELLEMRUMSTASTEN';
    vars.InstructionPrepare     = 'Træk vejret naturligt… \n\n Gør dig klar til at ånde ind om \n \n';
    vars.InstructionGetReady    = 'Gør dig klar…';
    vars.InstructionPrepareFirstTrial     = 'Gør dig klar til at ånde ind om \n \n';
    vars.InstructionInhale1     = 'Tag den første indånding…';
    vars.InstructionInhale2     = 'Tag den anden indånding…';
    vars.InstructionISI         = 'Ånd ud… \n\n Gør dig klar til at ånde ind om \n \n';
    vars.InstructionQ           = 'Hvilket åndedrag var mest udfordrende \n\n Det første (Venstre) eller det andet (Højre)';
    vars.InstructionPause       = 'Tag en kort pause. Rejs dig op og bevæg dig. \n \n Husk at tage skarpe og overfladiske indåndinger undervejs i opgaven. \n \n \n \n Du kan fortsætte om \n \n';
    vars.InstructionPauseStart  = 'Du kan nu fortsætte. \n \n Tryk på “MELLEMRUMSTASTEN” for at fortsætte... ';
    vars.InstructionEnd         = 'Du har gennemført sessionen. Tak!';
    
    
    % Experience ratings
    vars.InstructionEQ      = 'Besvar venligst nogle få enkle spørgsmål om, hvordan du havde det under Vejrtrækningsfølsomhedsopgaven. \n \n Tryk på “MELLEMRUMSTASTEN” for at fortsætte…';
    vars.QuestionsAsthma    = 'Har du astma eller en anden luftvejssygdom? \n \n Nej (Venstre) eller Ja (Højre)';
    
    % 1 Label, 2 Question, 3 Scale
    vars.Questions{1,1} = 'TaskGeneral';
    vars.Questions{1,2} = 'Jeg fandt opgaven';
    vars.Questions{1,3} = {'Ikke ubehageligt', 'Meget ubehageligt'};
    
    vars.Questions{2,1} = 'Dizzy';
    vars.Questions{2,2} = 'Jeg føler mig svimmel / ør.';
    vars.Questions{2,3} = {'Slet ikke', 'Fuldstændigt'};
    
    vars.Questions{3,1} = 'Breathless';
    vars.Questions{3,2} = 'Jeg føler mig åndeløse / forpustet / har besvær ved at trække vejret.';
    vars.Questions{3,3} = {'Slet ikke', 'Fuldstændigt'};
    
    vars.Questions{4,1} = 'Asthma';
    vars.Questions{4,2} = 'Hvis du lider af astma, vurder da alvorsgraden af dine symptomer i løbet af den sidste uge.';
    vars.Questions{4,3} = {'Ingen astma /ingen symptomer', 'Meget alvorlige symptomer'};
    
end

vars.nQuestions = length(vars.Questions);
vars.randQOrder = mixArray([1:vars.nQuestions]);
Results.ExpRateTask = NaN .* ones(1, vars.nBreaks);
Results.ExpRareEnd = NaN .* ones(1, vars.nQuestions);
