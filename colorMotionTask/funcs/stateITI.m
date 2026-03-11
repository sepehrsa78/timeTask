function [nextState, trialCtx, sessionState] = stateITI(cfg, trialCtx, sessionState, window, frameSpecs)
% stateITI  Inter-trial interval: blank screen, store data, advance trial.
%
%   [nextState, trialCtx, sessionState] = stateITI(cfg, trialCtx, sessionState, window, frameSpecs)
%
%   Displays a blank screen for cfg.timing.ITI seconds.
%   Stores the completed trial data into sessionState.
%   Advances the trial counter.
%   If ESCAPE was pressed during this trial, transitions to PAUSE.

vbl = trialCtx.vbl;

%% EyeLink trial-end messages
bgc = round(cfg.colors.background * 255);
Eyelink('Message', 'BLANK_SCREEN');
Eyelink('Message', '!V CLEAR %d %d %d', bgc(1), bgc(2), bgc(3));
Eyelink('Message', '!V TRIAL_VAR iteration %d', sessionState.currentTrial);
Eyelink('Message', '!V TRIAL_VAR motionCoh %f', trialCtx.trialData.motionCoh);
Eyelink('Message', '!V TRIAL_VAR motionDir %d', trialCtx.trialData.motionDir);
Eyelink('Message', '!V TRIAL_VAR colorCoh %f', trialCtx.trialData.colorCoh);
Eyelink('Message', '!V TRIAL_VAR colorDir %d', trialCtx.trialData.colorDir);
Eyelink('Message', '!V TRIAL_VAR correct %d', trialCtx.trialData.correct);
Eyelink('Message', 'TRIAL_RESULT 0');

%% Blank screen for ITI
for numFrames = 1:round(cfg.timing.ITI / frameSpecs.ifi) - 2
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);

    % Check ESCAPE during ITI
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(cfg.keyBoard.escapeKey)
        trialCtx.escapePressed = true;
    end
end

%% Store trial data
sessionState.trialData{sessionState.currentTrial} = trialCtx.trialData;

%% Store dot movie (positions + colors for all frames shown)
sessionState.dotMovies{sessionState.currentTrial}.dotPos      = trialCtx.dotPos(:, :, 1:trialCtx.trialData.framesShown);
sessionState.dotMovies{sessionState.currentTrial}.framesShown = trialCtx.trialData.framesShown;

%% Advance trial counter
sessionState.currentTrial = sessionState.currentTrial + 1;

%% Decide next state
if trialCtx.escapePressed
    nextState = 'PAUSE';
else
    nextState = 'TRIAL_SETUP';
end

end
