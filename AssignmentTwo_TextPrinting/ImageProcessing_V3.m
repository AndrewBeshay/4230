%% Load in the Picture 
I = imread("ImageOne.jpg");
%imshow(I);

%% Main function Part

%Make function to filter out the boxes 
[BWoverlay,S] = BoxFilter(I);

%Make function to Outline the Skeletonisation

[xPoints,yPoints, Branchpts,Pathpts] = SkelePath(BWoverlay);

[Pic] = convertBinImage2RGB(BWoverlay);

AnotherS = regionprops(BWoverlay,'Area','BoundingBox','Centroid');

%% Function to filter Boxes

function [BWoverlay,S] = BoxFilter(I)
BW = im2bw(I);
s = regionprops(~BW,'Area','BoundingBox','Centroid');
S = s;
corners = [];
   for i = 1:numel(s)
   a = find (s(i).Area < 6500 && s(i).Area > 5000 && abs(s(i).BoundingBox(3)-s(i).BoundingBox(4)) < 5);
  % a = find (s(i).Area < 1 && s(i).Area > 5000  && abs(s(i).BoundingBox(3)-s(i).BoundingBox(4)) < 5);
   if (a == 1)
        corners = [corners;s(i).BoundingBox];
    end
   end 
    
BWoverlay =  imcomplement(BW);
   
   for i = 1:size(corners,1)

    BWoverlay(corners(i,2):(corners(i,2) + corners(i,4)),...
        corners(i,1):(corners(i,1) + corners(i,3)))=0;
   end    
figure(20)
imshow(BWoverlay)
end 


%% Function to create the skeletonised path

function [Xpoints,Ypoints,BrchPts,Allpts,RGBPic] =  SkelePath(BWoverlay)
BW = im2bw(BWoverlay);
% BW2 = bwmorph(BW,'remove');
% BW3 = bwmorph(BW,'skel',Inf);
% imshow(BW3)
 
BW2 = bwmorph(BW,'skel',60);
BW2 = bwmorph(BW2,'clean');
Allpts = BW2;
out = bwmorph(BW2,'branchpoints');
out2 = bwskel(BW,'MinBranchLength',0);
BrchPts = out;

%out = bwskel(BW,'MinBranchLength',0);
%imshow(out);

Xpoints = [];
Ypoints = [];

XBranchpts = [];
YBranchpts = [];

for i = 1:size(out,2)
    for j = 1:size(out,1)
        if (find(out(j,i) == true))
            Xpoints = [Xpoints;j];
            Ypoints = [Ypoints;i];    
        end 
    end 
end 




for i = 1:size(out2,2)
    for j = 1:size(out2,1)
        if (find(out2(j,i) == true))
            XBranchpts = [XBranchpts;j];
            YBranchpts = [YBranchpts;i];    
        end 
    end 
end 



%Plotting Stuff
figure(21);
imshow(BWoverlay);
hold on;
plot(YBranchpts,XBranchpts,'y*');
hold on;
plot(Ypoints,Xpoints,'r*');
hold off;



% figure(22);
% imshow(labeloverlay(I,out,'Transparency',0))

end 

%% Function to convert Binary to RGB Image

function [RGB_Image] = convertBinImage2RGB(BinImage)
  RGB_Image = uint8( BinImage(:,:,[1 1 1]) * 255 );
end 

