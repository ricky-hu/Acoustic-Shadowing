% The following script reads the elasto data and displays them on the screen
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

%% reading .epr data (non scan converted elastography iamges)
path = 'data\';
filename = '16-20-26.epr';

n = 10;     % number of frames to be read
[Im, header] = RPread([path,filename], n);

figure;
for i = 1:n
    frame = Im(:,:,i); imagesc(frame);
    title(['Frame ' num2str(i)]), pause(0.1)
    drawnow;
end

%% reading .elo data (scan converted elastography images)
path = 'data\';
filename = '16-20-26.elo';

n = 10;     % number of frames to be read
[Im, hdr] = RPread([path,filename], n);

figure;
for i = 1:n
    frame = Im(:,:,i); imagesc(frame');
    title(['Frame ' num2str(i)]), axis image;
    pause(0.1)
    drawnow;
end

%% reading .el data (scan converted, superimposed, and color coded images)
path = 'data\';
filename = '16-20-26.el';

n = 10;     % number of frames to be read
[Im, hdr] = RPread([path,filename], n);

figure;
for i = 1:n
    frame = squeeze( Im(:,:,i) )';
    % int to RGB
    RGBimg(:,:,1) = rem(bitshift(frame,-16), 256)/255 ;
    RGBimg(:,:,2) = rem(bitshift(frame, -8), 256)/255 ;
    RGBimg(:,:,3) = rem(bitshift(frame,  0), 256)/255 ;
    imshow(RGBimg),      
    title(['Frame ' num2str(i)])
    drawnow;
end


