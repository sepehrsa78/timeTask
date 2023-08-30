 %% Refreshing the Workspace
sca
close all
if exist('answer', 'var') && answer{6, 1} ~= '1'
    clearvars -except run answer nBlock block sData taskSettings
else
    clear
end
clear global
clc
ListenChar
    
addpath('funcs')
path = pwd;
rng(sum(100 * clock));
%% Declare Golabal Variables

bsTime  = [];
beTime  = [];

global params

params.isFirst      = true;
params.isAllowed    = false;
%% Subject Information 

if ~exist('run', 'var')
    prompt         = 'Is this the first session?';
    sessionInfo    = 'Subject Information';
    isFirstSession = questdlg(prompt, sessionInfo, 'Yes', 'No', '');
    if strcmpi(isFirstSession, 'Yes')
        isFirstSession = true;
    else
        isFirstSession = false;
    end
end

if (exist('isFirstSession', 'var') && isFirstSession) || (exist('answer', 'var') && answer{6, 1} == '1')
    prompt      = {'Subject Name:', 'Subject Number:', 'Age:', 'Gender:', 'Hand:', 'Demo:', 'Time First:', 'Light Left:'};
    dlgtitle    = 'Subject Information';
    dims        = [1 35];
    answer      = inputdlg(prompt, dlgtitle, dims);
    run         = 1;
    ListenChar(2)
elseif exist('isFirstSession', 'var') && ~isFirstSession && ~exist('run', 'var')
    dataDir     = ls('./results/');
    dataDir     = dataDir(3:end, :);
    idx         = listdlg('ListString', dataDir);
    subjectName = dataDir(idx, :);
    
    load(fullfile('results', deblank(subjectName), strcat(subjectName, '_conditionMap.mat')))
    load(fullfile('results', deblank(subjectName), strcat(subjectName, '_data.mat')))
    taskSettings = sData.taskSettings;
    answer       = sData.sInfo;

    prompt                   = {'Block Number:'};
    dlgtitle                 = 'Run Information';
    dims                     = [1 35];
    bAns                     = inputdlg(prompt, dlgtitle, dims);
    run                      = str2double(bAns{1});
    fieldsToEmpty            = {...
        'fixOn', 'fixOff', 'lineOn', 'lineOff', 'setOn',...
        'setOff', 'tarOn', 'saccadeOn', 'saccadeInRect',...
        'feedBackOn', 'feedBackOff', 'prodDist', 'RT'};
    sData.Blocks(run).Trials = emptyStruct(sData.Blocks(run).Trials, fieldsToEmpty);
    block(run).trialSet      = emptyStruct(block(run).trialSet, fieldsToEmpty);
    ListenChar(2)
elseif exist('run', 'var')
    prompt                   = {'Block Number:'};
    dlgtitle                 = 'Run Information';
    dims                     = [1 35];
    defInput                 = run + 1;
    bAns                     = inputdlg(prompt, dlgtitle, dims, {num2str(defInput)});
    fieldsToEmpty            = {...
        'fixOn', 'fixOff', 'lineOn', 'lineOff', 'setOn',...
        'setOff', 'tarOn', 'saccadeOn', 'saccadeInRect',...
        'feedBackOn', 'feedBackOff', 'prodDist', 'RT'};
    run                      = str2double(bAns{1});
    sData.Blocks(run).Trials = emptyStruct(sData.Blocks(run).Trials, fieldsToEmpty);
    block(run).trialSet      = emptyStruct(block(run).trialSet, fieldsToEmpty);
    ListenChar(2)
end
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

% save(fullfile(path, 'results', answer{1, 1}, sprintf('%s_B%d_eyeD.edf', answer{2, 1}, run)));
% edfFile = fullfile(path, 'results', answer{1, 1}, sprintf('%sـB%d_eyeD', answer{2, 1}, run));
% 
% eyeInit(edfFile);
%% Psychtoolbox Setup

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 3);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
Screen('Preference', 'DefaultTextYPositionIsBaseline', 1);
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

% el = eyeCalib(window, width, height, backColor);
%% Task Parameters and Constants

timeCondsNum = 3;
distCondsNum = 3;
blockPmodal  = 4;
nBlock       = 8;

if answer{6, 1} == '1'
    trlReps  = 1;
    numTrls  = timeCondsNum * distCondsNum * trlReps;
else
    trlReps  = 1;
    numTrls  = timeCondsNum * distCondsNum * trlReps;
end

siShort = nan(size(nBlock, numTrls));
siInter = nan(size(nBlock, numTrls));
siLong  = nan(size(nBlock, numTrls));
diShort = nan(size(nBlock, numTrls));
diInter = nan(size(nBlock, numTrls));
diLong  = nan(size(nBlock, numTrls));
delay   = nan(size(nBlock, numTrls));

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

% Task Settings

if run == 1 && ~exist('sData', 'var')
    taskSettings = settingsTask(...
        delay, siShort, siInter,...
        siLong, diShort, diInter,...
        diLong, monitorDistance, monitorWidth,...
        screenWidth, xCenter, yCenter, windowRect);
end
%% Creating the Condition Map

