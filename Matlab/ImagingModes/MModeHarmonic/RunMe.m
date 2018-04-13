% The following script reads and displays the pulse inverted haronic M mode 
% images acquired using Sonix ultrasound machine
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

%% reading sample M mode data (before scan conversion)
path = 'data\';
filename ='14-27-27.mpr';

n = 400;     % number of frames
[Mlines, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
imagesc( Mlines );
axis square; title('Harmonic M-mode'); 
ylabel('Samples'); xlabel('Acquisitions');

%% reading sample M mode data (after scan conversion)
path = 'data\';
filename ='14-27-27.m';

n = 400;     % number of frames
[Mlines, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
imagesc( Mlines' ); 
axis image; title('Harmonic M-mode (scan converted)'); 
ylabel('Samples'); xlabel('Acquisitions');

%% reading sample M mode RF data
path = 'data\';
filename ='14-27-27.mrf';

n = 400;     % number of frames
[Mlines, header] = RPread( [path, filename], n); 

% accumulate the inverted signals to ge the harmonic component
HMlines = sum( Mlines, 2 );

% displaying RF images
figure; colormap(gray);
imagesc( squeeze(HMlines) ); 
axis square; title('Harmonic RF lines'); 
ylabel('RF Samples'); xlabel('Acquisitions');
