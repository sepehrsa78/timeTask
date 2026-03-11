function dot_pos = generateDots(cfg, motionDir, motionCoh, colorDir, colorCoh, screenInfo)
% generateDots  Pre-generate random dot positions with motion and color coherence.
%
%   dot_pos = generateDots(cfg, motionDir, motionCoh, colorDir, colorCoh, screenInfo)
%
%   Adapted from rig_files/dots_2d_col/generate2Ddots.m
%   Generates dots within a circular aperture with coherent motion and
%   independent color assignment per frame.
%
%   Inputs:
%       cfg        — task configuration struct (from taskCfg.m)
%       motionDir  — motion direction in degrees (90 = up, 270 = down)
%       motionCoh  — unsigned motion coherence [0–1]
%       colorDir   — 1 = color1 majority (green), 2 = color2 majority (red)
%       colorCoh   — unsigned color coherence [0–1], used as probability
%       screenInfo — struct with fields: pix_per_deg, mon_refresh
%
%   Output:
%       dot_pos    — [ndots x 3 x nFrames] array
%                    dim2: [x_pix, y_pix, color_code]
%                    color_code: 0=white, 1=color1, 2=color2

%% Extract parameters
aperture  = cfg.dots.aperture;       % [cx, cy, width, height] in degrees
speed     = cfg.dots.speed;          % deg/s
density   = cfg.dots.density;        % dots/deg^2/s
interval  = cfg.dots.interval;       % interleaved frames (usually 3)
pix_per_deg = screenInfo.pix_per_deg;
mon_refresh = screenInfo.mon_refresh;

% Duration to pre-generate (seconds)
duration = cfg.timing.maxRT + 1;
if cfg.timing.fixedDuration > 0
    duration = max(duration, cfg.timing.fixedDuration + cfg.timing.maxRT + 1);
end

%% Calculate number of dots
% Circular aperture area: pi/4 * width * height
ndots = round(density * (aperture(3) * aperture(4)) * (pi / 4) / mon_refresh);

%% Motion displacement per frame
dot_angle = pi * motionDir / 180;
dxdy = repmat(speed * interval / mon_refresh * ...
    [cos(dot_angle) -sin(dot_angle)], ndots, 1) * pix_per_deg;

%% Aperture radius in pixels
ap_radius = aperture(3:4) / 2 * pix_per_deg;
d_ppd = repmat(ap_radius, ndots, 1);

%% Initialize random number generator
rng('shuffle');

%% Total number of frames
nFrames = ceil(mon_refresh * (duration + 1));

%% Pre-fill the first n=interval frames with random positions
dot_pos = nan(ndots, 3, nFrames);
for j = 1:interval
    r     = sqrt(rand(ndots, 1));
    theta = 2 * pi * rand(ndots, 1);
    x_pos = r .* cos(theta);
    y_pos = r .* sin(theta);
    dot_pos(:, 1:2, j) = [x_pos y_pos] .* d_ppd;
end

%% Generate remaining frames with coherent motion
for f = interval + 1 : nFrames
    % Coherent dots: move from position interval frames ago
    L = rand(ndots, 1) < motionCoh;
    dot_pos(L, 1:2, f) = dot_pos(L, 1:2, f - interval) + dxdy(L, :);

    % Check which dots are outside the aperture
    [~, displacedR] = cart2pol(dot_pos(:, 1, f), dot_pos(:, 2, f));
    M = isnan(displacedR) | displacedR > d_ppd(:, 1);
    n_new = sum(M);

    % Replace out-of-aperture and incoherent dots with new random positions
    r_new     = sqrt(rand(n_new, 1));
    theta_new = 2 * pi * rand(n_new, 1);
    x_new     = r_new .* cos(theta_new);
    y_new     = r_new .* sin(theta_new);
    dot_pos(M, 1:2, f) = [x_new y_new] .* d_ppd(M, :);
end

%% Assign color to each dot per frame (independent of motion)
% Color coherence is used directly as probability p
col_p = 0.5 + colorCoh / 2;  % maps [0,1] coherence to [0.5,1] probability

for fr = 1:nFrames
    Lc = rand(ndots, 1) < col_p;
    if colorDir == 1       % majority is color1 (green)
        dot_pos(Lc,  3, fr) = 1;
        dot_pos(~Lc, 3, fr) = 2;
    elseif colorDir == 2   % majority is color2 (red)
        dot_pos(Lc,  3, fr) = 2;
        dot_pos(~Lc, 3, fr) = 1;
    else                   % no color (all white)
        dot_pos(:, 3, fr) = 0;
    end
end

end
