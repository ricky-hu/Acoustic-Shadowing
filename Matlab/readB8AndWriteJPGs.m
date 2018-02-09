%% Author Jorden Hetherington
%% Date: Feb 17, 2016
%% Read a .b8 file (from Ultrasonix machine) and write all the frames as jpgs in the fullFileName\jpgs folder

function readB8AndWriteJPGs(filename, baseFileName_NoExtension, outputDir, displaySomeImages)

    fid= fopen(filename, 'r');
    fileExt = filename(end-3:end);

    if( fid == -1)
        error('Cannot open file');
    end

    % read the header info
    hinfo = fread(fid, 19, 'int32');

    % load the header information into a structure and save under a separate file
    header = struct('filetype', 0, 'nframes', 0, 'w', 0, 'h', 0, 'ss', 0, 'ul', [0,0], 'ur', [0,0], 'br', [0,0], 'bl', [0,0], 'probe',0, 'txf', 0, 'sf', 0, 'dr', 0, 'ld', 0, 'extra', 0);
    header.filetype = hinfo(1);
    header.nframes = hinfo(2);
    header.w = hinfo(3);
    header.h = hinfo(4);
    header.ss = hinfo(5);
    header.ul = [hinfo(6), hinfo(7)];
    header.ur = [hinfo(8), hinfo(9)];
    header.br = [hinfo(10), hinfo(11)];
    header.bl = [hinfo(12), hinfo(13)];
    header.probe = hinfo(14);
    header.txf = hinfo(15);
    header.sf = hinfo(16);
    header.dr = hinfo(17);
    header.ld = hinfo(18);
    header.extra = hinfo(19);
    
%    ImArr = uint8(zeros(header.h,header.w,header.nframes));
%    enhanceImArr = zeros(header.h,header.w,header.nframes);

    v=[];

    if(header.filetype == 4) %postscan B .b8
        % read b8 data from file
        for frame_count = 1:header.nframes
            v = fread(fid,header.h*header.w,'uint8');
            temp = uint8(reshape(v,header.w,header.h));
            
			Im = temp';
			Imsingle = single(Im);
			
			ImOutputFile = strcat(outputDir, '\', baseFileName_NoExtension, '\Im', int2str(frame_count), '.jpg');
			imwrite(Im, ImOutputFile);

            %ImArr(:,:,frame_count) = temp';
            %Imsingle = single(ImArr(:,:,frame_count));
            %[~,enhanceIm] = bone_enhancement_jorden('asdf',Imsingle);
            %enhanceImArr(:,:,frame_count) = enhanceIm;
            
            if (displaySomeImages == 1) && ((mod(frame_count,100) == 0) || frame_count < 150)
				if (mod(frame_count,100) == 0) || (mod(frame_count,5) == 0 && frame_count < 50)
					frame_count %output count to user
				end
                figure(1)
                imshow(Im);
            end
        end
        return;
     else
        disp('Data not supported');
     end
        
    fclose(fid);

end


