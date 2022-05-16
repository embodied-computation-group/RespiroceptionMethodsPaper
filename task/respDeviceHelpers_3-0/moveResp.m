function [moved, currPosition] = moveResp(respDevice, newPosition, unitscale)
%moveResp Moves respiroception device to desired position
%   Input:
%       respDevice       serial port, e.g. "COM10" (windows)
%       newPosition      target position, e.g. "50" (0-100)
%       unitscale        units to scale. 0 percent (0-100), 1 mm (0-17)
%
% Niia Nikolova 
% Last edited 06/01/2021

% N.B. newPosition is rescaledunitscale to stepMotor values (31000 - 62500)
% Reference positions
%   ~38000  max position
%   ~12000  not touching

rescale     = 1;        % rescale motor step values

% Send command for move
moveCmd     = strcat(sprintf('a'));
writeline(respDevice, moveCmd);

try
    
    if rescale
        % Rescale new position input to motor step value
        [motorStepVal] = scale2motorstep(newPosition, unitscale);
    else
        motorStepVal = newPosition;
    end
    moveToHere     = strcat(sprintf('%03d', motorStepVal));
    
    % Move & update new current position output
    writeline(respDevice, moveToHere);
    currPosition = newPosition;
    moved = 1;

catch
    currPosition = NaN;
    moved = 0;
end

end

 