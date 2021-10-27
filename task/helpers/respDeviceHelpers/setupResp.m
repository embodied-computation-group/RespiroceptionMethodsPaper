function [init, respDevice] = setupResp(sPort, sBaudRate)
%setupResp Initializes device for respiroception (filter/load
%detection) task using serial port
%
%   Input: 
%       sPort       serial port, e.g. "COM5" (windows)
%       sBaudRate   device baud rate (9600)
%   Output:
%       init        initilaization successfull flag (1 yes, 0 no)
%       respDevice  device object handle
%   Example usage:
%       sPort = "COM5";
%       sBaudRate = 9600;
%       [init, respDevice] = setupResp(sPort, sBaudRate)

%
% To see a list of serial port devices, input serialportlist. Port name
% will differ by OS. 
% See, https://uk.mathworks.com/help/matlab/matlab_external/create-serial-port-object.html
%
% Niia Nikolova 26/08/2020

% Create serial port object
global respDevice

try   
    
    respDevice = serialport(sPort,sBaudRate);
    init = 1;

catch
    respDevice = NaN;
    init = 0;
    
end

if init
    disp('Serial port initialization successfull.');
else
    disp('Serial port initialization failed.');
    return
end



end

