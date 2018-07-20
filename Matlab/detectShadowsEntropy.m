% Function to read an image and highlight the shadows of B-Mode image using
% entropy
% Input: im - name of the B-Mode image
% Output: shadows - matrix of shadow (0) and non-shadow (1) regions
% Author: Ricky Hu
% Last Updated: 3-Jul-2018

function shadows = detectShadowsEntropy(imName)


% moving entropy window set to 1 - only looks at adjacent pixels
n = 15;
im = imread(imName);
im = double(im);
[imRows, imCols] = size(im);

% Applying low pass filter to image

thresh = 30;


for col = 1:imCols
    for row = 1:imRows
        if (im(row,col) > thresh)
            im(row,col) = 0;
        end
    end
end

% Incresing pixel intensity by 1 such that logarithms can be taken
im = im + 1;

% two cases - linear (easy, just look down vertical scanlines) and
% curvilinear (trapezoidal mask required to interpolate scanlines)

% linear case
if contains(imName, '_l_')
    % Computing intensity statistics down each line of the image
    ent = zeros(imRows,imCols);
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

    imagesc(ent);

    % Identifying shadow regions using otsu's method to look down scanline
    shadows = zeros(imRows,imCols);
    shift = 30;

    for col = 1:imCols
        % looking at otsu's threshold at the scanline (doesn't make sense to do
        % entire image as entropy is relative to individual scanlines)
        otsuThresh = multithresh(ent(:,col));

        % Start looking at row n+1 as nth row is where sliding window fully
        % begins and the nth row is garabage data being the first entropy
        % calculation as it is high entropy
        for row = (n+1+shift):imRows
            % if the entropy is greater than the threshold, that means that
            % this is a bright region and pixels before this region was not a
            % shadow
            if (ent(row,col) > otsuThresh)
                shadows(1:row,col) = 1;
            end
        end
    end

