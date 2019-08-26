function command = CreateCommand(flag, app)
    
    Header = "ML ";
    
    if flag == 0
        command = strcat(Header, '0 ');
    elseif flag == 1
        command = strcat(Header, '1 ', app.iostatus);    
    elseif flag == 2
        command = strcat(Header, '2 ', app.data);
    elseif flag == 3
        command = strcat(Header, '3 ', app.Special);
    elseif flag == 4
        command = strcat(Header, '4 ');
    elseif flag == 5
        command = strcat(Header, '5 ', app.ErrorMsg);
    else
        command = -1;
    end


end