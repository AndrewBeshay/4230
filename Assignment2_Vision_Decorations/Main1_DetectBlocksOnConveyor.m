function centroids = Main1_DetectBlocksOnConveyor()
    % Detect on the Conveyer to see if blocks exist, return the centroids
    clc;
    
    CameraCalibrationConveyor;
    conveyorImg = imread('Proper_Pics\conveyor_AllShapes2.jpg');
    ConveyorImg = undistortImage(conveyorImg,cameraParamsConveyor);
    %figure(); imshow(ConveyorImg);
    
    conveyorImg = segmentSection(conveyorImg, 551, 1155, 1, 586);
    %figure(); imshow(conveyorImg);
    [BW,maskedRGBImage] = createConveyorMask(conveyorImg);
    BW = ~BW;
    BW = bwareaopen(BW,450);             % remove white noise
    
    % use regionprops to calculate centroids
    blockProps = regionprops(BW, 'Centroid','Area');
    centroids = vertcat(blockProps.Centroid);
    areas = vertcat(blockProps.Area);
    removeIdx = find(areas > 5000);
    areas(removeIdx) = [];
    centroids(removeIdx,:) = [];
    figure();
    imshow(BW); hold on;
    plot(centroids(:,1), centroids(:,2), 'c*', 'MarkerSize', 10);
    
    % convert to real life
    centroids = conveyorPxlToReal(centroids(:,1), centroids(:,2));  
end
