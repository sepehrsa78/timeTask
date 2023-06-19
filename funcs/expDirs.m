function [block] = expDirs(taskSettings, frameSpecs, window, xCenter,...
    yCenter, block, iBlock, iTrial, timer)

rects.lineOS = block(iBlock).trialSet(iTrial).lineSpecs;

distSet      = ang2pix(block(iBlock).trialSet(iTrial).distInterval, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
[xTar, yTar] = pointOnLine(rects.lineOS, block(iBlock).trialSet(iTrial).distInterval, taskSettings);

fixDiameter         = ang2pix(taskSettings.diams.fix, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
setDiameter         = ang2pix(taskSettings.diams.set, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
targetDiameter      = ang2pix(taskSettings.diams.target, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
fixMarginRadius     = ang2pix(taskSettings.rads.fixMargin, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
timeMarginRadius    = ang2pix(taskSettings.rads.timeMargin, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
spaceMarginRadius   = ang2pix(taskSettings.rads.spaceMargin, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));
spaceFeedRadius     = ang2pix(taskSettings.rads.spaceFeed, taskSettings.dists.angParams(1), taskSettings.dists.angParams(2));

if strcmp(block(iBlock).trialSet(iTrial).flashLoc, 'right')
    coef = -1;
    leftP  = xCenter - coef * (fixDiameter / 2 + distSet);
    rightP = xCenter - coef * (fixDiameter / 2 + distSet + setDiameter);
else
    coef   = 1;
    leftP  = xCenter - coef * (fixDiameter / 2 + distSet + setDiameter);
    rightP = xCenter - coef * (fixDiameter / 2 + distSet);
end

rects.fixLines = [...
    xCenter - (fixDiameter / 2), xCenter + (fixDiameter / 2), xCenter, xCenter;...
    yCenter, yCenter, yCenter - (fixDiameter / 2), yCenter + (fixDiameter / 2)];
rects.setRect         = [...
    leftP , yCenter - abs(setDiameter / 2),...
    rightP, yCenter + abs(setDiameter / 2)];
rects.targetRect      = [...
    xTar - (targetDiameter / 2), yTar - (targetDiameter / 2),...
    xTar + (targetDiameter / 2), yTar + (targetDiameter / 2)];
rects.abortRect   = [...
    xCenter - spaceFeedRadius, yCenter - spaceFeedRadius,...
    xCenter + spaceFeedRadius, yCenter + spaceFeedRadius];
rects.fixMarginRect   = [...
    xCenter - fixMarginRadius, yCenter - fixMarginRadius,...
    xCenter + fixMarginRadius, yCenter + fixMarginRadius];
rects.timeMarginRect  = [...
    xTar - timeMarginRadius, yTar - timeMarginRadius,...
    xTar + timeMarginRadius, yTar + timeMarginRadius];
rects.checkRect   = [...
    xCenter - distSet - fixDiameter / 2, yCenter - distSet - fixDiameter / 2,...
    xCenter + distSet + fixDiameter / 2, yCenter + distSet + fixDiameter / 2];

vbl = Screen('Flip', window);
for numFrames = 1:round(taskSettings.durations.fixation / frameSpecs.ifi)
    Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).fixOn)
        block(iBlock).trialSet(iTrial).fixOn = vbl - timer;
        Eyelink('Message', 'Fix On');
    end
end

for numFrames = 1:round(block(iBlock).trialSet(iTrial).delay / frameSpecs.ifi)
    Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
    Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).lineOn)
        block(iBlock).trialSet(iTrial).lineOn = vbl - timer;
        block(iBlock).trialSet(iTrial).fixOff = vbl - timer;
        Eyelink('Message', 'Line On');
    end
end

for numFrames = 1:round(1)
    Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
    Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
    Screen('FillOval', window, taskSettings.colors.circles, rects.setRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).setOn)
        block(iBlock).trialSet(iTrial).lineOff = vbl - timer;
        block(iBlock).trialSet(iTrial).setOn   = vbl - timer;
        Eyelink('Message', 'Set On');
    end
end

