% figure 1, shadow from radial joint and radius/ulna

cd 'C:\Users\rickyhu.stu\Desktop\Data\Raw\pngs'
im1a = imread('uasd_5_l_rjoint_1_cropped.png');
im1b = imread('uasd_8_c_farm_1_cropped.png');
figure(1);

subplot(1,2,1);
imagesc(im1a);
colormap(gca,'gray');
title('a) Radial Joint Scan, Linear Transducer');
xlabel('Scanline Number');
ylabel('Depth (cm)');
[x y] = size(im1a);
text(100,304,'Radial Joint','Color','r');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);

subplot(1,2,2);
imagesc(im1b);
colormap(gca,'gray');
title('b) Forearm Scan, Curvilinear Transducer');
xlabel('Scanline Number');
ylabel('Depth (cm)');
[x y] = size(im1b);
text(500,115,'Air Gap','Color','r');
text(175,326,'Ulna','Color','r');
text(350,326,'Radius','Color','r');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);

set(gcf,'color','white');

% figure 2, comparison of B-Mode to RF

% going to parent folder
cd ..
im2a = imread('pngs\uasd_10_l_farm_1_cropped.png');
% looking at RF data
patchSizeX = 5;
patchSizeY = 100;
[rf, headerRF] = RPread('uasd_10_l_farm_1.rf', 1);
window = [];
absHil = log10(abs(hilbert(rf)));
figure(2)

subplot(1,2,1);
imagesc(im2a);
colormap(gca,'gray');
title('a) Linear Forearm Scan, B-Mode');
xlabel('Scanline Number');
ylabel('Depth (cm)');
[x y] = size(im1a);
text(250,300,'Radius','Color','r');
text(75,300,'Ulna','Color','r');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);

[rows cols] = size(im2a);
absHilScaled = imresize(absHil, [rows cols]);
absHilScaled = absHilScaled;
subplot(1,2,2)
imagesc(absHilScaled);
colormap(gca,'gray');
title('a) RF Echo Envelope Image (Log Scale)');
patchSizeY = 40;
% labelling axis
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 64 128 192 256]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [5 716 716*2 716*3 716*4]);
text(250,300,'Radius','Color','r');
text(75,300,'Ulna','Color','r');
xlabel('Scanline Numer');
ylabel('Depth (cm)');

set(gcf,'color','white');

% Figure 3, patches of RF speckle
patchSizeX = 5;
patchSizeY = 100;
[rf, headerRF] = RPread('uasd_3_l_rjoint_1.rf', 1);
patchY = [612 2700];
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
subplot(1,3,1)
imagesc(log10(absHil));
colormap(gca,'gray');
title('a) RF Echo Envelope Image (Log Scale)');
patchSizeY = 40;
for i = 1:cols
    if i == 1
        text((patchX - floor(patchSizeX/2)) - 80 , (patchY(i) - floor(patchSizeY/2)-100), 'Non-Shadow');
            
        rectangle('Position', ...
        [(patchX - floor(patchSizeX/2)), (patchY(i) - floor(patchSizeY/2)), patchSizeX, patchSizeY],  ...
        'EdgeColor' , 'b', 'LineWidth', 1);
    else
        text((patchX - floor(patchSizeX/2)) - 50 , (patchY(i) - floor(patchSizeY/2)-100), 'Shadow');
        rectangle('Position', ...
        [(patchX - floor(patchSizeX/2)), (patchY(i) - floor(patchSizeY/2)), patchSizeX, patchSizeY],  ...
        'EdgeColor' , 'r', 'LineWidth', 1);
    end
end

% labelling axis
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 64 128 192 256]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [5 716 716*2 716*3 716*4]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

% Showing different statistical distirbution
subplot(1,3,2);
maxVal1 = max(max(window(:,:,1)));
[tempRow tempCol] = size(window(:,:,1));
sizeWindow1 = tempRow*tempCol;
histogram(window(:,:,1), 'Normalization', 'probability', 'binWidth', 80*maxVal1/sizeWindow1, 'FaceColor', 'b');

