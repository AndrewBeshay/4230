% Detect MSER regions.
[mserRegions, mserConnComp] = detectMSERFeatures(BWoverlay, ... 
    'RegionAreaRange',[200 16000],'ThresholdDelta',4);

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
filterIdx = aspectRatio' > 4; 
filterIdx = filterIdx | [mserStats.Eccentricity] > .95 ;
filterIdx = filterIdx | [mserStats.Solidity] < 0.55 | [mserStats.Solidity] > 0.85 ;
filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

% Remove regions
mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

%Show remaining regions
figure(32)
imshow(BWoverlay)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Geometric Properties')
hold off

% Show remaining regions
figure(45)
imshow(BWoverlay)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Stroke Width Variation')
hold off

