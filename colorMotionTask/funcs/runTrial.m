function trialData = runTrial(cfg, trialParams, window, screenInfo, frameSpecs)
% runTrial  Execute a single color-motion discrimination trial.
%
%   trialData = runTrial(cfg, trialParams, window, screenInfo, frameSpecs)
%
%   Trial flow: fixation -> dots+targets (with saccade detection) -> feedback
%
%   Inputs:
%       cfg         — task configuration struct (from taskCfg.m)
%       trialParams — struct with fields:
%                       motionDir    — 90 (up) or 270 (down)
%                       motionCoh    — unsigned coherence [0-1]
%                       colorDir     — 1 (green majority) or 2 (red majority)
%                       colorCoh     — unsigned coherence [0-1]
%                       correctTarget— 'left' or 'right'
%       window      — PsychToolbox window pointer
%       screenInfo  — struct with: pix_per_deg, mon_refresh, screen_rect, cur_window
%       frameSpecs  — struct with: ifi, waitframes
%
%   Output:
%       trialData   — struct with all trial timing and outcome data

%% Initialize trial data
trialData = struct(...
    'motionDir',     trialParams.motionDir, ...
    'motionCoh',     trialParams.motionCoh, ...
    'colorDir',      trialParams.colorDir, ...
    'colorCoh',      trialParams.colorCoh, ...
    'correctTarget', trialParams.correctTarget, ...
    'fixOn',         [], ...
    'dotsOn',        [], ...
    'targetsOn',     [], ...
    'saccadeOn',     [], ...
    'saccadeLand',   [], ...
    'feedbackOn',    [], ...
    'feedbackOff',   [], ...
    'RT',            [], ...
    'response',      '', ...
    'correct',       [], ...
    'saccX',         [], ...
    'saccY',         []);

%% Compute geometry
[xCenter, yCenter] = RectCenter(screenInfo.screen_rect);

% Fixation cross lines
fixDiam  = ang2pix(cfg.fixation.diameter, cfg.monitor.distance, cfg.monitor.width / screenInfo.screen_rect(3));
fixLines = [...
    xCenter - fixDiam/2, xCenter + fixDiam/2, xCenter, xCenter; ...
    yCenter, yCenter, yCenter - fixDiam/2, yCenter + fixDiam/2];

% Fixation margin rect
fixMarginPx = ang2pix(cfg.fixation.margin, cfg.monitor.distance, cfg.monitor.width / screenInfo.screen_rect(3));
fixRect = [xCenter - fixMarginPx, yCenter - fixMarginPx, ...
           xCenter + fixMarginPx, yCenter + fixMarginPx];

% Target positions and rects
targEccPx  = ang2pix(cfg.targets.eccentricity, cfg.monitor.distance, cfg.monitor.width / screenInfo.screen_rect(3));
targDiamPx = ang2pix(cfg.targets.diameter, cfg.monitor.distance, cfg.monitor.width / screenInfo.screen_rect(3));

leftTargCenter  = [xCenter - targEccPx, yCenter];
rightTargCenter = [xCenter + targEccPx, yCenter];

leftRect  = [leftTargCenter(1) - targDiamPx/2,  leftTargCenter(2) - targDiamPx/2, ...
             leftTargCenter(1) + targDiamPx/2,  leftTargCenter(2) + targDiamPx/2];
rightRect = [rightTargCenter(1) - targDiamPx/2, rightTargCenter(2) - targDiamPx/2, ...
             rightTargCenter(1) + targDiamPx/2, rightTargCenter(2) + targDiamPx/2];

% Target margin rects (for saccade detection)
targMarginPx = ang2pix(cfg.targets.margin, cfg.monitor.distance, cfg.monitor.width / screenInfo.screen_rect(3));
leftTargMarginRect  = [leftTargCenter(1) - targMarginPx,  leftTargCenter(2) - targMarginPx, ...
                       leftTargCenter(1) + targMarginPx,  leftTargCenter(2) + targMarginPx];
rightTargMarginRect = [rightTargCenter(1) - targMarginPx, rightTargCenter(2) - targMarginPx, ...
                       rightTargCenter(1) + targMarginPx, rightTargCenter(2) + targMarginPx];

% Aperture center in screen pixels (for dot drawing)
apCenter = deg2screen(cfg.dots.aperture(1:2), screenInfo, 'v');

% Feedback rect (at center for abort)
feedRadius = ang2pix(0.75, cfg.monitor.distance, cfg.monitor.width / screenInfo.screen_rect(3));
abortRect  = [xCenter - feedRadius, yCenter - feedRadius, ...
              xCenter + feedRadius, yCenter + feedRadius];

%% Randomize dot color draw order for this trial
drawColor1First = rand < 0.5;

%% Pre-generate dots
dotPos = generateDots(cfg, trialParams.motionDir, trialParams.motionCoh, ...
    trialParams.colorDir, trialParams.colorCoh, screenInfo);

