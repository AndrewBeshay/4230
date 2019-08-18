function coordinates = Main4_MatchBlocks(shapeProps, patternProps)

desiredIdx = find(patternProps.Colour == shapeProps.Colour & patternProps.Shape == shapeProps.Shape);
if length(desiredIdx) > 0
    coordinates.Centroid = patternProps.Centroid(desiredIdx, :);
    coordinates.Orientation = patternProps.Orientation(desiredIdx);
else
    coordinates.Centroid = [];
    coordinates.Orientation = [];
end

end