%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is a callback to respond to the newFrameEvent of the
% UlteriusCOM server. It reads the data, randomly changes the hue and then
% injects the data back into the exam software. You can change this file to
% do any processing you may need on your data
%
% Copyright: Ultrasonix Medical Corporation Jan 2013
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newFrameCallback_withInjection(varargin)

COM_Object_Sending_Event = varargin{1};

Event_ID        = varargin{2};
IM              = varargin{3};
TYPE            = varargin{4};
is_cine         = varargin{5};
frameNumber     = varargin{6};
Event_Struct    = varargin{7};
Event_Name      = varargin{8};

% Converting the XRGB data to R and G and B channerls
R = bitshift(bitshift(uint32(IM),  8), -24);
G = bitshift(bitshift(uint32(IM), 16), -24);
B = bitshift(bitshift(uint32(IM), 24), -24);
% I = uint8(zeros([size(IM) 3]));
% I(:, :, 1) = uint8(R);
% I(:, :, 2) = uint8(G);
% I(:, :, 3) = uint8(B);
% imagesc(I);

IM = R*rand(1)*2^16+G*rand(1)*2^8+B*rand(1);

assignin('base', 'IMOut', IM);
evalin('base', 'h.injectImage(int32(IMOut));');
