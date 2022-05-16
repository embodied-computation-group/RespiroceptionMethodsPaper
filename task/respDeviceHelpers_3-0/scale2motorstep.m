function [motorStepVal] = scale2motorstep(scaleVal, unitscale)
%[motorStepVal] = scale2motorstep(scaleVal,unitscale) Rescale either a 
% percent (0-100) or mm (0-17) value [scaleVal] to 12000 -
% 38000 [motorStepVal] (step motor input for moveResp.m)
%
%   Input: 
%       scaleVal       input value 0-100
%       unitscale      units to scale. 0 percent (0-100), 1 mm (0-17)
%
%   Output:
%       motorStepVal   scaled value 9,000 - 32,000
%
% Note that motorStepVal values can vary by device, due to the way in which
% the lead screw is mounted to the motor & coupler
%   Green device            12,000 - 38,000
%   Red device (Olivia)     9,000 - 32,000
%   Yellow device           8,000 - 32,500 (old 30,300)
%   Black device            9,000 - 31,000
%   Black device #2 (SPICE) 9,000 - 32,000
%
% It is possible to fine tune this to some extent, by turning the screw
% attached to the back of the wedge on the device. Turn CCW (out) to
% decrease steps, and CW (in) to increas steps.
%
% minimum = load just touching tube (a A4 paper inserted between wedge and tube is just help in place), 
%   max = barely possibly to inhale through the tube
%       
% Niia Nikolova 06/01/2021


stepMotRange_min = 12000;            % <<====== THIS NEEDS TO BE ADJUSTED FOR EACH INDIVIDUAL MOTOR
stepMotRange_max = 38000;           % <<====== THIS NEEDS TO BE ADJUSTED FOR EACH INDIVIDUAL MOTOR

if unitscale == 0       % percent
    scaleInput = [0 scaleVal 100];
elseif unitscale == 1   % mm
    scaleInput = [0 scaleVal 17];
else
    disp('Error! Invalid unit scale paramter. Enter 0 for percent obstruction or 1 for mm');
    return
end
rescaledVals = rescale(scaleInput, stepMotRange_min, stepMotRange_max);
motorStepVal = round(rescaledVals(2));

% disp(['Motor step val: ', num2str(motorStepVal)]);
end

