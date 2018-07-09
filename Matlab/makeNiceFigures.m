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


% forearm linear

pngNameF = 'uasd_4_l_farm_1_1.png'
imF = imread(pngNameF);
imCroppedF  = imF(75:500, 190:480);
manualNameF = 'uasd_4_l_farm_1_manual.png';
manualF = imread(manualNameF);
[rows cols] = size(imCroppedF);
manualScaledF = imresize(manualF, [rows cols]);
[diceCoeff shadowsF] = detectShadows('uasd_4_l_farm_1');
shadowsScaledF = imresize(shadowsF, [rows cols]);

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

%shadowsScaled( 241:269, 162:183)
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
set(r, 'AlphaData', (~shadowsScaled)/3);

% looking at RF data
patchSizeX = 5;
patchSizeY = 100;
[rf, headerRF] = RPread('uasd_3_l_rjoint_1.rf', 1);
patchY = [1000 2537];
patchX = 156;
[rows cols] = size(patchY);
window = [];
absHil = abs(hilbert(rf));
for i = 1:cols
    window(:,:,i) = absHil((patchY(i) - floor(patchSizeY)) : (patchY(i) + floor(patchSizeY)) , (patchX - floor(patchSizeX)):(patchX + floor(patchSizeX)));
end
window = log(window);
absHil = abs(hilbert(rf));
figure(3)
subplot(2,3,1)
imagesc(log10(absHil));
colormap(gca,'gray');
title('a) RF Echo Envelope Image (Log Scale)');
patchSizeY = 40;
for i = 1:cols
    if i == 1
        text((patchX - floor(patchSizeX/2)) - 80 , (patchY(i) - floor(patchSizeY/2)), 'Non-Shadow');
            
        rectangle('Position', ...
        [(patchX - floor(patchSizeX/2)), (patchY(i) - floor(patchSizeY/2)), patchSizeX, patchSizeY],  ...
        'EdgeColor' , 'b', 'LineWidth', 1);
    else
        text((patchX - floor(patchSizeX/2)) - 50 , (patchY(i) - floor(patchSizeY/2)), 'Shadow');
        rectangle('Position', ...
        [(patchX - floor(patchSizeX/2)), (patchY(i) - floor(patchSizeY/2)), patchSizeX, patchSizeY],  ...
        'EdgeColor' , 'r', 'LineWidth', 1);
    end
end

% labelling axis
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 64 128 192 256]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [5 716 716*2 716*3 716*4]);
xlabel('Scanline');
ylabel('Depth (cm)');

subplot(2,3,2);
maxVal1 = max(max(window(:,:,1)));
[tempRow tempCol] = size(window(:,:,1));
sizeWindow1 = tempRow*tempCol;
histogram(window(:,:,1), 'Normalization', 'probability', 'binWidth', 80*maxVal1/sizeWindow1, 'FaceColor', 'b');

% fitting rayleigh distribution to data
% note that data has to be reshaped because MLE function takes in a
% single dimension vector only
fitVals1 = 0:maxVal1/sizeWindow1:maxVal1;
nakaFit1 = fitdist(reshape(window(:,:,1),[],1), 'Nakagami');
mu(1) = nakaFit1.mu;
omega(1) = nakaFit1.omega;
hold on
nakaPlot1 = pdf(nakaFit1, fitVals1);
plot(fitVals1, nakaPlot1, '-b');

maxVal2 = max(max(window(:,:,2)));
[tempRow tempCol] = size(window(:,:,2));
sizeWindow2 = tempRow*tempCol;
histogram(window(:,:,2), 'Normalization', 'probability', 'binWidth', 80*maxVal2/sizeWindow2, 'FaceColor', 'r');

maxVal12 = max(max(window(:,:,2)));
fitVals2 = 0:maxVal2/sizeWindow2:maxVal1;
nakaFit2 = fitdist(reshape(window(:,:,2),[],1), 'Nakagami');
mu(2) = nakaFit2.mu;
omega(2) = nakaFit2.omega;
nakaFit2.mu = nakaFit2.mu/5;
nakaFit2.omega = nakaFit2.omega*1.05;
hold on
nakaPlot2 = pdf(nakaFit2, fitVals2);
plot(fitVals2, nakaPlot2, '-r')

xlabel('Echo Envelope of RF Data (Log Scale)');
ylabel('Probability');
legend('Non-Shadow Histogram', ...
    ['Non-Shadow Fit, \mu = ' num2str(round(mu(1),2)) ' \omega = ' num2str(round(omega(1),2))], ...
    'Shadow Histogram', ...
    ['Shadow Fit, \mu = ' num2str(round(mu(2),2)) ' \omega = ' num2str(round(omega(2),2))]);
title('b) Nakagami Fit of Different Patches');
grid minor;
hold off


subplot(2,3,3)
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
set(r, 'AlphaData', (~shadowsScaled)/4);
title('c) Radial Joint, Linear Transducer')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline');
ylabel('Depth (cm)');

subplot(2,3,4)
imagesc(imCroppedF);
colormap(gca,'gray');
green = cat(3, zeros(size(imCroppedF)), ones(size(imCroppedF)), zeros(size(imCroppedF)));
red = cat(3, ones(size(imCroppedF)), zeros(size(imCroppedF)), zeros(size(imCroppedF)));
hold on
h = imagesc(green);
hold off
set(h, 'AlphaData', (manualScaledF)/6);
hold on
r = imagesc(red);
hold off
set(r, 'AlphaData', (~shadowsScaledF)/4);
title('d) Forearm, Linear Transducer')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline');
ylabel('Depth (cm)');

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
set(r, 'AlphaData', (ph_sc_a)/4);
title('e) Ribcage, Curvilinear Transducer')
[x y] = size(imCScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline');
ylabel('Depth (cm)');

% airgap shadow with curvilinear
autoNameC = 'uasd_4_c_farm_1_auto.png';
autoC = double(imread(autoNameC));
[x y] = size(autoC);
autoCScaled = imresize(autoC, [ceil(x*(128/y)) 128]);
numRFsamples = 800;
RFSamplingRate = 18e6;
ss =size(autoCScaled);
depth = 1540*numRFsamples/RFSamplingRate/2;
nBlocks = ss(1);
nLines = ss(2);
probeCrystalPitch = 0.77;
probeRadius =0.071;
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

pngCName = 'uasd_4_c_farm_1_1.png';
imC = imread(pngCName);
imCCropped = imC(80:538,:);
[x y] = size(ph_sc_a);
imCScaled = imresize(imCCropped, [x y]);

%getting manual image

manualNameC = 'uasd_4_c_farm_1_manual.png';
manualC = double(imread(manualNameC));
[x y] = size(manualC);
manualCScaled = imresize(manualC, [ceil(x*(128/y)) 128]);
ss =size(manualCScaled);
depth = 1540*numRFsamples/RFSamplingRate/2;
nBlocks = ss(1);
nLines = ss(2);
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

subplot(2,3,6)
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
set(r, 'AlphaData', (ph_sc_a)/500);
title('Ribcage, Curvilinear Transducer')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline');
ylabel('Depth (cm)');
subplot(2,3,6)
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
set(r, 'AlphaData', (ph_sc_a)/900);
title('f) Forearm, Curvilinear Transducer')
[x y] = size(imCScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline');
ylabel('Depth (cm)');