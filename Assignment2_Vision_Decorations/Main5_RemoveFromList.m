function [patternProps, conveyorList] = Main5_RemoveFromList(patternProps, conveyorList, coordinatePattern, coordinateConveyor)

% remove from patternProps
if size(patternProps.Shape, 2) > 0
    distance = sqrt( (patternProps.Centroid(:,1) - coordinatePattern(1)).^2 + (patternProps.Centroid(:,2) - coordinatePattern(2)).^2 );
    furthestIdx = find(distance == min(distance));
    patternProps.Colour(furthestIdx) = [];
    patternProps.Shape(furthestIdx) = [];
    patternProps.Centroid(furthestIdx,:) = [];
    patternProps.Orientation(furthestIdx) = [];
else 
    display("The pattern list is empty!");
end

% remove from conveyors list
if size(conveyorList,1) > 0
    distance = sqrt( (conveyorList(:,1) - coordinateConveyor(1)).^2 + (conveyorList(:,2) - coordinateConveyor(2)).^2 );
    furthestIdx = find(distance == min(distance));
    conveyorList(furthestIdx,:) = [];
else
    display("The conveyor list is empty!");
end

end