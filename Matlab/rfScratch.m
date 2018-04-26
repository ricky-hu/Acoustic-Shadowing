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
% patch size chosen to be 3x the wave length from literature, corresponding
% to 3*0.1158mm
colToPlot = 156;
rowToPlot = 410;
freq = 13.3*10^6;   % linear transducer freq
vel = 1540;         % speed of sound in tissue
wavelength = vel/freq;  
depth = .05;          % depth setting for arm scans in m

[rows cols] = size(rf);
% size of patch in the scanline direction, which is 3x the wavelength
patchSizeY = ceil((rows/depth)*3*wavelength);
%size of patch in the x direction, which is totally heuristic for now
patchSizeX = 5;

% averaging rf values for neighboring scanlines (number to acreage is
% patchSizeX

for i = 1:cols
    % handling cases where patch extends beyond boundaries
    if (i < floor(patchSizeX / 2) + 1 )
        rfAvg(:,i) = mean(rf(:,(1:(i+floor(patchSizeX/2)))),2);
    elseif (i > (cols - floor(patchSizeX / 2))) 
        rfAvg(:,i) = mean(rf(:,((i-floor(patchSizeX/2)):cols)),2);
    else
        rfAvg(:,i) = mean(rf(:, (i-floor(patchSizeX/2)):(i+floor(patchSizeX/2))),2);
    end
end
    
figure()
set(gcf,'color','white');
d(1) = subplot(2,3,1);
plot(rf(:,colToPlot));
xlabel('Row')
ylabel('RF value');
title('Raw RF of scanline');

d(2) = subplot(2,3,2);
plot(rfAvg(:,colToPlot));
xlabel('Row')
ylabel('Averaged RF value');
title('Averaged Raw RF of scanline');

d(3) = subplot(2,3,3);
plot(abs(hilbert(rf(:,colToPlot))));
xlabel('Row')
ylabel('Absolute Value of Hilbert Transform');
title('Absolute Value of Hilbert Transform of Scanline');

d(4) = subplot(2,3,4)
plot(abs(hilbert(rfAvg(:,colToPlot))));
xlabel('Row')
ylabel('Absolute Value of Averaged Hilbert Transform');
title('Absolute Value of Averaged Hilbert Transform of Scanline');

d(5) = subplot(2,3,5);
imagesc(logbmode);
colormap(gca,'gray');
hold on;
[r, c] = size(logbmode);
% drawing red line to indicate scanline
line([colToPlot, colToPlot], [1, r], 'Color', [1, 0, 0]);
title('B-Mode');

d(6) = subplot(2,3,6);
imagesc(rot90(logbmode));
% drawing red line to indicate scanline
line([1, r], [colToPlot, colToPlot], 'Color', [1, 0, 0]);
colormap(gca,'gray');
title('B-Mode (Rotated)');

%linking x axis of appropriate plots
linkaxes([d(1), d(2), d(3), d(4), d(6)], 'x');


%----------------------------------------------------------------
% looking at characteristic window at 4 regions: no shadow, shadow
% boundary, shallow shadow, and deep shadow
patchY = [400 1140 1376 2537]
patchX = 156;
% size of patch in the scanline direction, which is 3x the pulse length
patchSizeY = 30;
%size of patch in the x direction, which is totally heuristic for now
patchSizeX = 5;

% indices are really confusing here 
absHil = abs(hilbert(rfAvg));
absHilFil = wiener2(absHil, [patchSizeY patchSizeX]);
logbmode = log(absHil);
logbmodeFil = log(absHilFil);
[rows cols] = size(patchY)
window = [];
for i = 1:cols
    window(:,:,i) = absHil((patchY(i) - floor(patchSizeY/2)) : (patchY(i) + floor(patchSizeY/2)) , (patchX - floor(patchSizeX/2)):(patchX + floor(patchSizeX/2)));
end

figure()

% plotting bmod and filtered bmode
w(1) = subplot(2,3,1);
imagesc(logbmode);
[rowsRF colsRF] = size(logbmode);
line([patchX, patchX], [1, rowsRF], 'Color', [1, 0, 0]);
colormap(gca,'gray');
title('B-Mode');

%drawing bounding box highlighting patches
for i = 1:cols
    rectangle('Position', ...
        [(patchX - floor(patchSizeX/2)), (patchY(i) - floor(patchSizeY/2)), patchSizeX, patchSizeY],  ...
        'EdgeColor' , 'r', 'LineWidth', 1);
    txtstr = [int2str(patchX) ', ' int2str(patchY(i))];
    text((patchX - floor(patchSizeX/2)) + 20 , (patchY(i) - floor(patchSizeY/2)), txtstr);
end

w(2) = subplot(2,3,2);
imagesc(logbmodeFil);
colormap(gca,'gray');
title('Bmode, Wiener Filtered')


% using MLE to fit rayleigh distributions to data
for i=1:cols
    w(i) = subplot(2,3,i+2);
    maxVal = max(max(window(:,:,i)));
    [tempRow tempCol] = size(window(:,:,i));
    sizeWindow = tempRow*tempCol;
    histogram(window(:,:,i), 'Normalization', 'probability', 'binWidth', maxVal/sizeWindow);
    
    % fitting rayleigh distribution to data
    % note that data has to be reshaped because MLE function takes in a
    % single dimension vector only
    fitVals = 0:maxVal/sizeWindow:maxVal;
    raylFit = fitdist(reshape(window(:,:,i),[],1), 'Rayleigh');
    nakaFit = fitdist(reshape(window(:,:,i),[],1), 'Nakagami');
    riciFit = fitdist(reshape(window(:,:,i),[],1), 'Rician');
    theta(i) = raylFit.B;
    mu(i) = nakaFit.mu;
    omega(i) = nakaFit.omega;
    s(i) = riciFit.s;
    sigma(i) = riciFit.sigma;
    hold on
    raylPlot = pdf(raylFit, fitVals);
    nakaPlot = pdf(nakaFit, fitVals);
    riciPlot = pdf(riciFit, fitVals);
    
    plot(fitVals, raylPlot, '-r');
    plot(fitVals, nakaPlot, '-b');
    plot(fitVals, riciPlot, '-g');

    xlabel('Absolute value of Hilbert Transformed RF data');
    ylabel('Probability');
    legend('Histogram of Data', ['Rayleigh fit, \theta = ' num2str(theta(i))], ...
        ['Nakagami fit, \mu = ' num2str(mu(i)) ' \omega = ' num2str(omega(i))], ...
        ['Rician fit, s = ' num2str(s(i)) ' \sigma = ' num2str(sigma(i))]);
    title(['Patch at ' int2str(patchX) ', ' int2str(patchY(i))]);
    hold off
end

% looking at parameters down entire scanline
theta = [];
mu = [];
omega = [];
for m = 1:rowsRF
    patchStartY = m - floor(patchSizeY/2);
    patchEndY = m + floor(patchSizeY/2);
    

    % handling boundaries
    if (m < floor(patchSizeY/2) + 1)
        patchStartY = 1;
    elseif (m > (rowsRF - ceil(patchSizeY/2)) - 1)
        patchEndY = rowsRF;
    end
    % patchX fixed as column 156 for now
    patch = absHil(patchStartY:patchEndY, (patchX - floor(patchSizeX/2): patchX + floor(patchSizeX/2)));
    raylFitRow = fitdist(reshape(patch,[],1), 'Rayleigh');
    nakaFitRow = fitdist(reshape(patch,[],1), 'Nakagami');
    theta(m) = raylFitRow.B;
    mu(m) = nakaFitRow.mu;
    omega(m) = nakaFitRow.omega;

end

figure()
p(1) = subplot(2,3,1);
imagesc(logbmode);
[rowsRF colsRF] = size(logbmode);
line([patchX, patchX], [1, rowsRF], 'Color', [1, 0, 0]);
colormap(gca,'gray');
title('B-Mode');

% plotting parameters down scanline

p(2) = subplot(2,3,2);
imagesc(rot90(logbmode));
% drawing red line to indicate scanline
line([1, rowsRF], [patchX, patchX], 'Color', [1, 0, 0]);
colormap(gca,'gray');
title('B-Mode (Rotated)');

p(3) = subplot(2,3,3);
plot(theta);
xlabel('Axial Element');
ylabel('\theta');
title('Rayleigh - \theta');

p(4) = subplot(2,3,4);
plot(theta);
xlabel('Axial Element');
ylabel('\mu');
title('Nakagami - \mu');

p(5) = subplot(2,3,5);
plot(theta);
xlabel('Axial Element');
ylabel('\omega');
title('Nakagami - \omega');

linkaxes([p(2), p(3), p(4), p(5), 'x']);
%     


% h(2) = histogram(boundaryRFVals, 'Normalization', 'probability', 'binWidth', 1);
% xlim(xint);
% ylim(yint);
% xlabel('RF Value');
% ylabel('Probability');
% title('RF Distribution of Boundary Regions');
% 


boundaryThickness = 10;
[manualShadowMatrix, boundaryShadowMatrix, deepShadowMatrix] = outlineShadow(bmode, fileName, boundaryThickness);

% looking at the distributions of the rf data of each region (shadow, shadow boundary, and
% deep shadow)

% [rows, cols] = size(rf);
% shadowRFVals = zeros(1, (rows*cols));
% boundaryRFVals = zeros(1, (rows*cols));
% deepShadowRFVals = zeros(1, (rows*cols));
% noShadowRFVals = zeros(1, (rows*cols));
% 
% % have to do some indexing to keep track since data is large so the arrays
% % for each regionar epreallocated to teh max possible size, otherwise the
% % for loops take too long
% 
% numShadowRFVals = 0;
% numBoundaryRFVals = 0;
% numDeepShadowRFVals = 0;
% numNoShadowRFVals = 0;
% 
% % creating vectors for rf values for each region
% % this loop checks which region the current rf index matches and appends
% % the rf data to a vector associated with that region
% for colIdx = 1:cols
%     for rowIdx = 1:rows
%         if manualShadowMatrix(rowIdx, colIdx) == 0
%             shadowRFVals(1, numShadowRFVals + 1) = rf(rowIdx, colIdx);
%             numShadowRFVals = numShadowRFVals + 1;
%         % building the matrix of RF values for non-shadows
%         else
%             noShadowRFVals(1, numNoShadowRFVals + 1) = rf(rowIdx, colIdx);
%             numNoShadowRFVals = numNoShadowRFVals + 1;
%         end
%         % other regions don't have an else case, not considering the
%         % inverse regions of other regions for now
%         if boundaryShadowMatrix(rowIdx, colIdx) == 0
%             boundaryRFVals(1, numBoundaryRFVals + 1) = rf(rowIdx, colIdx);
%             numBoundaryRFVals = numBoundaryRFVals + 1;
%         end
%         if deepShadowMatrix(rowIdx, colIdx) == 0
%             deepShadowRFVals(1, numDeepShadowRFVals + 1) = rf(rowIdx, colIdx);
%             numDeepShadowRFVals = numDeepShadowRFVals + 1;
%         end          
%         if deepShadowMatrix(rowIdx, colIdx) == 0
%             deepShadowRFVals(1, numDeepShadowRFVals + 1) = rf(rowIdx, colIdx);
%             numDeepShadowRFVals = numDeepShadowRFVals + 1;
%         end           
%     end
% end
% 
% % resizing arrays so the preallocated zeros are gone
% shadowRFVals = shadowRFVals(1,1:(numShadowRFVals));
% boundaryRFVals = boundaryRFVals(1,1:(numBoundaryRFVals));
% deepShadowRFVals = deepShadowRFVals(1,1:(numDeepShadowRFVals));
% noShadowRFVals = noShadowRFVals(1,1:(numNoShadowRFVals));
% % plotting histograms of rf values in each region
% % the minimum rf value is -32768 and the max is 32768
% 
% figure()
% 
% % manually setting axis limit for now to visualize distributions
% xint = [-2000, 2000];
% yint = [0, .015];
% 
% set(gcf,'color','white');
% suptitle('RF distributions of different regions');
% 
% subplot(1,4,1);
% h(1) = histogram(shadowRFVals, 'BinWidth', 1, 'Normalization', 'probability');
% xlim(xint);
% ylim(yint);
% xlabel('RF Value');
% ylabel('Probability');
% title('RF Distribution of Shadow Regions');
% 
% subplot(1,4,2);
% h(2) = histogram(boundaryRFVals, 'Normalization', 'probability', 'binWidth', 1);
% xlim(xint);
% ylim(yint);
% xlabel('RF Value');
% ylabel('Probability');
% title('RF Distribution of Boundary Regions');
% 
% subplot(1,4,3);
% h(3) = histogram(deepShadowRFVals, 'BinWidth', 1, 'Normalization', 'probability');
% xlim(xint);
% ylim(yint);
% xlabel('RF Value');
% ylabel('Probability');
% title('RF Distribution of Deep Shadow Regions');
% 
% subplot(1,4,4);
% h(4) = histogram(noShadowRFVals, 'Normalization', 'probability', 'BinWidth', 1);
% xlim(xint);
% ylim(yint);
% xlabel('RF Value');
% ylabel('Probability');
% title('RF Distribution of Non-Shadow Regions');



