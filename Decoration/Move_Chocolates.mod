MODULE Move_Chocolates
    PERS robtarget target:=[[0,409,22.1],[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    VAR Block currBlock;
    
    PROC main()
        moveToCali;
        currBlock:=getConvBlocks();
        Conv2Table currBlock;
        currBlock:=getCakeBlock();
        IF currBlock.arrayLength <> 0 THEN
            Table2Cake currBlock;
        ELSE 
            goToTrash;
        ENDIF
    ENDPROC
ENDMODULE
