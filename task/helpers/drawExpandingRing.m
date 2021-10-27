function [scr, vars] = drawExpandingRing(scr, vars)
%[scr, vars] = drawExpandingRing(scr, vars) Draw expanding rings
%   Expanding / contracting rings to cue inhale/exhale for respiroception
%   task
% Based on PTB, PsychDemos/ExpandingRingsShader
%
% Project: Respiroception
%
% Input:
%   vars        struct with key parameters (most are defined in loadParams.m)
%   scr         struct with screen / display settings
%
% Niia Nikolova
% Last edit: 29/30/2021

cueExhale = 0;          % 1 contract ring to cue/pace exhalation
ringtype = 1;
global GL;

%% Create movie file
% movName = ['expandingRing_',num2str(vars.switchColour),'.mp4'];
% moviePtr = Screen('CreateMovie', scr.win, movName);
%% Setup size of expandingRing movie rect
movieRectSize        = [0; 0; 5; 5];
multFactorW         = scr.resolution.width ./ scr.MonitorWidth;
multFactorH         = scr.resolution.height ./ scr.MonitorHeight;
scr.movieRect(3)     = movieRectSize(3) .* multFactorW;
scr.movieRect(4)     = movieRectSize(4) .* multFactorH;
movrect = CenterRectOnPoint(scr.movieRect, scr.resolution.width/2, scr.resolution.height/2);


% Duration of plux flash for stimulus (2 frames)
pluxDurationSec =  scr.pluxDur(1) / scr.hz;

% Set screenID, win, windowSize
tw = scr.winRect(3);
th = scr.winRect(4);

% Load the 'ExpandingRingsShader' fragment program from file, compile it,
% return a handle to it:
rshader = [PsychtoolboxRoot 'PsychDemos/ExpandingRingsShader.vert.txt'];

if ringtype == 0
    expandingRingShader = LoadGLSLProgramFromFiles({ rshader, [PsychtoolboxRoot 'PsychDemos/ExpandingRingsShader.frag.txt'] }, 0);
    % Width of a single ring (radius) in pixels:
    ringwidth = 20;
else
    expandingRingShader = LoadGLSLProgramFromFiles({ rshader, [PsychtoolboxRoot 'PsychDemos/ExpandingSinesShader.frag.txt'] }, 0); % ,1  debug flag was 1
    % Width of a single ring (radius) / Period of a single color sine wave in pixels:
    ringwidth = 400;
end

% Create a purely virtual texture 'ringtex' of size tw x th virtual pixels
ringtex = Screen('SetOpenGLTexture', scr.win, [], 0, GL.TEXTURE_RECTANGLE_EXT, tw, th, 1, expandingRingShader);

% Bind the shader: After binding it, we can setup some constant parameters
% for our stimulus, so called GLSL 'uniform' variables. These are
% parameters that are constant during the whole session, or at least only
% change infrequently. They are set outside the fast stimulus rendering
% loop and potentially optimized by the graphics driver for fast execution:
glUseProgram(expandingRingShader);

% Set the 'RingCenter' parameter to the center position of the ring
% stimulus [tw/2, th/2]:
glUniform2f(glGetUniformLocation(expandingRingShader, 'RingCenter'), tw/2, th/2);

% Done with setup, disable shader. All other stimulus parameters will be
% set at each Screen('DrawTexture') invocation to allow fast dynamic change
% of the parameters during each stimulus redraw:
glUseProgram(0);

% Define first and second ring color as RGBA vector with normalized color
% component range between 0.0 and 1.0 (switch colours on breath 2)
if vars.switchColour 
    
    % Shaded rings, grey & teal
     firstColor = [0.14, 0.82, 0.67, 1];    % dark teal
     secondColor = [.2, .2, .2, 1];         % grey
    
    
else

    % Shaded rings, greay & teal
     firstColor = [0.14, 0.82, 0.67, 1];    % dark teal
     secondColor = [.2, .2, .2, 1];         % grey
