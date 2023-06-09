function [flags, tFixBreak, tSampl] = timeSaccade(taskSettings, window, flags, frameSpecs, rects, vbl)

while ~flags.break
    while flags.inFix
        %         tmp = Eyelink('NewestFloatSample');
        %         xFix = tmp.gx(1);
        %         yFix = tmp.gy(1);
        [xFix, yFix] = GetMouse();
        if ~IsInRect(xFix, yFix, rects.fixMarginRect) && IsInRect(xFix, yFix, taskSettings.windowRect)
            %             Eyelink('Message', 'Saccade On');
            tFixBreak   = GetSecs();
            flags.inFix = false;
            break
        end
    end

    for numFrames = 1:round(taskSettings.durations.saccAcc / frameSpecs.ifi)
        Screen('DrawLines', window, rects.lineOS, taskSettings.diams.lineWidth, taskSettings.colors.line);
        Screen('DrawLines', window, rects.fixLines, taskSettings.diams.fixWidth, taskSettings.colors.fix);
        Screen('FillOval', window, taskSettings.colors.circles, rects.targetRect);
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    end

    %         tmp    = Eyelink('NewestFloatSample');
    [xSacc, ySacc] = GetMouse();
    %             Eyelink('Message', 'Saccade In Rect');
    tSampl = GetSecs();
    flags.isHit  = IsInRect(xSacc, ySacc, rects.timeMarginRect);
    if ~flags.isHit
        flags.break = true;
        break
    end

    if ~flags.break
        while GetSecs() - tSampl < taskSettings.durations.tFixed
            %             tmpS   = Eyelink('NewestFloatSample');
            %             xTmp   = tmpS.gx(1);
            %             yTmp   = tmpS.gy(1);
            [xTmp, yTmp] = GetMouse();
            if IsInRect(xTmp, yTmp, rects.timeMarginRect)
                flags.eyeFixed = true;
                flags.break    = true;
            else
                flags.eyeFixed = false;
                flags.break    = true;
                break
            end
        end
    end
end
end
