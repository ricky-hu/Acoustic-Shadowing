%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the 32bit XRGB data saved by the Sonix systems
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_BColor(Data, Properties, Handle)

% Converting the XRGB data to R and G and B channerls
R = bitshift(bitshift(uint32(Data),  8), -24);
G = bitshift(bitshift(uint32(Data), 16), -24);
B = bitshift(bitshift(uint32(Data), 24), -24);
I = uint8(zeros([size(Data) 3]));
I(:, :, 1) = uint8(R);
I(:, :, 2) = uint8(G);
I(:, :, 3) = uint8(B);

% Dislaying the RF data sequence
imagesc(I, 'Parent', Handle);
axis(Handle, 'equal');
axis(Handle, 'tight');
end