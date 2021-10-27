function [keys] = keyConfig()
%function [keys] = keyConfig()

% Set-up keyboard
KbName('UnifyKeyNames')
keys.Escape = KbName('ESCAPE');
keys.Space = KbName('space');
keys.Left = KbName('LeftArrow');
keys.Right = KbName('RightArrow');
keys.One = KbName('1!');
keys.Two = KbName('2@');
keys.Three = KbName('3#');
keys.SoundStop = KbName('s');

end