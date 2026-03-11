function trialList = buildTrialList(cfg, isDemo)
% buildTrialList  Generate a shuffled factorial trial list.
%
%   trialList = buildTrialList(cfg, isDemo)
%
%   Creates a fully factorial design of signed motion coherence x signed
%   color coherence, repeated nReps times, and randomly shuffled.
%
%   Inputs:
%       cfg    — task configuration struct (from taskCfg.m)
%       isDemo — boolean; if true, use 1 repetition
%
%   Output:
%       trialList — struct array with one entry per trial

if nargin < 2
    isDemo = false;
end

% Signed coherences: positive = up/green, negative = down/red
unsignedCohs = cfg.coherences;
signedCohs   = [-fliplr(unsignedCohs(2:end)), unsignedCohs];

nLevels = length(signedCohs);

if isDemo
    nReps = 1;
else
    nReps = cfg.nReps;
end

% Full factorial cross
condIdx = 0;
condList = struct([]);

for iM = 1:nLevels
    for iC = 1:nLevels
        condIdx = condIdx + 1;

        mCoh = signedCohs(iM);
        cCoh = signedCohs(iC);

        % Decode signed coherence into direction + unsigned coherence
        if mCoh >= 0
            motionDir = 90;    % upward
        else
            motionDir = 270;   % downward
        end
        motionCohUns = abs(mCoh);

        if cCoh >= 0
            colorDir = 1;      % green majority
        else
            colorDir = 2;      % red majority
        end
        colorCohUns = abs(cCoh);

        % XOR rule: same-sign -> RIGHT, different-sign -> LEFT
        motionSign = sign(mCoh);
        colorSign  = sign(cCoh);

        if motionSign == 0 || colorSign == 0
            % Ambiguous: when one or both dimensions are zero,
            % assign randomly (both targets are equally valid)
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

        condList(condIdx).signedMotionCoh = mCoh;
        condList(condIdx).signedColorCoh  = cCoh;
        condList(condIdx).motionDir       = motionDir;
        condList(condIdx).motionCoh       = motionCohUns;
        condList(condIdx).colorDir        = colorDir;
        condList(condIdx).colorCoh        = colorCohUns;
        condList(condIdx).correctTarget   = correctTarget;
    end
end

% Repeat and shuffle
trialList = repmat(condList, [1 nReps]);
trialList = trialList(randperm(length(trialList)));

end
