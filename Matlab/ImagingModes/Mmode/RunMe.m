% The following script reads and displays the M mode images acquired using
% Sonix ultrasound machine
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
filename ='14-28-18.mpr';

n = 400;     % number of frames
[Mlines, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
imagesc( Mlines );
axis square; title('M-mode'); 
ylabel('Samples'); xlabel('Acquisitions');

%% reading sample M mode data (after scan conversion)
path = 'data\';
filename ='14-28-18.m';

n = 400;     % number of frames
[Mlines, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
imagesc( Mlines' ); 
axis image; title('M-mode (scan converted)'); 
ylabel('Samples'); xlabel('Acquisitions');

%% reading sample M mode RF data
path = 'data\';
filename ='14-28-18.mrf';

n = 400;     % number of frames
[Mlines, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
imagesc( squeeze(Mlines) ); 
axis square; title('RF lines'); 
ylabel('RF Samples'); xlabel('Acquisitions');
