function data = GPSVolumeFileRead(filename)

fileExt = filename(end-3:end);

fid = fopen(filename, 'rb');
if( fid == -1)
    error('Cannot open file.');
end

if strcmp(fileExt,'.gtv')

    nFrames = fread(fid, 1, 'int');
    
    zero = zeros([nFrames, 1]);
    
    data.frameNumber = zero;    
    
    data.header.type = zero;
    data.header.w = zero;
    data.header.h = zero;
    data.header.ss = zero;
    data.header.roi = zeros([nFrames, 8]);
    data.header.bxangle = zero;
    
    data.tagged = zero;
    data.dx = zero;
    data.dy = zero;
    
    data.GPS.x = zero;
    data.GPS.y = zero;
    data.GPS.z = zero;
    data.GPS.a = zero;
    data.GPS.e = zero;
    data.GPS.r = zero;
    data.GPS.s = zeros([nFrames, 3, 3]);
    data.GPS.q = zeros([nFrames, 4]);
    data.GPS.time = zero;
    data.GPS.quality = zero;
  
    for i=1:nFrames
        data.frameNumber(i) = fread(fid, 1, 'int');

        data.header.type(i) = fread(fid, 1, 'int');
        data.header.w(i) = fread(fid, 1, 'int');
        data.header.h(i) = fread(fid, 1, 'int');
        data.header.ss(i) = fread(fid, 1, 'int');
        data.header.roi(i,:) = fread(fid, 8, 'int');
        data.header.bxangle(i) = fread(fid, 1, 'int');
        
        data.tagged(i) = fread(fid, 1, 'int');
        
        data.dx(i) = fread(fid, 1, 'double');
        data.dy(i) = fread(fid, 1, 'double');

        data.GPS.x(i) = fread(fid, 1, 'double');
        data.GPS.y(i) = fread(fid, 1, 'double');
        data.GPS.z(i) = fread(fid, 1, 'double');
        data.GPS.a(i) = fread(fid, 1, 'double');
        data.GPS.e(i) = fread(fid, 1, 'double');
        data.GPS.r(i) = fread(fid, 1, 'double');
        data.GPS.s(i,:,:) = fread(fid, [3 3], 'double');
        data.GPS.q(i,:) = fread(fid, 4, 'double');
        data.GPS.time(i,:) = fread(fid, 1, 'double');
        data.GPS.quality(i) = fread(fid, 1, 'int');
        
        fread(fid, 1, 'int');
        
        if (i==1)
            data.frames = zeros([nFrames, data.header.w(i), data.header.h(i)]);
        end
        
        data.frames(i,:,:) = fread(fid, [data.header.w(1), data.header.h(1)], 'unsigned char');
    end
    
elseif strcmp(fileExt,'.grv')
    
    n1 = fread(fid, 1, 'int')';
    n2 = fread(fid, 1, 'int')';
    n3 = fread(fid, 1, 'int')';
    data = fread(fid, n1*n2*n3, 'float')';
    data = reshape(data, [n1 n2 n3]);
    
else
    
    error('File extension not recongnized.');
    
end

fclose(fid);
