function [outcome, RT, saccX, saccY] = detectSaccade(cfg, fixRect, leftTargRect, rightTargRect, stimOnTime)
% detectSaccade  Detect saccade from fixation to a target.
%
%   [outcome, RT, saccX, saccY] = detectSaccade(cfg, fixRect, leftTargRect, rightTargRect, stimOnTime)
%
%   Adapted from timeTask/funcs/timeSaccade.m
%   Polls EyeLink gaze samples to detect when the eye leaves fixation,
%   then determines which target (if any) the saccade landed on.
%
%   Inputs:
%       cfg           — task configuration struct
%       fixRect       — [x1,y1,x2,y2] fixation acceptance window
%       leftTargRect  — [x1,y1,x2,y2] left target acceptance window
%       rightTargRect — [x1,y1,x2,y2] right target acceptance window
%       stimOnTime    — GetSecs timestamp of stimulus onset
%
%   Outputs:
%       outcome — 'left', 'right', 'noTarget', or 'timeout'
%       RT      — reaction time (seconds from stimOnTime)
%       saccX   — x coordinate of saccade landing
%       saccY   — y coordinate of saccade landing

outcome = 'timeout';
RT      = NaN;
saccX   = NaN;
saccY   = NaN;

inFix    = true;
tFixBreak = NaN;

%% Wait for saccade (gaze leaving fixation window)
while inFix
    % Check timeout
    if GetSecs() - stimOnTime > cfg.timing.maxRT
        Eyelink('Message', 'TIMEOUT');
        return
    end

    tmp   = Eyelink('NewestFloatSample');
    xGaze = tmp.gx(1);
    yGaze = tmp.gy(1);

    inFix = IsInRect(xGaze, yGaze, fixRect);

    if ~inFix
        tFixBreak = GetSecs();
        RT = tFixBreak - stimOnTime;
        Eyelink('Message', 'SACCADE_ON');
    end
end

%% Wait for saccade to land (accumulation period)
WaitSecs(cfg.timing.saccadeAccum);

%% Sample landing position
tmp   = Eyelink('NewestFloatSample');
saccX = tmp.gx(1);
saccY = tmp.gy(1);
Eyelink('Message', 'SACCADE_LAND');

%% Check if gaze is in a target
inLeft  = IsInRect(saccX, saccY, leftTargRect);
inRight = IsInRect(saccX, saccY, rightTargRect);

if inLeft
    outcome = 'left';
elseif inRight
    outcome = 'right';
else
    outcome = 'noTarget';
    return
end

%% Verify fixation hold on target
if inLeft
    targetRect = leftTargRect;
else
    targetRect = rightTargRect;
end

tLand = GetSecs();
isHeld = true;
while GetSecs() - tLand < cfg.timing.fixHold
    tmpH  = Eyelink('NewestFloatSample');
    xH    = tmpH.gx(1);
    yH    = tmpH.gy(1);
    if ~IsInRect(xH, yH, targetRect)
        isHeld = false;
        break
    end
end

if ~isHeld
    outcome = 'noTarget';
end

end
