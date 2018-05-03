% makeNiceFigures.m
% script for me to make some nice figures
% don't run this it only works for a specific directory, this is just a random
% helper script

function makeNiceFigures()




% getting detected image
autoNameC = 'uasd_3_c_r_1_auto.png';
autoC = double(imread(autoNameC));
[x y] = size(autoC);
autoCScaled = imresize(autoC, [ceil(x*(128/y)) 128]);
numRFsamples = 2864;
RFSamplingRate = 18e6;
ss =size(autoCScaled);
depth = 1540*numRFsamples/RFSamplingRate/2;
nBlocks = ss(1);
nLines = ss(2);
probeCrystalPitch = 0.47;
probeRadius =0.061;
probeWidth = probeCrystalPitch*ss(2)*1e-3;
width = probeWidth;
Rt = probeRadius;
Rm = -1.0;
% Rm = 1e-8;
dR = depth / nBlocks;
dT = width / nLines / Rt;
%dT = width / nLines;
dP = 0.0;
dX = 0.5e-3;
sc = ScanConversion(Rt, Rm, dR, dT, dP, nBlocks, nLines, 1, dX, dX, 1);
ph_sc_a = sc.ScanConvert(autoCScaled);

pngCName = 'uasd_3_c_r_1_1.png';
imC = imread(pngCName);
imCCropped = imC(80:538,:);
[x y] = size(ph_sc_a);
imCScaled = imresize(imCCropped, [x y]);

%getting manual image

manualNameC = 'uasd_3_c_r_1_manual.png';
manualC = double(imread(manualNameC));
[x y] = size(manualC);
manualCScaled = imresize(manualC, [ceil(x*(128/y)) 128]);
numRFsamples = 2864;
RFSamplingRate = 18e6;
ss =size(manualCScaled);
depth = 1540*numRFsamples/RFSamplingRate/2;
nBlocks = ss(1);
nLines = ss(2);
probeCrystalPitch = 0.47;
probeRadius =0.061;
probeWidth = probeCrystalPitch*ss(2)*1e-3;
width = probeWidth;
Rt = probeRadius;
Rm = -1.0;
% Rm = 1e-8;
dR = depth / nBlocks;
dT = width / nLines / Rt;
%dT = width / nLines;
dP = 0.0;
dX = 0.5e-3;
sc = ScanConversion(Rt, Rm, dR, dT, dP, nBlocks, nLines, 1, dX, dX, 1);
ph_sc_m = sc.ScanConvert(manualCScaled);

figure(1)
imagesc(imCScaled);
colormap(gca,'gray');
green = cat(3, zeros(size(imCScaled)), ones(size(imCScaled)), zeros(size(imCScaled)));
red = cat(3, ones(size(imCScaled)), zeros(size(imCScaled)), zeros(size(imCScaled)));
hold on
h = imagesc(green);
hold off
set(h, 'AlphaData', (ph_sc_m)/6);
hold on
r = imagesc(red);
hold off
set(r, 'AlphaData', (ph_sc_a)/6);


% linear shadows 
%cutting off blackfill, looks like it goes 150 pixels on left and right and
%75 pixels from top to bottom
%
pngName = 'uasd_3_l_rjoint_1_1.png'
im = imread(pngName);

imCropped  = im(75:500, 190:480);
colormap(gca,'gray');
manualName = 'uasd_3_l_rjoint_1_manual.png'
manual = imread(manualName);

[rows cols] = size(imCropped);
manualScaled = imresize(manual, [rows cols]);

manualScaled = ~double(manualScaled);

% gettin detected shadows
[diceCoeff shadows] = detectShadows('uasd_3_l_rjoint_1');
shadowsScaled = imresize(shadows, [rows cols]);

figure(2)
imagesc(imCropped);
colormap(gca,'gray');
green = cat(3, zeros(size(imCropped)), ones(size(imCropped)), zeros(size(imCropped)));
red = cat(3, ones(size(imCropped)), zeros(size(imCropped)), zeros(size(imCropped)));
hold on
h = imagesc(green);
hold off
set(h, 'AlphaData', (~manualScaled)/6);
hold on
r = imagesc(red);
hold off
set(r, 'AlphaData', (shadowsScaled)/6);

% looking at RF data
patchSizeX = 5;
patchSizeY = 100;
[rf, headerRF] = RPread(['uasd_3_l_rjoint_1.rf'], 1);
patchY = [1000 2537];
patchX = 156;
[rows cols] = size(patchY);
window = [];
for i = 1:cols
    window(:,:,i) = absHil((patchY(i) - floor(patchSizeY)) : (patchY(i) + floor(patchSizeY)) , (patchX - floor(patchSizeX)):(patchX + floor(patchSizeX)));
end
window = log(window);
absHil = abs(hilbert(rf));
figure(3)
subplot(2,3,1)
imagesc(log10(absHil));
colormap(gca,'gray');
title('Hilbert Transform of RF data');
patchSizeY = 40
for i = 1:cols
    rectangle('Position', ...
        [(patchX - floor(patchSizeX/2)), (patchY(i) - floor(patchSizeY/2)), patchSizeX, patchSizeY],  ...
        'EdgeColor' , 'r', 'LineWidth', 1);
    txtstr = [int2str(patchX) ', ' int2str(patchY(i))];
    text((patchX - floor(patchSizeX/2)) + 20 , (patchY(i) - floor(patchSizeY/2)), txtstr);
end

for i=1:cols
    w(i) = subplot(2,3,i+1);
    maxVal = max(max(window(:,:,i)));
    [tempRow tempCol] = size(window(:,:,i));
    sizeWindow = tempRow*tempCol;
    histogram(window(:,:,i), 'Normalization', 'probability', 'binWidth', 80*maxVal/sizeWindow);
    
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

    xlabel('Absolute Value of Hilbert Transformed RF Data (Log Scale)');
    ylabel('Probability');
    legend('Histogram of Data', ['Rayleigh fit, \theta = ' num2str(theta(i))], ...
        ['Nakagami fit, \mu = ' num2str(mu(i)) ' \omega = ' num2str(omega(i))], ...
        ['Rician fit, s = ' num2str(s(i)) ' \sigma = ' num2str(sigma(i))]);
    title(['Patch at ' int2str(patchX) ', ' int2str(patchY(i))]);
    hold off
end

subplot(2,3,4)
imagesc(imCropped);
colormap(gca,'gray');
green = cat(3, zeros(size(imCropped)), ones(size(imCropped)), zeros(size(imCropped)));
red = cat(3, ones(size(imCropped)), zeros(size(imCropped)), zeros(size(imCropped)));
hold on
h = imagesc(green);
hold off
set(h, 'AlphaData', (~manualScaled)/6);
hold on
r = imagesc(red);
hold off
set(r, 'AlphaData', (shadowsScaled)/6);
title('Detected Shadows of Radial Joint with Linear Transducer')

subplot(2,3,5)
imagesc(imCScaled);
colormap(gca,'gray');
green = cat(3, zeros(size(imCScaled)), ones(size(imCScaled)), zeros(size(imCScaled)));
red = cat(3, ones(size(imCScaled)), zeros(size(imCScaled)), zeros(size(imCScaled)));
hold on
h = imagesc(green);
hold off
set(h, 'AlphaData', (ph_sc_m)/6);
hold on
r = imagesc(red);
hold off
set(r, 'AlphaData', (ph_sc_a)/6);
title('Detected Shadows of Ribcage with Curvilinear Transducer')

set(gcf,'color','white');




