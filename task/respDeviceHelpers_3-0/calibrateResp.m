function calibrateResp(respDevice)
%calibrateResp Calibrates the device. Wedge moves slowly (backwards then forwrads)
% until it reaches the switch.

%   Input:
%       respDevice       serial port, e.g. "COM5" (windows)
% Niia Nikolova 05/2022


calibrateCmd     = sprintf('c');
writeline(respDevice, calibrateCmd);

end
