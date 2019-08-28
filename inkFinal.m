%% Load struct from image
function inkFinal(app)
%     PxlPoints = ImageProcessing_Final();
    % app.InkCharacters = ImageProcessing_Final();
    app.IDLELabel.Text = "PRINTING";
    app.IDLELabel.FontColor = [0, 1, 1];

    PxlPoints = app.InkCharacters;
    %% Initialisation
    % numChars = numel(PxlPoints);
    numChars = numel(app.InkCharacters);
    tableHeight = 147;
    cakeHeight = 100; %Cake is 10cm high = 100mm
    travelHeight = 50; %Travel moves are a further 50mm higher

    outMtx = zeros(500,5,numChars); %[X,Y,Z,Bold,InkOn] * NumCharsDeep in 3rd Dim


    for charIdx=1:1:numChars
        %RealPoints =  imgPointsToWorld(PxlPoints(charIdx).points(:,1),PxlPoints(charIdx).points(:,2));
        %RealPoints(:,3) = tableHeight + cakeHeight;
        clear RealPoints
        %RealPoints =  tablePxlToReal(PxlPoints(charIdx).points(:,1),PxlPoints(charIdx).points(:,2));
        
        RealPoints(:,1) = PxlPoints(charIdx).points(:,1)*0.6498 - 10.8428;
        RealPoints(:,2) = PxlPoints(charIdx).points(:,2)*0.6578 - 523.5955;
        RealPoints(:,3) = tableHeight + cakeHeight;

        offset = 0;

        for ptRowIdx=1:1:(size(RealPoints,1) - 1)

            deltaXY = sqrt((RealPoints(ptRowIdx+1,1) - (RealPoints(ptRowIdx,1)))^2 ...
                + ((RealPoints(ptRowIdx+1,2)) - (RealPoints(ptRowIdx,2)))^2);
        
            outMtx(ptRowIdx + offset,:,charIdx) = ...
               [RealPoints(ptRowIdx,:) PxlPoints(charIdx).Bold 1]; 
            
            if(deltaXY > 5) %If deltaXY is greater than 5 mm, start new stroke
               outMtx(ptRowIdx + offset + 1,:,charIdx) = ...
                   [RealPoints(ptRowIdx,1) RealPoints(ptRowIdx,2) RealPoints(ptRowIdx,3)+travelHeight PxlPoints(charIdx).Bold 0];

               outMtx(ptRowIdx + offset + 2,:,charIdx) = ...
                   [RealPoints(ptRowIdx+1,1) RealPoints(ptRowIdx+1,2) RealPoints(ptRowIdx+1,3)+travelHeight PxlPoints(charIdx).Bold 0];


                   offset = offset+2;


          % outMtx(ptRowIdx + offset,:,charIdx) = ...
           %    [RealPoints(ptRowIdx,:) PxlPoints(charIdx).Bold 1];

        %else
          % outMtx(ptRowIdx + offset,:,charIdx) = ...
           %    [RealPoints(ptRowIdx,:) PxlPoints(charIdx).Bold 1]; 


                 end

        end

    end


    %% Sending to Robot



    command = CreateCommand(0, "");
    app.Commands = QueueCommand(app.Commands, command);

    while app.recieved ~= "1"
        continue;
    end



    inStr = "";
    outStr = "InkHome";
    command = CreateCommand(2, outStr);
    app.Commands = QueueCommand(app.Commands, command);
    % recv = SendCommand(app);
    UpdateConsole(app, char(app.recieved));
    % app.recieved = ParseMessage(recv);
    while (app.recieved ~= "DONE")
        command = CreateCommand(2, outStr);
        app.Commands = QueueCommand(app.Commands, command);
        % recv = SendCommand(app);
        UpdateConsole(app, char(app.recieved));
        % recv = ParseMessage(recv);
    end

    app.recieved = "";

    for charIdx=1:1:numChars
        inkFlowOld = 0;
        for rowIdx = 1:1:size(outMtx,1)
            inkFlow = outMtx(rowIdx,5,charIdx);
            if inkFlow ~= inkFlowOld && inkFlow == 1
                %Turn ink on

                outStr = "Ink1";
            elseif inkFlow ~= inkFlowOld && inkFlow == 0
                %Turn ink off
                outStr = "Ink0";
            end
            
            command = CreateCommand(2, outStr);
            app.Commands = QueueCommand(app.Commands, command);
            recv = SendCommand(app);

                outStr = num2str(dec2bin(bitset(app.iostatus, 4, 1)));
            elseif inkFlow ~= inkFlowOld && inkFlow == 0
                %Turn ink off
                outStr = num2str(dec2bin(bitset(app.iostatus, 4, 0)));
            end
        
            command = CreateCommand(2, outStr);
            app.Commands = QueueCommand(app.Commands, command);
            % recv = SendCommand(app);

            
            
            outStr = sprintf("X%3.3fY%3.3fZ%3.3fV%1i",...
                outMtx(rowIdx,1,charIdx),outMtx(rowIdx,2,charIdx),outMtx(rowIdx,3,charIdx),...
                outMtx(rowIdx,4,charIdx));


            if(sum(outMtx(rowIdx,:,charIdx)) == 0)
                %String out to turn off ink and return to ink printing home
                outStr = "InkHome";
                continue; 
            end

            %%Add code here to send to robot via TCP 
            command = CreateCommand(2, outStr);
            app.Commands = QueueCommand(app.Commands, command);
            % recv = SendCommand(app);
            %Wait/check response
            % inStr = "";
            if(app.recieved ~= "Done")
                break;
           end
           inkFlowOld = inkFlow;
        end

        outStr = "InkHome";
        command = CreateCommand(2, outStr);
        app.Commands = QueueCommand(app.Commands, command);

        while app.recieved ~= "Done"
            continue;
        end
        % recv = SendCommand(app);
        %Send to Robot
    end

    outStr = "Finish";
    command = CreateCommand(2, outStr);
    app.Commands = QueueCommand(app.Commands, command);
    %Send to Robot
    
    %{
    % New version, with text file
    fileID = fopen('inkPrintCmdList.txt','w');
    stringOut = 'CONST jointtarget WriteStart := [[0,0,0,0,90,0],[9E9,9E9,9E9,9E9,9E9,9E9]];\n';
    fprintf(fileID,stringOut);
    stringOut = 'VAR num Xpos;\n VAR num Ypos;\n VAR num Zpos; \n ';
    fprintf(fileID,stringOut);
    stringOut = 'VAR pos targetPos;\n VAR robtarget targetFull;\n';
    fprintf(fileID,stringOut);    
    stringOut = 'MoveAbsJ WriteStart , v500 , fine , tSCup;\n';
    fprintf(fileID,stringOut);
    
    inkStatOld = 0;
    
    for charIdx=1:1:numChars
        rowNum = 1;
        while (sum(outMtx(rowNum,:,charIdx)) ~= 0)
            Xpos = outMtx(rowNum,1,charIdx);
            Ypos = outMtx(rowNum,2,charIdx);
            Zpos = outMtx(rowNum,3,charIdx);
            Speed = outMtx(rowNum,4,charIdx);
            inkStatCur = outMtx(rowNum,5,charIdx);
            
            stringOut = sprintf('targetPos := [%3.3f,%3.3f,%3.3f];\n',Xpos,Ypos,Zpos);
            fprintf(fileID,stringOut);
            stringOut = 'targetFull := [targetPos,[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];\n';
            fprintf(fileID,stringOut);
            
            if inkStatCur ~= inkStatOld && inkStatCur == 1
                stringOut = '! Turn ink on. \n';
                fprintf(fileID,stringOut);
            elseif inkStatCur ~= inkStatOld && inkStatCur == 0
                 stringOut = '! Turn ink off. \n';
                fprintf(fileID,stringOut);   
            end
            
            if Speed == 0
                stringOut = 'MoveL targetFull , v50 , z1, tSCup;\n';
                fprintf(fileID,stringOut);
            else
                stringOut = 'MoveL targetFull , v100 , z1, tSCup;\n';
                fprintf(fileID,stringOut);
            end
            
            inkStatOld = inkStatCur;
            rowNum = rowNum+1;
            
        end
        
        stringOut = '!Ink Off \n MoveAbsJ WriteStart , v500 , fine , tSCup;\n';
        fprintf(fileID,stringOut);
    end
    %stringOut = 'MoveAbsJ WriteStart , v500 , fine , tSCup;\n';
    %fprintf(fileID,stringOut);
    
    fclose(fileID);
    %}

    while (app.recieved ~= "DONE")
        command = CreateCommand(2, outStr);
        app.Commands = QueueCommand(app.Commands, command);

    end
    
    app.recieved = "";

    app.InkPrintingLamp.Color = [0, 1, 0];
    UpdateConsole(app, "Ink Printing Completed");
    app.IDLELabel.Text = "IDLE";


end
