function [nextState, trialCtx] = stateFix(cfg, trialCtx, window, frameSpecs)
% stateFix  Gaze-gated fixation state.
%
%   [nextState, trialCtx] = stateFix(cfg, trialCtx, window, frameSpecs)
%
%   Waits until participant's gaze is in the fixation window for
%   cfg.timing.fixHoldToStart seconds, then holds for an additional
%   cfg.timing.fixation seconds before advancing to DOTS.
%   Checks ESCAPE each frame.

fixLines  = trialCtx.rects.fixLines;
fixRect   = trialCtx.rects.fixRect;
fixLW     = cfg.fixation.lineWidth;
fixColor  = cfg.colors.fix;

%% Phase 1: Wait for gaze to enter fixation window and hold
gazeAcquired = false;
holdStart    = NaN;

vbl = Screen('Flip', window);

while ~gazeAcquired
    % Draw fixation cross
    Screen('DrawLines', window, fixLines, fixLW, fixColor);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);

    % Check ESCAPE
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(cfg.keyBoard.escapeKey)
        trialCtx.escapePressed = true;
    end

    % Poll EyeLink
    tmp   = Eyelink('NewestFloatSample');
    xGaze = tmp.gx(1);
    yGaze = tmp.gy(1);

    if IsInRect(xGaze, yGaze, fixRect)
        if isnan(holdStart)
            holdStart = GetSecs();
            Eyelink('Message', 'FIX_ACQUIRED');
            trialCtx.trialData.fixAcquired = holdStart;
        end

        % Check if hold duration met
        if GetSecs() - holdStart >= cfg.timing.fixHoldToStart
            gazeAcquired = true;
        end
    else
        % Gaze left fixation window, reset hold timer
        holdStart = NaN;
    end
end

%% Phase 2: Maintain fixation for pre-stimulus period
Eyelink('Message', 'FIX_ON');
trialCtx.trialData.fixOn = GetSecs();

for numFrames = 1:round(cfg.timing.fixation / frameSpecs.ifi)
    Screen('DrawLines', window, fixLines, fixLW, fixColor);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);

    % Check ESCAPE
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(cfg.keyBoard.escapeKey)
        trialCtx.escapePressed = true;
    end
end

trialCtx.vbl = vbl;
nextState = 'DOTS';

end