end

% Initial shift- and radius value is zero: We start with a point in the
% center of the screen which will then expand and scroll by one pixel at
% each redraw:
shiftvalue = 0;
count = 0;

% Retrieve monitor refresh duration:
ifi = Screen('GetFlipInterval', scr.win);


%% Draw a rectangle where we wan to cut the movie (x y width height)
% movieRectSize        = [0; 0; 5; 5];
% multFactorW         = scr.resolution.width ./ scr.MonitorWidth;
% multFactorH         = scr.resolution.height ./ scr.MonitorHeight;
% scr.movieRect(3)     = movieRectSize(3) .* multFactorW;
% scr.movieRect(4)     = movieRectSize(4) .* multFactorH;
% movrect = CenterRectOnPoint(scr.movieRect, scr.resolution.width/2, scr.resolution.height/2);
% Screen('FrameRect', scr.win, [1 1 1], movrect,2);



% Show a pale circle and pause briefly
% We use 'firstColor' for the even rings, 'secondColor' for the odd
% rings.
rad = scr.rad+5;
Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3); 
Screen('Flip', scr.win);
WaitSecs(vars.breathPauseT);

% Perform initial flip to gray background and sync us to the retrace:
Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3);  
[vbl, StimOn] = Screen('Flip', scr.win);

% While loop to show stimulus until StimT seconds elapsed...
% Inhale
stimDurFr = vars.inhaleT * scr.hz;
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
    
    % Increase shift and radius of stimulus:
    shiftvalue = shiftvalue + 5;
    radius = shiftvalue;
    count = count + 1;
  
    % We use 'firstColor' for the even rings, 'secondColor' for the odd
    % rings.
    Screen('DrawTexture', scr.win, ringtex, [], [], [], [], [], firstColor, [], [], [secondColor(1), secondColor(2), secondColor(3), secondColor(4), shiftvalue, ringwidth, radius, 0]);
    DrawFormattedText(scr.win, [vars.InstructionInhale], 'center', 3*th/4, scr.TextColour);
    Screen('FrameOval', scr.win, firstColor, [scr.x_middle-rad scr.y_middle-rad scr.x_middle+rad scr.y_middle+rad], 3, 3); 

    % Request stimulus onset at next video refresh:
    vbl = Screen('Flip', scr.win, vbl + ifi/2);
    
    %% Add frame to movie
    %Screen('AddFrameToMovie', scr.win);% [,rect] [,bufferName] [,moviePtr=0] [,frameduration=1])
    
    %% Save an image of the frame
    imageArray=Screen('GetImage', scr.win, movrect);% [,bufferName] [,floatprecision=0] [,nrchannels=3])
    imString    = sprintf('%02d', count);
    imname  = ['im_',imString,'.png'];
    imwrite(imageArray, imname);
    
end


% Pause
while (GetSecs - StimOn) <= (vars.inhaleT + vars.breathPauseT)
    % Do nothing
    
end

%% Close movie
%Screen('FinalizeMovie', moviePtr);


% Exhale
if cueExhale
    while (GetSecs - StimOn) <= (vars.inhaleT + vars.breathPauseT + vars.exhaleT) % Exhale
        % Increase shift and radius of stimulus:
        shiftvalue = shiftvalue - 3;
        radius = shiftvalue;
        count = count + 1;
        
        % We use 'firstColor' for the even rings, 'secondColor' for the odd
        % rings.
        Screen('DrawTexture', scr.win, ringtex, [], [], [], [], [], firstColor, [], [], [secondColor(1), secondColor(2), secondColor(3), secondColor(4), shiftvalue, ringwidth, radius, 0]);
        DrawFormattedText(scr.win, [vars.InstructionExhale], 'center', 3*th/4, scr.TextColour);
        
        % Request stimulus onset at next video refresh:
        vbl = Screen('Flip', scr.win, vbl + ifi/2);
    end
end

% disp(['Max ring radius: ', num2str(radius)]);

end

