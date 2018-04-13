% function to read escan data
% Julio Lobo (May 2014)

function [data, header] = ReadEscanData(filename)

fid = fopen(filename);

if fid < 0
    data = -1;
    return;
end

HEADER_SIZE_V1 = 6;

% read size of V1 header (subsequent versions should be at least this size)
header = fread(fid,HEADER_SIZE_V1,'int32')

switch header(1) % check the header version
    case 1 % version 1
    	dataType =  header(2);
        date =      header(3);
        tag =       header(4);
        numDims = 2;
        dims = zeros(numDims,1);
        dims(1) =     header(5); % width
        dims(2) =     header(6); % height
    case 2 % version 2
        dataType =  header(2);
        date =      header(3);
        tag =       header(4);
        numDims =   header(5);
        dims = zeros(numDims,1);
        % read the rest of the dimensions
        dims(2:end) = fread(fid,numDims-1,'int32'); % height, framesPerPlane, numPlanes, NUM_SWEEPS_PER_ACQ
        % keep the first dimension
        dims(1) =   header(6)% width
        % check if scan converted dimension is available, otherwise assume
        % the data was scan converted
        if numDims < 6
            scanConvert = 1;
        else
            scanConvert = dims(6);
        end
        % concatenate rest of dims with header
        header = [header;dims(2:end)];
    otherwise
        error('ReadEscanDataBlock: Unrecognized header version.');
end

% get the position of the start of the data
dataPos = ftell(fid);
% get the position of the end of the data
fseek(fid,0,'eof');
dataEnd = ftell(fid);

DataSize = dataEnd - dataPos;

fseek(fid,dataPos,'bof');

switch dataType
    case -1
        dataPrecision = 'int32';
        DataSize = DataSize/4;
    case 1 % RF
        dataPrecision = 'short';
        DataSize = DataSize/2
    case 2 % Bmode
        dataPrecision = 'uchar';
    case 13 % accelerometer
        dataPrecision = 'double';
        DataSize = DataSize/8;
    otherwise % all others
        dataPrecision = 'float';
        DataSize = DataSize/4;
end

data = fread(fid,DataSize, dataPrecision);

if dataType == 1 ... % RF data
        || dataType == 7 ... % time data is not scan converted
        || ~scanConvert
    data = reshape(data, dims(2), dims(1)+128,[]);
else
    data = reshape(data, dims(1), dims(2),[]);
    data = permute(data, [2 1 3]);
end

data = reshape(data,dims(1),dims(2),[]);
if dataType == 7 % displacement time data
    data = permute(data,[2 1 3]);
end

fclose(fid);