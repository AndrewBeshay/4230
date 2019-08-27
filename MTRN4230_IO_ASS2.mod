MODULE MTRN4230_IO_ASS2
    ! Process Variables
    VAR num HaltProcess := 0;    ! When halted Store Current Process
    CONST num RobotIdle := 0;
    CONST num InkPrintOp := 1;
    CONST num BlockMove := 2;
    CONST num Halt := 3;
    CONST num StopProgram := 4;
    VAR bool Halted := FALSE;
    PERS num ConvMoveCalls := 0;
    
    ! Persistant variables from server side variables
    PERS bool ConveyorCompleted := FALSE;
    VAR intnum OpenConv;
    VAR intnum RobotUpdateFromGUI;
    VAR intnum ConvUpdate;
    VAR intnum ConvFillError;
    VAR intnum PeriToGUI;
    VAR intnum SpeedUpdate;
    VAR intnum EStopTrig;
    VAR intnum LightCurtainTrig;
    VAR intnum UpdateSafety;
    ! IO Initialisation Variables and Conveyor Variables
    VAR bool Init := FALSE;
    PERS bool updateGUI := FALSE;
    CONST num ToTable := 1;
    CONST num ToDropOff := 0;
    
    VAR num VacRun := 0;
    VAR num SolRun := 0;
    VAR num ConRun := 0;
    VAR num ConDir := 0;
    
    VAR string tempInk := "";
    
    PROC MAIN()
        WHILE (GUIReady = FALSE) DO
        !Do Nothing
        ENDWHILE
        IF (Init = FALSE) THEN
            CONNECT OpenConv WITH ConvOpened;
            ISignalDI DI10_1, 0, OpenConv;
            CONNECT ConvUpdate WITH ConvUpdateGUI;
            IPers ConveyorCompleted, ConvUpdate;
            CONNECT RobotUpdateFromGUI WITH UpdateRS;
            IPers RecvStringReady, RobotUpdateFromGUI;
            CONNECT ConvFillError WITH EmptyConv;
            IPers ConvMoveCalls, ConvFillError;
            CONNECT PeriToGUI WITH PStatusToGUI;
            IPers updateGUI, PeriToGUI;
            CONNECT SpeedUpdate WITH SpeedToGUI;
            IPers SpeedEE, SpeedUpdate;
            CONNECT UpdateSafety WITH GUISafety;
            InitialiseIOs;
            Halted := FALSE;
            Init := TRUE;
            ProgOperation := 0;
            
        ENDIF
        IF ProgOperation = RobotIdle THEN
            ! Done in RecvStringReady Interrupt
        ELSEIF ProgOperation = InkPrintOp THEN
            ! Done in RecvStringReady Interrupt
        ELSEIF ProgOperation = BlockMove THEN
            ! Done in RecvStringReady Interrupt
        ELSEIF ProgOperation = Halt THEN
            ConveyorStop;
            StopMove;
            SpeedEE := 0;
        ELSEIF ProgOperation = StopProgram THEN
            ProgOperation := RobotIdle;
            StopMove;
            SpeedEE := 0;
            Init := FALSE;
        ENDIF
        
        ERROR
        IF ERRNO = ERR_ROBLIMIT THEN
            ProgOperation := 0;
            Init := FALSE;
            SendString := "RS 3 Robot Extent Exceeded\0A";
            SendStringReady := TRUE;
        ENDIF
    ENDPROC
    
    PROC InkBlockage()
        SuctionOff;
        VacOff;
        MoveToHomePos; 
    ENDPROC
    
    PROC VacOn()
        SetDO DO10_1, 1;
        IF VacRun <> 1 THEN
            VacRun := 1;
            updateGUI := TRUE;
        ENDIF
        
    ENDPROC
    
    PROC InkOn()
        SetDO DO10_1, 1;
        IF VacRun <> 1 THEN
            VacRun := 1;
            updateGUI := TRUE;
        ENDIF
 
    ENDPROC
    
    PROC VacOff()
        SetDO DO10_1, 0;
        IF VacRun <> 0 THEN
            VacRun := 0;
            updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC InkOff()
        SetDO DO10_1, 0;
        IF VacRun <> 0 THEN
            VacRun := 0;
            updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC SuctionOn()
        VacOn;
        SetDO DO10_2, 1;
        IF SolRun <> 1 THEN
            SolRun := 1;
            updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC SuctionOff()
        VacOff;
        SetDO DO10_2, 0;
        IF SolRun <> 0 THEN
            SolRun := 0;
            updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC ConveyorStop()
        SetDO DO10_3, 0;
        SetDO DO10_4, 0;
        IF ConDir <> 0 OR ConRun <> 0 THEN
            ConRun := 0;
            ConDir := 0;
            updateGUI :=TRUE;
        ENDIF
    ENDPROC
    
    PROC ConveyorMove(num direction)
        ConveyorStop;
        OpenConv := 2;
        WHILE OpenConv <> 0 DO
            WaitTime 0.5;
            IF DI10_1 = 0 THEN
                IF OpenConv = 2 THEN
                    TPWrite "Ensure Conveyor Doors are closed properly";
                ENDIF
                OpenConv := 1;
            ELSEIF DI10_1 = 1 THEN
                OpenConv := 0;
            ENDIF
        ENDWHILE
        SetDO DO10_4, direction;
        SetDO DO10_3, 1;
        
        IF ConDir <> direction OR ConRun <> 1 THEN
            ConDir := direction;
            ConRun := 1;
            updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC MoveConvLength()
        ConveyorMove ToTable;
        ! Need To test this time in lab
        ! Ask if want to move conveyor camera width?
        WaitTime 10;
        ConveyorStop;
        ConveyorCompleted := TRUE;
        ConvMoveCalls := 0;
    ENDPROC

    PROC MoveCameraLength()
        ConveyorMove ToTable;
        ! Need To test this time in lab
        ! Ask if want to move conveyor camera width?
        WaitTime 2;
        ConveyorStop;
        ConvMoveCalls := ConvMoveCalls + 1;
        ConveyorCompleted := TRUE;
    ENDPROC
    
    PROC InitialiseIOs()
        MoveToHomePos;
        VacOff;
        SuctionOff;
        ConveyorStop;
        SendString := "";
        RecvString := "";
        ProgOperation := 0;
        SpeedEE := 0;
        GUIReady := FALSE;
        SendStringReady := FALSE;
        RecvStringReady := FALSE;
        Shutdown := FALSE;
    ENDPROC
    
    TRAP PStatusToGUI 
        IF updateGUI = TRUE THEN
            SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
            SendStringReady := TRUE;
            updateGUI := FALSE;
        ENDIF

    ENDTRAP
    
    TRAP ConvOpened
        WHILE DI10_1 = 0 DO
            WaitTime 1;
        ENDWHILE
        MoveConvLength;
    ENDTRAP
    
    TRAP ConvUpdateGUI
        IF ConveyorCompleted = TRUE THEN
            ConveyorCompleted := FALSE;
            SendString := "RS 4\0A";
            SendStringReady := TRUE;
        ENDIF
    ENDTRAP
    
    TRAP UpdateRS
        IF RecvStringReady = TRUE THEN
            IF GUIFlag = 1 THEN
                ! Idle Peripheral Toggle Actions
                IF StrPart(RecvString, 1, 1) = "1" THEN
                    VacOn;
                ELSE
                    VacOff;
                ENDIF
                IF StrPart(RecvString, 2, 1) = "1" THEN
                    SuctionOn;
                ELSE
                    SuctionOff;
                ENDIF
                IF StrPart(RecvString, 4, 1) = "1" THEN
                    ConDir := 1;
                ELSE
                    ConDir := 0;
                ENDIF
                IF StrPart(RecvString, 3, 1) = "1" THEN
                    ConveyorMove ConDir;
                ELSE
                    ConveyorStop;
                ENDIF
            ELSEIF GUIFlag = 2 THEN
                ! Ink Printing or Block Movement Command specific actions
                IF ProgOperation = 1 THEN
                    ! Implement ink printing program
                    tempInk := InkCmdProcess(RecvString);
                    IF tempInk = "Done" THEN
                        SendString := "RS 1 1"+tempInk;
                        SendStringReady := TRUE;
                    ELSEIF tempInk = "Error" THEN
                        SendString := "RS 3 Error in Ink Printing";
                        SendStringReady := TRUE;
                    ENDIF
                ELSEIF ProgOperation = 2 THEN
                    ! Implement Block movement program
                    
                ENDIF
            ELSEIF GUIFlag = 3 THEN
                ! Halt or Shutdown specific actions
                IF StrPart(RecvString, 1, 1) = "0" THEN
                    IF Halted = FALSE THEN
                        HaltProcess := ProgOperation;
                        ProgOperation := Halt;
                        Halted := TRUE;
                    ELSE
                        ProgOperation := HaltProcess;
                        HaltProcess := 0;
                        Halted := FALSE;
                    ENDIF
                ELSE
                    ProgOperation := StopProgram;
                    
                ENDIF
            ELSEIF GUIFlag = 4 THEN
                IF ConvMoveCalls < 5 THEN
                    MoveCameraLength;
                ENDIF
            ELSEIF GUIFlag = 5 THEN
                IF StrMatch(RecvString, 1, "Blocked Ink Ejector") <> StrLen(RecvString)+1 THEN
                    IF Halted = FALSE THEN
                        InkBlockage;
                        HaltProcess := ProgOperation;
                        ProgOperation := Halt;
                        Halted := TRUE;
                    ELSE
                        ProgOperation := HaltProcess;
                        HaltProcess := 0;
                        Halted := FALSE;
                    ENDIF
                ENDIF
            ENDIF
            RecvString := "";
            RecvStringReady := FALSE;
        ENDIF
        RETURN;
    ENDTRAP
    
    TRAP EmptyConv
        SendString := "RS 3 Conveyor Empty, Please Refill";
        SendStringReady := TRUE;
        RETURN;
    ENDTRAP
    
    TRAP SpeedToGUI
        SendString := "RS 2 "+ ValToStr(SpeedEE);
        SendStringReady := TRUE;
        RETURN;
    ENDTRAP
    
    TRAP GUISafety
        ! Dummy Value for now until work out how to access Safety Mechanisms
        SendString := "RS 3 111";
        !IF DO_ESTOP = 0 THEN
        !    
        !ENDIF
        IF UpdateSafety = 1 THEN
            
            UpdateSafety := 0;
        ENDIF
        RETURN;
    ENDTRAP
    
ENDMODULE