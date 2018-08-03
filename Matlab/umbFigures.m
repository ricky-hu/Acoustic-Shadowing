% umbFigures.m
% Making figures for technical note (condensed version of journalFigures.m)

% Figure 1 - Comparing manual, entropy, and rf detection
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
pngName = 'uasd_3_l_rjoint_1_1.png';
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
figure(1)
% showing RF detected shadows
subplot(4,2,1)
% imagesc(imCropped);
shadowsScaled(237:270,146:193) = 0;
colormap(gca,'gray');
fuse6a = imfuse(imCropped, ~shadowsScaled, 'blend');
imagesc(fuse6a);
% green = cat(3, zeros(size(imCropped)), ones(size(imCropped)), zeros(size(imCropped)));
% red = cat(3, ones(size(imCropped)), zeros(size(imCropped)), zeros(size(imCropped)));
% hold on
% h = imagesc(green);
% hold off
% set(h, 'AlphaData', (~manualScaled)/6);
% hold on
% r = imagesc(red);
% hold off
% set(r, 'AlphaData', (~shadowsScaled)/4);
title('a) Radial Joint, Linear Transducer')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');

subplot(4,2,3)
% imagesc(imCroppedF);
colormap(gca,'gray');
fuse6b = imfuse(imCroppedF, ~shadowsScaledF, 'blend');
imagesc(fuse6b);
% green = cat(3, zeros(size(imCroppedF)), ones(size(imCroppedF)), zeros(size(imCroppedF)));
% red = cat(3, ones(size(imCroppedF)), zeros(size(imCroppedF)), zeros(size(imCroppedF)));
% hold on
% h = imagesc(green);
% hold off
% set(h, 'AlphaData', (manualScaledF)/6);
% hold on
% r = imagesc(red);
% hold off
% set(r, 'AlphaData', (~shadowsScaledF)/4);
title('b) Forearm, Linear Transducer')
[x y] = size(imCroppedF);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,2,5)
imagesc(imCScaled);
colormap(gca,'gray');
fuse6C = imfuse(imCScaled, ph_sc_a, 'blend');
imagesc(fuse6C);
% green = cat(3, zeros(size(imCScaled)), ones(size(imCScaled)), zeros(size(imCScaled)));
% red = cat(3, ones(size(imCScaled)), zeros(size(imCScaled)), zeros(size(imCScaled)));
% hold on
% h = imagesc(green);
% hold off
% set(h, 'AlphaData', (ph_sc_m)/6);
% hold on
% r = imagesc(red);
% hold off
% set(r, 'AlphaData', (ph_sc_a)/4);
title('c) Ribcage, Curvilinear Transducer')
[x y] = size(imCScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
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

subplot(4,2,7)
imagesc(imCScaled);
colormap(gca,'gray');
fuse6d = imfuse(imCScaled, ph_sc_a, 'blend');
imagesc(fuse6d);
% green = cat(3, zeros(size(imCScaled)), ones(size(imCScaled)), zeros(size(imCScaled)));
% red = cat(3, ones(size(imCScaled)), zeros(size(imCScaled)), zeros(size(imCScaled)));
% hold on
% h = imagesc(green);
% hold off
% set(h, 'AlphaData', (ph_sc_m)/6);
% hold on
% r = imagesc(red);
% hold off
% set(r, 'AlphaData', (ph_sc_a)/900);
title('d) Forearm, Curvilinear Transducer')
[x y] = size(imCScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

set(gcf,'color','white');

% comparing to entropy images
shadowsCR = detectShadowsEntropy('pngs\uasd_3_c_r_1_cropped.png');
im8CR = imread('pngs\uasd_3_c_r_1_cropped.png');

shadowsCFa = detectShadowsEntropy('pngs\uasd_4_c_farm_1_cropped.png');
im8CFa = imread('pngs\uasd_4_c_farm_1_cropped.png');

shadowsLRj = detectShadowsEntropy('pngs\uasd_3_l_rjoint_1_cropped.png');
im8LRj = imread('pngs\uasd_3_l_rjoint_1_cropped.png');

shadowsLFa = detectShadowsEntropy('pngs\uasd_4_l_farm_1_cropped.png');
im8LFa = imread('pngs\uasd_4_l_farm_1_cropped.png');


subplot(4,2,2)
fuseLRj = imfuse(~shadowsLRj, im8LRj, 'blend');
imagesc(fuseLRj);
colormap('gray');
title('e) Radial joint, Linear Transducer')
[x y] = size(fuseLRj);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,2,4)
fuseLFa = imfuse(~shadowsLFa, im8LFa, 'blend');
imagesc(fuseLFa);
colormap('gray');
title('f) Forearm, Linear Transducer')
[x y] = size(fuseLFa);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,2,6)
fuseCR = imfuse(~shadowsCR, im8CR, 'blend');
imagesc(fuseCR);
colormap('gray');
title('g) Ribcage, Curvilinear Transducer')
[x y] = size(fuseCR);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

set(gcf,'color','white');

% Figure 2 Nakagami parameter maps

load('uasd_3_l_rjoint_1_nakParams.mat');
im2a = imread('pngs\uasd_3_l_rjoint_1_cropped.png');
numFrames = 1;
[rf, headerRF] = RPread(['uasd_3_l_rjoint_1', '.rf'], numFrames);

figure(2)

subplot(2,2,1)
imagesc(im2a)
[x y] = size(im2a);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('a) B-mode Image');
colormap(gca,'gray')


subplot(2,2,3)
imagesc(log10(abs(hilbert(rf))))
[x y] = size(abs(hilbert(rf)));
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('b) Log Scale of Echo Envelope');
colormap(gca,'gray')

subplot(2,2,2)
imagesc(imgaussfilt(log(omega),5));
colormap(gca,'jet')
hcb = colorbar;
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('c) Nakagami \omega Map');

subplot(2,2,4)
imagesc(imgaussfilt(log(mu),5));
colormap(gca,'jet')
hcb = colorbar;
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('d) Nakagami \mu Map');

set(gcf,'color','white');

