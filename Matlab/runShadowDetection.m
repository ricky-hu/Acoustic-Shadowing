% runShadowDetection
% main script to run shadow detection on all .rf files in the directory and
% compute dice coefficients

function diceList = runShadowDetection(dirName)

% getting list of files in directory

files = dir(fullfile(dirName, '*.rf'));
[numFiles dummy] = size(files);

% running detectShadows on each rf file
for n = 1:numFiles
    fileName = files(n).name;
    [filepath,name,ext] = fileparts(fileName);
    diceList(n,1) = fileName;
    diceList(n,2) = detectShadows(fileName);
end
    
    