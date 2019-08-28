MODULE MTRN4230_Server_Sample    

    ! The socket connected to the client.
    VAR socketdev client_socket;
    
    ! The host and port that we will be listening for a connection on.
    PERS string host := "192.168.125.1";
    PERS string Command := "";
    PERS string Data := "";
    PERS string SendData := "";
    PERS num Complete := 0;
    CONST string RSHeader := "RS ";
    CONST num port := 1025;
    
    PROC Main ()
        IF RobOS() THEN
            host := "192.168.125.1";
        ELSE
            host := "127.0.0.1";
        ENDIF
        MainServer;
        
    ENDPROC

    PROC MainServer()
        
        VAR string received_str;
        
        ListenForAndAcceptConnection;
        WHILE TRUE DO
            ParseAndRespond;
        ENDWHILE
        ! Receive a string from the client.
        !SocketReceive client_socket \Str:=received_str;
            
        ! Send the string back to the client, adding a line feed character.
        !SocketSend client_socket \Str:=(received_str + "Very Interesting\0a");
        !SocketSend client_socket \Str:=("RS 2 DONE");

        CloseConnection;
		
    ENDPROC

    PROC ListenForAndAcceptConnection()
        
        ! Create the socket to listen for a connection on.
        VAR socketdev welcome_socket;
        SocketCreate welcome_socket;
        
        ! Bind the socket to the host and port.
        SocketBind welcome_socket, host, port;
        
        ! Listen on the welcome socket.
        SocketListen welcome_socket;
        
        ! Accept a connection on the host and port.
        SocketAccept welcome_socket, client_socket \Time:=WAIT_MAX;
        
        ! Close the welcome socket, as it is no longer needed.
        SocketClose welcome_socket;
        
    ENDPROC
    
    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose client_socket;
    ENDPROC
        
    PROC ParseAndRespond()
        VAR string RecvString := "";
        VAR string SendString := "";
        VAR string HeaderTrap := "";
        VAR string FlagTrap := "";
        Complete := 0;
        
        SocketReceive client_socket \Str:=RecvString;
        
        HeaderTrap := StrPart("ML ", 1, 3);
        
        IF HeaderTrap = "ML " THEN
            RecvString := StrMap(RecvString, "ML ", "");
            
            FlagTrap := StrPart(RecvString, 1, 1);
            
            TEST FlagTrap
            CASE "0":
                command := "0";
                !received_str := StrMap(received_str, "0 ", "");
                data := StrMap(RecvString, "0 ", "");  
                SendString := RSHeader + "0 ";
            CASE "1":
                command := "1";
            CASE "2":
                command := "2";
            CASE "3":
                command := "3";
            CASE "4":
                command := "4";
            DEFAULT:
                command := "-1";
            ENDTEST
        ENDIF
        
        WHILE Complete = 0 DO
            
        ENDWHILE
        
        SendString := SendString + SendData;
        
        SocketSend client_socket \Str:=SendString;
        
    ENDPROC
    

ENDMODULE