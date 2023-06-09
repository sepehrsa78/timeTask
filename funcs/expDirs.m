function [block] = expDirs(frameSpecs, window, xCenter,...
    yCenter, block, iBlock, iTrial, timer)

lineOS = block(iBlock).trialSet(iTrial).lineSpecs;

distSet      = ang2pix(block(iBlock).trialSet(iTrial).distInterval, dists.angParams(1), dists.angParams(2));
[xTar, yTar] = pointOnLine(lineOS, block(iBlock).trialSet(iTrial).distInterval, dists, diams);

fixDiameter         = ang2pix(diams.fix, dists.angParams(1), dists.angParams(2));
setDiameter         = ang2pix(diams.set, dists.angParams(1), dists.angParams(2));
targetDiameter      = ang2pix(diams.target, dists.angParams(1), dists.angParams(2));
fixMarginRadius     = ang2pix(rads.fixMargin, dists.angParams(1), dists.angParams(2));
timeMarginRadius    = ang2pix(rads.timeMargin, dists.angParams(1), dists.angParams(2));
spaceMarginRadius   = ang2pix(rads.spaceMargin, dists.angParams(1), dists.angParams(2));
spaceFeedRadius     = ang2pix(rads.spaceFeed, dists.angParams(1), dists.angParams(2));
pointerMarginRadius = ang2pix(.1, dists.angParams(1), dists.angParams(2));

if strcmp(block(iBlock).trialSet(iTrial).flashLoc, 'right')
    coef = -1;
    leftP  = xCenter - coef * (fixDiameter / 2 + distSet);
    rightP = xCenter - coef * (fixDiameter / 2 + distSet + setDiameter);
else
    coef   = 1;
    leftP  = xCenter - coef * (fixDiameter / 2 + distSet + setDiameter);
    rightP = xCenter - coef * (fixDiameter / 2 + distSet);
end

fixLines = [...
    xCenter - (fixDiameter / 2), xCenter + (fixDiameter / 2), xCenter, xCenter;...
    yCenter, yCenter, yCenter - (fixDiameter / 2), yCenter + (fixDiameter / 2)];
setRect         = [...
    leftP , yCenter - abs(setDiameter / 2),...
    rightP, yCenter + abs(setDiameter / 2)];
targetRect      = [...
    xTar - (targetDiameter / 2), yTar - (targetDiameter / 2),...
    xTar + (targetDiameter / 2), yTar + (targetDiameter / 2)];
fixMarginRect   = [...
    xCenter - fixMarginRadius, yCenter - fixMarginRadius,...
    xCenter + fixMarginRadius, yCenter + fixMarginRadius];
checkRect   = [...
    xCenter - distSet - fixDiameter / 2, yCenter - distSet - fixDiameter / 2,...
    xCenter + distSet + fixDiameter / 2, yCenter + distSet + fixDiameter / 2];
abortRect   = [...
    xCenter - fixDiameter / 2, yCenter - fixDiameter / 2,...
    xCenter + fixDiameter / 2, yCenter + fixDiameter / 2];
timeMarginRect  = [...
    xTar - timeMarginRadius, yTar - timeMarginRadius,...
    xTar + timeMarginRadius, yTar + timeMarginRadius];

vbl = Screen('Flip', window);

for numFrames = 1:round(durations.fixation / frameSpecs.ifi)
    %     Screen('FrameOval', window, [1 0 0], checkRect);
    Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).fixOn)
        block(iBlock).trialSet(iTrial).fixOn = vbl - timer;
        Eyelink('Message', 'Fix On');
    end
end

for numFrames = 1:round(block(iBlock).trialSet(iTrial).delay / frameSpecs.ifi)
    Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
    Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
    %     Screen('FrameOval', window, [1 0 0], checkRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).lineOn)
        block(iBlock).trialSet(iTrial).lineOn = vbl - timer;
        block(iBlock).trialSet(iTrial).fixOff = vbl - timer;
        Eyelink('Message', 'Line On');
    end
end

for numFrames = 1:round(1)
    Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
    Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
    Screen('FillOval', window, colors.circles, setRect);
    %     Screen('FrameOval', window, [1 0 0], checkRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).setOn)
        block(iBlock).trialSet(iTrial).lineOff = vbl - timer;
        block(iBlock).trialSet(iTrial).setOn   = vbl - timer;
        Eyelink('Message', 'Set On');
    end
end

for numFrames = 1:round(block(iBlock).trialSet(iTrial).timeInterval / frameSpecs.ifi)
    Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
    Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
    %     Screen('FrameOval', window, [1 0 0], checkRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).setOff)
        block(iBlock).trialSet(iTrial).setOff = vbl - timer;
    end
end

