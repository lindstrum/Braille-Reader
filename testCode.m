%% Clear Workspace
close all; clear all; clc;

%% Test Images
%%
weAreGroup5 = testExtractionImage('images/group5.jpg',true,true) % Working
%%
testExtractionImage('images/abcdefghijk.jpg',true,true) % Working
%%
testExtractionImage('images/abcdefghijkWithTextAtBottom.jpg',true,true) % Working
%%
testExtractionImage('images/abcdefghijkWithTextAtTopAndBottom.jpg',true) % Working
%%
testExtractionImage('images/sentenceWithPeriod.jpg',false,true) % Working
%%
testExtractionImage('images/sentenceWithPeriod.jpg',true,true) % Sometimes does not work due to noise
%%
testExtractionImage('images/4linesOfText.jpg',true,true) % Working
%%
testExtractionImage('images/hH9.jpg',true,true) % Working
%%
testExtractionImage('images/brailleWord.jpg',true,true) % Not Working
%%
testExtractionImage('washroom/men.jpg',false,true,true) % Not working (men's washroom)
%%
testExtractionImage('washroom/women_close.jpg',false,true,true) % Not working (women's washroom at a close distance)
%%
testExtractionImage('washroom/women_far.jpg',false,true,true) % Not working (women's washroom at a far distance)

%% USER DEMO
testExtractionImage('images/j2.jpg',true,true)

%%
function text = testExtractionImage(imagePath,addNoise,showImages,invert)
if nargin < 2
    addNoise = false;
    showImages = false;
    invert = false;
elseif nargin < 3
    showImages = false;
end
if nargin < 4
    invert = false;
end

%% Read image
I = imread(imagePath);
if invert
    I = imcomplement(I);
end

%% Add noise for test purposes
if addNoise
    I = imnoise(I,'gaussian')
end

%% Extract braille
IBraille = removeNonBraille(I,showImages);

%% Get braille characters
characters = segmentImageToCharacters(IBraille);
figure
for i = 1:size(characters,3)
    subplot(1,size(characters,3),i), imshow(characters(:,:,i))
end

text = brailleToText(IBraille);
end