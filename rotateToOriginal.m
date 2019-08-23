function myPatternBW = rotateToOriginal(myPatternBW, blockBW)
% shift shape to the center
s = regionprops(myPatternBW, 'centroid');
centroid = [s.Centroid(1), (size(myPatternBW,1) - s.Centroid(2))];
myPatternBW = imtranslate(myPatternBW,[(size(myPatternBW,2)/2 - centroid(1)) -(size(myPatternBW,1)/2 - centroid(2))],'FillValues',0);

% calculate angle of the block, to know how much to rotate by
blockAngle = calculateAngle(blockBW);

myPatternBW = imrotate(myPatternBW,(90 - blockAngle),'bilinear','crop');
%figure; imshow(myPatternBW);

end