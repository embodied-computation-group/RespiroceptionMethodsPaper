function showInstruction(scr, keys, textInput)
%function showInstruction(scr, keys, textInput)
% Shows a message in open PTB window and waits for SPACE press
%   Input:
%       scr             structure with screen & window parameters
%       keys            key codes
%       textInput       text to show on the screem
%
%
% Niia Nikolova 01/010/2020


Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
DrawFormattedText(scr.win, textInput, 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);

% Wait for space
while keys.KeyCode(keys.Space) == 0
    [~, ~, keys.KeyCode] = KbCheck;
    WaitSecs(0.001);
end

% Show a blank screen for 200ms for flow
Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
[~, ~] = Screen('Flip', scr.win);
pause(0.2);

end