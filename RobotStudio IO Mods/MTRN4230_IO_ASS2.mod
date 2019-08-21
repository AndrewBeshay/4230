MODULE MTRN4230_IO_ASS2
    ! Process Variables
    VAR intnum ProcessStage := 0;
    VAR intnum HaltProcess := 0;    ! When halted Store Current Process
    CONST intnum RobotIdle := 0;
    CONST intnum InkPrint := 1;
    CONST intnum BlockMove := 2;
    CONST intnum Halt := 5;
    
    ! Persistant variables from server side variables
    
    ! IO Initialisation Variables and Conveyor Variables
    VAR bool Init := false;
    CONST intnum ToTable := 1;
    CONST intnum ToDropOff := 0;
    VAR intnum OpenConv;
    
    PROC MAIN()
        IF (Init = false) THEN
            InitialiseIOs;
            Init := true;
            WaitTime 3;
            MoveConvLength;
            WaitTime 3;
        ENDIF

    ENDPROC
    
    PROC InkBlockage()
        SuctionOff;
        VacOff;
        MoveToHomePos; 
    ENDPROC
    
    PROC DropBlock()
        SuctionOff;
        VacOff;
    ENDPROC
    
    PROC VacOn()
        SetDO DO10_1, 1;
    ENDPROC
    
    PROC VacOff()
        SetDO DO10_1, 0;
    ENDPROC
    
    PROC SuctionOn()
        SetDO DO10_2, 1;
    ENDPROC
    
    PROC SuctionOff()
        SetDO DO10_2, 0;
    ENDPROC
    
    PROC ConveyorStop()
        SetDO DO10_3, 0;
        SetDO DO10_4, 0;
    ENDPROC
    
    PROC ConveyorMove(intnum direction)
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
    ENDPROC
    
    PROC MoveConvLength()
        ConveyorMove ToTable;
        ! Need To test this time in lab
        ! Ask if want to move conveyor camera width?
        WaitTime 10;
        ConveyorStop;
    ENDPROC

    PROC MoveCameraLength()
        ConveyorMove ToTable;
        ! Need To test this time in lab
        ! Ask if want to move conveyor camera width?
        WaitTime 2;
        ConveyorStop;
    ENDPROC
    
    PROC InitialiseIOs()
        VacOff;
        SuctionOff;
        ConveyorStop;
        MoveToCalibPos;
    ENDPROC
    
    PROC PickUpBlock()
        VacOn;
        ! Move down to pick up?
        SuctionOn;
    ENDPROC
    
ENDMODULE