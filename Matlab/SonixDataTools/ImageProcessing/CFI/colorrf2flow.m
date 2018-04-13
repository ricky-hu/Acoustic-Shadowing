% The following script reads RF signals acquired using in the color Doppler
% mode and estimated the flow velocity image and power Doppler image by
% processing the RF data.
%
% Copyright Ultrasonix Medical corporation
% Author: Reza Zahiri Azar - July 2010

% Turned into a function
% Copyright Ultrasonix Medical Corporation - Nov 2012
% Modified by: Ali Baghani
function [dataOut dataScale] = colorrf2flow(RF, hdr, outputType)
% close all
% clear all
% clc 

%%%%%%%%%%%%%% Reading Color RF data %%%%%%%%%%%%%%

% path = 'D:\PatientInfo\reza\09-07-2010-Generic\'; 
% fileName = 'CarotidFlow.crf';
% path = 'D:\Matlab Studies\ColorDoppler\Sample\';
% fileName = '15-10-51.crf';
% 
% [data, hdr] = RPread( [path, fileName] );

% reshape into a proper matrix
% frameN = 1; % frame of interest
% RF = reshape( squeeze(data(:,:,frameN)), [hdr.h, hdr.extra, hdr.w]);
RF = reshape( RF, [hdr.h, hdr.extra, hdr.w]);

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
win    = hamming(W)';   % windowing

%%%%%%%%%%%%%%%%%%% I/Q Demodulation %%%%%%%%%
% Sine and Cosine Table calculation
Ts = 1/Fs;      % sampling period
c  = 1540;      % speed of sound m/s
D  = W*c/(Fs*2);                % Depth of window [meter]
T  = D/(c/2);                   % Time of each window [second]
t  = 0:Ts:T; t = t(1:W);        % Time indixes for each window

SinDem = win.*sin(2*pi*(Fe)*t); % sine table
CosDem = win.*cos(2*pi*(Fe)*t); % cosine table

%%%%%%%%%%%%%% I/Q Demodulation %%%%%%%%%%%%%%%
I     = zeros(numOfLine, nW, ensemble);
Q     = zeros(numOfLine, nW, ensemble);
filtI = zeros(numOfLine, nW, ensemble);
filtQ = zeros(numOfLine, nW, ensemble);
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

% %%%%%%%%%% Display results %%%%%%%%%%%%%%%%%%%
% fntSz = 14;
% % Display B mode images from RF data
% figure; 
% colormap(gray);
% dumpAVI = false;
% 
% for rpt = 1:1
%     for i = 1 : ensemble
%         B = sqrt( abs( hilbert( squeeze( RF(:,i,:) ) ) ) );
%         imagesc( B , [0, 100]);
%         colorbar;
%         title( ['B-mode Acquisition #', num2str(i)] ,'fontsize',fntSz);
%         set(gca,'fontsize',fntSz)
%         axis off;
%         pause(0.05);
%         
%     end
% 
% end


% % Display RF data for one line
% figure; 
% linInd = 1;%floor( numOfLine/2 );
% plot( squeeze( RF(:,:,linInd) ) ); axis tight;
% legend('1st ensemble', '2nd ensemble', '3rd ensemble', '...')
% set(gca,'fontsize',fntSz)
% xlabel('RF Samples');
% ylabel('RF amplitude');

% Display estimated velocity image
% create the flow colormap
num = 256;
cmap = [makeMap([0 1 1], [0 0 1], num/4); makeMap([0 0 1], [0 0 0], num/4); makeMap([0 0 0], [1 0 0], num/4); makeMap([1 0 0], [1 1 0], num/4)];
velScal = PRF * c / (2 * Fe);


switch outputType
    case 1 % 'Velocity Wall Filtered'
        dataOut   = vel * velScal;
        dataScale = [-velScal, velScal];
    case 2 % 'Velocity Clutter'
        dataOut   = velC * velScal;
        dataScale = [-velScal, velScal]/10;
    case 3 % 'Thresholded Velocity'
        dataOut   = vel2 * velScal;
        dataScale = [-velScal, velScal];
        
    case 4 % 'Variance Wall Filtered'
        dataOut   = sig;
        dataScale = [0,1];
    case 5 % 'Variance Clutter'
        dataOut   = sigC;
        dataScale = [0,1]/2;
    case 6 % 'Thresholded Variance'
        dataOut   = sig2;
        dataScale = [0,1];
        
    case 7 %'Power Doppler Wall Filtered'
        dataOut   = pow;
        dataScale = [0, 120];
    case 8 % 'Power Doppler Clutter'
        dataOut   = powC;
        dataScale = [0, 120]*2;
    case 9 % 'Thresholded Power Doppler'
        dataOut   = pow2;
        dataScale = [0, 120];
        
end

% figure; set(gcf,'position',[74 559 1082 375]);
% subplot(1,3,2), imagesc( vel * velScal , [-velScal, velScal]);
% title('Velocity Wall Filtered [cm/s]','fontsize',fntSz)
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% subplot(1,3,1), imagesc( velC * velScal , [-velScal, velScal]/10 );
% title('Velocity Clutter [cm/s]','fontsize',fntSz)
% colormap(cmap);
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% subplot(1,3,3), imagesc( vel2 * velScal , [-velScal, velScal]);
% title('Thresholded Velocity [cm/s]','fontsize',fntSz)
% colormap(cmap);
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;

% % Display estimated variance image
% figure; set(gcf,'position',[74 559 1082 375]);
% subplot(1,3,2), imagesc(sig , [0,1]);
% title('Variance Wall Filtered','fontsize',fntSz)
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% subplot(1,3,1), imagesc(sigC, [0,1]/2);
% title('Variance Clutter','fontsize',fntSz)
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% subplot(1,3,3), imagesc(sig2);
% title('Thresholded Variance','fontsize',fntSz)
% colormap(hot);
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% 
% % Display estimated power Doppler image
% figure; set(gcf,'position',[74 559 1082 375]);
% subplot(1,3,2), imagesc(pow, [0, 120]);
% title('Power Doppler Wall Filtered [dB]','fontsize',fntSz)
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% subplot(1,3,1), imagesc(powC, [0, 120]*2);
% title('Power Doppler Clutter [dB]','fontsize',fntSz)
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;
% subplot(1,3,3), imagesc(pow2, [0, 120]);
% title('Thresholded Power Doppler [dB]','fontsize',fntSz)
% colormap(copper);
% colorbar;
% set(gca,'fontsize',fntSz)
% axis off;