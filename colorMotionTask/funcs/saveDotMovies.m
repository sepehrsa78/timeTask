function saveDotMovies(sessionState, subjectDir, batchSize)
% saveDotMovies  Batch-save dot movies to disk.
%
%   saveDotMovies(sessionState, subjectDir, batchSize)
%
%   Saves the dot movie data (positions + colors for every frame) to a
%   separate file using HDF5 format (-v7.3) since movies can be large.
%   Called every batchSize trials, and also on pause/finish.
%
%   Inputs:
%       sessionState — session state struct containing dotMovies cell array
%       subjectDir   — path to subject's results directory
%       batchSize    — save every N trials (e.g., 100)

if ~isfield(sessionState, 'dotMovies') || isempty(sessionState.dotMovies)
    return
end

% Save on batch boundary, or when explicitly called (batchSize <= 0 forces save)
trialNum = sessionState.currentTrial - 1;  % last completed trial
if batchSize > 0 && mod(trialNum, batchSize) ~= 0
    return
end

dotMovies = sessionState.dotMovies; %#ok<NASGU>
subjectName = sessionState.sInfo{1};
save(fullfile(subjectDir, [subjectName '_dotMovies.mat']), 'dotMovies', '-v7.3');

end
