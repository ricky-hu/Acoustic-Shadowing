% patchScratch.m
% scratch work to visualize stats of patches of rf data

function patchesRaw = patchScratch(rf)

% defining test case regions
xSpan = 5;
ySpan = 10;
col = 156;
rowNon = 33;
rowBound = 1144;
rowShallow = 1383;
rowDeep = 2418;

patchesRaw = [];

% 3d matrix, each 3rd dimension index corresponds to a type of patch (non
% shadow, boundary, shallow shadow, deep shadow)
patchesRaw(:,:,1) = rf((rowNon - xSpan ):(rowNon + xSpan ), (col - ySpan ):(col + ySpan ));
patchesRaw(:,:,2) = rf((rowBound - xSpan ):(rowBound + xSpan ), (col - ySpan ):(col + ySpan ));
patchesRaw(:,:,3) = rf((rowShallow - xSpan ):(rowShallow + xSpan ), (col - ySpan ):(col + ySpan ));
patchesRaw(:,:,4) = rf((rowDeep - xSpan ):(rowDeep + xSpan ), (col - ySpan ):(col + ySpan ));


figure(3)
set(gcf,'color','white');
suptitle('RF distributions of different patches');

h(1) = subplot(1,4,1);
histogram(patchesRaw(:,:,1), 'BinWidth', 1, 'Normalization', 'probability');
xlabel('RF Value');
ylabel('Probability');
title('Non-shadow patch');

h(2) = subplot(1,4,2);
histogram(patchesRaw(:,:,2), 'Normalization', 'probability', 'binWidth', 1);
xlabel('RF Value');
ylabel('Probability');
title('Boundary Patch');

h(3) = subplot(1,4,3);
histogram(patchesRaw(:,:,3), 'Normalization', 'probability', 'binWidth', 1);
xlabel('RF Value');
ylabel('Probability');
title('Shallow Shadow Patch');

h(4) = subplot(1,4,4);
histogram(patchesRaw(:,:,4), 'Normalization', 'probability', 'binWidth', 1);
xlabel('RF Value');
ylabel('Probability');
title('Deep Shadow Patch');

linkaxes(h,'xy');

% looking at individual scanlines (averaged over patch) to see rayleigh distributions

patches = [];
tempPatches = [];
for i = 1:4
    % averaging across the columns of the patch
    for rowIdx = 1:(ySpan + 1)
        tempPatches(rowIdx,1,i) = mean(patchesRaw(rowIdx,:,i));
    end
    patches(:,1,i) = abs(hilbert(tempPatches(:,1,i)));
end

figure(4)
d(1) = subplot(1,4,1)

        

