% The following script reads the DAQ data and displays them on the screen
%
% Copyright Ultrasonix Medical Corporation - April 2010 
% Author: Reza Zahiri Azar

close all
clear all
clc

% parameters
nCh = 128;              % number of channels
reRoute = true;         % true: transducer element (correct image), false: DAQ element
chanls = ones(1,nCh);   % what channels to read (DAQ element), for each channel set to 1 
                        % if you want to read the data 

% Folder path
path = 'D:\svn\repos\branches\daq\DAQCommon\2010.04.09 - 09.51.49AM';
if (path(end) ~= '\') path = [path,'\']; end
    
H = figure; 
for frameN = 2:1:5  % display first 5 frames
    % read the data
    [hdr, RF] = readDAQ(path, chanls, frameN , reRoute);
    % creat envelope image
    B = sqrt( abs( hilbert(RF) ) ) ;
    % display image
    imagesc( B );   % invert the map
    title(['Transmit #',num2str( frameN )]);
    axis square;
    xlabel('Channels')
    ylabel('Samples (Depth)')
    colormap(bone)
    drawnow
end

% plot channel data
figure;
N = 32;     % show first N channels
amp = 2000; % echo amplitude range
for i = 1:N
    subplot(N,1,i)
    plot( RF(:, i) );
    set(gca,'XTick',[]); set(gca,'YTick',[]); 
    axis([-inf inf -amp amp]);
    ylabel(num2str(i))
end
