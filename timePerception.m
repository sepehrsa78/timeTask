%% Refreshing the Workspace
sca
close all
clear             
clear global
clc
    
addpath('funcs')
path = pwd;
%% Declare Golabal Variables

bsTime  = [];
beTime  = [];

global params

params.isFirst      = true;
params.isAllowed    = false;
params.isBlockEnd   = false;
params.isSave       = false;
%% Subject Information     

prompt      = {'Subject Name:', 'Age:', 'Gender:', 'Demo:', 'Subject Number:', 'Save Data:', 'Hand:', 'Time First:', 'Light Left:'};
dlgtitle    = 'Subject Information';
dims        = [1 35];
answer      = inputdlg(prompt, dlgtitle, dims);
%% Initialize Eyetracker

% debug = 1;
% if debug
%     PsychDebugWindowConfiguration([],0.7);
%     Screen('Preference', 'SkipSyncTests', 1);
% else
%     Screen('Preference', 'SkipSyncTests', 0);
% end

if ~exist(fullfile(path, 'results', answer{1, 1}), 'dir')
    mkdir(fullfile(path, 'results', answer{1, 1}))
end

save(fullfile(path, 'results', answer{1, 1}, sprintf('%s_eyeD.edf', answer{5, 1})));
edfFile = fullfile(path, 'results', answer{1, 1}, sprintf('%s_eyeD', answer{5, 1}));

eyeInit(edfFile);
%% Psychtoolbox Setup

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 3);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
Screen('Preference', 'DefaultTextYPositionIsBaseline', 1);

ListenChar(2)
%% Psychtoolbox Initialization

monitorWidth    = 530;                                                     % in milimeters
monitorDistance = 600;                                                     % in milimeters

screenNumber    = max(Screen('Screens'));
resolution      = Screen('Resolution', screenNumber);
screenWidth     = resolution.width;
screenHeight    = resolution.height;
pixelDepth      = resolution.pixelSize;
screenHz        = resolution.hz;
backColor       = [80 80 80] / 255;
nScreenBuffers  = 2;

