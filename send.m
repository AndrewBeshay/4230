function success = send(socket, flag, data);

    Header = "ML ";

    command = strcat(Header, flag, ' ', data);

    fwrite(socket, command);

end