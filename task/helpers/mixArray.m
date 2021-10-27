function [arrayOut] = mixArray(arrayIn)
%function [arrayOut] = mixArray(arrayIn)
%
% Mixes up the elements of an input array arrayIn using randperm
%
% Niia Nikolova 2020

randomorder = randperm(length(arrayIn));
arrayOut = arrayIn(randomorder);

end