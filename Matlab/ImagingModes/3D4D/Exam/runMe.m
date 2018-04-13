% The following script reads the 3D volume data acquired by the sonix 
% and visualizes it using texture mapping, surface rendering, and lighting.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\..\common');

%%%%%%%%%%%%%%%%%%%%%%% Reading volume Data %%%%%%%%%%%%%%%%%%
path = 'data\';
fileName = 'volume.3dv';
% openning the file
[vol, header] = RPread([path, fileName], 1);

%%%%%%%%%%%%%% 3D visualization using texture mapping %%%%%%%%%%%%%
figure;
set(gca, 'position', [0   0   1   1]);
vol3d('CData',vol,'texture','3D');
set(gca,'color','k'); set(gcf,'color','k');
axis image; axis vis3d; colormap(copper);
alphamap('decrease'); 
view(220,20);

% rotate the volume
step = 5;  % rotation step
for i=0:step:360
    camorbit(-step, 0);
    drawnow;
end

