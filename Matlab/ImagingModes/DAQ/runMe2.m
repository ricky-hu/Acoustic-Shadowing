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
d = 12;
for j=1:length(d)
%     s = sprintf('F:\\ultrafast_elasticity_data\\volt1_plane_wave_5_depth_4_file_8_no_steer_degee_2\\%d\\',d(j));
 s = sprintf('F:\\Oct_11_plane_wave\\daqrt\\exc_on_phantom_amp_2_no_rf\\%d\\',d);

    path = s;
    n = 125;     % frame number
    % [CHframes, header] = DAQread(path, ones(1,128), n, true);

    %%%%%%%%%%%%%%%% Display Channel data %%%%%%%%%%%%%%%%%%%%
    figure; colormap(gray);

    for i = 1:n
        [CHframes, header] = DAQread(path, ones(1,128), i, true);
        CHframe(:,:,i) = CHframes(:,:);
        if mod(i,5)==0
                RFframe(:,:,round(i/5)) = spatial_compound_parallelBeamformer_main(CHframe(:,:,i-4:(i)), 64, 40e6,2);
                Bmode(:,:,round(i/5)) = 20*log10( abs(hilbert(RFframe(:,:,round(i/5))) ) );
                 subplot(2, 2, 1 );
             imagesc( 20*log10( abs(hilbert(CHframe(:,:,round(i/5))) ) ) , [0 90]); 
            axis square; title('Channel image'); ylabel('Samples');
            xlabel('Scan Lines');

            subplot(2, 2, 2 )
            imagesc( 20*log10( abs(hilbert(RFframe(:,:,round(i/5))) ) ) , [0 90]); 
            title('B image'); ylabel('Samples'); xlabel('Scan Lines');
            axis square;

            subplot(2, 1, 2 )
            lnInd = size(CHframe(:,:,round(i/5)),2) / 2;    % line of interest
            plot( RFframe(:,lnInd,round(i/5) )); 
            title('Channel line'); xlabel('Samples'); ylabel('Amplitude');
            axis tight;

            drawnow;
        end

    end
end
