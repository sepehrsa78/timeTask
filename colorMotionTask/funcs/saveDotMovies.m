function saveDotMovies(sessionState, subjectDir, batchSize, screenInfo)
% saveDotMovies  Batch-save dot info to disk (rig_files format).
%
%   saveDotMovies(sessionState, subjectDir, batchSize, screenInfo)
%
%   Saves save_struct (containing dots_struct per trial) and screen_struct
%   to disk, matching the rig_files save format.
%   Called every batchSize trials, and also on pause/finish.
%
%   Inputs:
%       sessionState — session state struct containing save_struct cell array
%       subjectDir   — path to subject's results directory
%       batchSize    — save every N trials (e.g., 100); 0 forces immediate save
%       screenInfo   — screen info struct (saved as screen_struct)

if ~isfield(sessionState, 'save_struct') || isempty(sessionState.save_struct)
    return
end

% Save on batch boundary, or when explicitly called (batchSize <= 0 forces save)
trialNum = sessionState.currentTrial - 1;  % last completed trial
if batchSize > 0 && mod(trialNum, batchSize) ~= 0
    return
end

save_struct   = sessionState.save_struct; %#ok<NASGU>
screen_struct = screenInfo; %#ok<NASGU>
subjectName   = sessionState.sInfo{1};
save(fullfile(subjectDir, [subjectName '_dotInfo.mat']), 'save_struct', 'screen_struct', '-v7.3');

end
