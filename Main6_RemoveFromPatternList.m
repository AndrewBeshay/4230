function [patternProps] = Main6_RemoveFromPatternList(patternProps, coordinatePattern)

% remove from patternProps
if size(patternProps.Shape, 2) > 0
    distance = sqrt( (patternProps.Centroid(:,1) - coordinatePattern(1)).^2 + (patternProps.Centroid(:,2) - coordinatePattern(2)).^2 );
    furthestIdx = find(distance == min(distance));
    patternProps.Colour(furthestIdx) = [];
    patternProps.Shape(furthestIdx) = [];
    patternProps.Centroid(furthestIdx,:) = [];
    patternProps.Orientation(furthestIdx) = [];
end

if size(patternProps.Shape, 2) == 0
    display("The pattern list is empty!");
end

end