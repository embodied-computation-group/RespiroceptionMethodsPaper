function main(vars, scr)
%function main(vars, scr)
%
% Project: Respiratory Resistance Sensitivity (RRS) Task.
%
% Main experimental script. Called by experimentLauncher.m
%
% Input:
%   vars        struct with key parameters (most are defined in loadParams.m)
%   scr         struct with screen / display settings
%
% Niia Nikolova
% Last edit: 28/05/2021

%% Key flags
simplePlot      = 0;        % Show a simple plot summarising results at end of session
openSmallWin    = 0;        % open small window for debugging

%% ============================ SET-UP ================================

% Diplay configuration
[scr] = displayConfig(scr);

% Keyboard & keys configuration
[keys] = keyConfig();

% Reseed the random-number generator
SetupRand;

% Load the parameters
loadParams;

% Results structure
DummyDouble = ones(vars.NTrialsTotal,1).*NaN;
Results = struct('trialN',{DummyDouble},'Stim',{DummyDouble},'SignalInterval',{DummyDouble},...
    'Resp',{DummyDouble},'RespLR',{DummyDouble},'ConfResp', {DummyDouble},...
    'RT',{DummyDouble}, 'ConfRT', {DummyDouble}, 'ConfOn', {DummyDouble},...
    'ConfOff', {DummyDouble}, 'MetacogTrials', {DummyDouble},...
    'trialSuccess', {DummyDouble}, 'SubID', {DummyDouble});


%% Set up the respiratory load device, if not already initialized
if vars.RRSTdevice == 1
    if (exist('RD','var')==0) || isnan(RD.respDevice)  
        sBaudRate = 9600;
        [RD.init, RD.respDevice] = setupResp(sPort, sBaudRate);
        unitscale = vars.RDunitscale;       % units to scale. 0 percent (0-100), 1 mm (0-17)
        if ~RD.init
            return
        end
    end  
else
    RD = 0;         % dummy
end

%% Enter which sound to play
% The audio .wav file with the corresponding name should be located in
% /helpers/audio
if vars.playNoiseSound
    soundFile = 1;          % Which sound to play? 1 Waterfall, 2 RainA, 3 RainB (duration 60min)
    switch soundFile
        case 1
            thisSound = '32-Waterfall-60min.wav';
        case 2
            thisSound = '34-Rain-60min.wav';
        case 3
            thisSound = '44-Rain-60min.wav';
    end
end


%% Prepare to start
AssertOpenGL;

