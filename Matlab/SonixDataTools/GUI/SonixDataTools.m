%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A gui for loading, displaying, and processing the data saved by SonixRP  
% and SonixTouch research interfaces
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = SonixDataTools(varargin)
% SONIXDATATOOLS M-file for SonixDataTools.fig
%      SONIXDATATOOLS, by itself, creates a new SONIXDATATOOLS or raises
%      the existing
%      singleton*.
%
%      H = SONIXDATATOOLS returns the handle to a new SONIXDATATOOLS or the handle to
%      the existing singleton*.
%
%      SONIXDATATOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONIXDATATOOLS.M with the given input
%      arguments.
%
%      SONIXDATATOOLS('Property','Value',...) creates a new SONIXDATATOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SonixDataTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SonixDataTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SonixDataTools

% Last Modified by GUIDE v2.5 21-Nov-2012 11:29:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SonixDataTools_OpeningFcn, ...
                   'gui_OutputFcn',  @SonixDataTools_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SonixDataTools is made visible.
function SonixDataTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SonixDataTools (see VARARGIN)
clc;
handles.ChosenLineH   = -1;
handles.SecondaryPlot = -1;
handles.Playing       = 0;

% Choose default command line output for SonixDataTools
handles.output = hObject;

% Pixels per mm for scan conversion
handles.PPMM = 2;

% Settting the default version
handles.version = '6.1.0';

% Settting the default probe used with DAQ
handles.DAQProbeID = 4;

% Setting the default SDK Path to look for the probes.xml file
handles.SDKPath = '..\';

% Working directory and file type
handles.WorkingDirectory  = '..\SampleData\';
handles.WorkingFileTypeI  = 1;

% Update handles structure
guidata(hObject, handles);

% Add paths for functions
addpath('..\DataReaders\RPread');
addpath('..\DataReaders\DAQ');

addpath('..\ImageProcessing');
addpath('..\ImageProcessing\PW');
addpath('..\ImageProcessing\CFI');
addpath('..\ImageProcessing\BeamForming');

addpath('..\PlotFunctions');

addpath('..\UltrasonixLegacy\UltrasoundGUI');

addpath('..\Misc');

% --- Outputs from this function are returned to the command line.
function varargout = SonixDataTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function uipushtool_OpenFile_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Fixing the column width of the header info table
set(handles.table_HeaderInfo, 'Units', 'pixels');
temp = get(handles.table_HeaderInfo, 'Position');
set(handles.table_HeaderInfo, 'columnWidth', {temp(3)/2-2, temp(3)/2-2});
set(handles.table_HeaderInfo, 'Units', 'normal');
% Convert the string version to numeric value
inds      = regexp(handles.version, '\.');
vMajor    = str2double(handles.version(1:inds(1)-1));
vMinor    = str2double(handles.version(inds(1)+1:inds(2)-1));
vSubMinor = str2double(handles.version(inds(2)+1:end));
version   = vMajor * 100 * 100 + vMinor * 100 + vSubMinor;
if version >= 60003
    tempStringGPS1 = '*.gps1;*.gps2'; tempStringGPS2 = 'GPS data (*.gps1 or *.gps2)';
else
    tempStringGPS1 = '*.gps'; tempStringGPS2 = 'GPS data (*.gps)';
end
if version < 40000
    tempStringCVV1 = '*.cw'; tempStringCVV2 = 'Color: Velocity/Variance Scan Converted (*.cw)';
else
    tempStringCVV1 = '*.cvv'; tempStringCVV2 = 'Color: Velocity/Variance Scan Converted (*.cvv)';
