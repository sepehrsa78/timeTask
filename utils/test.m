PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 3);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
Screen('Preference', 'DefaultTextYPositionIsBaseline', 1);

%%
monitorWidth    = 311;                                                      % in milimeters
monitorDistance = 270;                                                      % in milimeters

delayRange    = [.250 .850];
shortRange    = [.494 .847];
interRange    = [.671 1.023];
longRange     = [.847 1.200];

nBlock   = 1;
numTrls = 500;

delay   = [];
siShort = [];
siInter = [];
siLong  = [];

tpd = expDist(1, 2000, delayRange(1), delayRange(2));

for timB = 1:nBlock
    delay{timB}  = random(tpd, numTrls);
    for timT = 1:numTrls
        siShort(timB, timT)  = shortRange(1)  + (shortRange(2) - shortRange(1)) * rand(1, 1);
        siInter(timB, timT)  = interRange(1)  + (interRange(2) - interRange(1)) * rand(1, 1);
        siLong(timB, timT)  = longRange(1)  + (longRange(2) - longRange(1)) * rand(1, 1);
    end
end

screenNumber    = 0;
resolution      = Screen('Resolution', screenNumber);
screenWidth     = resolution.width;
screenHeight    = resolution.height;
pixelDepth      = resolution.pixelSize;
screenHz        = resolution.hz;
nScreenBuffers  = 2;

durations.fixation          = 1;
durations.delay             = delay;
durations.siShort           = siShort;
durations.siInter           = siInter;
durations.siLong            = siLong;
durations.set2goBase        = .050;
dims.fix                    = .5;
dims.cues                   = 1.5;
dims.go                     = 5;
dims.distRange              = [7.5 12.5];
dims.angParams              = [monitorDistance, monitorWidth / screenWidth];
penWidthPixels              = 5;



[window, windowRect] = PsychImaging(...
    'OpenWindow', ...
    screenNumber, ...`
    [127 127 127] / 255, ...
    floor([0, 0, screenWidth, screenHeight] / 1), ...
    pixelDepth, ...
    nScreenBuffers, ...
    [], ...
    [], ...
    kPsychNeed32BPCFloat...
    );

ifi                = Screen('GetFlipInterval', window);
waitframes         = 1;
textcolor          = BlackIndex(window);
Screen('TextSize', window, 24);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
SetMouse(0, 0);

topPriorityLevel    = MaxPriority(window);
[xCenter, yCenter]  = RectCenter(windowRect);

distWarn = ang2pix(abs(dims.distRange(1) + (dims.distRange(2) - dims.distRange(1)) * randn(1, 1)), ...
    dims.angParams(1), dims.angParams(2));
distGo   = ang2pix(dims.go, dims.angParams(1), dims.angParams(2));

dotColor = white; 
fixDiameter = ang2pix(dims.fix, dims.angParams(1), dims.angParams(2));
cueDiameter = ang2pix(dims.cues, dims.angParams(1), dims.angParams(2));


fixRect  = [...
    xCenter - fixDiameter / 2, yCenter - fixDiameter / 2,...
    xCenter + fixDiameter / 2, yCenter + fixDiameter / 2];
warnRect = [...
    xCenter - cueDiameter / 2 - distWarn, yCenter - cueDiameter / 2,...
    xCenter + cueDiameter / 2 - distWarn, yCenter + cueDiameter / 2];
setRect  = [...
    xCenter - cueDiameter / 2 + distWarn, yCenter - cueDiameter / 2,...
    xCenter + cueDiameter / 2 + distWarn, yCenter + cueDiameter / 2];
goRect   = [...
    xCenter - cueDiameter / 2, yCenter - cueDiameter / 2 - distGo,...
    xCenter + cueDiameter / 2, yCenter + cueDiameter / 2 - distGo];


Screen('FillOval', window, [1 1 1], fixRect);
Screen('FillOval', window, [1 1 1], warnRect);
Screen('FillOval', window, [1 1 1], setRect);
Screen('FillOval', window, [1 1 1], goRect);
Screen('Flip', window);

WaitSecs(5);

sca