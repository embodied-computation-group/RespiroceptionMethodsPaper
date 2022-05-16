function moveInIncrements()
%moveInIncrements Moves respiroception device back and forth to increments
%of obstruction. Used for recording physio measures
%   Input:
%
%
%
% Niia Nikolova 15/06/2021


% Initialize resp device
unitscale   = 1;          % 0 units 0-100. 1 units 0-17
nReps       = 20;
sPort       = "COM5";
sBaudRate   = 9600;
[init, respDevice] = setupResp(sPort, sBaudRate);

if init
    % Set some variables
    maxMotorDur     = 1.5;                % in seconds (how long motor takes to move to new position, be liberal!)
    resetDur        = 10;                % sec in takes to reset
    
    % ----------------------------------------------------------------
    % First, reset the device
    resetResp(respDevice);
    % Wait for device to move (XX secs)
    WaitSecs(resetDur);
    
    % ----------------------------------------------------------------
    % Define increments to move to
    moveInc     = 1:1:17;
    nIncs       = size(moveInc,2);
    homePos     = 1;

    
    % Print start duration
    t = datetime('now');
    DateString = datestr(t);
    disp(['RRST device testing, started:   ', DateString]);
    
    for thisRep = 1 : nReps
        
        for thisStep = 1 : nIncs
          
            % Determine position to move to
            newPosition     = moveInc(thisStep);
            
            % Send move command
            moveResp(respDevice, newPosition, unitscale);
            
            % Wait for device to move (XX secs)
            WaitSecs(maxMotorDur);
        end
        
        % Move back to 0
        moveResp(respDevice, homePos, unitscale);
        
        % Wait for device to move (XX secs)
        WaitSecs(resetDur);
    end
    
else
    disp('Device initialization failed. Check that correct serial port number was used...');
    disp(['Current serial port: ', sPort]);
    return
    
end

