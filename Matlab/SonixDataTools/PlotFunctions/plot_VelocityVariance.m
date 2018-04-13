%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the velocity variance data saved by the Sonix systems
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plot_VelocityVariance(Data, Properties, Handles)

% Dislaying the Velocity data
imagesc(Data(:,1:size(Data,2)/2), 'Parent', Handles(1));
colormap_(Handles(1), 'copper');
axis(Handles(1), 'equal');
axis(Handles(1), 'tight');

% Dislaying the Variance data
h = imagesc(Data(:,size(Data,2)/2+1:end), 'Parent', Handles(2));
colormap_(Handles(2), 'copper');
axis(Handles(2), 'equal');
axis(Handles(2), 'tight');
end