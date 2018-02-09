function varargout = interactB8GUI(varargin)
% INTERACTB8GUI MATLAB code for interactB8GUI.fig
%      INTERACTB8GUI, by itself, creates a new INTERACTB8GUI or raises the existing
%      singleton*.
%
%      H = INTERACTB8GUI returns the handle to a new INTERACTB8GUI or the handle to
%      the existing singleton*.
%
%      INTERACTB8GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERACTB8GUI.M with the given input arguments.
%
%      INTERACTB8GUI('Property','Value',...) creates a new INTERACTB8GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interactB8GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interactB8GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interactB8GUI

% Last Modified by GUIDE v2.5 02-Jun-2016 15:09:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interactB8GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @interactB8GUI_OutputFcn, ...
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

% --- Executes just before interactB8GUI is made visible.
function interactB8GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interactB8GUI (see VARARGIN)

% Choose default command line output for interactB8GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using interactB8GUI.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end


% UIWAIT makes interactB8GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interactB8GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    inputB8File = get(handles.edit1, 'String');
    global fid
    global header
    [fid, header] = loadB8(inputB8File);
    readAllImagesFromB8;
    global allImages
    im = allImages(:,:,1);
    imshow(im, 'parent', handles.axes1);
catch
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    global header
    global allImages
    
    sliderPos = get(hObject,'Value');
    min = get(hObject,'Min'); max = get(hObject,'Max');
    sliderPercent = double(sliderPos) / double(max-min);
    imNum = uint8(sliderPercent*header.nframes)
    
    im = allImages(:,:,imNum);
    imshow(im, 'parent', handles.axes1);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [fid, header] = loadB8(filename)
    fid= fopen(filename, 'r');

    if( fid == -1)
        error('Cannot open file');
    end

    % read the header info
    hinfo = fread(fid, 19, 'int32');

    % load the header information into a structure and save under a separate file
    header = struct('filetype', 0, 'nframes', 0, 'w', 0, 'h', 0, 'ss', 0, 'ul', [0,0], 'ur', [0,0], 'br', [0,0], 'bl', [0,0], 'probe',0, 'txf', 0, 'sf', 0, 'dr', 0, 'ld', 0, 'extra', 0);
    header.filetype = hinfo(1);
    header.nframes = hinfo(2);
    header.w = hinfo(3);
    header.h = hinfo(4);
    header.ss = hinfo(5);
    header.ul = [hinfo(6), hinfo(7)];
    header.ur = [hinfo(8), hinfo(9)];
    header.br = [hinfo(10), hinfo(11)];
    header.bl = [hinfo(12), hinfo(13)];
    header.probe = hinfo(14);
    header.txf = hinfo(15);
    header.sf = hinfo(16);
    header.dr = hinfo(17);
    header.ld = hinfo(18);
    header.extra = hinfo(19);

function closeB8File
    global fid
    fclose(fid)

function readImFromB8
    global fid
    global header
    global Im
    [v,count] = fread(fid,header.w*header.h,'uint8'); 
    temp = uint8(reshape(v,header.w,header.h));
    Im = temp';%imrotate(temp, -90);

function readAllImagesFromB8
    global allImages
    global fid
    global header
    
    allImages = uint8(zeros([header.h,header.w,header.nframes]));
    
    for i=1:header.nframes
        [v,count] = fread(fid,header.w*header.h,'uint8'); 
        temp = uint8(reshape(v,header.w,header.h));
        allImages(:,:,i) = imrotate(temp, -90);
    end