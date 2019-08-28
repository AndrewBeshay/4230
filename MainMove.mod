MODULE MainMove
    
    PERS string Command;
    PERS string Data;
    PERS string SendData;
    PERS num Complete;
    VAR byte ConvMask := 3;
    VAR byte VacMask := 12;
    VAR byte IOData;
    
    PROC Main_Move()
        
        WHILE TRUE DO
            TEST Command
            CASE "0":
                IOData := StrToByte(Data\Bin);
                TEST BitAnd(ConvMask, IOData)
                CASE 0:
                    TurnConOff;
                    SetDO DO10_4, 1;
                CASE 1:
                    SetDO DO10_4, 0;
                CASE 2:
                    TurnConOff;
                    SetDO DO10_4, 1;
                    TurnConOnSafely;
                CASE 3:
                    TurnConOff;
                    SetDO DO10_4, 0;
                    TurnConOnSafely;
                ENDTEST
                
                TEST BitAnd(VacMask, IOData)
                CASE 0:
                    VacSolOff;
                    TurnVacOff;
                CASE 4:
                    TurnVacOff;
                    VacSolOn;
                CASE 8:
                    TurnVacOn;
                    VacSolOff;
                CASE 12:
                    TurnVacOn;
                    VacSolOff;
                ENDTEST
                
                Complete := 1;
                
            CASE "1":
            
            CASE "2":
            
            CASE "3":
            
            CASE "4":
            
            DEFAULT:
            
            ENDTEST
        ENDWHILE
        
    ENDPROC
    
    PROC TurnVacOn()
        ! Set VacRun on.
        SetDO DO10_1, 1;
    ENDPROC
    
    PROC TurnVacOff()
        ! Set VacRun off.
        SetDO DO10_1, 0;
    ENDPROC
    
    PROC VacSolOn()
        ! Set Vacuum Solenoid Open
        
    ENDPROC
    
    PROC VacSolOff()
        ! Set Vacuum Solenoid Closed
        
    ENDPROC
    
    PROC TurnConOnSafely()
        ! An example of how an IF statement is structured.
        ! DI10_1 is 'ConStat', and will only be equal to 1 if the conveyor is on and ready to run.
        ! If it is ready to run, we will run it, if not, we will set it off so that we can fix it.
        IF DI10_1 = 1 THEN
            SetDO DO10_3, 1;
        ELSE
            SetDO DO10_3, 0;
        ENDIF
        
    ENDPROC
    
    PROC TurnConOff()
        SetDO DO10_3, 0;
    ENDPROC
    
    
ENDMODULE