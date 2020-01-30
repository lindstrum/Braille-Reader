
function characters = segmentImageToCharacters(brailleImage);
%--------------------------------------------------------------------------         
% Inputs:       brailleImage is a binary image containing ONLY white braille dots 
%               
% Outputs:      characters is a 3d- array consisting of the braille
%               characters in the order they appear in the image. The first
%               two componets are the image dimensions and the third
%               component represents the index of the character in the
%               image. To access the ith image, the syntax 
%               characters(:, :, i) is used
%               
% Description:  This function takes a image full of braille characters and
%               segments the image into individual characters
%
% Assumptions: (1) The image consist of only white braille dots 
%
%              (2) All dots are (approximately) the same size 
%
%              (3) All dots are consistently spaced. That is, two adjacent
%                  dots in the same character are always the same distance from
%                  one another, and two adjacent characters are always the same
%                  distance from one another              
%
%              (4) There is line in the image where the first character has
%                  a dot in the left column
%
%              (5) There is a character with a dot in each column (not
%                  neccesarily the same row though)
%
%              (6) There is a character with a dot in two adjacent rows (not
%                  neccesarily same column though
%
%              (7) Dots are separated (measured from center) by more than
%                  two pixels
%   
%              (8) There are characters adjacent in x where the left character has 
%                  dots in the right column and the right character has got in the 
%                  left column. Note these characters do not need to be in
%                  the same row
%
%              (9) There are characters adjacent in y where the upper character has 
%                  dots in the bottom row and the lower character has dots
%                  in the upper row. Note these characters do not need to
%                  be in the same column
%
%              (10) There is a line where the first characters is not a
%                   space. 
%
%              (11) All lines are assumed to be the same length. If, by
%                   chance, one line is way shorter than the line of maximum
%                   length, the program assumes the extra space are spaces.
%
%              (12) There is a line where the last character is not a space
%
%`             (13) The distance between characters should be sufficently
%                   larger than the distance between dots in the same
%                   character
%
% Complexity: O(n^2) -> This comes from the fact that I resize the
%                       character array every image. This could be improved
%                       to average O(n) if I fix the size at the start but
%                       I have bugs doing that
%               
%--------------------------------------------------------------------------
    %Settings
    minimumSeparation = 2; %Minimum amount two dots must be separated
    %get number of characters in a line of braille in the image
    numCharactersInLine = getNumCharactersInLine(brailleImage, minimumSeparation);
    %get the number of rows of braille in the image
    numRows = getNumRows(brailleImage, minimumSeparation);
    %get the dimensions of a braille character, see function to see what
    %each output means
    [width, height, hspacing, vspacing] =  getCharacterDimensions(brailleImage, minimumSeparation);
    %padd image with zeros by two braille characters in each direaction.
    %This is incase a braille character with one column ends a line and is
    %cut short and to add a space
    brailleImage = padarray(brailleImage,[round(height),round(2 * width) + round(hspacing)]);
    %find the first braille character (upper left corner of it)
    [startY, startX] = getFirstRectCoordinates(brailleImage);
    %counters used to keep track of where we are in the image. These
    %represent the upper left corners of the characters
    currentY = startY;
    currentX = startX;
    %counter for the image number we are on
    imageCounter = 1;
    %extract the characters from the original image
    for i = 1 : numRows
        for j = 1 : numCharactersInLine
            characters(:, :, imageCounter) = brailleImage(currentY : currentY + height, currentX : currentX + width);
            currentX = currentX + width + hspacing;
            imageCounter = imageCounter + 1;
        end
        currentY = currentY + height + vspacing;
        currentX = startX;
    end
end



function numCharactersInALine = getNumCharactersInLine(brailleImage, minimumSeparation)
%--------------------------------------------------------------------------         
% Inputs:       brailleImage is an grayscale image containing ONLY white braille dots 
%
%               radiusRange is the range of radi of the dots
%
%               minimum separation is the minimum two dots must be
%               separated in order to be distinct
%               
% Outputs:      numCharactersInALine is the number of characters in every
%               line of braille text in the image. This will include spaces
%               
% Description:  This function finds the number of characters a line of
%               braille text 
% 
% Complexity: Average O(n) -> average comes from getting the character
%             dimensions
%--------------------------------------------------------------------------
    %find the centers of each dot
    centers = getDotProperties(brailleImage);
    %the width of a line is the difference between the leftmost and
    %rightmost dots. Note that if all last characters only have one left
    %column, this will be an underestimate, and this is accounted for below
    widthOfLine = max(centers(:, 1)) - min(centers(:, 1));
    %get the dimensions of a character
    [width, height, hspacing, vspacing] = getCharacterDimensions(brailleImage, minimumSeparation);
    %It starts at 1 and we include 1 to add a space at each line
    numCharactersInALine = 2;
    %subtract character width from line width until there are no more
    %characters. The number of times you do this is the number of
    %characters in a row
    while(widthOfLine > width)
        numCharactersInALine =  numCharactersInALine + 1;
        widthOfLine = widthOfLine - width - hspacing;
    end
end

function numRows = getNumRows(brailleImage, minimumSeparation)
%--------------------------------------------------------------------------         
% Inputs:       brailleImage is an grayscale image containing ONLY white braille dots 
%
%               radiusRange is the range of radi of the dots
%
%               minimum separation is the minimum two dots must be
%               separated in order to be distinct
%               
% Outputs:      numRows is the number of rows of braille in the image
%               
% Description:  This function finds the number of rows of braille in the
%               image
% 
% Complexity: Average O(n) -> average comes from getting the character
%             dimensions
%--------------------------------------------------------------------------
    %find the centers of each of the dots
    centers = getDotProperties(brailleImage);
    %the height of the text is the difference between y-coordinates of the
    %highest and lowest dot. Note that if all bottom top row characters
    %have no top row or all bottom row characters have no bottom row, this
    %will be an underestimate, and this is accounted for below
    heightOfText = max(centers(:, 2)) - min(centers(:, 2));
    %get the character dimensions
    [width, height, hspacing, vspacing] = getCharacterDimensions(brailleImage, minimumSeparation);
    %if vspacing is negative, it only has one row (assumed)
    if(vspacing < 0)
        numRows = 1;
    else 
    %subtract off the character height until there are no more characters
    %left. The number of times you do this is the number of rows
        numRows = 1;
        while(heightOfText > height)
            numRows =  numRows + 1;
            heightOfText = heightOfText - height - vspacing;
        end
    end
end

function [r, c] = getFirstRectCoordinates(brailleImage)
%--------------------------------------------------------------------------         
% Inputs:       brailleImage is an grayscale image containing ONLY white braille dots 
%     
%               radiusRange is the range of radi of the dots
%
% Outputs:      r and c are the row and column of the upper left corner of
%               the characer
%               
% Description:  This function finds the upper left corner of the first
%               braille character in the image
%
% Complexity: Worst Case O(n)
%--------------------------------------------------------------------------
    %find the centers and radii of each braille dot
    [centers, radii] = getDotProperties(brailleImage);
    %computer the average radii of the dots
    avgRadius = mean(radii);
    %find the center of the first dot (farthest dot up and left)
    centerXFirstDot = min(centers(:, 1));
    centerYFirstDot = min(centers(:, 2));
    %calculate the coorinates of the corner
    c = centerXFirstDot - avgRadius;
    r = centerYFirstDot - avgRadius;
end

function [width, height, hspacing, vspacing] =  getCharacterDimensions(brailleImage, minimumSeparation)
%--------------------------------------------------------------------------         
% Inputs:       brailleImage is an grayscale image containing ONLY white braille dots 
%               
% Outputs:      width is the height of each braille character
%
%               height is the height of each braille character
%               
%               hspacing is the space between two horizontally adjacent braillie characters 
%
%               vspacing is the space between two vertically adjacent braille character
%               
% Description:  This function finds the dimensions of any braille character
%               in the image 
%
% Complxity: Average O(n) where n is the numer of pixels-> average comes
%            sorting being average 
%--------------------------------------------------------------------------
    %find the centers and radii of each braille dot
    [centers, radii] = getDotProperties(brailleImage); 
   
    %sort the center points by row and column coordinates
    sortedXCoordinates = bucketsort(centers(:, 1));
    sortedYCoordinates = bucketsort(centers(:, 2));
    %find the minimum distance between two dots in vertical and horiztonal
    %and the minimum distance between two characters (from the centers of dots). 
    %minXDist/minYDist is the minimum spacing between two dots in x/y-direction which
    %is the separation between two dots in a row/column
    [minXDist, hspacing] =  minimumDifference(sortedXCoordinates, minimumSeparation);
    [minYDist, vspacing] = minimumDifference(sortedYCoordinates, minimumSeparation);
   
    %calculate average radius of circles 
    avgRadius = mean(radii);
     %subtract radii from spacing, because spacing is currently measured
    %from the centers of dots. We want it to be measured from the edge of
    %dots
    hspacing = hspacing - 2 * avgRadius; 
    vspacing = vspacing - 2 * avgRadius;
    %calculate width and height of a braille character
    width = 2 * avgRadius + minXDist;
    height = 2 * avgRadius + 2 * minYDist;
    
end

function [centers, radii] = getDotProperties(brailleImage)
   [labels, numDots] = bwlabel(brailleImage);
    centers = zeros(numDots, 2);
    radii = zeros(numDots, 1);
    props = regionprops(labels);
    for i = 1 : numDots
        centers(i, 1) = props(i).Centroid(1);
        centers(i, 2) = props(i).Centroid(2);
       radii(i) = (props(i).BoundingBox(3) + props(i).BoundingBox(4))/4;
    end
end


function [firstMinimum, secondMinimum] = minimumDifference(list, minimumSeparation)
%--------------------------------------------------------------------------         
% Inputs:       list is a sorted list of numbers 
%
%               minimumSeparation is the magnitude differences need to be in order to
%               be considered distinct
%               
% Outputs:      firstMinimum is the minimum difference between any two
%               numbers in the list greater than 1
%
%               secondMimum is the second lowest minimum difference between
%               any two number in the list greater than 1
%               
% Description:  Finds the 1st and 2nd minimum difference greater than 1 between any two numbers in the
%               list
%
% Usage: The minimum distance between dots in the x/y-direction is the
%        distance between dots in the same character and the second minimum
%        is the distance between dots in different characters
%
% Complexity: average O(n) where n is the size of the list -> average
%             because bucket sort is average O(n)
%--------------------------------------------------------------------------
    listLength = size(list, 1);
    %By default, there are no valid minimums. These would stay this way if
    %all adjacent dots are within minimum separation distance from one
    %another
    firstMinimum = -1;
    secondMinimum = -1;
    %if there is more than one number
    if(listLength > 1) 
        %compare each two adajcent numbers
        for i = 1 : listLength - 1
            difference = list(i + 1) - list(i);
            % if the two numbers are considered distinct from another (dots
            % are far enought apart)
            if(difference > minimumSeparation)
                %if there is no minimum yet
                if (firstMinimum < 0)
                    firstMinimum = difference;
                %if there is no second minimum and there is a first minimum
                elseif (secondMinimum < 0 && difference > firstMinimum + minimumSeparation)
                    secondMinimum = difference;
                %if smaller than first minimum (and distinct enought from
                %it)
                elseif(difference < firstMinimum - minimumSeparation)
                    secondMinimum = firstMinimum;
                    firstMinimum = difference;
                %if smaller than second minimum (and distinct enought from
                %it) but larger than the first minimum (by a sufficent
                %amount)
                elseif(difference < secondMinimum - minimumSeparation && difference > firstMinimum + minimumSeparation)
                    secondMinimum = difference;
                end 
            end   
        end
    end
end

%The following copyright is for all the code below

% Copyright (c) 2014, Brian Moore
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.


function sx = bucketsort(x)
%--------------------------------------------------------------------------
% Syntax:       sx = bucketsort(x);
%               
% Inputs:       x is a vector of length n
%               
% Outputs:      sx is the sorted (ascending) version of x
%               
% Description:  This function sorts the input array x in ascending order
%               using the bucket sort algorithm
%               
% Complexity:   O(n)      best-case performance
%               O(n)      average-case performance (if x is uniform)
%               O(n^2)    worst-case performance
%               O(n)      auxiliary space
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         January 5, 2014
%--------------------------------------------------------------------------

% Default load factor
alpha = 0.75; % alpha = n / m

% Find min and max elements of x
n = length(x);
[minx maxx] = minmax(x,n);

% Insert elements into m equal width buckets, each containing a doubly
% linked list
m = round(n / alpha);
dw = (maxx - minx) / m;
head = nan(1,m); % pointers to heads of bucket lists
prev = nan(1,n); % previous element pointers
next = nan(1,n); % next element pointers
last = nan(1,m); % temporary storage
for i = 1:n
    j = min(floor((x(i) - minx) / dw) + 1,m); % hack to make max(x) fall in last bucket
    if isnan(head(j))
        head(j) = i;
    else
        prev(i) = last(j);
        next(last(j)) = i;
    end
    last(j) = i;
end

% Bucket sort
sx = zeros(size(x)); % sorted array
kk = 0;
for j = 1:m
    % Check if jth bucket is nonempty
    if ~isnan(head(j))
        % Sort jth bucket
        x = insertionsort(x,prev,next,head(j));
        
        % Insert sorted elements into sorted array
        jj = head(j);
        while ~isnan(jj)
            kk = kk + 1;
            sx(kk) = x(jj);
            jj = next(jj);
        end
    end
end

end

function x = insertionsort(x,prev,next,head)
% Insertion sort for doubly-linked lists
% Note: In practice, x xhould be passed by reference

j = next(head); % start at second element
while ~isnan(j)
    pivot = x(j);
    i = j;
    while (~isnan(prev(i)) && (x(prev(i)) > pivot))
        x(i) = x(prev(i));
        i = prev(i);
    end
    x(i) = pivot;
    j = next(j);
end

end

function [min max] = minmax(x,n)
% Efficient algorithm for finding the min AND max elements of an array

% Initialize
if ~mod(n,2)
    % n is even
    if (x(2) > x(1))
        min = x(1);
        max = x(2);
    else
        min = x(2);
        max = x(1);
    end
    i = 3;
else
    % n is odd
    min = x(1);
    max = x(1);
    i = 2;
end

% Process elements in pairs
while (i < n)
    if (x(i + 1) > x(i))
        mini = x(i);
        maxi = x(i + 1);
    else
        mini = x(i + 1);
        maxi = x(i);
    end
    if (mini < min)
        min = mini;
    end
    if (maxi > max)
        max = maxi;
    end
    i = i + 2;
end

end

