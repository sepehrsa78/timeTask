function [block] = expDirs(frameSpecs, colors, diams, durations, dists, window, xCenter, yCenter, block, iBlock, iTrial, timer)

line = block(iBlock).trialSet(iTrial).lineSpecs;

distSet      = ang2pix(block(iBlock).trialSet(iTrial).distInterval, dists.angParams(1), dists.angParams(2));
[xTar, yTar] = pointOnLine(line, dists.targetPoint, dists);

fixDiameter    = ang2pix(diams.fix, dists.angParams(1), dists.angParams(2));
setDiameter    = ang2pix(diams.set, dists.angParams(1), dists.angParams(2));
targetDiameter = ang2pix(diams.target, dists.angParams(1), dists.angParams(2));

fixRect    = [...
    xCenter - fixDiameter / 2, yCenter - fixDiameter / 2,...
    xCenter + fixDiameter / 2, yCenter + fixDiameter / 2];
setRect    = [...
    xCenter - setDiameter / 2 - distSet, yCenter - setDiameter / 2,...
    xCenter + setDiameter / 2 - distSet, yCenter + setDiameter / 2];
targetRect = [...
    xTar - targetDiameter / 2, yTar - targetDiameter / 2,...
    xTar + targetDiameter / 2, yTar + targetDiameter / 2];

vbl = Screen('Flip', window);
for numFrames = 1:round(durations.fixation / frameSpecs.ifi)
    Screen('FillOval', window, colors.fix, fixRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).fixOn)
        block(iBlock).trialSet(iTrial).fixOn = vbl - timer;
    end
end

for numFrames = 1:round(block(iBlock).trialSet(iTrial).delay / frameSpecs.ifi)
    Screen('DrawLines', window, line, diams.lineWidth, colors.line);
    Screen('FillOval', window, colors.fix, fixRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).lineOn)
        block(iBlock).trialSet(iTrial).lineOn = vbl - timer;
    end
end

for numFrames = 1:round(0.010 / frameSpecs.ifi)
    Screen('DrawLines', window, line, diams.lineWidth, colors.line);
    Screen('FillOval', window, colors.fix, fixRect);
    Screen('FillOval', window, colors.circles, setRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    if isempty(block(iBlock).trialSet(iTrial).setOn)
        block(iBlock).trialSet(iTrial).setOn = vbl - timer;
    end
end

for numFrames = 1:round(block(iBlock).trialSet(iTrial).timeInterval / frameSpecs.ifi)
    Screen('DrawLines', window, line, diams.lineWidth, colors.line);
    Screen('FillOval', window, colors.fix, fixRect);
    vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
end

switch block(iBlock).trialSet(iTrial).blockType
    case 'time'

        Screen('DrawLines', window, line, diams.lineWidth, colors.line);
        Screen('FillOval', window, colors.fix, fixRect);
        Screen('FillOval', window, colors.circles, targetRect);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        block(iBlock).trialSet(iTrial).tarOn = vbl - timer;

        isHit = false;
        [x, y] = RectCenterd(targetRect);
        while ~isHit
            [keyIsDown, ~, keyCode] = KbCheck();
            if keyIsDown && keyCode(KbName('ESCAPE'))
                sca;
                break
            end
            [xSacc, ySacc] = GetMouse();
            isHit = targetHit([x, y], [xSacc, ySacc], diams.margin, dists);
            if isHit
                block(iBlock).trialSet(iTrial).RT = GetSecs() - vbl;
                vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
            end
        end

    case 'space'
        
        isWithinLine = false;
        while ~isWithinLine
            [keyIsDown, ~, keyCode] = KbCheck();
            if keyIsDown && keyCode(KbName('ESCAPE'))
                sca;
                break
            end
            [xSacc, ySacc] = GetMouse();
            pointer = [...
                xSacc - targetDiameter / 2, ySacc - targetDiameter / 2,...
                xSacc + targetDiameter / 2, ySacc + targetDiameter / 2];
            isWithinLine = marginalDistance([xSacc, ySacc], line, diams.margin, dists);
            if isWithinLine
                block(iBlock).trialSet(iTrial).RT = GetSecs() - vbl;
                vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
            end
        end

end


end