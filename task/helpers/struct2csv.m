function [success] = struct2csv(structName,outputFile)
%[success] = struct2csv(structName,outputFile)
%   Converst a structure structName to table and save as .csv file of name outputFile
try
    temp_table = struct2table(structName);
    writetable(temp_table,outputFile)
    success = 1;
catch ME
    
end

end

