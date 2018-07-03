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

% Applying low pass filter to image

thresh = 30;
[imRows, imCols] = size(im);

for col = 1:imCols
    for row = 1:imRows
        if (im(row,col) > thresh)
            im(row,col) = 0;
        end
    end
end

% Incresing pixel intensity by 1 such that logarithms can be taken
im = im + 1;

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
stdWeight = 1;
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

imagesc(shadows);

for col = 1:imCols
    rowMean = mean(ent(:,col));
    rowStd = std(ent(:,col));
    

end
    %looking for the point of highest entropy with low entropy afterward
    shdwIdx = 1;
    shdwEnt = 0;
    
    % Start looking at row n+1 as nth row is where sliding window fully
    % begins and the nth row is garabage data being the first entropy
    % calculation as it is high entropy
    for row = (n+1+shift):imRows
        if (ent(row,col) >= (shdwEnt - rowStd*stdWeight))
            shdwEnt = ent(row,col);
            shdwIdx = row;
        end
    end
    shadow(shdwIdx:end, col) = 0;
end

% % Obtaining manual outline of shadow region
% imshow(scan);
% 
% % This step prompts the user to highlight the region of interest
% manualShdw = roipoly;
% 
% % Note that MATLAB fills the outlined polygon with white, which is the
% % opposite of the shadowing algorithm (fills it with black), so the values
% % are flipped to compare
% 
% manualShdw = ~manualShdw;
% imwrite(manualShdw, 'manual.jpg');
% manualImg = imread('manual.jpg');
% 
% % Comparing the higlighted region to to shadow region
% tPos = 0;
% tNeg = 0;
% fPos = 0;
% fNeg = 0;
% totalElements = imCols*imRows;
% 
% % Marking comparisons between manual and detected shadow regions as either
% % true or false positives or negatives
% 
% for col = 1:imCols
%     for row = 1:imRows
%         if ((shadow(row,col) == 0 )&& (manualShdw(row,col) == 0))
%             tNeg = tNeg + 1;
%         elseif ((shadow(row,col) == 0 )&& (manualShdw(row,col) == 1))
%             fNeg = fNeg + 1;
%         elseif ((shadow(row,col) == 1 )&& (manualShdw(row,col) == 1))
%             tPos = tPos + 1;
%         elseif ((shadow(row,col) == 1 )&& (manualShdw(row,col) == 0))
%             fPos = fPos + 1;
%         end
%     end
% end
% 
% % Computing reliability and validity values
% sens = tPos / (tPos + fNeg);
% spec = tNeg / (tNeg + fPos);
% ppv = tPos / (tPos + fPos);
% npv = tNeg / (tNeg + fNeg);
% 
% fprintf('Sensitivity: %f \n', sens);
% fprintf('Specificity: %f \n', spec);
% fprintf('Positive Predictive Value: %f \n', ppv);
% fprintf('Negative Predictive Value: %f \n', npv);
% 

% Visualizing original image
subplot(1,4,1);
imshow(scan);
colormap(gca,'gray');
title('Original Ultrasound Image');
xlabel('Lateral Element');
ylabel('Axial Element');

% % Visualizing shadow regions
% subplot(1,3,2);
% imagesc(shadow);
% colormap(gca,'gray');
% hcb = colorbar;
% title(hcb,'Shadow Scale');
% title('Automated Shadow Detection');
% xlabel('Lateral Element');
% ylabel('Axial Element');
% 
% % Visualizing manual shadow region
% subplot(1,3,3);
% imagesc(manualImg);
% colormap(gca,'gray');
% hcb = colorbar;
% title(hcb,'Shadow Scale');
% title('Manual Shadow Detection');
% xlabel('Lateral Element');
% ylabel('Axial Element');
% 
% set(gcf,'color','w');

% Optional, intermediate heatmap
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
