function conveyorList = Main1_DetectBlocksOnConveyor(app)
    % Detect on the Conveyer to see if blocks exist, return the centroids
    clc;
    
    CameraCalibrationConveyor;
    if app.ConType == 0
        conveyorImg = app.SnapConv;
    else
        conveyorImg = imread('Conveyor6.jpg');
    end
    conveyorImg = undistortImage(conveyorImg,cameraParamsConveyor);
    %figure(); imshow(conveyorImg);

    [BW,maskedRGBImage] = createConveyorMask2(conveyorImg);
    BW = ~BW;
    BW = segmentSection(BW, 560, 1155, 10, 586);
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
        conveyorList = conveyorPxlToReal(centroids(:,1), centroids(:,2));  
        conveyorList = [conveyorList zeros(size(conveyorList,1),1)];
        % figure();
        % imshow(BW); hold on;
        % plot(centroids(:,1), centroids(:,2), 'c*', 'MarkerSize', 10);
    else
        display("No blocks detected on the conveyor");
        conveyorList = [];
    end
    
    
end
