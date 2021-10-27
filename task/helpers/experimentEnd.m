function experimentEnd(vars, scr, keys, Results, stair)
%function experimentEnd(vars, scr, keys, Results, stair)

% Get open audio device count
countAudDev = PsychPortAudio('GetOpenDeviceCount');

if vars.Aborted

    % Abort screen
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, 'Experiment was aborted!', 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    WaitSecs(0.5);
    ShowCursor;
    sca;
    disp('Experiment aborted by user!');
    
    % Save, mark the run
    vars.DataFileName = ['Aborted_', vars.DataFileName];
    save(strcat(vars.OutputFolder, vars.DataFileName), 'stair', 'Results', 'vars', 'scr', 'keys' );
    disp(['Run was aborted. Results were saved as: ', vars.DataFileName]);
    
    % and as .csv
    Results.stair = stair;                  % Add staircase params to Results struct for the .csv
    csvName = strcat(vars.OutputFolder, vars.DataFileName, '.csv');
    struct2csv(Results, csvName);

    % Stop audio playback
    if countAudDev ~= 0
        PsychPortAudio('Close', 0);
    end
    
elseif vars.Error
    % Error
    vars.DataFileName = ['Error_',vars.DataFileName];
    save(strcat(vars.OutputFolder, vars.DataFileName), 'stair', 'Results', 'vars', 'scr', 'keys' );
    % and as .csv
    Results.stair = stair;                      % Add staircase structure to Results to save
    csvName = strcat(vars.OutputFolder, vars.DataFileName, '.csv');
    struct2csv(Results, csvName);
    
    disp(['Run crashed. Results were saved as: ', vars.DataFileName]);
    disp(' ** Error!! ***')
    
    % Stop audio playback
    if countAudDev ~= 0
        PsychPortAudio('Close', 0);
    end
    
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
    
else % Successfull run
    % Show end screen and clean up
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, vars.InstructionEnd, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    WaitSecs(3);
    
    % Save the data
    save(strcat(vars.OutputFolder, vars.DataFileName), 'stair', 'Results', 'vars', 'scr', 'keys' );
    disp(['Run complete. Results were saved as: ', vars.DataFileName]);
    
    % and as .csv
    Results.stair = stair;                      % Add staircase structure to Results to save
    csvName = strcat(vars.OutputFolder, vars.DataFileName, '.csv');
    struct2csv(Results, csvName);                                      
    
    % Stop audio playback
    if countAudDev ~= 0
        PsychPortAudio('Close', 0);
    end
end


sca;
ShowCursor;
fclose('all');
Priority(0);
