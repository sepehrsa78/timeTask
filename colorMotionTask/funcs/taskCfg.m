function cfg = taskCfg()

% Color-Motion Task Configuration
% All editable parameters for the color-motion discrimination task.
% Modify this file to change task behavior.

%% Dot Colors (0-255 RGB)
cfg.colors.color1         = [0 200 0];       % "green" — positive color coherence
cfg.colors.color2         = [200 0 0];       % "red"   — negative color coherence
cfg.colors.white          = [255 255 255];

%% Display Colors (normalized 0-1 for PsychImaging)
cfg.colors.background     = [80 80 80] / 255;
cfg.colors.fix            = [0.75 0.75 0.75];
cfg.colors.feedbackGo     = [0 0.75 0];
cfg.colors.feedbackAbort  = [0.75 0.75 0];
cfg.colors.target         = [0.75 0.75 0.75]; % neutral targets

%% Random Dot Parameters
cfg.dots.aperture         = [0 0 10 10];     % [cx, cy, width, height] in degrees
cfg.dots.speed            = 5;               % degrees per second
cfg.dots.density          = 16.7;            % dots per degree^2 per second
cfg.dots.dotSize          = 3;               % dot size in pixels
cfg.dots.interval         = 3;               % interleaved motion frames

%% Coherence Levels (unsigned, 0-1)
% Both motion and color use the same set.
% Signed coherences are generated automatically:
%   positive motion = upward (90 deg), negative = downward (270 deg)
%   positive color  = green majority,  negative = red majority
cfg.coherences            = [0, 0.032, 0.064, 0.128, 0.256, 0.512];

%% Experimental Design
cfg.nReps                 = 5;               % repetitions per unique condition
cfg.trialsPerBlock        = 0;               % 0 = all trials in one block

%% Timing (seconds)
cfg.timing.fixation       = 0.5;             % fixation duration before stimulus
cfg.timing.maxRT          = 5.0;             % maximum response time
cfg.timing.fixedDuration  = 0;               % 0 = RT mode; >0 = fixed viewing duration
cfg.timing.feedbackDur    = 0.3;             % feedback display duration
cfg.timing.ITI            = 1.0;             % inter-trial interval
cfg.timing.saccadeAccum   = 0.1;             % wait after saccade for fixation check
cfg.timing.fixHold        = 0.1;             % required fixation hold on target

%% Target Parameters (visual degrees)
cfg.targets.eccentricity  = 8;               % horizontal distance from center
cfg.targets.diameter      = 1.5;             % target diameter
cfg.targets.shape         = 'ellipse';       % 'ellipse' or 'rect'
cfg.targets.margin        = 2;               % acceptance window radius

%% Fixation Parameters (visual degrees)
cfg.fixation.diameter     = 0.5;             % fixation cross arm length
cfg.fixation.lineWidth    = 5;               % fixation cross line width (pixels)
cfg.fixation.margin       = 2;               % fixation window radius

%% Monitor Parameters
cfg.monitor.width         = 530;             % monitor width in mm
cfg.monitor.distance      = 600;             % viewing distance in mm
cfg.monitor.refreshRate   = 60;              % monitor refresh rate in Hz

%% Keyboard
cfg.keyBoard.escapeKey    = KbName('ESCAPE');
cfg.keyBoard.spaceKey     = KbName('Space');

end
