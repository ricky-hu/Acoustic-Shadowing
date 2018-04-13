% The following script (1) reads the IQ signal from CW, (2) extracts the IQ
% signals at the desired PRF, (3) applies the wall filter to the IQ signals,
% (4) generates the spectrum from the wall filtered data.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - May 2014

close all;
clear
clc

% add the path for the RP reader
addpath('..\common');

%% %%%%%%%%%%%%%%%%%%%%% Reading IQ Signals %%%%%%%%%%%%%%
path = 'data\';
filename = '14-52-17.drf';
n = 400000;  % number of acquisitions/shots to be read
[IQ,header] = RPread([path, filename], n);

% make sure there is enough data
if (n > header.nframes ) 
    n = header.nframes;
    IQ = IQ(1:n,:);
end

% saving the data from the header
PRFCW   = 100*1e3;       % hardware has a fixed PRF of 100KHz for CW
PRF     = header.dr;     % pulse repetition frequency for display
Fe      = header.txf;           % TX frequency MHz
Fs      = header.sf;            % Sampling frequency MHz
Gate    = header.h;             % Gate size

%% %%%%%%%%%%% extracting I and Q data %%%%%%%%%%%%%%%%%%%% 
% get IQ data at the display PRF by decimating the original IQ
decimFactor = round(PRFCW / PRF);
% decimation
I = decimate(IQ(1,:), decimFactor); 
Q = decimate(IQ(2,:), decimFactor);
n = length(I);

%% %%%%%%%%%%%%%%%%%%% wall filtering %%%%%%%%%%%%%%%%%%%%% 
Wn = 0.05;          % high pass filter
filterOrder = 5;    % order of the filter
[B,A] = butter(filterOrder,Wn,'high');

filtI = filter(B,A,I);  % filtered I
filtQ = filter(B,A,Q);  % filtered Q

%% %%%%%%%%%%%%%%%%%%%%%% spectrum %%%%%%%%%%%%%%%%%%%%%%%
nFFT  = 128;    % output of FFT
nSamples = 64;  % number of data points used for FFT
sweep = 32;     % data shift from one fft to the next fft
win = hanning(nSamples)';   % windowing

for i = 2 : floor( (n - nSamples)/sweep) - 1 % skip the transient response of filter
    startInd = 1 + (i-1)*sweep;
    endInd   = startInd +nSamples-1;
    data =  ( filtI(startInd:endInd) + 1i * filtQ(startInd:endInd) ) ;
    spect(:,i-1) = fftshift( fft( data.* win , nFFT) )';
end;

%% %%%%%%%%%%%%%%% Display Results %%%%%%%%%%%%%%%%%%%%%%%
figure;
set(gcf,'position',[70, 70, 1100, 600]);
fntSz = 12;

subplot(3,1,1)
plot((1:n)/PRF,I,(1:n)/PRF,Q); 
legend('I','Q');
ylabel('I/Q'); xlabel('Time [s]');

subplot(3,1,2)
plot((1:n)/PRF,filtI,(1:n)/PRF,filtQ); 
legend('Wall filtered I','Wall filtered Q');
ylabel('filtered I/Q');

subplot(3,1,3)
imagesc( 20*log10( abs(spect) ) );   % apply log compression to spectrum
colormap(gray), caxis([20,90]) % dB scale
ylabel('Spectrum');
