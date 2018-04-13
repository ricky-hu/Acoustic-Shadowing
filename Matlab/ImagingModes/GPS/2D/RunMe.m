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

%% reading sample B data (after scan conversion)
path = 'data\';
filename ='15-30-32.b8';        % b mode images
gpsfilename ='15-30-32.gps1';   % gps coordinates

n = 30;     % number of frames
[Bframes, header] = RPread( [path, filename], n); 
[GPSlocations, ~] = RPread( [path, gpsfilename], n); 

% displaying RF images
figure; colormap(gray);
for i = 1:n
    Bframe = Bframes(:,:,i)';   % currnet frame
    imagesc( Bframe );
    axis square; title('B image'); 
    ylabel('Samples'); xlabel('Scan Lines');
    title(['GPS Coordinates (X=', num2str(GPSlocations.gps_posx(i),4), ...
        ', Y=', num2str(GPSlocations.gps_posy(i),4),...
        ', Z=', num2str(GPSlocations.gps_posz(i),4),')' ]); 
    axis image;
    drawnow;
end
