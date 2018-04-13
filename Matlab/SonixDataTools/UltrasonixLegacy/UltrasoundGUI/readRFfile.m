function [rf] = readRFfile(varargin)
%
%readRFfile Read an RF file as a matrix and store it in a .mat file
%
%   RF = readRFfile(FILENAME)
%   FILENAME : name of the file to be read without the .rf extension
%   RF : output double-type RF matrix with dimensions (RFsamples * LineNumber * Frames)
%           See comment below as to why type double.
%   width, height: as read from file header. I'm assuming these are # scan
%   lines and length thereof. STAUFFER.
%
% Reza Zahiri 2006
%
% M Stauffer        - modifications July 2007 - added other outputs, and see below
% T de Souza-Daw    - modifications 5 September - added, interpret full header
% and RF structure
% Reza              - modification April 2009 - unnecessary allocations are
%                   removed. The function now returns only the prefered
%                   Frame and does not read the whole data

% Changed the number of arguments by Ali
if (nargin == 2)
    filename  = varargin{1}; 
    prefFrame = varargin{2};
    version   = '5.7.x';
else
    filename  = varargin{1}; 
    prefFrame = varargin{2};
    version   = varargin{3};
end    

disp('readRFFile: STAUFFER edited...');

[path,namewithoutext,ext,ver] = fileparts(filename);
if isempty(ext)
    filename = strcat(filename,'.rf');
end
fid = fopen(strcat(filename),'r');
if fid == -1
    error('readFRfile: error opening file.');
end

disp('readFRfile: Reading .rf file...');

try %Try block for file reading and processing

    %File Header - see Page 10 of Ultrasounix Manual
    %Read
    %
    [tag1,count] = fread(fid,19,'int32'); %19 fields in header see below.
        %STAUFFER - sonix RP 3.x now has file header with 19 long int,
        %instead of the old 7
    frames = tag1(2);
    numFrames = frames;
    w = tag1(3); %STAUFFER - as best I can tell, w is # scan lines
    h = tag1(4); % and h is scan line length
    disp(sprintf('readRFfile: w: %d h: %d numFrames: %d',w,h,numFrames));

    if strcmp(version, '5.7.x')
        % Note: Added by Reza April 2009
        % Only read prefered frame
        fseek(fid, 4 + (prefFrame-1) * (4 + w*h*2), 'cof');
        RF = fread(fid, [h, w],'int16'); 
    elseif strcmp(version(1), '6')
        % Note: Added by Ali B Nov 2012
        % Frame No has been dropped since Sonix 6.X
        fseek(fid, (prefFrame-1) * (w*h*2), 'cof');
        RF = fread(fid, [h, w],'int16');
    end
    
%     % Read the raw data
%     RF = zeros(h,w,1,'double');
%         %STAUFFER - make type double. This is what the 'readDMPfileRF.m'
%         %from Ultrasonix does, used in their MATLAB gui sample
%         %'GraphicUnit_export.m'. If use type int16, it complains cuz funcs
%         %like fft don't work on int type.
%     tag(frames)=0;
% 
%     for frame_count = 1:frames
% 
%         %Each frame has 4 byte header for frame number
%         [tag(frame_count),count] = fread(fid,1,'int32'); %STAUFFER changed to 'int32' from 'int' to be safe
%         %the acutal data...
%         [v,count] = fread(fid,w*h,'int16'); %STAUFFER changed to 'int16' from 'short' just to be safe
% 
%         RF(:,:,frame_count) = int16(reshape(v,h,w));
%         %disp([frame_count tag(frame_count)]); testing
%         %disp(['readRFfile: Min/Max: ' num2str(min(min(RF))) ' ' num2str(max(max(RF)))])
%     end
% 
%     %STAUFFER - removing this, and will just use returned array
%     %save(strcat(namewithoutext,'.mat'),'RF');
catch
    fclose(fid);
    error('UPenn:readRFfile',['Error processing file.' lasterr]);
end
disp('readFRfile: Done reading file.');


% Tony de Souza-Daw
% File Header - see Page 10 of Ultrasounix Manual
rf.type = tag1(1);      %int type; % data type (can be determined by file extensions)
rf.frames = tag1(2);    %int frames; % number of frames in file
rf.w = tag1(3);         %int w; % width (number of vectors for raw, image width for processed data)
rf.h = tag1(4);         %int h; % height (number of samples for raw, image height for processed data)
rf.ss = tag1(5);        %int ss; % data sample size in bits
rf.ulx = tag1(6);       %int ulx; % roi - upper left (x)
rf.uly = tag1(7);       %int uly;% roi - upper left (y)
rf.urx = tag1(8);       %int urx; % roi - upper right (x)
rf.ury = tag1(9);       %int ury; % roi - upper right (y)
rf.brx = tag1(10);      %int brx; % roi - bottom right (x)
rf.bry = tag1(11);      %int bry; % roi - bottom right (y)
rf.blx = tag1(12);      %int blx; % roi - bottom left (x)
rf.bly = tag1(13);      %int bly; % roi - bottom left (y)
rf.probe = tag1(14);    %int probe; % probe identifier - additional probe information can be found using this id
rf.txf = tag1(15);      %int txf; % transmit frequency in Hz
rf.sf = tag1(16);       %int sf; % sampling frequency in Hz
rf.dr = tag1(17);       %int dr; % data rate (fps or prp in Doppler modes)
rf.ld = tag1(18);       %int ld; % line density (can be used to calculate element spacing if pitch and native # elements is known
rf.extra = tag1(19);    %int extra; % extra information (ensemble for color RF)

%Data
rf.data = RF;
fclose(fid);

