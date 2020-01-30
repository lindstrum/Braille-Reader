function I2 = removeNonBraille(I,showImages)
if nargin < 2
    showImages = false;
end

%% Contstants to play around with
BW_THRESH = 0.8;
STREL_SIZE = 5;
THIN_THRESH = 0.9;
BOUNDING_BOX_AREA_THRESH = 1.1;
CIRCLE_AREA_THRESH = 1.1;
ADAPTIVE_BLOCK_SIZE = [113 94];

%% Read the image (image may need to be inverted)
% I2 = rgb2gray(imread('brailleWord.jpg'));
I2 = rgb2gray(I);
if showImages
    figure, imshow(I2), title('Grayscale');
end

%% Remove noise from the image
% Median filter (just for comparison, not used for final output)
% figure, imshow(medfilt2(I2)), title('Median filter')

% Gaussian filter
I2 = imgaussfilt(I2);
if showImages
    figure, imshow(I2), title('Gaussian filter');
end

%% Thresholding and Inverting
% Adaptive Thresholding (just for comparison, not used for final output)
% I2 = blkproc(I2,ADAPTIVE_BLOCK_SIZE,@imbinarize);
% Iinverted = imcomplement(I2);
% Iinverted = imopen(Iinverted,strel('disk',STREL_SIZE));
% figure, imshow(Iinverted), title('Adaptive Thresholding')

% Global Thresholding
I2 = im2bw(I2,BW_THRESH);
Iinverted = imcomplement(I2);
Iinverted = imopen(Iinverted,strel('disk',STREL_SIZE)); % Open to clean it up a bit
if showImages
    figure, imshow(Iinverted), title('Global Thresholding');
end

%% Find blobs (connected components)
[L, N] = bwlabel(Iinverted);
props = regionprops(L, 'all');

%% Find circular blobs (using thinness ratio)
if numel(props) > 0
    areas = cat(1,props.Area);
    perimeters = cat(1,props.Perimeter);
    thinnessRatio = 4*pi*areas./perimeters.^2;
    
    circleIndices = find(thinnessRatio > THIN_THRESH);
    circles = props(circleIndices);
end
%% Remove round objects that aren't actually circles (like rectangles with rounded off corners)
if numel(circles) > 0
    areas = cat(1,circles.Area);
    boundingBoxes = cat(1,circles.BoundingBox);
    boundingBoxAreas = boundingBoxes(:,3).*boundingBoxes(:,4);
    
    circleIndices = find(areas*BOUNDING_BOX_AREA_THRESH <= boundingBoxAreas);
    circles = circles(circleIndices);
end
%% Assume that the braille is the small circles in the image
if numel(circles) > 0
    areas = cat(1,circles.Area);
    minArea = min(areas);
    potentialBrailleIndices = find(areas <= minArea*CIRCLE_AREA_THRESH);
    potentialBraille = circles(potentialBrailleIndices);
else
    potentialBraille = [];
end
%% Draw bounding boxes on the circles
if showImages
    for i=1:numel(potentialBraille)
        
        bb = potentialBraille(i).BoundingBox;
        rectangle('Position', bb, 'EdgeColor','r');
        
    end
end

%% Extract the letters
newImage = zeros(size(I2));
for i=1:numel(potentialBraille)
    newImage(potentialBraille(i).SubarrayIdx{:}) = Iinverted(potentialBraille(i).SubarrayIdx{:});
end

%% Output an image that is just the blobs extracted
if showImages
    figure, imshow(newImage),title('Just Braille');
end
I2 = newImage;
end