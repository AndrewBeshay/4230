function shapesAndProperties = Main3_IdentifyShapesInPattern()

red = 1.1;
green = 1.2;
blue = 1.3;
yellow = 1.4;

CameraCalibration;

%% Identify shapes and colour of the pattern
table_Img = imread('Proper_Pics\AllShapes\Red_AllShapes.jpg');
table_Img = undistortImage(table_Img, cameraParams);
table_Img = segmentSection(table_Img, 552, 1043, 288, 782);
figure; imshow(table_Img);

table_ImgBW = ~im2bw(table_Img);
table_ImgBW = segmentSection(table_ImgBW, 552, 1043, 288, 782);
table_ImgBW = removeLettersAndNumbers(table_ImgBW);
table_ImgBW = bwareaopen(table_ImgBW,100);
figure; imshow(table_ImgBW);

shapesAndProperties = [];

%% filter all colours
% red
[myPatternRedBW,myPatternRed] = createPatternRedMask(table_Img);
myPatternRedBW = imfill(myPatternRedBW,'holes');
myPatternRedBW = bwareaopen(myPatternRedBW,100);
%myPatternRedBW = bwmorph(myPatternRedBW, 'majority');
figure; imshow(myPatternRed);
figure; imshow(myPatternRedBW);

% green
% green's bit more sensitive 
table_Img = imsharpen(table_Img, 'Radius', 5, 'Amount', 1.5);
[myPatternGreenBW,myPatternGreen] = createPatternGreenMask(table_Img);
myPatternGreenBW = bwareaopen(myPatternGreenBW,100);
myPatternGreenBW = imfill(myPatternGreenBW,'holes');
figure; imshow(myPatternGreen);
figure; imshow(myPatternGreenBW);

% Blue
[myPatternBlueBW,myPatternBlue] = createPatternBlueMask(table_Img);
myPatternBlueBW = bwareaopen(myPatternBlueBW,200);
figure; imshow(myPatternBlue);
figure; imshow(myPatternBlueBW);

% Yellow
[myPatternYellowBW,myPatternYellow] = createPatternYellowMask(table_Img);
myPatternYellowBW = bwareaopen(myPatternYellowBW,200);
figure; imshow(myPatternYellow);
figure; imshow(myPatternYellowBW);

%% See if the colours exists in the pattern
redExists = find(myPatternRedBW);
greenExists = find(myPatternGreenBW);
blueExists = find(myPatternBlueBW);
yellowExists = find(myPatternYellowBW);

% process red
if length(redExists) > 50 
    cicleAreaThreshold = 1150;
    area2Threshold = 720;
    imopenSquareDim = 20;
    
    [redShape, redCentroid, redOrientation] = identifyAllShapes(myPatternRedBW, ...
        table_ImgBW, cicleAreaThreshold, area2Threshold);
    redCentroidWorld = tablePxlToReal(redCentroid(:,1), redCentroid(:,2));
else 
    display("No red exists in the pattern");
    redShape = [];
    redCentroid = [];
    redOrientation = [];
    redCentroidWorld = [];
end 

% process green
if length(greenExists) > 50 
    cicleAreaThreshold = 1115;
    area2Threshold = 820;
    [greenShape, greenCentroid, greenOrientation] = identifyAllShapes(myPatternGreenBW, ...
        table_ImgBW, cicleAreaThreshold, area2Threshold);
    greenCentroidWorld = tablePxlToReal(greenCentroid(:,1), greenCentroid(:,2));
else
    display("No green exists in the pattern");
    greenShape = [];
    greenCentroid = [];
    greenOrientation = [];
    greenCentroidWorld = [];
end 

% process blue
if length(blueExists) > 50 
    cicleAreaThreshold = 1150;
    area2Threshold = 875;
    imopenSquareDim = 20;
    [blueShape, blueCentroid, blueOrientation] = identifyAllShapes(myPatternBlueBW, ...
        table_ImgBW, cicleAreaThreshold, area2Threshold);
    blueCentroidWorld = tablePxlToReal(blueCentroid(:,1), blueCentroid(:,2));
else
    display("No blue exists in the pattern");
    blueShape = [];
    blueCentroid = [];
    blueOrientation = [];
    blueCentroidWorld = [];
end 

% process yellow
if length(yellowExists) > 50   
    cicleAreaThreshold = 1150;
    area2Threshold = 720;
    imopenSquareDim = 20;
    [yellowShape, yellowCentroid, yellowOrientation] = identifyAllShapes(myPatternYellowBW, ...
        table_ImgBW, cicleAreaThreshold, area2Threshold);
    yellowCentroidWorld = tablePxlToReal(yellowCentroid(:,1), yellowCentroid(:,2));
else
    display("No yellow exists in the pattern");
    yellowShape = [];
    yellowCentroid = [];
    yellowOrientation = [];
    yellowCentroidWorld = [];
end

% convert the coordinates to real world





%{
shapesAndProperties = [ones(size(redShape, 1), 1)*red redShape redCentroid redOrientation;...
    ones(size(greenShape, 1), 1)*green greenShape greenCentroid greenOrientation;...
    ones(size(blueShape, 1), 1)*blue blueShape blueCentroid blueOrientation;...
    ones(size(yellowShape, 1), 1)*yellow yellowShape yellowCentroid yellowOrientation]
%}

shapesAndProperties = [ones(size(redShape, 1), 1)*red redShape redCentroidWorld redOrientation;...
    ones(size(greenShape, 1), 1)*green greenShape greenCentroidWorld greenOrientation;...
    ones(size(blueShape, 1), 1)*blue blueShape blueCentroidWorld blueOrientation;...
    ones(size(yellowShape, 1), 1)*yellow yellowShape yellowCentroidWorld yellowOrientation];
%}
end