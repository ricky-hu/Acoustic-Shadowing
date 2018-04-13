function bfData = beamform(pbfData, fulAprSz, probe)
% The following script take the pre-beamform data and creates beamfromed
% image.
% input:
%   preBeamformed: the first dimension is sample the second dimension
%   scan-line
%   fulAprSz : the receive aperture size to use for beamforming
% output:
%   out: beamformed rf data
%
% Author: Ali Baghani
% Copyright Ultrasonix Medical Corporation - 2014


upSampleRate = 3;
pbfData = resample(pbfData, upSampleRate, 1);

nSamples = size(pbfData, 1);
nLines   = size(pbfData, 2);

bfData = zeros(nSamples + 1, nLines);	

hlfAprSz = floor(fulAprSz / 2);
fulAprSz = hlfAprSz * 2 + 1;

channelSpacing = probe.pitch / 1000;    % milimeter
sampleSpacing  = 1540 / 40e6 / 2 / upSampleRate * 1e3; % milimeter
nSampleOffset  = -66 * upSampleRate;

paddedPBFData = zeros(nSamples + 1, nLines + fulAprSz); % The last row of zeros is for when the index goes out of bounds
paddedPBFData(1:end-1, hlfAprSz+1:hlfAprSz + nLines) = pbfData;

% calc delays based on depth
nSamplesMatrix = repmat((1:nSamples+1).', 1, fulAprSz);
distance2probe = nSamplesMatrix * 2 + nSampleOffset;
xMatrix = repmat((-hlfAprSz:hlfAprSz), nSamples + 1, 1);
ch2samp = channelSpacing / sampleSpacing;

probeRadius = probe.radius / 1000; % in milimeter
if  probeRadius == 0
    delaysMatrix = round(nSamplesMatrix + sqrt((xMatrix * ch2samp).^2 +  distance2probe.^2) - distance2probe);
else
    thetaMatrix = xMatrix * (channelSpacing / probeRadius);
    xMatrix1 = (probeRadius / sampleSpacing) * sin(thetaMatrix);
    yMatrix1 = (probeRadius / sampleSpacing) * (1.0 - cos(thetaMatrix));
    delaysMatrix = round(nSamplesMatrix + sqrt(xMatrix1.^2 +  (distance2probe + yMatrix1).^2) - distance2probe);
end   

withinBounds = (delaysMatrix <= nSamples);
delaysMatrix = withinBounds .* delaysMatrix + not(withinBounds) .* (nSamples + 1);

for i = (1:nLines)
    rawIndices   = delaysMatrix(:) +  (xMatrix(:) + i + hlfAprSz - 1) * (nSamples + 1);
    bfData(:, i) = sum(reshape(paddedPBFData(rawIndices), nSamples + 1, fulAprSz), 2) / fulAprSz;
end

bfData = resample(bfData(1:end-1, :), 1, 3);