end
% Get the file name from the user
fileTypeList = {
     '*.b32', 'B: Scan Converted 32 bit (*.b32)';           % 1
     '*.b8' , 'B: Scan Converted 8 bit (*.b8)';             % 2
     '*.bpr', 'B: Pre Scan Converted (*.bpr)';              % 3
     '*.rf' , 'B: RF Post Beam Formed (*.rf)';              % 4
     '*.m'  , 'M: Scan Converted (*.m)';                    % 5
     '*.mpr', 'M: Pre Scan Converted (*.mpr)';              % 6
     '*.mrf', 'M: RF Post Beam Formed (*.mrf)';             % 7
     '*.pw',  'PW: Spectrum (*.pw)';                        % 8
     '*.drf', 'PW/CW: RF Post Beam Formed (*.drf)';         % 9
     '*.col', 'Color: Color+B Scan Converted (*.col)';      % 10
     tempStringCVV1, tempStringCVV2;                        % 11
     '*.crf', 'Color: RF Post Beam Formed (*.crf)';         % 12
     '*.el',  'Elasto: Elasto+B Scan Converted (*.el)';     % 13
     '*.elo', 'Elasto: Overlay (*.elo)';                    % 14
     '*.epr', 'Elasto: Pre Scan Converted (*.epr)';         % 15
     '*.ecg', 'ECG data (*.ecg)';                           % 16
     '*.colmrf', 'ColorM: RF Post Beam Formed (*.colmrf)';  % 17
     tempStringGPS1, tempStringGPS2;                        % 18
     '*.daqrf', 'DAQ: RF Pre Beam Formed (*.daqrf)';        % 19
     '*.daq', 'SonixDAQ data FROM SDK (*.daq)';             % 20
     '*.3dd', '3D: Pre Scan Converted (*.3dd)';             % 21
     '*.3dv', '3D: Post Scan Converted (*.3dv)';            % 22
     };
