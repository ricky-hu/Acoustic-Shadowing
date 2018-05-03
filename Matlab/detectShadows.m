% detectShadows.m
% main script to run shadow detection algorithm, compare with manual
% detection, and compute dice coefficients
% input:    fileName string name of the file base name without extension

function [diceCoeff, shadows] = detectShadows(fileName)

patchSizeX = 5;
patchSizeY = 30;

% reading RF file
numFrames = 1;
[rf, headerRF] = RPread([fileName '.rf'], numFrames);
[rows cols] = size(rf);
rfAvg = zeros(rows,cols);
% averaging over scanlines
for i = 1:cols
    % handling cases where patch extends beyond boundaries
    if (i < floor(patchSizeX / 2) + 1 )
        rfAvg(:,i) = mean(rf(:,(1:(i+floor(patchSizeX/2)))),2);
    elseif (i > (cols - floor(patchSizeX / 2))) 
        rfAvg(:,i) = mean(rf(:,((i-ceil(patchSizeX/2)):cols)),2);
    else
        rfAvg(:,i) = mean(rf(:, (i-floor(patchSizeX/2)):(i+floor(patchSizeX/2))),2);
    end
end

% performing absolute value of hilbert transform to obtain wavepacket of RF
absHil = abs(hilbert(rf));

load([fileName '_nakParams.mat'])
% assuming Nakagami maps have been computed to save time (can be changed later to call
% computeNakagamiMaps function

% detecting shadow susing otsu's method to threshold nakagami parameters

[detRows detCols] = size(absHil);

% thresholding by the scale parameter w

% padding ringdown

pad = 30;

shadows = ones(detRows, detCols);

for colIdx = 1:detCols
    
    %computing otsu thresholding levels for this scanline
    levelLineW = multithresh(log(omega(:,colIdx)));
    levelLineU = multithresh(log(mu(:,colIdx)));
    
    for rowIdx = pad:(detRows - pad)   
        if( log(omega(rowIdx, colIdx)) > levelLineW)
            shadows(1:rowIdx, colIdx) = 0;
        end
    end
end

% visualizing
figure()
f(1) = subplot(1,3,1);
imagesc(log10(absHil));
title('log(abs(hilbert(rf))) (almost b-mode)');
colormap(gca,'gray');
hcb = colorbar;

f(2) = subplot(1,3,2);
imagesc(shadows);
title('Detected shadows');  
colormap(gca,'gray');
hcb = colorbar;   



% comparing manual shadows and computing dice coefficient
boundaryThickness = 10;
[manualShadowMatrix, boundaryShadowMatrix, deepShadowMatrix] = outlineShadow(log(absHil), fileName, boundaryThickness);

manualShadowMatrix = double(manualShadowMatrix);
shadows = double(shadows);
diceCoeff = dice(shadows, manualShadowMatrix);

% further visualizing
f(3) = subplot(1,3,3);
imagesc(manualShadowMatrix);
title('Manual shadows');  
colormap(gca,'gray');
hcb = colorbar;   

linkaxes(f, 'xy')
