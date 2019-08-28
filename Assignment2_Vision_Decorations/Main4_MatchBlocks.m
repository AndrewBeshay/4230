function destCoordinates = Main4_MatchBlocks(shapeProps, patternProps)

desiredIdx = find(patternProps.Colour == shapeProps.Colour & patternProps.Shape == shapeProps.Shape);
if length(desiredIdx) > 0
    display("Match found!");
    destCoordinates = [patternProps.Centroid(desiredIdx, :) (shapeProps.Orientation - patternProps.Orientation(desiredIdx))];
else
    display("Match not found... Sorry :(");
    destCoordinates  = [];
end


end