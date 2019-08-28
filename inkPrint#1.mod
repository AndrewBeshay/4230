MODULE inkPrint
    !Ink printing for MTRN4230
    
    !CONST intnum regSpeed := 50; ! Regular speed = 50 mm/sec
    !CONST intnum boldSpeed := 100; !Bold speed = 100 mm/sec
    
    CONST string okay :="Done";
    CONST string problem := "Error!";
    
    FUNC string InkCmdProcess(string InkCmd)
        
        !VAR string InkCmd;
        VAR string Xval; !Store X value (string)
        VAR string Yval; !Store Y value (string)
        VAR string Zval; !Store Z value (string)
        VAR string speed; !Store speed boolean (string)
        !VAR string inkStat; !Store ink boolean (string)
        
        VAR num Xstart; !X coordiate start position in String (number)
        VAR num Ystart; !Y coordiate start position in String (number)
        VAR num Zstart; !Z coordiate start position in String (number)
        VAR num Vloc; !Speed Boolean start position in String (number)
        !VAR num Iloc; !Ink Boolean start position in String (number)
        
        
        VAR num Xlength; !Length of X coordinate value
        VAR num Ylength; !Length of Y coordinate value
        VAR num Zlength; !Length of Z coordinate value
        
        VAR num Xpos; !X coordinate, converted to number
        VAR num Ypos; !Y coordinate, converted to number
        VAR num Zpos; !Z coordinate, converted to number
        VAR bool bold; !Bold boolean, converted to bool
        !VAR bool ink; !Ink boolean, converted to bool
        VAR pos targetPos; !Target position
        VAR robtarget targetFull; !Robot Target for final position
        VAR speeddata moveSpeed; !Value of speed. 50mm/sec for regular, 100mm/sec for bold. Extract from global variables.
        
        VAR num CmdSize;
        VAR bool check;
        
        VAR num inkHomeMove;

        VAR num inkStatOn;
        VAR num inkStatOff;
        
        VAR string retString;
        
        !SocketReceive client_socket \Str:=InkCmd;
        CmdSize:= StrLen(InkCmd);
        
        inkHomeMove := StrMatch(InkCmd,1,"InkHome");

        inkStatOff := StrMatch(InkCmd,1,"Ink0");
        inkStatOn := StrMatch(InkCmd,1,"Ink1");
        IF inkStatOff = 1 THEN
            InkOff;
            retString := okay;
        ELSEIF inkStatOn = 1 THEN
            InkOn;
            retString := okay;
        ELSEIF inkHomeMove = 1 THEN

        IF inkHomeMove = 1 THEN

            InkOff; !Check ink is off
            MoveToInkHome; !Move to Ink Home position (UNSW Calib Pos, w/ End Effector vertically down)
            !Send done string back to MATLAB
            retString := okay;
        ELSE          
            Xstart := StrMatch(InkCmd,1,"X");
            !Xend := StrMatch(InkCmd,1,";");
            Ystart := StrMatch(InkCmd,1,"Y");
            Zstart := StrMatch(InkCmd,1,"Z");
            Vloc := StrMatch(InkCmd,1,"V");
            Iloc := StrMatch(InkCmd,1,"I");
            
            Xlength := Ystart - Xstart - 1;
            Ylength := Zstart - Ystart - 1;
            Zlength := Vloc - Zstart - 1;
            
            Xval := StrPart(InkCmd,Xstart+1,Xlength); !AREA OF CONCERN
            Yval := StrPart(InkCmd,Ystart+1,Ylength);
            Zval := StrPart(InkCmd,Zstart+1,Zlength);
            speed := StrPart(InkCmd,Vloc+1,1);
            !inkStat := StrPart(InkCmd,Iloc+1,1);
            

            check := StrToVal(Xval,Xpos);
            check := StrToVal(Yval,Ypos);
            check := StrToVal(Zval,Zpos);
            check := StrToVal(speed,bold);
            !check := StrToVal(inkStat,ink);
            
            IF bold = TRUE THEN
                moveSpeed := v50;
                SpeedEE := 50;
            ELSE
                moveSpeed := v100;
                SpeedEE := 100;
            ENDIF
            
!            IF ink = TRUE THEN
!                InkOn; !Ink on turns on the vacuum on to simulate ink printing
!            ELSE
!                InkOff; !Ink off turns off the vacuum to simulate stopping ink printing
!            ENDIF
            
            targetPos := [Xpos,Ypos,Zpos];
            targetFull := [targetPos,[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
            
            
            MoveL targetFull,  moveSpeed, z1, tSCup;
            
            !Send string back to MATLAB to say okay
            retString := okay;
        ENDIF
        RETURN retString;
    ENDFUNC
 

ENDMODULE