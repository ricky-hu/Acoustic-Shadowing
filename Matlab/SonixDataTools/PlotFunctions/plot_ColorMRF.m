%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the color m mode RF data saved by the Sonix systems
%
% Copyright: Ultrasonix Medical Corporation Oct 2013
% Author: Corina Leung, Software Team Lead Research & OEM,
% corina.leung@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_ColorMRF(Data, Properties, Handle, Gain)

% Changing the order of the indexes for display
Data1 = reshape(Data, [Properties.h Properties.extra Properties.w]);
Data2 = permute(Data1, [1 3 2]);
Data3 = reshape(Data2, size(Data));

% Dislaying the RF data sequence
imagesc(Data3, 'Parent', Handle);
colormap_(Handle, 'gray');

hold(Handle, 'on');     

% Using the appropriate tick labels to reflect the fact that the data
% represents multiple acquisitions of the same set of RF lines
set(Handle, 'XTick', [1:Properties.extra]*Properties.w);        

set(Handle,'CLim', Gain*get(Handle,'CLim'));
end