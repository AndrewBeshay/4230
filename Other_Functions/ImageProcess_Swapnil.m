%% Load in the Picture 
I = imread('Assignment_2_Test_Pics\Test_Pattern.PNG');
imshow(I);

%% Filterin out the Boxes in the picture
BW = im2bw(I);
%     %SEsquareSmall = strel('square',10);
%     SEsquareLrg = strel('octagon',9);
%     workBinErode = imerode(~BW,SEsquareLrg);
%     %workBEOpen = imopen(workBinErode,SEsquareLrg);
%     
%     imshow(workBinErode);
    
    s = regionprops(~BW,'Area','BoundingBox','Centroid');
    
    imshow(BW);
    
    corners = [];
   for i = 1:numel(s)
   a = find (s(i).Area < 6500 && s(i).Area > 5000 && abs(s(i).BoundingBox(3)-s(i).BoundingBox(4)) < 5);
    if (a == 1)
        corners = [corners;s(i).BoundingBox];
    end
   end 
    
   BWoverlay = ~BW;
   
   for i = 1:size(corners,1)

    BWoverlay(corners(i,2):(corners(i,2) + corners(i,4)),...
        corners(i,1):(corners(i,1) + corners(i,3)))=0;
   end 
   
   
%    figure(20)
    imshow(BWoverlay)



%% Skeletonization 

% Icomplement = imcomplement(BWOverlay);
% BW = im2bw(Icomplement);
%imshow(BW);

%% Outlining the Skeletonization 

out = bwskel(BWoverlay);
%imshow(labeloverlay(I,out,'Transparency',0))



