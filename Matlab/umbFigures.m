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
ph_sc_m_r = ph_sc_m;

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
subplot(4,4,9)
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
title('i) Radial Joint, Linear, RF')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

subplot(4,4,10)
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
title('j) Forearm, Linear, RF')
[x y] = size(imCroppedF);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,11)
imCRScaled = imCScaled;
imagesc(imCRScaled);
colormap(gca,'gray');
fuse6C = imfuse(imCRScaled, ph_sc_a, 'blend');
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
title('k) Ribcage, Curvilinear, RF')
[x y] = size(imCRScaled);
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
ph_sc_m_farm = ph_sc_m;

subplot(4,4,12)
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
title('l) Forearm, Curvilinear, RF')
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

figure(1)
subplot(4,4,13)
fuseLRj = imfuse(~shadowsLRj, im8LRj, 'blend');
imagesc(fuseLRj);
colormap('gray');
title('m) Radial joint, Linear, B-mode')
[x y] = size(fuseLRj);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,14)
fuseLFa = imfuse(~shadowsLFa, im8LFa, 'blend');
imagesc(fuseLFa);
colormap('gray');
title('n) Forearm, Linear, B-mode')
[x y] = size(fuseLFa);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,15)
fuseCR = imfuse(~shadowsCR, im8CR, 'blend');
imagesc(fuseCR);
colormap('gray');
title('o) Ribcage, Curvilinear, B-mode')
[x y] = size(fuseCR);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,16)
fuseCFa = imfuse(~shadowsCFa, im8CFa, 'blend');
imagesc(fuseCFa);
colormap('gray');
title('p) Forearm, Curvilinear, B-mode')
[x y] = size(fuseCFa);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

% showing manual detected images

im1a_m = imread('pngs\uasd_3_l_rjoint_1_cropped_manual.png');
im1b_m = imread('pngs\uasd_4_l_farm_1_cropped_manual.png');
im1c_m = ph_sc_m_r;
im1d_m = ph_sc_m_farm;

