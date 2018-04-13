% The following script (1) reads the RF data in PW mode, (2) generates the
% IQ signal, (3) applies the wall filter to the IQ signals, and (4)
% generates the spectrum from the wall filtered data.
%
% Copyright Ultrasonix Medical Corporation - May 2009
% Author: Reza Zahiri Azar

% Turned into a function
% Copyright Ultrasonix Medical Corporation - Nov 2012
% Modified by: Ali Baghani
function [Iout Qout spec] = dopplerrf2spectrum(PWRF, header, WF)
% close all;
% clear all;
% clc;

%%%%%%%%%%%%%%%%%%%%%%% Reading RF Signals %%%%%%%%%%%%%%
% path = '\\dataserver\storage\Shared\jessie\pwRF\';%'D:\PatientInfo\reza\05-17-2010-Generic\';
% filename = '18-24-51.drf';%'11-50-54.drf';

% frameN = 10000; % number of frames to be read
% upSamp = 1;     % upsampling factor for the rf data
PWRF   = PWRF';
frameN = size(PWRF, 1);
% [header, PWRF] = readPWframe( path, filename, frameN, upSamp);

% figure;
% plot(PWRF(1:50,:)');
% axis tight
% title('RF Lines');
% xlabel('Samples');
% ylabel('Amplitude');

%%%%%%%%%%%%%%%%%%%%%%% Quadrature I/Q Demodulation %%%%%%%%%%%%%%

PRF     = header.dr;         % pulse repetition frequency
Fe      = header.txf;       % TX frequency MHz
Fs      = header.sf;   % Sampling frequency MHz
Gate    = header.h;            % Gate size

% Windowing 
win     = hamming(Gate)';

% Demodulation Signals 
t  = [1:Gate]/Fs; 
SinDem = win.*sin(2*pi*(Fe)*t);
CosDem = win.*cos(2*pi*(Fe)*t);

% Quadrature Detector 
% for fe = 1:frameN           
%     I(fe) = SinDem * PWRF(fe,:)';   % sum of product to remove high frequencies as well
%     Q(fe) = CosDem * PWRF(fe,:)';
% end;
I = SinDem * PWRF';
Q = CosDem * PWRF';
% 
% figure;
% plot(1000*[1:frameN]/PRF,I,1000*[1:frameN]/PRF,Q); 
% legend('I','Q');
% xlabel('Time (miliseconds)');

%%%%%%%%%%%%%%%%%%%%% wall filter %%%%%%%%%%%%%%%%%%%%%%%%% 
Wn = 0.05;          % high pass filter
filterOrder = 5;    % order of the filter
[B,A] = butter(filterOrder,Wn,'high');
% figure;
% freqz(B,A);         % frequency response of filter
% title('Wall Filter');

filtI = filter(B,A,I);  % filtered I
filtQ = filter(B,A,Q);  % filtered Q
% 
% figure;
% plot(1000*[1:frameN]/PRF,filtI,1000*[1:frameN]/PRF,filtQ); 
% legend('Wall Filtered I','Wall Filtered Q');
% xlabel('Time (miliseconds)');

%%%%%%%%%%%%%%%%%%%%%%%% spectrum %%%%%%%%%%%%%%%%%%%%%%%%%
if (WF)
    nFFT  = 128;    % output of FFT
    nSamples = 64;  % number of data points used for FFT
    sweep = 32;     % data shift from one fft to the next fft
    win = hanning(nSamples)';   % windowing

    spec = zeros(floor( (frameN - nSamples)/sweep) - 1, nFFT);
    for i = 2 : floor( (frameN - nSamples)/sweep) - 1 % skip the transient response of filter
        startInd = 1 + (i-1)*sweep;
        endInd   = startInd +nSamples-1;
        data =  ( filtI(startInd:endInd) + j * filtQ(startInd:endInd) ) ;
        theta = angle( data(1:end-1) * data(2:end)' );
        spec(i-1,:) = fftshift( fft( data.* win , nFFT) );
        angs(i-1) = theta;
    end;
    Iout = filtI;
    Qout = filtQ;
    % figure; 
    % imagesc( sqrt( abs(spec) )' );
    % colormap(gray);
    % title('Spectrum Wall Filtered');
    % caxis([0,200])
else
    nFFT  = 128;    % output of FFT
    nSamples = 64;  % number of data points used for FFT
    sweep = 32;     % data shift from one fft to the next fft
    win = hanning(nSamples)';   % windowing

    spec = zeros(floor( (frameN - nSamples)/sweep) - 1, nFFT);
    for i = 2 : floor( (frameN - nSamples)/sweep) - 1 % skip the transient response of filter
        startInd = 1 + (i-1)*sweep;
        endInd   = startInd +nSamples-1;
        data =  ( I(startInd:endInd) + j * Q(startInd:endInd) ) ;
        theta = angle( data(1:end-1) * data(2:end)' );
        % wall filtering
        data = data .* exp(-j*theta*[0:nSamples-1]);
        data = data - mean(data);

        spec(i-1,:) = fftshift( fft( data.* win , nFFT) );
        angs(i-1) = theta;
    end;
    Iout = I;
    Qout = Q;
    % figure; 
    % imagesc( sqrt( abs(spec) )' );
    % colormap(gray);
    % title('Spectrum Unfiltered');
    % caxis([0,200])
end

spec = sqrt( abs(spec) )' ;
