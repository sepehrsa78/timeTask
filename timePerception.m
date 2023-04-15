%% Refreshing the Workspace
sca
close all
clear             
clear global
clc

addpath('funcs')
path = pwd;
%% Declare Golabal Variables

delayRange    = [.250 .850];
shortRange    = [.494 .847];
interRange    = [.671 1.023];
longRange     = [.847 1.200];

bsTime  = [];
beTime  = [];

global params

params.isFirst      = true;
params.isAllowed    = false;
params.isBlockEnd   = false;
params.isSave       = false;
%% Subject Information

prompt      = {'Subject Name:', 'Age:', 'Gender:', 'Demo:', 'Eye Tracker:', 'Save Data:', 'Hand:'};
dlgtitle    = 'Subject Information';
dims        = [1 35];
answer      = inputdlg(prompt, dlgtitle, dims);
%% Psychtoolbox Setup

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 3);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
Screen('Preference', 'DefaultTextYPositionIsBaseline', 1);
%% Psychtoolbox Initialization

monitorWidth    = 311;                                                      % in milimeters
monitorDistance = 200;                                                     % in milimeters

screenNumber    = 0;
resolution      = Screen('Resolution', screenNumber);
screenWidth     = resolution.width;
screenHeight    = resolution.height;
pixelDepth      = resolution.pixelSize;
screenHz        = resolution.hz;
nScreenBuffers  = 2;

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

frameSpecs.ifi        = Screen('GetFlipInterval', window);
frameSpecs.waitframes = 1;
textcolor             = BlackIndex(window);
penWidthPixels        = 5;
Screen('TextSize', window, 24);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

topPriorityLevel    = MaxPriority(window);
[xCenter, yCenter]  = RectCenter(windowRect);
SetMouse(xCenter, yCenter);
%% Task Parameters and Constants

timeCondsNum = 3;
distCondsNum = 3;
trlReps      = 1;

if answer{4, 1} == '1'
    nBlock   = 1;
    numTrls  = 20;
    realTrls = timeCondsNum * distCondsNum * trlReps;
else
    nBlock   = 6;
    numTrls  = timeCondsNum * distCondsNum * trlReps;
end

delay   = [];
siShort = [];
siInter = [];
siLong  = [];

tpd = expDist(1, 2000, delayRange(1), delayRange(2));

for iBlock = 1:nBlock
    for iTrial = 1:numTrls
        siShort(iBlock, iTrial)   = shortRange(1) + (shortRange(2) - shortRange(1)) * rand(1, 1);
        siInter(iBlock, iTrial)   = interRange(1) + (interRange(2) - interRange(1)) * rand(1, 1);
        siLong(iBlock, iTrial)    = longRange(1) + (longRange(2) - longRange(1)) * rand(1, 1);
        diShort(iBlock, iTrial)   = 4;
        diInter(iBlock, iTrial)   = 6;
        diLong(iBlock, iTrial)    = 8;
        delay(iBlock, iTrial)     = (500 + randi([1, 500])) / 1000;
    end
end

% Paradigm Constants

durations.fixation          = 1;
durations.delay             = delay;
durations.siShort           = siShort;
durations.siInter           = siInter;
durations.siLong            = siLong;
durations.ITI               = 1;

diams.fix                   = .5;
diams.set                   = 1.5;
diams.target                = .5;
diams.lineWidth             = 5;

rads.timeMargin              = 1;
rads.spaceMargin             = 1;
rads.fixMargin               = 2;

dists.targetPoint           = 10;
dists.shortRange            = diShort;
dists.mideRange             = diInter;
dists.longRange             = diLong;
dists.angParams             = [monitorDistance, monitorWidth / screenWidth];

lines.left                  = [0 xCenter; 0 yCenter];
lines.middle                = [xCenter xCenter; 0 yCenter];
lines.right                 = [xCenter * 2 xCenter; 0 yCenter];

colors.right                = [0 1 0];
colors.circles              = [1 1 1];
colors.fix                  = [1 1 1];
colors.line                 = [.1 .1 .1];
colors.margin               = [1 0 0];

% Keyboard Information

keyBoard.escapeKey = KbName('ESCAPE');
keyBoard.spaceKey  = KbName('Space');
keyBoard.leftKey   = KbName('LeftArrow');
keyBoard.rightKey  = KbName('RightArrow');
%% Creating the Condition Map

blockTypes = repmat(["time" "space"], [1 timeCondsNum]);
blockTypes = blockTypes(randperm(length(blockTypes)));
interTypes = ["short", "inter", "long"];
lineOri    = ["left", "center", "right"];

lineLocs = string(nan(size(blockTypes)));
lineLocs(find(strcmp(blockTypes, 'time'), 3))  = lineOri(randperm(length(lineOri)));
lineLocs(find(strcmp(blockTypes, 'space'), 3)) = lineOri(randperm(length(lineOri)));

