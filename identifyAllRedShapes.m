function [Shape, Centroid, Orientation] = identifyAllRedShapes(myPatternBW, table_ImgBW)

    circle = 2.1;
    flower = 2.2;
    diamond = 2.3;
    square = 2.4;
    star4 = 2.5;
    star6 = 2.6;
    
    % identify all the shapes that exist in the pattern for that colour
    s = regionprops(myPatternBW, 'Centroid');
    centroids = vertcat(s.Centroid);
    Shape = [];
    Centroid = [];
    Orientation = [];
    
    for i = 1: size(centroids,1)
        blockBW = removeOtherShapes(table_ImgBW, centroids(i,:));
        shapeBW = removeOtherShapes(myPatternBW, centroids(i,:));
        s = regionprops(shapeBW, 'Area', 'Perimeter', 'MajorAxisLength', 'EquivDiameter');
        diff = abs(s.MajorAxisLength - s.EquivDiameter);
        
        if s.Area > 1150
            % circle
            Shape = [Shape; circle];
            
        elseif s.Area > 720 
            % either flower, diamond or square            
            if s.Perimeter > 130
                Shape = [Shape; flower];
            else 
                shapeBW = rotateToOriginal(shapeBW, blockBW);
                seSquare = strel('Square', 25);
                shapeBW2 = imopen(shapeBW, seSquare);
                a = find(shapeBW2);
                
                if length(a) > 0
                    Shape = [Shape; square];
                else 
                    Shape = [Shape; diamond];
                end
                
            end
            
        else 
            % 4 star or 6 star
            if diff > 5.2
                Shape = [Shape; star4];
            else
                Shape = [Shape; star6];
            end
            
        end
        
        Centroid = [Centroid; centroids(i,:)];
        angle = calculateAngle(blockBW);
        Orientation = [Orientation; angle];
    end
    
end