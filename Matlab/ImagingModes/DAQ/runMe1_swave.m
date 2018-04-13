% The following script reads channel data and generate B-mode image from it
% using beamforming, IQ demodulation, envelope detection, and log 
% compression.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Nov 2013

close all;
clear all;
clc;

% add the path for the RP reader
addpath('..\common');

%%%%%%%%%%%%%%%%%%%%%%% Reading Channel Data %%%%%%%%%%%%%
% Case 1: reading from .rf or .daqrf data
% path = 'data\daqrf\';
% fileName = 'daqData.rf';
% n = 1;     % number of frames
% [CHframes,header] = RPread([path, fileName], n);

% Case 2: reading from data folder
d = 10;
for j=1:length(d)
      s = sprintf('H:\\SWAVE2.0\\Ultrafast\\200_.5\\15\\');
    path = s;
    n =125;     % frame number
    % [CHframes, header] = DAQread(path, ones(1,128), n, true);

    %%%%%%%%%%%%%%%% Display Channel data %%%%%%%%%%%%%%%%%%%%
    figure; colormap(gray);

    for i = 1:n
        [CHframes, header] = DAQread(path, ones(1,128), i, true);
        CHframe(:,:,(j-1)*n+i) = CHframes(:,:);
%         RFframe(:,:,(j-1)*n+i) = parallelBeamformer(CHframe(:,:,(j-1)*n+i), 64, 40e6);
%         Bmode(:,:,(j-1)*n+i) = 20*log10( abs(hilbert(RFframe(:,:,(j-1)*n+i)) ) );
%          subplot(2, 2, 1 );
%      imagesc( 20*log10( abs(hilbert(CHframe(:,:,(j-1)*n+i)) ) ) , [0 90]); 
%     axis square; title('Channel image'); ylabel('Samples');
%     xlabel('Scan Lines');
% 
%     subplot(2, 2, 2 )
%     imagesc( 20*log10( abs(hilbert(RFframe(:,:,(j-1)*n+i)) ) ) , [0 90]); 
%     title('B image'); ylabel('Samples'); xlabel('Scan Lines');
%     axis square;
% % 
%     subplot(2, 1, 2 )
%     lnInd = size(CHframe(:,:,(j-1)*n+i),2) / 2;    % line of interest
%     plot( RFframe(:,lnInd,(j-1)*n+i )); 
%     title('Channel line'); xlabel('Samples'); ylabel('Amplitude');
%     axis tight;
%     i
%     drawnow;

    end
end

