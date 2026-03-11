function drawDotsFrame(window, dotPos, frameIdx, cfg, apCenter, drawColor1First)
% drawDotsFrame  Render one frame of colored random dots.
%
%   drawDotsFrame(window, dotPos, frameIdx, cfg, apCenter, drawColor1First)
%
%   Adapted from rig_files/dots_2d_col/dotsShow.m
%   Draws dots for a single frame, colored by their color code.
%   Does NOT flip the screen — caller is responsible for Screen('Flip').
%
%   Inputs:
%       window          — PsychToolbox window pointer
%       dotPos          — [ndots x 3 x nFrames] pre-generated dot array
%       frameIdx        — which frame to draw (1-indexed)
%       cfg             — task configuration struct
%       apCenter        — [x, y] aperture center in screen pixels
%       drawColor1First — boolean: if true, draw color1 (green) before color2 (red)

pos = round(dotPos(:, 1:2, frameIdx)');  % [2 x ndots] screen-relative positions
col = dotPos(:, 3, frameIdx)';           % [1 x ndots] color codes

color1RGB = cfg.colors.color1;  % green
color2RGB = cfg.colors.color2;  % red
whiteRGB  = cfg.colors.white;
dotSize   = cfg.dots.dotSize;

% Draw dots in randomized color order to avoid rendering bias
if drawColor1First
    % Draw color1 (green) first, then color2 (red), then white
    mask1 = col == 1;
    if any(mask1)
        Screen('DrawDots', window, pos(:, mask1), dotSize, color1RGB', apCenter);
    end
    mask2 = col == 2;
    if any(mask2)
        Screen('DrawDots', window, pos(:, mask2), dotSize, color2RGB', apCenter);
    end
else
    % Draw color2 (red) first, then color1 (green), then white
    mask2 = col == 2;
    if any(mask2)
        Screen('DrawDots', window, pos(:, mask2), dotSize, color2RGB', apCenter);
    end
    mask1 = col == 1;
    if any(mask1)
        Screen('DrawDots', window, pos(:, mask1), dotSize, color1RGB', apCenter);
    end
end

% Draw any white dots
mask0 = col == 0;
if any(mask0)
    Screen('DrawDots', window, pos(:, mask0), dotSize, whiteRGB', apCenter);
end

end
