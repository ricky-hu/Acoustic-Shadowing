% computeEntropyDice.m
% computes dice similarity coefficients from entropy methods

function computeEntropyDice(dirName)

% getting list of files in directory

files = dir(fullfile(dirName, '*_cropped.png'));
[numFiles dummy] = size(files);
diceList = {};

% running entropy shadow detection on each file

for n = 1:numFiles
    % clearing figures
    close all;
    fileName = files(n).name;
    [filepath,name,ext] = fileparts(fileName);
    if exist([name '_manual.png'])
        manualShadows = imread([name '_manual.png']);
        shadows = detectShadowsEntropy(fileName);
        diceCoeff = dice(~shadows, manualShadows)
        
        diceList{n,1} = name;
        diceList{n,2} = diceCoeff;
    end
end
