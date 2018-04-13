%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An example script for connecting to the UlteriusCOM server, and
% downloading and displaying data in real-time
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

% Registering the COM server on the computer
system(['cd "' SDK_BIN_PATH '" && ' 'regsvr32 UlteriusCOM.dll']);
% Getting a handle to the COM server inside Matlab
h = actxserver('UlteriusCOM.Server');

% registering the callbacks;
h.registerevent({'paramEvent' 'paramCallback'});                           % NOTICE: THE FORMAT NEEDS TO BE CHANGED FOR MATLAB 6.5 (R2013) 
h.registerevent({'newFrameEvent' 'newFrameCallback'});                     % NOTICE: THE FORMAT NEEDS TO BE CHANGED FOR MATLAB 6.5 (R2013) 

% Testing the callback
display('Testing the callback: You should see a checkboard image!'); invoke(h, 'testCallback');

% Connecting to the machine running the exam software
h.connect(SONIX_IP);
if (invoke(h, 'isConnected'))
    display('Connected to the Exam software');
else
    display('Connection failed!');
end

% Depending on the type of data you are acquiring in real-time, you may
% need to get every other frame, or every other 3rd frame, etc.
h.setdataRateReductionFactor(2)   % YOU NEED TO CHANGE THIS LINE

%% Acquiring data for 100 seconds
% Freezing the system
if (~invoke(h, 'getFreezeState'))
    while(~invoke(h, 'toggleFreeze')) % Freeze
    end
end

if (h.setDataToAcquire(TYPE))
    if (invoke(h, 'getDataToAcquire') == TYPE)
        display('Successfully requested the Exam software to send the data');
        % Unfreeze for 100 seconds to acquire data
        while(~invoke(h, 'toggleFreeze')) 
        end
        pause(100);
        while(~invoke(h, 'toggleFreeze'))
        end
    else
        display('There has been an error in asking the Exam software to send this type of data');
    end
end

%% Releasing the Handle to the Ulterius COM server and unregistering
% Disconnecting from the exam software
invoke(h, 'disconnect');
if (invoke(h, 'isConnected'))
    display('Disconnection failed!');
else
    display('Disconnected from the Exam Software');
end
delete(h);
system(['cd "' SDK_BIN_PATH '" && ' 'regsvr32 /u UlteriusCOM.dll']);
