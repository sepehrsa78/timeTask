function [flags, tFixBreak, tSampl] = timeSaccade(...
    taskSettings, flags, rects)

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
    Eyelink('Message', 'Saccade In Rect');
    xSacc  = tmp.gx(1);
    ySacc  = tmp.gy(1);
    
    flags.isHit  = IsInRect(xSacc, ySacc, rects.timeMarginRect);
    if ~flags.isHit
        flags.break = true;
        break
    end
    
    if ~flags.break
        while GetSecs() - tSampl < taskSettings.durations.tFixed
            tmpS   = Eyelink('NewestFloatSample');
            xTmp   = tmpS.gx(1);
            yTmp   = tmpS.gy(1);
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
