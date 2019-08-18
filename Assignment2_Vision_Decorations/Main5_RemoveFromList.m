function [patternList, conveyorList] = Main5_RemoveFromList(patternList, conveyorList, coordinatePattern, coordinateConveyor)

distance = sqrt( (patternList(:,3) - coordinatePattern(1)).^2 + (patternList(:,4) - coordinatePattern(2)).^2 );
furthestIdx = find(distance == min(distance));
patternList(furthestIdx,:) = [];

distance = sqrt( (conveyorList(:,1) - coordinateConveyor(1)).^2 + (conveyorList(:,2) - coordinateConveyor(2)).^2 );
furthestIdx = find(distance == min(distance));
conveyorList(furthestIdx,:) = [];

end