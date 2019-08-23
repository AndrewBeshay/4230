function table_ImgBW = removeLettersAndNumbers(table_ImgBW)

s = regionprops(table_ImgBW, 'MajorAxisLength', 'BoundingBox'); 
bbox = vertcat(s.BoundingBox);
majorAxis = vertcat(s.MajorAxisLength);

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

idx = find(majorAxis > 75);

for l = 1: length(idx)
    table_ImgBW(round(ymin(idx(l))):round(ymax(idx(l))), round(xmin(idx(l))):round(xmax(idx(l))), :) = 0;
end

%figure; imshow(table_ImgBW); hold on;
%centroid(idx,:) = [];
%plot(centroid(:,1), centroid(:,2), 'c*', 'MarkerSize', 8); hold off;
end