function patternProps = Main3_IdentifyShapesInPattern()

red = 1.1;
green = 1.2;
blue = 1.3;
yellow = 1.4;

CameraCalibration;

%% Identify shapes and colour of the pattern
table_Img = imread('Proper_Pics\Patterns\Pattern12.jpg');
table_Img = undistortImage(table_Img, cameraParams);
table_Img = segmentSection(table_Img, 552, 1043, 288, 782);
figure; imshow(table_Img);

table_ImgBW = ~im2bw(table_Img);
table_ImgBW = segmentSection(table_ImgBW, 552, 1043, 288, 782);
table_ImgBW = removeLettersAndNumbers(table_ImgBW);
table_ImgBW = bwareaopen(table_ImgBW,100);
figure; imshow(table_ImgBW);


patternProps.Colour = [];
patternProps.Shape = [];
patternProps.Centroid = [];
patternProps.Orientation = [];
%}

%% Filter all colours
% red
[myPatternRedBW,myPatternRed] = createPatternRedMask(table_Img);
myPatternRedBW = imfill(myPatternRedBW,'holes');
myPatternRedBW = bwareaopen(myPatternRedBW,100);
figure; imshow(myPatternRed);
figure; imshow(myPatternRedBW);

% green
% green's bit more sensitive 
[myPatternGreenBW,myPatternGreen] = createPatternGreenMask2(table_Img);
myPatternGreenBW = bwareaopen(myPatternGreenBW,200);
figure; imshow(myPatternGreen);
figure; imshow(myPatternGreenBW);

% Blue
table_Img = imsharpen(table_Img, 'Radius', 5, 'Amount', 1.5);
[myPatternBlueBW,myPatternBlue] = createPatternBlueMask3(table_Img);
myPatternBlueBW = bwareaopen(myPatternBlueBW,200);
figure; imshow(myPatternBlue);
figure; imshow(myPatternBlueBW);

% Yellow
[myPatternYellowBW,myPatternYellow] = createPatternYellowMask3(table_Img);
myPatternYellowBW = bwareaopen(myPatternYellowBW,350);
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
    
    [redShape, redCentroid, redOrientation] = identifyAllRedShapes(myPatternRedBW, ...
        table_ImgBW);
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
    [greenShape, greenCentroid, greenOrientation] = identifyAllGreenShapes(myPatternGreenBW, table_ImgBW);
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

    [blueShape, blueCentroid, blueOrientation] = identifyAllBlueShapes(myPatternBlueBW, table_ImgBW);
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
    [yellowShape, yellowCentroid, yellowOrientation] = identifyAllYellowShapes(myPatternYellowBW, ...
        table_ImgBW, cicleAreaThreshold, area2Threshold);
    yellowCentroidWorld = tablePxlToReal(yellowCentroid(:,1), yellowCentroid(:,2));
else
    display("No yellow exists in the pattern");
    yellowShape = [];
    yellowCentroid = [];
    yellowOrientation = [];
    yellowCentroidWorld = [];
end

%{
patternProps.Colour = [ones(size(redShape, 1), 1)*red; ones(size(greenShape, 1), 1)*green;...
                        ones(size(blueShape, 1), 1)*blue; ones(size(yellowShape, 1), 1)*yellow];
patternProps.Shape = [redShape; greenShape; blueShape; yellowShape];
patternProps.Centroid = [redCentroidWorld; greenCentroidWorld; blueCentroidWorld; yellowCentroidWorld];
patternProps.Orientation = [redOrientation; greenOrientation; blueOrientation; yellowOrientation];
%}


patternProps = [ones(size(redShape, 1), 1)*red redShape redCentroid redOrientation;...
    ones(size(greenShape, 1), 1)*green greenShape greenCentroid greenOrientation;...
    ones(size(blueShape, 1), 1)*blue blueShape blueCentroid blueOrientation;...
    ones(size(yellowShape, 1), 1)*yellow yellowShape yellowCentroid yellowOrientation];
%}

%{
%% For testing puspose, copy to the command prompt after you run this code
patternProps = ans;
table_Img = imread('Proper_Pics\Patterns\Pattern1.jpg');figure; imshow(table_Img); hold on; 
for n = 1:size(patternProps,1)
    plot(patternProps(n,3), patternProps(n,4), 'c*', 'MarkerSize', 8);
    pause;
end
%}
end