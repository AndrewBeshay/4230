function Coords = imgPointsToWorld(X, Y)
%img = imread('blank_image2.jpg');
% img2 = imread('blank_image3.jpg');
load('calibrationSession.mat');
%imUndistorted = undistortImage(img,cameraParams);
% imshow(img);
% imUndistorted = undistortImage(img2,cameraParams);
% imshow(imUndistorted);

cameraParams = calibrationSession.CameraParameters;

K = cameraParams.IntrinsicMatrix;

% WPTS = [568, -520;
%         175, 0;
%         175, 260;
%         175, 520;
%         548.6, 0];
%     
% IMGPTS = [7, 573;
%           797, 284;
%           1198, 282
%           1600, 280;
%           793, 856];
%% Working one
WPTS = [361.8, 0;
        175, -520;
        175, 520;
        548.6, 0];
IMGPTS = [794, 571.5;
        6, 279;
        1600, 287;
        794, 855];
            
             
           
            

[R, T] = extrinsics(IMGPTS, WPTS, cameraParams);
% ginput(4)
% RobotCoord
% while true;
% RobotCoord = round([pointsToWorld(cameraParams, R, T, ginput(1)) 147],2)
% RobotCoord = [RobotCoord 147];
% h1 = text(RobotCoord(1), RobotCoord(2), RobotCoord(3), '1');
Coords = pointsToWorld(cameraParams, R, T, [X Y]);
% end
%     return RobotCoord;
end
% % pointsToWorld(cameraParams, R, T, ginput(4))