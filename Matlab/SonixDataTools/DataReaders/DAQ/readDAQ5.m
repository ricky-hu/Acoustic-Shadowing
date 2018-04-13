function [hdr, RFframe] = readDAQ(path, chanls, frameN, reRoute)
% Read the specified channel data from .daq files
% Usage:
% [hdr, RFframe] = readRFframe(path, filename, frameInd);
%       path:       strings showin the path to the data folder
%       chanls:     chanels of interest
%       frameInd:   index of frame of interest
%       reRoute:    true: transducer element, false: DAQ element
% Example:
%       Reading single frame
%       [header, RFframe] = readRFframe('c:\foldername\', ones(1,128), 2, true);
%       will return the second frame as a 2D matrix in RFframe
% Example:
%       use inside a for loop in order to read several frames
%       for i:1:10
%           [header, RFframe(i,:,:)] = readRFframe('c:\foldername\', ones(1,128), i, true);
%       end;
%
% Author: Reza Zahiri Azar, March 2008, University of British Columbia


% Signal assignement to transducer element
if (reRoute)
    chRout = [0 16 32 48 64 80 96 112 1 17 33 49 65 81 97 113 2 18 34 50 66 82 98 114 ...
              3 19 35 51 67 83 99 115 4 20 36 52 68 84 100 116 5 21 37 53 69 85 101 117 ...
              6 22 38 54 70 86 102 118 7 23 39 55 71 87 103 119 8 24 40 56 72 88 104 120 ...
              9 25 41 57 73 89 105 121 10 26 42 58 74 90 106 122 11 27 43 59 75 91 107 ...
              123 12 28 44 60 76 92 108 124 13 29 45 61 77 93 109 125 14 30 46 62 78 94 ...
              110 126 15 31 47 63 79 95 111 127];
else    % show channel signals
    chRout = [0:127];  
end

for i = 1:128
    if (chanls(i) == 1)
        % create the file name
        chlInd = i-1;
        if (chlInd<10)
            tag = ['00',num2str(chlInd)];
        elseif (chlInd<100)
            tag = ['0',num2str(chlInd)];
        else
            tag = num2str(chlInd);
        end
        filename = ['CH',tag,'-0000.daq'];

        % open channel file
        fid = fopen([path, filename],'r');
        
        % read header
        hdr = fread(fid, 2, 'int32');
        numFrame = hdr(1);      % number of frames acquired
        lLength  = hdr(2);      % length of each line in samples
        
        % jump to requested frame
        fseek( fid, (frameN-1) * ( lLength * 2), 'cof');
        
        % read channel data and correct the mapping
        dataformat = 'int16';
        ind = 1 + chRout(i);
        RFframe(:,ind)       = fread(fid, [lLength], dataformat );   % the actual data
        
        % close channel file
        fclose(fid);
        
    end;
end;

