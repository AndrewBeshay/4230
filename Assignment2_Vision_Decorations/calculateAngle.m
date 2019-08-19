function angle = calculateAngle(myShpBW)
    p = regionprops(myShpBW, 'Extrema'); 
    sortedExtrema = sort(p.Extrema(:,2), 'descend'); % sort the y values descending order
    firstPtIdx = find(p.Extrema(:,2) == sortedExtrema(1)); % find the largest value of y
    secondPtIdx = find(p.Extrema(:,2) == sortedExtrema(3));
    sides = p.Extrema(firstPtIdx(1),:) - p.Extrema(secondPtIdx(1),:); 
    angle = rad2deg(atan2(sides(2),-sides(1)));
    if angle > 90
        angle = angle - 90;
    end
    
    %figure; imshow(myShpBW); hold on;
    %plot(p.Extrema(:,1), p.Extrema(:,2), 'c*', 'MarkerSize', 8); hold off;
    
    %display("Angle Calculated based on the pic below :)");
    %figure; imshow(myShpBW); hold on;
    %plot(p.Extrema(firstPtIdx(1),1), p.Extrema(firstPtIdx(1),2), 'c*', 'MarkerSize', 8);
    %plot(p.Extrema(secondPtIdx(1),1), p.Extrema(secondPtIdx(1),2), 'c*', 'MarkerSize', 8); hold off;  
end