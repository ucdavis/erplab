function varargout = csd_generate(varargin)
% CSD_GENERATE MATLAB code for csd_generate.fig
%      CSD_GENERATE, by itself, creates a new CSD_GENERATE or raises the existing
%      singleton*.
%
%      H = CSD_GENERATE returns the handle to a new CSD_GENERATE or the handle to
%      the existing singleton*.
%
%      CSD_GENERATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSD_GENERATE.M with the given input arguments.
%
%      CSD_GENERATE('Property','Value',...) creates a new CSD_GENERATE or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csd_generate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csd_generate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csd_generate

% Last Modified by GUIDE v2.5 03-Aug-2016 19:48:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csd_generate_OpeningFcn, ...
                   'gui_OutputFcn',  @csd_generate_OutputFcn, ...
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

% --- Executes just before csd_generate is made visible.
function csd_generate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csd_generate (see VARARGIN)

% Choose default command line output for csd_generate
handles.output = hObject;

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

% initialise with defaults
handles.mcont   = 4;
handles.smoothl = 0.00001;
handles.headrad = 10;


% Update handles structure
guidata(hObject, handles);





% help
%helpbutton

% UIWAIT makes csd_generate wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = csd_generate_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);
pause(0.1)





% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Sanity-check output
if isa(handles.mcont,'double') ~= 1 || isnan(handles.mcont)
    ertext = 'mcont was set to 4';
    disp(ertext)
    handles.mcont = 4;
end
    


handles.output = [handles.mcont handles.smoothl handles.headrad];



  % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.figure1);

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://psychophysiology.cpmc.columbia.edu/software/CSDtoolbox/index.html','-browser');



% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end




% Update handles structure
guidata(handles.figure1, handles);



function mcont_Callback(hObject, eventdata, handles)
% hObject    handle to mcont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mcont as text
%        str2double(get(hObject,'String')) returns contents of mcont as a double
mcont = str2double(get(hObject,'String'));
% Save the new  value
handles.mcont = mcont;
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function mcont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mcont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function headplot_fig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to headplot_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate headplot_fig
axes(hObject)
imshow('CSD_elec_plot.png')


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function lambdabox_Callback(hObject, eventdata, handles)
% hObject    handle to lambdabox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambdabox as text
%        str2double(get(hObject,'String')) returns contents of lambdabox as a double
smoothl = str2double(get(hObject,'String'));
% Save the new  value
handles.smoothl = smoothl;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function lambdabox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambdabox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function headradbox_Callback(hObject, eventdata, handles)
% hObject    handle to headradbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of headradbox as text
%        str2double(get(hObject,'String')) returns contents of headradbox as a double
headrad = str2double(get(hObject,'String'));
% Save the new  value
handles.headrad = headrad;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function headradbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to headradbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
