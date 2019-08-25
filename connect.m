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
% function [socket, connectType] = startConnectionToRobot()
%     % Will attempt to start a connection to the robot/simulation
    
    
%         % The robot's details:
%         % Real Robot     '192.168.125.1'
%         % Fake Robot     '127.0.0.1'
%         % Port           '1025'
        
%         RSAddress = '192.168.125.1';
%         FakeAddress = '127.0.0.1';
%         robotPort = 1025;
        
%         % Connection variables 
%         % Open a TCP connection to the robot.
%         % will check if its a simulation or not
%         % Check if the connection is valid
        
%         conFlag = 1;
%         while conFlag 
%             socket = connectAttempt(RSAddress, robotPort);
%             if(isequal(get(socket, 'Status'), 'open'))
%                 connectType = 1;
%                 conFlag = 0;
%             else
%                 socket = connectAttempt(FakeAddress, robotPort);
%                 if(isequal(get(socket, 'Status'), 'open'))
%                     connectType = 0;
%                     conFlag = 0;
%                 else
%                     disp('No Connecto')
%                     try
%                         conFlag = connectionPopUp();
%                     catch
%                         disp('connectionPopUp failed');
%                     end
                    
%                     if conFlag == 0
%                         connectType = 2; %error
%                     end
%                 end
%             end
            
            
%         end
            
%         %------------------------------------------------------------------
%         % Confirmation of robot stuff
%         %   Should probably set the robot's status bits here
%         %       Set Connected
%         %       Set Confirmation
%         %-------------------------------------------------------------------
%     %     if (connectType ~= 2)
%     %         
%     %         fwrite(socket, [datestr(datetime('now'),'mmm-dd HH:MM:SS') ... 
%     %                        '. Henlo Robot!.\n']);     %send message
%     %         data = fgetl(socket);     %recieve reply
%     %         fprintf(char(data));     % Print confirmation
%     %         %------------------------------------------------------------------
%     %         %Set the status bits for intialization!!!!
%     %         %Set hte confirmation bit and see if it comes back okay
%     %         initConfMsg = toggleStatus('Confirmation');
%     %         fwrite(socket, initConfMsg);
%     % 
%     %         initConfMsg = toggleStatus('Connected');
%     %         fwrite(socket, initConfMsg);
%     %                 
%     %     end
        
        
%     end
    
    
    
%     function socket = connectAttempt(address, port)
    
%         socket = tcpip(address, port);
%         set(socket, 'Timeout', 1);
        
%         try
%             disp(['Opening a TCP connection to ', address, ' on port ', num2str(port)]);
%             fopen(socket);
%             disp(['Connected to ', address, ' on port ', num2str(port)]);
%         catch
%             disp(['Could not open TCP connection to ', address, ' on port ', port]);
%         end
        
%     end
    