[window, windowRect] = PsychImaging(...
    'OpenWindow', ...
    screenNumber, ...`
    backColor, ...
    floor([0, 0, screenWidth, screenHeight] / 1), ...
    pixelDepth, ...
    nScreenBuffers, ...
    [], ...
    [], ...
    kPsychNeed32BPCFloat...
    );

frameSpecs.ifi        = Screen('GetFlipInterval', window);
[width, height]       = Screen('WindowSize', window);
frameSpecs.waitframes = 1;
frameSpecs.frameRate  = 1 / frameSpecs.ifi;
textcolor             = BlackIndex(window);
penWidthPixels        = 5;
Screen('TextSize', window, 24);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

topPriorityLevel    = MaxPriority(window);
[xCenter, yCenter]  = RectCenter(windowRect);
SetMouse(xCenter, yCenter);
%% Eye Calibration

el = eyeCalib(window, width, height, backColor);
%% Task Parameters and Constants

timeCondsNum = 3;
distCondsNum = 3;
blockPmodal  = 4;
trlReps      = 6;

if answer{4, 1} == '1'
    nBlock   = 1;
    numTrls  = 20;
    realTrls = timeCondsNum * distCondsNum * trlReps;
else
    nBlock   = 8;
    numTrls  = timeCondsNum * distCondsNum * trlReps;
end

delay   = [];
siShort = [];
siInter = [];
siLong  = [];

for iBlock = 1:nBlock
    for iTrial = 1:numTrls
        siShort(iBlock, iTrial)   = .4;
        siInter(iBlock, iTrial)   = .8;
        siLong(iBlock, iTrial)    = 1.6;
        diShort(iBlock, iTrial)   = 6;
        diInter(iBlock, iTrial)   = 8;
        diLong(iBlock, iTrial)    = 12;
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
durations.tFixed            = .084;
durations.feedB             = 0.033;
durations.saccAcc           = .2;

diams.fix                   = .5;
diams.set                   = 1.5;
diams.target                = 1.5;
diams.lineWidth             = 10;
diams.fixWidth              = 2;

rads.timeMargin              = 2;
rads.spaceMargin             = 2;
rads.spaceFeed               = .75;
rads.fixMargin               = 2;

dists.shortRange            = diShort;
dists.mideRange             = diInter;
dists.longRange             = diLong;
dists.angParams             = [monitorDistance, monitorWidth / screenWidth];

lines.upRight               = [xCenter * 2 xCenter; 0 yCenter];
lines.downRight             = [xCenter * 2 xCenter; yCenter * 2 yCenter];
lines.upLeft                = [0 xCenter; 0 yCenter];
lines.downLeft              = [0 xCenter; yCenter * 2 yCenter];

colors.go                   = [0 1 0];
colors.abort                = [1 1 0];
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

blockTypes = [repmat({'time'}, [1 blockPmodal]) repmat({'space'}, [1 blockPmodal])];
flashLocs  = repmat([repmat({'left'}, [1 blockPmodal / 2]) repmat({'right'}, [1 blockPmodal / 2])], [1 length(unique(blockTypes))]);
if answer{8, 1} ~= '1'
    blockTypes = flip(blockTypes);
end
if answer{9, 1} ~= '1'
    flashLocs  = flip(flashLocs);
end
interTypes = {'short', 'inter', 'long'};
lineOri    = {'upright', 'downright', 'upleft', 'downleft'};
leftOr     = lineOri(contains(lineOri, 'left'));
rightOr    = lineOri(contains(lineOri, 'right'));

lineLocs = cell(size(blockTypes));
lineLocs(find(strcmp(blockTypes, 'time') & strcmp(flashLocs, 'right'), blockPmodal / 2)) = repmat(leftOr(randperm(length(leftOr))), [1 blockPmodal / 4]);
lineLocs(find(strcmp(blockTypes, 'time') & strcmp(flashLocs, 'left'), blockPmodal / 2))  = repmat(rightOr(randperm(length(rightOr))), [1 blockPmodal / 4]);
lineLocs(find(strcmp(blockTypes, 'space') & strcmp(flashLocs, 'right'), blockPmodal / 2))= repmat(leftOr(randperm(length(leftOr))), [1 blockPmodal / 4]);
lineLocs(find(strcmp(blockTypes, 'space') & strcmp(flashLocs, 'left'), blockPmodal / 2)) = repmat(rightOr(randperm(length(rightOr))), [1 blockPmodal / 4]);

timeSpaceIntervals = cellstr(repmat(permn(interTypes, 2), [trlReps 1]));

for iBlock = 1:nBlock
    switch lineLocs{iBlock}
        case 'upright'
            lineSpecs = lines.upRight;
        case 'downright'
            lineSpecs = lines.downRight;
        case 'upleft'
            lineSpecs = lines.upLeft;
        case 'downleft'
            lineSpecs = lines.downLeft;
    end
    block(iBlock).trialSet = struct(...
        'blockType', repmat(blockTypes(iBlock), [numTrls, 1]),...
        'targetLineLoc', repmat(lineLocs(iBlock), [numTrls, 1]),...
        'lineSpecs', repmat({lineSpecs}, [numTrls, 1]),...
        'flashLoc', repmat(flashLocs(iBlock), [numTrls, 1]),...
        'timeIntervalType', timeSpaceIntervals(:, 1),...
        'distIntervalType', timeSpaceIntervals(:, 2),...
        'delay', num2cell(durations.delay(iBlock, :))',...
        'timeInterval', [],...
        'distInterval', [],...
        'targetInterval', [],...
        'fixOn', [],...
        'fixOff', [],...
        'lineOn', [],...
        'lineOff', [],...
        'setOn', [],...
        'setOff', [],...
        'tarOn', [],...
        'saccadeOn', [],...
        'saccadeInRect', [],...
        'feedBackOn', [],...
        'feedBackOff', [],...
        'prodDist', [],...
        'RT', []...
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
                block(iBlock).trialSet(iTrial).distInterval   = diShort(iBlock, iTrial);
                block(iBlock).trialSet(iTrial).targetInterval = diShort(iBlock, iTrial);
            case 'inter'
                block(iBlock).trialSet(iTrial).distInterval   = diInter(iBlock, iTrial);
                block(iBlock).trialSet(iTrial).targetInterval = diInter(iBlock, iTrial);
            case 'long'
                block(iBlock).trialSet(iTrial).distInterval   = diLong(iBlock, iTrial);
                block(iBlock).trialSet(iTrial).targetInterval = diLong(iBlock, iTrial);
        end

    end

    block(iBlock).trialSet = block(iBlock).trialSet(randperm(numTrls));

end
%% Task Body

rng(sum(100 * clock));

Eyelink('SetOfflineMode');
Eyelink('StartRecording');
WaitSecs(.010)

timer = GetSecs();

for iBlock = 1:nBlock

    iTrial = 0;
    params.isAllowed = true;
    bsTime(iBlock) = GetSecs() - timer;
    sData.Blocks(iBlock).bsTime = bsTime(iBlock);

    while iTrial <= numTrls 

        if params.isFirst
            Prompt_Start = sprintf('%s', string(blockTypes(iBlock)));
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
        
        Eyelink('Message', 'TRIALID %d', iTrial);
        Eyelink('Command', 'record_status_message "TRIAL %d/%d"', iTrial, numTrls);

        Priority(topPriorityLevel);
        [block] = expDirs(...
            frameSpecs, colors, rads, diams, durations, dists,...
            window, xCenter, yCenter, block, iBlock, iTrial, timer);

        Eyelink('Message', 'BLANK_SCREEN');
        Eyelink('Message', '!V CLEAR %d %d %d', 80, 80, 80);
        Eyelink('Message', '!V TRIAL_VAR iteration %d', iTrial); % Trial iteration
        Eyelink('Message', 'TRIAL_RESULT 0');

        WaitSecs(durations.ITI);
        Priority(0); 

    end

    sData.Blocks(iBlock).Trials = block(iBlock).trialSet;
    params.isBlockEnd = true;    

    if params.isBlockEnd && iBlock < nBlock
        ebTime(iBlock) = GetSecs() - timer;
        sData.Blocks(iBlock).ebTime = ebTime(iBlock);
        Prompt_Start = sprintf('%s', string(blockTypes(iBlock + 1)));
        DrawFormattedText(window, char(Prompt_Start),...
            'center', 'center', BlackIndex(screenNumber) / 2);
        Screen('Flip', window);
        KbStrokeWait;
        Screen('Flip', window);
        params.isBlockEnd = false;
    end
    if iBlock == nBlock
        ebTime(iBlock) = GetSecs() - timer;
        sData.Blocks(iBlock).ebTime = ebTime(iBlock);
        Prompt_Start = 'Task Finished';
        DrawFormattedText(window, Prompt_Start,...
            'center', 'center', BlackIndex(screenNumber) / 2);
        Screen('Flip', window);

        WaitSecs(0.100)
        Eyelink('StopRecording')
    end
end
%% Data Storage

sData.sInfo          = answer;
sData.Durations      = durations;
sData.Rads           = rads;
sData.Dists          = dists;
sData.Diams          = diams;
sData.Rads           = rads;
sData.Lines          = lines;
sData.Colors         = colors;
sData.blockType      = blockTypes;
%% Save Data
   
if answer{6, 1} == '1'
    params.isSave = true;
end

if answer{6, 1} == '1' && params.isSave
    if ~exist(fullfile(path, 'results', answer{1, 1}), 'dir')
        mkdir(fullfile(path, 'results', answer{1, 1}))
    end
    if answer{4, 1} == '1'
        save(fullfile(path, 'results', answer{1, 1}, [answer{1, 1}, '_demo_data.mat']))
    else
        save(fullfile(path, 'results', answer{1, 1}, [answer{1, 1}, '_data.mat']), 'sData')
    end
end

%% Close Eyetracker

% CLOSE EDF FILE. TRANSFER EDF COPY TO DISPLAY PC. CLOSE EYELINK CONNECTION. FINISH UP

% Put tracker in idle/offline mode before closing file.
Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
WaitSecs(0.5); % Allow some time before closing and transferring file
Eyelink('CloseFile'); % Close EDF file on Host PC

cd(fullfile(path, 'results', answer{1, 1}))

% Transfer a copy of the EDF file to Display PC
transferFile(edfFile, 0, window, backColor, windowRect(4)); % See transferFile function below

% Close all the windows and screens
sca;
Eyelink('Shutdown');

% Make the cursor visible
ShowCursor;
ListenChar(0)
