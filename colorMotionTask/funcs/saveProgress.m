function saveProgress(sessionState, subjectDir)
% saveProgress  Save current session state to disk (without dot info).
%
%   saveProgress(sessionState, subjectDir)
%
%   Saves the sessionState struct (excluding save_struct, which is large
%   and saved separately by saveDotMovies) so the task can be resumed
%   from the exact trial where it left off.

% Exclude save_struct from per-trial auto-save to keep files small
stateToSave = sessionState;
if isfield(stateToSave, 'save_struct')
    stateToSave = rmfield(stateToSave, 'save_struct');
end

save(fullfile(subjectDir, 'sessionState.mat'), 'stateToSave');

% Also save a named copy for easy access
subjectName = sessionState.sInfo{1};
save(fullfile(subjectDir, [subjectName '_data.mat']), 'stateToSave');

end
