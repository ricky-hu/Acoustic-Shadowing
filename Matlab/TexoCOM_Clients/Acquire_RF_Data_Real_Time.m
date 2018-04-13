%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An example script for connecting to the TexoCOM server, and acquiring the
% data in real time.
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

% Making the plot functions accessible to the environment
addpath('..\SonixDataTools\PlotFunctions');
addpath('..\SonixDataTools\ImageProcessing');
addpath('..\SonixDataTools\Misc');

% SDK path to find the TexoCOM server
SDK_BIN_PATH = '../../bin';                                                % YOU NEED TO CHANGE THIS LINE IF YOU MOVE THE CODE

% Registering the TexoCOM server on the computer and getting a handle to it
system(['cd "' SDK_BIN_PATH '" && ' 'regsvr32 TexoCOM.dll']);
h = actxserver('TexoCOM.Server');

% Choosing the connector to which the probe is connected
ConnectorWhereTheProbeIsConnected = 0;                                     % YOU NEED TO CHANGE THIS LINE TO REFLECT THE EXPERIMENTAL SETUP

% Some imaging parameters
gain  = 0.8;
power = 10;
depth = 100e3;

% registering the callback
h.registerevent({'newFrameEvent' 'newFrameCallback'});                     % NOTICE: THE FORMAT NEEDS TO BE CHANGED FOR MATLAB 6.5 (R2013) 

% because of the delays, in order to prevent the events from building up,
% not all frames are received. Every third frame is received in this
% example
h.setdataRateReductionFactor(3);                                           % YOU MAY WANT TO CHANGE THIS LINE

%% Initializing Texo
disp('Initializing Texo: programming the firmware');
FirmwarePath = '../../texo/dat/';                                          % YOU NEED TO CHANGE THIS LINE IF YOU MOVE THE CODE
success = h.texoInit(FirmwarePath, 3, 4, 0, 64, 0 , 128, true);            % YOU NEED TO CHANGE THIS LINE TO REFLECT YOUR HARDWARE
if(success)
    disp('Texo was successfully initialized!');
else
    disp('Texo could not be initialized!');
end

% Activating a probe connector
success = h.texoActivateProbeConnector(ConnectorWhereTheProbeIsConnected);
if(success)
    disp('The probe connector was successfully activated!');
else
    disp('Could not activate the connector!');
end

% Selecting the probe
h.texoSelectProbe(h.texoGetProbeCode(ConnectorWhereTheProbeIsConnected));
if(success)
    disp('The probe was successfully selected!');
else
    disp('Could not select the probe!');
end

%% Programing a sequence

% setting up a fixed tgc
invoke(h, 'texoClearTGCs');
h.texoAddTGCFixed(gain);

% setting up the power
h.texoSetPower(power, power, power);

% setting up the VCA
h.texoVCAInfo_setAmplification(16);
h.texoVCAInfo_setActivetermination(1);
h.texoVCAInfo_setInclamp(1600);
h.texoVCAInfo_setLPF(1);
h.texoVCAInfo_setLNAIntegratorEnable(1);
h.texoVCAInfo_setPGAIntegratorEnable(1);
h.texoVCAInfo_setHPFDigitalEnable(1);
h.texoVCAInfo_setHPFDigitalValue(11);
invoke(h, 'texoSetVCAInfo');

% the sequence
success = invoke(h, 'texoBeginSequence');
if(success)
    disp('Programming the sequence started!');
else
    disp('Failed to start programming the sequence!');
end

% setting transmit parameters
h.texoTP_setCenterElement(0);
h.texoTP_setAperture(64);
h.texoTP_setFocusDistance(depth * 1000 / 2);    % half the imaging depth
h.texoTP_setAngle(0);
h.texoTP_setFrequency(invoke(h, 'texoGetProbeCenterFreq'));
h.texoTP_setPulseShape('+-');
h.texoTP_setSpeedOfSound(1540);
h.texoTP_setSync(0);
h.texoTP_setUseManualDelays(0);
h.texoTP_setUseMask(0);
h.texoTP_setTableIndex(-1);
h.texoTP_setTxRepeat(0);
h.texoTP_setTxDelay(100);
% setting receive parameters
h.texoRP_setCenterElement(0);
h.texoRP_setAperture(64);
h.texoRP_setAngle(0);
h.texoRP_setMaxApertureDepth(30000);
h.texoRP_setAcquisitionDepth(150e3);
h.texoRP_setSaveDelay(1 * 1000);
h.texoRP_setRxBeamFormingDelay(2500);
h.texoRP_setSpeedOfSound(1540);
h.texoRP_setChannelMask(uint8(ones(1, 64)));
h.texoRP_setApplyFocus(1);
h.texoRP_setUseCustomWindow(0);
h.texoRP_setDecimation(0);
h.texoRP_setLGCValue(0);
h.texoRP_setTGCSel(0);
h.texoRP_setTableIndex(-1);
h.texoRP_setCustomLineDuration(0);
h.texoRP_setNumChannels(64);
h.texoRP_setWeightType(0);  % apodization
h.texoRP_setFnumber(20);    % F number x10: 20 mean Fnumber = 2.0

for Cntr = 0:127
    h.texoTP_setCenterElement(Cntr+0.5);
    h.texoRP_setCenterElement(Cntr+0.5);
    [success, lineSize, lineDuration] = invoke(h, 'texoAddLine');
    if (success)
        disp(['Successfully programmed line ' num2str(Cntr+0.5) ...
                 ' and the lineSize is ' num2str(lineSize) ...
                 ' and duration ' num2str(lineDuration)]);
    end
end

success = invoke(h, 'texoEndSequence');
if(success)
    disp('Programming the sequence finished!');
else
    disp('Failed to finish programming the sequence!');
end

%% Running Imaging for 100 seconds
success = invoke(h, 'texoRunImage');
if(success)
    disp('Imaging started!');
else
    disp('Imaging could not be started');
end

pause(100);

success = invoke(h, 'texoStopImage');
if(success)
    disp('Imaging stopped!');
else
    disp('Imaging could not be stopped');
end

%% Shutting down Texo
invoke(h, 'texoShutdown');
delete(h);
system(['cd "' SDK_BIN_PATH '" && ' 'regsvr32 /u TexoCOM.dll']);