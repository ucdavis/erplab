function varargout = f_ERP_meas_basecorr(varargin)
% F_ERP_MEAS_BASECORR MATLAB code for f_ERP_meas_basecorr.fig
%      F_ERP_MEAS_BASECORR, by itself, creates a new F_ERP_MEAS_BASECORR or raises the existing
%      singleton*.
%
%      H = F_ERP_MEAS_BASECORR returns the handle to a new F_ERP_MEAS_BASECORR or the handle to
%      the existing singleton*.
%
%      F_ERP_MEAS_BASECORR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_MEAS_BASECORR.M with the given input arguments.
%
%      F_ERP_MEAS_BASECORR('Property','Value',...) creates a new F_ERP_MEAS_BASECORR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_meas_basecorr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_meas_basecorr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_meas_basecorr

% Last Modified by GUIDE v2.5 23-Aug-2022 09:26:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_meas_basecorr_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_meas_basecorr_OutputFcn, ...
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


% --- Executes just before f_ERP_meas_basecorr is made visible.
function f_ERP_meas_basecorr_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_meas_basecorr

try
    Baseline_method  = varargin{1}; %% 1. long; 0 wide
    %     latency= varargin{2};
catch
    Baseline_method  = 'pre'; %% 1. long; 0 wide
    %     latency= '';
end
% handles.latency = latency;
handles.output = [];
% erpmenu  = findobj('tag', 'erpsets');
% handles.pathName = pathName;
% if ~isempty(erpmenu)
%     handles.menuerp = get(erpmenu);
%     set(handles.menuerp.Children, 'Enable','off');
% end

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   ERP Measurement Tool'])


set(handles.current_erp_label,'String', ['ERP Measurement Tool: Baseline Period in ms'],...
    'FontWeight','Bold', 'FontSize', 16);
if length(Baseline_method)==2
    set(handles.edit_custom, 'String', num2str(Baseline_method));
    
else
    
    if strcmpi(Baseline_method,'pre')
        set(handles.radiobutton_pre, 'Value', 1);
        set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
        set(handles.radiobutton_whole, 'Value', 0);
        set(handles.radiobutton_custom, 'Value', 0);
        set(handles.edit_custom, 'Enable', 'off');
        set(handles.radiobutton_none, 'Value', 0);
    elseif strcmpi(Baseline_method,'post')
        set(handles.radiobutton_pre, 'Value', 0);
        set(handles.radiobutton_post, 'Value', 1);%radiobutton_whole
        set(handles.radiobutton_whole, 'Value', 0);
        set(handles.radiobutton_custom, 'Value', 0);
        set(handles.edit_custom, 'Enable', 'off');
        set(handles.radiobutton_none, 'Value', 0);
    elseif strcmpi(Baseline_method,'whole')
        set(handles.radiobutton_pre, 'Value', 0);
        set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
        set(handles.radiobutton_whole, 'Value', 1);
        set(handles.radiobutton_custom, 'Value', 0);
        set(handles.edit_custom, 'Enable', 'off');
        set(handles.radiobutton_none, 'Value', 0);
    elseif strcmpi(Baseline_method,'none')
         set(handles.radiobutton_pre, 'Value', 0);
        set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
        set(handles.radiobutton_whole, 'Value', 0);
        set(handles.radiobutton_custom, 'Value', 0);
        set(handles.edit_custom, 'Enable', 'off');
        set(handles.radiobutton_none, 'Value', 1);
    else
        set(handles.radiobutton_pre, 'Value', 0);
        set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
        set(handles.radiobutton_whole, 'Value', 0);
        set(handles.radiobutton_custom, 'Value', 0);
        set(handles.edit_custom, 'Enable', 'off');
        set(handles.radiobutton_none, 'Value', 1);
    end
end
% set(handles.edit_custom, 'String', pathName);
%
% % Color GUI
% %
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_ERP_meas_basecorr_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)


function edit_custom_Callback(hObject, eventdata, handles)

