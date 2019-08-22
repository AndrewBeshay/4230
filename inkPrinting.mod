MODULE inkPrint
    !Ink printing for MTRN4230
    
    
    PROC InkCmdIn()
        
        VAR string InkCmd;
        VAR string Xval;
        VAR string Yval;
        VAR string Zval;
        VAR string speed;
        VAR string inkStat;
        
        VAR num Xstart;
        VAR num Ystart;
        VAR num Zstart;
        VAR num Vloc;
        VAR num Iloc;
        
        
        VAR num Xlength;
        VAR num Ylength;
        VAR num Zlength;
        
        
        
        VAR num Xpos;
        VAR num Ypos;
        VAR num Zpos;
        VAR bool bold;
        VAR bool ink;
        
        VAR num moveSpeed;
        
        VAR num CmdSize;
        VAR bool check;
        
        SocketReceive client_socket \Str:=InkCmd;
        CmdSize:= StrLen(InkCmd);
        Xstart := StrMatch(InkCmd,1,"X");
        Xend := StrMatch(InkCmd,1,";");
        Ystart := StrMatch(InkCmd,1,"Y");
        Zstart := StrMatch(InkCmd,1,"Z");
        Vloc := StrMatch(InkCmd,1,"V");
        Iloc := StrMatch(InkCmd,1,"I");
        
        Xlength := Ystart - Xstart;
        Ylength := Zstart - Ystart;
        Zlength := Vloc - Zstart;
        
        Xval := StrPart(InkCmd,Xstart+1,Xlength);
        Yval := StrPart(InkCmd,Ystart+1,Ylength);
        Zval := StrPart(InkCmd,Zstart+1,Zlength);
        speed := StrPart(InkCmd,Vloc+1,1);
        inkStat := StrPart(InkCmd,Iloc+1,1);
        

        check := StrToVal(Xval,Xpos);
        check := StrToVal(Yval,Ypos);
        check := StrToVal(Zval,Zpos);
        check := StrToVal(speed,bold);
        check := StrToVal(inkStat,ink);
        
        IF bold
            moveSpeed := 100;
        ELSE
            moveSpeed := 50;
        ENDIF
        
        IF ink
            !Vacuum on
        ELSE
            !Vacuum off
        ENDIF
        
        
        
        MoveL [Xpos Ypos Zpos],  moveSpeed, fine, toolScup
        

    ENDPROC
    
    
    
    
    
    

ENDMODULE