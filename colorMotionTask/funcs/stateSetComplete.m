function [nextState, sessionState] = stateSetComplete(cfg, sessionState, window)
% stateSetComplete  Prompt experimenter after all trials in a set are done.
%
%   [nextState, sessionState] = stateSetComplete(cfg, sessionState, window)
%
%   Asks: "All trials complete. Run another set? [Y/N]"
%   Y -> regenerate trial list, reset counter, return TRIAL_SETUP
%   N -> return FINISH

nCompleted = length(sessionState.trialData);

promptText = sprintf(['All %d trials complete.\n\n' ...
    'Run another set?\n\n' ...
    'Y - Yes, run another set\n' ...
    'N - No, finish session\n'], nCompleted);

screenNumber = max(Screen('Screens'));
Screen('TextSize', window, 28);
DrawFormattedText(window, promptText, 'center', 'center', BlackIndex(screenNumber) / 2);
Screen('Flip', window);

keyY = KbName('y');
keyN = KbName('n');

while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(keyY)
            KbReleaseWait;

            % Increment set number
            if ~isfield(sessionState, 'setNumber')
                sessionState.setNumber = 1;
            end
            sessionState.setNumber = sessionState.setNumber + 1;

            % Determine if demo mode
            isDemo = false;
            if isfield(sessionState, 'sInfo') && length(sessionState.sInfo) >= 6
                isDemo = strcmp(sessionState.sInfo{6}, '1');
            end

            % Regenerate trial list
            sessionState.trialList    = buildTrialList(cfg, isDemo);
            sessionState.currentTrial = 1;

            Screen('Flip', window);
            nextState = 'TRIAL_SETUP';
            return

        elseif keyCode(keyN)
            KbReleaseWait;
            nextState = 'FINISH';
            return
        end
    end
    WaitSecs(0.01);
end

end
