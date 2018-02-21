function patchStats = computePatchStats(image)

% loading the image

im = imread(image);
im = double(im);
[imRows, imCols] = size(im);

% defining the size of the patch, e.g. patchSpanX = 1 and patchSpan Y = 3
% would the center pixel, with only 1 adjacent pixel left and right and 3
% pixels top and bottom, totalling 3 x 7 = 21 pixels
patchSpanX = 5;
patchSpanY = 5;

% patchStats is the matrix with each element being a 
patchStats = [];

% iterating through image to compute statistics for each patch
for rowIdx = 1:imRows
    for colIdx = 1:imCols
        
        % defing the index boundaries of the patch
        xMin = rowIdx - patchSpanX;
        xMax = rowIdx + patchSpanX;
        yMin = colIdx - patchSpanY;
        yMax = colIdx + patchSpanY;
        
        % special conditions if the patch center is on an edge - in this
        % case, the patch will not extend past the boundaries of the
        % original image and will be a truncated patch
        if rowIdx <= patchSpanX
            xMin = 1;
        elseif rowIdx >= (imRows - patchSpanX)
            xMax = imRows;
        end
        
        if colIdx <= patchSpanY
            yMin = 1;
        elseif colIdx >= (imCols - patchSpanY)
            yMax = imCols;
        end
          
        patch = im(xMin:xMax, yMin:yMax);
        stats = computeStats(patch);
        
        % adding the vector of stats into a matrix corresponding to each
        % pixel of the image such 
        [statsRows, statsCols] =  size(stats);
        for i = 1:statsCols
            patchStats(rowIdx, colIdx, i) = stats(i);
        end
    end
end
       
% computing fft

% spectral = fft2(im);


% displaying Stats

figure(1)
imshow(image);
colormap(gca,'gray');
title('Original Ultrasound Image');
xlabel('Lateral Element');
ylabel('Axial Element');

figure(2)
imagesc(patchStats(:,:,1));
colormap(gca,'hot');
hcb = colorbar;
title(hcb,'Mean Intensity of Patch');
title('Mean Intensity Heatmap');
xlabel('Lateral Element');
ylabel('Axial Element');

figure(3)
imagesc(patchStats(:,:,2));
colormap(gca,'hot');
hcb = colorbar;
title(hcb,'Standard Deviation of Patch');
title('Standard Deviation Heatmap');
xlabel('Lateral Element');
ylabel('Axial Element');

figure(4)
imagesc(patchStats(:,:,3));
colormap(gca,'hot');
hcb = colorbar;
title(hcb,'Variance of Patch');
title('Variance Heatmap');
xlabel('Lateral Element');
ylabel('Axial Element');

figure(5)
imagesc(patchStats(:,:,4));
colormap(gca,'hot');
hcb = colorbar;
title(hcb,'Skewness of Patch');
title('Skewness Heatmap');
xlabel('Lateral Element');
ylabel('Axial Element');

figure(6)
imagesc(patchStats(:,:,5));
colormap(gca,'hot');
hcb = colorbar;
title(hcb,'Kurtosis of Patch');
title('Kurtosis Heatmap');
xlabel('Lateral Element');
ylabel('Axial Element');

% figure(7)
% imagesc(patchStats(:,:,4));
% colormap(gca,'hot');
% hcb = colorbar;
% title(hcb,'FFT of image');
% title('Kurtosis Heatmap');
% xlabel('Lateral Element');
% ylabel('Axial Element');