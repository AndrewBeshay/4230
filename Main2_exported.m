classdef Main2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainUIFigure                  matlab.ui.Figure
        TabGroup                      matlab.ui.container.TabGroup
        OrderTab                      matlab.ui.container.Tab
        UIAxes                        matlab.ui.control.UIAxes
        READYButton                   matlab.ui.control.Button
        LampLabel                     matlab.ui.control.Label
        Lamp                          matlab.ui.control.Lamp
        MainTab                       matlab.ui.container.Tab
        TableCamera                   matlab.ui.control.UIAxes
        ConveyorCamera                matlab.ui.control.UIAxes
        Notifications                 matlab.ui.container.Panel
        Controls                      matlab.ui.container.Panel
        POWERButton                   matlab.ui.control.Button
        VacuumLabel                   matlab.ui.control.Label
        ConveyorLabel                 matlab.ui.control.Label
        ConveyorDirectionButtonGroup  matlab.ui.container.ButtonGroup
        TowardsButton                 matlab.ui.control.RadioButton
        AwayButton                    matlab.ui.control.RadioButton
        SOLENOIDButton                matlab.ui.control.Button
        STARTButton                   matlab.ui.control.StateButton
        SolenoidButtonGroup           matlab.ui.container.ButtonGroup
        OffButton                     matlab.ui.control.RadioButton
        OnButton                      matlab.ui.control.RadioButton
        ConsolePanel                  matlab.ui.container.Panel
        TextArea                      matlab.ui.control.TextArea
        CameraTab                     matlab.ui.container.Tab
        TableCameraPanel              matlab.ui.container.Panel
        TCam                          matlab.ui.control.UIAxes
        ConveyorCameraPanel           matlab.ui.container.Panel
        CCam                          matlab.ui.control.UIAxes
        Status                        matlab.ui.control.Lamp
        Knob                          matlab.ui.control.DiscreteKnob
        ROBOTSTATELabel               matlab.ui.control.Label
        TASKLabel                     matlab.ui.control.Label
        CONNECTIONLabel               matlab.ui.control.Label
    end

    
    properties (Access = private)
        % Camera objects
        TableCam;
        ConvCam;
        
        % IO states (OFF = 0, ON = 1)
        Vacuum = 0; 
        Sol = 0;
        Conv = 0;
        ConvDir = 0;  % Forward = 0, Backward = 1
        
        % Connection
        Connected = 0;
        Socket; 
        
        Timer;
        ErrorFlag; 
    end
    
    methods (Access = private)
        
        function results = video_feed(app)
            % Table Cam
            app.TableCam = videoinput('winvideo', 1, 'MJPG_1600x1200');
            app.TableCam.Res = app.TableCam.VideoResolution;
            app.TableCam.Bands = app.TableCam.NumberOfBands;
            app.TableCamImg = imshow(zeros([app.TableCam.Res(2), app.TableCam.Res(1), app.TableCam.Bands]),...
                'Parent', app.TableCamera);
            app.TableCam.Prev = preview(app.TableCam, app.TableCamImg);
            src = getselectedsource(app.TableCam);
            src.ExposureMode = 'manual';
            src.Exposure = -4;
            
            % Conveyor Cam
            app.ConvCam = videoinput('winvideo', 2, 'MJPG_1600x1200');
            app.ConvCam.Res = app.ConvCam.VideoResolution;
            app.ConvCam.Bands = app.ConvCam.NumberOfBands;
            app.ConvCamImg = imshow(zeros([app.ConvCam.Res(2), app.ConvCam.Res(1), app.ConvCam.Bands]),...
                'Parent', app.ConveyorCamera);
            app.ConvCam.Prev = preview(app.ConvCam, app.ConvCamImg);
            src = getselectedsource(app.ConvCam);
            src.ExposureMode = 'manual';
            src.Exposure = -4;
            
        end
        
        function main(app)
            if app.connected == 0
                app.Socket = connect();
                app.connected = 1;
            end
            
            if app.connect == 1
                out = query(app.Socket, cmd);
            end
            
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            try
                video_feed(app);
            catch 
                warning('Problem starting cameras');
            end
            
            app.Timer = timer('StartDelay', 5, 'Period', 0.5, 'ExecutionMode', 'fixedRate', 'TasksToExecute', Inf,...
                'BusyMode', 'drop');
            app.Timer.TimerFcn = @(obj,event)app.main(app);
            start(app.Timer);
            
        end

        % Value changed function: STARTButton
        function STARTButtonValueChanged(app, event)
            if app.STARTButton.Value
                app.STARTButton.Text = "STOP";
            else
                app.STARTButton.Text = "START";
            end
        end

        % Value changed function: Knob
        function KnobValueChanged(app, event)
            value = app.Knob.Value;
            
            if value == "OFF"
                app.Status.Color = [1, 0, 0];
            elseif value == "PAUSE"
                app.Status.Color = [1, 0.41, 0.16];
            elseif value == "ON"
                app.Status.Color = [0, 1, 0];
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainUIFigure and hide until all components are created
            app.MainUIFigure = uifigure('Visible', 'off');
            app.MainUIFigure.Color = [0.149 0.149 0.149];
            app.MainUIFigure.Position = [100 100 1034 698];
            app.MainUIFigure.Name = 'Main';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.MainUIFigure);
            app.TabGroup.Position = [1 1 1034 599];

            % Create OrderTab
            app.OrderTab = uitab(app.TabGroup);
            app.OrderTab.Title = 'Order';
            app.OrderTab.BackgroundColor = [0.2 0.2 0.2];
            app.OrderTab.ForegroundColor = [0.149 0.149 0.149];

            % Create UIAxes
            app.UIAxes = uiaxes(app.OrderTab);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.GridColor = [1 1 1];
            app.UIAxes.XColor = 'none';
            app.UIAxes.XTick = [0 1];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YColor = 'none';
            app.UIAxes.YTick = [0 1];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.Color = [0.149 0.149 0.149];
            app.UIAxes.BackgroundColor = [0.149 0.149 0.149];
            app.UIAxes.Position = [16 208 483 350];

            % Create READYButton
            app.READYButton = uibutton(app.OrderTab, 'push');
            app.READYButton.BackgroundColor = [0.302 0.302 0.302];
            app.READYButton.FontName = 'Calibri';
            app.READYButton.FontSize = 40;
            app.READYButton.FontWeight = 'bold';
            app.READYButton.FontColor = [0.902 0.902 0.902];
            app.READYButton.Position = [127 41 262 81];
            app.READYButton.Text = 'READY';

            % Create LampLabel
            app.LampLabel = uilabel(app.OrderTab);
            app.LampLabel.HorizontalAlignment = 'right';
            app.LampLabel.FontWeight = 'bold';
            app.LampLabel.FontColor = [0.902 0.902 0.902];
            app.LampLabel.Position = [528 527 38 22];
            app.LampLabel.Text = 'Lamp';

            % Create Lamp
            app.Lamp = uilamp(app.OrderTab);
            app.Lamp.Position = [581 520 36 36];

            % Create MainTab
            app.MainTab = uitab(app.TabGroup);
            app.MainTab.Title = 'Main';
            app.MainTab.BackgroundColor = [0.2 0.2 0.2];
            app.MainTab.ForegroundColor = [0.149 0.149 0.149];

            % Create TableCamera
            app.TableCamera = uiaxes(app.MainTab);
            title(app.TableCamera, '')
            xlabel(app.TableCamera, '')
            ylabel(app.TableCamera, {''; ''})
            app.TableCamera.XColor = 'none';
            app.TableCamera.XTick = [0 1];
            app.TableCamera.XTickLabel = '';
            app.TableCamera.YColor = 'none';
            app.TableCamera.YTick = [0 1];
            app.TableCamera.YTickLabel = '';
            app.TableCamera.Color = [0.149 0.149 0.149];
            app.TableCamera.BackgroundColor = [0.149 0.149 0.149];
            app.TableCamera.Position = [39 304 373 259];

            % Create ConveyorCamera
            app.ConveyorCamera = uiaxes(app.MainTab);
            title(app.ConveyorCamera, '')
            xlabel(app.ConveyorCamera, '')
            ylabel(app.ConveyorCamera, '')
            app.ConveyorCamera.XColor = 'none';
            app.ConveyorCamera.XTick = [0 1];
            app.ConveyorCamera.XTickLabel = '';
            app.ConveyorCamera.YColor = 'none';
            app.ConveyorCamera.YTick = [0 1];
            app.ConveyorCamera.YTickLabel = '';
            app.ConveyorCamera.Color = [0.149 0.149 0.149];
            app.ConveyorCamera.BackgroundColor = [0.149 0.149 0.149];
            app.ConveyorCamera.Position = [39 20 373 266];

            % Create Notifications
            app.Notifications = uipanel(app.MainTab);
            app.Notifications.ForegroundColor = [0.902 0.902 0.902];
            app.Notifications.TitlePosition = 'centertop';
            app.Notifications.Title = 'Notifications';
            app.Notifications.BackgroundColor = [0.149 0.149 0.149];
            app.Notifications.Position = [538 422 441 141];

            % Create Controls
            app.Controls = uipanel(app.MainTab);
            app.Controls.ForegroundColor = [0.902 0.902 0.902];
            app.Controls.TitlePosition = 'centertop';
            app.Controls.Title = 'Controls';
            app.Controls.BackgroundColor = [0.149 0.149 0.149];
            app.Controls.Position = [539 189 441 221];

            % Create POWERButton
            app.POWERButton = uibutton(app.Controls, 'push');
            app.POWERButton.BackgroundColor = [0.302 0.302 0.302];
            app.POWERButton.FontColor = [0.902 0.902 0.902];
            app.POWERButton.Position = [294 129 100 22];
            app.POWERButton.Text = 'POWER';

            % Create VacuumLabel
            app.VacuumLabel = uilabel(app.Controls);
            app.VacuumLabel.FontWeight = 'bold';
            app.VacuumLabel.FontColor = [0.902 0.902 0.902];
            app.VacuumLabel.Position = [319 164 52 22];
            app.VacuumLabel.Text = 'Vacuum';

            % Create ConveyorLabel
            app.ConveyorLabel = uilabel(app.Controls);
            app.ConveyorLabel.FontWeight = 'bold';
            app.ConveyorLabel.FontColor = [0.902 0.902 0.902];
            app.ConveyorLabel.Position = [65 164 61 22];
            app.ConveyorLabel.Text = 'Conveyor';

            % Create ConveyorDirectionButtonGroup
            app.ConveyorDirectionButtonGroup = uibuttongroup(app.Controls);
            app.ConveyorDirectionButtonGroup.ForegroundColor = [0.902 0.902 0.902];
            app.ConveyorDirectionButtonGroup.TitlePosition = 'centertop';
            app.ConveyorDirectionButtonGroup.Title = 'Conveyor Direction';
            app.ConveyorDirectionButtonGroup.BackgroundColor = [0.349 0.349 0.349];
            app.ConveyorDirectionButtonGroup.Position = [32 23 123 94];

            % Create TowardsButton
            app.TowardsButton = uiradiobutton(app.ConveyorDirectionButtonGroup);
            app.TowardsButton.Text = 'Towards';
            app.TowardsButton.Position = [24 44 67 22];
            app.TowardsButton.Value = true;

            % Create AwayButton
            app.AwayButton = uiradiobutton(app.ConveyorDirectionButtonGroup);
            app.AwayButton.Text = 'Away';
            app.AwayButton.Position = [24 10 51 22];

            % Create SOLENOIDButton
            app.SOLENOIDButton = uibutton(app.Controls, 'push');
            app.SOLENOIDButton.Position = [294 59 100 22];
            app.SOLENOIDButton.Text = 'SOLENOID';

            % Create STARTButton
            app.STARTButton = uibutton(app.Controls, 'state');
            app.STARTButton.ValueChangedFcn = createCallbackFcn(app, @STARTButtonValueChanged, true);
            app.STARTButton.Text = 'START';
            app.STARTButton.BackgroundColor = [0.302 0.302 0.302];
            app.STARTButton.FontColor = [0.902 0.902 0.902];
            app.STARTButton.Position = [44 129 100 22];

            % Create SolenoidButtonGroup
            app.SolenoidButtonGroup = uibuttongroup(app.Controls);
            app.SolenoidButtonGroup.ForegroundColor = [0.902 0.902 0.902];
            app.SolenoidButtonGroup.TitlePosition = 'centertop';
            app.SolenoidButtonGroup.Title = 'Solenoid';
            app.SolenoidButtonGroup.BackgroundColor = [0.349 0.349 0.349];
            app.SolenoidButtonGroup.Position = [282 23 123 94];

            % Create OffButton
            app.OffButton = uiradiobutton(app.SolenoidButtonGroup);
            app.OffButton.Text = 'Off';
            app.OffButton.Position = [43 44 38 22];
            app.OffButton.Value = true;

            % Create OnButton
            app.OnButton = uiradiobutton(app.SolenoidButtonGroup);
            app.OnButton.Text = {'On'; ''};
            app.OnButton.Position = [43 10 38 22];

            % Create ConsolePanel
            app.ConsolePanel = uipanel(app.MainTab);
            app.ConsolePanel.ForegroundColor = [0.902 0.902 0.902];
            app.ConsolePanel.TitlePosition = 'centertop';
            app.ConsolePanel.Title = 'Console';
            app.ConsolePanel.BackgroundColor = [0.149 0.149 0.149];
            app.ConsolePanel.Position = [539 20 441 165];

            % Create TextArea
            app.TextArea = uitextarea(app.ConsolePanel);
            app.TextArea.FontColor = [0.9412 0.9412 0.9412];
            app.TextArea.BackgroundColor = [0.502 0.502 0.502];
            app.TextArea.Position = [1 0 441 147];

            % Create CameraTab
            app.CameraTab = uitab(app.TabGroup);
            app.CameraTab.Title = 'Camera';
            app.CameraTab.BackgroundColor = [0.149 0.149 0.149];
            app.CameraTab.ForegroundColor = [0.149 0.149 0.149];

            % Create TableCameraPanel
            app.TableCameraPanel = uipanel(app.CameraTab);
            app.TableCameraPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.TableCameraPanel.BorderType = 'none';
            app.TableCameraPanel.TitlePosition = 'centertop';
            app.TableCameraPanel.Title = 'Table Camera';
            app.TableCameraPanel.BackgroundColor = [0.149 0.149 0.149];
            app.TableCameraPanel.Position = [18 59 478 417];

            % Create TCam
            app.TCam = uiaxes(app.TableCameraPanel);
            title(app.TCam, '')
            xlabel(app.TCam, '')
            ylabel(app.TCam, '')
            app.TCam.XColor = 'none';
            app.TCam.XTick = [0 1];
            app.TCam.XTickLabel = '';
            app.TCam.YColor = 'none';
            app.TCam.YTick = [0 1];
            app.TCam.YTickLabel = '';
            app.TCam.Color = [0.149 0.149 0.149];
            app.TCam.BackgroundColor = [0 0 0];
            app.TCam.Position = [0 1 478 395];

            % Create ConveyorCameraPanel
            app.ConveyorCameraPanel = uipanel(app.CameraTab);
            app.ConveyorCameraPanel.ForegroundColor = [0.902 0.902 0.902];
            app.ConveyorCameraPanel.BorderType = 'none';
            app.ConveyorCameraPanel.TitlePosition = 'centertop';
            app.ConveyorCameraPanel.Title = 'Conveyor Camera';
            app.ConveyorCameraPanel.BackgroundColor = [0.149 0.149 0.149];
            app.ConveyorCameraPanel.Position = [525 59 487 417];

            % Create CCam
            app.CCam = uiaxes(app.ConveyorCameraPanel);
            title(app.CCam, '')
            xlabel(app.CCam, '')
            ylabel(app.CCam, '')
            app.CCam.XColor = 'none';
            app.CCam.XTick = [0 1];
            app.CCam.XTickLabel = '';
            app.CCam.YColor = 'none';
            app.CCam.YTick = [0 1];
            app.CCam.YTickLabel = '';
            app.CCam.Color = [0.149 0.149 0.149];
            app.CCam.BackgroundColor = [0 0 0];
            app.CCam.Position = [5 1 478 395];

            % Create Status
            app.Status = uilamp(app.MainUIFigure);
            app.Status.Position = [10 615 73 73];

            % Create Knob
            app.Knob = uiknob(app.MainUIFigure, 'discrete');
            app.Knob.Items = {'OFF', 'PAUSE', 'ON'};
            app.Knob.ValueChangedFcn = createCallbackFcn(app, @KnobValueChanged, true);
            app.Knob.FontWeight = 'bold';
            app.Knob.FontColor = [0.902 0.902 0.902];
            app.Knob.Position = [127 610 60 60];
            app.Knob.Value = 'ON';

            % Create ROBOTSTATELabel
            app.ROBOTSTATELabel = uilabel(app.MainUIFigure);
            app.ROBOTSTATELabel.HorizontalAlignment = 'right';
            app.ROBOTSTATELabel.FontSize = 18;
            app.ROBOTSTATELabel.FontWeight = 'bold';
            app.ROBOTSTATELabel.FontColor = [0.902 0.902 0.902];
            app.ROBOTSTATELabel.Position = [246 618 144 52];
            app.ROBOTSTATELabel.Text = 'ROBOT STATE:';

            % Create TASKLabel
            app.TASKLabel = uilabel(app.MainUIFigure);
            app.TASKLabel.HorizontalAlignment = 'right';
            app.TASKLabel.FontSize = 18;
            app.TASKLabel.FontWeight = 'bold';
            app.TASKLabel.FontColor = [0.902 0.902 0.902];
            app.TASKLabel.Position = [532 623 67 43];
            app.TASKLabel.Text = 'TASK:';

            % Create CONNECTIONLabel
            app.CONNECTIONLabel = uilabel(app.MainUIFigure);
            app.CONNECTIONLabel.HorizontalAlignment = 'right';
            app.CONNECTIONLabel.FontSize = 18;
            app.CONNECTIONLabel.FontWeight = 'bold';
            app.CONNECTIONLabel.FontColor = [0.902 0.902 0.902];
            app.CONNECTIONLabel.Position = [770 623 142 43];
            app.CONNECTIONLabel.Text = 'CONNECTION:';

            % Show the figure after all components are created
            app.MainUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Main2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MainUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MainUIFigure)
        end
    end
end