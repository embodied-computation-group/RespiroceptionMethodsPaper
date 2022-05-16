function testRespDevice(nMinutes)
%testRespDevice Moves respiroception device back and forth to random
%position for a set number of minutes. To use for testing the device.
%   Input:
%       nMinutes        number of minutes to move for
%
%
% Niia Nikolova 16/11/2020

% N.B. newPosition is rescaled to stepMotor values 
% Reference positions   12000 - 38000

% Initialize resp device
unitscale = 1;          % units 0-100
sPort = "COM5";
sBaudRate = 9600;
[init, respDevice] = setupResp(sPort, sBaudRate);

if init
    % Set some variables
    nSeconds        = nMinutes .* 60;   % # seconds to run device for
    maxMotorDur     = 3;                % in seconds (check & update before starting,
                                    % or the motor may receive commands before it is
                                    % finished moving, risking to be decalibrated)
    maxResetDur     = 10;
    basePos         = 9;
    jitterAmnt      = 8;
    
    % ----------------------------------------------------------------
    % First, reset the device
    resetResp(respDevice);
    % Wait for device to move (XX secs)
    WaitSecs(maxMotorDur);
     
    % ----------------------------------------------------------------
    % Move back and forth for the desired duration (nMinutes)
    
    currDuration    = 0;
    startT          = GetSecs;
    tic;
    
    % Print start duration
    t = datetime('now');
    DateString = datestr(t);
    disp(['RRST device testing, started:   ', DateString]);
    
    
    while logical(currDuration <= nSeconds)
        
        currT           = GetSecs;
        currDuration    = currT - startT;
        
        % Determine a random position to move to (middle position +/- jitter)
        jitterVal       = randi([-jitterAmnt, jitterAmnt]);               % +/- jitterAmnt
        newPosition     = basePos + jitterVal;

        % Send move command
        moveResp(respDevice, newPosition, unitscale);
        
        % Wait for device to move (XX secs)
         WaitSecs(maxMotorDur);
        
    end
    toc
    
else
    disp('Device initialization failed. Check that correct serial port number was used...');
    disp(['Current serial port: ', sPort]);
    return
    
end

