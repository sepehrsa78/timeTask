%% Color-Motion Discrimination Task
%  Randomly moving dots with random color (green/red).
%  Subject integrates signed motion coherence and signed color coherence
%  to saccade to left or right target.
%
%  Rule (XOR mapping):
%    Up + Green   -> RIGHT
%    Down + Red   -> RIGHT
%    Down + Green -> LEFT
%    Up + Red     -> LEFT

%% Refreshing the Workspace
sca
close all
if exist('answer', 'var') && answer{6, 1} ~= '1'
    clearvars -except run answer nBlock block sData cfg
else
    clear
end
clear global
clc
ListenChar

addpath('funcs')
path = pwd;
rng('shuffle');

%% Declare Global Variables
global params

params.isFirst   = true;
params.isAllowed = false;

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
    prompt   = {'Subject Name:', 'Subject Number:', 'Age:', 'Gender:', 'Hand:', 'Demo:'};
    dlgtitle = 'Subject Information';
    dims     = [1 35];
    answer   = inputdlg(prompt, dlgtitle, dims);
    run      = 1;
    ListenChar(2)
elseif exist('isFirstSession', 'var') && ~isFirstSession && ~exist('run', 'var')
    dataDir = dir('./results/');
    names   = {};
    for iFolder = 3:length(dataDir)
        names{end+1} = dataDir(iFolder).name; %#ok<SAGROW>
    end
    names       = char(names);
    idx         = listdlg('ListString', cellstr(names));
    subjectName = deblank(names(idx, :));

    load(fullfile('results', subjectName, [subjectName '_conditionMap.mat']))
    if exist(fullfile('results', subjectName, [subjectName '_data.mat']), 'file')
        load(fullfile('results', subjectName, [subjectName '_data.mat']))
        cfg    = sData.cfg;
        answer = sData.sInfo;
    end

    prompt   = {'Block Number:'};
    dlgtitle = 'Run Information';
    dims     = [1 35];
    bAns     = inputdlg(prompt, dlgtitle, dims);
    run      = str2double(bAns{1});
    ListenChar(2)
elseif exist('run', 'var')
    prompt   = {'Block Number:'};
    dlgtitle = 'Run Information';
    dims     = [1 35];
    defInput = run + 1;
    bAns     = inputdlg(prompt, dlgtitle, dims, {num2str(defInput)});
    run      = str2double(bAns{1});
    ListenChar(2)
end

%% Load Configuration
if ~exist('cfg', 'var')
    cfg = taskCfg();
end

%% Initialize Eyetracker
if ~exist(fullfile(path, 'results', answer{1, 1}), 'dir')
    mkdir(fullfile(path, 'results', answer{1, 1}))
end

edfFileName = sprintf('%s_B%d', answer{2, 1}, run);
save(fullfile(path, 'results', answer{1, 1}, [edfFileName '_eD.edf']));
eyeInit(edfFileName);

%% Psychtoolbox Setup
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 3);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
Screen('Preference', 'DefaultTextYPositionIsBaseline', 1);

%% Psychtoolbox Initialization
screenNumber   = max(Screen('Screens'));
resolution     = Screen('Resolution', screenNumber);
screenWidth    = resolution.width;
screenHeight   = resolution.height;
pixelDepth     = resolution.pixelSize;
screenHz       = resolution.hz;
backColor      = cfg.colors.background;
nScreenBuffers = 2;

[window, windowRect] = PsychImaging(...
    'OpenWindow', ...
    screenNumber, ...
    backColor, ...
    floor([0, 0, screenWidth, screenHeight] / 1), ...
    pixelDepth, ...
    nScreenBuffers, ...
    [], ...
    [], ...
    kPsychNeed32BPCFloat ...
    );

frameSpecs.ifi        = Screen('GetFlipInterval', window);
[width, height]       = Screen('WindowSize', window);
frameSpecs.waitframes = 1;
frameSpecs.frameRate  = 1 / frameSpecs.ifi;
Screen('TextSize', window, 24);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

topPriorityLevel   = MaxPriority(window);
[xCenter, yCenter] = RectCenter(windowRect);
SetMouse(xCenter, yCenter);

