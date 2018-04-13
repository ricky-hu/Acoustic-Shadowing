%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates the standard header which is created by the exam 
% software to save the data. This header is needed by SonixDataTools for
% properly displaying the data
%
% Copyright: Ultrasonix Medical Corporation Jan 2013
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = MakeHeader4CineData(arg1, type)

if ishandle(arg1)
    Ulterius_COM_Handle = arg1;
    MAX_ATTEMPT = 10;
    h           = Ulterius_COM_Handle;

    % Reading the number of frames in the cine from the COM server for the data type
    Attempt     = 1;
    nFrames     = -1;
    while and(Attempt< MAX_ATTEMPT, nFrames < 0)
        nFrames = h.getCineDataCount(type);
        Attempt = Attempt + 1;
    end
    if (nFrames<=0)
        header = [];
        return;
    end

    % Reading the data descriptor from the COM server
    Attempt     = 1;
    success     = 0;
    while and(Attempt< MAX_ATTEMPT, ~success)
        [success Descriptor] = invoke(h, 'getDataDescriptor', type);
        Attempt = Attempt + 1;
    end
    if (~success)
        header = [];
        return;
    end
else
    Descriptor = arg1;
    nFrames = 1;
end

header.filetype = Descriptor(1);
header.nframes  = nFrames;
header.w        = Descriptor(2);
header.h        = Descriptor(3);
header.ss       = Descriptor(4);
header.ul       = [Descriptor(5), Descriptor(6)];
header.ur       = [Descriptor(7), Descriptor(8)];
header.br       = [Descriptor(9), Descriptor(10)];
header.bl       = [Descriptor(11), Descriptor(12)];
header.probe    = 0;
header.txf      = 0;
header.sf       = 0;
header.dr       = 0;
header.ld       = 0;
header.extra    = 0;