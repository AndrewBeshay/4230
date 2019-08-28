MODULE MTRN4230_IO_ASS2
    ! Process Variables
    CONST num RobotIdle := 0;
    CONST num InkPrintOp := 1;
    CONST num BlockMove := 2;
    CONST num Halt := 3;
    CONST num StopProgram := 4;
    VAR num ConvMoveCalls := 0;
    
    ! Persistant variables from server side variables
    !PERS bool ConveyorCompleted := FALSE;
    !VAR intnum OpenConv;
    !VAR intnum RobotUpdateFromGUI;
    !VAR intnum ConvUpdate;
    !VAR intnum ConvFillError;
    !VAR intnum PeriToGUI;
    VAR intnum SpeedUpdate;
    !VAR intnum EStopTrig;
    !VAR intnum LightCurtainTrig;
    !VAR intnum UpdateSafety;
    ! IO Initialisation Variables and Conveyor Variables
    VAR bool Init := FALSE;
    !PERS bool updateGUI := FALSE;
    CONST num ToTable := 1;
    CONST num ToDropOff := 0;
    
    VAR num VacRun := 0;
    VAR num SolRun := 0;
    VAR num ConRun := 0;
    VAR num ConDir := 0;
    
    VAR string tempInk := "";
    
    VAR bool IntSetup := FALSE;
    
    PROC MAIN()
        WHILE (GUIReady = FALSE) DO
        !Do Nothing
            Init := FALSE;
            WaitTime 1;
        ENDWHILE
        IF IntSetup = FALSE THEN
            !CONNECT OpenConv WITH ConvOpened;
            !ISignalDI DI10_1, 0, OpenConv;
            !CONNECT ConvUpdate WITH ConvUpdateGUI;
            !IPers ConveyorCompleted, ConvUpdate;
            !CONNECT ConvFillError WITH EmptyConv;
            !IPers ConvMoveCalls, ConvFillError;
            !CONNECT PeriToGUI WITH PStatusToGUI;
            !IPers updateGUI, PeriToGUI;
            CONNECT SpeedUpdate WITH SpeedToGUI;
            IPers SpeedEE, SpeedUpdate;
            IntSetup := TRUE;
        ENDIF
        WaitTime 0.2;
        IF (Init = FALSE) THEN            
            InitialiseIOs;
            Halted := FALSE;
            Init := TRUE;            
        ENDIF
        
        ConvOpened;
        UpdateRS;
        RequestedMovement;
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
            SendString := "RS 1 "+ValToStr(ProgOperation);
            StopMove;
            SpeedEE := 0;
            Init := FALSE;
            WaitTime 5;
            ProgOperation := RobotIdle;
            SendString := "RS 1 "+ValToStr(ProgOperation);
        ENDIF
        
        
        ERROR
        IF ERRNO = ERR_ROBLIMIT THEN
            ProgOperation := 0;
            Init := FALSE;
            SendString := "RS 3 Robot Extent Exceeded\0A";
            !SendStringReady := TRUE;
        
        ENDIF
    ENDPROC
    
    PROC InkBlockage()
        SuctionOff;
        VacOff;
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        MoveToHomePos; 
        SendString := "RS 1 "+ValToStr(ProgOperation);
    ENDPROC
    
    PROC VacOn()
        SetDO DO10_1, 1;
        IF VacRun <> 1 THEN
            VacRun := 1;
            !updateGUI := TRUE;
        ENDIF
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
    ENDPROC
    
    PROC InkOn()
        SetDO DO10_1, 1;
        IF VacRun <> 1 THEN
            VacRun := 1;
            !updateGUI := TRUE;
        ENDIF
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
    ENDPROC
    
    PROC VacOff()
        SetDO DO10_1, 0;
        IF VacRun <> 0 THEN
            VacRun := 0;
            !updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC InkOff()
        SetDO DO10_1, 0;
        IF VacRun <> 0 THEN
            VacRun := 0;
            !updateGUI := TRUE;
        ENDIF
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
    ENDPROC
    
    PROC SuctionOn()
        VacOn;
        SetDO DO10_2, 1;
        IF SolRun <> 1 THEN
            SolRun := 1;
            !updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC SuctionOff()
        VacOff;
        SetDO DO10_2, 0;
        IF SolRun <> 0 THEN
            SolRun := 0;
            !updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC ConveyorStop()
        SetDO DO10_3, 0;
        SetDO DO10_4, 0;
        IF ConDir <> 0 OR ConRun <> 0 THEN
            ConRun := 0;
            ConDir := 0;
            !updateGUI :=TRUE;
        ENDIF
    ENDPROC
    
    PROC ConveyorMove(num direction)
        ConveyorStop;
        SetDO DO10_4, direction;
        WaitTime 0.2;
        SetDO DO10_3, 1;
        
        IF ConDir <> direction OR ConRun <> 1 THEN
            ConDir := direction;
            ConRun := 1;
            !updateGUI := TRUE;
        ENDIF
    ENDPROC
    
    PROC MoveConvLength()
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        ConveyorMove ToTable;
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        ! Need To test this time in lab
        ! Ask if want to move conveyor camera width?
        WaitTime 10;
        ConveyorStop;
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        !ConveyorCompleted := TRUE;
        ConvMoveCalls := 0;
    ENDPROC

    PROC MoveCameraLength()
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        ConveyorMove ToTable;
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        ! Need To test this time in lab
        ! Ask if want to move conveyor camera width?
        WaitTime 2;
        ConveyorStop;
        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
        !ConvMoveCalls := ConvMoveCalls + 1;
        !ConveyorCompleted := TRUE;
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
        GUIFlag := 0;
        GUIReady := TRUE;
        SendStringReady := FALSE;
        RecvStringReady := FALSE;
        Shutdown := FALSE;
        ConvMoveCalls := 0;
        AskedForConveyor := FALSE;
    ENDPROC
    
    !TRAP PStatusToGUI 
    !    IF updateGUI = TRUE THEN
    !        SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
    !        !SendStringReady := TRUE;
    !        updateGUI := FALSE;
    !    ENDIF
    !ENDTRAP
    
    PROC ConvOpened()
        VAR bool RecentClose := FALSE;
        IF DI10_1 = 0 THEN
            SendString := "RS 3 Conveyor Door Opened";            
        ENDIF
        WHILE DI10_1 = 0 DO
            WaitTime 1;
            RecentClose := TRUE;
        ENDWHILE
        IF RecentClose = TRUE THEN
            MoveConvLength;
        ENDIF
    ENDPROC
    
    !TRAP ConvUpdateGUI
    !    IF ConveyorCompleted = TRUE THEN
    !        ConveyorCompleted := FALSE;
    !        SendString := "RS 4\0A";
    !        !SendStringReady := TRUE;
    !    ENDIF
    !ENDTRAP
    
    PROC UpdateRS()
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
                SendString := "RS 0 "+ValToStr(VacRun)+ValToStr(SolRun)+ValToStr(ConRun)+ValToStr(ConDir)+"\0A";
            ELSEIF GUIFlag = 2 THEN
                ! Ink Printing or Block Movement Command specific actions
                IF ProgOperation = 1 THEN
                    ! Implement ink printing program
                    tempInk := InkCmdProcess(RecvString);
                    IF tempInk = "Done" THEN
                        SendString := "RS 1 1 "+tempInk;
                        !SendStringReady := TRUE;
                    ELSEIF tempInk = "Error" THEN
                        SendString := "RS 3 Error in Ink Printing";
                        !SendStringReady := TRUE;
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
                        SendString := "RS 1 "+ValToStr(ProgOperation);
                        Halted := TRUE;
                    ELSE
                        ProgOperation := HaltProcess;
                        SendString := "RS 1 "+ValToStr(ProgOperation);
                        HaltProcess := 0;
                        Halted := FALSE;
                    ENDIF
                ELSE
                    ProgOperation := StopProgram;
                ENDIF
            !ELSEIF GUIFlag = 4 THEN
                !SendString := "RS HERE \0A";
                !WaitTime 1;
                !IF ConvMoveCalls <> 5 THEN
                !    MoveCameraLength;
                !    ConvMoveCalls:= ConvMoveCalls + 1;
                !ELSE
                !    SendString := "RS 3 Conveyor Empty, Please Refill\0A";
                !ENDIF
                !GUIFlag := 0;
                !WaitTime 0.5;
                !SendString := "RS 4 \0A";
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
        
    ENDPROC
    
    PROC RequestedMovement()
        IF AskedForConveyor = TRUE THEN
            MoveCameraLength;
            AskedForConveyor := FALSE;
            ConvMoveCalls := ConvMoveCalls + 1;
        ENDIF
        
        IF ConvMoveCalls > 5 THEN
            SendString := "Conveyor Is Empty, Consider Refilling";
        ENDIF
    ENDPROC
    
    !TRAP EmptyConv
    !    SendString := "RS 3 Conveyor Empty, Please Refill";
    !    !SendStringReady := TRUE;
    !    RETURN;
    !ENDTRAP
    
    TRAP SpeedToGUI
        SendString := "RS 2 "+ ValToStr(SpeedEE);
        !SendStringReady := TRUE;
        RETURN;
    ENDTRAP
    
    !TRAP GUISafety
        ! Dummy Value for now until work out how to access Safety Mechanisms
    !    SendString := "RS 3 111";
        !SendStringReady := TRUE;
        !IF DO_ESTOP = 0 THEN
        !    
        !ENDIF
        
    !    IF UpdateSafety = 1 THEN
            
    !        UpdateSafety := 0;
    !    ENDIF
        !SendStringReady := TRUE;
    !    RETURN;
    !ENDTRAP
    
ENDMODULE