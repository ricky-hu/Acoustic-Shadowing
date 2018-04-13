%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An example script for connecting to the UlteriusCOM server, and
% downloading the data and injecting it back to the exam software
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

TYPE = 8;    

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
h.registerevent({'newFrameEvent' 'newFrameCallback_withInjection'});       % NOTICE: THE FORMAT NEEDS TO BE CHANGED FOR MATLAB 6.5 (R2013) 

% Connecting to the machine running the exam software
h.connect(SONIX_IP);
if (invoke(h, 'isConnected'))
    display('Connected to the Exam software');
else
    display('Connection failed!');
end

% Depending on the type of data you are acquiring in real-time, you may
% need to get every other frame, or every other 3rd frame, etc.
h.setdataRateReductionFactor(5)   % YOU NEED TO CHANGE THIS LINE

%% Acquiring and injecting images for 100 seconds
% Freezing the system
if (~invoke(h, 'getFreezeState'))
    while(~invoke(h, 'toggleFreeze')) % Freeze
    end
end

% turning on the injection mode
h.setInjectMode(1);
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
% turning off the injection mode
h.setInjectMode(0);

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
