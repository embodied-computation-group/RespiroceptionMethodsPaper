function respiroceptionTutorial(scr, keys, vars, RD)
%respiroceptionTutorial(scr, keys, vars)
%
% Runs a tutorial for respiroception task
%
%   Input:
%       scr       screen parameters structure
%       keys      key names structure
%       vars      general vars (set by loadParams.m)
%
% Niia Nikolova 01/10/2020

%% Set variables & instructions
nTutorialTrials = 6;        % Number of tutorial trials to run (up to 6)

% Instructions
if vars.language == 1       % English
    instr.A     = 'On each trial, you will take two breaths (inhalations).  \n \n Take sharp and shallow breaths, and aim to pace them consistently with the expanding circle.  \n \n Inhale through the blue mouthpiece, and exhale through your nose. \n \n \n \n Press ''SPACE'' to continue.';
    instr.B     = 'Then you will be asked to decide which of the two breaths was more difficult, \n \n the first or the second. You will have 3 seconds to respond. \n \n \n \n First breath - press LEFT mouse button    |     Second breath - press RIGHT mouse button \n \n \n \n Let''s try it now. \n \n \n \n Press ''SPACE'' to continue.';
    instr.C     = 'That was an easy trial, but sometimes it will be harder to \n \n decide which of the two breaths was more difficult. \n \n In these cases, please take your best guess and respond. Let''s try a hard trial now.  \n \n \n \n Press ''SPACE'' to continue.';
    instr.D     = 'After each trial, you will be asked to rate how confident you are in your choice. You will have 5 seconds to respond. \n \n Let''s try a confidence rating. \n \n \n \n Press ''SPACE'' to continue.';
    instr.E     = 'Great! Now you will do a few practice trials. \n \n \n \n Press ''SPACE'' to continue.';
    instr.F     = 'You have completed the tutorial and will now go on to the main experiment. This will take about 30-40 minutes. \n \n \n \n Remember to take shallow, sharp breaths to avoid hyperventilating. \n \n \n \n You will have several opportunities to take breaks of at least two minutes. \n \n It is important that you breathe normally during the breaks, \n \n and you should stand up and move within the room.  \n \n You can shake your arms and legs, or stretch. \n \n \n \n Press ''SPACE'' to continue.';
    % instr.G     = 'You have completed the tutorial and will now go on to the main experiment. \n \n \n \n Press ''SPACE'' to continue. ';
    instr.H     = 'Get ready…';
    
    instr.feedbackC = 'Correct!';
    instr.feedbackI = 'Incorrect!';
    instr.feedbackSlow = 'You did not make a response.';
    
elseif vars.language == 2       % Danish
    instr.A     = 'I hver runde skal du tage to åndedrag (indåndinger). \n\n Tag skarpe og overfladiske åndedrag og forsøg at indånde jævnt, mens cirklen på skærmen udvider sig. \n\n Ånd ind gennem det blå mundstykke og ånd ud gennem næsen. \n \n \n \n  Tryk på “MELLEMRUMSTASTEN” for at fortsætte.';
    instr.B     = 'Efterfølgende vil du blive spurgt om, hvilken af de to indåndinger, der var mest udfordrende, \n\n den første eller den anden. Du vil have 3 sekunder til at svare \n\n\n\n Første åndedrag - tryk VENSTRE museknap  |   Andet åndedrag - tryk på HØJRE museknap \n\n\n Nu er det tid til at prøve, hvordan det virker. \n\n\n\n Tryk på “MELLEMRUMSTASTEN” for at fortsætte.';
    instr.C     = 'Det var en let runde, men sommetider vil det være sværere \n\n at afgøre hvilken af de to indåndinger der var mest udfordrende. \n\n I disse tilfælde skal du komme med dit bedste bud. Nu kan du prøve en svær runde. \n\n\n\n Tryk på “MELLEMRUMSTASTEN” for at fortsætte.';
    instr.D     = 'Efter hver runde vil du blive bedt om at vurdere, hvor sikker du var på dit valg. Du vil have 5 sekunder til at svare. \n\n Lad os prøve en runde, hvor du vurderer dit valg. \n\n\n\n Tryk på “MELLEMRUMSTASTEN” for at fortsætte.';
    instr.E     = 'Godt klaret! Nu skal du prøve nogle få træningsrunder. \n\n\n\n Tryk på “MELLEMRUMSTASTEN” for at fortsætte.';
    instr.F     = 'Du har gennemført introduktionsdelen og kan nu fortsætte til selve eksperimentet. Dette vil tage ca. 30-40 minutter. \n\n\n\n Husk, at du skal tage skarpe og overfladiske indåndinger, så du undgår at hyperventilere. \n\n\n\n Du vil få flere muligheder for at holde pauser på mindst to minutter undervejs. \n\n Det er vigtigt, at du trækker vejret normalt i pauserne. \n\n og du bør rejse dig og gå lidt rundt i rummet (hvis du fysisk er i stand til det). \n\n Du må også gerne bevæge/ryste arme og ben eller strække dig. \n\n\n\n Tryk på “MELLEMRUMSTASTEN” for at fortsætte.';
    % instr.G     = 'You have completed the tutorial and will now go on to the main experiment. \n \n \n \n Press ''SPACE'' to continue. ';
    instr.H     = 'Gør dig klar…';
    
    instr.feedbackC = 'Korrekt!';
    instr.feedbackI = 'Ukorrekt!';
    instr.feedbackSlow = 'Du svarede ikke.';
