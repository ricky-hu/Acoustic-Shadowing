%bmode=(log10(abs(hilbert(RFframe))));

[x y] = size(bmodeScaled);
numRFsamples = 1824 ;
RFSamplingRate = 15e6;
ss =size(bmodeScaled);
depth = 1540*numRFsamples/RFSamplingRate/2;
nBlocks = ss(1);
nLines = ss(2);
probeCrystalPitch = 0.47;
probeRadius =0.061;
probeWidth = probeCrystalPitch*ss(2)*1e-3;
width = probeWidth;
Rt = probeRadius;
Rm = -1.0;
% Rm = 1e-8;
dR = depth / nBlocks;
dT = width / nLines / Rt;
%dT = width / nLines;
dP = 0.0;
dX = 0.5e-3;
sc = ScanConversion(Rt, Rm, dR, dT, dP, nBlocks, nLines, 1, dX, dX, 1);
ph_sc = sc.ScanConvert(bmodeScaled);
figure(5);
imagesc(ph_sc);
colormap gray