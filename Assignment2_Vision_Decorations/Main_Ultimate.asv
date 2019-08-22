function Main_Ultimate()

conveyorList = [];
patternProps = [];

while(1)
    if size(conveyorList,1) == 0
        % indicate to move conveyor
        % and wait for a return (while loop) if not detected
        % continue
        conveyorList = Main1_DetectBlocksOnConveyor();
    end 
    
    if size(patternProps.Shape, 2) == 0
        display("The Pattern is complete!, please insert another");
        % wait until there is a new pattern
        patternProps = Main3_IdentifyShapesInPattern();
    end
    
    % send conveyorList(1,:)
    
    % move block from conveyor to transfer section of the table
    % expect a return to indicate completion of moving from conveyor
    % to transfer section
        [conveyorList] = Main5_RemoveFromConveyorList(conveyorList, conveyorList(1,:));
        
    shapeProps = Main2_IdentifyBlock();
    if size(shapeProps.Centroid,1) == 0
        % nothing on the table, do nothing
        display("Table is empty");
        % send [0, 0, 0]
    else
        
        if size(shapeProps.Shape,1) == 0
            % shape is unrecognisable
            display("The shape and colour is unrecognisable");
            % move to bin, send [0, -409, 200]
        else 
            destCoordinates = Main4_MatchBlocks(shapeProps, patternProps);
            if size(destCoordinates, 1) > 0
                % match found
                % send destCoordinate(1,:)
                % move pattern, wait for indication of completion
                [patternProps] = Main6_RemoveFromPatternList(patternProps, destCoordinate(1,:));
            else 
                % match not found
                % move to bin, send [0, -409, 200]
                % move pattern, wait for indication of completion
            end
            
        end
        
    end
            
       
end


end