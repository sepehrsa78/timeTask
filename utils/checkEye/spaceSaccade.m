function [flags, tFixBreak, tSampl, xSacc, ySacc, dist2cent, dist2line] = spaceSaccade(taskSettings, window, flags, frameSpecs,...
    rects, spaceMarginRadius, pointerMarginRadius, xCenter, yCenter, vbl, timer)

while ~flags.break
    while flags.inFix
        %         tmp = Eyelink('NewestFloatSample');
        %         xFix = tmp.gx(1);
        %         yFix = tmp.gy(1);
        [xFix, yFix] = GetMouse();
        %         rects.pointMarginRect = [...
        %             xFix - pointerMarginRadius, yFix - pointerMarginRadius,...
        %             xFix + pointerMarginRadius, yFix + pointerMarginRadius];
        %         Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
        %         Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.go);
        %         Screen('FillOval', window, taskSettings.colors.go, rects.pointMarginRect);
        %         Screen('FrameOval', window, [1 0 0], rects.checkRect);
        %         Screen('FrameOval', window, [1 0 0], rects.fixMarginRect);
        %         vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        if ~IsInRect(xFix, yFix, rects.fixMarginRect) && IsInRect(xFix, yFix, taskSettings.windowRect)
            tFixBreak   = GetSecs();
            %             Eyelink('Message', 'Saccade On');
            flags.inFix = false;
            break
        end
    end

    for numFrames = 1:round(taskSettings.durations.saccAcc / frameSpecs.ifi)
        Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
        Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.go);
        %     Screen('FrameOval', window, [1 0 0], checkRect);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    end

    %     tmp    = Eyelink('NewestFloatSample');
    [xSacc, ySacc] = GetMouse();
    %         Eyelink('Message', 'Saccade In Rect');
    tSampl = GetSecs();
    %     xSacc  = tmp.gx(1);
    %     ySacc  = tmp.gy(1);
    [flags.isOnLine, dist2cent, dist2line] = marginalDistance(taskSettings, [xCenter, yCenter], [xSacc, ySacc], rects);
    if flags.isOnLine
        rects.spaceMarginRect = [...
            xSacc - spaceMarginRadius, ySacc - spaceMarginRadius,...
            xSacc + spaceMarginRadius, ySacc + spaceMarginRadius];
        while GetSecs() - tSampl < taskSettings.durations.tFixed
            %             tmpS   = Eyelink('NewestFloatSample');
            %             xTmp   = tmpS.gx(1);
            %             yTmp   = tmpS.gy(1);
            [xTmp, yTmp] = GetMouse();
            if IsInRect(xTmp, yTmp, rects.spaceMarginRect)
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
