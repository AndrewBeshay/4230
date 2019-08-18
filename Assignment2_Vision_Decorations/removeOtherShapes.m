function table_ImgBW = removeOtherShapes(table_ImgBW, shapeCentroids)
% this takes the centroid of a given shape and removes all the other shapes
% works with the other blocks as well

% centroid of the blocks
blockStats = regionprops(table_ImgBW,'Centroid', 'BoundingBox');
blockCentroids = vertcat(blockStats.Centroid); 
bbox = vertcat(blockStats.BoundingBox);

% store all values
xCorner = bbox(:,1);
yCorner = bbox(:,2);
width = bbox(:,3);
height = bbox(:,4);

%% Drawing boxes 
xmin = xCorner;
ymin = yCorner;
xmax = xmin + width - 1;
ymax = ymin + height - 1;
% Expand the bounding boxes by a small amount.
expansionAmount = 0.01;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;
% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(table_ImgBW,2));
ymax = min(ymax, size(table_ImgBW,1));

% find the closest distance of the shape to the block
distance = sqrt( (blockCentroids(:,1) - shapeCentroids(1)).^2 + (blockCentroids(:,2) - shapeCentroids(2)).^2 );
furthestIdx = find(distance ~= min(distance));
blockCentroids(furthestIdx,:) = [];

for l = 1: length(furthestIdx)
    table_ImgBW(round(ymin(furthestIdx(l))):round(ymax(furthestIdx(l))), round(xmin(furthestIdx(l))):round(xmax(furthestIdx(l))), :) = 0;
end

%figure; imshow(table_ImgBW); hold on;
%plot(blockCentroids(1), blockCentroids(2), 'c*', 'MarkerSize', 9); hold off;
end