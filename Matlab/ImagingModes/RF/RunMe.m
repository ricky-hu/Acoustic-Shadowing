% The following script reads and displays the RF signals acquired using
% Sonix ultrasound machine
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
filename ='rf.rf';

n = 1;     % number of frames
[RFframes, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
for i = 1:n
    RFframe = RFframes(:,:,i);

    subplot(2, 2, 1 );
    imagesc( RFframe );
    axis square; title('RF image'); ylabel('Samples');
    xlabel('Scan Lines');

    subplot(2, 2, 2 )
    imagesc( 20*log10( abs(hilbert(RFframe) ) ) , [20 90]); 
    title('B image'); ylabel('Samples'); xlabel('Scan Lines');
    axis square;

    subplot(2, 1, 2 )
    lnInd = 130;    % line of interest
    plot( RFframe(:,lnInd)  ); 
    title('RF line'); xlabel('Samples'); ylabel('Amplitude');
    axis tight;
end
