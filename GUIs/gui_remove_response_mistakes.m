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

% Last Modified by GUIDE v2.5 28-Apr-2022 15:23:08

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

handles.all_ev_unique = all_ev_unique;

handles.uitable_events.Data = all_ev_unique';

handles.stim_codes = [];
handles.resp_codes = [];
handles.output = [handles.stim_codes,handles.resp_codes];


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_remove_response_mistakes wait for user response (see UIRESUME)
uiwait(handles.remove_response_mistake_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = gui_remove_response_mistakes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles,'stim_codes')
    % default output on 'Apply'
    varargout{1} = handles.stim_codes;
    varargout{2} = handles.resp_codes;
    
    delete(handles.remove_response_mistake_GUI);
else
    % forced closed already, no handles left
    varargout{1} = [];
    varargout{2} = [];
 
end





function edit_stim_codes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stim_codes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stim_codes as text
%        str2double(get(hObject,'String')) returns contents of edit_stim_codes as a double

% on the user entering a string, we want to sanitize it, and save the list
% of numbers as a vector
str_here = get(hObject,'String');
regex_target = ',';

split_str = regexp(str_here,regex_target,'split');
%disp(split_str)

stim_codes_entered = str2double(split_str);

% are these valid?
stim_codes_match = ismember(stim_codes_entered,handles.all_ev_unique);

if any(stim_codes_match) == 0
    beep
    warning('Please check stim codes -- some not found in this EEG set')
end

handles.stim_codes = stim_codes_entered;
% Update handles structure
guidata(hObject, handles);




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

str_here = get(hObject,'String');
regex_target = ',';

split_str = regexp(str_here,regex_target,'split');
%disp(split_str)

resp_codes_entered = str2double(split_str);

% are these valid?
resp_codes_match = ismember(resp_codes_entered,handles.all_ev_unique);

if any(resp_codes_match) == 0
    beep
    warning('Please check resp codes -- some not found in this EEG set')
end

handles.resp_codes = resp_codes_entered;
% Update handles structure
guidata(hObject, handles);


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


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stim_codes = [];
handles.resp_codes = [];
handles.output = [handles.stim_codes,handles.resp_codes];

uiresume(handles.remove_response_mistake_GUI);
% Hint: delete(hObject) closes the figure
delete(hObject);



% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web https://github.com/lucklab/erplab/wiki/ -browser


% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update handles structure
guidata(hObject, handles);

uiresume(handles.remove_response_mistake_GUI);
%delete(handles.remove_response_mistake_GUI);


% --- Executes when user attempts to close remove_response_mistake_GUI.
function remove_response_mistake_GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to remove_response_mistake_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.stim_codes = [];
handles.resp_codes = [];
handles.output = [handles.stim_codes,handles.resp_codes];

uiresume(handles.remove_response_mistake_GUI);
% Hint: delete(hObject) closes the figure
delete(hObject);
delete(handles.remove_response_mistake_GUI);


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