blockTypes = [repmat({'time'}, [1 blockPmodal]) repmat({'space'}, [1 blockPmodal])];
flashLocs  = repmat([repmat({'left'}, [1 blockPmodal / 2]) repmat({'right'}, [1 blockPmodal / 2])], [1 length(unique(blockTypes))]);
if answer{7, 1} ~= '1'
    blockTypes = flip(blockTypes);
end
if answer{8, 1} ~= '1'
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

if run == 1 && ~exist('sData', 'var')
    for iBlock = 1:nBlock
        switch lineLocs{iBlock}
            case 'upright'
                lineSpecs = taskSettings.lines.upRight;
            case 'downright'
                lineSpecs = taskSettings.lines.downRight;
            case 'upleft'
                lineSpecs = taskSettings.lines.upLeft;
            case 'downleft'
                lineSpecs = taskSettings.lines.downLeft;
        end
        block(iBlock).trialSet = struct(...
            'blockType', repmat(blockTypes(iBlock), [numTrls, 1]),...
            'targetLineLoc', repmat(lineLocs(iBlock), [numTrls, 1]),...
            'lineSpecs', repmat({lineSpecs}, [numTrls, 1]),...
            'flashLoc', repmat(flashLocs(iBlock), [numTrls, 1]),...
            'timeIntervalType', timeSpaceIntervals(:, 1),...
            'distIntervalType', timeSpaceIntervals(:, 2),...
            'delay', num2cell(taskSettings.durations.delay(iBlock, :))',...
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
        if answer{6, 1} ~= '1'
            sData.Blocks(iBlock).Trials = block(iBlock).trialSet;
        end
    end
    if answer{6, 1} ~= '1'
        save(fullfile(path, 'results', answer{1, 1}, sprintf('%s_conditionMap.mat', answer{1, 1})), 'block');
    end
end
%% Task Body

% Eyelink('SetOfflineMode');
% Eyelink('StartRecording');
% WaitSecs(.010)

timer = GetSecs();

iTrial            = 0;
params.isAllowed  = true;
while iTrial <= numTrls

    if params.isFirst
        Prompt_Start = sprintf('%s', string(blockTypes(run)));
        DrawFormattedText(window, char(Prompt_Start),...
            'center', 'center', BlackIndex(screenNumber) / 2);
        Screen('Flip', window);
        KbStrokeWait;
        Screen('Flip', window);

        params.isFirst = false;
        bsTime(run)              = GetSecs() - timer;
        sData.Blocks(run).bsTime = bsTime(run);
    end

    if params.isAllowed
        iTrial = iTrial + 1;
    end

    if iTrial > numTrls
        params.isAllowed  = false;
        break
    end

%     Eyelink('Message', 'TRIALID %d', iTrial);
%     Eyelink('Command', 'record_status_message "TRIAL %d/%d"', iTrial, numTrls);

    Priority(topPriorityLevel);
    [block] = expDirs(taskSettings, frameSpecs, window, xCenter, yCenter, block, run, iTrial, timer);

%     Eyelink('Message', 'BLANK_SCREEN');
%     Eyelink('Message', '!V CLEAR %d %d %d', 80, 80, 80);
%     Eyelink('Message', '!V TRIAL_VAR iteration %d', iTrial); % Trial iteration
%     Eyelink('Message', 'TRIAL_RESULT 0');

WaitSecs(taskSettings.durations.ITI - frameSpecs.ifi); 

end

ebTime(run)              = GetSecs() - timer;
sData.Blocks(run).ebTime = ebTime(run);
sData.Blocks(run).Trials = block(run).trialSet;
Prompt_Start = 'Task Finished';
DrawFormattedText(window, Prompt_Start, 'center', 'center', BlackIndex(screenNumber) / 2);
Screen('Flip', window);
sca;
Priority(0);
% WaitSecs(0.100)
% Eyelink('StopRecording')
%% Data Storage

if run == 1 && answer{6, 1} ~= '1'
    sData.sInfo          = answer;
    sData.taskSettings   = taskSettings;
    sData.blockType      = blockTypes;
end
%% Save Data
   
if ~exist(fullfile(path, 'results', answer{1, 1}), 'dir')
    mkdir(fullfile(path, 'results', answer{1, 1}))
end
if answer{6, 1} ~= '1'
    blockData = block(run).trialSet;
    save(fullfile(path, 'results', answer{1, 1}, [answer{1, 1}, sprintf('_B%d_data.mat', run)]), 'blockData')
    save(fullfile(path, 'results', answer{1, 1}, [answer{1, 1}, '_data.mat']), 'sData')
end
%% Close Eyetracker

% % CLOSE EDF FILE. TRANSFER EDF COPY TO DISPLAY PC. CLOSE EYELINK CONNECTION. FINISH UP
% 
% % Put tracker in idle/offline mode before closing file.
% Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
% Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
% WaitSecs(0.5); % Allow some time before closing and transferring file
% Eyelink('CloseFile'); % Close EDF file on Host PC
% 
% cd(fullfile(path, 'results', answer{1, 1}))
% 
% % Transfer a copy of the EDF file to Display PC
% transferFile(edfFile, 0, v window, backColor, windowRect(4)); % See transferFile function below
% 
% % Close all the windows and screens
% sca;
% Eyelink('Shutdown');

% Make the cursor visible
ShowCursor;
ListenChar
