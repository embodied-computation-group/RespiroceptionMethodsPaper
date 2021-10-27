function [moved, currPosition] = moveResp2ITIpos(respDevice, unitscale)
%moveResp2NoLoad Moves respiroception device ~1000 steps back from no load
%position (position 5 +-5)
%   Input:
%       respDevice       serial port, e.g. "COM5" (windows)
%       unitscale        units to scale. 0 percent (0-100), 1 mm (0-17)
%
% Niia Nikolova 05/10/2020

% Add some jitter
basePos         = 50;       
jitterAmnt      = 30;      
jitterVal = randi([-jitterAmnt, jitterAmnt]);               % +/- 30%
newPosition = basePos + jitterVal;
    
% Move to jittered position
[moved, currPosition] = moveResp(respDevice, newPosition, unitscale);

end

 