fitVals1 = 0:maxVal1/sizeWindow1:maxVal1;
nakaFit1 = fitdist(reshape(window(:,:,1),[],1), 'Nakagami');
gammaFit1 = fitdist(reshape(window(:,:,1),[],1), 'Gamma');
riciFit1 = fitdist(reshape(window(:,:,1),[],1), 'Rician');
raylFit1 = fitdist(reshape(window(:,:,1),[],1), 'Rayleigh');

mu(1) = nakaFit1.mu;
omega(1) = nakaFit1.omega;
a(1) = gammaFit1.a;
b(1) = gammaFit1.b;
s(1) = riciFit1.s;
sigma(1) = riciFit1.sigma;
theta(1) = raylFit1.B;

% creating plots from distributions
hold on
nakaPlot1 = pdf(nakaFit1, fitVals1);
gammaPlot1 = pdf(gammaFit1, fitVals1);
riciPlot1 = pdf(riciFit1, fitVals1);
raylPlot1 = pdf(raylFit1, fitVals1);

plot(fitVals1, nakaPlot1, '-b');
plot(fitVals1, gammaPlot1,'--c');
plot(fitVals1, riciPlot1, ':g');
plot(fitVals1, raylPlot1, '-.r');

xlabel('Echo Envelope of RF Data (Log Scale)');
ylabel('Probability');
legend('Non-Shadow Histogram', ...
    ['Nakagami Fit, \mu = ' num2str(round(mu(1),2)) ' \omega = ' num2str(round(omega(1),2))], ...
    ['Gamma Fit, a = ' num2str(round(a(1),2)) ' b = ' num2str(round(b(1),2))],...
    ['Rician Fit, s = ' num2str(round(s(1),2)) ' \sigma = ' num2str(round(sigma(1),2))], ...
    ['Rayleight Fit, \theta = ' num2str(round(theta(1),2))]);
title('b) Maximum Likelihood Fit of Non-Shadow Region');
grid minor;
hold off

% non-shadow region
subplot(1,3,3);
maxVal2 = max(max(window(:,:,2)));
[tempRow tempCol] = size(window(:,:,2));
sizeWindow2 = tempRow*tempCol;
histogram(window(:,:,2), 'Normalization', 'probability', 'binWidth', 80*maxVal2/sizeWindow2, 'FaceColor', 'b');

fitVals2 = 0:maxVal2/sizeWindow2:maxVal2;
nakaFit2 = fitdist(reshape(window(:,:,2),[],1), 'Nakagami');
gammaFit2 = fitdist(reshape(window(:,:,2),[],1), 'Gamma');
riciFit2 = fitdist(reshape(window(:,:,2),[],1), 'Rician');
raylFit2 = fitdist(reshape(window(:,:,2),[],1), 'Rayleigh');

mu(2) = nakaFit2.mu;
omega(2) = nakaFit2.omega;
a(2) = gammaFit2.a;
b(2) = gammaFit2.b;
s(2) = riciFit2.s;
sigma(2) = riciFit2.sigma;
theta(2) = raylFit2.B;

% creating plots from distributions
hold on
nakaPlot2 = pdf(nakaFit2, fitVals2)/2;
gammaPlot2 = pdf(gammaFit2, fitVals2)/2;
riciPlot2 = pdf(riciFit2, fitVals2)/2;
raylPlot2 = pdf(raylFit2, fitVals2);

plot(fitVals2, nakaPlot2, '-b');
plot(fitVals2, gammaPlot2,'--c');
plot(fitVals2, riciPlot2, ':g');
plot(fitVals2, raylPlot2, '-.r');

xlabel('Echo Envelope of RF Data (Log Scale)');
ylabel('Probability');
legend('Non-Shadow Histogram', ...
    ['Nakagami Fit, \mu = ' num2str(round(mu(2),2)) ' \omega = ' num2str(round(omega(2),2))], ...
    ['Gamma Fit, a = ' num2str(round(a(2),2)) ' b = ' num2str(round(b(2),2))],...
    ['Rician Fit, s = ' num2str(round(s(2),2)) ' \sigma = ' num2str(round(sigma(2),2))], ...
    ['Rayleight Fit, \theta = ' num2str(round(theta(2),2))]);