elseif contains(imName, '_c_r_')
    % looking for the "top corners" of the US image to build trapezoid
    % strategy is to capture the side "slopes" of the ringdo
    
    % looking for first image pixel
    slopeRowStart = 0;
    for row = 1:imRows
        % check if there are at least two nonzero elements (two corners)
        if (nnz(im(row,:)) > 1)
            % find first and last nonzero element to build left and right
            % slopes
            left(row) = find(im(row,:), 1, 'first');
            right(row) = find(im(row,:), 1, 'last');
            
            % keeping track of the row number where image begins
            if (slopeRowStart == 0)
                slopeRowStart = row;
            end
        end
    end
    
    slopeColStart = left(1);
    % looking at the left slope, we traverse down the ringdown pixels and
    % extrapolate downwards to find the slope
    
    % the ringdown pixels end when the descent no longer follows a linear
    % path
    minCol = imCols;
    for row = 1:imRows
        if left(row) <= minCol
            minCol = left(row);
        else
            % we've reached the end of the ringdown region
            slopeRowEnd = row - 1;
            slopeColEnd = left(row - 1); 
            break;
        end
    end
    
    % with the start/stop elements for the left edge, we can compute the
    % slope
    
    dCol = slopeColEnd - slopeColStart;
    dRow = slopeRowEnd - slopeRowStart;
    
    % now we can create a path for this slope
    segmentRowEnd = 1;
    segmentColEnd = 1;
    for i = 1:imRows
        if segmentRowEnd <= imRows && segmentRowEnd >= 1 && segmentColEnd <= imCols && segmentColEnd >= 1
            segmentRowEnd = slopeRowStart + dRow*i;
            segmentColEnd = slopeColStart + dCol*i;
        else
            segmentRowEnd = slopeRowStart + dRow*(i-2);
            segmentColEnd = slopeColStart + dCol*(i-2);
            break;
        end
    end
    
    % can create the line segment defining the scanline path
    
    scanlineY = [slopeRowStart segmentRowEnd];
    scanlineX = [slopeColStart segmentColEnd];
        
    % finding last element and where the middle scaneline is
    % note that these columns are for the first imaging row
    lastScanlineCol = right(1);
    midScanlineCol = ceil((right(1)+left(1))/2);
    
    % the number of columns between has +1 because we are including the
    % edges
    colsBetween = right(1) - left(1) + 1;
    
    % building the array of slopes, note that dRow stays the same, just
    % dCol changes
    slopes = [];
    
    % we know the middle scanline has slope of 0 so we can interpolate the
    % slopes between the left edge and right edge
    % we also know that the rightmost scanline has its slope symmetrically
    % reflected across the axis of the middle scanline
    
    % factor of 2 is because the slopes are distributed between dCol
    % (negative) and -dCol (positive)
    % subtracting 1 from colsBetween to take into account the 0 slope
    % element
    dSlopeCol = -(2*dCol/(colsBetween-1));
    for k = 1:colsBetween
        slopes(k) = dCol + (k-1)*dSlopeCol;
    end
    
    [garbageVar numLines] = size(slopes);
    
    % now we want to find the first row for where imaging starts so we can
    % avoid the blackfill regions
    
    for col = left(1):right(1)
        for row = 1:imRows
            if im(row,col) ~= 0
                % indexing is because we want rowStart to start indexing at
                % 1, not at left(1)
                rowStart(col-left(1)+1) = row;
                break;
            end
        end
    end
                
    % pathRowStart is the row index where the scanlines start
    % pathColStart is an array of column indexes for the scanlines
    pathRowStart = rowStart;
    pathColStart = left(1):1:right(1);
    
    % creating two vectors, one for the coordinates where scanline starts
    % and one for where it ends

    scanlineRowStart = [];
    scanlineColStart = [];
    
    scanlineRowEnd = [];
    scanlineColEnd = [];
    
    for i = 1:numLines
        
        % creating paths from the slopes and the starting element
        scanlineRowStart(i) = pathRowStart(i);
        scanlineColStart(i) = pathColStart(i);
        
        % now we need to traverse down the slope to find the last element
        % where this scanline ends
        scanlineRowEnd(i) = 1;
        scanlineColEnd(i) = 1; 
        for j = 1:imRows
            if scanlineRowEnd(i) <= imRows && scanlineRowEnd(i) >= 1 && scanlineColEnd(i) <= imCols && scanlineColEnd(i) >= 1
                scanlineRowEnd(i) = scanlineRowStart(i) + dRow*j;
                scanlineColEnd(i) = scanlineColStart(i) + slopes(i)*j;
            else
                scanlineRowEnd(i) = scanlineRowStart(i) + dRow*(j-2);
                scanlineColEnd(i) = scanlineColStart(i) + slopes(i)*(j-2);
                break;
            end
        end
    end

    % visualizing
    figure(1)
    imagesc(im);
    colormap('gray');
    hold on;
    % plot(scanlineX,scanlineY,'-r');
    
    % only plotting every 5 indices for visibility
    i = 1;
    while i <= numLines
        plot([scanlineColStart(i) scanlineColEnd(i)], [scanlineRowStart(i) scanlineRowEnd(i)],  '-r');
        i = i+5;
    end
    hold off;
    
    % building the matrix of scanlines for entropy analysis
    scanlineMatrix = zeros(imRows,numLines,2);
    
    for i = 1:numLines
        segmentX = [scanlineColStart(i) scanlineColEnd(i)];
        segmentY = [scanlineRowStart(i) scanlineRowEnd(i)];
    
        % profile(1,:) are the columns (y coordinates), profile(2,:) are the
        % rows (x coordinates) 

        [yCoords xCoords intensities] = improfile(im,segmentX,segmentY);
        
        % now we build a nxnx2 matrix such that the columns contain the
        % coordinates of the scanline
        % we can then traverse down the column as if we are traverse down a
        % straight scanline and perform entropy analysis
        
        % needs padding of the array
        scanlineMatrix(:,i,1) = xCoords;
        scanlineMatrix(:,i,2) = yCoords;
    end
    
end






% Visualizing original image
subplot(1,4,1);
imshow(scan);
colormap(gca,'gray');
title('Original Ultrasound Image');
xlabel('Lateral Element');
ylabel('Axial Element');


subplot(1,4,3);
imagesc(ent);
colormap(gca,'hot');
hcb = colorbar;
title(hcb,'Entropy Value');
title('Entropy Heatmap');
xlabel('Lateral Element');
ylabel('Axial Element');

% Optional, intermediate low pass filter
subplot(1,4,2);
image(im);
colormap(gca,'gray')
title('Low-Pass Filtered Image');
xlabel('Lateral Element');
ylabel('Axial Element');

% Visualizing shadow regions
subplot(1,4,4);
imagesc(shadow);
colormap(gca,'gray');
hcb = colorbar;
title(hcb,'Shadow Scale');
title('Automated Shadow Detection');
xlabel('Lateral Element');
ylabel('Axial Element');

set(gcf,'color','w');
