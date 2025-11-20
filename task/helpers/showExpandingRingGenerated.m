function [scr, vars] = showExpandingRingGenerated(scr, vars)
%[scr, vars] = showExpandingRingGenerated(scr, vars) 
% Generates expanding ring stimulus (replaces movie version)
%
% Project: Respiroception
%
% Input:
%   vars        struct with key parameters (most are defined in loadParams.m)
%   scr         struct with screen / display settings
%
% Created based on showExpandingRing.m

cueExhale = 0;          % NOT YET IMPLEMENTED 1 contract ring to cue/pace exhalation

% Duration of plux flash for stimulus (2 frames)
pluxDurationSec =  scr.pluxDur(1) / scr.hz;

% Set screenID, win, windowSize
tw = scr.winRect(3);
th = scr.winRect(4);

% Retrieve monitor refresh duration:
ifi = Screen('GetFlipInterval', scr.win);
firstColor = [0.14, 0.82, 0.67, 1];    % dark teal

% Show a pale circle and pause briefly
% We use 'firstColor' for the even rings, 'secondColor' for the odd
% rings.
rad = scr.rad;
Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);
Screen('Flip', scr.win);
WaitSecs(vars.breathPauseT);

% Perform initial flip to gray background and sync us to the retrace:
Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);
[~, StimOn] = Screen('Flip', scr.win);

% Calculate frames
nInhaleFr = round(vars.inhaleT * scr.hz);
nPauseFr = round(vars.breathPauseT * scr.hz);
totalFr = nInhaleFr + nPauseFr;

for thisFr = 1:totalFr
    
    % Calculate current radius
    if thisFr <= nInhaleFr
        % Linear expansion
        currentRad = (thisFr / nInhaleFr) * scr.rad;
    else
        % Hold at max radius
        currentRad = scr.rad;
    end
    
    % Draw expanding circle (FillOval)
    % Rect for current circle
    currentRect = [0 0 currentRad*2 currentRad*2];
    currentRect = CenterRectOnPoint(currentRect, scr.x_middle, scr.y_middle);
    Screen('FillOval', scr.win, firstColor, currentRect);

    % If using Plux for physiological measures, display a square in the
    % bottom right screen corner
    if vars.pluxSynch
        % if were in the first pluxDurationSec seconds, draw the rectangle
        if vars.stimIsHere == 1     &&((GetSecs - StimOn) <= pluxDurationSec) % stim interval
            Screen('FillRect', scr.win, scr.pluxWhite, scr.pluxRect);
        elseif vars.stimIsHere == 0 &&((GetSecs - StimOn) <= pluxDurationSec) % stim interval
            Screen('FillRect', scr.win, scr.pluxBlack, scr.pluxRect);
            
        end
    end
    
    DrawFormattedText(scr.win, [vars.InstructionInhale], 'center', 3*th/4, scr.TextColour);
    
    % Draw outer static ring
    Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);

    % Update display:
     Screen('Flip', scr.win);

end

% Exhale
if cueExhale
    % Calculate frames for exhale
    nExhaleFr = round(vars.exhaleT * scr.hz);
    
    % Start time for exhale phase (approximate based on loop end)
    % Ideally we use GetSecs - StimOn to be precise, but frame counting is consistent with above
    
    for thisFr = 1:nExhaleFr
        % Linear contraction
        currentRad = scr.rad - ((thisFr / nExhaleFr) * scr.rad);
        
        % Draw contracting circle
        currentRect = [0 0 currentRad*2 currentRad*2];
        currentRect = CenterRectOnPoint(currentRect, scr.x_middle, scr.y_middle);
        Screen('FillOval', scr.win, firstColor, currentRect);
        
        DrawFormattedText(scr.win, [vars.InstructionExhale], 'center', 3*th/4, scr.TextColour);
        
        % Draw outer static ring
        Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);
        
        % Request stimulus onset at next video refresh:
        Screen('Flip', scr.win);
    end
end

end
