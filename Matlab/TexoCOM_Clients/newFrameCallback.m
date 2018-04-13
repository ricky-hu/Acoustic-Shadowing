%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An example callback fucntion for responding to the newFrameEvent of the
% TexoCOM server when acquiring data in real time.
%
% Copyright: Ultrasonix Medical Corporation Jan 2013
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newFrameCallback(varargin)

COM_Object_Sending_Event = varargin{1};

Event_ID        = varargin{2};
data            = varargin{3};
frameNumber     = varargin{4};
Event_Struct    = varargin{5};
Event_Name      = varargin{6};

data = reshape(data, [size(data,1)/128 128]);

figure(1)
subplot(1, 2 , 1);
imagesc(data);
colormap(gray);

title(num2str(frameNumber));

subplot(1, 2, 2);
plot(data(:, 64));

