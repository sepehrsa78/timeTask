function [nextState, trialCtx] = stateFeedback(cfg, trialCtx, window, frameSpecs)
% stateFeedback  Display trial feedback.
%
%   [nextState, trialCtx] = stateFeedback(cfg, trialCtx, window, frameSpecs)
%
%   Shows green feedback on the correct target for correct trials,
%   or yellow abort feedback at center for errors/timeouts.

vbl       = trialCtx.vbl;
fixLines  = trialCtx.rects.fixLines;
leftRect  = trialCtx.rects.leftRect;
rightRect = trialCtx.rects.rightRect;
abortRect = trialCtx.rects.abortRect;

if trialCtx.trialData.correct
    % Green feedback on the selected target
    if strcmp(trialCtx.trialData.response, 'left')
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
            trialCtx.trialData.feedbackOn = vbl;
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
            trialCtx.trialData.feedbackOn = vbl;
            Eyelink('Message', 'FEEDBACK_ON error');
        else
            vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        end
    end
end

vbl = Screen('Flip', window);
trialCtx.trialData.feedbackOff = vbl;
Eyelink('Message', 'FEEDBACK_OFF');

trialCtx.vbl = vbl;
nextState = 'ITI';

end
