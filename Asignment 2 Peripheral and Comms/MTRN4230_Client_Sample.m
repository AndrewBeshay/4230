% Script to communicate with IRB120 robot system
% Mark Whitty, Zhihao Zhang
% 140324
function MTRN4230_Client_Sample
    global ABCD;
    ABCD.exit = 1;
    ABCD.sendString = '';
    ABCD.recvString = '';

% The robot's IP address.
% robot_IP_address = '192.168.125.5'; % Real robot ip address
robot_IP_address = '127.0.0.1'; % Simulation ip address

% The port that the robot will be listening on. This must be the same as in
% your RAPID program.
robot_port = 1025;

% Open a TCP connection to the robot.
socket = tcpip(robot_IP_address, robot_port);
set(socket, 'ReadAsyncMode', 'continuous');
fopen(socket);

% Check if the connection is valid.+6

if(~isequal(get(socket, 'Status'), 'open'))
    warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port]);
    close all;
    ABCD.exit = ~ABCD.exit;
    return;
end
fprintf('Successfully connected;')
    RobotStudioIndicator = 'From RobotStudio:';
    figure(1);
    hold on;
    compscreen = get(0, 'Screensize');
    set(gcf, 'Position', [1, 40, compscreen(3)/2, round((compscreen(4)-120)/2)]);   
    ABCD.statusString = uicontrol('Style', 'text','HorizontalAlignment', 'left', 'String', 'Hi', 'Position', [compscreen(3)/2-250 100 200 30]);
    ABCD.received =  uicontrol('Style', 'text','HorizontalAlignment', 'left', 'String', RobotStudioIndicator , 'Position', [compscreen(3)/2-250 130 200 30]);
    uicontrol('Style','pushbutton','String','END Now','Position',[90,1,80,20],'Callback',{@MyCallBackA,1});
    uicontrol('Style', 'pushbutton','String', 'ML 0 ', 'Position', [1, round((compscreen(4)-120)/2)-200, 100, 20], 'Callback', {@MyCallBackA, 2});
    uicontrol('Style', 'pushbutton','String', 'ML 1 0000', 'Position', [1, round((compscreen(4)-120)/2)-230, 100, 20], 'Callback', {@MyCallBackA, 3});
    uicontrol('Style', 'pushbutton','String', 'ML 1 1111 ', 'Position', [100+50, round((compscreen(4)-120)/2)-230, 100, 20], 'Callback', {@MyCallBackA, 4});
    uicontrol('Style', 'pushbutton','String', 'ML 1 1010 ', 'Position', [100+150, round((compscreen(4)-120)/2)-230, 100, 20], 'Callback', {@MyCallBackA, 9});
    uicontrol('Style', 'pushbutton','String', 'ML 3 0', 'Position', [1, round((compscreen(4)-120)/2)-260, 100, 20], 'Callback', {@MyCallBackA, 5});
    uicontrol('Style', 'pushbutton','String', 'ML 3 1 ', 'Position', [100+50, round((compscreen(4)-120)/2)-260, 100, 20], 'Callback', {@MyCallBackA, 6});
    uicontrol('Style', 'pushbutton','String', 'ML 4 ', 'Position', [100+50, round((compscreen(4)-120)/2)-290, 100, 20], 'Callback', {@MyCallBackA, 7});
    uicontrol('Style', 'pushbutton','String', 'ML 5 Blocked Ink Ejector ', 'Position', [100+50, round((compscreen(4)-120)/2)-320, 100, 20], 'Callback', {@MyCallBackA, 8});
    
    hold off

%header = 'ML ';

oldS = '';
% Send a sample string to the server on the robot.
while (ABCD.exit)
    
    if (strcmp(ABCD.sendString, '') == 0)
        oldS = ABCD.sendString;
        fwrite(socket, oldS);
        ABCD.sendString = '';
    end
% Read a line from the socket. Note the line feed appended to the message in the RADID sample code.
    data = fgetl(socket);

% Print the data that we got.
    if (~isempty(data))
        fprintf(char(data));
        fromRS = sprintf(char(data));
        ABCD.recvString = strcat(RobotStudioIndicator, fromRS);
        set(ABCD.received, 'String', ABCD.recvString);
    end
    pause(2);
end

%fwrite(socket, 'Finished\n');

% Close the socket.
fclose(socket);
close all;
end

function MyCallBackA(~,~,x)   
    global ABCD;

    if (x==1)
        ABCD.sendString = 'ML finishedML \n';
        
        ABCD.exit = ~ABCD.exit; %Switch ON->OFF->ON -> and so on.
        set(ABCD.statusString,'String','you pressed "END NOW"');
        uiwait(msgbox('Closing!','Warning','modal'));
        close all
        return;
    elseif (x==2)
        ABCD.sendString = 'ML 0 \n';
        
        set(ABCD.statusString,'String','Switching Program operation');
        return;
    
    elseif (x == 3)
        ABCD.sendString = 'ML 1 0000 \n';
        
        set(ABCD.statusString,'String','Toggle all peripherals off');
        return;
    elseif (x == 4)
        ABCD.sendString = 'ML 1 1111 \n';

        set(ABCD.statusString,'String','Toggle all peripherals on');
        return;
    elseif (x == 5)
        ABCD.sendString = 'ML 3 0 \n';
        
        set(ABCD.statusString,'String','Halt Toggle');
        return;
    elseif (x == 6)
        ABCD.sendString = 'ML 3 1 \n';
        
        set(ABCD.statusString,'String','Shutdown');
        ABCD.exit = ~ABCD.exit;
        uiwait(msgbox('Closing!','Warning','modal'));
        close all;
        return;
    elseif (x == 7)
        ABCD.sendString = 'ML 4 \n';
        
        set(ABCD.statusString,'String','Conveyor Move request');
        return;
    elseif (x == 8)
        ABCD.sendString = 'ML 5 Blocked Ink Ejector ';
        
        set(ABCD.statusString,'String','Ink Ejector Dummy Error');
        return;
    elseif (x == 9)
        ABCD.sendString = 'ML 1 1010 ';
        set(ABCD.statusString, 'Set Peripherals to Patern');
    end
    return;    
end