title('c) Maximum Likelihood Fit of Shadow Region');
grid minor;
hold off
set(gcf,'color','white');

% figure 4, RF processing steps

numFrames = 1;
[rf, headerRF] = RPread(['uasd_3_l_rjoint_1', '.rf'], numFrames);
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

figure(4)
subplot(2,2,1)
imagesc(rf);
hold on
colormap('gray');
[r, c] = size(rf);
line([colToPlot, colToPlot], [1, r], 'Color', [1, 0, 0]);
[x y] = size(rf);
text(28,1253,'Sample Scanline','Color','r');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('a) Raw RF Data');
hold off

subplot(2,2,2)
plot(rf(:,colToPlot),'.b');
[x y] = size(rf(:,colToPlot));
hold on
plot(abs(hilbert(rf(:,colToPlot))),'-r');
set(gca,'XTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'XTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
legend('RF Signal Valus of Scanline', 'Echo Envelope')
xlabel('Depth (cm)');
ylabel('RF Signal Value');
title('b) Sample Scanline RF Values');
hold off

subplot(2,2,3)
imagesc(abs(hilbert(rf)))
[x y] = size(abs(hilbert(rf)));
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('c) Echo Envelope of RF Data');
colormap('gray')

subplot(2,2,4)
imagesc(log(abs(hilbert(rf))))
[x y] = size(abs(hilbert(rf)));
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('d) Log Scale of Echo Envelope');
colormap('gray')

set(gcf,'color','white')

% figure 5, seeing nakagami parameters radial joint image

load('uasd_3_l_rjoint_1_nakParams.mat');

figure(5)

subplot(1,3,1)
imagesc(log10(abs(hilbert(rf))))
[x y] = size(abs(hilbert(rf)));
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('a) Log Scale of Echo Envelope');
colormap(gca,'gray')

subplot(1,3,2)
imagesc(imgaussfilt(log(omega),5));
colormap(gca,'jet')
hcb = colorbar;
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('b) Nakagami \omega Map');

subplot(1,3,3)
imagesc(imgaussfilt(log(mu),5));
hcb = colorbar;
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('c) Nakagami \mu Map');

set(gcf,'color','white');

% Figure 6, using code from makeNiceFigures.m, really bulky code here
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

figure(6)
subplot(2,2,1)
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
shadowsScaled(237:270,146:193) = 0;
set(r, 'AlphaData', (~shadowsScaled)/4);
title('A) Radial Joint, Linear Transducer')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');

subplot(2,2,2)
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
title('b) Forearm, Linear Transducer')
[x y] = size(imCropped);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

subplot(2,2,3)
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

subplot(2,2,4)
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
title('d) Forearm, Curvilinear Transducer')
[x y] = size(imCScaled);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');

set(gcf,'color','white');

% figure 7 tracking curvilinear paths

% this was more simply done by running the detectShadowsEntropy script
% rather than pasting everything here

% figure 9, looking closely at shadow region
im9a = imread('uasd_9_l_rjoint_1_cropped.png');

figure(9)
subplot(1,2,1)
imagesc(im9a)
colormap('gray');
[x y] = size(im9a);
rectangle('Position', [140, 160, 150, 100], 'EdgeColor' , 'r', 'LineWidth', 1);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('a) B-Mode image of Radial Joint');

subplot(1,2,2)
imagesc(im9a)
colormap('gray');
[x y] = size(im9a);
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.20'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
xlabel('Scanline Number');
ylabel('Depth (cm)');
title('b) Enlarged Shadow Boundary');
text(178,169,'Brightest Region','Color','r');
text(178,160,'Increasing Brightness','Color','r');
text(178,181,'Decreasing Brightness','Color','r');
text(178,228,'Deep Shadow','Color','r');

set(gcf,'color','white');
