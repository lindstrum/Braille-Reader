function text = brailleToText(image)
    %get the characte images
    characters = segmentImageToCharacters(image);
    %get the number of character images
    [r, c, numCharacters] = size(characters);
    %variables for keeping track if the next braille character should be
    %capital
    isCapital = false;
    isNumber = false;
    %variable for the returned text
    text = "";
    %for each of the characters, find the text character
    for i = 1 : numCharacters
        character = brailleCharacterToAlphabetCharacter(characters(:, :, i), isCapital, isNumber);
        if character == "CAPITAL"
            isCapital = true;
            isNumber = false;
        elseif character == "NUMBER"
            isNumber = true;
        elseif character == "LETTER"
            isNumber = false;
        else 
            text = text + character;
            isCapital = false;
            if character == " ";
                isNumber = false;
            end
        end
    end
end

