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
        socket = tcpip(Robot_IP, PORT, 'Timeout', 0.5);
        set(socket, 'ReadAsyncMode', 'continuous', 'Timeout', 0.5);
        
        % try 
        %     fopen(socket);
        % catch
        %     warning(['Could not open TCP connection to ', Robot_IP, ' on port ', num2str(PORT), '\n']);
        % end
        try
            disp(['FROM connectAttempt: Opening a TCP connection to ', Robot_IP, ' on port ', num2str(PORT)]);
            fopen(socket);
            disp(['FROM connectAttempt: Connected to ', Robot_IP, ' on port ', num2str(PORT)]);
            connected = 1;
        catch
            disp(['FROM connectAttempt: Could not open TCP connection to ', Robot_IP, ' on port ', num2str(PORT)]);
            connected = 0;
        end

        pause(5);

        socket = tcpip(Simulate_IP, PORT, 'Timeout', 0.5);
        set(socket, 'ReadAsyncMode', 'continuous', 'Timeout', 0.5);
        
        try
            disp(['FROM connectAttempt: Opening a TCP connection to ', Simulate_IP, ' on port ', num2str(PORT)]);
            fopen(socket);
            disp(['FROM connectAttempt: Connected to ', Simulate_IP, ' on port ', num2str(PORT)]);
            connnected = 1;
            Err = 1;
        catch
            disp(['FROM connectAttempt: Could not open TCP connection to ', Simulate_IP, ' on port ', num2str(PORT)]);
            connected = 0;
            Err = -1;
        end
        
        % if(~isequal(get(socket, 'Status'), 'open'))
        %     warning(['Could not open TCP connection to ', Robot_IP, ' on port ', num2str(PORT), '\n']);
        %     %% Attempt to connect to simulator instead
        %     % pause(5);
        %     socket = tcpip(Simulate_IP, PORT);%, 'Timeout', 5);
        %     set(socket, 'ReadAsyncMode', 'continuous');
            
        %     Err = 1;
            
        %     %% Everything broken
        %     if(~isequal(get(socket, 'Status'), 'open'))
        %         warning(['Could not open TCP connection to ', Simulate_IP, ' on port ', num2str(PORT), '\n']);
        %         Err = -1;
        %         return;
        %     end 

        %     return;
        % end
        disp(['Connected to: ', num2str(Err)]);
        connected = 1;
        % fopen(socket);
    end


end

    