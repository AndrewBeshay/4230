function Recieved = SendCommand(cmd, socket)

    query(socket, cmd);
    pause(1);
    Recieved = query(socket, cmd);
    
end