%% Build screenInfo struct (compatible with deg2screen.m)
screenInfo.cur_window  = window;
screenInfo.screen_rect = windowRect;
screenInfo.mon_refresh = frameSpecs.frameRate;
screenInfo.pix_per_deg = (windowRect(3) / cfg.monitor.width) * ...
    (1 / (2 * atan2(1/2, cfg.monitor.distance))) * (pi / 180);

%% Eye Calibration
el = eyeCalib(window, width, height, backColor);

%% Generate Condition Map
if run == 1 && ~exist('sData', 'var')
    % Signed coherences: positive = up/green, negative = down/red
    unsignedCohs = cfg.coherences;
    signedMotionCohs = [-fliplr(unsignedCohs(2:end)), unsignedCohs];
    signedColorCohs  = [-fliplr(unsignedCohs(2:end)), unsignedCohs];

    % Full factorial
    nMotion = length(signedMotionCohs);
    nColor  = length(signedColorCohs);
    nConds  = nMotion * nColor;

    condList = [];
    condIdx  = 0;
    for iM = 1:nMotion
        for iC = 1:nColor
            condIdx = condIdx + 1;

            mCoh = signedMotionCohs(iM);
            cCoh = signedColorCohs(iC);

            % Decode signed coherence into direction + unsigned coherence
            if mCoh >= 0
                motionDir = 90;   % upward
            else
                motionDir = 270;  % downward
            end
            motionCohUns = abs(mCoh);

            if cCoh >= 0
                colorDir = 1;     % green majority
            else
                colorDir = 2;     % red majority
            end
            colorCohUns = abs(cCoh);

            % XOR rule: same-sign -> RIGHT, different-sign -> LEFT
            motionSign = sign(mCoh);
            colorSign  = sign(cCoh);
            if motionSign == 0 && colorSign == 0
                % Both zero: randomly assign (ambiguous trial)
                if rand < 0.5
                    correctTarget = 'right';
                else
                    correctTarget = 'left';
                end
            elseif motionSign == 0
                % Motion ambiguous: correct target based on color alone
                % (could go either way; assign randomly)
                if rand < 0.5
                    correctTarget = 'right';
                else
                    correctTarget = 'left';
                end
            elseif colorSign == 0
                % Color ambiguous: correct target based on motion alone
                if rand < 0.5
                    correctTarget = 'right';
                else
                    correctTarget = 'left';
                end
            elseif motionSign == colorSign
                correctTarget = 'right';
            else
                correctTarget = 'left';
            end

            condList(condIdx).signedMotionCoh = mCoh; %#ok<SAGROW>
            condList(condIdx).signedColorCoh  = cCoh;
            condList(condIdx).motionDir       = motionDir;
            condList(condIdx).motionCoh       = motionCohUns;
            condList(condIdx).colorDir        = colorDir;
            condList(condIdx).colorCoh        = colorCohUns;
            condList(condIdx).correctTarget   = correctTarget;
        end
    end

    % Repeat conditions and shuffle
    if answer{6, 1} == '1'
        nReps = 1;  % demo mode
    else
        nReps = cfg.nReps;
    end

    allTrials = repmat(condList, [1 nReps]);
    allTrials = allTrials(randperm(length(allTrials)));

    % Split into blocks
    numTrls = length(allTrials);
    if cfg.trialsPerBlock > 0 && cfg.trialsPerBlock < numTrls
        nBlock = ceil(numTrls / cfg.trialsPerBlock);
    else
        nBlock = 1;
    end

    trialsPerBlock = ceil(numTrls / nBlock);

    for iBlock = 1:nBlock
        startIdx = (iBlock - 1) * trialsPerBlock + 1;
        endIdx   = min(iBlock * trialsPerBlock, numTrls);
        block(iBlock).trialSet = allTrials(startIdx:endIdx); %#ok<SAGROW>
    end

    % Save condition map
    save(fullfile(path, 'results', answer{1, 1}, ...
        [answer{1, 1} '_conditionMap.mat']), 'block', 'answer', 'cfg');
end

%% Task Body
Eyelink('SetOfflineMode');
Eyelink('StartRecording');
WaitSecs(0.010);
timer = GetSecs();

currentBlock  = run;
numTrls       = length(block(currentBlock).trialSet);
iTrial        = 0;
params.isAllowed = true;

