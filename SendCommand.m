function Recieved = SendCommand(app)

    if isempty(app.Commands)
        app.Commands = [app.Commands CreateCommand(0, app)];
    end

    
    fwrite(app.Socket, app.Commands(1));
    app.Console.Value = {app.Console.Value , strcat('Sent: ',app.Commands(1))};
    app.Commands(1) = [];
    
    pause(1);
    
    Recieved = fgetl(socket);
    
end