[FileName, PathName, FileTypeSel] = uigetfile(fileTypeList,...
    'Open a SonixRP Compatible File', ...
    [handles.WorkingDirectory '\' fileTypeList{handles.WorkingFileTypeI, 1}]);
% Make sure the user selected a FileName
if (FileTypeSel == 0)
    return;
end
% Matlab has a bug and cannot detect the correct FileTypeSel, if the filter
% is preselected through the third parameter passed in in the uigetfile()
% function. Some gymnastics is needed to overcome Matlab's incompetence
myFileTypeSel = 0;
for Cntr1 = 1:size(fileTypeList, 1)
    extensionStartCharIndex = regexp(fileTypeList{Cntr1, 1}, '\*\.[^;]*');
    for Cntr2 = 1:size(extensionStartCharIndex, 2) - 1
        if ~isempty(strfind(FileName, fileTypeList{Cntr1, 1}(extensionStartCharIndex(Cntr2) + ...
            2:extensionStartCharIndex(Cntr2 + 1) - 1)))
            myFileTypeSel = Cntr1;
            break;
        end
    end
    if ~isempty(strfind(FileName, fileTypeList{Cntr1, 1}(extensionStartCharIndex(end) + 2:end)))
        myFileTypeSel = Cntr1;
    end
    if myFileTypeSel == Cntr1
        break;
    end
end
if and(FileTypeSel ~= myFileTypeSel, myFileTypeSel ~=0)
    FileTypeSel = myFileTypeSel;
end    
% Storing the selected file type and directory for ease of coming back
handles.WorkingDirectory = PathName;
handles.WorkingFileTypeI = FileTypeSel;
% Read the data from the disk into memory
handles.FileName = [PathName FileName];
switch FileTypeSel
    case 20  % DAQ data
        % Convert the string version to numeric value
        inds      = regexp(handles.version, '\.');
        vMajor    = str2double(handles.version(1:inds(1)-1));
        vMinor    = str2double(handles.version(inds(1)+1:inds(2)-1));
        vSubMinor = str2double(handles.version(inds(2)+1:end));
        version   = vMajor * 100 * 100 + vMinor * 100 + vSubMinor;
        if version < 60000
            [hdr, RFframe] = readDAQ5(PathName, ones(1,128), 1, true);
        else
            [hdr, RFframe] = readDAQ6(PathName, ones(1,128), 1, true);
        end
        handles.header = header4DAQ(hdr, RFframe, handles.DAQProbeID);
        handles.Data = zeros(handles.header.h,handles.header.w,handles.header.nframes);
        for Cntr = 1:handles.header.nframes
            if version < 60000
                [hdr, RFframe] = readDAQ5(PathName, ones(1,128), Cntr, true);
            else
                [hdr, RFframe] = readDAQ6(PathName, ones(1,128), Cntr, true);
            end
            handles.Data(:,:,Cntr) = RFframe;
        end
    case {15,16} % pre scan converted elastography and ECG data missing.
        h = warndlg({'There is a known issue with this type of file which will be addressed in future releases of the Sonix software'}, 'modal');
        uiwait(h);
        return;
    case 18 % GPS data
        if (handles.FileName(end)=='s')
            h = warndlg({'The file you are opening is a .gps file, which was saved with a version of Sonix prior to 6.0.3',...
                         'There are now known issues with the data saved by these versions, which have been resolved in 6.0.3'}, 'modal');
            uiwait(h);
            [handles.Data, handles.header] = RPread(handles.FileName, handles.version);
        else
            [handles.Data, handles.header] = RPread(handles.FileName, handles.version);
        end
    otherwise
        [handles.Data, handles.header] = RPread(handles.FileName, handles.version);
end
% Read the probe data from the probes.xml file
handles.ProbeStruct = readprobe([handles.SDKPath '\probes.xml'], handles.header.probe);
% If the reading was successful, the gui is updated by opening a panel
if (~isempty(handles.header))
    if (handles.header.filetype ~= -2) % Anything except the DAQ
        set(handles.panel_FileName, 'Title', [PathName FileName]);
    else % for the DAQ data, a bunch of files are opened actually
        set(handles.panel_FileName, 'Title', [PathName 'all the files from CH000.daq to CH127.daq']);
    end
    set(handles.panel_FileName, 'Visible', 'on');
    handles.Playing = false;     
    % If there is more than one frame the slider and play/stop botton are
    % displayed
    if (size(handles.Data, 3) > 1)
        set(handles.slider_FrameSelector, 'Visible', 'on');
        set(handles.pushbutton_PlayPause, 'Visible', 'on');
        set(handles.slider_FrameSelector, 'Value', 1);
        set(handles.slider_FrameSelector, 'Min', 1);
        set(handles.slider_FrameSelector, 'Max', size(handles.Data, 3));             
    else
        set(handles.slider_FrameSelector, 'Visible', 'off');
        set(handles.slider_FrameSelector, 'Value', 1);
        set(handles.slider_FrameSelector, 'Min', 1);
        set(handles.slider_FrameSelector, 'Max', 1);             
        set(handles.pushbutton_PlayPause, 'Visible', 'off');       
    end
else
    error('The header is empty');
end
% Setting up the table which contains the header information
handles = fillTable(handles);
% Main display
tempH = plot_SonixRP(handles.Data(:, :, 1),...
                     handles.header ,...
                     [handles.axes_MainArea handles.axes_SecondaryArea],...
                     1-get(handles.slider_MainGain, 'Value'));
switch(handles.header.filetype)
    case {2, 4, 16, 64, 256, 512, 1048576, -2, 4194304}
        set(handles.slider_MainGain, 'Visible', 'on');
    otherwise
        set(handles.slider_MainGain, 'Value', 0.0);
        set(handles.slider_MainGain, 'Visible', 'off');
end         

% Clearing the secondary plot
set(handles.togglebutton_ShowHide,'Value', get(handles.togglebutton_ShowHide,'Min'));
if (ishandle(handles.ChosenLineH))
    delete(handles.ChosenLineH);
end
if (ishandle(handles.SecondaryPlot))
    delete(handles.SecondaryPlot);
end
if (ishandle(tempH))
    handles.SecondaryPlot = tempH;
else   
    set(handles.axes_SecondaryArea, 'Visible', 'off');
    set(handles.slider_SecondaryGain, 'Visible', 'off');
end
% Prepare the appropriate menu items based on the type of the data that 
% has been read
handles = setupSecondaryPlot(handles);
% Update handles structure
guidata(hObject, handles);
 

% --- Executes during object creation, after setting all properties.
function slider_FrameSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_FrameSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_PlayPause.
function pushbutton_PlayPause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PlayPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Since different processing steps require different amount of time, the
% frame rate of the play back is determined by the type of processing
% selected
if (get(handles.togglebutton_ShowHide,'Value') == get(handles.togglebutton_ShowHide,'Max'))
    switch (strcat(num2str(handles.header.filetype), ',' , num2str(get(handles.popupmenu_Analyze, 'Value'))))
        case {'2,1', '16,1', '16,2', '-2,1', '4194304,1'} % Show single line
            Period = 0.5;
        case {'16,3', '2,2'} % Convert RF to B-Mode
            Period = 1.0;
        case {'16,4'} % Raw RF gui
            Period = 0.3;
        case {'128,1','128,2','128,3','128,4','2097152,1'} % Raw RF gui (single spectrum)
            Period = 0.1;
        case {'512,1','512,2','512,3','512,4','512,5','512,6','512,7','512,8','512,9'} % CFI: colour flow imaging
            Period = 1.5;
        case {'1048576,1'} % ColM RF
            Period = 1.5;
        case {'-2,2','-2,3','4194304,2','4194304,3'}
            Period = 2.0;
        otherwise
            Period = 3.0;
    end
else
    if (handles.header.filetype == 128)
        Period = 0.1;
    else
        Period = 0.3;
    end
end
% If the movie is running stop it, else start it
if (handles.Playing)
    stop(handles.timer);
    delete(handles.timer);
    handles.Playing = false;
    set(handles.togglebutton_ShowHide, 'Enable', 'on');
else
    handles.timer = timer('TimerFcn',{@timer_Callback, hObject}, 'Period', Period , 'ExecutionMode', 'fixedRate');
    % Update handles structure
    guidata(hObject, handles);
    start(handles.timer);
    handles.Playing = true;
    set(handles.togglebutton_ShowHide, 'Enable', 'off');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_CloseFile.
function pushbutton_CloseFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CloseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.panel_FileName, 'Title', '');
for hPlots = get(handles.axes_MainArea, 'Children')
    delete(hPlots);
end
set(handles.axes_MainArea, 'Visible', 'off');
set(handles.slider_FrameSelector, 'Visible', 'off');
set(handles.panel_FileName, 'Visible', 'off');
set(handles.pushbutton_PlayPause, 'Visible', 'off');
if (handles.Playing)
    stop(handles.timer);
    delete(handles.timer);
    handles.Playing = false;
end
% Clearing the secondary plot
set(handles.togglebutton_ShowHide,'Value', get(handles.togglebutton_ShowHide,'Min'));
if (ishandle(handles.ChosenLineH))
    delete(handles.ChosenLineH);
end
if (ishandle(handles.SecondaryPlot))
    delete(handles.SecondaryPlot);
end
set(handles.axes_SecondaryArea, 'Visible', 'off');
set(handles.slider_SecondaryGain, 'Visible', 'off');
% Update handles structure
guidata(hObject, handles);

% ******** ******** ******** ******** ******** ******** ******** ******** 
% ******** ********  Main functions which cause a drawing ****** ******** 
% ******** ******** ******** ******** ******** ******** ******** ******** 
% This function is called with the timer and loops through the sequence of
% images
function timer_Callback(timerobj, timerevent, hObject)
% get the gui handles
handles = guidata(hObject);
% find the current frame from the slider
FrameNo = fix(get(handles.slider_FrameSelector, 'Value'));
% increment the current frame and loop around
if (FrameNo + 1 > get(handles.slider_FrameSelector, 'Max'))
    FrameNo = 1;
else
    FrameNo = FrameNo + 1;
end
% update the slider
set(handles.slider_FrameSelector, 'Value', FrameNo);
% Main display
tempH = plot_SonixRP(handles.Data(:, :, FrameNo),...
                     handles.header ,...
                     [handles.axes_MainArea handles.axes_SecondaryArea],...
                     1-get(handles.slider_MainGain, 'Value'));                 
% Secondary display
if (handles.header.filetype ~= 128) % No need to update Doppler spectrum
    handles = DisplaySecondary(handles, FrameNo);
end
if (ishandle(tempH))
    handles.SecondaryPlot = tempH;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in togglebutton_ShowHide.
function togglebutton_ShowHide_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_ShowHide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_ShowHide

% If the movie is running take no action
if (handles.Playing)
    return
end
% Deciding on the frame no
if (size(handles.Data, 3) > 1)
        FrameNo = round(get(handles.slider_FrameSelector, 'Value'));
    else
        FrameNo = 1;
end    
% Decision tree to make an action based on the selection of the user from
% the gui when the Analyze button is pressed
if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.popupmenu_Analyze, 'Enable', 'off');   
    switch (strcat(num2str(handles.header.filetype), ',' , num2str(get(handles.popupmenu_Analyze, 'Value'))))
        case {'2,1', '16,1', '16,2', '-2,1', '4194304,1'} % Show single line
            h = msgbox('Please select a line you want to display from the left plot', 'modal');
            uiwait(h);            
            % Give the user the gui to pick a line on the main axes
            axes(handles.axes_MainArea);
            [x, y] = ginput(1);
            handles.ChosenLine = round(x);
            % Secondary display
            handles = DisplaySecondary(handles, FrameNo);     
        case {'16,4'} % No need for a secondary display, just open the rf processing gui
            handles.SecondaryPlot = GraphicUnit_export([],handles.FileName, FrameNo, handles.version);
            pParent = get(handles.figure1, 'Position');
            set(handles.SecondaryPlot, 'Position', [pParent(1)+0.05*pParent(3) pParent(2)+0.15*pParent(4) 0.8*pParent(3) 0.8*pParent(4)]);
        case {'-2,2', '-2,3'} % Warning about the DAQ beam-forming
            if (handles.DAQProbeID ~= 2)
                h = warndlg({'Please note that beamforming is ONLY MEANINGFUL when the details of the transmitted geometry is known to the beamformer!'...
                             'Please choose the correct probe from the Settings menu.'}, 'modal');
                uiwait(h);
                set(handles.togglebutton_ShowHide, 'Value', get(handles.togglebutton_ShowHide,'Min'));
                set(handles.axes_SecondaryArea, 'Visible', 'off');
                set(handles.popupmenu_Analyze, 'Enable', 'on');
                set(handles.slider_SecondaryGain, 'Visible', 'off');
            else
                % Secondary display
                handles = DisplaySecondary(handles, FrameNo);                 
            end
        otherwise
            % Secondary display
            handles = DisplaySecondary(handles, FrameNo);                 
    end
