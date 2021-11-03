function Value = GetFields(S, Name)
%Value = GetFields(S, Name)
%
% For a structure S and fieldname 'Name', returns an array with all entries
% in that field
%
% Niia 02/2021

Value = cell(size(Name));
Data  = struct2cell(S); 
Value = Data(1,:)';