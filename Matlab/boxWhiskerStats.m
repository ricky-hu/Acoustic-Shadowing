% boxWhiskerStats.m
% author:   Ricky Hu
% output:   a box and whisker plot of statistical parameters for different
%           regions
% input:    an nxnx3 matrix corresponding consisting of the following:
%           nxnx1: a matrix of 1 (no shadow) or 0 (shadow)
%           nxnx2: a matrix of 1 (not a shadow boundary) or 0 (within some)
%           pixels of a shadow boundary highlighted by user)
%           nxnx3: a matrix of 1 (not deep inside a shadow region) or 0
%           (deep within a shadow region)

function boxWhiskerStats(image)

clf;
image = 'cropped_jpgs/armc.jpg';


manualShdwMatrix = outlineShadow(image);

im = imread(image);

% Applying high pass filter to get rid of noise
thresh = 50;
[imRows, imCols] = size(im);

for col = 1:imCols
    for row = 1:imRows
        if (im(row,col) < thresh)
            im(row,col) = 0;
        end
    end
end


[rows,cols] = size(manualShdwMatrix(:,:,1));

% Obtaining the incides where a shadow, boundary, and deep shadow start and
% end
for colIdx = 1:cols
    allShdwIdxStart = find(manualShdwMatrix(:,colIdx,1) == 0, 1, 'first');
    boundaryShdwIdxStart = find(manualShdwMatrix(:,colIdx,2) == 0, 1, 'first');
    boundaryShdwIdxEnd = find(manualShdwMatrix(:,colIdx,2) == 0, 1, 'last');
    deepShdwIdxStart = find(manualShdwMatrix(:,colIdx,3) == 0, 1, 'first');

    % Obtaining stats for the subvector of different shadowing categories
    % in this column
    if(~(isnan(allShdwIdxStart)))
        nonShdwStats(:,colIdx) = computeStats(im(1:(allShdwIdxStart - 1),colIdx));
        allShdwStats(:,colIdx) = computeStats(im(allShdwIdxStart:end,colIdx));
    end
    
    if(~(isnan(boundaryShdwIdxStart))&& ~(isnan(boundaryShdwIdxEnd)))
        boundaryShdwStats(:,colIdx) = computeStats(im(boundaryShdwIdxStart:boundaryShdwIdxEnd,colIdx));
    end
            
    if(~(isnan(deepShdwIdxStart)))
        deepShdwStats(:,colIdx) = computeStats(im(deepShdwIdxStart:end,colIdx));
    end
end

% Displaying box whisker stats
figure(1)
boxplot([nonShdwStats(1,:)' allShdwStats(1,:)' boundaryShdwStats(1,:)' deepShdwStats(1,:)'], ...
    'Labels', {'Non-shadow regions', 'Shadow regions', 'Shadow boundary', 'Deep shadow regions'});
title('Mean intensity of different regions');
set(gcf,'color','white');

figure(2)
boxplot([nonShdwStats(2,:)' allShdwStats(2,:)' boundaryShdwStats(2,:)' deepShdwStats(2,:)'], ...
    'Labels', {'Non-shadow regions', 'Shadow regions', 'Shadow boundary', 'Deep shadow regions'});
title('Standard Deviation of different regions');
set(gcf,'color','white');

figure(3)
boxplot([nonShdwStats(3,:)' allShdwStats(3,:)' boundaryShdwStats(3,:)' deepShdwStats(3,:)'], ...
    'Labels', {'Non-shadow regions', 'Shadow regions', 'Shadow boundary', 'Deep shadow regions'});
title('Variance of different regions');
set(gcf,'color','white');

figure(4)
boxplot([nonShdwStats(4,:)' allShdwStats(4,:)' boundaryShdwStats(4,:)' deepShdwStats(4,:)'], ...
    'Labels', {'Non-shadow regions', 'Shadow regions', 'Shadow boundary', 'Deep shadow regions'});
title('Skewness of different regions');
set(gcf,'color','white');

figure(5)
boxplot([nonShdwStats(5,:)' allShdwStats(5,:)' boundaryShdwStats(5,:)' deepShdwStats(5,:)'], ...
    'Labels', {'Non-shadow regions', 'Shadow regions', 'Shadow boundary', 'Deep shadow regions'});
title('Kurtosis of different regions');
set(gcf,'color','white');

figure(6);
imshow(im);