% runShadowDetection
% main script to run shadow detection on all .rf files in the directory and
% compute dice coefficients

function diceList = runShadowDetection(dirName)

% getting list of files in directory

files = dir(fullfile(dirName, '*.rf'));
[numFiles dummy] = size(files);
diceList = {};
% running detectShadows on each rf file

for n = 1:numFiles
    % clearing figures
    close all;
    fileName = files(n).name;
    [filepath,name,ext] = fileparts(fileName);
    if exist([name '_nakParams.mat'], 'file')
        diceList{n,1} = name;
        [diceList{n,2} shadows] = detectShadows(name);
    end
end
    
    