else
    if (ishandle(handles.ChosenLineH))
        delete(handles.ChosenLineH);
    end
    if (ishandle(handles.SecondaryPlot))
        delete(handles.SecondaryPlot);
    end
    set(handles.axes_SecondaryArea, 'Visible', 'off');
    set(handles.popupmenu_Analyze, 'Enable', 'on');
    set(handles.slider_SecondaryGain, 'Visible', 'off');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
function slider_FrameSelector_Callback(hObject, eventdata, handles)
% hObject    handle to slider_FrameSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% If the movie is running take no action
if (handles.Playing)
    return
end
% Deciding on the frame no
if (size(handles.Data, 3) > 1)
        FrameNo = round(get(handles.slider_FrameSelector, 'Value'));
    else
        FrameNo = 1;
end
% Main display
tempH = plot_SonixRP(handles.Data(:, :,  FrameNo),...
                     handles.header ,...
                     [handles.axes_MainArea handles.axes_SecondaryArea],...
                     1-get(handles.slider_MainGain, 'Value'));
% Secondary display
if (handles.header.filetype ~= 128) % No need to update Doppler spectrum
    handles = DisplaySecondary(handles, FrameNo);
end
if (ishandle(tempH))
    handles.SecondaryPlot = tempH;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
function slider_MainGain_Callback(hObject, eventdata, handles)
% hObject    handle to slider_MainGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If the movie is running take no action
if (handles.Playing)
    return
