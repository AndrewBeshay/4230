%% Initiate connection to Robot

function [socket, conType] = connect()
    % Script to communicate with IRB120 robot system
    % Mark Whitty, Zhihao Zhang
    % 140324

    Robot_IP = '192.168.125.1'; % Real robot ip address
    Simulate_IP = '127.0.0.1';  % Simulation ip address

    % The port that the robot will be listening on. This must be the same as in
    % your RAPID program.
    PORT = 1025;
    
    conType = 0;
    connected = 0;

    while ~connected
        socket = tcpip(Robot_IP, PORT, 'Timeout', 0.5);
        set(socket, 'ReadAsyncMode', 'continuous', 'Timeout', 0.5);
        
        try
            fopen(socket);
        catch
            warning(['Could not open TCP connection to ', Robot_IP, ' on port ', num2str(PORT)]);
            conType = 1;
        end
        

        if(~isequal(get(socket, 'Status'), 'open'))
            

            pause(2);
            socket = tcpip(Simulate_IP, PORT, 'Timeout', 1);
            set(socket, 'ReadAsyncMode', 'continuous');

            try
                fopen(socket);
            catch
               warning(['Could not open TCP connection to ', Simulate_IP, ' on port ', num2str(PORT)]); 
               conType = -1;
            end
            
            %% Everything broken
            if(~isequal(get(socket, 'Status'), 'open'))
                % warning(['Could not open TCP connection to ', Simulate_IP, ' on port ', num2str(PORT), '\n']);
                % conType = -1;
                connected = 0;
                return;
            end 

            return;
        end
        disp(['Connected to: ', num2str(conType)]);
        connected = 1;
    end


end

    