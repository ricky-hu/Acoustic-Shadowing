% rfScratch.m
% scratchpad to view RF files

function rfScratch(fileName, numFrames)

% not sure why but some of the headers for the .rf files don't match Sonix's lookup
% table, so instead of using sonix's off the shelf RF reader I am doing it
% manually myself
% 
% fid= fopen(fileName, 'r');
% 
% if( fid == -1)
%     error('Cannot open file');
% end
% 
% % read the header info
% hinfo = fread(fid, 19, 'int32');
% header.filetype = hinfo(1);
% header.nframes = hinfo(2);
% header.w = hinfo(3);
% header.h = hinfo(4);
% header.ss = hinfo(5);
% header.ul = [hinfo(6), hinfo(7)];
% header.ur = [hinfo(8), hinfo(9)];
% header.br = [hinfo(10), hinfo(11)];
% header.bl = [hinfo(12), hinfo(13)];
% header.probe = hinfo(14);
% header.txf = hinfo(15);
% header.sf = hinfo(16);
% header.dr = hinfo(17);
% header.ld = hinfo(18);bm
% header.extra = hinfo(19);

% rf(:,:,1) = fread(fid, [header.h, header.w], 'int16');

numFrames = 1;
[rf, headerRF] = RPread([fileName '.rf'], numFrames);
% comparing rf to bmode (hilbert transform) and manipulated bmode (log of
% hilbert transform)

figure(1);

f(1) = subplot(1,4,1);
imagesc(rf);
colormap(gca,'gray');
hcb = colorbar;
title('RF')

f(2) = subplot(1,4,2);
bmode = abs(hilbert(rf));
imagesc(bmode);
colormap(gca,'gray');
hcb = colorbar;
title('RF - Hilbert Transform')

f(3) = subplot(1,4,3);
bmode = log(bmode);
imagesc(bmode);
colormap(gca,'gray');
hcb = colorbar;
title('RF - Hilbert Transform (log scale)');

subplot(1,4,4);
bmodeProcessed = imread([fileName '_1.png']);
imagesc(bmodeProcessed);
colormap(gca,'gray');
title('B-Mode');

linkaxes(f, 'xy');
set(gcf,'color','white');

% investigating the log(hilbert(rf)) figure as it provides clear indication
% of shadow regions

boundaryThickness = 10;
[manualShadowMatrix, boundaryShadowMatrix, deepShadowMatrix] = outlineShadow(bmode, fileName, boundaryThickness);

% looking at the distributions of the rf data of each region (shadow, shadow boundary, and
% deep shadow)

[rows, cols] = size(rf);
shadowRFVals = zeros(1, (rows*cols));
boundaryRFVals = zeros(1, (rows*cols));
deepShadowRFVals = zeros(1, (rows*cols));

% have to do some indexing to keep track since data is large so the arrays
% for each regionar epreallocated to teh max possible size, otherwise the
% for loops take too long

numShadowRFVals = 0;
numBoundaryRFVals = 0;
numDeepShadowRFVals = 0;

% creating vectors for rf values for each region
% this loop checks which region the current rf index matches and appends
% the rf data to a vector associated with that region
for colIdx = 1:cols
    for rowIdx = 1:rows
        if manualShadowMatrix(rowIdx, colIdx) == 0
            shadowRFVals(1, numShadowRFVals + 1) = rf(rowIdx, colIdx);
            numShadowRFVals = numShadowRFVals + 1;
        end
        if boundaryShadowMatrix(rowIdx, colIdx) == 0
            boundaryRFVals(1, numBoundaryRFVals + 1) = rf(rowIdx, colIdx);
            numBoundaryRFVals = numBoundaryRFVals + 1;
        end
        if deepShadowMatrix(rowIdx, colIdx) == 0
            deepShadowRFVals(1, numDeepShadowRFVals + 1) = rf(rowIdx, colIdx);
            numDeepShadowRFVals = numDeepShadowRFVals + 1;
        end                 
    end
end

% resizing arrays so the preallocated zeros are gone
shadowRFVals = shadowRFVals(1,1:(numShadowRFVals));
boundaryRFVals = boundaryRFVals(1,1:(numBoundaryRFVals));
deepShadowRFVals = deepShadowRFVals(1,1:(numDeepShadowRFVals));

% plotting histograms of rf values in each region
% the minimum rf value is -32768 and the max is 32768

figure(2)

subplot(1,3,1);
histogram(shadowRFVals, 'BinWidth', 1);
xlabel('RF Value');
ylabel('Number of elements');
title('RF Distribution of Shadow Regions');

subplot(1,3,2);
histogram(boundaryRFVals, 'BinWidth', 1);
xlabel('RF Value');
ylabel('Number of elements');
title('RF Distribution of Boundary Regions');

subplot(1,3,3);
histogram(deepShadowRFVals, 'BinWidth', 1);
xlabel('RF Value');
ylabel('Number of elements');
title('RF Distribution of Deep Shadow Regions');


