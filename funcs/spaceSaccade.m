function [flags, tFixBreak, tSampl, xSacc, ySacc, dist2cent, dist2line] = spaceSaccade(taskSettings, flags,...
    rects, spaceMarginRadius)

while ~flags.break
    while flags.inFix
        %         tmp = Eyelink('NewestFloatSample');
        %         xFix = tmp.gx(1);
        %         yFix = tmp.gy(1);
        [xFix, yFix] = GetMouse();
        if ~IsInRect(xFix, yFix, rects.fixMarginRect) && IsInRect(xFix, yFix, taskSettings.windowRect)
            tFixBreak   = GetSecs();
            %             Eyelink('Message', 'Saccade On');
            flags.inFix = false;
            break
        end
    end

    WaitSecs(taskSettings.durations.saccAcc);

    %     tmp    = Eyelink('NewestFloatSample');
    [xSacc, ySacc] = GetMouse();
    %         Eyelink('Message', 'Saccade In Rect');
    tSampl = GetSecs();
    %     xSacc  = tmp.gx(1);
    %     ySacc  = tmp.gy(1);
    [flags.isOnLine, dist2cent, dist2line] = marginalDistance(taskSettings, [xSacc, ySacc], rects);
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
