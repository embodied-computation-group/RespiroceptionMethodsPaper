function [stair] = updateStaircase(stair, Resp)
% function [stair] = updateStaircase(stair, Resp)
%
% Update N-down staircase with most recent response Resp
%
%
% Niia Nikolova, 29/05/2020

IsReversal = 0;

switch Resp
    
    %% Up step (angry)
    case 0
        
        stair.xCurrent = stair.xCurrent + stair.StepSize;         % Up one StepSize
        
        % Reversal if previous step was down
        if stair.Previous == -1
            IsReversal = 1;
            stair.ReversalCounter = stair.ReversalCounter + 1;
        end
        
        stair.Previous = 1;

    %% Down step (happy)
    case 1
        
        stair.xCurrent = stair.xCurrent - stair.StepSize;         % Down one StepSize
        
        % Reversal if previous step was up
        if stair.Previous == 1
            IsReversal = 1;
            stair.ReversalCounter = stair.ReversalCounter + 1;
        end
        
        stair.Previous = -1;
        
% Different rules before & after 1st reversal, eg. 2-down 1-up
%             if (stair.ReversalCounter == 0 && stair.HappyCounter == 1)    % Before 1st reversal
%                 stair.xCurrent = stair.xCurrent - stair.StepSize;         % Down one StepSize
%
%             elseif (stair.ReversalCounter > 0 && stair.HappyCounter < stair.NumDown)
%                 stair.HappyCounter = stair.HappyCounter + 1;
%
%             elseif (stair.ReversalCounter > 0 && stair.HappyCounter == stair.NumDown)
%                 stair.xCurrent = stair.xCurrent - stair.StepSize;         % Down one StepSize
%                 stair.HappyCounter = 1;
%             end
        
end

stair.ReversalFlags = [stair.ReversalFlags, IsReversal];

%% Check if desired # of reversals has been reached, and if so set stop flag to 1
if (stair.ReversalCounter == stair.ReversalStop)
    stair.stop = 1;
end
