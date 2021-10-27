function [scr, vars] = showExpandingRing(scr, vars)
%[scr, vars] = showExpandingRing(scr, vars) 
% Plays expandingRing movie
%
% Project: Respiroception
%
% Input:
%   vars        struct with key parameters (most are defined in loadParams.m)
%   scr         struct with screen / display settings
%
% Niia Nikolova
% Last edit: 27/05/2021

cueExhale = 0;          % NOT YET IMPLEMENTED 1 contract ring to cue/pace exhalation

% Movie
% movieDir needs to be full hard path
movieDir = vars.helpersPath;%'C:\Users\niian\Documents\GitHub\ECG_aarhus\Respiroception\task\helpers';
movieName = 'expandingRing60.avi';

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
rad = scr.rad+5;
Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);
Screen('Flip', scr.win);
WaitSecs(vars.breathPauseT);

% Perform initial flip to gray background and sync us to the retrace:
Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);
[~, StimOn] = Screen('Flip', scr.win);

% Open movie file:
moviepath = fullfile(movieDir, filesep, movieName);
pixelFormat=4;
[movie movieduration fps imgw imgh] = Screen('OpenMovie', scr.win, moviepath, [], [], [], pixelFormat);

% Start playback engine:
Screen('PlayMovie', movie, 1);

% While loop to show stimulus until StimT seconds elapsed...
% Inhale
stimDurFr = (vars.inhaleT + vars.breathPauseT) * scr.hz;

for thisFr = 1:stimDurFr
    % while (GetSecs - StimOn) <= vars.inhaleT  % Inhale
    
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
    Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);
    
    % Draw movie frame
    % Wait for next movie frame, retrieve texture handle to it
    tex = Screen('GetMovieImage', scr.win, movie);
    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end
                
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', scr.win, tex);

    % Update display:
     Screen('Flip', scr.win);
     
     % Release texture:
     Screen('Close', tex);

end

% % Pause
% while (GetSecs - StimOn) <= (vars.inhaleT + vars.breathPauseT)
%     % Do nothing 
% end

% Stop playback:
Screen('PlayMovie', movie, 0);
% Close movie:
Screen('CloseMovie', movie);



% Exhale
if cueExhale
    while (GetSecs - StimOn) <= (vars.inhaleT + vars.breathPauseT + vars.exhaleT) % Exhale
        
        % Show exhale movie
        
        
        DrawFormattedText(scr.win, [vars.InstructionExhale], 'center', 3*th/4, scr.TextColour);
        
        % Request stimulus onset at next video refresh:
        vbl = Screen('Flip', scr.win, vbl + ifi/2);
    end
end


end