end

unitscale = vars.RDunitscale;

if vars.RDunitscale == 0
    easyStim        = 97;
    hardStim        = 65;
    exampleStimuli  = [98, 61, 82];
    stimInAlt       = [1, 2, 2];
elseif vars.RDunitscale == 1
    easyStim        = 16;
    hardStim        = 12;
    exampleStimuli  = [15, 11, 15, 10, 12, 14];
    stimInAlt       = [1, 2, 2, 1, 1, 2];
end

try
    
    pause(0.200);
    [~, ~, keys.KeyCode] = KbCheck;
    
    vars.stimIsHere = 2;        % plux synch colour, unused for tutorial!
    
    %% General task instructions
    showInstruction(scr, keys, instr.A);
    
    
    %% 1. Easy trial
    showInstruction(scr, keys, instr.B);
    
    % Get ready...
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, instr.H, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    pause(2);
    
    %% Run through the two alternatives
    for thisAlt = 1:2
        
        if thisAlt == 1
            % Move to easy load
            if vars.RRSTdevice == 1
                moveResp(RD.respDevice, easyStim, unitscale);
            end
        elseif thisAlt == 2
            % Move to no load
            if vars.RRSTdevice == 1
                moveResp2NoLoad(RD.respDevice, unitscale);
            end
        end
        
        % Clear display while we adjust the load & show counter
        tRemaining = vars.ISI;          % Update counter
        counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
        [~, ISIstart] = Screen('Flip', scr.win);
        
        % Wait for ISI time
        while (GetSecs - ISIstart) <= vars.ISI
            % Update counter
            tRemaining = round(vars.ISI - (GetSecs - ISIstart));
            counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
            [~, ~] = Screen('Flip', scr.win);
            
            % KbCheck for Esc key
            if keys.KeyCode(keys.Escape)==1
                return
            end
            [~, ~, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
        end
        
        % Show circles, 'Inhale...'
        if thisAlt == 1
            vars.InstructionInhale = vars.InstructionInhale1;
            vars.switchColour = 0;
        elseif thisAlt == 2
            vars.InstructionInhale = vars.InstructionInhale2;
            vars.switchColour = 1;
        end
        
        %[scr, vars] = drawExpandingRing(scr, vars);
        %[scr, vars] = showExpandingRing(scr, vars);
        [scr, vars] = showExpandingRingGenerated(scr, vars);
        
    end
    
    % Show response prompt screen
    pause(0.4);
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
    
    [~, vars.StartRT] = Screen('Flip', scr.win);
    
    % Fetch the participant's response, via keyboard or mouse
    [vars] = getResponse(keys, scr, vars);
    
    % Move to No Load
    if vars.RRSTdevice == 1
        [~, ~] = moveResp2NoLoad(RD.respDevice, unitscale);
    end
    
    % Give feedback
    if vars.RespLR == 0                         % Resp stim 1
        Resp = 1;                               % Correct
        feedbackText = instr.feedbackC;
    elseif vars.RespLR == 1                     % Resp stim 2
        Resp = 0;                               % Incorrect
        feedbackText = instr.feedbackI;
    else
        Resp = NaN;
        feedbackText = instr.feedbackSlow;
    end
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, feedbackText, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    pause(1.5);
    
    
    
    
    %% 2. Hard trial
    showInstruction(scr, keys, instr.C);
    
    % Get ready...
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, instr.H, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    pause(2);
    
    %% Run through the two alternatives
    for thisAlt = 1:2
        
        if thisAlt == 1
            % Move to no load
            if vars.RRSTdevice == 1
                moveResp2NoLoad(RD.respDevice, unitscale);
            end
        elseif thisAlt == 2
            % Move to hard load
            if vars.RRSTdevice == 1
                moveResp(RD.respDevice, hardStim, unitscale);
            end
        end
        
        % Clear display while we adjust the load & show counter
        tRemaining = vars.ISI;          % Update counter
        counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
        [~, ISIstart] = Screen('Flip', scr.win);
        
        % Wait for ISI time
        while (GetSecs - ISIstart) <= vars.ISI
            % Update counter
            tRemaining = round(vars.ISI - (GetSecs - ISIstart));
            counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
            [~, ~] = Screen('Flip', scr.win);
            
            % KbCheck for Esc key
            if keys.KeyCode(keys.Escape)==1
                return
            end
            [~, ~, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
        end
        
        % Show circles, 'Inhale...'
        if thisAlt == 1
            vars.InstructionInhale = vars.InstructionInhale1;
            vars.switchColour = 0;
        elseif thisAlt == 2
            vars.InstructionInhale = vars.InstructionInhale2;
            vars.switchColour = 1;
        end
        
        %[scr, vars] = drawExpandingRing(scr, vars);
        %[scr, vars] = showExpandingRing(scr, vars);
        [scr, vars] = showExpandingRingGenerated(scr, vars);
        
    end
    
    % Show response prompt screen
    pause(0.4);
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
    
    [~, vars.StartRT] = Screen('Flip', scr.win);
    
    % Fetch the participant's response, via keyboard or mouse
    [vars] = getResponse(keys, scr, vars);
    
    % Move to No Load
    if vars.RRSTdevice == 1
        [~, ~] = moveResp2NoLoad(RD.respDevice, unitscale);
        pause(0.5);
    end
    
    % Give feedback
    if vars.RespLR == 0                         % Resp stim 1
        Resp = 0;                               % Incorrect
        feedbackText = instr.feedbackI;
    elseif vars.RespLR == 1                     % Resp stim 2
        Resp = 1;                               % Correct
        feedbackText = instr.feedbackC;
    else
        Resp = NaN;
        feedbackText = instr.feedbackSlow;
    end
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, feedbackText, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    pause(1.5);
    
    
    %% 3. Confidence rating
    showInstruction(scr, keys, instr.D);
    
    % Get ready...
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, instr.H, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    pause(2);
    
    %% Run through the two alternatives
    for thisAlt = 1:2
        
        if thisAlt == 1
            % Move to easy load
            if vars.RRSTdevice == 1
                moveResp(RD.respDevice, easyStim, unitscale);
            end
        elseif thisAlt == 2
            % Move to no load
            if vars.RRSTdevice == 1
                moveResp2NoLoad(RD.respDevice, unitscale);
            end
        end
        
        % Clear display while we adjust the load & show counter
        tRemaining = vars.ISI;          % Update counter
        counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
        [~, ISIstart] = Screen('Flip', scr.win);
        
        % Wait for ISI time
        while (GetSecs - ISIstart) <= vars.ISI
            % Update counter
            tRemaining = round(vars.ISI - (GetSecs - ISIstart));
            counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
            [~, ~] = Screen('Flip', scr.win);
            
            % KbCheck for Esc key
            if keys.KeyCode(keys.Escape)==1
                return
            end
            [~, ~, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
        end
        
        % Show circles, 'Inhale...'
        if thisAlt == 1
            vars.InstructionInhale = vars.InstructionInhale1;
            vars.switchColour = 0;
        elseif thisAlt == 2
            vars.InstructionInhale = vars.InstructionInhale2;
            vars.switchColour = 1;
        end
        
        %[scr, vars] = drawExpandingRing(scr, vars);
        %[scr, vars] = showExpandingRing(scr, vars);
        [scr, vars] = showExpandingRingGenerated(scr, vars);
    end
    
    % Show response prompt screen
    pause(0.4);
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
    
    [~, vars.StartRT] = Screen('Flip', scr.win);
    
    % Fetch the participant's response, via keyboard or mouse
    [~] = getResponse(keys, scr, vars);
    
    % Move to No Load
    if vars.RRSTdevice == 1
        [~, ~] = moveResp2NoLoad(RD.respDevice, unitscale);
        pause(0.5);
    end
    
    
    % Fetch the participant's confidence rating
    [~] = getConfidence(keys, scr, vars);
    pause(0.2);
    
    
    %% 4. Example of 2-3 trials
    showInstruction(scr, keys, instr.E);
    
    for thisExampleTrial = 1:nTutorialTrials
        
        % Get ready...
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, instr.H, 'center', 'center', scr.TextColour);
        [~, ~] = Screen('Flip', scr.win);
        pause(2);
        
        %% Run through the two alternatives
        for thisAlt = 1:2
            
            if stimInAlt(thisExampleTrial) == thisAlt
                % Move to desired load
                if vars.RRSTdevice == 1
                    moveResp(RD.respDevice, exampleStimuli(thisExampleTrial), unitscale);
                end
            else
                % Move to no load
                if vars.RRSTdevice == 1
                    moveResp2NoLoad(RD.respDevice, unitscale);
                end
            end
            
            % Clear display while we adjust the load & show counter
            tRemaining = vars.ISI;          % Update counter
            counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
            [~, ISIstart] = Screen('Flip', scr.win);
            
            % Wait for ISI time
            while (GetSecs - ISIstart) <= vars.ISI
                % Update counter
                tRemaining = round(vars.ISI - (GetSecs - ISIstart));
                counterText = strcat(vars.InstructionPrepare, num2str(tRemaining), ' sec.');
                Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
                [~, ~] = Screen('Flip', scr.win);
                
                % KbCheck for Esc key
                if keys.KeyCode(keys.Escape)==1
                    return
                end
                [~, ~, keys.KeyCode] = KbCheck;
                WaitSecs(0.001);
            end
            
            % Show circles, 'Inhale...'
            if thisAlt == 1
                vars.InstructionInhale = vars.InstructionInhale1;
                vars.switchColour = 0;
            elseif thisAlt == 2
                vars.InstructionInhale = vars.InstructionInhale2;
                vars.switchColour = 1;
            end
            
            %[scr, vars] = drawExpandingRing(scr, vars);
            %[scr, vars] = showExpandingRing(scr, vars);
            [scr, vars] = showExpandingRingGenerated(scr, vars);
        end
        
        % Show response prompt screen
        pause(0.4);
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
        
        [~, vars.StartRT] = Screen('Flip', scr.win);
        
        % Fetch the participant's response, via keyboard or mouse
        [~] = getResponse(keys, scr, vars);
        
        % Move to No Load
        if vars.RRSTdevice == 1
            [~, ~] = moveResp2NoLoad(RD.respDevice, unitscale);
            pause(0.5);
        end
        
        
        % Fetch the participant's confidence rating
        [~] = getConfidence(keys, scr, vars);
        pause(0.2);
        
        % ITI
        if vars.RRSTdevice == 1
            [~, ~] = moveResp2ITIpos(RD.respDevice, unitscale);
        end
        
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        [~, StartITI] = Screen('Flip', scr.win);
        
        % Present the gray screen for ITI duration
        while (GetSecs - StartITI) <= vars.ITI(thisExampleTrial)
            
            if keys.KeyCode(keys.Escape)==1
                return
            end
        end
        
        [~, ~, keys.KeyCode] = KbCheck;
        WaitSecs(0.001);
        
    end % Example trials
    
    
    %% Conclusions
    % Reset resp device & pause
    if vars.RRSTdevice == 1
        resetResp(RD.respDevice)
    end
    
    [~, startPause] = Screen('Flip', scr.win);
    
    while (GetSecs - startPause) <= vars.pauseT
        % Update counter
        tRemaining = ceil((vars.pauseT - (GetSecs - startPause))/60);
        counterText = strcat(vars.InstructionPause, num2str(tRemaining), ' minute.');
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, counterText, 'center', 'center', scr.TextColour);
        [~, ~] = Screen('Flip', scr.win);
    end
    
    showInstruction(scr, keys, instr.F);
    
catch ME
    rethrow(ME)
    
    
end

end