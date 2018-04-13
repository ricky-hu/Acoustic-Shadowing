% The following script reads channel data and generate B-mode image from it
% using beamforming, IQ demodulation, envelope detection, and log 
% compression.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Nov 2013

% close all;
% clear all;
% clc;

% add the path for the RP reader
addpath('..\common');

%%%%%%%%%%%%%%%%%%%%%%% Reading Channel Data %%%%%%%%%%%%%
% Case 1: reading from .rf or .daqrf data
% path = 'data\daqrf\';
% fileName = 'daqData.rf';
% n = 1;     % number of frames
% [CHframes,header] = RPread([path, fileName], n);

% Case 2: reading from data folder
path = 'F:\ultrafast_elasticity_data\volt1_plane_wave_15_depth_6_file_13\1149\';
n = 10;     % frame number
% [CHframes, header] = DAQread(path, ones(1,128), n, true);

%%%%%%%%%%%%%%%% Display Channel data %%%%%%%%%%%%%%%%%%%%
figure; colormap(gray);
for i = 1:n
    [CHframes, header] = DAQread(path, ones(1,128), i, true);
    CHframe = CHframes(:,:,1);

    subplot(2, 2, 1 );
    imagesc( CHframe );
    axis square; title('Channel image'); ylabel('Samples');
    xlabel('Scan Lines');

    subplot(2, 2, 2 )
    imagesc( 20*log10( abs(hilbert(CHframe) ) ) , [0 90]); 
    title('B image'); ylabel('Samples'); xlabel('Scan Lines');
    axis square;

    subplot(2, 1, 2 )
    lnInd = size(CHframe,2) / 2;    % line of interest
    plot( CHframe(:,lnInd) ); 
    title('Channel line'); xlabel('Samples'); ylabel('Amplitude');
    axis tight;
    
    drawnow;
end

%%%%%%%%%%%%%%%%%%%% Apply Beamforming %%%%%%%%%%%%%%%%%
figure; colormap(gray);
for i = 1:n
    [CHframes, header] = DAQread(path, ones(1,128), i, true);
    CHframe = CHframes(:,:,1);
    % run parallel beamformer on channel data
    RFframe = parallelBeamformer(CHframe, 64, 40e6);

    subplot(2, 2, 1 );
    imagesc( RFframe );
    axis square; title('Channel image'); ylabel('Samples');
    xlabel('Scan Lines');

    subplot(2, 2, 2 )
    imagesc( 20*log10( abs(hilbert(RFframe) ) ) , [0 90]); 
    title('B image'); ylabel('Samples'); xlabel('Scan Lines');
    axis square;

    subplot(2, 1, 2 )
    lnInd = size(CHframe,2) / 2;    % line of interest
    plot( RFframe(:,lnInd) ); 
    title('Channel line'); xlabel('Samples'); ylabel('Amplitude');
    axis tight;
    
    drawnow;
end
