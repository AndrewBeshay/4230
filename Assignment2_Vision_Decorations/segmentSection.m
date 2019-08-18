function conveyerImg = segmentSection(conveyerImg, xmin, xmax, ymin, ymax)
    if xmin > 1
        conveyerImg(:,1:xmin,:) = 0;
    end
    
    if ymin > 1
        conveyerImg(1:ymin,:,:) = 0;
    end
    
    if xmax < size(conveyerImg, 2)
        conveyerImg(:,xmax:size(conveyerImg, 2),:) = 0;
    end
    
    if ymax < size(conveyerImg, 1)
        conveyerImg(ymax:size(conveyerImg, 1),:,:) = 0;
    end

end