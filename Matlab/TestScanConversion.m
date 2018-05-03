%% params
depth = 5e-2;
nBlocks = 100;
nLines = 200;
width = 0.0209;
Rt = 0.01;
Rm = -1.0;
% Rm = 1e-8;
dR = depth / nBlocks;
dT = width / nLines / Rt;
dP = 0.0;
dX = 0.2e-3;
nX = 519;
nY = 275;

for cntr = 1:5
    %% data to compare against
    fid = fopen(['ScanConvert-pre-0',num2str(cntr),'.bin']);
    preSC = fread(fid, nLines*nBlocks, 'float');
    preSC = reshape(preSC,[nBlocks,nLines]);
    fclose(fid);

    fid = fopen(['ScanConvert-post-0',num2str(cntr),'.bin']);
    postSC = fread(fid, nX*nY, 'float');
    postSC = reshape(postSC,[nY,nX]);
    fclose(fid);

    %% initialize
    sc = ScanConversion(Rt, Rm, dR, dT, dP, nBlocks, nLines, 1, dX, dX, 1);
%     sc.setClampMode(true);

    %% convert then revert
    scPost = sc.ScanConvert(preSC);
    scPre = sc.ScanRevert(scPost);

    %% compare to reference data
    figure;
    subplot(1,2,1);
    imagesc(scPost,[0 2]);
    axis image;
    title('SconConversion Post');
    subplot(1,2,2);
    imagesc(postSC,[0 2]);
    axis image;
    title('Reference Post');

    figure;
    subplot(1,2,1);
    imagesc(scPre,[0 2]);
    axis image;
    title('SconConversion Pre');
    subplot(1,2,2);
    imagesc(preSC,[0 2]);
    axis image;
    title('Reference Pre');
end