%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is a callback to respond to the newFrameEvent of the
% UlteriusCOM server. It displays the data using the SonixDataTools
%
% Copyright: Ultrasonix Medical Corporation Jan 2013
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newFrameCallback(varargin)

COM_Object_Sending_Event = varargin{1};

Event_ID        = varargin{2};
IM              = varargin{3};
TYPE            = varargin{4};
is_cine         = varargin{5};
frameNumber     = varargin{6};
Event_Struct    = varargin{7};
Event_Name      = varargin{8};

%%%%%%%%%%%%%%%%%%%%%% Data Adjustments %%%%%%%%%%%%%%%%%%%%%%%
figure(1)
figHandles = get(figure(1), 'Children');
delete(figHandles);
axesHandle1 = axes;

% For the velocity/vector, the images are
% concatanated horizontally, instead of vertically
if sum(TYPE == [2048]) > 0
    IM = [IM(:,1:size(IM, 2)/2);
          IM(:,size(IM, 2)/2+1:end)];
end

% Scan Conversion causes the image to be transposed
if sum(TYPE == [1 4 8 64 256 1024 2048 4096 8192 16384]) > 0
    IM = IM';
end

% For displaying RF data, the color limits are adjusted for 
% better contrast
Gain = 1;
if sum(TYPE == [16]) > 0
    Gain = 0.1;
end

% For some algorithms, the data should be converted to the 
% double type
if sum(TYPE == [128]) > 0
    IM = double(IM);
end

% A second plot is needed for RF display and velocity/variance
axesHandle2 = 0;
if sum(TYPE == [128 2048]) > 0
    figure(2)
    axesHandle2 = axes;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Desc(1)       = TYPE;
    Desc(2)       = size(IM, 1);
    Desc(3)       = size(IM, 2);
    Desc(4)       = 8;
    Desc(5)       = 1;
    Desc(6)       = 1;
    Desc(7)       = 1;
    Desc(8)       = 1;
    Desc(9)       = 1;
    Desc(10)      = 1;
    Desc(11)      = 1;
    Desc(12)      = 1;
    Desc(13)      = 0;

% Making the header for the data needed by plot_SonixRP
DataHeader = MakeHeader4CineData(Desc, TYPE);

% Displaying the data using the plot_SonixRP function
if ~isempty(DataHeader)
    plot_SonixRP(IM, DataHeader, [axesHandle1 axesHandle2], Gain);
end
title(['Frame No ' num2str(frameNumber)]);
hold off
