 function varargout = gui_erplabShiftEventCodes(varargin)
% GUI_ERPLABSHIFTEVENTCODES MATLAB code for gui_erplabShiftEventCodes.fig
%      GUI_ERPLABSHIFTEVENTCODES, by itself, creates a new GUI_ERPLABSHIFTEVENTCODES or raises the existing
%      singleton*.
%
%      H = GUI_ERPLABSHIFTEVENTCODES returns the handle to a new GUI_ERPLABSHIFTEVENTCODES or the handle to
%      the existing singleton*.
%
%      GUI_ERPLABSHIFTEVENTCODES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ERPLABSHIFTEVENTCODES.M with the given input arguments.
%
%      GUI_ERPLABSHIFTEVENTCODES('Property','Value',...) creates a new GUI_ERPLABSHIFTEVENTCODES or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_erplabShiftEventCodes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_erplabShiftEventCodes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_erplabShiftEventCodes

% Last Modified by GUIDE v2.5 25-Oct-2016 10:44:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_erplabShiftEventCodes_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_erplabShiftEventCodes_OutputFcn, ...
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

% --- Executes just before gui_erplabShiftEventCodes is made visible.
function gui_erplabShiftEventCodes_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_erplabShiftEventCodes (see VARARGIN)

% Choose default command line output for gui_erplabShiftEventCodes
handles.output = []; % hObject;


% Handle input parameters from ERPLABWORKINGMEMORY
try
    
    handles.eventcodes          = varargin{1}{1};
    handles.timeshift           = varargin{1}{2};
    handles.roundingInput       = varargin{1}{3};
    handles.displayEEG          = varargin{1}{4};
    
catch
    % Default values for GUI
    handles.eventcodes          = '';
    handles.timeshift           = 0;
    handles.roundingInput       = 'earlier';
    handles.displayEEG          = false;
end

set(handles.editboxEventCodes, ...
    'String', num2str(handles.eventcodes));
set(handles.editboxTimeshift,  ...
    'String', num2str(handles.timeshift));
set(handles.checkbox_displayEEG, ...
    'Value',  handles.displayEEG);


% Set correct rounding radio button
switch handles.roundingInput
    case 'earlier'
        set(handles.uipanelRounding,   ...
            'SelectedObject', handles.radioBtnRoundEarlier);
    case 'nearest'
        set(handles.uipanelRounding,   ...
            'SelectedObject', handles.radioBtnRoundNearest);
    case 'later'
        set(handles.uipanelRounding,   ...
            'SelectedObject', handles.radioBtnRoundLater);
    otherwise
        set(handles.uipanelRounding,   ...
            'SelectedObject', handles.radioBtnRoundEarlier);
end


% Set Window title
windowTitle = ['ERPLAB ' geterplabversion() '   -   Shift Event Codes GUI'];
set(handles.gui_chassis, 'Name', windowTitle);

handles = painterplab(handles);     % Set color GUI
handles = setfonterplab(handles);   % Set font size



% Run intialization procedures
initialize_gui(hObject, handles, false);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_erplabShiftEventCodes wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = gui_erplabShiftEventCodes_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.5)


% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset) %#ok<*INUSD>
% If the metricdata field is present and the pushbutton_cancel flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to pushbutton_cancel the data.



% Update handles structure
guidata(handles.gui_chassis, handles);





% --- Executes on button press in pushbutton_shiftEvents.
function pushbutton_shiftEvents_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to pushbutton_shiftEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Command-line feedback to user
display('Shifting events...');

% editboxEventCodes_Callback(hObject, eventdata, handles)

% Save the input variables to output
handles.output = {        ...
    handles.eventcodes,   ...
    handles.timeshift,    ...
    handles.roundingInput ...
    handles.displayEEG    ...
    };

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Command-line feedback to user
disp('User selected Cancel')

% Clear all input variables
handles.output = []; 

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --- Executes when selected object changed in uipanelRounding.
function uipanelRounding_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanelRounding 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Set rounding input value depending on which radial button was selected
if (hObject == handles.radioBtnRoundNearest)
    handles.roundingInput = 'nearest';
elseif (hObject == handles.radioBtnRoundEarlier)
    handles.roundingInput = 'earlier';
elseif (hObject == handles.radioBtnRoundLater)
    handles.roundingInput = 'later';
end

% Save the new rounding value
guidata(hObject,handles)








function editboxEventCodes_Callback(hObject, eventdata, handles)
% hObject    handle to editboxEventCodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editboxEventCodes as text
%        str2double(get(hObject,'String')) returns contents of editboxEventCodes as a double

% Using `str2num` (vs `str2double`) to handle both string arrray input and
% single string/character input

% Strip any non-numeric token and replace w/ whitespace (' ')
editString         = regexprep(get(hObject,'String'), '[^0-9:]', ' ');
handles.eventcodes = str2num(editString);  %#ok<ST2NM>

% Display corrected eventcode string back to GUI
set(handles.editboxEventCodes, 'String', editString);

% Save the new replace channels value
guidata(hObject,handles)


function editboxTimeshift_Callback(hObject, eventdata, handles)
% hObject    handle to editboxTimeshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editboxTimeshift as text
%        str2double(get(hObject,'String')) returns contents of editboxTimeshift as a double

handles.timeshift = str2num(get(hObject,'String')); %#ok<ST2NM>

% Save the new ignore channels value
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function editboxTimeshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editboxTimeshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_displayEEG.
function checkbox_displayEEG_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayEEG
% returns contents of editbox_EndEventCodeBufferMS as a double
handles.displayEEG = get(hObject,'Value'); 

% Save the new value
guidata(hObject,handles);


% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('https://github.com/lucklab/erplab/wiki/Continuous-EEG-Preprocessing#shift-event-codes',...
    '-browser');


% --- Executes during object creation, after setting all properties.
function editboxEventCodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editboxEventCodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
