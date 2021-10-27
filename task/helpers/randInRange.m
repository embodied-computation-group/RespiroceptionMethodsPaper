function randArray = randInRange(rangeMin, rangeMax, arraySize)
% function randArray = randInRange(rangeMin, rangeMax, arraySize)
%
% Creates an array of arraySize of random numbers from the uniform distribution in
% range rangeMin - rangeMax

randArray = (rangeMax - rangeMin) .* rand(arraySize) + rangeMin;

end