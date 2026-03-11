function drawTargets(window, leftRect, rightRect, targetColor)
% drawTargets  Draw left and right choice targets.
%
%   drawTargets(window, leftRect, rightRect, targetColor)
%
%   Simplified from rig_files/dots_2d_col/targDraw.m
%   Draws two neutral filled ovals at the specified positions.
%   Does NOT flip the screen.
%
%   Inputs:
%       window      — PsychToolbox window pointer
%       leftRect    — [x1, y1, x2, y2] bounding rect for left target
%       rightRect   — [x1, y1, x2, y2] bounding rect for right target
%       targetColor — [r, g, b] color (normalized 0-1 or 0-255)

Screen('FillOval', window, targetColor, leftRect);
Screen('FillOval', window, targetColor, rightRect);

end