while iTrial <= numTrls

    if params.isFirst
        promptStr = sprintf('Block %d / %d\nPress any key to start', currentBlock, nBlock);
        DrawFormattedText(window, promptStr, 'center', 'center', BlackIndex(screenNumber) / 2);
        Screen('Flip', window);
        KbStrokeWait;
        Screen('Flip', window);
        params.isFirst = false;
    end

    if params.isAllowed
        iTrial = iTrial + 1;
    end

    if iTrial > numTrls
        params.isAllowed = false;
        break
    end

    Eyelink('Message', 'TRIALID %d', iTrial);
    Eyelink('Command', 'record_status_message "TRIAL %d/%d"', iTrial, numTrls);

    % Build trialParams struct for this trial
    trialParams.motionDir     = block(currentBlock).trialSet(iTrial).motionDir;
    trialParams.motionCoh     = block(currentBlock).trialSet(iTrial).motionCoh;
    trialParams.colorDir      = block(currentBlock).trialSet(iTrial).colorDir;
    trialParams.colorCoh      = block(currentBlock).trialSet(iTrial).colorCoh;
    trialParams.correctTarget = block(currentBlock).trialSet(iTrial).correctTarget;

    Priority(topPriorityLevel);
    trialData = runTrial(cfg, trialParams, window, screenInfo, frameSpecs);
    Priority(0);

    % Store trial data
    block(currentBlock).trialSet(iTrial).trialData = trialData;

    % Eyelink trial end messages
    Eyelink('Message', 'BLANK_SCREEN');
    bgc = round(cfg.colors.background * 255);
    Eyelink('Message', '!V CLEAR %d %d %d', bgc(1), bgc(2), bgc(3));
    Eyelink('Message', '!V TRIAL_VAR iteration %d', iTrial);
    Eyelink('Message', '!V TRIAL_VAR motionCoh %f', trialParams.motionCoh);
    Eyelink('Message', '!V TRIAL_VAR motionDir %d', trialParams.motionDir);
    Eyelink('Message', '!V TRIAL_VAR colorCoh %f', trialParams.colorCoh);
    Eyelink('Message', '!V TRIAL_VAR colorDir %d', trialParams.colorDir);
    Eyelink('Message', '!V TRIAL_VAR correct %d', trialData.correct);
    Eyelink('Message', 'TRIAL_RESULT 0');

    % ITI
    vbl = Screen('Flip', window);
    for numFrames = 1:round(cfg.timing.ITI / frameSpecs.ifi) - 2
        vbl = Screen('Flip', window, vbl + (frameSpecs.waitframes - 0.5) * frameSpecs.ifi);
    end
end

Eyelink('StopRecording');

%% Data Storage
sData.Blocks(currentBlock).Trials = block(currentBlock).trialSet;
sData.Blocks(currentBlock).bTime  = GetSecs() - timer;

if currentBlock == 1 && answer{6, 1} ~= '1'
    sData.sInfo = answer;
    sData.cfg   = cfg;
end

%% Save Data
if ~exist(fullfile(path, 'results', answer{1, 1}), 'dir')
    mkdir(fullfile(path, 'results', answer{1, 1}))
end
if answer{6, 1} ~= '1'
    blockData = block(currentBlock).trialSet;
    save(fullfile(path, 'results', answer{1, 1}, ...
        sprintf('%s_B%d_data.mat', answer{1, 1}, currentBlock)), 'blockData')
    save(fullfile(path, 'results', answer{1, 1}, ...
        [answer{1, 1} '_data.mat']), 'sData')
end

%% Task Finished Prompt
promptStr = 'Task Finished';
DrawFormattedText(window, promptStr, 'center', 'center', BlackIndex(screenNumber) / 2);
Screen('Flip', window);
WaitSecs(0.100);

%% Close Eyetracker
Eyelink('SetOfflineMode');
Eyelink('Command', 'clear_screen 0');
WaitSecs(0.5);
Eyelink('CloseFile');

cd(fullfile(path, 'results', answer{1, 1}))
transferFile(edfFileName, 0, window, backColor, windowRect(4));

sca;
Eyelink('Shutdown');
ShowCursor;
ListenChar;
