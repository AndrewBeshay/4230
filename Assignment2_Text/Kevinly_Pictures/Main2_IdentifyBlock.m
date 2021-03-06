function shapeProps = Main2_IdentifyBlock()
 
red = 1.1;
green = 1.2;
blue = 1.3;
yellow = 1.4;
 
circle = 2.1;
flower = 2.2;
diamond = 2.3;
square = 2.4;
star4 = 2.5;
star6 = 2.6;
 
recognise = 0;
 
CameraCalibration;
 
% Undistort and segment
transfer_Img = imread('Proper_Pics\Shapes\grn4star.jpg');
transfer_Img = undistortImage(transfer_Img, cameraParams);
transfer_Img = segmentSection(transfer_Img, 1238, size(transfer_Img,2), 290, 783);
figure; imshow(transfer_Img);
 
% Get black and white version of the image
transfer_ImgBW = im2bw(transfer_Img);
transfer_ImgBW = ~transfer_ImgBW;
transfer_ImgBW = segmentSection(transfer_ImgBW, 1238, size(transfer_Img,2), 290, 783);
transfer_ImgBW = bwareaopen(transfer_ImgBW,400); 
figure; imshow(transfer_ImgBW);
 
% Colour masking
[myRedShpBW,myRedShp] = createTableRedMask(transfer_Img);
[myGreenShpBW,myGreenShp] = createTableGreenMask(transfer_Img);
[myBlueShpBW,myBlueShp] = createTableBlueMask(transfer_Img);
[myYellowShpBW,myYellowShp] = createTableYellowMask(transfer_Img);
 
% Remove any white noise from all the masks
myRedShpBW = bwareaopen(myRedShpBW,400); 
myGreenShpBW = bwareaopen(myGreenShpBW,400); 
myBlueShpBW = bwareaopen(myBlueShpBW,400); 
myYellowShpBW = bwareaopen(myYellowShpBW,400);
 
% Determine if the colour is red, green, blue or yellow
redExist = find(myRedShpBW);
greenExist = find(myGreenShpBW);
blueExist = find(myBlueShpBW);
yellowExist = find(myYellowShpBW);
 
if length(redExist) > 50
    display("It's a red shape");
    Colour = 'Red';
    blockColour = red;
    myShpGray = rgb2gray(myRedShp);
    myShpBW = myRedShpBW;
    myFinalShp = myRedShp;
    recognise = 1;
    
elseif length(greenExist) > 50
    display("It's a green shape");
    Colour = 'Green';
    blockColour = green;
    myShpGray = rgb2gray(myGreenShp);
    myShpBW = myGreenShpBW;
    myFinalShp = myGreenShp;
    recognise = 1;
 
elseif length(blueExist) > 50
    display("It's a blue shape");
    Colour = 'Blue';
    blockColour = blue;
    myShpGray = rgb2gray(myBlueShp);
    myShpBW = myBlueShpBW;
    myFinalShp = myBlueShp;
    recognise = 1;
    
elseif length(yellowExist) > 50
    display("It's a yellow shape");
    Colour = 'Yellow';
    blockColour = yellow;
    myShpGray = rgb2gray(myYellowShp);
    myShpBW = myYellowShpBW;
    myFinalShp = myYellowShp; 
    recognise = 1;
    
else
    % Unrecognisable shape
    %display("The shape and colour are unrecognisable");
    shapeProps.Colour = [];
    shapeProps.Shape = [];
end
 
%figure; imshow(myShpBW);
%figure; imshow(myFinalShp);
    
if recognise == 1
    % Determine the shape property
    s = regionprops(myShpBW, 'Area', 'MajorAxisLength', 'MinorAxisLength',...
        'Eccentricity', 'Orientation', 'EulerNumber', 'EquivDiameter',...
        'Perimeter', 'ConvexArea', 'Extent', 'FilledArea', 'Solidity', 'Centroid');
    shpStats = [s.Area s.MajorAxisLength s.MinorAxisLength s.Eccentricity s.Orientation s.EulerNumber ...
        s.EquivDiameter s.Perimeter s.ConvexArea s.Extent s.FilledArea s.Solidity];
 
    % determine the angle of the shape
    shpAngle = calculateAngle(myShpBW);
    blockAngle = calculateAngle(transfer_ImgBW);
 
    % Determine the shape
    if s.Area > 1200
        display("It's a circle");
        Shape = 'Circle';
        blockShape = circle;
    elseif s.Area > 850
        if s.Perimeter > 150
            display("It's a flower");
            Shape = 'Flower';
            blockShape = flower;
        else 
            if abs(shpAngle - blockAngle) < 10
                display("It's a square");
                Shape = 'Square';
                blockShape = square;
            else 
                display("It's a diamond");
                Shape = 'Diamond';
                blockShape = diamond;
            end
        end
    else 
        if s.MajorAxisLength > 34.5
            display("It's a 4star");
            Shape = '4star';
            blockShape = star4;
        else 
            display("It's a 6star");
            Shape = '6star';
            blockShape = star6;
        end
    end
 
    % record final properties
    transferCentroid = tablePxlToReal(s.Centroid(1), s.Centroid(2));
    transferOrientation = blockAngle;
 
    shapeProps.Colour = blockColour;
    shapeProps.Shape = blockShape;
    shapeProps.Centroid = transferCentroid;
    shapeProps.Orientation = transferOrientation;
    
    % shapeProps = [blockColour blockShape transferCentroid transferOrientation];
else 
    % see if there are any blocks at all
    s = regionprops(transfer_ImgBW, 'Centroid');
    centroid = vertcat(s.Centroid);
    if size(centroid, 1) > 0
        % block does exist
        shapeProps.Centroid = tablePxlToReal(s.Centroid(1), s.Centroid(2));
        shapeProps.Orientation = calculateAngle(transfer_ImgBW);
    else
        % transfer section is empty
        %display("The transfer section is empty");
        shapeProps.Centroid = [];
        shapeProps.Orientation = [];
end
 
end