for numFrames = 1:round(block(iBlock).trialSet(iTrial).timeInterval / frameSpecs.ifi)
    Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
    Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).setOff)
        block(iBlock).trialSet(iTrial).setOff = vbl - timer;
        Eyelink('Message', 'Set Off');
    end
end

switch block(iBlock).trialSet(iTrial).blockType
    case 'time'
        
        Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
        Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
        Screen('FillOval', window, taskSettings.colors.circles, rects.targetRect);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        block(iBlock).trialSet(iTrial).tarOn = vbl - timer;
        Eyelink('Message', 'Target On');
        
        flags.isHit    = false;
        flags.eyeFixed = false;
        flags.inFix    = true;
        flags.break    = false;
        
        [flags, tFixBreak, tSampl] = timeSaccade(taskSettings, flags, rects);
        block(iBlock).trialSet(iTrial).saccadeOn     = tFixBreak - timer;
        block(iBlock).trialSet(iTrial).saccadeInRect = tSampl - timer;
        
        if flags.isHit && flags.eyeFixed
            block(iBlock).trialSet(iTrial).RT            = tFixBreak - vbl;
            for numFrames = 1:round(taskSettings.durations.feedB / frameSpecs.ifi)
                Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
                Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
                Screen('FillOval', window, taskSettings.colors.go, rects.targetRect);
                
                if numFrames == 1
                    vbl = Screen('Flip', window);
                    block(iBlock).trialSet(iTrial).feedBackOn = vbl - timer;
                    Eyelink('Message', 'Success Feedback On');
                else
                    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
                end
            end
            vbl = Screen('Flip', window);
            block(iBlock).trialSet(iTrial).feedBackOff = vbl - timer;
            Eyelink('Message', 'Success Feedback Off');
        else
            Screen('FillOval', window, taskSettings.colors.abort, rects.abortRect);
            for numFrames = 1:round(taskSettings.durations.feedB / frameSpecs.ifi)
                Screen('FillOval', window, taskSettings.colors.abort, rects.abortRect);
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
        
        Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
        Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.go);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        block(iBlock).trialSet(iTrial).tarOn = vbl - timer;
        Eyelink('Message', 'Target On');
        greenOn = vbl;
        
        flags.isOnLine = false;
        flags.eyeFixed = false;
        flags.inFix    = true;
        flags.break    = false; 
        
        [flags, tFixBreak, tSampl, xSacc, ySacc, dist2cent, dist2line] = spaceSaccade(...
            taskSettings, flags, rects, spaceMarginRadius);
        block(iBlock).trialSet(iTrial).saccadeOn     = tFixBreak - timer;
        block(iBlock).trialSet(iTrial).saccadeInRect = tSampl - timer;
        
        if flags.isOnLine && flags.eyeFixed
            block(iBlock).trialSet(iTrial).RT            = tFixBreak - greenOn;
            block(iBlock).trialSet(iTrial).prodDist      = [dist2cent, dist2line, xSacc, ySacc];
            
            rects.spaceFeedRect = [...
                xSacc - spaceFeedRadius, ySacc - spaceFeedRadius,...
                xSacc + spaceFeedRadius, ySacc + spaceFeedRadius];
            
            for numFrames = 1:round(taskSettings.durations.feedB / frameSpecs.ifi)
                Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
                Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.go);
                Screen('FillOval', window, taskSettings.colors.go, rects.spaceFeedRect);
                if numFrames == 1
                    vbl = Screen('Flip', window);
                    block(iBlock).trialSet(iTrial).feedBackOn = vbl - timer;
                    Eyelink('Message', 'Success Feedback On');
                else
                    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
                end
            end
            vbl = Screen('Flip', window);
            block(iBlock).trialSet(iTrial).feedBackOff = vbl - timer;
            Eyelink('Message', 'Success Feedback Off');
        else
            Screen('FillOval', window, taskSettings.colors.abort, rects.abortRect);
            for numFrames = 1:round(taskSettings.durations.feedB / frameSpecs.ifi)
                Screen('FillOval', window, taskSettings.colors.abort, rects.abortRect);
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
