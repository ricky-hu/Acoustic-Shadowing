% The following script reads and displays the B mode images acquired using
% Sonix ultrasound machine
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

%% reading sample B data (before scan conversion)
path = 'data\';
filename ='16-16-56.bpr';

n = 20;     % number of frames
[Bframes, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
for i = 1:n
    Bframe = Bframes(:,:,i);   % currnet frame
    imagesc( Bframe );
    axis square; title('B image'); 
    ylabel('Samples'); xlabel('Scan Lines');
    title(['Frame ',num2str(i)]);
    drawnow;
end

%% reading sample B data (after scan conversion)
path = 'data\';
filename ='16-16-56.b8';

n = 20;     % number of frames
[Bframes, header] = RPread( [path, filename], n); 

% displaying RF images
figure; colormap(gray);
for i = 1:n
    Bframe = Bframes(:,:,i)';   % currnet frame
    imagesc( Bframe );
    axis square; title('B image'); 
    ylabel('Samples'); xlabel('Scan Lines');
    title(['Frame ',num2str(i)]); axis image;
    drawnow;
end
