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
logbmode = log(bmode);
imagesc(logbmode);
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

% plotting a single scanline, chose column 156 as it has different regions
% easily visible
colToPlot = 10;

figure()
set(gcf,'color','white');
d(1) = subplot(2,2,1);
plot(rf(:,colToPlot));
xlabel('Row')
ylabel('RF value');
title('Raw RF of scanline');

d(2) = subplot(2,2,2);
plot(abs(hilbert(rf(:,colToPlot))));
xlabel('Row')
ylabel('Absolute Value of Hilbert Transform');
title('Absolute Value of Hilbert Transform of Scanline');

d(3) = subplot(2,2,3);
imagesc(logbmode);
colormap(gca,'gray');
hold on;
[r, c] = size(logbmode);
% drawing red line to indicate scanline
line([colToPlot, colToPlot], [1, r], 'Color', [1, 0, 0]);
title('B-Mode');

d(4) = subplot(2,2,4);
imagesc(rot90(logbmode));
% drawing red line to indicate scanline
line([1, r], [colToPlot, colToPlot], 'Color', [1, 0, 0]);
colormap(gca,'gray');
title('B-Mode (Rotated)');

%linking x axis of appropriate plots
linkaxes([d(1), d(2), d(4)], 'x');

boundaryThickness = 10;
[manualShadowMatrix, boundaryShadowMatrix, deepShadowMatrix] = outlineShadow(bmode, fileName, boundaryThickness);

% looking at the distributions of the rf data of each region (shadow, shadow boundary, and
% deep shadow)

[rows, cols] = size(rf);
shadowRFVals = zeros(1, (rows*cols));
boundaryRFVals = zeros(1, (rows*cols));
deepShadowRFVals = zeros(1, (rows*cols));
noShadowRFVals = zeros(1, (rows*cols));

% have to do some indexing to keep track since data is large so the arrays
% for each regionar epreallocated to teh max possible size, otherwise the
% for loops take too long

numShadowRFVals = 0;
numBoundaryRFVals = 0;
numDeepShadowRFVals = 0;
numNoShadowRFVals = 0;

% creating vectors for rf values for each region
% this loop checks which region the current rf index matches and appends
% the rf data to a vector associated with that region
for colIdx = 1:cols
    for rowIdx = 1:rows
        if manualShadowMatrix(rowIdx, colIdx) == 0
            shadowRFVals(1, numShadowRFVals + 1) = rf(rowIdx, colIdx);
            numShadowRFVals = numShadowRFVals + 1;
        % building the matrix of RF values for non-shadows
        else
            noShadowRFVals(1, numNoShadowRFVals + 1) = rf(rowIdx, colIdx);
            numNoShadowRFVals = numNoShadowRFVals + 1;
        end
        % other regions don't have an else case, not considering the
        % inverse regions of other regions for now
        if boundaryShadowMatrix(rowIdx, colIdx) == 0
            boundaryRFVals(1, numBoundaryRFVals + 1) = rf(rowIdx, colIdx);
            numBoundaryRFVals = numBoundaryRFVals + 1;
        end
        if deepShadowMatrix(rowIdx, colIdx) == 0
            deepShadowRFVals(1, numDeepShadowRFVals + 1) = rf(rowIdx, colIdx);
            numDeepShadowRFVals = numDeepShadowRFVals + 1;
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
noShadowRFVals = noShadowRFVals(1,1:(numNoShadowRFVals));
% plotting histograms of rf values in each region
% the minimum rf value is -32768 and the max is 32768

figure()

% manually setting axis limit for now to visualize distributions
xint = [-2000, 2000];
yint = [0, .015];

set(gcf,'color','white');
suptitle('RF distributions of different regions');

subplot(1,4,1);
h(1) = histogram(shadowRFVals, 'BinWidth', 1, 'Normalization', 'probability');
xlim(xint);
ylim(yint);
xlabel('RF Value');
ylabel('Probability');
title('RF Distribution of Shadow Regions');

subplot(1,4,2);
h(2) = histogram(boundaryRFVals, 'Normalization', 'probability', 'binWidth', 1);
xlim(xint);
ylim(yint);
xlabel('RF Value');
ylabel('Probability');
title('RF Distribution of Boundary Regions');

subplot(1,4,3);
h(3) = histogram(deepShadowRFVals, 'BinWidth', 1, 'Normalization', 'probability');
xlim(xint);
ylim(yint);
xlabel('RF Value');
ylabel('Probability');
title('RF Distribution of Deep Shadow Regions');

subplot(1,4,4);
h(4) = histogram(noShadowRFVals, 'Normalization', 'probability', 'BinWidth', 1);
xlim(xint);
ylim(yint);
xlabel('RF Value');
ylabel('Probability');
title('RF Distribution of Non-Shadow Regions');



