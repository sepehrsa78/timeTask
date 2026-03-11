function saveProgress(sessionState, subjectDir)
% saveProgress  Save current session state to disk.
%
%   saveProgress(sessionState, subjectDir)
%
%   Saves the full sessionState struct so the task can be resumed
%   from the exact trial where it left off.

save(fullfile(subjectDir, 'sessionState.mat'), 'sessionState');

% Also save a named copy for easy access
subjectName = sessionState.sInfo{1};
save(fullfile(subjectDir, [subjectName '_data.mat']), 'sessionState');

end
