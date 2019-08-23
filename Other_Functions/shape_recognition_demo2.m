% Demo to find certain shapes in an image based on their shape.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
fontSize = 20;

% Read in a standard MATLAB gray scale demo image.
% Let's let the user select from a list of all the demo images that ship with the Image Processing Toolbox.
folder = fileparts(which('pillsetc.png')); % Determine where demo folder is (works with all versions).
baseFileName = 'pillsetc.png';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% File doesn't exist -- didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end

% Read in image into an array.
rgbImage = imread(fullFileName);
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display it.
subplot(2, 2, 1);
imshow(rgbImage, []);
title('Input Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Give a name to the title bar.
set(gcf,'name','Shape Recognition Demo','numbertitle','off')

% If it's monochrome (indexed), convert it to color.
if numberOfColorBands > 1
	grayImage = rgbImage(:,:,2);
else
	% It's already a gray scale image.
	grayImage = rgbImage;
end

% Make a triangle on it.
triangleXCoordinates = [360 420 480];
triangleYCoordinates = [350 252 350];
traiangleBinaryImage = poly2mask(triangleXCoordinates, triangleYCoordinates, rows, columns);
% Burn it into the gray scale image.
grayImage(traiangleBinaryImage) = 255;

% Display it.
subplot(2, 2, 2);
imshow(grayImage, []);
title('Grayscale Image', 'FontSize', fontSize);

% Binarize the image.
binaryImage = grayImage > 120;
% Display it.
subplot(2, 2, 3);
imshow(binaryImage, []);
title('Initial (Noisy) Binary Image', 'FontSize', fontSize);

% Remove small objects.
binaryImage = bwareaopen(binaryImage, 300);
% Display it.
subplot(2, 2, 4);
imshow(binaryImage, []);
title('Cleaned Binary Image', 'FontSize', fontSize);

[labeledImage, numberOfObjects] = bwlabel(binaryImage);
blobMeasurements = regionprops(labeledImage,...
	'Perimeter', 'Area', 'FilledArea', 'Solidity', 'Centroid');

% Get the outermost boundaries of the objects, just for fun, so we can highlight/outline the current blob in red.
filledImage = imfill(binaryImage, 'holes');
boundaries = bwboundaries(filledImage);

% Collect some of the measurements into individual arrays.
perimeters = [blobMeasurements.Perimeter];
areas = [blobMeasurements.Area];
filledAreas = [blobMeasurements.FilledArea];
solidities = [blobMeasurements.Solidity];
% Calculate circularities:
circularities = perimeters .^2 ./ (4 * pi * filledAreas);
% Print to command window.
fprintf('#, Perimeter,        Area, Filled Area, Solidity, Circularity\n');
for blobNumber = 1 : numberOfObjects
	fprintf('%d, %9.3f, %11.3f, %11.3f, %8.3f, %11.3f\n', ...
		blobNumber, perimeters(blobNumber), areas(blobNumber), ...
		filledAreas(blobNumber), solidities(blobNumber), circularities(blobNumber));
end

% Say what they are.
% IMPORTANT NOTE: depending on the aspect ratio of the rectangle or triangle
for blobNumber = 1 : numberOfObjects
	% Outline the object so the user can see it.
	thisBoundary = boundaries{blobNumber};
	subplot(2, 2, 2); % Switch to upper right image.
	hold on;
	% Display prior boundaries in blue
	for k = 1 : blobNumber-1
		thisBoundary = boundaries{k};
		plot(thisBoundary(:,2), thisBoundary(:,1), 'b', 'LineWidth', 3);
	end
	% Display this bounary in red.
	thisBoundary = boundaries{blobNumber};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 3);
	subplot(2, 2, 4); % Switch to lower right image.
	
	% Determine the shape.
	if circularities(blobNumber) < 1.2
		% Theoretical value for a circle is 1.
		message = sprintf('For object #%d,\nthe perimeter = %.3f,\nthe area = %.3f,\nthe circularity = %.3f,\nso the object is a circle',...
			blobNumber, perimeters(blobNumber), areas(blobNumber), circularities(blobNumber));
		shape = 'circle';
	elseif circularities(blobNumber) < 1.5
		% Theoretical value for a square is (4d)^2 / (4*pi*d^2) = 4/pi = 1.273
		message = sprintf('For object #%d,\nthe perimeter = %.3f,\nthe area = %.3f,\nthe circularity = %.3f,\nso the object is a square',...
			blobNumber, perimeters(blobNumber), areas(blobNumber), circularities(blobNumber));
		shape = 'square';
	elseif circularities(blobNumber) > 1.5 && circularities(blobNumber) < 1.8
		% Theoretical value for an isosceles triangle is (3d)^2 / (4 * pi * 0.5 * d * d * sind(60)) = 9/(4 * pi * 0.5*sind(60)) = 1.6539
		message = sprintf('For object #%d,\nthe perimeter = %.3f,\nthe area = %.3f,\nthe circularity = %.3f,\nso the object is an isosceles triangle',...
			blobNumber, perimeters(blobNumber), areas(blobNumber), circularities(blobNumber));
		shape = 'triangle';
	else
		message = sprintf('The circularity of object #%d is %.3f,\nso the object is something else.',...
			blobNumber, circularities(blobNumber));
		shape = 'something else';
	end
	
	% Display the classification that we determined in overlay above the object.
	overlayMessage = sprintf('Object #%d = %s\ncirc = %.2f, s = %.2f', ...
		blobNumber, shape, circularities(blobNumber), solidities(blobNumber));
	text(blobMeasurements(blobNumber).Centroid(1), blobMeasurements(blobNumber).Centroid(2), ...
		overlayMessage, 'Color', 'r');
	
	% Ask the user if they want to continue
	if blobNumber < numberOfObjects
		button = questdlg(message, 'Continue', 'Continue', 'Cancel', 'Continue');
		if strcmp(button, 'Cancel')
			break;
		end
	end
end

