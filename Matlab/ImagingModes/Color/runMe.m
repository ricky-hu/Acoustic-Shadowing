% The following script reads RF signals acquired using in the color Doppler
% mode and estimated the flow velocity image and power Doppler image by
% processing the RF data.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all
clear all
clc 

% add the path for the RP reader
addpath('..\common');

%%%%%%%%%%%%%% Reading Color RF data %%%%%%%%%%%%%%
path = 'data\';
fileName = 'CarotidFlow.crf';

n = 1; % number of frames
[data, hdr] = RPread( [path, fileName], n);

% reshape into a proper matrix
frameN = 1;     % frame of interest
RF = reshape( squeeze(data(:,:,frameN)), [hdr.h, hdr.extra, hdr.w]);

% data information
PRF= hdr.dr;            % pulse repetition frequency
Fe = hdr.txf;           % emition frequency MHz
Fs = hdr.sf;            % sampling frequency MHz
ensemble = hdr.extra;   % number of RF acquisition 
LineLength = hdr.h;     % RF Line length
numOfLine = hdr.w;      % number of scan lines

%%%%%%%% Signal Processing Parameters %%%%%%%%
W      = 20;            % window size of I/Q demodulation
deltaW = 10;            % window overlap
nW     = floor( (LineLength - W)/deltaW );     % number of windows
win    = hanning(W)';   % windowing
win    = win / sum(win);
% Sine and Cosine Table calculation
SinDem = win.*sin(2*pi*Fe/Fs*(1:W)); % sine table
CosDem = win.*cos(2*pi*Fe/Fs*(1:W)); % cosine table

%%%%%%%%%%%%%% I/Q Demodulation %%%%%%%%%%%%%%%
I     = zeros(numOfLine, nW, ensemble);
Q     = zeros(numOfLine, nW, ensemble);
filtI = zeros(numOfLine, nW, ensemble);
filtQ = zeros(numOfLine, nW, ensemble);

vel = zeros(nW, numOfLine);
pow = zeros(nW, numOfLine);
sig = zeros(nW, numOfLine);

velC = zeros(nW, numOfLine);
powC = zeros(nW, numOfLine);
sigC = zeros(nW, numOfLine);

for le = 1:numOfLine            % for each line
	for oe = 1:ensemble         % for each observation
        currentLine = RF(:,oe,le);   
        for j = 1: nW           % for each window
            % locate the current window
            currentWindow = currentLine(1 + (j-1)*deltaW : (j-1)*deltaW + W);
            % multiply with sine and cosine table to generate I/Q
            % Note: summation is used as a LPF, more complicated implementation 
            % can be used instead.
            Re = SinDem * currentWindow; 
            Im = CosDem * currentWindow;  
            
            I(le,j,oe) =  Re;
            Q(le,j,oe) = Im;
        end;
	end;
	
	%%%%%%%%%%%%%% wall filter %%%%%%%%%%%%%%%%%
    filterOrder = 2;            % order of the wall filter 
	Wn = 100/(PRF/2);           % 100 Hz high pass filter
	[B,A] = butter(filterOrder,Wn,'high');
    
    for j = 1: nW
        filtI(le,j,:) = filtfilt(B,A,I(le,j,:)); 
        filtQ(le,j,:) = filtfilt(B,A,Q(le,j,:)); 
    end;
	
	%%%%%%%%%%%%%% AutoCorrelation %%%%%%%%%%%%%
	for j = 1: nW
       
        % wall filtered I/Q data
        [velocity, sigma, power] = autoCorrelation( filtI(le,j,:), filtQ(le,j,:), ensemble );
        vel(j,le) = velocity;
        pow(j,le) = power;
        sig(j,le) = sigma;

        % unfiltered I/Q data (Clutter)
        [velocityC, sigmaC, powerC] = autoCorrelation( I(le,j,:), Q(le,j,:), ensemble );
        velC(j,le) = velocityC;
        powC(j,le) = powerC;
        sigC(j,le) = sigmaC;
        
	end;
end;

%%%%%%%%%%%%%%%% Post Processing %%%%%%%%%%%%
% filter the data based on the Threshold values defined in the function
[vel2, pow2, sig2] = filterColorImages(vel, pow, sig, velC, powC, sigC);

%%%%%%%%%% Display results %%%%%%%%%%%%%%%%%%%
fntSz = 12;
% create the flow colormap
num = 256;
cmap = [makeMap([0 1 1], [0 0 1], num/4); makeMap([0 0 1], [0 0 0], num/4); ...
    makeMap([0 0 0], [1 0 0], num/4); makeMap([1 0 0], [1 1 0], num/4)];
velScal = 100 * (PRF * 1540) / (2 * Fe) / 2;

% display estimated velocity
figure; 
subplot(1,2,1), imagesc( vel * velScal , [-velScal, velScal]);
title('Velocity [cm/s]','fontsize',fntSz)
colorbar;
set(gca,'fontsize',fntSz)
axis off; axis square;
subplot(1,2,2), imagesc( vel2 * velScal , [-velScal, velScal]);
title('Filtered Velocity [cm/s]','fontsize',fntSz)
colormap(cmap);
colorbar;
set(gca,'fontsize',fntSz)
axis off; axis square;

% display estimated variance
figure; 
subplot(1,2,1), imagesc(sig , [0,1]);
title('Variance Wall Filtered','fontsize',fntSz)
colorbar;
set(gca,'fontsize',fntSz)
axis off; axis square;
subplot(1,2,2), imagesc(sig2, [0,1]);
title('Filtered Variance','fontsize',fntSz)
colormap(hot);
colorbar;
set(gca,'fontsize',fntSz)
axis off; axis square;

% display estimated power
figure; 
subplot(1,2,1), imagesc(pow, [0, 70]);
title('Power Doppler Wall Filtered [dB]','fontsize',fntSz)
colorbar;
set(gca,'fontsize',fntSz)
axis off; axis square;
subplot(1,2,2), imagesc(pow2, [0, 70]);
title('Thresholded Power Doppler [dB]','fontsize',fntSz)
colormap(copper);
colorbar;
set(gca,'fontsize',fntSz)
axis off; axis square;