end
% Main display
tempH = plot_SonixRP(handles.Data(:, :, fix(get(handles.slider_FrameSelector, 'Value'))),...
                     handles.header ,...
                     [handles.axes_MainArea handles.axes_SecondaryArea],...
                     1-get(handles.slider_MainGain, 'Value'));
if (ishandle(tempH))
    handles.SecondaryPlot = tempH;
end                
% Update handles structure
guidata(hObject, handles);

% --- Executes on slider movement.
function slider_SecondaryGain_Callback(hObject, eventdata, handles)
% hObject    handle to slider_SecondaryGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If the movie is running take no action
if (handles.Playing)
    return
end
% Deciding on the frame no
if (size(handles.Data, 3) > 1)
        FrameNo = round(get(handles.slider_FrameSelector, 'Value'));
    else
        FrameNo = 1;
end
% Secondary display
handles = DisplaySecondary(handles, FrameNo);
% set(handles.axes_SecondaryArea,'CLim', (1-get(handles.slider_SecondaryGain, 'Value'))*get(handles.axes_SecondaryArea,'CLim'));
% Update handles structure
guidata(hObject, handles);
% ******** ******** ******** ******** ******** ******** ******** ******** 
% ******** ******** ******** ******** ******** ******** ******** ******** 
% ******** ******** ******** ******** ******** ******** ******** ******** 

% --- Executes on selection change in popupmenu_Analyze.
function popupmenu_Analyze_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_Analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_Analyze contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_Analyze


