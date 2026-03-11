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

%% Store dots_struct (matching rig_files format)
dots_struct.aperture        = cfg.dots.aperture;
dots_struct.direction       = trialCtx.trialParams.motionDir;
dots_struct.coherence       = trialCtx.trialParams.motionCoh;
dots_struct.speed           = cfg.dots.speed;
dots_struct.density         = cfg.dots.density;
dots_struct.dot_size        = cfg.dots.dotSize;
dots_struct.col_dir         = trialCtx.trialParams.colorDir;
dots_struct.col_coh         = trialCtx.trialParams.colorCoh;
dots_struct.interval        = cfg.dots.interval;
dots_struct.show_color1_first = trialCtx.drawColor1First;
dots_struct.shown_frames    = trialCtx.trialData.framesShown;
dots_struct.dot_pos         = trialCtx.dotPos(:, :, 1:trialCtx.trialData.framesShown);
sessionState.save_struct{sessionState.currentTrial}.dots_struct = dots_struct;

%% Advance trial counter
sessionState.currentTrial = sessionState.currentTrial + 1;

%% Decide next state
if trialCtx.escapePressed
    nextState = 'PAUSE';
else
    nextState = 'TRIAL_SETUP';
end

end
