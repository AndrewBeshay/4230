function coordinates = Main4_MatchBlocks(shapeProps, patternProps)

desiredIdx = find(patternProps.Colour == shapeProps.Colour & patternProps.Shape == shapeProps.Shape);
if length(desiredIdx) > 0
    display("Match found!");
    coordinates.Centroid = patternProps.Centroid(desiredIdx, :);
    coordinates.Orientation = patternProps.Orientation(desiredIdx);
else
    display("Match not found... Sorry :(");
    coordinates.Centroid = [];
    coordinates.Orientation = [];
end


end