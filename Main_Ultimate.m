function Main_Ultimate(app)

conveyorList = [];
patternProps = [];
done = 0;

while(~done)
    if size(conveyorList,1) == 0
        % indicate to move conveyor
        % and wait for a return (while loop) if not detected
        % continue
        conveyorList = Main1_DetectBlocksOnConveyor();
    end 
    
    if size(patternProps.Shape, 2) == 0
        display("The Pattern is complete!, please insert another");
        UpdateConsole(app, "Block Decorating Complete");
        app.CakeDecorationLamp.Color = [0, 1, 0];
        done = 1;
        break;
        % wait until there is a new pattern
        % patternProps = Main3_IdentifyShapesInPattern();
    end
    
    % send conveyorList(1,:)
    % command = CreateCommand(2, "InkHome");
    % app.Commands = QueueCommand(app.Commands, command);
    % recv = SendCommand(app);
    
    % move block from conveyor to transfer section of the table
    % expect a return to indicate completion of moving from conveyor
    % to transfer section
    [conveyorList] = Main5_RemoveFromConveyorList(conveyorList, conveyorList(1,:));
        
    shapeProps = Main2_IdentifyBlock();
    if size(shapeProps.Centroid,1) == 0
        % nothing on the table, do nothing
        display("Table is empty");
        command = CreateCommand(2, "0 0 0 0");
        app.Commands = QueueCommand(app.Commands, command);
        recv = SendCommand(app);

        % send [0, 0, 0, 0]
        % wait for response
    else
        
        if size(shapeProps.Shape,1) == 0
            % shape is unrecognisable
            display("The shape and colour is unrecognisable");
            command = CreateCommand(2, "0 -409 200 0");
            app.Commands = QueueCommand(app.Commands, command);
            recv = SendCommand(app);
            % move to bin, send [0, -409, 200, 0]
            % wait for response
        else 
            destCoordinates = Main4_MatchBlocks(shapeProps, patternProps);
            if size(destCoordinates, 1) > 0
                % match found
                command = CreateCommand(2, destCoordinate(1,:));
                app.Commands = QueueCommand(app.Commands, command);
                recv = SendCommand(app);
                % send destCoordinate(1,:)
                % move pattern, wait for indication of completion
                [patternProps] = Main6_RemoveFromPatternList(patternProps, destCoordinates(1,:));
            else 
                % match not found
                command = CreateCommand(2, "0 -409 200 0");
                app.Commands = QueueCommand(app.Commands, command);
                recv = SendCommand(app);
                % move to bin, send [0, -409, 200, 0]
                % wait for response
            end
            
        end
        
    end
            
       
end


end