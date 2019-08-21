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
        goWait;
        convBlock:=getConvBlocks();
        Conv2Table convBlock;
        cakeBlock:=getCakeBlock();
        IF cakeBlock.p <> [0,0,0] THEN
            Table2Cake cakeBlock;
            sendBlocks2MatLab;
        ELSE 
            goToTrash;
        ENDIF
        Close mlStream;
        Close mlSend;
    ENDPROC
    
ENDMODULE