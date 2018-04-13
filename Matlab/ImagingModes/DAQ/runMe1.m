% The following script reads channel data and generate B-mode image from it
% using beamforming, IQ demodulation, envelope detection, and log 
% compression.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Nov 2013

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

%%%%%%%%%%%%%%%%%%%%%%% Reading Channel Data %%%%%%%%%%%%%
% Case 1: reading from .rf or .daqrf data
% path = 'data\daqrf\';
% fileName = 'daqData.rf';
% n = 1;     % number of frames
% [CHframes,header] = RPread([path, fileName], n);

% Case 2: reading from data folder
d = 10;
for j=1:length(d)
      s = sprintf('C:\\Farah\\Ultrafast_Matlab_code\\oct24_data\\oct24\\200Hz_2V_4cm\\48\\');
    path = s;
    n =125;     % frame number
    % [CHframes, header] = DAQread(path, ones(1,128), n, true);

    %%%%%%%%%%%%%%%% Display Channel data %%%%%%%%%%%%%%%%%%%%
    figure; colormap(gray);

    for i = 1:n
        [CHframes, header] = DAQread(path, ones(1,128), i, true);
        CHframe(:,:,(j-1)*n+i) = CHframes(:,:);
%         RFframe(:,:,(j-1)*n+i) = parallelBeamformer(CHframe(:,:,(j-1)*n+i), 64, 40e6);
%         Bmode(:,:,(j-1)*n+i) = 20*log10( abs(hilbert(RFframe(:,:,(j-1)*n+i)) ) );
%          subplot(2, 2, 1 );
%      imagesc( 20*log10( abs(hilbert(CHframe(:,:,(j-1)*n+i)) ) ) , [0 90]); 
%     axis square; title('Channel image'); ylabel('Samples');
%     xlabel('Scan Lines');
% 
%     subplot(2, 2, 2 )
%     imagesc( 20*log10( abs(hilbert(RFframe(:,:,(j-1)*n+i)) ) ) , [0 90]); 
%     title('B image'); ylabel('Samples'); xlabel('Scan Lines');
%     axis square;
% % 
%     subplot(2, 1, 2 )
%     lnInd = size(CHframe(:,:,(j-1)*n+i),2) / 2;    % line of interest
%     plot( RFframe(:,lnInd,(j-1)*n+i )); 
%     title('Channel line'); xlabel('Samples'); ylabel('Amplitude');
%     axis tight;
%     i
%     drawnow;

    end
end