%% === PHASE 1: FIXATION ===
vbl = Screen('Flip', window);
for numFrames = 1:round(cfg.timing.fixation / frameSpecs.ifi)
    Screen('DrawLines', window, fixLines, cfg.fixation.lineWidth, cfg.colors.fix);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(trialData.fixOn)
        trialData.fixOn = vbl;
        Eyelink('Message', 'FIX_ON');
    end
end

%% === PHASE 2: DOTS + TARGETS + SACCADE DETECTION ===
frameIdx    = 0;
saccDetected = false;
stimOnTime  = NaN;

if cfg.timing.fixedDuration > 0
    % Fixed duration mode: show dots for set time, then blank + wait for saccade
    maxDotFrames = round(cfg.timing.fixedDuration / frameSpecs.ifi);
else
    % RT mode: show dots until saccade or timeout
    maxDotFrames = round(cfg.timing.maxRT / frameSpecs.ifi);
end

% Dot display loop with per-frame saccade checking
for numFrames = 1:maxDotFrames
    frameIdx = frameIdx + 1;

    % Draw dots
    drawDotsFrame(window, dotPos, frameIdx, cfg, apCenter, drawColor1First);
    % Draw targets
    drawTargets(window, leftRect, rightRect, cfg.colors.target);
    % Draw fixation
    Screen('DrawLines', window, fixLines, cfg.fixation.lineWidth, cfg.colors.fix);

    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);

    if isempty(trialData.dotsOn)
        trialData.dotsOn    = vbl;
        trialData.targetsOn = vbl;
        stimOnTime = vbl;
        Eyelink('Message', 'DOTS_ON');
        Eyelink('Message', 'TARGETS_ON');
    end

    % Check gaze position each frame
    tmp   = Eyelink('NewestFloatSample');
    xGaze = tmp.gx(1);
    yGaze = tmp.gy(1);

    if ~IsInRect(xGaze, yGaze, fixRect)
        % Saccade detected — break out to saccade landing detection
        saccDetected = true;
        trialData.saccadeOn = GetSecs();
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
    trialData.saccX = saccX;
    trialData.saccY = saccY;
    trialData.saccadeLand = GetSecs();
    trialData.RT = trialData.saccadeOn - stimOnTime;
    Eyelink('Message', 'SACCADE_LAND');

    % Determine which target
    inLeft  = IsInRect(saccX, saccY, leftTargMarginRect);
    inRight = IsInRect(saccX, saccY, rightTargMarginRect);

    if inLeft
        trialData.response = 'left';
    elseif inRight
        trialData.response = 'right';
    else
        trialData.response = 'noTarget';
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
            trialData.response = 'noTarget';
        end
    end

elseif cfg.timing.fixedDuration > 0
    % Fixed duration mode: dots finished, now wait for saccade without dots
    [outcome, RT, saccX, saccY] = detectSaccade(cfg, fixRect, ...
        leftTargMarginRect, rightTargMarginRect, stimOnTime);
    trialData.response    = outcome;
    trialData.RT          = RT;
    trialData.saccX       = saccX;
    trialData.saccY       = saccY;
    trialData.saccadeOn   = stimOnTime + RT;
    trialData.saccadeLand = GetSecs();
else
    % RT mode timeout
    trialData.response = 'timeout';
    trialData.RT       = NaN;
    Eyelink('Message', 'TIMEOUT');
end

%% === PHASE 3: EVALUATE RESPONSE ===
if strcmp(trialData.response, trialData.correctTarget)
    trialData.correct = true;
else
    trialData.correct = false;
end

%% === PHASE 4: FEEDBACK ===
if trialData.correct
    % Green feedback on the selected target
    if strcmp(trialData.response, 'left')
        feedRect = leftRect;
    else
        feedRect = rightRect;
    end
    for numFrames = 1:round(cfg.timing.feedbackDur / frameSpecs.ifi)
        drawTargets(window, leftRect, rightRect, cfg.colors.target);
        Screen('FillOval', window, cfg.colors.feedbackGo, feedRect);
        Screen('DrawLines', window, fixLines, cfg.fixation.lineWidth, cfg.colors.fix);
        if numFrames == 1
            vbl = Screen('Flip', window);
            trialData.feedbackOn = vbl;
            Eyelink('Message', 'FEEDBACK_ON correct');
        else
            vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        end
    end
else
    % Yellow abort feedback at center
    for numFrames = 1:round(cfg.timing.feedbackDur / frameSpecs.ifi)
        Screen('FillOval', window, cfg.colors.feedbackAbort, abortRect);
        if numFrames == 1
            vbl = Screen('Flip', window);
            trialData.feedbackOn = vbl;
            Eyelink('Message', 'FEEDBACK_ON error');
        else
            vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        end
    end
end

vbl = Screen('Flip', window);
trialData.feedbackOff = vbl;
Eyelink('Message', 'FEEDBACK_OFF');

end
