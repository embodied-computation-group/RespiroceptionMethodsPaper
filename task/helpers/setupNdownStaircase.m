function [stair] = setupNdownStaircase(vars)
%function [stair] = setupNdownStaircase(vars)
% 
% Set up  an N-down staircase. Possible to have several interleaved
% staircases by passing a nested structure, e.g. staircase.StartHigh
% Input: vars structure with fields, 
%       NumTrials           % max # trials in the staircase 
%       NumDown             % N 'correct' items in a row to go down, after 1st reversal
%       StepSize            % Step size 
%       ThreshStart         % Starting point of staircase 
%       HappyCounter/Correct counter           % Response 'happy'/correct counter
%       ReversalCounter     % Reversal counter
%       ReversalStop        % # of reversals to stop after
%       xCurrent            % Current stim value
%       x                   % Vector of stims presented by trial
%       stop                % starts as 0, switch to 1 when it's time to stop 
% 
% Niia Nikolova, 29/05/2020

stair.HappyCounter = 1;                                      % Response 'happy'/correct counter
stair.ReversalCounter = 0;                                   % Reversal counter
stair.xCurrent = vars.ThreshStart;                          % Current stim value
stair.x = [];                                                % Vector of stims presented by trial
stair.ReversalFlags = [];
stair.stop = 0;

% Assign general staircase variables
stair.StepSize = vars.StepSize;
stair.NumTrials = vars.NumTrials;
stair.NumDown = vars.NumDown;
stair.StepSize = vars.StepSize;
stair.ReversalStop = vars.ReversalStop;

if vars.ThreshStart > 100           % High start
    stair.Previous = -1;
elseif vars.ThreshStart <100        % Low start
    stair.Previous = 1;
end