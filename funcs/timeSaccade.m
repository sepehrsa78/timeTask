function [flags, tFixBreak, tSampl] = timeSaccade(...
    taskSettings, flags, rects)

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

    WaitSecs(taskSettings.durations.saccAcc);

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
