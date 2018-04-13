% The following script reads the 3D volume data acquired by Propello SDK
% and visualizes it in Matlab.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all
clear all
clc

% add the path for the RP reader
addpath('..\..\common');

%% Example to read B data
path = 'data\';
filename = 'B.vol';

% loads the volume information and header data from the file
[vol, hdr] = PropelloRead([path, filename]);

% display images
figure; colormap(gray); 
for i = 1:hdr.fpV
    imagesc( squeeze( vol(:,:,i) )' )
    title(['Frame # ',num2str(i)]),
    caxis([0 255]), axis square
    drawnow;            
end;

%% Example to read CFM data (Velocity and Variance)
clear all

path = 'data\';
filename = 'C.vol';

% loads the volume information and header data from the file
[vol, hdr] = PropelloRead([path, filename]);

% make color map
num = 256;
cmap = [makeMap([0 1 1], [0 0 1], num/4); makeMap([0 0 1], [0 0 0], num/4); ...
    makeMap([0 0 0], [1 0 0], num/4); makeMap([1 0 0], [1 1 0], num/4)];

% display images
figure; colormap(cmap); 
for i = 1:2:hdr.fpV
    subplot(1,2,1), subimage( squeeze( vol(:,:,i) )', jet )
    title(['Variance (Frame# ',num2str(i),')']),
    caxis([0 255]), axis square,
    
    subplot(1,2,2), subimage( squeeze( vol(:,:,i+1) )', cmap )
    title(['Velocity (Frame# ',num2str(i),')']),
    caxis([0 255]), axis square,
    
    drawnow;            
end;

%% Example to read scan converted CFM images superimposed on B images
clear all

path = 'data\';
filename = 'BC.vol';

% loads the volume information and header data from the file
[vol, hdr] = PropelloRead([path, filename]);

% display images
figure; colormap(gray); 
for i = 1:hdr.fpV
    frame = squeeze( vol(:,:,i) )';
    % extract RGB
    RBGimg(:,:,1) = rem(bitshift(frame,-16), 256)/255 ;
    RBGimg(:,:,2) = rem(bitshift(frame, -8), 256)/255 ;
    RBGimg(:,:,3) = rem(bitshift(frame,  0), 256)/255 ;
    imshow(RBGimg)     
    title(['Frame # ',num2str(i)]),
    drawnow;            
end;