% This code is responsible for identifying provided shapes and determining
% whether the shape and colour is desired by the customer
% By Kevinly Santoso
% Last Updated: 18/08/2019

%{

Source:
    https://au.mathworks.com/help/vision/ug/local-feature-detection-and-extraction.html
    https://au.mathworks.com/help/vision/ref/detectfastfeatures.html
    https://au.mathworks.com/help/vision/ref/detectharrisfeatures.html
    https://au.mathworks.com/help/vision/ref/matchfeatures.html
    https://au.mathworks.com/help/vision/examples/object-detection-in-a-cluttered-scene-using-point-feature-matching.html
    https://au.mathworks.com/matlabcentral/fileexchange/34626-object-matching
    https://au.mathworks.com/matlabcentral/answers/114176-matching-signs-using-surf

Other feature detection methods:
    https://au.mathworks.com/help/vision/ref/detectmineigenfeatures.html
    https://au.mathworks.com/help/vision/ref/detectorbfeatures.html
    https://au.mathworks.com/help/vision/ref/detectmserfeatures.html
    https://au.mathworks.com/help/vision/ref/detectbriskfeatures.html

%}

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

transfer_Img = imread('Proper_Pics\Shapes\blueSquare.jpg');
transfer_Img = undistortImage(transfer_Img, cameraParams);
transfer_Img = segmentSection(transfer_Img, 1238, size(transfer_Img,2), 290, 783);
transfer_ImgBW = im2bw(transfer_Img);
transfer_ImgBW = ~transfer_ImgBW;
transfer_ImgBW = segmentSection(transfer_ImgBW, 1238, size(transfer_Img,2), 290, 783);
transfer_ImgBW = bwareaopen(transfer_ImgBW,400); 
figure; imshow(transfer_Img);

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
    display("The shape is unrecognisable"); 
end

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
    shapeProps.Colour = [];
    shapeProps.Shape = [];
    shapeProps.Centroid = [];
    shapeProps.Orientation = [];
end

end