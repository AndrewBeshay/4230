%% Initiate connection to Robot

function [socket, Err] = connect()
    % Script to communicate with IRB120 robot system
    % Mark Whitty, Zhihao Zhang
    % 140324

    Robot_IP = '192.168.125.1'; % Real robot ip address
    Simulate_IP = '127.0.0.1';  % Simulation ip address

    % The port that the robot will be listening on. This must be the same as in
    % your RAPID program.
    PORT = 1025;
    
    Err = 0;
    % Open a TCP connection to the robot
    connected = 0;

    while ~connected
        socket = tcpip(Robot_IP, PORT);
        set(socket, 'ReadAsyncMode', 'continuous');

        if(~isequal(get(socket, 'Status'), 'open'))
            warning(['Could not open TCP connection to ', Robot_IP, ' on port ', PORT]);
            %% Attempt to connect to simulator instead
            socket = tcpip(Simulate_IP, PORT);
            set(socket, 'ReadAsyncMode', 'continuous');
            Err = 1;
            
            %% Everything broken
            if(~isequal(get(socket, 'Status'), 'open'))
                warning(['Could not open TCP connection to ', Robot_IP, ' on port ', PORT]);
                Err = -1;
                return;
            end 

            return;
        end

        connected = 1;
    end


end

    