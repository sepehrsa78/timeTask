function [nextState, trialCtx] = stateSetup(cfg, sessionState, screenInfo, frameSpecs)
% stateSetup  Pre-generate dots and compute geometry for current trial.
%
%   [nextState, trialCtx] = stateSetup(cfg, sessionState, screenInfo, frameSpecs)
%
%   If all trials are done, returns 'SET_COMPLETE'.
%   Otherwise, sets up trialCtx and returns 'FIXATION'.

trialCtx = struct();

% Check if all trials are done
if sessionState.currentTrial > length(sessionState.trialList)
    nextState = 'SET_COMPLETE';
    return
end

%% Extract trial parameters
trial = sessionState.trialList(sessionState.currentTrial);
trialCtx.trialParams = trial;

%% Compute geometry
[xCenter, yCenter] = RectCenter(screenInfo.screen_rect);
pxlSize = cfg.monitor.width / screenInfo.screen_rect(3);

% Fixation cross lines
fixDiam  = ang2pix(cfg.fixation.diameter, cfg.monitor.distance, pxlSize);
trialCtx.rects.fixLines = [...
    xCenter - fixDiam/2, xCenter + fixDiam/2, xCenter, xCenter; ...
    yCenter, yCenter, yCenter - fixDiam/2, yCenter + fixDiam/2];

% Fixation margin rect
fixMarginPx = ang2pix(cfg.fixation.margin, cfg.monitor.distance, pxlSize);
trialCtx.rects.fixRect = [xCenter - fixMarginPx, yCenter - fixMarginPx, ...
                           xCenter + fixMarginPx, yCenter + fixMarginPx];

% Target positions
targEccPx  = ang2pix(cfg.targets.eccentricity, cfg.monitor.distance, pxlSize);
targDiamPx = ang2pix(cfg.targets.diameter, cfg.monitor.distance, pxlSize);

leftCenter  = [xCenter - targEccPx, yCenter];
rightCenter = [xCenter + targEccPx, yCenter];

trialCtx.rects.leftRect  = [leftCenter(1) - targDiamPx/2,  leftCenter(2) - targDiamPx/2, ...
                             leftCenter(1) + targDiamPx/2,  leftCenter(2) + targDiamPx/2];
trialCtx.rects.rightRect = [rightCenter(1) - targDiamPx/2, rightCenter(2) - targDiamPx/2, ...
                             rightCenter(1) + targDiamPx/2, rightCenter(2) + targDiamPx/2];

% Target margin rects (acceptance windows for saccade detection)
targMarginPx = ang2pix(cfg.targets.margin, cfg.monitor.distance, pxlSize);
trialCtx.rects.leftTargMarginRect  = [leftCenter(1) - targMarginPx,  leftCenter(2) - targMarginPx, ...
                                       leftCenter(1) + targMarginPx,  leftCenter(2) + targMarginPx];
trialCtx.rects.rightTargMarginRect = [rightCenter(1) - targMarginPx, rightCenter(2) - targMarginPx, ...
                                       rightCenter(1) + targMarginPx, rightCenter(2) + targMarginPx];

% Abort feedback rect (at center)
feedRadius = ang2pix(0.75, cfg.monitor.distance, pxlSize);
trialCtx.rects.abortRect = [xCenter - feedRadius, yCenter - feedRadius, ...
                             xCenter + feedRadius, yCenter + feedRadius];

% Aperture center in screen pixels
trialCtx.apCenter = deg2screen(cfg.dots.aperture(1:2), screenInfo, 'v');

%% Randomize dot color draw order
trialCtx.drawColor1First = rand < 0.5;

%% Pre-generate dots
trialCtx.dotPos = generateDots(cfg, trial.motionDir, trial.motionCoh, ...
    trial.colorDir, trial.colorCoh, screenInfo);

%% Initialize trial data struct
trialCtx.trialData = struct(...
    'motionDir',     trial.motionDir, ...
    'motionCoh',     trial.motionCoh, ...
    'colorDir',      trial.colorDir, ...
    'colorCoh',      trial.colorCoh, ...
    'correctTarget', trial.correctTarget, ...
    'signedMotionCoh', trial.signedMotionCoh, ...
    'signedColorCoh',  trial.signedColorCoh, ...
    'fixAcquired',   [], ...
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
    'saccY',         [], ...
    'framesShown',   0);

trialCtx.escapePressed = false;
trialCtx.vbl = [];

%% Console output
if trial.motionDir == 90
    motionStr = 'UP';
else
    motionStr = 'DOWN';
end
if trial.colorDir == 1
    colorStr = 'GREEN';
else
    colorStr = 'RED';
end
fprintf('Trial %d/%d | Motion: %s (%.3f) | Color: %s (%.3f) | Correct: %s\n', ...
    sessionState.currentTrial, length(sessionState.trialList), ...
    motionStr, trial.motionCoh, colorStr, trial.colorCoh, ...
    upper(trial.correctTarget));

%% EyeLink trial start messages
Eyelink('Message', 'TRIALID %d', sessionState.currentTrial);
Eyelink('Command', 'record_status_message "TRIAL %d/%d"', ...
    sessionState.currentTrial, length(sessionState.trialList));

nextState = 'FIXATION';

end
