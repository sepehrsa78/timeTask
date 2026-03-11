function [nextState, trialCtx] = stateDots(cfg, trialCtx, window, screenInfo, frameSpecs)
% stateDots  Display dots + targets and detect saccade response.
%
%   [nextState, trialCtx] = stateDots(cfg, trialCtx, window, screenInfo, frameSpecs)
%
%   Shows random dots with colored motion, draws left/right targets,
%   and polls EyeLink each frame for saccade detection.
%   Supports both RT mode and fixed duration mode.

vbl       = trialCtx.vbl;
fixLines  = trialCtx.rects.fixLines;
fixRect   = trialCtx.rects.fixRect;
leftRect  = trialCtx.rects.leftRect;
rightRect = trialCtx.rects.rightRect;
leftTargMarginRect  = trialCtx.rects.leftTargMarginRect;
rightTargMarginRect = trialCtx.rects.rightTargMarginRect;
apCenter  = trialCtx.apCenter;
dotPos    = trialCtx.dotPos;

%% Determine max frames
if cfg.timing.fixedDuration > 0
    maxDotFrames = round(cfg.timing.fixedDuration / frameSpecs.ifi);
else
    maxDotFrames = round(cfg.timing.maxRT / frameSpecs.ifi);
end

%% Dot display loop with per-frame saccade checking
frameIdx     = 0;
saccDetected = false;
stimOnTime   = NaN;

for numFrames = 1:maxDotFrames
    frameIdx = frameIdx + 1;

    % Draw dots
    drawDotsFrame(window, dotPos, frameIdx, cfg, apCenter, trialCtx.drawColor1First);
    % Draw targets
    drawTargets(window, leftRect, rightRect, cfg.colors.target);
    % Draw fixation
    Screen('DrawLines', window, fixLines, cfg.fixation.lineWidth, cfg.colors.fix);

    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);

    if isempty(trialCtx.trialData.dotsOn)
        trialCtx.trialData.dotsOn    = vbl;
        trialCtx.trialData.targetsOn = vbl;
        stimOnTime = vbl;
        Eyelink('Message', 'DOTS_ON');
        Eyelink('Message', 'TARGETS_ON');
    end

    % Check ESCAPE
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(cfg.keyBoard.escapeKey)
        trialCtx.escapePressed = true;
    end

    % Poll EyeLink for saccade
    tmp   = Eyelink('NewestFloatSample');
    xGaze = tmp.gx(1);
    yGaze = tmp.gy(1);

    if ~IsInRect(xGaze, yGaze, fixRect)
        saccDetected = true;
        trialCtx.trialData.saccadeOn = GetSecs();
        Eyelink('Message', 'SACCADE_ON');
        break
    end
end

%% Handle saccade landing or timeout
if saccDetected
    % Wait for saccade to land
    WaitSecs(cfg.timing.saccadeAccum);

    tmp   = Eyelink('NewestFloatSample');
    saccX = tmp.gx(1);
    saccY = tmp.gy(1);
    trialCtx.trialData.saccX       = saccX;
    trialCtx.trialData.saccY       = saccY;
    trialCtx.trialData.saccadeLand = GetSecs();
    trialCtx.trialData.RT          = trialCtx.trialData.saccadeOn - stimOnTime;
    Eyelink('Message', 'SACCADE_LAND');

    % Determine which target
    inLeft  = IsInRect(saccX, saccY, leftTargMarginRect);
    inRight = IsInRect(saccX, saccY, rightTargMarginRect);

    if inLeft
        trialCtx.trialData.response = 'left';
    elseif inRight
        trialCtx.trialData.response = 'right';
    else
        trialCtx.trialData.response = 'noTarget';
    end

    % Verify fixation hold on target
    if inLeft || inRight
        if inLeft
            holdRect = leftTargMarginRect;
        else
            holdRect = rightTargMarginRect;
        end
        tLand  = GetSecs();
        isHeld = true;
        while GetSecs() - tLand < cfg.timing.fixHold
            tmpH = Eyelink('NewestFloatSample');
            if ~IsInRect(tmpH.gx(1), tmpH.gy(1), holdRect)
                isHeld = false;
                break
            end
        end
        if ~isHeld
            trialCtx.trialData.response = 'noTarget';
        end
    end

elseif cfg.timing.fixedDuration > 0
    % Fixed duration mode: wait for saccade without dots
    [outcome, RT, saccX, saccY] = detectSaccade(cfg, fixRect, ...
        leftTargMarginRect, rightTargMarginRect, stimOnTime);
    trialCtx.trialData.response    = outcome;
    trialCtx.trialData.RT          = RT;
    trialCtx.trialData.saccX       = saccX;
    trialCtx.trialData.saccY       = saccY;
    trialCtx.trialData.saccadeOn   = stimOnTime + RT;
    trialCtx.trialData.saccadeLand = GetSecs();
else
    % RT mode timeout
    trialCtx.trialData.response = 'timeout';
    trialCtx.trialData.RT       = NaN;
    Eyelink('Message', 'TIMEOUT');
end

%% Evaluate response
if strcmp(trialCtx.trialData.response, trialCtx.trialData.correctTarget)
    trialCtx.trialData.correct = true;
else
    trialCtx.trialData.correct = false;
end

trialCtx.vbl = vbl;
nextState = 'FEEDBACK';

end
