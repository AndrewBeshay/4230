function command = CreateCommand(flag, data)
    
    Header = "ML ";
    
    if flag == 0
        command = strcat(Header, "0 ");
    elseif flag == 1
        command = strcat(Header, "1 ", data);    
    elseif flag == 2
        command = strcat(Header, "2 ", data);
    elseif flag == 3
        command = strcat(Header, "3 ", data);
    elseif flag == 4
        command = strcat(Header, "4 ");
    elseif flag == 5
        command = strcat(Header, "5 ", data);
    else
        command = -1;
    end

    % command

end