% --- Executes during object creation, after setting all properties.
function popupmenu_Analyze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_Analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider_MainGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_MainGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider_SecondaryGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_SecondaryGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%--------------------------------------------------------------------------
function handles = fillTable(handles)
    TempCell = {};
    TempCell{1, 1} = 'File Type';
    TempCell{2, 1} = 'No. of Frames';
    TempCell{3, 1} = 'Width';
    TempCell{4, 1} = 'Height';
    TempCell{5, 1} = 'Sample Size';
    TempCell{6, 1} = 'Upper left';
    TempCell{7, 1} = 'Upper right';
    TempCell{8, 1} = 'Bottom right';
    TempCell{9, 1} = 'Bottom left';
    TempCell{10, 1}= 'Probe ID';
    TempCell{11, 1}= 'Tx Freqency';
    TempCell{12, 1}= 'Sampling Freq';
    TempCell{13, 1}= 'Pulse Rep Freq';
    TempCell{14, 1}= 'Line Density';
    TempCell{15, 1}= 'Extra Info';
    TempCell{16, 1}= '-----------------';
    TempCell{17, 1}= 'Probe name';
    TempCell{18, 1}= 'Num of elements';
    TempCell{19, 1}= 'Lateral radius';
    TempCell{20, 1}= 'Element pitch';
    TempCell{21, 1}= '-----------------';
    TempCell{22, 1}= 'Imaging depth';
    
    TempCell{2, 2} = num2str(handles.header.nframes);
    TempCell{3, 2} = num2str(handles.header.w);
    TempCell{4, 2} = num2str(handles.header.h);
    TempCell{5, 2} = strcat(num2str(handles.header.ss),' bits');
    TempCell{6, 2} = strcat('[',num2str(handles.header.ul(1)),',',num2str(handles.header.ul(2)),']');
    TempCell{7, 2} = strcat('[',num2str(handles.header.ur(1)),',',num2str(handles.header.ur(2)),']');
    TempCell{8, 2} = strcat('[',num2str(handles.header.br(1)),',',num2str(handles.header.br(2)),']');
    TempCell{9, 2} = strcat('[',num2str(handles.header.bl(1)),',',num2str(handles.header.bl(2)),']');
    TempCell{10, 2}= num2str(handles.header.probe);
    TempCell{11, 2}= strcat(num2str(handles.header.txf/1e6), ' MHz');
    TempCell{12, 2}= strcat(num2str(handles.header.sf/1e6), ' MHz');
    TempCell{13, 2}= strcat(num2str(handles.header.dr/1e3), ' kHz');
    TempCell{14, 2}= num2str(handles.header.ld);
    TempCell{15, 2}= num2str(handles.header.extra);
    TempCell{16, 2}= '-----------------';
    TempCell{17, 2}= handles.ProbeStruct.name;
    TempCell{18, 2}= num2str(handles.ProbeStruct.numElements);
    TempCell{19, 2}= strcat(num2str(handles.ProbeStruct.radius*1e-3), ' mm');
    TempCell{20, 2}= strcat(num2str(handles.ProbeStruct.pitch), ' um');
    TempCell{21, 2}= '-----------------';
    TempCell{22, 2}= strcat(num2str(handles.header.h/handles.header.sf*1540/2 * 1e3) , ' mm');
    switch (handles.header.filetype)
        case 2
            TempCell{1, 2} = 'B:PreScanConverted';
        case 4
            TempCell{1, 2} = 'B:ScanConverted';
        case 8
            TempCell{1, 2} = 'B:ScanConverted';
        case 16
            TempCell{1, 2} = 'RF:PostBeamformed';
        case 32
            TempCell{1, 2} = 'M:PreScanConverted';
        case 64
            TempCell{1, 2} = 'M:ScanConverted';
        case 128
            TempCell{1, 2} = 'PW/CW RF';
        case 256
            TempCell{1, 2} = 'PW Spectrum';
        case 512
            TempCell{1, 2} = 'Color RF';
        case 1024
            TempCell{1, 2} = 'Color+B Image';
        case 2048
            TempCell{1, 2} = 'Color';
        case 4096
            TempCell{1, 2} = 'Color Velocity/Variance';
        case 8192
            TempCell{1, 2} = 'Elasto+B Image';
        case 16384
            TempCell{1, 2} = 'Elasto Overlay';
        case 32768
            TempCell{1, 2} = 'Elasto Pre Scan Converted';
        case 65536
            TempCell{1, 2} = 'ECG data';
        case {131072, 262144}
            TempCell{1, 2} = 'GPS data';
        case {524288}
            TempCell{1, 2} = 'Timestamp data';
        case 1048576
            TempCell{1, 2} = 'ColorM RF data';
        case 2097152
            TempCell{1, 2} = 'M RF data';
        case 4194304
            TempCell{1, 2} = 'DAQ RF data';
        case 8388608
            TempCell{1, 2} = '3D:PreScanConverted';
        case 16777216
            TempCell{1, 2} = '3D:ScanConverted (Reconstructed)';
    end
    set(handles.table_HeaderInfo, 'Data', TempCell);
