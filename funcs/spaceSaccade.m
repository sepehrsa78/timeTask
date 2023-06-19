function [flags, tFixBreak, tSampl, xSacc, ySacc, dist2cent, dist2line] = spaceSaccade(...
    taskSettings, flags, rects, spaceMarginRadius)

while ~flags.break
    while flags.inFix
        tmp         = Eyelink('NewestFloatSample');
        tFixBreak   = GetSecs();
        xFix        = tmp.gx(1);
        yFix        = tmp.gy(1);
        flags.inFix = IsInRect(xFix, yFix, rects.fixMarginRect);
        if ~flags.inFix
            Eyelink('Message', 'Saccade On');
            break
        end
    end
    
    WaitSecs(taskSettings.durations.saccAcc);
    
    tmp    = Eyelink('NewestFloatSample');  
    tSampl = GetSecs();
    Eyelink('Message', 'Saccade On Line');
    xSacc  = tmp.gx(1);
    ySacc  = tmp.gy(1);
    
    [flags.isOnLine, dist2cent, dist2line] = marginalDistance(taskSettings, [xSacc, ySacc], rects);
    if flags.isOnLine
        rects.spaceMarginRect = [...
            xSacc - spaceMarginRadius, ySacc - spaceMarginRadius,...
            xSacc + spaceMarginRadius, ySacc + spaceMarginRadius];
        while GetSecs() - tSampl < taskSettings.durations.tFixed
            tmpS   = Eyelink('NewestFloatSample');
            xTmp   = tmpS.gx(1);
            yTmp   = tmpS.gy(1);
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
