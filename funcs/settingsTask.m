function taskSettings = settingsTask(delay, siShort, siInter, siLong, diShort, diInter, diLong, monitorDistance, monitorWidth, screenWidth, xCenter, yCenter, windowRect)

% Paradigm Constants

taskSettings.durations.fixation          = 1;
taskSettings.durations.delay             = delay;
taskSettings.durations.siShort           = siShort;
taskSettings.durations.siInter           = siInter;
taskSettings.durations.siLong            = siLong;
taskSettings.durations.ITI               = 1;
taskSettings.durations.tFixed            = .1;
taskSettings.durations.feedB             = 0.3;
taskSettings.durations.saccAcc           = .1;

taskSettings.diams.fix                   = .5;
taskSettings.diams.set                   = 1.5;
taskSettings.diams.target                = 1.5;
taskSettings.diams.lineWidth             = 15;
taskSettings.diams.fixWidth              = 5;

taskSettings.rads.timeMargin              = 2;
taskSettings.rads.spaceMargin             = 2;
taskSettings.rads.spaceFeed               = .75;
taskSettings.rads.fixMargin               = 2;

taskSettings.dists.shortRange            = diShort;
taskSettings.dists.mideRange             = diInter;
taskSettings.dists.longRange             = diLong;
taskSettings.dists.angParams             = [monitorDistance, monitorWidth / screenWidth];

taskSettings.lines.upRight               = [xCenter * 2 xCenter; 0 yCenter];
taskSettings.lines.downRight             = [xCenter * 2 xCenter; yCenter * 2 yCenter];
taskSettings.lines.upLeft                = [0 xCenter; 0 yCenter];
taskSettings.lines.downLeft              = [0 xCenter; yCenter * 2 yCenter];

taskSettings.colors.go                   = [0 .75 0];
taskSettings.colors.abort                = [.75 .75 0];
taskSettings.colors.circles              = [.75 .75 .75];
taskSettings.colors.fix                  = [.75 .75 .75];
taskSettings.colors.line                 = [.22 .22 .22];
taskSettings.colors.margin               = [1 0 0];

taskSettings.windowRect                  = windowRect;

% Keyboard Information

taskSettings.keyBoard.escapeKey = KbName('ESCAPE');
taskSettings.keyBoard.spaceKey  = KbName('Space');
taskSettings.keyBoard.leftKey   = KbName('LeftArrow');
taskSettings.keyBoard.rightKey  = KbName('RightArrow');