function varargout = f_EEG_import_GUI(varargin)
% F_EEG_IMPORT_GUI MATLAB code for f_EEG_import_GUI.fig
%      F_EEG_IMPORT_GUI, by itself, creates a new F_EEG_IMPORT_GUI or raises the existing
%      singleton*.
%
%      H = F_EEG_IMPORT_GUI returns the handle to a new F_EEG_IMPORT_GUI or the handle to
%      the existing singleton*.
%
%      F_EEG_IMPORT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_EEG_IMPORT_GUI.M with the given input arguments.
%
%      F_EEG_IMPORT_GUI('Property','Value',...) creates a new F_EEG_IMPORT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_EEG_import_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_EEG_import_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_EEG_import_GUI

% Last Modified by GUIDE v2.5 14-Aug-2023 19:11:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_EEG_import_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_EEG_import_GUI_OutputFcn, ...
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


% --- Executes just before f_EEG_import_GUI is made visible.
function f_EEG_import_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_EEG_import_GUI

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
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Import EEG data GUI'])


% Color GUI
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
try
    p1 = which('eegplugin_bva_io','-all');
    p1 = p1{1};
    p1 = p1(1:findstr(p1,'eegplugin_bva_io.m')-1);
    addpath(genpath([p1]));
catch
end

handles = setfonterplabestudio(handles);

handles.checkbox_func_plugs.Value = 0;
handles.listbox_plugins.Enable = 'off';
Plugin_fuName = {'';'ASCII/float file or Matlab array';'Biosemi BDF file (BIOSIG toolbox)';...
    'EDF/EDF+/GDF files (BIOSIG toolbox)';'Biosemi BDF and EDF files (BDF plugin)';...
    'Brain Vis. Rec. .vhdr or .ahdr file';'Brain Vis. Anal. Matlab file';'Magstim/EGI .mff file';...
    'Neuroscan .CNT file';'Neuroscan .EEG file'};
handles.listbox_plugins.String = Plugin_fuName;
handles.listbox_plugins.Value=1;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_EEG_import_GUI_OutputFcn(hObject, eventdata, handles)

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
    handles.listbox_plugins.Enable = 'off';
    handles.listbox_plugins.Value=1;
else
    handles.listbox_plugins.Enable = 'on';
end



