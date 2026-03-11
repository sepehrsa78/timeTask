%% Color-Motion Discrimination Task (State Machine)
%  Randomly moving dots with random color (green/red).
%  Subject integrates signed motion coherence and signed color coherence
%  to saccade to left or right target.
%
%  Rule (XOR mapping):
%    Up + Green   -> RIGHT     Down + Red   -> RIGHT
%    Down + Green -> LEFT      Up + Red     -> LEFT
%
%  State machine architecture: TRIAL_SETUP -> FIXATION -> DOTS -> FEEDBACK -> ITI
%  ESCAPE pauses after current trial finishes (Resume / Recalibrate / Quit)

%% Refreshing the Workspace
sca
close all
clear
clear global
clc
ListenChar

addpath(genpath('funcs'))
basePath = pwd;
rng('shuffle');

%% Subject Information
prompt         = 'Is this the first session?';
sessionInfo    = 'Subject Information';
isFirstSession = questdlg(prompt, sessionInfo, 'Yes', 'No', '');
isFirstSession = strcmpi(isFirstSession, 'Yes');

%% Load Configuration
cfg = taskCfg();

if isFirstSession
    prompt   = {'Subject Name:', 'Subject Number:', 'Age:', 'Gender:', 'Hand:', 'Demo:'};
    dlgtitle = 'Subject Information';
    dims     = [1 35];
    answer   = inputdlg(prompt, dlgtitle, dims);
    ListenChar(2)

    subjectDir = fullfile(basePath, 'results', answer{1});
    if ~exist(subjectDir, 'dir')
        mkdir(subjectDir)
    end

    % Build fresh trial list
    isDemo    = strcmp(answer{6}, '1');
    trialList = buildTrialList(cfg, isDemo);

    % Initialize session state
    sessionState.trialList    = trialList;
    sessionState.currentTrial = 1;
    sessionState.trialData    = {};
    sessionState.sInfo        = answer;
    sessionState.cfg          = cfg;
    sessionState.setNumber    = 1;
    sessionState.segmentNum   = 1;
else
    % Resume existing session
    dataDir = dir('./results/');
    names   = {};
    for iFolder = 3:length(dataDir)
        names{end+1} = dataDir(iFolder).name; %#ok<SAGROW>
    end
    names       = char(names);
    idx         = listdlg('ListString', cellstr(names));
    subjectName = deblank(names(idx, :));
    subjectDir  = fullfile(basePath, 'results', subjectName);

    [trialList, sessionState] = loadProgress(subjectDir);

    if isempty(sessionState)
        error('No saved session found for %s', subjectName);
    end

    answer = sessionState.sInfo;
    cfg    = sessionState.cfg;
    ListenChar(2)
end

%% Initialize Eyetracker
edfFileName = sprintf('%s_S%d', answer{2}, sessionState.segmentNum);
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

%% Start Recording
Eyelink('SetOfflineMode');
Eyelink('StartRecording');
WaitSecs(0.010);
sessionState.startTime = GetSecs();

%% Show start prompt
promptStr = sprintf('Color-Motion Task\nTrial %d / %d\nPress any key to start', ...
    sessionState.currentTrial, length(sessionState.trialList));
DrawFormattedText(window, promptStr, 'center', 'center', BlackIndex(screenNumber) / 2);
Screen('Flip', window);
KbStrokeWait;
Screen('Flip', window);

%% ====== STATE MACHINE ======
state    = 'TRIAL_SETUP';
trialCtx = struct();

while true
    switch state
        case 'TRIAL_SETUP'
            Priority(topPriorityLevel);
            [state, trialCtx] = stateSetup(cfg, sessionState, screenInfo, frameSpecs);

        case 'FIXATION'
            [state, trialCtx] = stateFix(cfg, trialCtx, window, frameSpecs);

        case 'DOTS'
            [state, trialCtx] = stateDots(cfg, trialCtx, window, screenInfo, frameSpecs);

        case 'FEEDBACK'
            [state, trialCtx] = stateFeedback(cfg, trialCtx, window, frameSpecs);

        case 'ITI'
            [state, trialCtx, sessionState] = stateITI(cfg, trialCtx, sessionState, window, frameSpecs);
            Priority(0);
            saveProgress(sessionState, subjectDir);
            saveDotMovies(sessionState, subjectDir, cfg.dotMovieBatchSize, screenInfo);

        case 'PAUSE'
            Priority(0);
            saveDotMovies(sessionState, subjectDir, 0, screenInfo);  % force save before pause
            [state, sessionState] = statePause(cfg, sessionState, window, el, width, height, backColor, subjectDir);

        case 'SET_COMPLETE'
            Priority(0);
            [state, sessionState] = stateSetComplete(cfg, sessionState, window);

        case 'FINISH'
            Priority(0);
            break
    end
end

%% Final Save
saveDotMovies(sessionState, subjectDir, 0, screenInfo);  % force save remaining dot movies
saveProgress(sessionState, subjectDir);

%% Task Finished Prompt
promptStr = sprintf('Session complete.\n%d trials recorded.', length(sessionState.trialData));
DrawFormattedText(window, promptStr, 'center', 'center', BlackIndex(screenNumber) / 2);
Screen('Flip', window);
WaitSecs(0.5);

%% Close Eyetracker
Eyelink('StopRecording');
Eyelink('SetOfflineMode');
Eyelink('Command', 'clear_screen 0');
WaitSecs(0.5);
Eyelink('CloseFile');

cd(subjectDir)
transferFile(edfFileName, 0, window, backColor, windowRect(4));

sca;
Eyelink('Shutdown');
ShowCursor;
ListenChar;
