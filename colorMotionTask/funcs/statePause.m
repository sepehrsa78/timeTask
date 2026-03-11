function [nextState, sessionState] = statePause(cfg, sessionState, window, el, width, height, backColor, subjectDir)
% statePause  Pause menu: Resume, Recalibrate, or Save & Quit.
%
%   [nextState, sessionState] = statePause(cfg, sessionState, window, el, width, height, backColor, subjectDir)
%
%   Displays a pause menu and waits for the experimenter's choice.

% Save progress before showing menu
saveProgress(sessionState, subjectDir);

% Display pause menu
menuText = sprintf(['PAUSED\n\n' ...
    'Trial %d / %d completed\n\n' ...
    '1 - Resume\n' ...
    '2 - Recalibrate EyeLink\n' ...
    '3 - Save & Quit\n'], ...
    sessionState.currentTrial - 1, length(sessionState.trialList));

screenNumber = max(Screen('Screens'));
Screen('TextSize', window, 28);
DrawFormattedText(window, menuText, 'center', 'center', BlackIndex(screenNumber) / 2);
Screen('Flip', window);

% Wait for valid keypress
key1 = KbName('1!');
key2 = KbName('2@');
key3 = KbName('3#');

while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(key1)
            % Resume
            KbReleaseWait;
            Screen('Flip', window);
            nextState = 'TRIAL_SETUP';
            return
        elseif keyCode(key2)
            % Recalibrate
            KbReleaseWait;
            Eyelink('StopRecording');
            eyeCalib(window, width, height, backColor);
            Eyelink('StartRecording');
            WaitSecs(0.010);
            Screen('Flip', window);
            nextState = 'TRIAL_SETUP';
            return
        elseif keyCode(key3)
            % Save & Quit
            KbReleaseWait;
            saveProgress(sessionState, subjectDir);
            nextState = 'FINISH';
            return
        end
    end
    WaitSecs(0.01);
end

end
