function MainUltimate()

conveyorList = Main1_DetectBlocksOnConveyor();
patternProps = Main3_IdentifyShapesInPattern();

while size(conveyorList,1) > 0 && size(patternProps.Shape, 2) > 0
   % move block from conveyor to transfer section of the table
   shapeProps = Main2_IdentifyBlock();
   if size(shapeProps.Centroid,1) == 0
       display("Table is empty");
       % do nothing
   else
       if size(shapeProps.Shape,1) == 0
           display("The shape and colour is unrecognisable");
           % move to bin
       else
           destCoordinates = Main4_MatchBlocks(shapeProps, patternProps);
           % move pattern, wait for indication of completion
           [patternProps, conveyorList] = Main5_RemoveFromList(patternProps, conveyorList, coordinatePattern, coordinateConveyor);
       end
   end
  
end

end