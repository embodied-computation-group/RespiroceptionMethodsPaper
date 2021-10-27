function [outputArray] = loadFiles(dataFolder, searchString)
% function [outputArray] = loadFiles(dataFolder, searchString)
%
% Load all files in inputDir and concat data into outputArray
%
%       dataFolder      path to folder from which to load files
%       searchString    [optional] string specifyingn which files to load,
%                       can use wildcard, e.g. '\EmotDiscrim*'
%
% Niia Nikolova
% Last edit: 24/04/2020


%% Set-up
% Check input args
if nargin < 1
    disp('loadFiles error! Please specify a directory.');
    return;
elseif nargin == 1
    searchString = '\*';
end

% Find files in folder
dataSpec = [dataFolder, searchString];
files = dir(dataSpec);

% Get some information about the data
if ~isempty(files)
    firstFilePath = [files(1).folder, filesep, files(1).name];
    firstFile = load(firstFilePath, 'Results');
    structNames = (fieldnames(firstFile.Results));
    nFields = numel(structNames);
else
    disp('Error, no files found in directory.');
    return
end

% Set up output array
dimRows = 1;
dimCols = nFields;
outputArray = zeros(dimRows, dimCols);


%% Run through the files and extract the data
for thisFile = 1 : length(files)
    thisFilePath = [files(thisFile).folder, filesep, files(thisFile).name];
    thisFileResults = load(thisFilePath, 'Results');        % load struct
    thisFileVars = load(thisFilePath, 'vars');        % load struct
    
    % loop through stuct fields and populate outputArray rows
    for thisField = 1:nFields
        
        thisFieldData = thisFileResults.Results.(structNames{thisField});
        
        %         % code individual in stimulus                           <---- N.B.  FIELD NUMBER SPECIFIC TO EMOT DISCRIM TASK ***
        %         % m08  , m31  , f06  , f24
        %         if thisField == 9
        %             strings2replace = thisFieldData;
        %             [~,~,thisFieldData ] = unique(strings2replace,'stable');
        %         end
        
        % Ignote signalInterval field, mismatch in dimensions
        if strcmp(structNames{thisField}, 'SignalInterval') ~= 1
            dataFileArray(1:size(thisFieldData,1), thisField) = thisFieldData;
        end
        
    end%thisField
    
    % concatenate output array
    outputArray = vertcat(outputArray, dataFileArray);

end

% clean up zero rows, NaN columns
outputArray( ~any(outputArray,2), : ) = [];              % for zero - rows
outputArray = outputArray(:, ~all(isnan(outputArray)));   % for nan - columns

% done
end
