function conveyorCentroids = Main1_DetectBlocksOnConveyor()
    % Detect on the Conveyer to see if blocks exist, return the centroids
    clc;
    
    CameraCalibrationConveyor;
    conveyorImg = imread('Proper_Pics\conveyor5.jpg');
    conveyorImg = undistortImage(conveyorImg,cameraParamsConveyor);
    %figure(); imshow(conveyorImg);

    [BW,maskedRGBImage] = createConveyorMask3(conveyorImg);
    BW = ~BW;
    BW = segmentSection(BW, 555, 1155, 10, 586);
    BW = bwareaopen(BW,2000);             % remove white noise
    BW = bwmorph(BW, 'hbreak');

    % use regionprops to calculate centroids
    blockProps = regionprops(BW, 'Centroid','Area');
    centroids = vertcat(blockProps.Centroid);
    areas = vertcat(blockProps.Area);
    if size(centroids,1) > 0
        removeIdx = find(areas > 7000 | areas < 1000);
        areas(removeIdx) = [];
        centroids(removeIdx,:) = [];
        % convert to real life
        conveyorCentroids = conveyorPxlToReal(centroids(:,1), centroids(:,2));  

        figure();
        imshow(BW); hold on;
        plot(centroids(:,1), centroids(:,2), 'c*', 'MarkerSize', 10);
    else
        display("No blocks detected on the conveyor");
        conveyorCentroids = [];
    end
    
    
end
