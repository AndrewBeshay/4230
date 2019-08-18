function coordinates = Main4_MatchBlocks(blockProps, patternShapeProps)

desiredIdx = find(patternShapeProps(:,1) == blockProps(1) & patternShapeProps(:,2) == blockProps(2));
if length(desiredIdx) > 1
    coordinates = patternShapeProps(desiredIdx, 3:6);
else
    coordinates = [];
end

end