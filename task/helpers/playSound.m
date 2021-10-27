function playSound(filename)
% playSound sound engine
% input: filename (.wav file)
% Troubleshooting:
%
% If we get this error:Failed to open audio device
% close the device PsychPortAudio('Close', 0)
% 
% Niia Nikolova 12.2019

%34-Rain-60min.wav

printOutput = 0;        % Optional flag to print playback status to command line 

switch nargin
    case 0
        filename = 'funk.wav';
        disp('No audio (.wav) file provided.');
end

InitializePsychSound;%(1); % could set optional desperate to 1?


Parameters.pa.device       = 4;%2            % try with default setting - NB that default may be MME --> BAD for timing! 
% Run PsychPortAudio('GetDevices') to get a list of all available devices
Parameters.pa.mode         = 1;            % playback only
Parameters.pa.latencyClass = 1;            % 0 don't care // 1 go for low latency // 2 really agressive // 3 monster // 4 fail if can't MONSTER
% Parameters.pa.freq         = 48000;        % INPUT DEFAULT DEVICE FREQ HERE
% Parameters.pa.channels     = 2;%1;            % go for mono as we don't care...
repetitions                 = 2;

Parameters.pa.wavfilename = [ '..' filesep 'helpers' filesep 'audio' filesep filename];

% Read WAV file from filesystem:
[y, freq] = psychwavread(Parameters.pa.wavfilename);
wavedata = y';
Parameters.pa.channels = size(wavedata,1); % Number of rows == number of channels.

% Make sure we have always 2 channels stereo output.
% Why? Because some low-end and embedded soundcards
% only support 2 channels, not 1 channel, and we want
% to be robust in our demos.
if Parameters.pa.channels < 2
    wavedata = [wavedata ; wavedata];
    Parameters.pa.channels = 2;
end

% Parameters.pa.toneBuffer   = PsychPortAudio('FillBuffer',Parameters.pa.H,cfg.Binding.tone);
% Parameters.pa.volume       = PsychPortAudio('Volume',Parameters.pa.H);


% Open the  audio device, with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
% try
%     % Try with the 'freq'uency we wanted:
%     Parameters.pa.H            = PsychPortAudio('Open',Parameters.pa.device,...
%                                             Parameters.pa.mode,...
%                                             Parameters.pa.latencyClass,...
%                                             Parameters.pa.freq,...
%                                             Parameters.pa.channels);
% catch
%     % Failed. Retry with default frequency as suggested by device:
%     fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
%     fprintf('Sound may sound a bit out of tune, ...\n\n');
% 
%     psychlasterror('reset');
%     Parameters.pa.H = PsychPortAudio('Open', Parameters.pa.device, [], 0, [], Parameters.pa.channels);
% end

% Open the  audio device
Parameters.pa.H = PsychPortAudio('Open', Parameters.pa.device, [], 0, [], Parameters.pa.channels);

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', Parameters.pa.H, wavedata);

% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
t1 = PsychPortAudio('Start', Parameters.pa.H, repetitions, 0, 1);

% Wait for release of all keys on keyboard:
KbReleaseWait;

% fprintf('Audio playback started, press any key for about 1 second to quit.\n');
% 
% lastSample = 0;
% lastTime = t1;

% % Stay in a little loop until keypress:
% while ~KbCheck
% 
%     % Wait a seconds...
%     WaitSecs(1);
% 
%     % Query current playback status and print it to the Matlab window:
%     s = PsychPortAudio('GetStatus', Parameters.pa.H);
%     tHost = GetSecs;
% 
%     if printOutput
%         % Print it:
%         fprintf('\n\nAudio playback started, press any key for about 1 second to quit.\n');
%         fprintf('This is some status output of PsychPortAudio:\n');
%         disp(s);
%         
%         realSampleRate = (s.ElapsedOutSamples - lastSample) / (s.CurrentStreamTime - lastTime);
%         fprintf('Measured average samplerate Hz: %f\n', realSampleRate);
%         
%         tHost = s.CurrentStreamTime;
%         clockDelta = (s.ElapsedOutSamples / s.SampleRate) - (tHost - t1);
%         clockRatio = (s.ElapsedOutSamples / s.SampleRate) / (tHost - t1);
%         fprintf('Delta between audio hw clock and host clock: %f msecs. Ratio %f.\n', 1000 * clockDelta, clockRatio);
%     end
% end

% %% If we want to wait for the sound to finish playing...
% %% Find out the duration of the audio file
% info = audioinfo([ '.' filesep 'audio' filesep filename]);
% audioDuration = (info.Duration)+1;    % wait for audio and a sec at the end
% %% Wait for the sound to finish 
% WaitSecs(audioDuration);


% % Stop playback:
% PsychPortAudio('Stop', Parameters.pa.H);
% 
% % Close the audio device:
% PsychPortAudio('Close', Parameters.pa.H);
% 
% % Done.
% fprintf('Finished playing sound!\n');