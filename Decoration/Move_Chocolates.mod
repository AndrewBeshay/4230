MODULE Move_Chocolates
    PERS robtarget target:=[[0,409,22.1],[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS string currStage:= "Waiting for Conveyor";
    PERS Block convBlock;
    PERS Block cakeBlock;
    VAR string mlBlocks;
    VAR iodev mlStream;
    VAR iodev mlSend;
    VAR bool posValid;
    VAR bool oriValid;

    PROC main()
        Open "HOME:/hello.txt", mlStream\Read;
        Open "HOME:/bye.txt", mlSend\Write;
            
        IF currStage = "Waiting for Cake" THEN
            GOTO Cake_Wait;
        ELSEIF currStage = "Waiting for Conveyor" THEN
            GOTO Conveyor;
        ELSEIF currStage = "Waiting for Results" THEN
            GOTO Looking;
        ELSE
            GOTO Done;
        ENDIF
        
        Cake_Wait:
            moveToHome;
            mlBlocks := ReadStr(mlStream \Delim:= " ");
            IF mlBlocks = "begin" THEN
                goWait;
                currStage:= "Waiting for Conveyor";
            ENDIF
            GOTO Done;
        
        Conveyor:
            mlBlocks := ReadStr(mlStream \Delim:= " ");
            IF mlBlocks = "conv" THEN
                convBlock:=getConvBlocks();
                IF posValid AND oriValid THEN
                Conv2Table convBlock;
                goWait;
                currStage := "Waiting for Results";
                ELSE
                    sendError(3);
                ENDIF
            ELSEIF mlBlocks = "cake" THEN
                sendError(1);
            ELSEIF mlBlocks = "complete" THEN
                moveToHome;
                currStage:= "Waiting for Cake";
            ELSE
                sendError(4);
            ENDIF
            GOTO Done;
                
        Looking:
            mlBlocks := ReadStr(mlStream \Delim:= " ");
            IF mlBlocks = "cake" THEN
                cakeBlock:=getCakeBlock();
                IF posValid AND oriValid THEN
                    GOTO Placing;
                ELSE
                    sendError(3);
                    GOTO Done;
                ENDIF
            ELSEIF mlBlocks = "conv" THEN
                sendError(2);
            ELSE
                sendError(4);
            ENDIF
            GOTO Done;
            
            
        Placing:
            IF cakeBlock.p = [0,0,0] THEN
                ! Nothing
            ELSEIF cakeBlock.p = [0,-409,200] THEN
                goToTrash;
            ELSE
                Table2Cake cakeBlock;
            ENDIF
            sendBlocks2MatLab;
            goWait;
            currStage := "Waiting for Conveyor";
            
        Done:
            Close mlStream;
            Close mlSend;
    ENDPROC
    
ENDMODULE