timeSpaceIntervals = cellstr(repmat(permn(interTypes, 2), [trlReps 1]));

for iBlock = 1:nBlock
    switch lineLocs(iBlock)
        case "left"
            lineSpecs = lines.left;
        case "center"
            lineSpecs = lines.middle;
        case "right"
            lineSpecs = lines.right;
    end
    block(iBlock).trialSet = struct(...
        'blockType', repmat({blockTypes(iBlock)}, [numTrls, 1]),...
        'targetLineLoc', repmat({lineLocs(iBlock)}, [numTrls, 1]),...
        'lineSpecs', repmat({lineSpecs}, [numTrls, 1]),...
        'timeIntervalType', timeSpaceIntervals(:, 1),...
        'distIntervalType', timeSpaceIntervals(:, 2),...
        'delay', num2cell(durations.delay(iBlock, :))',...
        'timeInterval', [],...
        'distInterval', [],...
        'fixOn', [],...
        'lineOn', [],...
        'setOn', [],...
        'tarOn', [],...
        'saccadeOn', [],...
        'RT', [],...
        'acc', []...
        );
end
for iBlock = 1:nBlock

    for iTrial = 1:numTrls
        switch block(iBlock).trialSet(iTrial).timeIntervalType
            case 'short'
                block(iBlock).trialSet(iTrial).timeInterval = siShort(iBlock, iTrial);
            case 'inter'
                block(iBlock).trialSet(iTrial).timeInterval = siInter(iBlock, iTrial);
            case 'long'
                block(iBlock).trialSet(iTrial).timeInterval = siLong(iBlock, iTrial);
        end
        switch block(iBlock).trialSet(iTrial).distIntervalType
            case 'short'
                block(iBlock).trialSet(iTrial).distInterval = diShort(iBlock, iTrial);
            case 'inter'
                block(iBlock).trialSet(iTrial).distInterval = diInter(iBlock, iTrial);
            case 'long'
                block(iBlock).trialSet(iTrial).distInterval = diLong(iBlock, iTrial);
        end

    end

    block(iBlock).trialSet = block(iBlock).trialSet(randperm(numTrls));

end
%% Task Body

rand('seed', sum(100 * clock));

timer = GetSecs();
for iBlock = 1:nBlock

    iTrial = 0;
    params.isAllowed = true;
    bsTime(iBlock) = GetSecs() - timer;

    while iTrial <= numTrls 

        if params.isFirst
            Prompt_Start = sprintf("%s", blockTypes(iBlock));
            DrawFormattedText(window, char(Prompt_Start),...
                'center', 'center', BlackIndex(screenNumber) / 2);
            Screen('Flip', window);
            KbStrokeWait;
            Screen('Flip', window);

            params.isFirst = false;
        end

        if params.isAllowed
            iTrial = iTrial + 1;
        end

        if iTrial > numTrls
            params.isAllowed  = false;
            break
        end

        Priority(topPriorityLevel);
        block = expDirs(...
            frameSpecs, colors, rads, diams, durations, dists,...
            window, xCenter, yCenter, block, iBlock, iTrial, timer);
        Priority(0);

    end

    params.isBlockEnd = true;

    if params.isBlockEnd && iBlock < nBlock
        Prompt_Start = sprintf("%s", blockTypes(iBlock + 1  ));
        DrawFormattedText(window, char(Prompt_Start),...
            'center', 'center', BlackIndex(screenNumber) / 2);
        Screen('Flip', window);
        KbStrokeWait;
        Screen('Flip', window);
        params.isBlockEnd = false;
        ebTime(iBlock) = GetSecs() - timer;
    end
    if iBlock == nBlock
        ebTime(iBlock) = GetSecs() - timer;
        Prompt_Start = 'Task Finished';
        DrawFormattedText(window, Prompt_Start,...
            'center', 'center', BlackIndex(screenNumber) / 2);
        Screen('Flip', window);
        WaitSecs(1);
        sca;
    end
end

sData.sInfo                 = answer;
sData.Blocks.Durations      = durations;
sData.Blocks.blockType      = blockTypes;
sData.Blocks.bsTime         = bsTime;
sData.Blocks.ebTime         = ebTime;
sData.Blocks.Trials         = block;
%% Save Data

% if answer{6, 1} == '1'
%     params.isSave = true;
% end
% 
% if answer{6, 1} == '1' && params.isSave
%     if ~exist(fullfile(path, 'results', answer{1, 1}), "dir")
%         mkdir(fullfile(path, 'results', answer{1, 1}))
%     end
%     if answer{4, 1} == '1'
%         save(fullfile(path, 'results', answer{1, 1}, [answer{1, 1}, '_demo_data.mat']))
%     else
%         save(fullfile(path, 'results', answer{1, 1}, [answer{1, 1}, '_data.mat']), 'sData')
%     end
% end