%%
freqs = 200; %excitation freq
% To Escan
Data_name ='\Feb22\200Hz_.5\\';
mkdir(['C:\Farah\Ultrafast_Matlab_code\',Data_name])
cd(['C:\Farah\Ultrafast_Matlab_code\',Data_name])
% ss = size(data_process);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_process = CHframe;
overall_image = data_process(:);
ss = size(data_process);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acq_number = 1;
new_data_location   = ['C:\Farah\Ultrafast_Matlab_code',Data_name,'\'];
rf_data_name        = ['rfData_acq', num2str(acq_number)];
ts_data_name        = ['timeStamp_acq', num2str(acq_number)];
tsf_data_name       = ['timeStamp_acq', num2str(acq_number),'frame'];
fl_data_name        = ['frequencyList_acq', num2str(acq_number)];
axial_res           = 1540/(4e7)*(10^3)/2;
Depth               = ss(1)*axial_res;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numLines  = 128;
N_element = numLines;
eScanParams.elastography.numPlanes = 1;
num_frames  = 125;
%which = 2;FFF
eScanParams.elastography.numSweeps = 1;
eScanParams.motor.angleIncrement = 0;
eScanParams.excitation.frequency = num2str(freqs);
% eScanParams.excitation.multiFrequency = 'false';
% eScanParams.ultrasound.txFrequency = 7e6; % probably not needed
eScanParams.ultrasound.samplingFrequency = 20e6; % probably not needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part (1): Generate the rf file for everything
cmd = (['fidEscanRF = fopen(''',new_data_location,rf_data_name,''',''wb'');']);
eval(cmd);
%overall_image = parsed_data(:,:,(3*(which-1)+1):which*num_frames);
%overall_image = parsed_data(:,:,1:num_frames);
%overall_image = round(RF_data_kSVD);

%image_depth = max(size(parsed_data));
image_depth = ss(1);
%image_depth = max(size(overall_image));
% RF_data_l = log(abs(RF_data));
% overall_image = RF_data_l-max(RF_data_l(:))+60;
% overall_image(overall_image<0)=0;
% overall_image = round(overall_image/60*128);

for f = 1:eScanParams.elastography.numPlanes
    %f = 1:num_frames*eScanParams.elastography.numPlanes
    version = 2;
    datatype = 1;% 1 - RF, 14 - timestamp
    datadate = year(date)*10000 + month(date)*100 + day(date);
    tag = round(rand()*10000);
    numDims = 6;

    if f == 1
        % white the header file
        LineLength = image_depth;
        %eScanParams.ultrasound.numLines = N_element;
        eScanParams.ultrasound.numLines = N_element;
        dims(1) = eScanParams.ultrasound.numLines;
        dims(2) = LineLength;
        dims(3) = num_frames ;
        dims(4) = eScanParams.elastography.numPlanes;
        dims(5) = eScanParams.elastography.numSweeps;
        dims(6) = 0;
        % write escan header
        header = [version;datatype;datadate;tag;numDims;dims']; 
        fwrite(fidEscanRF,header,'int32');
    end 
    
    current_frame = round(squeeze(overall_image(:,f)));
    fwrite(fidEscanRF,current_frame,'short');
end
fclose(fidEscanRF);
% check the written file is alright
% cmd  = ['rf_data = ReadEscanData(''', new_data_location,rf_data_name,''');'];
% eval(cmd)

% Part (2):generate the frame timestamp files
cmd = (['fidEscanTSF = fopen(''',new_data_location,tsf_data_name,''',''wb'');']);
eval(cmd);
frameTimeStamps = ((1:num_frames*eScanParams.elastography.numPlanes)-1);%*128+1;
dims(1) = 1;
dims(2) = 1;
datatype = 14;
header = [version;datatype;datadate;tag;numDims;dims']; 
fwrite(fidEscanTSF,header,'int32');
fwrite(fidEscanTSF,frameTimeStamps,'float32');
fclose(fidEscanTSF);
% cmd  = ['tsf_data = ReadEscanData(''', new_data_location,tsf_data_name,''');'];
% eval(cmd)

% Part (3): Generae the plane timestamp files
cmd = (['fidEscanTS = fopen(''',new_data_location,ts_data_name,''',''wb'');']);
eval(cmd);
%planeTimeStamps = (0:eScanParams.elastography.numPlanes)*1.2083/2 ; 
planeTimeStamps = 0;
dims(1) = 1;
dims(2) = 1;
dims(3) = 1;
datatype = 14;
header = [version;datatype;datadate;tag;numDims;dims']; 
fwrite(fidEscanTS,header,'int32');
fwrite(fidEscanTS,planeTimeStamps,'float32');
fclose(fidEscanTS);
% cmd  = ['ts_data = ReadEscanData(''', new_data_location,ts_data_name,''');'];
% eval(cmd)

% Part (4): Generate the frequency list file
cmd = (['fidEscanFL = fopen(''',new_data_location,fl_data_name,''',''wb'');']);
eval(cmd);
% write header
dims(4) = 1;
datatype = 14; % NA
header = [version;datatype;datadate;tag;numDims;dims']; 
fwrite(fidEscanFL,header,'int32');
for f = 1:eScanParams.elastography.numSweeps
    fwrite(fidEscanFL,0,'float32'); % -1 is multi frequency
end
fclose(fidEscanFL);
% cmd  = ['fl_data = ReadEscanData(''', new_data_location,fl_data_name,''');'];
% eval(cmd)
