%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function displays the main data types saved by the SonixRP
% research inteface
% Inputs:
% Data: the data in matlab array format (can be provided by RPread.m)
% Properties: the header of the file (can be provided by RPread.m)
% Handles(1): the Handles(1) to the axes where the plot is to be done
% Gain: adjusts the contrast of the image
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plot_SonixRP(Data, Properties, Handles, Gain)

% Usually the secondary axes are not used for any plots, except for the
% case of velocity/variance plots.
h = -1;

switch(Properties.filetype)
    
    case {4, 16777216} % scanconverted B Grayscale, 3D
        imagesc(Data, 'Parent', Handles(1)); 
        axis(Handles(1), 'equal');
        colormap_(Handles(1), 'gray');
        axis(Handles(1), 'tight');
        set(Handles(1),'CLim', Gain*get(Handles(1),'CLim'));

    case {2, 64, 32, 8388608} % prescanconverted B and M, 3D
        imagesc(Data, 'Parent', Handles(1));
        colormap_(Handles(1), 'gray');
        set(Handles(1),'CLim', Gain*get(Handles(1),'CLim'));
    
    case {-2, 16, 4194304}% RF, DAQ RF
        imagesc(Data, 'Parent', Handles(1));
        colormap_(Handles(1), 'gray');        
        set(Handles(1),'CLim', (1-Gain)/2 + Gain*get(Handles(1),'CLim'));
        
    case 128 % PW/CW RF
        plot((1-1/3:1/3:size(Data,1)+1/3),resample(Data, 3, 1), 'Parent', Handles(1));
        axis(Handles(1), [1 size(Data, 1) -2^13 2^13]);
        if ~isempty(get(Handles(2), 'Children'))
            h = get(Handles(2), 'Children');
        end
        
    case 256 % PW Spectrum
        imagesc(Data, 'Parent', Handles(1));
        colormap_(Handles(1), 'gray');        
        set(Handles(1),'CLim', Gain*get(Handles(1),'CLim'));
        
    case 512 % Color RF
        plot_ColorRF(Data, Properties, Handles(1), Gain);
    
    case {8, 1024, 8192} % scanconverted B + color Doppler
        plot_BColor(Data, Properties, Handles(1));
        
    case 2048
        h = plot_VelocityVariance(Data, Properties, Handles);
        
    case {16384, 32768} % Elastography overlay and midway processed
        imagesc(Data, 'Parent', Handles(1)); 
        axis(Handles(1), 'equal');
        colormap_(Handles(1), 'jet');
        axis(Handles(1), 'tight');
        
    case 131072 % GPS data
        axes(Handles(1));
        plot3(squeeze(Data.gps_posx),squeeze(Data.gps_posy),squeeze(Data.gps_posz));
        axis(Handles(1), 'equal');
   
    case 1048576 %.colmrf
        plot_ColorMRF(Data, Properties, Handles(1), Gain);
        
    case 2097152 % .mrf
        plot((1-1/3:1/3:size(Data,1)+1/3),resample(Data, 3, 1), 'Parent', Handles(1));
        axis(Handles(1), [1 size(Data, 1) -2^13 2^13]);
        if ~isempty(get(Handles(2), 'Children'))
            h = get(Handles(2), 'Children');
        end       
end