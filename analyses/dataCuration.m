%% Refresh Workspace

clear
clc
%% Load Data

dataPath    = 'F:\#2 MS Projects\Ongoing\timePerception\analysis\Data';
infoPath    = 'F:\#2 MS Projects\Ongoing\timePerception\dataInfo';
dataList    = deblank(string(ls(dataPath)));
dataList    = dataList(3:end);
idx         = listdlg('ListString', dataList); 
subjectName = dataList(idx);
load(fullfile(dataPath, subjectName, strcat(subjectName, "_data.mat")));
clear idx
%% Space and Time Data Selection

spaceData = [];
timeData  = [];

for iBlock = 1:size(sData.Blocks, 2)
    for iTrial = 1:size(sData.Blocks(iBlock).Trials, 1)
        sData.Blocks(iBlock).Trials(iTrial).blockNum = iBlock;
    end
end

for i = 1:size(sData.Blocks, 2)
    switch sData.blockType{i}
        case 'space'
            spaceData = vertcat(spaceData, sData.Blocks(i).Trials);
        case 'time'
            timeData = vertcat(timeData, sData.Blocks(i).Trials);
    end

end

timeTable  = struct2table(timeData);
spaceTable = struct2table(spaceData);

timeTable(:, "prodDist") = [];
timeTable(cellfun(@isempty, timeTable.RT), :) = [];
spaceTable(cellfun(@isempty, spaceTable.prodDist), :) = [];
%% Subject Info 

if ~exist(fullfile(infoPath, 'subInfo2.csv'), "file")
    vars    = [...
        "name", "ID", "age", "gender", "handedness", "firstBlocks",...
        "lineLoc", "lineOr", "timeWm", "timeWp",...
        "spaceWm_BLS", "spaceWm_MAP", "spaceWp_BLS", "spaceWp_MAP",...
        "AIC_BLS_Space", "AIC_MAP_Space", "BIC_BLS_Space", "BIC_MAP_Space"];
    subInfo  = cell2table(cell(100, length(vars)), 'VariableNames', vars);
end

for i = 1:length(dataList)
    load(fullfile(dataPath, dataList(i), strcat(dataList(i), "_data.mat")));

    if sData.sInfo{7} == '1'
        firstBlocks = 'time';
    else
        firstBlocks = 'space';
    end

    if sData.sInfo{8} == '1'
        lineLoc = 'right';
    else
        lineLoc = 'left';
    end

    if sData.sInfo{9} == '1'
        lineOr = 'up';
    else
        lineOr = 'down';
    end

    row                      = str2double(sData.sInfo{2});
    subInfo.name{row}        = sData.sInfo{1};
    subInfo.ID{row}          = sData.sInfo{2};
    subInfo.age{row}         = sData.sInfo{3};
    subInfo.gender{row}      = sData.sInfo{4};
    subInfo.handedness{row}  = sData.sInfo{5};
    subInfo.firstBlocks{row} = firstBlocks;
    subInfo.lineLoc{row}     = lineLoc;
    subInfo.lineOr{row}      = lineOr;
end
writetable(subInfo, fullfile(infoPath, "subInfo.csv"))
%% Save CSV
    
write(timeTable, fullfile(dataPath, subjectName, strcat(subjectName, "_timeData.csv")))
write(spaceTable, fullfile(dataPath, subjectName, strcat(subjectName, "_spaceData.csv")))