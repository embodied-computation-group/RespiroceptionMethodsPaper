function [scr] = displayConfig(scr)
%function [scr] = displayConfig(scr)
%
% Called by main.m
% Input: 
%   scr         struct with screen / display settings
% 
% Niia Nikolova
% Last edit: 11/06/2020


%% Set-up screen
if length(Screen('Screens')) > 1
    scr.ExternalMonitor = 1;% set to 1 for secondary monitor
    % N.B. It's not optimal to use external monitor for newer Win systems
    % (Windows 7+) due to timing issues
else
    scr.ExternalMonitor = 0;
end

if scr.ExternalMonitor
    scr.screenID = max(Screen('Screens'));
    [width, height]=Screen('DisplaySize', scr.screenID);    % returns screen dim in mm
    width = width/10;                                       % in cm
    height = height/10;
    
    if ~isfield(scr,'MonitorHeight') || isempty(scr.MonitorHeight)
        scr.MonitorHeight = height; end     % in cm 
    if ~isfield(scr,'MonitorWidth') || isempty(scr.MonitorWidth)
        scr.MonitorWidth = width; end
    if ~isfield(scr,'ViewDist') || isempty(scr.ViewDist)
        scr.ViewDist = 75; end
else % Laptop
    scr.screenID = min(Screen('Screens')); 
    [width, height]=Screen('DisplaySize', scr.screenID);    
    width = width/10;
    height = height/10;
    
    if ~isfield(scr,'MonitorHeight') || isempty(scr.MonitorHeight)
        scr.MonitorHeight = height; end
    if ~isfield(scr,'MonitorWidth') || isempty(scr.MonitorWidth)
        scr.MonitorWidth = width; end
    if ~isfield(scr,'ViewDist') || isempty(scr.ViewDist)
        scr.ViewDist = 40; end
end


scr.dist    = scr.ViewDist;
scr.width   = scr.MonitorWidth;
scr.resolution = Screen('Resolution', scr.screenID);

%% Colours and text params
Gray = GrayIndex(scr.screenID);
% White = WhiteIndex(scr.screenID);
% Black = BlackIndex(scr.screenID);
scr.BackgroundGray = Gray;
% scr.TextColour = Black;


end