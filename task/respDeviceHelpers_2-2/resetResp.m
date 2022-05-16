function resetResp(respDevice)
%resetResp REcalibrates respiratory device by sending negative step value
%   Input:
%       respDevice       serial port, e.g. "COM10" (windows)
%
% Note this takes approx. 10 seconds!
%
% Niia Nikolova 
% Last edited 05/12/2020


try

    newPosition = -200;
    
    motorStepVal = newPosition;
    moveToHere     = strcat(sprintf('%03d', motorStepVal));
    
    % Move & update new current position output
    writeline(respDevice, moveToHere)

catch
    disp('ERROR. Could not reset resp device.');
end

end

 