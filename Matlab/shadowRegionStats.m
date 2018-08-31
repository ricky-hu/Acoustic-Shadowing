% shadowRegionStats.m
% gets Nakagami and Entropy stats of shadow giving an image name

function [rfStats, entropyStats] = shadowRegionStats(fileName)

boundaryThicknessInitial = 20;

% getting RF image
numFrames = 1;
[rf, headerRF] = RPread([fileName '.rf'], numFrames);

% looking at rf shadows
% should already have image outlined before using this function
% 0 = shadow, 1 = noshadow
[manualShadowMatrix, boundaryMatrix, deepShadowMatrix] = outlineShadow(rf, fileName, boundaryThicknessInitial);

% getting nakagami parameters
load([fileName '_nakParams.mat']);

% pre-allocating
[tempX tempY] = size(rf);
lengthStats = tempX*tempY;
shadowStats = zeros(1,lengthStats);
noShadowStats = zeros(1,lengthStats);
boundaryStats = zeros(1,lengthStats);
deepShadowStats = zeros(1,lengthStats);

shadowIdx = 1;
noShadowIdx = 1;
boundaryIdx = 1;
deepShadowIdx = 1;

logOmega = log10(omega);
[numRows numCols] = size(logOmega);
for row = 1:numRows
    for col = 1:numCols
        % checking if it is a manual shadow
        if manualShadowMatrix(row, col) == 0
            shadowStats(1,shadowIdx) = logOmega(row,col);
            shadowIdx = shadowIdx + 1;
        else
            noShadowStats(1,noShadowIdx) = logOmega(row,col);
            noShadowIdx = noShadowIdx + 1;
        end
        if boundaryMatrix(row, col) == 0
            boundaryStats(1,boundaryIdx) = logOmega(row,col);
            boundaryIdx = boundaryIdx + 1;
        end
        if deepShadowMatrix(row,col) == 0
            deepShadowStats(1,deepShadowIdx) = logOmega(row,col);
            deepShadowIdx = deepShadowIdx + 1;
        end
    end
end

endS = find(shadowStats, 1, 'last');
endNS = find(noShadowStats, 1 ,'last');
endB = find(boundaryStats, 1, 'last');
endDS = find(deepShadowStats, 1, 'last');

% truncating tailing zeros

shadowStats = shadowStats(1,1:endS);
noShadowStats = noShadowStats(1,1:endNS);
boundaryStats = boundaryStats(1,1:endB);
deepShadowStats = deepShadowStats(1,1:endDS);

% computing mean and std into return variable
rfStats(1,1) = mean(shadowStats);
rfStats(1,2) = std(shadowStats);
rfStats(2,1) = mean(noShadowStats);
rfStats(2,2) = std(noShadowStats);
rfStats(3,1) = mean(boundaryStats);
rfStats(3,2) = std(boundaryStats);
rfStats(4,1) = mean(deepShadowStats);
rfStats(4,2) = std(deepShadowStats);

% now looking at entropy stats

fileName = ['pngs\' fileName];
im = imread([fileName '_cropped.png']);
[manualShadowMatrix, boundaryMatrix, deepShadowMatrix] = outlineShadow(im, [fileName '_cropped'], boundaryThicknessInitial);

% obtaining entropy matrix
[entropy, temp] = detectShadowsEntropy([fileName '_cropped.png']);

% increasing entropy values by 1 to allow log scale

entropy = entropy + 1;
entropy = log10(entropy);

% pre-allocating
[tempX tempY] = size(entropy);
lengthStats = tempX*tempY;
shadowStats = zeros(1,lengthStats);
noShadowStats = zeros(1,lengthStats);
boundaryStats = zeros(1,lengthStats);
deepShadowStats = zeros(1,lengthStats);

shadowIdx = 1;
noShadowIdx = 1;
boundaryIdx = 1;
deepShadowIdx = 1;

[numRows numCols] = size(entropy);
for row = 1:numRows
    for col = 1:numCols
        % checking if it is a manual shadow
        if manualShadowMatrix(row, col) == 0
            shadowStats(1,shadowIdx) = entropy(row,col);
            shadowIdx = shadowIdx + 1;
        else
            noShadowStats(1,noShadowIdx) = entropy(row,col);
            noShadowIdx = noShadowIdx + 1;
        end
        if boundaryMatrix(row, col) == 0
            boundaryStats(1,boundaryIdx) = entropy(row,col);
            boundaryIdx = boundaryIdx + 1;
        end
        if deepShadowMatrix(row,col) == 0
            deepShadowStats(1,deepShadowIdx) = entropy(row,col);
            deepShadowIdx = deepShadowIdx + 1;
        end
    end
end

endS = find(shadowStats, 1, 'last');
endNS = find(noShadowStats, 1 ,'last');
endB = find(boundaryStats, 1, 'last');
endDS = find(deepShadowStats, 1, 'last');

% truncating tailing zeros

shadowStats = shadowStats(1,1:endS);
noShadowStats = noShadowStats(1,1:endNS);
boundaryStats = boundaryStats(1,1:endB);
deepShadowStats = deepShadowStats(1,1:endDS);

% computing mean and std into return variable
entropyStats(1,1) = mean(shadowStats);
entropyStats(1,2) = std(shadowStats);
entropyStats(2,1) = mean(noShadowStats);
entropyStats(2,2) = std(noShadowStats);
entropyStats(3,1) = mean(boundaryStats);
entropyStats(3,2) = std(boundaryStats);
entropyStats(4,1) = mean(deepShadowStats);
entropyStats(4,2) = std(deepShadowStats);