%--------------------------------------------------------------------------
function handles = setupSecondaryPlot(handles)
    TempCell = {};
    switch (handles.header.filetype)
        case 2 % B:PreScanConverted
            TempCell{1, 1} = 'Show single scan line';
            TempCell{2, 1} = 'Scan convert';
        case 4 % B:ScanConverted GrayScale
            TempCell{1, 1} = '';
        case 8 % B:ScanConverted RGB
            TempCell{1, 1} = '';
        case 16 % RF:PostBeamformed
            TempCell{1, 1} = 'Show single RF-line';
            TempCell{2, 1} = 'Show spectrum of single RF-line';
            TempCell{3, 1} = 'Convert to pre-scan-converted B-Mode';
            TempCell{4, 1} = 'Process with Raw RF processing GUI';
        case 32 % M:PreScanConverted
            TempCell{1, 1} = '';
        case 64 % M:ScanConverted
            TempCell{1, 1} = '';
        case 128 % PW/CW RF
            TempCell{1, 1} = 'Convert to Doppler spectrum (with wall filter)';
            TempCell{1, 2} = 'Convert to Doppler spectrum (w/o wall filter)';
            TempCell{1, 3} = 'Convert to I/Q data (with wall filter)';
            TempCell{1, 4} = 'Convert to I/Q data (w/o wall filter)';
        case 256 % PW Spectrum
            TempCell{1, 1} = '';
        case 512 % Color RF
            TempCell{1, 1} = 'Convert to Velocity Wall Filtered';
            TempCell{2, 1} = 'Convert to Velocity Clutter';
            TempCell{3, 1} = 'Convert to Thresholded Velocity';
            TempCell{4, 1} = 'Convert to Variance Wall Filtered';
            TempCell{5, 1} = 'Convert to Variance Clutter';
            TempCell{6, 1} = 'Convert to Thresholded Variance';
            TempCell{7, 1} = 'Convert to Power Doppler Wall Filtered';
            TempCell{8, 1} = 'Convert to Power Doppler Clutter';
            TempCell{9, 1} = 'Convert to Thresholded Power Doppler';
        case 1024 % Color+B Image
            TempCell{1, 1} = '';
        case 2048 % Color
            TempCell{1, 1} = '';
        case 4096 % Color Velocity/Variance
            TempCell{1, 1} = '';
        case 8192 % Elasto+B Image
            TempCell{1, 1} = '';
        case 16384 % Elasto Overlay
            TempCell{1, 1} = '';
        case 32768 % Elasto Pre Scan Converted
            TempCell{1, 1} = '';
        case 65536 % ECG data
            TempCell{1, 1} = '';
        case {131072, 262144} % GPS data
            TempCell{1, 1} = '';
        case {524288} % time stamp data
            TempCell{1, 1} = '';
        case 1048576 % ColorM RF data
            TempCell{1, 1} = '';
        case 2097152 % M RF data
            TempCell{1, 1} = '';
        case 4194304 % DAQ RF data
            TempCell{1, 1} = 'Show single scan line';
            TempCell{1, 2} = 'Convert to beam-formed RF';
            TempCell{1, 3} = 'Beam-form, envelope detect, and log compress';
        case 8388608 % 3D PreScanConverted
            TempCell{1, 1} = '';
        case 16777216 % 3D ScanConverted 
            TempCell{1, 1} = 'Surface Render';
        case -2 % DAQ data
            TempCell{1, 1} = 'Show single scan line';
            TempCell{1, 2} = 'Convert to beam-formed RF';
            TempCell{1, 3} = 'Beam-form, envelope detect, and log compress';
        otherwise
            TempCell{1, 1} = '';
    end
    set(handles.popupmenu_Analyze, 'Value', 1);
    set(handles.popupmenu_Analyze, 'String', TempCell);
    set(handles.popupmenu_Analyze, 'Enable', 'on');    
    if and(sum(size(TempCell) == [1, 1]) == 2, isempty(TempCell{1,1}))
        set(handles.popupmenu_Analyze, 'Visible', 'off');
        set(handles.togglebutton_ShowHide, 'Visible', 'off');
    else
        set(handles.popupmenu_Analyze ,'Visible', 'on');
        set(handles.togglebutton_ShowHide, 'Visible', 'on');
    end


