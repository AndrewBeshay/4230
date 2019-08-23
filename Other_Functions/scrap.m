% scrap

% Find Centroids of all the shapes on the pattern
    %% use regionprops to calculate properties such as bounding box
    myPatternBW = im2bw(myPattern);
    s = regionprops(~myPatternBW,'BoundingBox');
    bbox = vertcat(s.BoundingBox);
    
    % store all values
    xCorner = bbox(:,1);
    yCorner = bbox(:,2);
    width = bbox(:,3);
    height = bbox(:,4);
    
    areas = [];
    for n = 1:size(width,1)
       area = width(n)*height(n);
       areas = [areas; area]; 
    end
    
    centroidX = xCorner + width/2;
    centroidY = yCorner + height/2;
    centroids = [centroidX centroidY];
    
    %% Drawing boxes 
    xmin = xCorner;
    ymin = yCorner;
    xmax = xmin + width - 1;
    ymax = ymin + height - 1;
    % Expand the bounding boxes by a small amount.
    expansionAmount = 0.02;
    xmin = (1-expansionAmount) * xmin;
    ymin = (1-expansionAmount) * ymin;
    xmax = (1+expansionAmount) * xmax;
    ymax = (1+expansionAmount) * ymax;
    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(myPatternGray,2));
    ymax = min(ymax, size(myPatternGray,1));
    
    % find the letters using their specific areas
    letterAreasIdx = find(areas > 5000 & areas < 10000); % need to change this when you have pics from camera
    % make all the letters white
    for l = 1: length(letterAreasIdx)
        myPattern(round(ymin(letterAreasIdx(l))):round(ymax(letterAreasIdx(l))), round(xmin(letterAreasIdx(l))):round(xmax(letterAreasIdx(l))), :) = 255;
    end
    % remove letters from the boxes drawn
    xmin(letterAreasIdx) = [];
    ymin(letterAreasIdx) = [];
    xmax(letterAreasIdx) = [];
    ymax(letterAreasIdx) = [];
    % remove letters from the list
    xCorner(letterAreasIdx) = [];
    yCorner(letterAreasIdx) = [];
    width(letterAreasIdx) = [];
    height(letterAreasIdx) = [];
    areas(letterAreasIdx) = [];
    centroids(letterAreasIdx,:) = [];
    
    % finds the border
    borderIdx = find(areas > 10000); 
    % remove letters from the boxes drawn
    xmin(borderIdx) = [];
    ymin(borderIdx) = [];
    xmax(borderIdx) = [];
    ymax(borderIdx) = [];
    % remove the border from the list
    xCorner(borderIdx) = [];
    yCorner(borderIdx) = [];
    width(borderIdx) = [];
    height(borderIdx) = [];
    areas(borderIdx) = [];
    centroids(borderIdx,:) = [];
    
    
    % Identify which of the centroids fall under the colour filter
    for n = 1:size(centroids,1)
        if ColourPatternBW(round(centroids(n,2)), round(centroids(n,1))) == 0
            % on that centroid the BW filter is black, as in the shape doesnt fall under that reagion
            % make the object on the pattern white
            myPattern(round(ymin(n)):round(ymax(n)), round(xmin(n)):round(xmax(n)), :) = 255;
            % remove from the list
            xmin(n) = 0; ymin(n) = 0; xmax(n) = 0; ymax(n) = 0;
            % remove the object from the list
            xCorner(n) = 0; yCorner(n) = 0; width(n) = 0; height(n) = 0; areas(n) = 0;
            centroids(n,:) = [0,0];
        end
    end
    xminZeroIdx = find(xmin == 0);
    yminZeroIdx = find(ymin == 0);
    xmaxZeroIdx = find(xmax == 0);
    ymaxZeroIdx = find(ymax == 0);
    xCornerZeroIdx = find(xCorner == 0);
    yCornerZeroIdx = find(yCorner == 0);
    widthZeroIdx = find(width == 0);
    heightZeroIdx = find(height == 0);
    areasZeroIdx = find(areas == 0);
    centroidZeroIdx = find(centroids(:,1) == 0);
    xmin(xminZeroIdx) = []; ymin(yminZeroIdx) = []; xmax(xmaxZeroIdx) = []; ymax(ymaxZeroIdx) = [];
    xCorner(xCornerZeroIdx) = []; yCorner(yCornerZeroIdx) = []; width(widthZeroIdx) = []; 
    height(heightZeroIdx) = []; areas(areasZeroIdx) = [];
    
    % Show the expanded bounding boxes of what is left
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1]; % left corner x and y, width and height
    IExpandedBBoxes = insertShape(myPattern,'Rectangle',expandedBBoxes,'LineWidth',3);
    
    %% feature detection
    figure();
    imshow(myFinalShp); 
    hold on;
    blockPts = detectHarrisFeatures(myShpGray, 'MinQuality', 0.0001);
    plot(blockPts.selectStrongest(40)); 
    hold off;
    
    figure();
    imshow(IExpandedBBoxes);
    hold on;
    plot(centroids(:,1), centroids(:,2), 'c*', 'MarkerSize', 8);
    % identify features from the pattern
    myPatternGray = rgb2gray(myPattern);
    patternPts = detectHarrisFeatures(myPatternGray, 'MinQuality', 0.01);
    plot(patternPts.selectStrongest(100));
    hold off;
    
    [blockFtrs,blockValidPts] = extractFeatures(myShpGray,blockPts, 'Method', 'Block'); % single
    [patternFtrs,patternValidPts] = extractFeatures(myPatternGray,patternPts, 'Method', 'Block'); % uint8
    indexPairs = matchFeatures(blockFtrs,patternFtrs,'MatchThreshold', 100, 'MaxRatio', 1);
    % , 'Method', 'Approximate', 
    
    matchedPoints1 = blockValidPts(indexPairs(:,1),:);
    matchedPoints2 = patternValidPts(indexPairs(:,2),:);
    
    figure(); showMatchedFeatures(myShpGray,myPatternGray,matchedPoints1,matchedPoints2, 'montage');
    legend('matched points 1','matched points 2');
    
    [tform, inlierShpPoints, inlierPatternPoints] = estimateGeometricTransform(matchedPoints1, matchedPoints2, 'projective');
    figure;
    showMatchedFeatures(myShpGray, myPatternGray, inlierShpPoints, inlierPatternPoints, 'montage');