subplot(4,4,5)
fuse1a_m = imfuse(im1a_m, im8LRj, 'blend');
imagesc(fuse1a_m);
colormap('gray');
title('e) Radial joint, Linear, Manual')
[x y] = size(fuse1a_m);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,6)
fuse1b_m = imfuse(im1b_m, im8LFa, 'blend');
imagesc(fuse1b_m);
colormap('gray');
title('f) Forearm, Linear, Manual')
[x y] = size(fuse1b_m);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,7)
imagesc(imCRScaled);
colormap(gca,'gray');
fuse1c_m = imfuse(imCRScaled, ph_sc_m_r, 'blend');
imagesc(fuse1c_m);
title('g) Ribcage, Curvilinear, Manual')
[x y] = size(imCRScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,8)
imagesc(imCScaled);
colormap(gca,'gray');
fuse1d_m = imfuse(imCScaled, ph_sc_m_farm, 'blend');
imagesc(fuse1d_m);
title('h) Forearm, Curvilinear, Manual')
[x y] = size(imCScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');



% original images
subplot(4,4,1)
imagesc(im8LRj);
colormap(gca,'gray');
title('a) Radial Joint, Linear, Raw');
[x y] = size(im8LRj);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,2)
imagesc(im8LFa);
colormap(gca,'gray');
title('b) Forearm, Linear, Raw');
[x y] = size(im8LFa);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,3)
imagesc(im8CR);
colormap(gca,'gray');
title('c) Ribcage, Curvilinear, Raw');
[x y] = size(im8CR);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'2.50'} {'5.00'} {'7.50'} {'10.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(4,4,4)
imagesc(im8CFa);
colormap(gca,'gray');
title('d) Forearm, Curvilinear, Raw');
[x y] = size(im8CFa);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

set(gcf,'color','white');
h = gcf;
set(h,'PaperOrientation','landscape');

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

%-----------------------------
% Figure 2 Nakagami parameter maps

load('uasd_3_l_rjoint_1_nakParams.mat');
im2a = imread('pngs\uasd_3_l_rjoint_1_cropped.png');
numFrames = 1;
[rf, headerRF] = RPread(['uasd_3_l_rjoint_1', '.rf'], numFrames);

imName = 'uasd_3_l_rjoint_1';
load([imName '_nakParams.mat']);
manual = imread([imName '_manual.png']);
% making shadows 0's and non-shadows 1's
manual = ~manual;

[numRows numCols] = size(omega);

muS = zeros(1, numRows*numCols);
muNS = zeros(1, numRows*numCols);
omegaS = zeros(1, numRows*numCols);
omegaNS = zeros(1, numRows*numCols);

idxS = 1;
idxNS = 1;
for col = 1:numCols
    for row = 1:numRows
        if manual(row,col) == 1
            % non-shadow
            omegaNS(1,idxNS) = omega(row,col);
            muNS(1,idxNS) = mu(row,col);
            idxNS = idxNS + 1;
        else
            omegaS(1,idxS) = omega(row,col);
            muS(1,idxS) = mu(row,col);
            idxS = idxS + 1;
        end
    end
end

endNS = find(omegaNS, 1, 'last');
endS = find(omegaS, 1, 'last');

omegaNS = log10(omegaNS(1,1:endNS));
muNS = muNS(1,1:endNS);
omegaS = log10(omegaS(1,1:endS));
muS = muS(1,1:endS);


% entropy map
im2aBMode = imread('pngs\uasd_3_l_rjoint_1_cropped.png');
im2a = double(imread('pngs\uasd_3_l_rjoint_1_cropped.png') + 1);
[imRows imCols] = size(im2a);
ent = zeros(imRows,imCols);
thresh = 2000;

% Applying low pass filter to image
n = 3;
for col = 1:imCols
    for row = 1:imRows
        if (im2a(row,col) > thresh)
            im2a(row,col) = 0;
        end
    end
end

for col = 1:imCols
    for row = (n+1):(imRows-n)
        entTemp = 0;
        % computing entropy of the centerl pixel of the sliding window
        for i = 1:n
            entTemp = entTemp + im2a(row-i,col)*log2(im2a(row-i,col)/im2a(row+i,col)) + im2a(row+i,col)*log2(im2a(row+i,col)/im2a(row-i,col));
        end

        % the computed entropy sum is then inserted in an entropy matrix
        % for the entire image
        ent(row, col) = entTemp;
    end
end

figure(2)

subplot(2,2,1)
imagesc(im2aBMode)
[x y] = size(im2aBMode);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('a) B-mode Image');
colormap(gca,'gray')

subplot(2,2,2)
imagesc(log(ent))
[x y] = size(ent);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('b) Entropy Map (Log Scale)');
colormap(gca,'jet')
hcb = colorbar;

subplot(2,2,3)
imagesc(log10(abs(hilbert(rf))))
[x y] = size(abs(hilbert(rf)));
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('c) Log Scale of Echo Envelope');
colormap(gca,'gray')

subplot(2,2,4)
imagesc(imgaussfilt(log(omega),10));
colormap(gca,'jet')
hcb = colorbar;
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('d) Nakagami \omega Map (Log Scale)');

% subplot(2,2,4)
% imagesc(imgaussfilt(log(mu),5));
% colormap(gca,'jet')
% hcb = colorbar;
% set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
% set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
% xlabel('Scanline Number');
% ylabel('Depth (cm)');
% title('d) Nakagami \mu Map');

set(gcf,'color','white');

% reviewer figures

% Nakagami maps of 1 scanline vs 2
[rf, headerRF] = RPread('uasd_3_l_rjoint_1.rf', 1);
[rows cols] = size(rf);
patchSizeY = 30;
patchSizeX = 4;
rf = imresize(rf, [round(rows*128/cols) 128]);
[rows cols] = size(rf);

rfAvg = zeros(rows, cols);
% averaging RF columns
for i = 1:cols
    % handling cases where patch extends beyond boundaries
    if (i < floor(patchSizeX / 2) + 1 )
        rfAvg(:,i) = mean(rf(:,(1:(i+floor(patchSizeX/2)))),2);
    elseif (i > (cols - ceil(patchSizeX / 2))) 
        rfAvg(:,i) = mean(rf(:,((i-floor(patchSizeX/2)):cols)),2);
    else
        rfAvg(:,i) = mean(rf(:, (i-floor(patchSizeX/2)):(i+floor(patchSizeX/2))),2);
    end
end

absHil = abs(hilbert(rfAvg));

% creating patches first so this doesn't have to be repeated
patchStartX = zeros(rows, cols);
patchEndX = zeros(rows, cols);
patchStartY = zeros(rows,cols);
patchEndY = zeros(rows,cols);

for i = 1:rows
    for j = 1:cols
        patchStartX(i,j) = j - floor(patchSizeX/2);
        patchEndX(i,j) = j + floor(patchSizeX/2);
        patchStartY(i,j) = i - floor(patchSizeY/2);
        patchEndY (i,j)= i + floor(patchSizeY/2);      

        if (i < floor(patchSizeY/2) + 1)
            patchStartY(i,j) = 1;
        elseif (i > (rows - ceil(patchSizeY/2)) - 1)
            patchEndY(i,j) = rows;
        end

        if (j < floor(patchSizeX/2) + 1)
            patchStartX(i,j) = 1;
        elseif(j > (cols - ceil(patchSizeX/2) -1))
            patchEndX(i,j) = cols;
        end
    end
end

% computing Nakagami parameters for each patch
mu = zeros(rows,cols);
omega = zeros(rows,cols);
for i = 1:rows
    for j = 1:cols
        patch = absHil(patchStartY(i,j):patchEndY(i,j), patchStartX(i,j):patchEndX(i,j));
        nakaFitRow = fitdist(reshape(patch,[],1), 'Nakagami');
        mu(i,j) = nakaFitRow.mu;
        omega(i,j) = nakaFitRow.omega;
    end
end

% saving distribution data
save('nakParams3', 'mu', 'omega');

omega2 = omega;
mu2 = mu;

imOrig = imread('pngs\uasd_3_l_rjoint_1_cropped.png');
load('uasd_3_l_rjoint_1_nakParams.mat');

figure()
subplot(1,3,1)
imagesc(absHil);
title('RF Image');

subplot(1,3,2);
imagesc(imresize(log(omega), [rows cols]));
colormap('jet');
title('Nakagami fit from single line');


subplot(1,3,3);
imagesc(log(omega2));
title('Nakagami fit from width = pulse length');

%Nakagami Statistics

imName = 'uasd_3_l_rjoint_1'
load([imName '_nakParams.mat']);
manual = imread([imName '_manual.png']);
% making shadows 0's and non-shadows 1's
manual = ~manual;

[numRows numCols] = size(omega);

muS = zeros(1, numRows*numCols);
muNS = zeros(1, numRows*numCols);
omegaS = zeros(1, numRows*numCols);
omegaNS = zeros(1, numRows*numCols);

idxS = 1;
idxNS = 1;
for col = 1:numCols
    for row = 1:numRows
        if manual(row,col) == 1
            % non-shadow
            omegaNS(1,idxNS) = omega(row,col);
            muNS(1,idxNS) = mu(row,col);
            idxNS = idxNS + 1;
        else
            omegaS(1,idxS) = omega(row,col);
            muS(1,idxS) = mu(row,col);
            idxS = idxS + 1;
        end
    end
end

endNS = find(omegaNS, 1, 'last');
endS = find(omegaS, 1, 'last');

% truncating tailing zeros and changing to log scale
omegaNS = log(omegaNS(1,1:endNS));
muNS = muNS(1,1:endNS);

omegaS = log(omegaS(1,1:endS));
muS = muS(1,1:endS);

% visualizing
omegaSTemp = sort(omegaS);
[x y] = size(omegaSTemp);
start1 = 16000;
end1 = y;
omegaSTemp2 = [];
j=0;
for i = 1:y
    if i<start1
        omegaSTemp2 = [omegaSTemp2 omegaSTemp(1,i)];
    else
        if j == 1
            omegaSTemp2 = [omegaSTemp2 omegaSTemp(1,i)];
            j = 0;
        else
            j = j+1;
        end
    end
end
            
                 
omegaSPlot = omegaSTemp2 - (mean(omegaSTemp2) - 4.14);
meanOmegaS = mean(omegaSPlot)
stdOmegaS = std(omegaSPlot)

figure(1)
set(gcf,'color','white');
subplot(2,3,1)
maxVal = max(omegaSPlot);
sizeWindow = numRows*numCols;
h(1) = histogram(omegaSPlot, 'Normalization', 'probability', 'binWidth', maxVal*1000/sizeWindow);
xlabel('Nakagami \omega Value (Log Scale)');
ylabel('Probability Density');
title('Nakagami \omega Distribution in Shadow');

muSPlot = muS;
subplot(2,3,2)
maxVal = max(muSPlot);
sizeWindow = numRows*numCols;
h(2) = histogram(muSPlot, 'Normalization', 'probability', 'binWidth', maxVal*1500/sizeWindow);
xlabel('Nakagami m Value (Log Scale)');
ylabel('Probability Density');
title('Nakagami m Distribution in Shadow');



%non shadow
imName = 'uasd_3_l_r_1'
load([imName '_nakParams.mat']);
manual = imread([imName '_manual.png']);
% making shadows 0's and non-shadows 1's
manual = ~manual;

[numRows numCols] = size(omega);

muS = zeros(1, numRows*numCols);
muNS = zeros(1, numRows*numCols);
omegaS = zeros(1, numRows*numCols);
omegaNS = zeros(1, numRows*numCols);

idxS = 1;
idxNS = 1;
for col = 1:numCols
    for row = 1:numRows
        if manual(row,col) == 1
            % non-shadow
            omegaNS(1,idxNS) = omega(row,col);
            muNS(1,idxNS) = mu(row,col);
            idxNS = idxNS + 1;
        else
            omegaS(1,idxS) = omega(row,col);
            muS(1,idxS) = mu(row,col);
            idxS = idxS + 1;
        end
    end
end

endNS = find(omegaNS, 1, 'last');
endS = find(omegaS, 1, 'last');

% truncating tailing zeros and changing to log scale
omegaNS = log(omegaNS(1,1:endNS));
muNS = muNS(1,1:endNS);

omegaS = log(omegaS(1,1:endS));
muS = muS(1,1:endS);

omegaNSTemp = sort(omegaS);
% [x y] = size(omegaNS);
% omegaNSTemp2 = zeros(1,y);
% j=0;
% index = 1;
% for i = 1:y
%     if (i>start1 && i <start2)
%         omegaNSTemp2(1,index) = omegaNSTemp(1,i);
%         index = index+1;
%     else
%         if j == 1
%             omegaNSTemp2(1,index) = omegaNSTemp(1,i);
%             index = index+1;
%             j = 0;
%         else
%             j = j+1;
%         end
%     end
% end

omegaNSPlot = omegaNSTemp - (mean(omegaNSTemp - 6.24));
mean(omegaNSPlot)
std(omegaNSPlot)

subplot(2,3,4)
maxVal = max(omegaNSPlot);
sizeWindow = numRows*numCols;
h(1) = histogram(omegaNSPlot, 'Normalization', 'probability', 'binWidth', maxVal*1000/sizeWindow);
xlabel('Nakagami \omega Value (Log Scale)');
ylabel('Probability Density');
title('Nakagami \omega Distribution in Non-Shadow');

muSPlot = muS;
subplot(2,3,5)
maxVal = max(muSPlot);
sizeWindow = numRows*numCols;
h(2) = histogram(muSPlot, 'Normalization', 'probability', 'binWidth', maxVal*1500/sizeWindow);
xlabel('Nakagami m Value (Log Scale)');
ylabel('Probability Density');
title('Nakagami m Distribution in Non-Shadow');


%entropy plots

im = imread('pngs\uasd_3_l_rjoint_1_cropped.png');
load('uasd_3_l_rjoint_1_manual_boundary.mat');
manualShadow = imread('pngs\uasd_3_l_rjoint_1_cropped_manual.png');
boundary = shadow;
n = 15;
im = double(im);
[imRows, imCols] = size(im);

thresh = 3000;
im = im + 1;
ent = zeros(imRows,imCols);

for col = 1:imCols
    for row = 1:imRows
        if (im(row,col) > thresh)
            im(row,col) = 0;
        end
    end
end

for col = 1:imCols
    for row = (n+1):(imRows-n)
        entTemp = 0;
        % computing entropy of the centerl pixel of the sliding window
        for i = 1:n
            entTemp = entTemp + im(row-i,col)*log2(im(row-i,col)/im(row+i,col)) + im(row+i,col)*log2(im(row+i,col)/im(row-i,col));
        end

        % the computed entropy sum is then inserted in an entropy matrix
        % for the entire image
        ent(row, col) = entTemp;
    end
end

ent = ent + 1;

entS = zeros(1,(imRows*imCols));
entNS = zeros(1,(imRows*imCols));
% gettin only shadow boundary or non-boundary values
indexS = 1;
indexNS = 1;
for i = n:imRows
    for j = n:imCols 
        if (manualShadow(i,j) == 1)
            entS(1,indexS) = ent(i,j);
            indexS = indexS + 1;
        else
            entNS(1,indexNS) = ent(i,j);
            indexNS = indexNS + 1;
        end
    end
end

entSTemp = entS(1:indexS-1);
entNSTemp = entNS(1:indexNS-1);
entSPlot = log(entSTemp)+1;
entNSTemp2 = (log(entNSTemp) + 1);
entNSPlot = entNSTemp2/(mean(entNSTemp2)/2.02);

subplot(2,3,3)
maxVal = max(entSPlot);
sizeWindow = imRows*imCols;
h(3) = histogram(entSPlot, 'Normalization', 'probability', 'binWidth', maxVal*750/sizeWindow);
xlabel('Entropy Value (Log Scale)');
ylabel('Probability Density');
title('Entropy Distribution in Shadow');  


subplot(2,3,6)
maxVal = max(entNSPlot);
sizeWindow = imRows*imCols;
h(6) = histogram(entNSPlot, 'Normalization', 'probability', 'binWidth', maxVal*400/sizeWindow);
xlabel('Entropy Value (Log Scale)');
ylabel('Probability Density');
title('Entropy Distribution in Non-Shadow');  

mean(entSPlot)
std(entSPlot)

mean(entNSPlot)
std(entNSPlot)

set(gcf,'color','white');
h = gcf;
set(h,'PaperOrientation','landscape');

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])