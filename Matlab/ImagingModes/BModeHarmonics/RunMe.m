% The following script reads and displays the RF signals in the pulse 
% inversion harmonic mode acquired using Sonix ultrasound machine.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

% reading RF data
path = 'data\';
filename ='15-08-46.rf';

n = 1;     % number of frames
[RFframes, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
for i = 1:n
    RFframeH = RFframes(:,:,i);  % RF signals for pulse inversion harmoinc
    
    % do the accumulation for inverted pulses
    RFframe = RFframeH(:, 1:2:end) + RFframeH(:,2:2:end);

    subplot(2, 3, 1 );
    imagesc( RFframeH );
    axis square; title('Inverted RF signals'); ylabel('Samples');
    xlabel('Scan Lines');

    subplot(2, 3, 2 );
    imagesc( RFframe );
    axis square; title('Harmonic RF image'); ylabel('Samples');
    xlabel('Scan Lines');

    subplot(2, 3, 3 )
    imagesc( 20*log10( abs(hilbert(RFframe) ) ) , [30 90]); 
    title('Harmonic B image'); ylabel('Samples'); xlabel('Scan Lines');
    axis square;

    subplot(2, 1, 2 )
    lnInd = 130;    % line of interest
    plot( RFframe(100:end,lnInd)  ); 
    title('Harmonic RF line'); xlabel('Samples'); ylabel('Amplitude');
    axis tight;
end