Baseline = str2num(handles.String);
if isempty(Baseline) || length(Baseline) ==1
    msgboxText =  {'Invalid Baseline range!';'Please enter two numeric values'};
    title = 'EStudio: f_ERP_meas_basecorr()  error: Baseline Period setting';
    errorfound(msgboxText, title);
    return;
end




% --- Executes during object creation, after setting all properties.
function edit_custom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_pre.
function radiobutton_pre_Callback(hObject, eventdata, handles)
set(handles.radiobutton_pre, 'Value', 1);
set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
set(handles.radiobutton_whole, 'Value', 0);
set(handles.radiobutton_custom, 'Value', 0);
set(handles.radiobutton_none, 'Value', 0);
set(handles.edit_custom, 'Enable', 'off');


% --- Executes on button press in radiobutton_post.
function radiobutton_post_Callback(hObject, eventdata, handles)
set(handles.radiobutton_pre, 'Value', 0);
set(handles.radiobutton_post, 'Value', 1);%radiobutton_whole
set(handles.radiobutton_whole, 'Value', 0);
set(handles.radiobutton_custom, 'Value', 0);
set(handles.radiobutton_none, 'Value', 0);
set(handles.edit_custom, 'Enable', 'off');


% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
beep;
disp('User selected Cancel')
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)

if handles.radiobutton_none.Value
    Baseline_corre = 'none';
elseif handles.radiobutton_pre.Value
    Baseline_corre = 'pre';
elseif handles.radiobutton_post.Value
    Baseline_corre = 'post';
elseif handles.radiobutton_whole.Value
    Baseline_corre = 'whole';
elseif handles.radiobutton_custom.Value
    
    Baseline_corre = str2num(handles.edit_custom.String);
    if isempty(Baseline_corre) || length(Baseline_corre) ==1
        msgboxText =  {'Invalid Baseline range!';'Please enter two numeric values'};
        title = 'EStudio: f_ERP_meas_basecorr()  error: Baseline Period setting';
        errorfound(msgboxText, title);
        return;
    elseif Baseline_corre(1)>=Baseline_corre(2)
        msgboxText = ['EStudio says: The first latency should be smaller than the seocnd one.'];
        title = 'EStudio: f_ERP_meas_basecorr()  error: Baseline Period setting';
        errorfound(sprintf(msgboxText), title);
        return;
    end
    Baseline_corre = handles.edit_custom.String;
else
    Baseline_corre = 'none';
    
end

handles.output = Baseline_corre;
% Update handles structure
guidata(hObject, handles);

uiresume(handles.gui_chassis);




% -----------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.gui_chassis);
else
    % The GUI is no longer waiting, just close it
    delete(handles.gui_chassis);
end


% --- Executes on button press in radiobutton_whole.
function radiobutton_whole_Callback(hObject, eventdata, handles)
set(handles.radiobutton_pre, 'Value', 0);
set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
set(handles.radiobutton_whole, 'Value', 1);
set(handles.radiobutton_custom, 'Value', 0);
set(handles.radiobutton_none, 'Value', 0);
set(handles.edit_custom, 'Enable', 'off');

% --- Executes on button press in radiobutton_custom.
function radiobutton_custom_Callback(hObject, eventdata, handles)
set(handles.radiobutton_pre, 'Value', 0);
set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
set(handles.radiobutton_whole, 'Value', 0);
set(handles.radiobutton_custom, 'Value', 1);
set(handles.radiobutton_none, 'Value', 0);
set(handles.edit_custom, 'Enable', 'on');


% --- Executes on button press in radiobutton_none.
function radiobutton_none_Callback(hObject, eventdata, handles)
set(handles.radiobutton_pre, 'Value', 0);
set(handles.radiobutton_post, 'Value', 0);%radiobutton_whole
set(handles.radiobutton_whole, 'Value', 0);
set(handles.radiobutton_custom, 'Value', 0);
set(handles.radiobutton_none, 'Value', 1);
set(handles.edit_custom, 'Enable', 'off');
% Hint: get(hObject,'Value') returns toggle state of radiobutton_none
