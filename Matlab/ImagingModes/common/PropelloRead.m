% Loads the ultrasound volume data acquired using the Propello SDK
%
% Inputs:  
%     datapath - The path of the data to open
%
% Return:
%     volume -  The volume data returned into a 3D array
%     hdr - header which contains the following information:
%
%          hdr.datatype -   Data type (0: prescan B, 1: postscan B, 2: rf, 3: vel/var, 5 = B+flow RGB)
%          hdr.numVols -    The number of volumes in the file
%          hdr.fpV -        Frames per volume
%          hdr.h -          Image height of the image (samples per line)
%          hdr.w -          Image width (scan lines per frame)
%          hdr.ss -         Sample size
%
% Example:
%
% [volume, hdr] = PropelloRead(datapath);
% 
% for i = 1:hdr.fpV, 
%      imagesc(volume(:,:,i)); 
%      pause(0.05); 
% end
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Jan 2014

function [volume, hdr]  = PropelloRead(datapath)

fid= fopen(datapath, 'r'); 
if( fid == -1), error('Cannot open file'); end

% read the header info
volinfo = fread(fid, 7, 'int');

hdr.datatype = volinfo(1);  % data type      
hdr.numVols = volinfo(2);   % number of volumes
hdr.fpV = volinfo(3);   % frames per volume
hdr.w = volinfo(4);     % width
hdr.h = volinfo(5);     % height
hdr.ss = volinfo(6)/8;  % in bytes

% read the actual data
if(hdr.datatype == 0 ) % pre scanconversion B
    volume = zeros(hdr.h, hdr.w, hdr.fpV);
    for i = 1:hdr.fpV
        volume(:,:,i) = fread(fid, [hdr.h, hdr.w],'uint8'); 
    end
elseif (hdr.datatype == 1) % post scanconversion B
    volume = zeros(hdr.w, hdr.h, hdr.fpV);
    for i = 1:hdr.fpV
        volume(:,:,i) = fread(fid, [hdr.w, hdr.h],'uint8'); 
    end
elseif (hdr.datatype == 2) % RF data
    volume = zeros(hdr.h, hdr.w, hdr.fpV);
    for i = 1:hdr.fpV
        volume(:,:,i) = fread(fid, [hdr.h, hdr.w],'int16'); 
    end
elseif (hdr.datatype == 3)  % Velocity and Variance   
    volume = zeros(hdr.w, hdr.h, hdr.fpV*2);
    for i = 1:hdr.fpV*2
        volume(:,:,i) = fread(fid, [hdr.w, hdr.h],'uint8'); 
    end
elseif (hdr.datatype == 5) % B+flow RGB    
    volume = zeros(hdr.w, hdr.h, hdr.fpV);
    for i = 1:hdr.fpV
        volume(:,:,i) = fread(fid, [hdr.w, hdr.h],'int32'); 
    end
end
    
fclose(fid);