try
    %% Open screen window
    if openSmallWin
    	[scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray, [0,0,3840/3,2160/3]);
    else
        [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray);
    end
    
    % Set text size, dependent on screen resolution
    if any(logical(scr.winRect(:)>3000))       % 4K resolution
        scr.TextSize = 45;%65;
    else
        scr.TextSize = 28;%50;
    end
    Screen('TextSize', scr.win, scr.TextSize);
    Screen('TextFont', scr.win, 'Arial');  
    Screen('Textfont', scr.win, '-:lang=da');   % allow danish characters
    
    % Switch color specification to use the 0.0 - 1.0 range instead of the 0 -
    % 255 range. This is more natural for these kind of stimuli:
    Screen('ColorRange', scr.win, 1);
    White   = WhiteIndex(scr.screenID);
    Black   = BlackIndex(scr.screenID);
    Gray    = GrayIndex(scr.screenID);
    scr.BackgroundGray  = Gray + 0.037;%-0.3;
    scr.TextColour      = White;
    firstColor          = [0.14, 0.82, 0.67, 1];       	% dark teal
    
    % Get frame rate
    scr.hz  = Screen('NominalFrameRate', scr.win); 
    disp(['Frame rate: ', num2str(scr.hz)])

    % Set priority for script execution to realtime priority:
    scr.priorityLevel = MaxPriority(scr.win);
    Priority(scr.priorityLevel);
    
    % Determine stim size in pixels
    scr.dist        = scr.ViewDist;
    scr.width       = scr.MonitorWidth;
    scr.height      = scr.winRect(4);
    %scr.resolution  = scr.winRect(3);           	% number of pixels of display in horizontal direction
    scr.rad         = 240;                        	% radius of circle to display for breath
    scr.x_middle    = scr.winRect(3) / 2;
    scr.y_middle    = scr.winRect(4) / 2;
    
    % Dummy calls to prevent delays
    vars.ValidTrial = zeros(1,2);
    vars.RunSuccessfull = 0;
    vars.Aborted    = 0;
    vars.Error      = 0;
    vars.abortFlag  = 0;
    metacogTrialsCreated = 0;
    probeNb         = 1;

    Resp            = nan;
    vars.RespLR     = nan;
    vars.ConfResp   = nan;
    
    GetSecs;
    WaitSecs(0.500);
    [~, ~, keys.KeyCode] = KbCheck;
    
    %% Show task instructions
    showInstruction(scr, keys, vars.InstructionTask);
    
    % Move device to ITI position (a little bit back from no load)
    if vars.RRSTdevice == 1
        moveResp2ITIpos(RD.respDevice, unitscale);
    end
    
    % Start noise playback
    if vars.playNoiseSound
        playSound(thisSound);
    end
    
    
    %% ============================ TUTORIAL ================================
    
    if vars.runTutorial
        
        % Run tutorial
        disp('Running through tutorial...');
        respiroceptionTutorial(scr, keys, vars, RD);

    end
    
    
    %% ========================== MAIN EXPERIMENT ===========================
    
    % The experiment will begin now
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, [vars.InstructionStart], 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    WaitSecs(0.2);
    
    % Wait for space
    while keys.KeyCode(keys.Space) == 0
        [~, ~, keys.KeyCode] = KbCheck;
        WaitSecs(0.001);
    end
    Results.SessionStartT = GetSecs;            % Session start timestamp
       
    
    %% Get Ready screen
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, vars.InstructionGetReady, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    WaitSecs(3);                % pause before experiment start
    thisTrial = 1;              % trial counter
    thisMetacogTrial = 1;
    go2MetacogTrials = 0;
    endOfExpt = 0;
    
    
    %% Run through trials
    while endOfExpt ~= 1                % General stop flag for the loop
        
        % Present the two stim alternatives
        for thisAlt = 1:2
            
            if vars.Procedure == 3      % MCS - manually set the current stim intensity
                stair.PM.xCurrent = vars.StimTrialList(thisTrial);
            end
            
            %% Move respdevice to desired position
            if vars.wheresTheSignal(thisTrial) == thisAlt	% If this is the signal alternative  
                vars.stimIsHere = 1;            % set flag to 1, used for plux synch in drawExpandingRing.m
                
                % Determine which stimulus to present
                if stair(1).PM.stop~=1  || stair(2).PM.stop~=1   	% Psi staircase or N-down
                    % Which staircase is the stim coming from
                    thisTrialStaircase  = vars.whichStair(thisTrial);
                    thisTrialStim       = round(stair(thisTrialStaircase).PM.xCurrent);

                else                        % Metacog trials
                    if isfield('vars', 'MetacogTrialsList')
                        disp(['Metacog trial # ', num2str(thisMetacogTrial)]);
                        thisTrialStim   = vars.MetacogTrialsList(thisMetacogTrial);
                    else 
                        % Finish trials
                        break
                    end
                end
                
                disp(['Trial # ', num2str(thisTrial), ', staircase ', num2str(thisTrialStaircase),'. Position: ', num2str(thisTrialStim)]);
                disp(['Load is in breath ', num2str(vars.wheresTheSignal(thisTrial))]);
                
                % Move to desired load
                if vars.RRSTdevice == 1
                    moveResp(RD.respDevice, thisTrialStim, unitscale);
                end
                
            else	% If this is the null stim, make a sham movement
                vars.stimIsHere = 0;            % set flag to 0, used for pluc synch
                
                % No load
                if vars.RRSTdevice == 1
                    moveResp2NoLoad(RD.respDevice, unitscale);
                end
            end
            
            % Clear display while we adjust the load & show counter
            % Update counter
            tRemaining = vars.ISI;
            if thisAlt==2
                instructionPrepare2Breathe = vars.InstructionISI ;
            else
                instructionPrepare2Breathe = vars.InstructionPrepareFirstTrial;
            end
            counterText = strcat(instructionPrepare2Breathe, num2str(tRemaining), ' sec.');
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            Screen('FrameOval', scr.win, firstColor, [scr.x_middle-scr.rad scr.y_middle-scr.rad scr.x_middle+scr.rad scr.y_middle+scr.rad], 3, 3);
            DrawFormattedText(scr.win, counterText, 'center', 3*scr.height/4, scr.TextColour);
            [~, ISIstart] = Screen('Flip', scr.win);
            
            % Wait for ISI time
            while (GetSecs - ISIstart) <= vars.ISI
                % Update counter
                tRemaining = round(vars.ISI - (GetSecs - ISIstart));
                counterText = strcat(instructionPrepare2Breathe, num2str(tRemaining), ' sec.');
                Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                Screen('FrameOval', scr.win, firstColor, [scr.x_middle-scr.rad scr.y_middle-scr.rad scr.x_middle+scr.rad scr.y_middle+scr.rad], 3, 3);  
                DrawFormattedText(scr.win, counterText, 'center', 3*scr.height/4, scr.TextColour);
                [~, ~] = Screen('Flip', scr.win);
                
                % KbCheck for Esc key
                if keys.KeyCode(keys.Escape)==1
                    % Reset resp device
                    if vars.RRSTdevice == 1
                        resetResp(RD.respDevice)
                    end
                    % Save, mark the run
                    vars.RunSuccessfull = 0;
                    vars.Aborted = 1;
                    experimentEnd(vars, scr, keys, Results, stair);
                    return
                end
                [~, ~, keys.KeyCode] = KbCheck;
                WaitSecs(0.001);
            end

            
            %% Text: 'Inhale....'
            if thisAlt == 1
                vars.InstructionInhale = vars.InstructionInhale1;
                vars.switchColour = 0;
            elseif thisAlt == 2
                vars.InstructionInhale = vars.InstructionInhale2;
                vars.switchColour = 1;
            end

            % Show expanding circle
            %[scr, vars] = drawExpandingRing(scr, vars);
            [scr, vars] = showExpandingRing(scr, vars);
            

        end% 2 Intervals
        
        
        %% Show response prompt screen
        WaitSecs(0.4);
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
        [~, vars.StartRT] = Screen('Flip', scr.win);
        
        % Fetch the participant's response, via keyboard or mouse
        [vars] = getResponse(keys, scr, vars);

        % Get response time
        RT = (vars.EndRT - vars.StartRT);
        
        % Get accuracy
        if vars.wheresTheSignal(thisTrial) == 1         % Load on breath 1
            if vars.RespLR == 0                         % Resp stim 1 
                Resp = 1;                               % Correct
            elseif vars.RespLR == 1                     % Resp stim 2
                Resp = 0;                               % Incorrect
            else               
                Resp = NaN;
            end
            
        elseif vars.wheresTheSignal(thisTrial) == 2     % Load on breath 2
            if vars.RespLR == 0                         % Resp stim 1 
                Resp = 0;                               % Incorrect
            elseif vars.RespLR == 1                     % Resp stim 2
                Resp = 1;                               % Correct
            else               
                Resp = NaN;
            end
        end
        
        % if Esc was pressed
        if vars.abortFlag == 1
            % Reset resp device
            if vars.RRSTdevice == 1
                resetResp(RD.respDevice)
            end
            % Save, mark the run
            vars.RunSuccessfull = 0;
            vars.Aborted = 1;
            experimentEnd(vars, scr, keys, Results, stair);
            return
        end
        

        % Update staircase, if valid response & we're in the main staircase
        if vars.ValidTrial(1) && (go2MetacogTrials ==0) %(stair.PM.stop~=1)
            
            if vars.Procedure == 1          % Psi
                stair.PM = PAL_AMPM_updatePM(stair.PM, Resp);
            elseif vars.Procedure == 2      % N-down
                stair(thisTrialStaircase).PM = PAL_AMUD_updateUD_NN(stair(thisTrialStaircase).PM, Resp);
            elseif vars.Procedure == 3      % MCS
                if thisTrial == vars.NTrialsTotal
                    stair.PM.stop = 1;
                else
                    stair.PM.stop = 0;
                end
            elseif vars.Procedure == 4
                stair(thisTrialStaircase).PM  = PAL_AMRF_updateRF(stair(thisTrialStaircase).PM , stair(thisTrialStaircase).PM.xCurrent, Resp);
            end
        end

        % Update Results mat
        Results.trialN(thisTrial)       = thisTrial;
        Results.Stim(thisTrial)         = thisTrialStim;
        Results.SignalInterval(thisTrial) = vars.wheresTheSignal(thisTrial);
        Results.SubID(thisTrial)        = vars.subNo;
        Results.Resp(thisTrial)         = Resp;             % Correct?
        Results.RespLR(thisTrial)       = vars.RespLR;     	% 0 left (1st breath), 1 right (2nd breath)
        Results.RT(thisTrial)           = RT;
        Results.MetacogTrials(thisTrial)= thisMetacogTrial;
        
        if ~isnan(Resp)
            if Resp
                disp('Correct response');
            else
                disp('Incorrect response');
            end
        end
        
        % Time to stop?
        if (stair(1).PM.stop ~= 1) 
            if numel(stair) > 1
                if (stair(2).PM.stop ~= 1)
                    go2MetacogTrials = 0;
                end
            else
                go2MetacogTrials = 0;
            end
        else
            % If we want to add some extra metacoginition trials
            if vars.NMetacogTrials ~= 0
                go2MetacogTrials = 1;
                thisMetacogTrial = thisMetacogTrial + 1;
                if metacogTrialsCreated == 0
                    % Psi stop reached. Calucalte threshold and create jittered
                    % stim vector for metacog trials
                    vars.MetacogTrialsList = getPMFbasedTrials(vars, stair);
                    metacogTrialsCreated = 1;
                    
                end
            end
        end
        
              
        
        %% Move device back to ITI position
        if vars.RRSTdevice == 1
            moveResp2ITIpos(RD.respDevice, unitscale);
        end
        
        %% Confidence rating     
        if vars.ConfRating
            
            % Fetch the participant's confidence rating
            [vars] = getConfidence(keys, scr, vars);
            
            Results.ConfOn(thisTrial)   = vars.ConfOnset - Results.SessionStartT;
            Results.ConfOff(thisTrial)  = vars.ConfOffset - Results.SessionStartT;
            
            if vars.abortFlag       % Esc was pressed
                Results.ConfResp(thisTrial) = NaN;
                % Reset resp device
                if vars.RRSTdevice == 1
                    resetResp(RD.respDevice)
                end
                % Save, mark the run
                vars.RunSuccessfull = 0;
                vars.Aborted = 1;
                experimentEnd(keys, Results, scr, vars);
                return
            end
            
            % If this trial was successfull, move on...
            if(vars.ValidTrial(2)), WaitSecs(0.2); end
            
            % Write trial result to file
            Results.ConfResp(thisTrial) = vars.ConfResp;
            Results.ConfRT(thisTrial) = vars.ConfRatingRT;
            
            % Was this a successfull trial? (both emotion and confidence rating valid)
            % 1-success, 0-fail
            Results.trialSuccess(thisTrial) = logical(sum(vars.ValidTrial) == 2);
            
            
        else % no Confidence rating
            
            % Was this a successfull trial? (emotion rating valid)
            % 1-success, 0-fail
            Results.trialSuccess(thisTrial) = logical(sum(vars.ValidTrial) == 1);
            
        end
        
        
        %% ITI / prepare for next trial
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        [~, StartITI] = Screen('Flip', scr.win);
        
        % Present the gray screen for ITI duration
        while (GetSecs - StartITI) <= vars.ITI(thisTrial)
            
            if keys.KeyCode(keys.Escape)==1
                % Reset resp device
                if vars.RRSTdevice == 1
                    resetResp(RD.respDevice)
                end
                % Save, mark the run
                vars.RunSuccessfull = 0;
                vars.Aborted = 1;
                experimentEnd(vars, scr, keys, Results, stair);
                return
            end
        end
        [~, ~, keys.KeyCode] = KbCheck;
        WaitSecs(0.001);
        
        % Time to stop?
        if (thisTrial == vars.NTrialsTotal)
            endOfExpt = 1;
        end
        
        % if this was a valid trial, advance one. Else, repeat it.
        if vars.ValidTrial(1)            % face affect rating
            thisTrial = thisTrial + 1;
        else
            disp('Invalid response. Repeating trial.');
            % Repeat the trial...
        end 

        % Reset Texture, ValidTrial, Resp
        vars.ValidTrial	= zeros(1,2);
        Resp            = NaN;
        vars.RespLR     = NaN;
        vars.ConfResp   = NaN;
        
        
        
        %% Break every ~5min (vars.PauseFreq trials & not the last trial)
        if ~rem((thisTrial-1), vars.PauseFreq) && ((thisTrial-1) ~= vars.NTrialsTotal)
            
            % Reset resp device
            if vars.RRSTdevice == 1
                resetResp(RD.respDevice);
            end
            
            if vars.probeTaskSatisfaction
                [position, ~, RT, answer] = slideScale(scr.win, ...
                    vars.Questions{1,2}, ...
                    scr.winRect, ...
                    vars.Questions{1,3}, ...
                    'scalalength', 0.6,...
                    'linelength', 20,...
                    'width', 10,...
                    'device', 'mouse', ...
                    'stepsize', 4, ...
                    'startposition', 'shuffle', ...
                    'range', 2, ...
                    'aborttime', vars.eqT,...
                    'slidercolor', [0.14 0.42 0.38],...
                    'scalacolor', [1 1 1]);
                
                % Update results
                Results.ExpRateTask(1, probeNb) = position;
                Results.ExpRateTask(2, probeNb) = RT;
                Results.ExpRateTask(3, probeNb) = answer;
                Results.ExpRateTask(4, probeNb) = probeNb;
                
                disp([vars.Questions{1}, ', rating: ', num2str(position)]);
                WaitSecs(0.2);
                
                probeNb = probeNb + 1;
            end
            
            
            disp(['You have completed ', num2str(thisTrial), ' out of ', num2str(vars.NTrialsTotal), ' trials.']);
            
            % Gray screen - Take a short break and press 'space' to
            % continue, also shows approx. minutes of break remaining
            [~, startPause] = Screen('Flip', scr.win);
            
            while (GetSecs - startPause) <= vars.pauseT
                % Update counter
                tRemaining = ceil((vars.pauseT - (GetSecs - startPause))/60);
                counterText = strcat(vars.InstructionPause, num2str(tRemaining), ' min.');
                Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
                [~, ~] = Screen('Flip', scr.win);
                
                % KbCheck for Esc key
                if keys.KeyCode(keys.Escape)==1
                    % Reset resp device
                    if vars.RRSTdevice == 1
                        resetResp(RD.respDevice)
                    end
                    % Save, mark the run
                    vars.RunSuccessfull = 0;
                    vars.Aborted = 1;
                    experimentEnd(vars, scr, keys, Results, stair);
                    return
                end
                [~, ~, keys.KeyCode] = KbCheck;
                WaitSecs(0.001);
            end
           
            % 'You can continue now'
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, vars.InstructionPauseStart, 'center', 'center', scr.TextColour);
            [~, ~] = Screen('Flip', scr.win);
            
            while keys.KeyCode(keys.Space) == 0
                [~, ~, keys.KeyCode] = KbCheck;
                WaitSecs(0.001);
            end
            
        end
        
    end%thisTrial
    
    
    
    %% Probe task satisfaction at end of session
    if vars.probeTaskSatisfaction
        [position, ~, RT, answer] = slideScale(scr.win, ...
            vars.Questions{1,2}, ...
            scr.winRect, ...
            vars.Questions{1,3}, ...
            'scalalength', 0.6,...
            'linelength', 20,...
            'width', 10,...
            'device', 'mouse', ...
            'stepsize', 4, ...
            'startposition', 'shuffle', ...
            'range', 2, ...
            'aborttime', vars.eqT,...
            'slidercolor', [0.14 0.42 0.38],...
            'scalacolor', [1 1 1]);
        
        % Update results
        Results.ExpRateTask(1, probeNb) = position;
        Results.ExpRateTask(2, probeNb) = RT;
        Results.ExpRateTask(3, probeNb) = answer;
        Results.ExpRateTask(4, probeNb) = probeNb;
        
        disp([vars.Questions{1}, ', rating: ', num2str(position)]);
        WaitSecs(0.2);
        
        probeNb = probeNb + 1;
    end
    
    
    %% Experience ratings
    if vars.collectExperienceRatings
        % Show instruction
        showInstruction(scr, keys, vars.InstructionEQ);

        % Experience sampling  Qs
        for EQcounter = 1:vars.nQuestions
            thisQ = vars.randQOrder(EQcounter);               % Random order of questions
            
            [position, RT, answer] = slideScale(scr.win, ...
                vars.Questions{thisQ,2}, ...
                scr.winRect, ...
                vars.Questions{thisQ,3}, ...
                'scalalength', 0.6,...
                'linelength', 20,...
                'width', 10,...
                'device', 'mouse', ...
                'stepsize', 4, ...
                'startposition', 'shuffle', ...
                'range', 2, ...
                'aborttime', vars.eqT,...
                'slidercolor', [0.14 0.42 0.38],...
                'scalacolor', [1 1 1]);
            
            % Update results
            Results.ExpRareEnd(1, thisQ) = position;
            Results.ExpRareEnd(2, thisQ) = RT;
            Results.ExpRareEnd(3, thisQ) = answer;
            Results.ExpRareEnd(4, thisQ) = thisQ;
            
            disp([vars.Questions{thisQ}, ', rating: ', num2str(position)]);
            WaitSecs(0.2);
            
        end%Qcounter
        
        if 0    % If we want a yes / no question on asthma
            % Do you have asthma (yes / no)
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, [vars.QuestionsAsthma], 'center', 'center', scr.TextColour);
            [~, vars.StartRT] = Screen('Flip', scr.win);
            % Fetch the participant's response, via keyboard or mouse = 0;
            vars.fixedTiming = 0;       % no time limit
            vars.InstructionQ = '';
            [vars] = getResponse(keys, scr, vars);
            
            % Update results
            asthmaQ = vars.nQuestions +1;
            Results.ExpRareEnd(1, asthmaQ) = vars.RespLR;
            Results.ExpRareEnd(2, asthmaQ) = (vars.EndRT - vars.StartRT);
            Results.ExpRareEnd(3, asthmaQ) = vars.ValidTrial(1);
            Results.ExpRareEnd(4, asthmaQ) = asthmaQ;
        end
    end
    
    
    vars.RunSuccessfull = 1;
    
    % Save, mark the run
    experimentEnd(vars, scr, keys, Results, stair);
    
    % Cleanup at end of experiment - Close window, show mouse cursor, close
    % result file, switch back to priority 0
    sca;
    ShowCursor;
    fclose('all');
    Priority(0);
    
    if vars.Procedure == 1          % Psi
        disp('Calculating threshold and slope estimates. This will take a few seconds...');
        
        % Print thresh & slope estimates
        disp(['Threshold estimate: ', num2str(stair(thisTrialStaircase).PM.threshold(vars.NumTrials))]);
        disp(['Slope estimate: ', num2str(10.^stair(thisTrialStaircase).PM.slope(vars.NumTrials))]);         % PM.slope is in log10 units of beta parameter
    end
    
    % Reset resp device
    if vars.RRSTdevice == 1
        resetResp(RD.respDevice)
    end
    
    % Plot stimuli x trial # and PMF estimate
    if simplePlot && vars.Procedure == 1    % Psi
        simplePMFplot(stair);               % NB this only takes one staircase
    elseif simplePlot && vars.Procedure == 2    % N-down
        simpleUDplot(stair);
    elseif simplePlot && vars.Procedure == 4    % PEST
        simpleUDplot(stair);
    end
    
catch   % Error. Clean up...
    % Save, mark the run
    vars.RunSuccessfull = 0;
    vars.Error = 1;
    experimentEnd(vars, scr, keys, Results, stair);
    
end
