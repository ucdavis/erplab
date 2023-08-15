function varargout = f_EEG_import(varargin)
% F_EEG_IMPORT MATLAB code for f_EEG_import.fig
%      F_EEG_IMPORT, by itself, creates a new F_EEG_IMPORT or raises the existing
%      singleton*.
%
%      H = F_EEG_IMPORT returns the handle to a new F_EEG_IMPORT or the handle to
%      the existing singleton*.
%
%      F_EEG_IMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_EEG_IMPORT.M with the given input arguments.
%
%      F_EEG_IMPORT('Property','Value',...) creates a new F_EEG_IMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_EEG_import_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_EEG_import_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_EEG_import

% Last Modified by GUIDE v2.5 14-Aug-2023 12:54:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_EEG_import_OpeningFcn, ...
    'gui_OutputFcn',  @f_EEG_import_OutputFcn, ...
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


% --- Executes just before f_EEG_import is made visible.
function f_EEG_import_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_EEG_import

try
    ALLEEG  = varargin{1};
catch
    ALLEEG = [];
end

% handles.erpnameor = ERP.erpname;
handles.output = [];
handles.ALLEEG = ALLEEG;

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Import data GUI'])


% Color GUI
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

handles.checkbox_func_plugs.Value = 0;
handles.pushbutton_asii.Enable = 'off';
handles.pushbutton_biosemibdf.Enable = 'off';
handles.pushbutton_bio_edf.Enable = 'off';
handles.pushbutton_visrec.Enable = 'off';
handles.pushbutton_visanal.Enable = 'off';
handles.pushbutton_mff.Enable = 'off';
handles.pushbutton_cnt.Enable = 'off';
handles.pushbutton_eeg.Enable = 'off';
handles.pushbutton_bdf_plugin.Enable = 'off';

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_EEG_import_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% try
%     set(handles.menuerp.Children, 'Enable','on');
% catch
%     disp('EEGset menu was not found...')
% end
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)





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

handles.output = handles.ALLEEG;
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


% --- Executes on button press in checkbox_func_plugs.
function checkbox_func_plugs_Callback(hObject, eventdata, handles)

if handles.checkbox_func_plugs.Value == 0;
    handles.pushbutton_asii.Enable = 'off';
    handles.pushbutton_biosemibdf.Enable = 'off';
    handles.pushbutton_bio_edf.Enable = 'off';
    handles.pushbutton_visrec.Enable = 'off';
    handles.pushbutton_visanal.Enable = 'off';
    handles.pushbutton_mff.Enable = 'off';
    handles.pushbutton_cnt.Enable = 'off';
    handles.pushbutton_eeg.Enable = 'off';
    handles.pushbutton_bdf_plugin.Enable = 'off';
else
    handles.pushbutton_asii.Enable = 'on';
    handles.pushbutton_biosemibdf.Enable = 'on';
    handles.pushbutton_bio_edf.Enable = 'on';
    handles.pushbutton_visrec.Enable = 'on';
    handles.pushbutton_visanal.Enable = 'on';
    handles.pushbutton_mff.Enable = 'on';
    handles.pushbutton_cnt.Enable = 'on';
    handles.pushbutton_eeg.Enable = 'on';
    handles.pushbutton_bdf_plugin.Enable = 'on';
end



% --- Executes on button press in pushbutton_fileio.
function pushbutton_fileio_Callback(hObject, eventdata, handles)
%%check if the function exist?
fileName = which('pop_fileio');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Filio Vxxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_fileio();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);



% --- Executes on button press in pushbutton_biosiginter.
function pushbutton_biosiginter_Callback(hObject, eventdata, handles)
fileName = which('pop_biosig');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_biosig();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);




% --- Executes on button press in pushbutton_troubleformat.
function pushbutton_troubleformat_Callback(hObject, eventdata, handles)
pophelp('troubleshooting_data_formats');
guidata(hObject, handles);


% --- Executes on importing ASCII/float file or Matlab array
function pushbutton_asii_Callback(hObject, eventdata, handles)
fileName = which('pop_importdata');
if isempty(fileName)
    handles.text_message.String = 'There is no function "ASCII/float file or Matlab array".';
    return;
end

[EEG LASTCOM] = pop_importdata;
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);




% --- Executes on importing Biosemi BDF file (BIOSIG toolbox)
function pushbutton_biosemibdf_Callback(hObject, eventdata, handles)

fileName = which('pop_biosig');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_biosig();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);



% --- Executes on imporing EDF/EDF+/GDF files (BIOSIG toolbox)
function pushbutton_bio_edf_Callback(hObject, eventdata, handles)
fileName = which('pop_biosig');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_biosig();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);



% --- Executes on importing Brain Vis. Rec. .vhdr file
function pushbutton_visrec_Callback(hObject, eventdata, handles)

fileName = which('pop_loadbva');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > bva-io Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_loadbva();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);


% --- Executes on importing Brain Vis. Anal. Matlab file
function pushbutton_visanal_Callback(hObject, eventdata, handles)

fileName = which('pop_loadbva');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > bva-io Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_loadbva();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);




% --- Executes on button press in pushbutton_mff.
%%[EEG, LASTCOM] = pop_mffimport
function pushbutton_mff_Callback(hObject, eventdata, handles)

fileName = which('pop_mffimport');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > MFFMaltabIO Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_mffimport();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);





% --- Executes on importing Neuroscan .CNT file
function pushbutton_cnt_Callback(hObject, eventdata, handles)
fileName = which('pop_loadcnt');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > neuroscanio Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_loadcnt();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);




% --- Executes on importing Neuroscan .EEG file
function pushbutton_eeg_Callback(hObject, eventdata, handles)
fileName = which('pop_loadeeg');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > neuroscanio Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_loadeeg();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);


%%pop_readbdf


% --- Executes on button press in pushbutton_bdf_plugin.
function pushbutton_bdf_plugin_Callback(hObject, eventdata, handles)
fileName = which('pop_readbdf');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > BDFimport Vxx" to download it';
    return;
end
[EEG,LASTCOM] = pop_readbdf();
if isempty(EEG)
    disp('User selected Cancel');
   return; 
end
EEG = eegh(LASTCOM, EEG);
ALLEEG = handles.ALLEEG;
if isempty(ALLEEG)
    OLDSET=1;
else
    %  ALLEEG(length(ALLEEG)+1) = EEG;
    OLDSET = length(ALLEEG);
end
[ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);

handles.ALLEEG = ALLEEG;
guidata(hObject, handles);
