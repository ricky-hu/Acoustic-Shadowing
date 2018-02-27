% boxWhiskerStats.m
% author:   Ricky Hu
% output:   Test figures and images using MATLAB's image processing toolbox

close all;
clf;
image = 'cropped_jpgs/armc.jpg';
im = imread(image);
% Applying high pass filter to image

thresh = 0;
[imRows, imCols] = size(im);

for col = 1:imCols
    for row = 1:imRows
        if (im(row,col) < thresh)
            im(row,col) = 0;
        end
    end
end

%---------------------------------
% FAST corner detection
figure()
corners = detectFASTFeatures(im,'MinContrast',0.01);
imFAST = insertMarker(im,corners,'circle');
imshow(imFAST);
title('FAST minimum contrast feature detection');

%--------------------
% minimum eigenvalue corner detection
figure()
corners = detectMinEigenFeatures(im,'MinQuality',0.01,'FilterSize', 3);
imEigen = insertMarker(im,corners,'circle');
imshow(imEigen);
title('Minimum eigenvalue feature detection');

%--------------------
% maxmimally stable extremal region detection
figure()
[regions, mserCC] = detectMSERFeatures(im, 'MaxAreaVariation', 0.5);
imshow(im); hold on;

% show all detected MSER regions
plot(regions,'showPixelList',true,'showEllipses',false);
title('MSER regions');

%--------------------
% edge detection
figure()
canny = edge(im,'canny');
imshowpair(im,canny,'montage');
title('Canny Detection');

%--------------------
% edge detection
% Marker-Controlled Watershed Segmentation
I = im;
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure
imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

L = watershed(gradmag);
Lrgb = label2rgb(L);
figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)')

se = strel('disk', 20);
Io = imopen(I, se);
figure
imshow(Io), title('Opening (Io)')

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
figure
imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);
figure
imshow(Ioc), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure
imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

fgm = imregionalmax(Iobrcbr);
figure
imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

I2 = I;
I2(fgm) = 255;
figure
imshow(I2), title('Regional maxima superimposed on original image (I2)')

se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
figure
imshow(I3)
title('Modified regional maxima superimposed on original image (fgm4)')

bw = imbinarize(Iobrcbr);
figure
imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure
imshow(bgm), title('Watershed ridge lines (bgm)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);

L = watershed(gradmag2);

I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure
imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')