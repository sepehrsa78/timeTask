function [block, flags, tFixBreak, tSampl] = timeSaccade(block, iBlock, iTrial, window, flags, frameSpecs, durations,...
    abortRect, fixMarginRect, timeMarginRect, pointerMarginRadius, colors, vbl, timer, diams, lineOS, fixLines)

while ~flags.break
    while flags.inFix
        %         [keyIsDown, ~, keyCode] = KbCheck();
        %         if keyIsDown && keyCode(KbName('ESCAPE'))
        %             sca;
        %             ListenChar(0);
        %             Eyelink('StopRecording')
        %             break
        %         end
        %         tmp = Eyelink('NewestFloatSample');
        %         xFix = tmp.gx(1);
        %         yFix = tmp.gy(1);
        [xFix, yFix] = GetMouse();
        if ~IsInRect(xFix, yFix, fixMarginRect)
            tFixBreak   = GetSecs();
            %             Eyelink('Message', 'Saccade On');
            flags.inFix = false;
            break
        end
    end

    while GetSecs() - tFixBreak < durations.saccAcc
        %         tmp    = Eyelink('NewestFloatSample');
        [xSacc, ySacc] = GetMouse();
        tSampl = GetSecs();
        %         xSacc  = tmp.gx(1);
        %         ySacc  = tmp.gy(1);
        %         pointMarginRect = [...
        %             xSacc - pointerMarginRadius, ySacc - pointerMarginRadius,...
        %             xSacc + pointerMarginRadius, ySacc + pointerMarginRadius];
        %         Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
        %         Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
        %         Screen('FillOval', window, colors.margin, pointMarginRect);
        %         vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
        flags.isHit  = IsInRect(xSacc, ySacc, timeMarginRect);
        if flags.isHit
            %             Eyelink('Message', 'Saccade In Rect');
            break
        end
    end

    if ~flags.isHit
        flags.break = true;
        break
    end

    if ~flags.break
        while GetSecs() - tSampl < durations.tFixed
            %             tmpS   = Eyelink('NewestFloatSample');
            %             xTmp   = tmpS.gx(1);
            %             yTmp   = tmpS.gy(1);
            [xTmp, yTmp] = GetMouse();
            %             pointMarginRect = [...
            %                 xTmp - pointerMarginRadius, yTmp - pointerMarginRadius,...
            %                 xTmp + pointerMarginRadius, yTmp + pointerMarginRadius];
            %             Screen('DrawLines', window, lineOS, diams.lineWidth, colors.line);
            %             Screen('DrawLines', window, fixLines, diams.fixWidth, colors.fix);
            %             Screen('FillOval', window, colors.margin, pointMarginRect);
            %             vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
            %             [xTmp, yTmp] = GetMouse();
            if IsInRect(xTmp, yTmp, timeMarginRect)
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
