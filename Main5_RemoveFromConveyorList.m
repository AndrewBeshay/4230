function [conveyorList] = Main5_RemoveFromConveyorList(conveyorList, coordinateConveyor)

% remove from conveyors list
if size(conveyorList,1) > 0
    distance = sqrt( (conveyorList(:,1) - coordinateConveyor(1)).^2 + (conveyorList(:,2) - coordinateConveyor(2)).^2 );
    furthestIdx = find(distance == min(distance));
    conveyorList(furthestIdx,:) = [];
end

if size(conveyorList,1) == 0
    display("The conveyor list is empty!");
end

end