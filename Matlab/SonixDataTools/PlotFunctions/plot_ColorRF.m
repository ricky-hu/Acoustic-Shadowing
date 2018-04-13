%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the color RF data saved by the Sonix systems
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_ColorRF(Data, Properties, Handle, Gain)

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
set(Handle, 'XTickLabel', repmat(num2str(Properties.w), Properties.extra, 1));        

% Drawing lines to separate the sequence of acquisitions of the same set of
% RF lines
for Cntr = 1:Properties.extra-1
    plot(Cntr*Properties.w*[1 1], [1 size(Data, 1)], 'Parent', Handle);
    text((Cntr-1)*Properties.w, -1/50*size(Data, 1), strcat('Rep ', num2str(Cntr)), 'Parent', Handle, 'Color', 'b');
end
text(Cntr*Properties.w, -1/50*size(Data, 1), strcat('Rep ', num2str(Cntr+1)), 'Parent', Handle, 'Color', 'b');

hold(Handle, 'off');

set(Handle,'CLim', Gain*get(Handle,'CLim'));
end