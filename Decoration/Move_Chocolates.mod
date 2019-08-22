MODULE Move_Chocolates
    PERS robtarget target:=[[175,-100,147],[0,-0.5,-0.866025,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    VAR Block convBlock;
    VAR Block cakeBlock;
    VAR string mlBlocks;
    VAR iodev mlStream;
    VAR iodev mlSend;
    VAR bool ok;
    
    PROC main()
        Open "HOME:/hello.txt", mlStream\Read;
        Open "HOME:/bye.txt", mlSend\Write;
            
        Cake_Wait:
            moveToHome;
            messageWait;
            mlBlocks := ReadStr(mlStream \Delim:= " ");
            IF mlBlocks = "close" THEN
                GOTO Close_Shop;
            ELSEIF mlBlocks <> "begin" THEN
                GOTO Cake_Wait;
            ENDIF
        
        Conveyer:
            goWait;
            messageWait;
            mlBlocks := ReadStr(mlStream \Delim:= " ");
            IF mlBlocks = "conv" THEN
                convBlock:=getConvBlocks();
                Conv2Table convBlock;
            ELSEIF mlBlocks = "cake" THEN
                sendError(1);
                GOTO Conveyer;
            ELSEIF mlBlocks = "complete" THEN
                GOTO Cake_Wait;
            ELSEIF mlBlocks = "close" THEN
                GOTO Close_Shop;
            ELSE
                GOTO Conveyer;
            ENDIF
                
        Looking:
            goWait;
            messageWait;
            mlBlocks := ReadStr(mlStream \Delim:= " ");
            IF mlBlocks = "cake" THEN
                cakeBlock:=getCakeBlock();
            ELSEIF mlBlocks = "conv" THEN
                sendError(2);
                GOTO Looking;
            ELSE
                GOTO Looking;
            ENDIF
            
            
        Placing:
            IF cakeBlock.p = [0,0,0] THEN
                GOTO Conveyer;
            ELSEIF cakeBlock.p = [0,-409,200] THEN
                goToTrash;
            ELSE
                Table2Cake cakeBlock;
            ENDIF
            sendBlocks2MatLab;
            GOTO Conveyer;
            
        Close_Shop:
            moveToHome;
            Close mlStream;
            Close mlSend;
    ENDPROC
    
ENDMODULE