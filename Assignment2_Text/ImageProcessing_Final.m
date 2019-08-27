%% Load in the Picture 
%Adding a Live Feed thingo 
I = imread("ImageFour.jpg");
%% Main function Part
%-----------------Initial function to filter out the boxes----------------
[BWoverlay,S] = BoxFilter(I);
%------------------Finding the text Area----------------------------------
[Pic] = convertBinImage2RGB(BWoverlay);
I = rgb2gray(Pic);
[I] = DetectText(I,Pic);
%-------Final Filtering of the image to get rid of everything except the text---------------- 
I = ~I;
[BWoverlay,S2] = BoxFilter(I);
%--------------------Show Final Filtered Image---------------------------- 
figure(25);
imshow(BWoverlay);
%---------------------Detecting the Bold Letters--------------------------
[mserReg,mserStat] = DetectBold(BWoverlay);


%------------------Function to Smoothen out the Image---------------------
binaryImage = SmoothImage(BWoverlay);

%---------------Finding the Path of the robot----------------------------

boundaries = FindPath(binaryImage);
BoundaryFilt = [];
for i = 1:size(boundaries,1)
    if (size(boundaries{i},1) > 149)
       BoundaryFilt = [BoundaryFilt;boundaries(i)]; 
    end   
end

%---------------Creating the Structs--------------------------------------
txtStructs = CreateStructs(BoundaryFilt,mserReg,mserStat);

%---------------Plotting the path----------------------------------------- 
b2 = txtStructs(8).points;
x = b2(:,2);
y = b2(:,1);
figure(67);
imshow(binaryImage);
hold on;
plot(x,y,'r-');
hold off;
%% Putting all the info into structs to be sent to the robot 
function txtStruct = CreateStructs(BoundaryFilt,mserReg,mserStat)
for i = 1:size(BoundaryFilt,1);
    temp = BoundaryFilt{i};
    %Gets rid of the duplicates 
    temp = unique(temp, 'row', 'stable');
    %Putting the Path into the struct
    txtStruct(i).points = temp;
    
    %Detect if character in the Bold Region
    
    for j = 1:size(mserStat,1)
        %CurrBox = mserStat(j).BoundingBox;
         CurrBox = mserReg(j).PixelList;
        Cond = (find(temp(5,1) == CurrBox(:,1)));
         Cond2 =(find(temp(5,2) == CurrBox(:,2)));
%         Cond = (find(temp(1,1) > CurrBox(2) && temp(1,1) < CurrBox(2) +CurrBox(4)));
%         Cond2 = (find(temp(1,2) > CurrBox(1) && temp(1,2) < CurrBox(1) +CurrBox(3)));
        
      if(~isempty(Cond) && ~isempty(Cond2))
            txtStruct(i).Bold = 1;
            break;       
      else  
            txtStruct(i).Bold = 0;    
      end     
    end 
        
end 

end 

%% Function to filter Boxes

function [BWoverlay,S] = BoxFilter(I)
BW = im2bw(I);
s = regionprops(~BW,'Area','BoundingBox','Centroid');
S = s;
corners = [];
   for i = 1:numel(s)
  %a = find (s(i).Area < 6500 && s(i).Area > 5000 && abs(s(i).BoundingBox(3)-s(i).BoundingBox(4)) < 5);
  a = find (s(i).Area < 70 && s(i).Area > 0 | (s(i).Area < 3000)) %&& s(i).Area > 0 && abs(s(i).BoundingBox(3)-s(i).BoundingBox(4)) < 50));
   if (a == 1)
        corners = [corners;s(i).BoundingBox];
    end
   end 
    
BWoverlay =  imcomplement(BW);
   
   for i = 1:size(corners,1)

    BWoverlay(corners(i,2):(corners(i,2) + corners(i,4)),...
        corners(i,1):(corners(i,1) + corners(i,3)))=0;
   end    
% figure(20)
% imshow(BWoverlay);
end 

%% Detecting the Text

function [I] = DetectText(I,Pic)
% Detect MSER regions.
[mserRegions, mserConnComp] = detectMSERFeatures(I, ... 
    'RegionAreaRange',[200 8000],'ThresholdDelta',3);

% Use regionprops to measure MSER properties
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

% Compute the aspect ratio using bounding box data.
bbox = vertcat(mserStats.BoundingBox);
w = bbox(:,3);
h = bbox(:,4);
aspectRatio = w./h;
% Threshold the data to determine which regions to remove. These thresholds
% may need to be tuned for other images.
filterIdx = aspectRatio' > 3; 
filterIdx = filterIdx | [mserStats.Eccentricity] > .95 ;
filterIdx = filterIdx | [mserStats.Solidity] < 0.2;
filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.7;
filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

% Remove regions
mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

% Show remaining regions
% figure(22)
% imshow(I)
% hold on
% plot(mserRegions, 'showPixelList', true,'showEllipses',false)
% title('After Removing Non-Text Regions Based On Geometric Properties')
% hold off

