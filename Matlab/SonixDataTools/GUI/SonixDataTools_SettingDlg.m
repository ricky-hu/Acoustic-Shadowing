%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A settings dialog box for choosing the version of the Sonix used to
% acquire data and pathname of the installed SDKs. Part of SonixDataTools,
% a gui for loading, displaying, and processing the data saved by SonixRP  
% and SonixTouch research interfaces
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Reserach Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = SonixDataTools_SettingDlg(varargin)
% SONIXDATATOOLS_SETTINGDLG M-file for SonixDataTools_SettingDlg.fig
%      SONIXDATATOOLS_SETTINGDLG, by itself, creates a new SONIXDATATOOLS_SETTINGDLG or raises the existing
%      singleton*.
%
%      H = SONIXDATATOOLS_SETTINGDLG returns the handle to a new SONIXDATATOOLS_SETTINGDLG or the handle to
%      the existing singleton*.
%
%      SONIXDATATOOLS_SETTINGDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONIXDATATOOLS_SETTINGDLG.M with the given input arguments.
%
%      SONIXDATATOOLS_SETTINGDLG('Property','Value',...) creates a new SONIXDATATOOLS_SETTINGDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SonixDataTools_SettingDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SonixDataTools_SettingDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SonixDataTools_SettingDlg

% Last Modified by GUIDE v2.5 27-Nov-2013 15:14:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SonixDataTools_SettingDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @SonixDataTools_SettingDlg_OutputFcn, ...
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


% --- Executes just before SonixDataTools_SettingDlg is made visible.
function SonixDataTools_SettingDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SonixDataTools_SettingDlg (see VARARGIN)

% Choose default command line output for SonixDataTools_SettingDlg
handles.output = hObject;

% Uses the input arguments coming from the main dialog to update the
% default values for the fields
if (nargin > 3)
    handles.ParentHandles    = varargin{1};

    set(handles.edit_SDKPath,'String',handles.ParentHandles.SDKPath);

    % Filling up the list of versions
    handles.versionNameCell = {'5.7.3', '5.7.4', '6.0.0', '6.0.1', '6.0.2', '6.0.3', '6.0.4', '6.0.5', '6.0.6', '6.0.7', '6.1.0'};
    set(handles.popupmenu_VersionSelector, 'String', handles.versionNameCell);
    set(handles.popupmenu_VersionSelector, 'Value', find(strcmp(handles.ParentHandles.version, handles.versionNameCell)));

    % Filling up the list of available probes
    Cntr1 = 0;
    for Cntr = 0:127
        tempProbeStruct = readprobe([get(handles.edit_SDKPath,'String') '\probes.xml'], Cntr);
        if ~isempty(tempProbeStruct)
            Cntr1 = Cntr1 + 1;
            probeNameCell{Cntr1} = tempProbeStruct.name;
            handles.probeIDs(Cntr1) = Cntr;
        end        
    end
    set(handles.popupmenu_ProbeSelector, 'Value', find(handles.probeIDs == handles.ParentHandles.DAQProbeID));
    set(handles.popupmenu_ProbeSelector, 'String', probeNameCell);

end

handles.Waiting = true;
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SonixDataTools_SettingDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Get default command line output from handles structure
varargout{1} = handles.output;

handles.ParentHandles.SDKPath    = get(handles.edit_SDKPath,'String');
handles.ParentHandles.version    = handles.versionNameCell{get(handles.popupmenu_VersionSelector, 'Value')};
handles.ParentHandles.DAQProbeID = handles.probeIDs(get(handles.popupmenu_ProbeSelector, 'Value'));
 
varargout{2} = handles.ParentHandles;

delete(hObject);

function edit_SDKPath_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SDKPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SDKPath as text
%        str2double(get(hObject,'String')) returns contents of edit_SDKPath as a double


% --- Executes during object creation, after setting all properties.
function edit_SDKPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_SDKPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
    if (handles.Waiting)
        uiresume(handles.figure1);
    end
end

% --- Executes on selection change in popupmenu_ProbeSelector.
function popupmenu_ProbeSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_ProbeSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_ProbeSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_ProbeSelector
% --- Executes during object creation, after setting all properties.
function popupmenu_ProbeSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_ProbeSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(handles.figure1, eventdata, handles);


% --- Executes on selection change in popupmenu_VersionSelector.
function popupmenu_VersionSelector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_VersionSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_VersionSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_VersionSelector


% --- Executes during object creation, after setting all properties.
function popupmenu_VersionSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_VersionSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
