function [block, flags, tFixBreak, tSampl, xSacc, ySacc, dist2cent] = spaceSaccade(block, iBlock, iTrial, window, flags, frameSpecs, durations, rads, dists,...
    abortRect, fixMarginRect, spaceMarginRadius, pointerMarginRadius, xCenter, yCenter, lineOS, colors, vbl, timer, diams, fixLines)

while ~flags.break
    while flags.inFix
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown && keyCode(KbName('ESCAPE'))
            sca;
            ListenChar(0);
            Eyelink('StopRecording')
            break
        end
        tmp = Eyelink('NewestFloatSample');
        xFix = tmp.gx(1);
        yFix = tmp.gy(1);
        %         [xFix, yFix] = GetMouse();
        %         pointMarginRect = [...
        %             xFix - pointerMarginRadius, yFix - pointerMarginRadius,...
        %             xFix + pointerMarginRadius, yFix + pointerMarginRadius];
        %         Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
        %         Screen('DrawLines', window, fixLines, diams.fixWidth, colors.go);
        %         Screen('FillOval', window, colors.go, pointMarginRect);
        %         Screen('FrameOval', window, [1 0 0], checkRect);
        %         Screen('FrameOval', window, [1 0 0], fixMarginRect);
        %         vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        if ~IsInRect(xFix, yFix, fixMarginRect)
            tFixBreak   = GetSecs();
            Eyelink('Message', 'Saccade On');
            flags.inFix = false;
            break
        end
    end

    WaitSecs(durations.saccAcc);

    tmp    = Eyelink('NewestFloatSample');
    %     [xSacc, ySacc] = GetMouse();
    tSampl = GetSecs();
    xSacc  = tmp.gx(1);
    ySacc  = tmp.gy(1);
    [flags.isOnLine, dist2cent] = marginalDistance([xCenter, yCenter], [xSacc, ySacc], lineOS, rads.spaceMargin, dists);
    if flags.isOnLine
        Eyelink('Message', 'Saccade In Rect');
        spaceMarginRect = [...
            xSacc - spaceMarginRadius, ySacc - spaceMarginRadius,...
            xSacc + spaceMarginRadius, ySacc + spaceMarginRadius];
        while GetSecs() - tSampl < durations.tFixed
            tmpS   = Eyelink('NewestFloatSample');
            xTmp   = tmpS.gx(1);
            yTmp   = tmpS.gy(1);
%             [xTmp, yTmp] = GetMouse();
            if IsInRect(xTmp, yTmp, spaceMarginRect)
                flags.eyeFixed = true;
                flags.break    = true;
            else
                flags.eyeFixed = false;
                flags.break    = true;
                break
            end
        end
    else
        flags.break = true;
        break
    end
end
end
