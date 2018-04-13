%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An example script for connecting to the UlteriusCOM server, reading the
% cine buffer and displaying the data.
%
% Copyright: Ultrasonix Medical Corporation Jan 2013
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Notice: Matlab 7 (R2014) supports COM function calls with different no of I/O:
%         y = h.f0;
%         y = h.f0();
%         y = h.f1(x);
%         y = h.f2(x1, x2, ...);
%         [y1, y2] = h.f3(x);
%
%         Matlab 6.5 (R2013) only supports COM function calls of the type:
%         y = h.f1(x);
%         y = h.f2(x1, x2, ...);
%         When you have no inputs, you should use:
%         y = invoke(h, 'f0');
%         When you have multiple outputs, you should use:
%         [y1, y2] = invoke(h, 'f3', x);

% Clearing the environment
clc
clear
close all

% Choose the data type you want to read from the Cine buffer
TYPE = 4;    
       %1;      % XRGB sequence of screen shots       **** KNOWN ISSUE ****
       %2;      % pre scan converted B-mode data
       %4;      % grayscale scan converted B-mode data
       %8;      % XRGB scan converted B-mode data
       %16;     % RF Data
       %32;     % M-mode pre scan conversion data     **** KNOWN ISSUE ****
       %64;     % M-mode data 
       %128;    % Pulse Doppler RF data
       %256;    % Pulse Doppler spectrum data
       %512;    % Color Doppler RF data               **** KNOWN ISSUE ****
       %1024;   % Scan converted B-mode with color Doppler super-imposed
       %2048;   % Color Doppler velocity/variance images
       %4096;   % Contrast agent data ?????
       %8192;   % Scan converted B-mode with elastography super-imposed
       %16384;  % Elastography overlay
       %32768;  % Elastography pre scan conversion    **** KNOWN ISSUE ****
       %65536;  % ECG data ??????
       %131072; % GPS data from the probe ???????
       %262144; % GPS data from the needle ??????
       %268435456; % PNG image ??????

% Making the plot functions accessible to the environment
addpath('..\SonixDataTools\PlotFunctions');
addpath('..\SonixDataTools\ImageProcessing');
addpath('..\SonixDataTools\Misc');

% SDK path to find the Ulterius COM server
SDK_BIN_PATH = '../../bin';                                                % YOU NEED TO CHANGE THIS LINE IF YOU MOVE THE CODE
% The IP address of the machine running the exam software 
SONIX_IP     = 'localhost';                                                % YOU NEED TO CHANGE THIS LINE IF YOU ARE RUNNING REMOTELY

% Registering the UlteriusCOM server on the computer
system(['cd "' SDK_BIN_PATH '" && ' 'regsvr32 UlteriusCOM.dll']);
% Getting a handle to the UlteriusCOM server inside Matlab
h = actxserver('UlteriusCOM.Server');

% registering the parameter callback;
h.registerevent({'paramEvent' 'paramCallback'});                           % NOTICE: THE FORMAT NEEDS TO BE CHANGED FOR MATLAB 6.5 (R2013) 

% Connecting to the machine running the exam software
h.connect(SONIX_IP);
if (invoke(h, 'isConnected'))
    display('Connected to the Exam software');
else
    display('Connection failed!');
end

%% Acquiring some data on the exam software
% Freezing the system
if (~invoke(h, 'getFreezeState'))
    while(~invoke(h, 'toggleFreeze')) % Freeze
    end
end

% Unfreeze for 2 seconds to acquire data
while(~invoke(h, 'toggleFreeze')) 
end
pause(2);
while(~invoke(h, 'toggleFreeze'))
end

%% Dowloading the data from the Exam software and displaying it
figure(1)
axesHandle1 = axes;
% Reading the frames one by one from the Cine
for FrameCntr = 1:h.getCineDataCount(TYPE)
    
    % Sometimes the data is not read over TCP/IP, so the read needs to be
    % repeated until the data comes in
    success = false;
    while (~success)
        pause(0.1); % giving the system time to adapt
        [success, IM] = invoke(h, 'getCineData', TYPE, FrameCntr, false);
    end
    
    %%%%%%%%%%%%%%%%%%%%%% Data Adjustments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For the velocity/vector, the images are
    % concatanated horizontally, instead of vertically
    if sum(TYPE == [2048]) > 0
        IM = [IM(:,1:size(IM, 2)/2);
              IM(:,size(IM, 2)/2+1:end)];
    end
    % Scan Conversion causes the image to be transposed
    if sum(TYPE == [1 4 8 64 256 1024 2048 4096 8192 16384]) > 0
        IM = IM';
    end
    % For displaying RF data, the color limits are adjusted for 
    % better contrast
    Gain = 1;
    if sum(TYPE == [16]) > 0
        Gain = 0.1;
    end
    % For some algorithms, the data should be converted to the 
    % double type
    if sum(TYPE == [128]) > 0
        IM = double(IM);
    end
    % A second plot is needed for RF display and velocity/variance
    axesHandle2 = 0;
    if sum(TYPE == [128 2048]) > 0
        figure(2)
        axesHandle2 = axes;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Making the header for the data
    DataHeader = MakeHeader4CineData(h, TYPE);
    
    % Displaying the data using the plot_SonixRP function
    if ~isempty(DataHeader)
        plot_SonixRP(IM, DataHeader, [axesHandle1 axesHandle2], Gain);
    end
    title(['Frame No ' num2str(FrameCntr) ' out of ' num2str(h.getCineDataCount(TYPE))]);
    hold off
end

%% Releasing the Handle to the Ulterius COM server and unregistering
% Disconnecting from the exam software
invoke(h, 'disconnect');
if (invoke(h, 'isConnected'))
    display('Disconnection failed!');
else
    display('Disconnected');
end
delete(h);
system(['cd "' SDK_BIN_PATH '" && ' 'regsvr32 /u UlteriusCOM.dll']);