function handles = DisplaySecondary(handles, FrameNo)
% Secondary display
if (get(handles.togglebutton_ShowHide,'Value') == get(handles.togglebutton_ShowHide,'Max'))  % The Analyze button is down
    switch (strcat(num2str(handles.header.filetype), ',' , num2str(get(handles.popupmenu_Analyze, 'Value'))))
        case {'2,1', '16,1', '16,2', '-2,1', '4194304,1'}    % Show single line
            Extra    = handles.ChosenLine;
            tempData = handles.Data(:, :, FrameNo); 
        case{'2,2'}                     % Scan convert the b-mode data
            Extra    = [handles.header.h/handles.header.sf*1540/2/size(handles.Data,1), ...
                        handles.ProbeStruct.pitch*1e-6*handles.ProbeStruct.numElements/handles.header.w, ...
                        handles.ProbeStruct.radius*1e-6, ...
                        handles.PPMM];            % The physical dimensions of the image   
            tempData = handles.Data(:, :, FrameNo); 
        case {'16,3'}                   % Convert RF to B-Mode
            Extra    = 0;
            tempData = handles.Data(:, :, FrameNo);
        case{'128,1','128,2','128,3','128,4'}           % Convert Doppler RF to Doppler spectrum
            Extra    = FrameNo;
            tempData = handles.Data;
        case{'512,1','512,2','512,3','512,4','512,5','512,6','512,7','512,8','512,9'} 
                                        % Velocity/Variance/Power Doppler ... Wall Filtered/Clutter/Thresholded
            Extra    = get(handles.popupmenu_Analyze, 'Value');  % The type of image to be generated
            tempData = handles.Data(:, :, FrameNo);       
        case{'-2,2','-2,3','4194304,2','4194304,3'}                    % Beam-forming the RF data
            Extra    = handles.ProbeStruct;
            tempData = handles.Data(:, :, FrameNo);
    end
    % Analyzing and plotting the data on the secondary axes
    tempH = plot_AnalyzedData(tempData,...
                              handles.header , ...
                              get(handles.popupmenu_Analyze, 'Value'), ...
                              [handles.axes_MainArea handles.axes_SecondaryArea],...
                              1-get(handles.slider_SecondaryGain, 'Value'),...
                              Extra);
    switch (strcat(num2str(handles.header.filetype), ',' , num2str(get(handles.popupmenu_Analyze, 'Value'))))
        case{'512,1','512,2','512,3','512,4','512,5','512,6','512,7','512,8','512,9','-2,2','-2,3','4194304,2','4194304,3','128,1','128,2','16,3','2,2'}         
            handles.ChosenLineH     = -1;
            handles.SecondaryPlot   = tempH(2);            
            set(handles.slider_SecondaryGain, 'Visible', 'on');
        case{'2,1','16,1','16,2','-2,1','4194304,1','128,3','128,4'}
            handles.ChosenLineH 	= tempH(1);
            handles.SecondaryPlot   = tempH(2);
            set(handles.slider_SecondaryGain, 'Visible', 'off');
    end
end


% --------------------------------------------------------------------
function menu_File_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_File_Open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uipushtool_OpenFile_ClickedCallback(handles.uipushtool_OpenFile, [], handles);


% --------------------------------------------------------------------
function menu_File_Close_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pushbutton_CloseFile_Callback(handles.pushbutton_CloseFile, [], handles);


% --------------------------------------------------------------------
function menu_Help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Help_About_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Help_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox({'Sonix Data Tools Version 6.1.0', '' ,'Ultrasonix Medical Corporation 2012', ''}, 'About', 'modal');
% uiwait(h);            


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Fixing the column width of the header info table
set(handles.table_HeaderInfo, 'Units', 'pixels');
temp = get(handles.table_HeaderInfo, 'Position');
set(handles.table_HeaderInfo, 'columnWidth', {temp(3)/2-2, temp(3)/2-2});
set(handles.table_HeaderInfo, 'Units', 'normal');


% --------------------------------------------------------------------
function menu_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Settings_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Settings_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If the movie is running take no action
if (handles.Playing)
    return
end
% Open the settings dialog box and get the input from the user
[output handles] = SonixDataTools_SettingDlg(handles);
% If in DAQ mode, the table needs to be updated
if isfield(handles, 'header')
    if handles.header.filetype== -2 % DAQ
        % Read the probe data from the probes.xml file
        handles.ProbeStruct = readprobe([handles.SDKPath '\probes.xml'], handles.DAQProbeID);
        % Setting up the table which contains the header information
        handles = fillTable(handles);
    end
end
% Update handles structure
guidata(hObject, handles);
