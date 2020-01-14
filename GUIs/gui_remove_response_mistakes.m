function varargout = gui_remove_response_mistakes(varargin)
% GUI_REMOVE_RESPONSE_MISTAKES MATLAB code for gui_remove_response_mistakes.fig
%      GUI_REMOVE_RESPONSE_MISTAKES, by itself, creates a new GUI_REMOVE_RESPONSE_MISTAKES or raises the existing
%      singleton*.
%
%      H = GUI_REMOVE_RESPONSE_MISTAKES returns the handle to a new GUI_REMOVE_RESPONSE_MISTAKES or the handle to
%      the existing singleton*.
%
%      GUI_REMOVE_RESPONSE_MISTAKES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_REMOVE_RESPONSE_MISTAKES.M with the given input arguments.
%
%      GUI_REMOVE_RESPONSE_MISTAKES('Property','Value',...) creates a new GUI_REMOVE_RESPONSE_MISTAKES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_remove_response_mistakes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_remove_response_mistakes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_remove_response_mistakes

% Last Modified by GUIDE v2.5 13-Jan-2020 13:59:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_remove_response_mistakes_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_remove_response_mistakes_OutputFcn, ...
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


% --- Executes just before gui_remove_response_mistakes is made visible.
function gui_remove_response_mistakes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_remove_response_mistakes (see VARARGIN)

% Choose default command line output for gui_remove_response_mistakes
handles.output = hObject;

% Identify and import current EEG set from base workspace
valid_EEG_set = 0;

try
    EEG = evalin('base','EEG');
    valid_EEG_set = 1;
catch
    error('The EEG structure is missing?')
end

% Prepare info
info_name = [EEG.setname];
handles.text_curr_set_name.String = info_name;

% Check numeric or string type
if ischar(EEG.event(1).type)
    ec_type_is_str = 1;
else
    ec_type_is_str = 0;
end

evT = struct2table(EEG.event);
if ec_type_is_str
    all_ev = str2double(evT.type);
else
    all_ev = evT.type;
end

all_ev_unique = unique(all_ev);
all_ev_unique(isnan(all_ev_unique)) = [];

handles.uitable_events.Data = all_ev_unique';



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_remove_response_mistakes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_remove_response_mistakes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_stim_codes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stim_codes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stim_codes as text
%        str2double(get(hObject,'String')) returns contents of edit_stim_codes as a double


% --- Executes during object creation, after setting all properties.
function edit_stim_codes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stim_codes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_resp_codes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_resp_codes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_resp_codes as text
%        str2double(get(hObject,'String')) returns contents of edit_resp_codes as a double


% --- Executes during object creation, after setting all properties.
function edit_resp_codes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_resp_codes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
