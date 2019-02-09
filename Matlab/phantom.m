%phantom images

imL = imread('phant2low_l_cropped.png');
imM = 1.5*imread('phant2med_l_cropped.png');
imH = 2*imread('phant2high_l_cropped.png');

shL = imread('phant2low_manual.png');
shM = imread('phant2med_manual.png');
shH = imread('phant2high_manual.png');

EL = imread('phant2low_entropy.png');
EM = imread('phant2med_entropy.png');
EH = imread('phant2high_entropy.png');

[x y] = size(imL);


figure();

subplot(3,3,1);
colormap('gray');
set(gcf,'color','white');
imagesc(imL);
title('a) Low Gain (25%), Original');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');


subplot(3,3,2);
imagesc(imM);
title('b) Medium Gain (50%), Original');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

subplot(3,3,3);
imagesc(imH);
title('c) High Gain (75%), Original');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

%fusing images)
imLF = imfuse(imL,shL,'blend');
imMF = imfuse(imM,shM,'blend');
imHF = imfuse(imH,shH,'blend');

subplot(3,3,4);
colormap('gray')
imagesc(imLF);
title('d) Low Gain (25%), RF');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

subplot(3,3,5);
colormap('gray')
imagesc(imMF);
title('e) Medium Gain (50%), RF');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

subplot(3,3,6);
colormap('gray')
imagesc(imHF);
title('f) High Gain (75%), RF');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

imLE = imfuse(imL,EL,'blend');
imME = imfuse(imL,EM,'blend');
imHE = imfuse(imL,~EH,'blend');

subplot(3,3,7);
colormap('gray')
imagesc(imLE);
title('g) Low Gain (25%), B-mode');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

subplot(3,3,8);
colormap('gray')
imagesc(imME);
title('h) Medium Gain (50%), B-mode');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

subplot(3,3,9);
colormap('gray')
imagesc(imHE);
title('i) High Gain (75%), B-mode');
set(gca,'XTickLabel', [{'0'} {'32'} {'64'} {'96'} {'128'}], 'XTick', [1 floor(y*.25) floor(y*.5) floor(y*.75) y]);
set(gca,'YTickLabel', [{'0.00'} {'1.25'} {'2.50'} {'3.75'} {'5.00'}], 'YTick', [1 floor(x*.25) floor(x*.5) floor(x*.75) x]);
ylabel('Depth (cm)');
xlabel('Scanline Number');

