% The following script (1) reads the RF data in PW mode, (2) generates the
% IQ signal, (3) applies the wall filter to the IQ signals, and (4)
% generates the spectrum from the wall filtered data.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

%%%%%%%%%%%%%%%%%%%%%%% Reading RF Signals %%%%%%%%%%%%%%
path = 'data\';
filename = '10-41-18.drf';

n = 9000; % number of acquisition
[PWRF, header] = RPread( [path, filename], n);

% extracting header info
PRF     = header.dr;            % pulse repetition frequency
Fe      = header.txf;           % TX frequency MHz
Fs      = header.sf;            % Sampling frequency MHz
Gate    = header.h;             % Gate size

figure;
subplot(4,1,1)
imagesc((1:n)/PRF, (1:Gate), PWRF);
axis tight
xlabel('Time [sec]');
ylabel('RF');
colormap(gray);

%%%%%%%%%%%%%%%%%%%%%%% Quadrature I/Q Demodulation %%%%%%%%%%%%%%
% Windowing 
win = hamming(Gate)';
% Demodulation Signals 
SinDem = win .* sin(2*pi*Fe/Fs*(1:Gate));
CosDem = win .* cos(2*pi*Fe/Fs*(1:Gate));

% Quadrature Detector 
I = zeros(1,n); Q = zeros(1,n);
for fe = 1:n           
    I(fe) = SinDem * PWRF(:,fe);
    Q(fe) = CosDem * PWRF(:,fe);
end;

subplot(4,1,2)
plot((1:n)/PRF,I,(1:n)/PRF,Q); 
legend('I','Q');
ylabel('I/Q'); xlabel('Time [s]');

%%%%%%%%%%%%%%%%%%%%% wall filter %%%%%%%%%%%%%%%%%%%%%%%%% 
Wn = 0.05;          % high pass filter
filterOrder = 5;    % order of the filter
[B,A] = butter(filterOrder,Wn,'high');

filtI = filter(B,A,I);  % filtered I
filtQ = filter(B,A,Q);  % filtered Q

subplot(4,1,3)
plot((1:n)/PRF,filtI,(1:n)/PRF,filtQ); 
legend('Wall filtered I','Wall filtered Q');
ylabel('filtered I/Q');

%%%%%%%%%%%%%%%%%%%%%%%% spectrum %%%%%%%%%%%%%%%%%%%%%%%%%
nFFT  = 128;    % output of FFT
nSamples = 64;  % number of data points used for FFT
sweep = 32;     % data shift from one fft to the next fft
win = hanning(nSamples)';   % windowing

for i = 2 : floor( (n - nSamples)/sweep) - 1 % skip the transient response of filter
    startInd = 1 + (i-1)*sweep;
    endInd   = startInd +nSamples-1;
    data =  ( filtI(startInd:endInd) + 1i * filtQ(startInd:endInd) ) ;
    spect(:,i-1) = ( fft( data.* win , nFFT) )';
end;

subplot(4,1,4)
imagesc( 20*log10( abs(spect) ) );   % apply log compression to spectrum
colormap(gray), caxis([20,90]) % dB scale
ylabel('Spectrum');
