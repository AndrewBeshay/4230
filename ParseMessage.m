
function done = ParseMessage(app)

    app.recieved = char(app.recieved);

    if startsWith(app.recieved, 'RS') 
        app.recieved = strrep(app.recieved, 'RS', '');

        if startsWith(app.recieved, '0')
            app.recieved = strrep(app.recieved, '0 ', '');
            if strlength(app.recieved) == 4
                done = app.recieved;
            end
        elseif startsWith(app.recieved, '1')
            app.recieved = strrep(app.recieved, '1 ', '');

            if startsWith(app.recieved, '1')
                app.recieved = strrep(app.recieved, '1 ', '');
            end
            done = app.recieved;
        elseif startsWith(app.recieved, '2')
            app.recieved = strrep(app.recieved, '2 ', '');
            done = app.recieved;
        elseif startsWith(app.recieved, '3')
            app.recieved = strrep(app.recieved, '3 ', '');

            app.ErrorFlag = 1;
            app.ErrorMsg = app.recieved;
            % if strlength(app.recieved) == 8
            %     done = app.recieved;
            % end
            done = app.recieved;
        elseif startsWith(app.recieved, '4')
            app.recieved = strrep(app.recieved, '3 ', '');
            done = app.recieved;
        end
        done = '-1';
    else
        done = '-1';
    end
        
end