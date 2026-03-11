function [trialList, sessionState] = loadProgress(subjectDir)
% loadProgress  Load saved session state from disk.
%
%   [trialList, sessionState] = loadProgress(subjectDir)
%
%   If a sessionState.mat file exists in subjectDir, loads it and returns
%   the trial list and session state so the task can resume.
%   If no saved state exists, returns empty arrays.
%
%   Outputs:
%       trialList    — struct array of trial conditions (or empty)
%       sessionState — full session state struct (or empty)

trialList    = [];
sessionState = [];

stateFile = fullfile(subjectDir, 'sessionState.mat');
if exist(stateFile, 'file')
    loaded = load(stateFile, 'sessionState');
    sessionState = loaded.sessionState;
    trialList    = sessionState.trialList;
end

end
