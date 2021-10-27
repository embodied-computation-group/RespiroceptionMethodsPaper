% Make an avi movie from a collection of PNG images in a folder.
% Specify the folder.
myFolder = 'C:\Users\niian\Documents\GitHub\ECG_aarhus\Respiroception\task\RRS_2-2\images';
if ~isdir(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
    uiwait(warndlg(errorMessage));
    return;
end
% Get a directory listing.
filePattern = fullfile(myFolder, '*.png');
pngFiles = dir(filePattern);
% Open the video writer object.
writerObj = VideoWriter('expandingRing60.avi');
writerObj.FrameRate = 60;
open(writerObj);
% Go through image by image writing it out to the AVI file.
for frameNumber = 1 : length(pngFiles)
    % Construct the full filename.
    baseFileName = pngFiles(frameNumber).name;
    fullFileName = fullfile(myFolder, baseFileName);
    % Display image name in the command window.
    fprintf(1, 'Now reading %s\n', fullFileName);
    % Display image in an axes control.
    thisimage = imread(fullFileName);
    imshow(thisimage);  % Display image.
    drawnow; % Force display to update immediately.
    % Write this frame out to the AVI file.
    writeVideo(writerObj, thisimage);
end
% Close down the video writer object to finish the file.
close(writerObj);