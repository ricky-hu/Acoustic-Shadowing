% rfScratch.m
% scratchpad to view RF files

function rfScratch(fileName, numFrames)

% not sure why but the headers for the .rf files don't match Sonix's lookup
% table, so instead of using sonix's off the shelf RF reader I am doing it
% manually myself

fid= fopen(fileName, 'r');

if( fid == -1)
    error('Cannot open file');
end

% read the header info
hinfo = fread(fid, 19, 'int32');
header.filetype = hinfo(1);
header.nframes = hinfo(2);
header.w = hinfo(3);
header.h = hinfo(4);
header.ss = hinfo(5);
header.ul = [hinfo(6), hinfo(7)];
header.ur = [hinfo(8), hinfo(9)];
header.br = [hinfo(10), hinfo(11)];
header.bl = [hinfo(12), hinfo(13)];
header.probe = hinfo(14);
header.txf = hinfo(15);
header.sf = hinfo(16);
header.dr = hinfo(17);
header.ld = hinfo(18);
header.extra = hinfo(19);

rf(:,:) = fread(fid, [header.h, header.w], 'int16');

% comparing to BMode image
figure(1);

% stupid blackfill in images - need to get rid of this or somehow crop it out
% bmode = cropBModeL([num2str(fileName(1:end-3))  '_1.png']);

bmode = imread([num2str(fileName(1:end-3))  '_1.png']);

subplot(1,2,1);
imagesc(rf);
colormap(gca,'jet');
hcb = colorbar;

subplot(1,2,2);
image(bmode);

