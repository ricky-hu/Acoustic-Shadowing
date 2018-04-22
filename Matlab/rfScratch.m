% rfScratch.m
% scratchpad to view RF files

function rfScratch(fileName, numFrames)

% not sure why but some of the headers for the .rf files don't match Sonix's lookup
% table, so instead of using sonix's off the shelf RF reader I am doing it
% manually myself
% 
% fid= fopen(fileName, 'r');
% 
% if( fid == -1)
%     error('Cannot open file');
% end
% 
% % read the header info
% hinfo = fread(fid, 19, 'int32');
% header.filetype = hinfo(1);
% header.nframes = hinfo(2);
% header.w = hinfo(3);
% header.h = hinfo(4);
% header.ss = hinfo(5);
% header.ul = [hinfo(6), hinfo(7)];
% header.ur = [hinfo(8), hinfo(9)];
% header.br = [hinfo(10), hinfo(11)];
% header.bl = [hinfo(12), hinfo(13)];
% header.probe = hinfo(14);
% header.txf = hinfo(15);
% header.sf = hinfo(16);
% header.dr = hinfo(17);
% header.ld = hinfo(18);bm
% header.extra = hinfo(19);

% rf(:,:,1) = fread(fid, [header.h, header.w], 'int16');

numFrames = 1;
[rf, headerRF] = RPread([fileName '.rf'], numFrames);
% comparing rf to bmode (hilbert transform) and manipulated bmode (log of
% hilbert transform)

figure(1);

f(1) = subplot(1,4,1);
imagesc(rf);
colormap(gca,'gray');
hcb = colorbar;
title('RF')

f(2) = subplot(1,4,2);
bmode = abs(hilbert(rf));
imagesc(bmode);
colormap(gca,'gray');
hcb = colorbar;
title('RF - Hilbert Transform')

f(3) = subplot(1,4,3);
bmode = log(bmode);
imagesc(bmode);
colormap(gca,'gray');
hcb = colorbar;
title('RF - Hilbert Transform (log scale)');

subplot(1,4,4);
bmodeProcessed = imread([fileName '_1.png']);
imagesc(bmodeProcessed);
colormap(gca,'gray');
title('B-Mode');

linkaxes(f, 'xy');
set(gcf,'color','white');

% investigating the log(hilbert(rf)) figure as it provides clear indication
% of shadow regions

manualShadow = outlineShadow(bmode);



