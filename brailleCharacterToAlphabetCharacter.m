function character = getBrailleCharacter(brailleCharacter, isCapital, isNumber)
%--------------------------------------------------------------------------         
% Inputs:       brailleCharacter is a binary image representing a braille.
%               It contains only white dots for the character coordinates
%
%               isCapital is a boolean that is true if this character is
%               meant to be capital (when a certain braille character came
%               before)
%
%               isNumber is a boolean that is true if this character is
%               meant to be a number (when a certain braille character came
%               before)
%               
% Outputs:      character is the specfic character than is shown in the
%               braille image. 
%               
% Description:  This function takes a braille character and corresponding
%               nonbraille character If the braille character is not actually a character
%              (such as a capital), it returns "CAPITAL"
%
% Complexity: O(n) -> Getting the properties is O(n)
%               
%--------------------------------------------------------------------------
    %Get the coordinates of each dot. See the function at the bottom to see
    %what rows and columns mean
    [rows, columns, numDots] = getProperties(brailleCharacter);
    %Find the character based on the properties (and whether its a capital
    %or number)
    switch numDots
        case 0
            character = " ";
        case 1
           switch rows 
               case 1
                   if isNumber
                       character = "1";
                   else
                       character = "a";
                   end
               case 2
                   character = ",";
               case 3
                   if columns == 1
                       character = "'";
                   else
                       character = "CAPITAL";
                   end
               otherwise 
                   character = "?";
           end
        case 2
            if rows == [1,1]
                character = "c";
            elseif rows == [2, 2]
                if isNumber
                    character = "3";
                else
                    character = ":";
                end
            elseif rows == [3, 3]
                character = "-";
            elseif rows == [1, 2]
                 if isNumber
                     if columns == [1, 1]
                        character = "2";
                     else
                         character = "5";
                     end
                 else 
                     if columns == [1, 1]
                        character = "b";
                     elseif columns == [2, 2]
                        character = "LETTER";
                     else
                        character = "e";
                     end
                 end
            elseif rows == [2, 1]
                if isNumber
                    character = "9";
                else 
                    character = "i";
                end
            elseif rows == [1, 3]
                 character = "k";
            elseif rows == [2, 3]
                 character = ";";
            elseif rows == [2, 1]
                 character = "*";
            else
                 character = "?";
            end
        case 3
            if rows == [1, 1, 2]
                if isNumber 
                    character = "4";
                else
                    character = "d";
                end
            elseif rows ==  [1, 2, 1]
                if isNumber
                    character = "6";
                else
                    character = "f";
                end
            elseif rows == [1, 3, 1]
                 character = "m";
            elseif rows == [1, 2, 2]
                if isNumber 
                    character = "8";
                else
                    character = "h";
                end
            elseif rows == [2, 1, 2]
                if isNumber 
                    character = "0"
                else
                    character = "j";
                end
            elseif rows == [1, 2, 3]
                 character = "l";
            elseif rows == [1, 3, 2]
                 character = "o";
            elseif rows == [2, 3, 1]
                 character = "s";
            elseif rows == [1, 3, 3]
                 character = "u";
            elseif rows == [2, 2, 3]
                 character = ".";
            elseif rows == [2, 3, 2]
                 character = "!";
            elseif rows == [3, 2, 3]
                character = '"';
            else
                 character = "_";
            end
        case 4
            if rows == [1, 2, 1, 2]
                if isNumber 
                    character = "7";
                else
                    character = "g";
                end
            elseif rows ==  [1, 3, 1, 2]
                 character = "n";
            elseif rows == [1, 2, 3, 1]
                 character = "p";
            elseif rows == [1, 2, 3, 2]
                 character = "r";
            elseif rows == [2, 1, 2, 3]
                 character = "w";
            elseif rows == [2, 3, 1, 2]
                 character = "t";
            elseif rows == [1, 2, 3, 3]
                 character = "v";
            elseif rows == [1, 3, 2, 3]
                 character = "z";
            elseif rows == [1, 3, 1, 3]
                 character = "x";
            elseif rows == [3, 1 ,2 ,3]
                character = "NUMBER";
            else 
                 character = "_";
            end
        case 5
            if rows == [1, 2, 3, 1, 2]
                 character = "q";
            elseif rows == [1, 3, 1, 2, 3]
                 character = "y";
            else
                 character = "_";
            end       
    end
    %if the character should be capital, translate to a capital
    if isCapital
        character = upper(character);
    end
end

function [rows, columns, N] = getProperties(brailleCharacter)
%--------------------------------------------------------------------------         
% Inputs:       brailleCharacter is a binary image representing a braille.
%               It contains only white dots for the character coordinates
%               
% Outputs:      rows is a row-vector that represents the row coordiantes of
%               the character in the order they appear in the character.
%               The order is based on going down the first column and then
%               the second column.
%
%               columns is a row-vector that represents the column coordiantes of
%               the character in the order they appear in the character.
%               The order is based on going down the first column and then
%               the second column
%               
% Description:  This function finds the properties of a braille character
%               image such as the row, column coordinates and the number of
%               dots
%
% Complexity: O(n) -> Region props is O(n)
%               
%--------------------------------------------------------------------------
    %Label the image
    [L, N] = bwlabel(brailleCharacter);
    %Get the size of the image
    [numRowPixels, numColPixels] = size(brailleCharacter);
    %% Find the absolute coordinates (pixels) of the center of each dot and the radius
    props = regionprops(L);
    y = [];
    x = [];
    for i=1:N
        bb = props(i).BoundingBox;
        centroid = props(i).Centroid;
        x = [x centroid(1)];
        y = [y centroid(2)];  
        radius = max(bb(3)/2, bb(4)/2);
    end
    %% find the relative coordinates: (i, j) where i = 1, 2, or 3 and j = 1 or 2
    
    %find the midpoint of the image in x and y
    xMidPoint = numColPixels / 2;
    yMidPoint = numRowPixels / 2;
    rows = [];
    columns = [];
    %for each row and column coordinate, find its relative coordinate
    for i = 1 : N
        %for the columns, its coordiante is based whether its coordiante is
        %less than or greater than the center
        if x(i) < xMidPoint
            columns(i) = 1;
        else
            columns(i) = 2;
        end
        % If the row coordainte is close to the center, its row coordainte
        % is  2. Else, it depends if the coordiante is before or after the
        % center
        if abs(y(i) - yMidPoint) < radius
            rows(i) = 2;
        elseif y(i) > yMidPoint
            rows(i) = 3;
        else 
            rows(i) = 1;
        end     
    end
end