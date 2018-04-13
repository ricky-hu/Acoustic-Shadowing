%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function constructs a Sonix standard header for the DAQ data for
% compatibility with other data saved by Sonix research interface
%
% Usage: header = header4DAQ(hdr, RFFrame, ProbeNo)
% Input: hdr is the header coming from the readDAQ file and contains the
% number of frames, RFFrame is a typical frame, and ProbeNo is the ID of
% the probe
% Output: header is the Sonix standard header
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = header4DAQ(hdr, RFFrame, ProbeNo)
header.filetype = -2;
header.nframes = hdr(2);
header.w = size(RFFrame, 2);
header.h = hdr(3);
header.ss = 16;
header.ul = [0, 0];
header.ur = [0, 0];
header.br = [0, 0];
header.bl = [0, 0];
header.probe = ProbeNo;
header.txf = 0;
header.sf = 40e6;
header.dr = 0;
header.ld = size(RFFrame, 2);
header.extra = 0;
