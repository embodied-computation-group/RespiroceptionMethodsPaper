function [vars] = getResponse(keys, scr, vars)
%function [vars] = getResponse(keys, scr, vars)
%
% Get the participants response - either keyboard or mouse
%
% Project: Respiroception task
%
% Input:
%   keys (struct)
%   scr (struct)
%   vars (struct)
%
%
% Output:
%   vars (struct)
%
%
% Niia Nikolova
% Last edit: 25/09/2020

feedbackString  = 'O';
outputString    = '';
postResponseInt = 0.3;      %  pause for 300ms after response

% Duration of plux flash for response (4 frames)
pluxDurationSec =  scr.pluxDur(2) / scr.hz;


% loop until valid key is pressed or RespT is reached
while ((GetSecs - vars.StartRT) <= vars.RespT)
    
    switch vars.InputDevice
        
        case 1 % Keyboard response
            
            % KbCheck for response
            if keys.KeyCode(keys.Left)==1         % Stim 1
                % update results
                vars.RespLR = 0;
                vars.ValidTrial(1) = 1;
                
            elseif keys.KeyCode(keys.Right)==1    % Stim 2
                % update results
                vars.RespLR = 1;
                vars.ValidTrial(1) = 1;
                
            elseif keys.KeyCode(keys.Escape)==1
                vars.abortFlag = 1;
                
            else
                % ? DrawText: Please press a valid key...
            end
            
            [~, vars.EndRT, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
            
        case 2 % Mouse
            
            [~,~,buttons] = GetMouse;
            while (~any(buttons)) && ((GetSecs - vars.StartRT) <= vars.RespT) % wait for press & response time
                [~,~,buttons] = GetMouse; % L [1 0 0], R [0 0 1]
            end
            
            if buttons == [1 0 0]       % Left - Stim 1
                % update results
                vars.RespLR = 0;
                vars.ValidTrial(1) = 1;
                
            elseif buttons == [0 0 1]   % Right - Stim 2
                % update results
                vars.RespLR = 1;
                vars.ValidTrial(1) = 1;
                
            else
                
            end
            vars.EndRT = GetSecs;
    end
    
    %     %% Brief feedback
    %     if vars.Resp == 1% happy
    %         emotString = 'Happy';
    %         feedbackXPos = ((scr.winRect(3)/2)+150);
    %     elseif vars.Resp == 0
    %         emotString = 'Angry';
    %         feedbackXPos = ((scr.winRect(3)/2)-250);
    %     else
    %         emotString = '';
    %         feedbackXPos = ((scr.winRect(3)/2));
    %     end
    
    %% Once a response is made, (show feedback), pause for a few ms
    % fixed timing - wait for response interval to pass
    [~, stimOn] = Screen('Flip', scr.win);
    if vars.fixedTiming
        if ~isnan(vars.RespLR) && (vars.ValidTrial(1))    % valid trial
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
            
            %             % Feedback
            %             DrawFormattedText(scr.win, feedbackString, feedbackXPos, ((scr.winRect(4)/2)+150), scr.AccentColour);
            
            [~, ~] = Screen('Flip', scr.win);
            
            %             outputString = ['Response recorded: ', emotString];
        else
            outputString = 'No response recorded';
        end
        
    else    % Variable timing
        if ~isnan(vars.RespLR) && (vars.ValidTrial(1))
            
            while (GetSecs - stimOn) <= postResponseInt
                Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
                DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 3*scr.height/4, scr.TextColour);
                
                %             %Feedback
                %             DrawFormattedText(scr.win, feedbackString, feedbackXPos, ((scr.winRect(4)/2)+150), scr.AccentColour);
                
                % If using Plux for physiological measures, display a square in the
                % bottom right screen corner
                if vars.pluxSynch
                    % if were in the first pluxDurationSec seconds, draw the rectangle
                    if vars.RespLR == 0     &&((GetSecs - stimOn) <= pluxDurationSec) % stim interval
                        Screen('FillRect', scr.win, scr.pluxWhite, scr.pluxRect);
                    elseif vars.RespLR == 1 &&((GetSecs - stimOn) <= pluxDurationSec) % stim interval
                        Screen('FillRect', scr.win, scr.pluxBlack, scr.pluxRect);
                    end
                end
                Screen('Flip', scr.win);
                
            end
            %WaitSecs(0.3);
            
        else
            outputString = 'No response recorded';
        end
        
        WaitSecs(0.2);
        break;
    end
    
    
end

disp(outputString);

end