regionImage = mserStats.Image;
regionImage = padarray(regionImage, [1 1]);
% Compute the stroke width image.
distanceImage = bwdist(~regionImage); 
skeletonImage = bwmorph(regionImage, 'thin', inf);
strokeWidthImage = distanceImage;
strokeWidthImage(~skeletonImage) = 0;
% Compute the stroke width variation metric 
strokeWidthValues = distanceImage(skeletonImage);   
strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
% Threshold the stroke width variation metric
strokeWidthThreshold = 0.3;
strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;
% Process the remaining regions
for j = 1:numel(mserStats)
    
    regionImage = mserStats(j).Image;
    regionImage = padarray(regionImage, [1 1], 0);
    
    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);
    
    strokeWidthValues = distanceImage(skeletonImage);
    
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
    
    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;
    
end

% Remove regions based on the stroke width variation
mserRegions(strokeWidthFilterIdx) = [];
mserStats(strokeWidthFilterIdx) = [];

% % Show remaining regions
% figure(25)
% imshow(I)
% hold on
% plot(mserRegions, 'showPixelList', true,'showEllipses',false)
% title('After Removing Non-Text Regions Based On Stroke Width Variation')
% hold off
regionImage = mserStats(3).Image;
regionImage = padarray(regionImage, [1 1]);
% Compute the stroke width image.
distanceImage = bwdist(~regionImage); 
skeletonImage = bwmorph(regionImage, 'thin', inf);
strokeWidthImage = distanceImage;
strokeWidthImage(~skeletonImage) = 0;

% Get bounding boxes for all the regions
bboxes = vertcat(mserStats.BoundingBox);
% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

% Expand the bounding boxes by a small amount.
expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;

% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

% Show the expanded bounding boxes
expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
IExpandedBBoxes = insertShape(Pic,'Rectangle',expandedBBoxes,'LineWidth',3);

% Compute the overlap ratio
overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
% Set the overlap ratio between a bounding box and itself to zero to
% simplify the graph representation.
n = size(overlapRatio,1); 
overlapRatio(1:n+1:n^2) = 0;
% Create the graph
g = graph(overlapRatio);
% Find the connected text regions within the graph
componentIndices = conncomp(g);
% Merge the boxes based on the minimum and maximum dimensions.
xmin = accumarray(componentIndices', xmin, [], @min);
ymin = accumarray(componentIndices', ymin, [], @min);
xmax = accumarray(componentIndices', xmax, [], @max);
ymax = accumarray(componentIndices', ymax, [], @max);
% Compose the merged bounding boxes using the [x y width height] format.
textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
% Remove bounding boxes that only contain one text region
numRegionsInGroup = histcounts(componentIndices);
textBBoxes(numRegionsInGroup == 1, :) = [];
% Show the final text detection result.
ITextRegion = insertShape(Pic, 'Rectangle', textBBoxes,'LineWidth',3);

figure(30)
imshow(ITextRegion)
title('Detected Text')
for i = 1:size(I,1)
    for j = 1:size(I,2)
        if( i < ymin | i > ymax | j < xmin | j > xmax)
            I(i,j) = 0;
        end 
    end 
    
end

I = I;


end 

%% Detecting the Bold Regions of the Image

function [mserReg,mserStat] = DetectBold(BWoverlay)
    % Detect MSER regions.
[mserRegions2, mserConnComp2] = detectMSERFeatures(BWoverlay, ... 
    'RegionAreaRange',[200 16000],'ThresholdDelta',4);

% Use regionprops to measure MSER properties
mserStats2 = regionprops(mserConnComp2, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

% Compute the aspect ratio using bounding box data.
bbox = vertcat(mserStats2.BoundingBox);
w = bbox(:,3);
h = bbox(:,4);
aspectRatio = w./h;
% Threshold the data to determine which regions to remove. These thresholds
% may need to be tuned for other images.
filterIdx = aspectRatio' > 4; 
filterIdx = filterIdx | [mserStats2.Eccentricity] > .95 ;
filterIdx = filterIdx | [mserStats2.Solidity] < 0.55 | [mserStats2.Solidity] > 0.85 ;
filterIdx = filterIdx | [mserStats2.Extent] < 0.2 | [mserStats2.Extent] > 0.9;
filterIdx = filterIdx | [mserStats2.EulerNumber] < -4;

% Remove regions
mserStats2(filterIdx) = [];
mserRegions2(filterIdx) = [];


mserReg = mserRegions2;
mserStat = mserStats2;

%Show remaining regions
figure(32)
imshow(BWoverlay)
hold on
plot(mserRegions2, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Geometric Properties')
hold off

% Show remaining regions
figure(45)
imshow(BWoverlay)
hold on
plot(mserRegions2, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Stroke Width Variation')
hold off



end 
%% Function to smooth the Image Out

function binaryImage = SmoothImage(BWoverlay);
windowSize = 5; % Whatever odd integer you want that's more than 1.
kernel = ones(5)/windowSize^2;
blurredImage = conv2(BWoverlay, kernel, 'same');
binaryImage = blurredImage > 0.5;


end 
%% Function that creates the boundaries used for Path

function boundaries = FindPath(binaryImage);
%Using the BWBoundaries Method
BW3 = bwmorph(binaryImage,'thin',inf);
BW3 = bwmorph(BW3,'clean');
BW3 = bwmorph(BW3,'spur',4);
% se = strel('line',5,0);
% BW3 = imdilate(BW3,se);
boundaries = bwboundaries(BW3,'noholes');
end 
%% Function to convert Binary to RGB Image

function [RGB_Image] = convertBinImage2RGB(BinImage)
  RGB_Image = uint8( BinImage(:,:,[1 1 1]) * 255 );
end 

