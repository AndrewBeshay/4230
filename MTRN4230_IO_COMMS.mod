MODULE MTRN4230_IO_COMMS
    VAR bool InitComms := FALSE;
    PERS string host := "192.168.125.1";
    VAR socketdev client_GUI;
    VAR socketdev server;   ! Robot Studio acts as the server
    VAR string receivedData;
    VAR string sendMessage;
    CONST num port := 1025;
    VAR bool keep_listening := TRUE;
    
    ! Received Flags
    CONST intnum GUIFlag := 0;
    CONST intnum InkDetectFlag := 1;
    CONST intnum BlockDetectFlag := 2;
    
    ! Send Flags
    CONST string PumpStatus := "0";
    CONST string SolStatus := "1";
    CONST string ConvOn := "2";
    CONST string ConvDir := "3";
    CONST string ProgStatus := "5";
    CONST string TCPSPeed := "6";
    CONST string ErrorStatus := "7";
    
    PROC Main()
        IF InitComms = FALSE THEN 
            IF RobOS() THEN
                host := "192.168.125.5";
            ELSE
                host := "127.0.0.1";
            ENDIF
            
            SocketCreate server;
            SocketBind server, host, port;
            SocketListen server;
            SocketAccept server, client_GUI \Time:=WAIT_MAX;
        ENDIF
        
        WHILE keep_listening DO
            SocketReceive client_GUI \Str:=receivedData;
            SocketSend client_GUI \Str:=(receivedData + "\0A");
            TPWrite receivedData;
            WaitTime 2;
        ENDWHILE
        
        ERROR
            IF ERRNO = ERR_SOCK_TIMEOUT THEN
                RETRY;
            ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
                SocketClose server;
                SocketClose client_GUI;
                SocketCreate server;
                SocketBind server, host, 1025;
                SocketListen server;
                SocketAccept server, client_GUI;
                RETRY;
            ELSE
                TPWrite "ERRNO = "\Num:=ERRNO;
                !Stop;
            ENDIF
    ENDPROC

    
    
ENDMODULE