% --- Executes on button press in pushbutton_fileio.
function pushbutton_fileio_Callback(hObject, eventdata, handles)
handles.text_message.String = '';
%%check if the function exist?
fileName = which('pop_fileio');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Filio Vxxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end
% [EEG,LASTCOM] = pop_fileio();
% if isempty(EEG)
%     disp('User selected Cancel');
%     return;
% end
% EEG = eegh(LASTCOM, EEG);
% ALLEEG = handles.ALLEEG;
% if isempty(ALLEEG)
%     OLDSET=1;
% else
%     %  ALLEEG(length(ALLEEG)+1) = EEG;
%     OLDSET = length(ALLEEG);
% end
% [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
%
% handles.ALLEEG = ALLEEG;
% guidata(hObject, handles);
ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile('*.*', 'Choose files or header files -- pop_fileio()',...
    'MultiSelect', 'on');

if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_fileio([filepath,filename], 'dataformat','auto');
        [~, myFilename, ~] = fileparts(filename);
    else
        [EEG,LASTCOM] = pop_fileio([filepath,filename{Numofile}], 'dataformat','auto');
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton_biosiginter.
function pushbutton_biosiginter_Callback(hObject, eventdata, handles)
% handles.text_message.String = '';
fileName = which('pop_biosig');
% fileName = which('biosig_installer');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end
ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile({'*.BDF;*.bdf';'*.EDF+;*.edf+';'*.GDF;*.gdf'}, 'Choose BDF/EDF+/GDF files -- pop_biosig()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        try
            [EEG,LASTCOM] = pop_biosig([filepath,filename]);
        catch
            handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
            handles.listbox_plugins.Value=1;
            return;
        end
        [~, myFilename, ~] = fileparts(filename);
    else
        try
            [EEG,LASTCOM] = pop_biosig([filepath,filename{Numofile}]);
        catch
            handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
            handles.listbox_plugins.Value=1;
            return;
        end
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end
guidata(hObject, handles);




% --- Executes on button press in pushbutton_troubleformat.
function pushbutton_troubleformat_Callback(hObject, eventdata, handles)
pophelp('troubleshooting_data_formats');
guidata(hObject, handles);


% --- Executes on importing ASCII/float file or Matlab array
function handles = pushbutton_asii(hObject, eventdata, handles)
% handles.text_message.String = '';

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
function handles = pushbutton_biosemibdf(hObject, eventdata, handles)
% handles.text_message.String = '';

fileName = which('pop_biosig');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end

ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile({'*.BDF;*.bdf';'*.EDF+;*.edf+';'*.GDF;*.gdf'}, 'Choose BDF/EDF+/GDF files -- pop_biosig()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        try
            [EEG,LASTCOM] = pop_biosig([filepath,filename]);
        catch
            handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
            handles.listbox_plugins.Value=1;
            return;
        end
        [~, myFilename, ~] = fileparts(filename);
    else
        try
            [EEG,LASTCOM] = pop_biosig([filepath,filename{Numofile}]);
        catch
            handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
            handles.listbox_plugins.Value=1;
            return;
        end
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end
% guidata(hObject, handles);



% --- Executes on imporing EDF/EDF+/GDF files (BIOSIG toolbox)
function handles = pushbutton_bio_edf(hObject, eventdata, handles)
% handles.text_message.String = '';

fileName = which('pop_biosig');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end

ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile({'*.BDF;*.bdf';'*.EDF+;*.edf+';'*.GDF;*.gdf'}, 'Choose BDF/EDF+/GDF files -- pop_biosig()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end
if iscell(filename)
    filterindex  = length(filename);
else
    filterindex =1;
end
for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        try
            [EEG,LASTCOM] = pop_biosig([filepath,filename]);
        catch
            handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
            handles.listbox_plugins.Value=1;
            return;
        end
        [~, myFilename, ~] = fileparts(filename);
    else
        try
            [EEG,LASTCOM] = pop_biosig([filepath,filename{Numofile}]);
        catch
            handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > Biosig Vxx" to download it';
            handles.listbox_plugins.Value=1;
            return;
        end
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end




% --- Executes on importing Brain Vis. Rec. .vhdr file
function handles = pushbutton_visrec(hObject, eventdata, handles)
% handles.text_message.String = '';
fileName = which('pop_loadbva');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > bva-io Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end
% [EEG,LASTCOM] = pop_loadbv();
ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile({'*.vhdr' '*.ahdr'}, 'Select Brain Vision vhdr-file - pop_loadbv()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_loadbv(filepath,filename);
        [~, myFilename, ~] = fileparts(filename);
    else
        [EEG,LASTCOM] = pop_loadbv(filepath,filename{Numofile});
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end



% --- Executes on importing Brain Vis. Anal. Matlab file
function handles = pushbutton_visanal(hObject, eventdata, handles)
% handles.text_message.String = '';

fileName = which('pop_loadbva');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > bva-io Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end
ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile('*.mat;*.MAT', 'Choose a Matlab file from Brain Vision Analyser -- pop_loadbva',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_loadbva([filepath,filename]);
        [~, myFilename, ~] = fileparts(filename);
    else
        [EEG,LASTCOM] = pop_loadbva([filepath,filename{Numofile}]);
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end
% guidata(hObject, handles);




% --- Executes on button press in pushbutton_mff.
%%[EEG, LASTCOM] = pop_mffimport
function handles = pushbutton_mff(hObject, eventdata, handles)
% handles.text_message.String = '';
fileName = which('pop_mffimport');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > MFFMaltabIO Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end

ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile('*.MFF;*.mff', 'Select an EGI .mff file(s)--pop_mffimport',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end
if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_mffimport([filepath,filename]);
        [~, myFilename, ~] = fileparts(filename);
    else
        [EEG,LASTCOM] = pop_mffimport([filepath,filename{Numofile}]);
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end





% --- Executes on importing Neuroscan .CNT file
function handles = pushbutton_cnt(hObject, eventdata, handles)
% handles.text_message.String = '';
fileName = which('pop_loadcnt');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > neuroscanio Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end

ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile('*.CNT;*.cnt', 'Load CNT files -- pop_loadcnt()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_loadcnt([filepath,filename]);
        [~, myFilename, ~] = fileparts(filename);
    else
        [EEG,LASTCOM] = pop_loadcnt([filepath,filename{Numofile}]);
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end




% --- Executes on importing Neuroscan .EEG file
function handles = pushbutton_eeg(hObject, eventdata, handles)
% handles.text_message.String = '';
fileName = which('pop_loadeeg');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > neuroscanio Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end
% [EEG,LASTCOM] = pop_loadeeg();
ALLEEG = handles.ALLEEG;
[filename, filepath,filterindex] = uigetfile('*.eeg;*.EEG', 'Load EEG files -- pop_loadeeg()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

if iscell(filename)
   filterindex  = length(filename); 
else
  filterindex =1;  
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_loadeeg(filename,filepath);
        [~, myFilename, ~] = fileparts(filename);
    else
        [EEG,LASTCOM] = pop_loadeeg(filename{Numofile},filepath);
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end

%%pop_readbdf


% --- Executes on button press in pushbutton_bdf_plugin.
function handles = pushbutton_bdf_plugin(hObject, eventdata, handles)
% handles.text_message.String = '';
fileName = which('pop_readbdf');
if isempty(fileName)
    handles.text_message.String = 'Please use EEGLAB menu: "File > Manage EEGLAB extension > BDFimport Vxx" to download it';
    handles.listbox_plugins.Value=1;
    return;
end
ALLEEG = handles.ALLEEG;
% [EEG,LASTCOM] = pop_readbdf();
[filename, filepath,filterindex] = uigetfile('*.BDF;*.bdf', 'Load BDF files -- pop_loadcnt()',...
    'MultiSelect', 'on');
if filterindex==0
    handles.text_message.String = 'User selected Cancel';
    handles.listbox_plugins.Value=1;
    return;
end

for Numofile = 1:filterindex %%loop for subjects which is allow to load the mutiple datasets
    handles.text_message.String = ['Loading data (',num2str(Numofile),'/',num2str(filterindex),')'];
    if filterindex==1
        [EEG,LASTCOM] = pop_readbdf([filepath,filename]);
    else
        [EEG,LASTCOM] = pop_readbdf([filepath,filename{Numofile}]);
    end
    if isempty(EEG)
        disp('User selected Cancel');
        return;
    end
    EEG = eegh(LASTCOM, EEG);
    if isempty(ALLEEG)
        OLDSET=1;
    else
        OLDSET = length(ALLEEG);
    end
    if filterindex==1
        [~, myFilename, ~] = fileparts(filename);
    else
        [~, myFilename, ~] = fileparts(filename{Numofile});
    end
    if ~isempty(myFilename)
        EEG.setname = myFilename;
    end
    [ALLEEG, EEG] = pop_newset( ALLEEG, EEG,OLDSET);
    handles.ALLEEG = ALLEEG;
end


% --- Executes on selection change in listbox_plugins.
function listbox_plugins_Callback(hObject, eventdata, handles)
Value = handles.listbox_plugins.Value;
handles.text_message.String = 'Loading data';
handles.text_message.ForegroundColor = [0 0 0];
handles.text_message.FontSize= handles.text_message.FontSize+2;
switch Value
    case 1
    case 2
        handles = pushbutton_asii(hObject, eventdata, handles);
    case 3
        handles = pushbutton_biosemibdf(hObject, eventdata, handles);
    case 4
        handles = pushbutton_bio_edf(hObject, eventdata, handles);
    case 5
        handles = pushbutton_bdf_plugin(hObject, eventdata, handles);
    case 6
        handles = pushbutton_visrec(hObject, eventdata, handles);
    case 7
        handles = pushbutton_visanal(hObject, eventdata, handles);
    case 8
        handles = pushbutton_mff(hObject, eventdata, handles);
    case 9
        handles = pushbutton_cnt(hObject, eventdata, handles);
    case 10
        handles = pushbutton_eeg(hObject, eventdata, handles);
end
handles.listbox_plugins.Value =1;
handles.text_message.String = 'Loading was done!';
pause(0.1);
handles.text_message.String = '';
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function listbox_plugins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_eeglab_extension.
function pushbutton_eeglab_extension_Callback(hObject, eventdata, handles)
plugin_menu([]);


