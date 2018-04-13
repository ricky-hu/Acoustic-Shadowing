%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function displays some typical analyzed data
%
% Inputs:
% Data: the data in matlab array format (can be provided by RPread.m)
% Properties: the header of the file (can be provided by RPread.m)
% AnalysisType: the type of analysis to be performed on the data
% Handles: the handles to the [main axes, secondary axes] where the plots 
% are to be done
% Gain: adjusts the brightness of the grayscale images when applicable.
% Exta: extra parameters passed depending on the action to be performed.
% 
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rH = plot_AnalyzedData(Data, Properties, AnalysisType, Handles, Gain, Extra)

    switch (strcat(num2str(Properties.filetype), ',' , num2str(AnalysisType)))
        
        case {'2,1', '16,1','-2,1','4194304,1'} % Show single line
            % plot the selected line
            axes(Handles(1));
            hold(Handles(1), 'on');
            rH(1) = plot([Extra Extra], [1 size(Data, 1)], 'Parent',Handles(1));
            hold(Handles(1), 'off');
            % Plot the line data
            axes(Handles(2));
            rH(2) = plot(Data(:, Extra), 'Parent', Handles(2));
        
        case {'16,2'} % spectrum of RF line
            % plot the selected line
            axes(Handles(1));
            hold(Handles(1), 'on');
            rH(1) = plot([Extra Extra], [1 size(Data, 1)], 'Parent',Handles(1));
            hold(Handles(1), 'off');
            % Plot the line data
            axes(Handles(2));
            Spect = abs(fftshift(fft(Data(:, Extra))));
            Freqs = fftfreqs(size(Spect, 1))'*Properties.sf/1e6;
            rH(2) = plot(Freqs(fix((size(Freqs, 1)+1)/2):end), Spect(fix((size(Spect, 1)+1)/2):end), 'Parent', Handles(2));
            xlabel(Handles(2), 'MHz');
        
        case {'16,3'} % Convert RF to B-Mode
            axes(Handles(2));
            bmData = rf2bmode(Data);
            rH(2) = imagesc(bmData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;
        
        case {'2,2'} % Scan-converted B-Mode
            scData = scanconvert(Data, Extra(1), Extra(2), Extra(3), Extra(4));   % Scan converts the B-mode image        
            axes(Handles(2));
            rH(2) = imagesc((1:size(scData,2))/Extra(4),(1:size(scData,1))/Extra(4),scData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'equal');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;
            xlabel(Handles(2),'mm');
            ylabel(Handles(2),'mm');
        
        case {'128,1'} % Doppler RF data
            [IData, QData, spData] = dopplerrf2spectrum(squeeze(Data),Properties, true); % Derives the spectrum from the data with wall filter
            axes(Handles(2));
            rH(2) = imagesc(spData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;

        case {'128,2'} % Doppler RF data
            [IData, QData, spData] = dopplerrf2spectrum(squeeze(Data),Properties, false); % Derives the spectrum from the data without wall filter
            axes(Handles(2));
            rH(2) = imagesc(spData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;

        case {'128,3'} % Doppler RF data
            [IData, QData, spData] = dopplerrf2spectrum(squeeze(Data),Properties, true); % Derives the I/Q data from the data with wall filter
            axes(Handles(2));
            rH = plot(1000*(1:Properties.nframes)/Properties.dr,IData,1000*(1:Properties.nframes)/Properties.dr,QData, 'Parent', Handles(2)); 

        case {'128,4'} % Doppler RF data
            [IData, QData, spData] = dopplerrf2spectrum(squeeze(Data),Properties, false); % Derives the I/Q data from the data without wall filter
            axes(Handles(2));
            rH = plot(1000*(1:Properties.nframes)/Properties.dr,IData,1000*(1:Properties.nframes)/Properties.dr,QData, 'Parent', Handles(2)); 
            
        case {'512,1','512,2','512,3','512,4','512,5','512,6','512,7','512,8','512,9'} % Color doppler RF data
            [CFIData, CFIScale] = colorrf2flow(Data, Properties, Extra); % Performs different types of color flow imaging (CFI):
                                                                         % Velocity/Variance/Power Doppler ... Wall Filtered/Clutter/Thresholded
            axes(Handles(2));
            rH(2) = imagesc(CFIData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;            
        
        case {'1048576,1','1048576,2','1048576,3','1048576,4','1048576,5','1048576,6','1048576,7','1048576,8','1048576,9'} % Color doppler RF data
            [CFIData, CFIScale] = colorrf2flow(Data, Properties, Extra); % Performs different types of color flow imaging (CFI):
                                                                         % Velocity/Variance/Power Doppler ... Wall Filtered/Clutter/Thresholded
            axes(Handles(2));
            rH(2) = imagesc(CFIData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;   
            
        case{'-2,2','4194304,2'}  % DAQ data
            bfData = beamform(Data, 64, Extra);  % Performs the beamforming on the DAQ data
            axes(Handles(2));
            rH(2) = imagesc(bfData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim',  (1-Gain)/2 + Gain*get(Handles(2),'CLim'));
            rH(1) = -1;
        
        case{'-2,3','4194304,3'} % DAQ data beam-form and envelope detect
            bfData = beamform(Data, 64, Extra);  % Performs the beamforming on the DAQ data
            bmData = rf2bmode(bfData);
            axes(Handles(2));
            rH(2) = imagesc(bmData, 'Parent', Handles(2)); 
            colormap_(Handles(2), 'gray');
            axis(Handles(2), 'tight');
            set(Handles(2),'CLim', Gain*get(Handles(2),'CLim'));
            rH(1) = -1;
    end
    
end