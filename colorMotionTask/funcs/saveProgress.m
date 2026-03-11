function saveProgress(sessionState, subjectDir)
% saveProgress  Save current session state to disk (without dot movies).
%
%   saveProgress(sessionState, subjectDir)
%
%   Saves the sessionState struct (excluding dotMovies, which are large
%   and saved separately by saveDotMovies) so the task can be resumed
%   from the exact trial where it left off.

% Exclude dotMovies from per-trial auto-save to keep files small
stateToSave = sessionState;
if isfield(stateToSave, 'dotMovies')
    stateToSave = rmfield(stateToSave, 'dotMovies');
end

save(fullfile(subjectDir, 'sessionState.mat'), 'stateToSave');

% Also save a named copy for easy access
subjectName = sessionState.sInfo{1};
save(fullfile(subjectDir, [subjectName '_data.mat']), 'stateToSave');

end