switch block(iBlock).trialSet(iTrial).blockType
    case 'time'
        
        Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
        Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
        Screen('FillOval', window, colors.circles, targetRect);
        %         Screen('FrameOval', window, [1 0 0], checkRect);
        %         Screen('FrameOval', window, [1 0 0], timeMarginRect);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        block(iBlock).trialSet(iTrial).tarOn = vbl - timer;
        Eyelink('Message', 'Target On');
        
        flags.isHit    = false;
        flags.eyeFixed = false;
        flags.inFix    = true;
        flags.break    = false;
        
        [block, flags, tFixBreak, tSampl] = timeSaccade(...
            block, iBlock, iTrial, window, flags, frameSpecs,...
    abortRect, fixMarginRect, timeMarginRect, pointerMarginRadius,...
    vbl, timer, lineOS, fixLines);
        
        if flags.isHit && flags.eyeFixed
            block(iBlock).trialSet(iTrial).saccadeOn     = tFixBreak - timer;
            block(iBlock).trialSet(iTrial).saccadeInRect = tSampl - timer;
            block(iBlock).trialSet(iTrial).RT            = tFixBreak - vbl;
            for numFrames = 1:round(durations.feedB / frameSpecs.ifi)
                Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
                Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
                Screen('FillOval', window, colors.go, targetRect);
                vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
                if numFrames == 1
                    block(iBlock).trialSet(iTrial).feedBackOn = vbl - timer;
                    Eyelink('Message', 'Success Feedback On');
                end
            end
            vbl = Screen('Flip', window);
            block(iBlock).trialSet(iTrial).feedBackOff = vbl - timer;
            Eyelink('Message', 'Success Feedback Off');
        else
            Screen('FillOval', window, colors.abort, abortRect);
            for numFrames = 1:round(durations.feedB / frameSpecs.ifi)
                Screen('FillOval', window, colors.abort, abortRect);
                vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
                if numFrames == 1
                    block(iBlock).trialSet(iTrial).feedBackOn = vbl - timer;
                    Eyelink('Message', 'Abort Feedback On');
                end
            end
            vbl = Screen('Flip', window);
            block(iBlock).trialSet(iTrial).feedBackOff = vbl - timer;
            Eyelink('Message', 'Abort Feedback Off');
        end
    case 'space'
        
        Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
        Screen('DrawLines', window, fixLines, diams.fixWidth, colors.go);
        %         Screen('FrameOval', window, [1 0 0], checkRect);
        %         Screen('FrameOval', window, [1 0 0], fixMarginRect);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        block(iBlock).trialSet(iTrial).tarOn = vbl - timer;
        Eyelink('Message', 'Target On');
        greenOn = vbl;
        
        flags.isOnLine = false;
        flags.eyeFixed = false;
        flags.inFix    = true;
        flags.break    = false;
        
        
        [block, flags, tFixBreak, tSampl, xSacc, ySacc, dist2cent, dist2line] = spaceSaccade(...
            block, iBlock, iTrial, window, flags, frameSpecs,...
            abortRect, fixMarginRect, spaceMarginRadius, pointerMarginRadius,...
            xCenter, yCenter, lineOS, colors, vbl, timer, fixLines);
        
        if flags.isOnLine && flags.eyeFixed
            block(iBlock).trialSet(iTrial).saccadeOn     = tFixBreak - timer;
            block(iBlock).trialSet(iTrial).saccadeInRect = tSampl - timer;
            block(iBlock).trialSet(iTrial).RT            = tFixBreak - greenOn;
            block(iBlock).trialSet(iTrial).prodDist      = [dist2cent, dist2line, xSacc, ySacc];
            
            spaceFeedRect = [...
                xSacc - spaceFeedRadius, ySacc - spaceFeedRadius,...
                xSacc + spaceFeedRadius, ySacc + spaceFeedRadius];
            
            for numFrames = 1:round(durations.feedB / frameSpecs.ifi)
                Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
                Screen('DrawLines', window, fixLines, diams.fixWidth, colors.go);
                Screen('FillOval', window, colors.go, spaceFeedRect);
                vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
                if numFrames == 1
                    block(iBlock).trialSet(iTrial).feedBackOn = vbl - timer;
                    Eyelink('Message', 'Success Feedback On');
                end
            end
            vbl = Screen('Flip', window);
            block(iBlock).trialSet(iTrial).feedBackOff = vbl - timer;
            Eyelink('Message', 'Success Feedback Off');
        else
            Screen('FillOval', window, colors.abort, abortRect);
            for numFrames = 1:round(durations.feedB / frameSpecs.ifi)
                Screen('FillOval', window, colors.abort, abortRect);
                vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
                if numFrames == 1
                    block(iBlock).trialSet(iTrial).feedBackOn = vbl - timer;
                    Eyelink('Message', 'Abort Feedback On');
                end
            end
            vbl = Screen('Flip', window);
            block(iBlock).trialSet(iTrial).feedBackOff = vbl - timer;
            Eyelink('Message', 'Abort Feedback Off');
        end
end
end
