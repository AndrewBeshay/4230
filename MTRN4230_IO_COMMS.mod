MODULE MTRN4230_IO_COMMS
    VAR bool InitComms := FALSE;
    PERS string host := "127.0.0.1";
    VAR socketdev client_GUI;
    VAR socketdev server;   ! Robot Studio acts as the server
    VAR string receivedData;
    VAR string sendMessage;
    CONST num port := 1025;
    VAR bool keep_listening := TRUE;
    CONST string Finished := "FinishedML";
    
    VAR num checker := 0;

    CONST string GUIHeader := "ML ";
    ! Received Flags
    CONST string UpdateOp :=GUIHeader+"0 ";     
    CONST string TogglePeri:=GUIHeader+ "1 ";
    CONST string FunctionString := GUIheader+"2 ";
    CONST string SpecialOp := GUIHeader+"3 ";
    CONST string ConvRequest := GUIHeader+"4 ";
    CONST string DummyError := GUIHeader+"5 ";
    VAR num HeadLen;
    VAR num ExtractStart;
    ! Send Flags
    ! Strings will be sent to GUI in form:
    ! 1. Header RS
    ! 2. Send Flag
    ! 3. Updated Value
    CONST string RobStatus := "0 "; ! Updata Values: binary made from 4 registers
    CONST string ProgStatus := "1 "; ! 0 = idle, 1 = ink printing, 2 = block decoration, 3= complete shut down, 5 = halt
    CONST string ToolSpeed := "2 "; ! 0 = No movement
    CONST string ErrorStatus := "3 ";
    CONST string ConveyorDone := "4 ";
    CONST string Header := "RS ";
    
    VAR intnum toSend;
    
    PROC MAIN()
        IF InitComms = FALSE THEN
            checker := 0;
            IF RobOS() THEN
                host := "192.168.125.5";
            ELSE
                host := "127.0.0.1";
            ENDIF
            
            SocketCreate server;
            SocketBind server, host, port;
            SocketListen server;
            SocketAccept server, client_GUI \Time:=WAIT_MAX;
            keep_listening := TRUE;
            InitComms := TRUE;
            HeadLen := StrLen(UpdateOp);
            ExtractStart := HeadLen + 1;
            receivedData := "";
            GUIReady := TRUE;
            checker := 1;
        ENDIF
        
        CONNECT toSend WITH SendToGUI;
        IPers SendStringReady, toSend;
        
        WHILE keep_listening DO
            SocketReceive client_GUI \Str:=receivedData;
            checker := 2;
            WaitTime 0.2;
            IF StrMatch(receivedData, 1, UpdateOp) <> StrLen(receivedData)+1 THEN
                checker := 3;
                GUIFlag := 0;
                IF ProgOperation < 2 THEN
                    ProgOperation := ProgOperation+1;
                    SendString := Header+RobStatus+ValToStr(ProgOperation);
                    SendStringReady := TRUE;
                ELSEIF ProgOperation = 3 OR ProgOperation = 4 THEN
                    
                ELSEIF ProgOperation = 2 THEN
                    ProgOperation := 0;
                    SendString := Header+RobStatus+ValToStr(ProgOperation);
                    SendStringReady := TRUE;
                ENDIF
            ELSEIF StrMatch(receivedData, 1, TogglePeri) <> StrLen(receivedData)+1 AND ProgOperation = 0 THEN
                checker := 4;
                GUIFlag := 1;
                RecvString := StrPart(receivedData, ExtractStart, StrLen(receivedData)-HeadLen);
                RecvStringReady := TRUE;
            ELSEIF StrMatch(receivedData, 1, FunctionString) <> StrLen(receivedData)+1 THEN
                checker := 5;
                GUIFlag := 2;
                RecvString := StrPart(receivedData, ExtractStart, StrLen(receivedData)-HeadLen);
                RecvStringReady := TRUE;
            ELSEIF StrMatch(receivedData, 1, Finished) <> StrLen(receivedData)+1 THEN
                checker := 6;
                keep_listening := FALSE;
                InitComms := FALSE;
                SocketClose client_GUI;
                SocketClose server;
                receivedData := "DONE";
                Stop;
                EXIT;
            ELSE
                checker := 7;
                !SocketSend client_GUI \Str:=(receivedData + "\0A");
                !TPWrite receivedData;
                receivedData := "";
            ENDIF

            WaitTime 2;
            checker := 8;
        ENDWHILE
        SocketClose server;
        ERROR
            IF ERRNO = ERR_SOCK_TIMEOUT THEN
                RETRY;
            ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
                SocketClose server;
                !SocketClose client_GUI;
                SocketCreate server;
                SocketBind server, host, port;
                SocketListen server;
                SocketAccept server, client_GUI \Time:=WAIT_MAX;
                RETRY;
            ELSE
                TPWrite "ERRNO = "\Num:=ERRNO;
                SocketClose server;
                SocketClose client_GUI;
                Stop;
            ENDIF
    ENDPROC

    TRAP SendToGUI
        IF SendStringReady = TRUE THEN
            SocketSend client_GUI \Str:=SendString;
            SendString := "";
            SendStringReady := FALSE;
        ELSE
            ! Do Nothing
        ENDIF
        RETURN;
    ENDTRAP
    
ENDMODULE