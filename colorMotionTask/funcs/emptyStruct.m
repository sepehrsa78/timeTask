function nullStruct = emptyStruct(struct, fieldsToEmpty)
myCellArray                        = struct2cell(struct);
fieldsToEmptyIndex                 = ismember(fieldnames(struct), fieldsToEmpty);
myCellArray(fieldsToEmptyIndex, :) = {[]};
nullStruct                         = cell2struct(myCellArray, fieldnames(struct), 1);
end