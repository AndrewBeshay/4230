
function done = ParseMessage(recv)

    recv = char(recv);

    if startsWith(recv, 'RS') 
        recv = strrep(recv, 'RS', '');

        if startsWith(recv, '0')
            recv = strrep(recv, '0 ', '');
            if strlength(recv) == 4
                done = recv;
            end
        elseif startsWith(recv, '1')
            recv = strrep(recv, '1 ', '');
            if strlength(recv) == 1
                done = recv;
            end
        elseif startsWith(recv, '2')
            recv = strrep(recv, '2 ', '');
            done = recv;
        elseif startsWith(recv, '3')
            recv = strrep(recv, '3 ', '');
            if strlength(recv) == 8
                done = recv;
            end
        elseif startsWith(recv, '4')
            recv = strrep(recv, '3 ', '');
            done = recv;
        end
        
end