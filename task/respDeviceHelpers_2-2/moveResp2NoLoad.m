function [moved, currPosition] = moveResp2NoLoad(respDevice, unitscale)
%moveResp2NoLoad Moves respiroception device to no load position (not
%touching tube), ~ position 20
%   Input:
%       respDevice       serial port, e.g. "COM5" (windows)
%       unitscale        units to scale. 0 percent (0-100), 1 mm (0-17)
% Niia Nikolova 01/10/2020


% Move to No Load position
newPosition = 0;
[moved, currPosition] = moveResp(respDevice, newPosition, unitscale);

end

 