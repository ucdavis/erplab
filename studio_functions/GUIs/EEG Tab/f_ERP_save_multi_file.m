function varargout = f_ERP_save_multi_file(varargin)
% F_ERP_SAVE_MULTI_FILE MATLAB code for f_ERP_save_multi_file.fig
%      F_ERP_SAVE_MULTI_FILE, by itself, creates a new F_ERP_SAVE_MULTI_FILE or raises the existing
%      singleton*.
%
%      H = F_ERP_SAVE_MULTI_FILE returns the handle to a new F_ERP_SAVE_MULTI_FILE or the handle to
%      the existing singleton*.
%
%      F_ERP_SAVE_MULTI_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_SAVE_MULTI_FILE.M with the given input arguments.
%
%      F_ERP_SAVE_MULTI_FILE('Property','Value',...) creates a new F_ERP_SAVE_MULTI_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_save_multi_file_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_save_multi_file_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_save_multi_file

% Last Modified by GUIDE v2.5 10-Jan-2024 13:52:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_save_multi_file_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_save_multi_file_OutputFcn, ...
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


% --- Executes just before f_ERP_save_multi_file is made visible.
function f_ERP_save_multi_file_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_save_multi_file

try
    ALLERP  = varargin{1};
    EEGArray = varargin{2};
    suffix = varargin{3};
catch
    suffix  = '';
    EEGLAB = [];
    EEGLAB.setname = 'No erpset was selected';
    EEGLAB.filename ='No erpset was selected';
    EEGLAB.event = [];
    EEGLAB.chanlocs = [];
    EEGLAB.nbchan = 0;
    ALLERP(1) = EEGLAB;
    EEGArray = 1;
end

% handles.erpnameor = erpname;
handles.output = [];
handles.suffix = suffix;

handles.ALLERP = ALLERP;
handles.EEGArray =EEGArray;

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Save multiple erpsets GUI'])


% set(handles.checkbox1_suffix,'Value',1);
set(handles.edit_suffix_name,'String',suffix);
set(handles.checkbox2_save_label,'Value',0);

ColumnName_table = {'ERP name','File name'};

set(handles.uitable1_erpset_table,'ColumnName',cellstr(ColumnName_table));
set(handles.uitable1_erpset_table,'RowName',cellstr(num2str(EEGArray')));


for Numoferpset = 1:numel(EEGArray)
    DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).setname,suffix);
    DataString{Numoferpset,2} = '';
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});
set(handles.uitable1_erpset_table,'Enable','on');
set(handles.checkbox3_filename_erpname,'Enable','off');
set(handles.edit_path,'Enable','off','String','');
set(handles.pushbutton_path_browse,'Enable','off');
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
handles.uitable1_erpset_table.BackgroundColor = [1 1 1];
handles.checkbox1_suffix.BackgroundColor = [1 1 1];
handles.checkbox3_filename_erpname.BackgroundColor = [1 1 1];
% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_ERP_save_multi_file_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
try
    varargout{1} = handles.output;
catch
    varargout{1} = [];
end

delete(handles.gui_chassis);
pause(0.1)



% --- Executes on button press in checkbox1_suffix.
function checkbox1_suffix_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
EEGArray = handles.EEGArray;
suffix_edit = handles.edit_suffix_name.String;

if isempty(suffix_edit)
    msgboxText =  'You must enter a suffix at least!';
    title = 'EStudio: f_ERP_save_multi_file() error';
    errorfound(msgboxText, title);
    return
end


DataString_before = handles.uitable1_erpset_table.Data;
for Numoferpset = 1:numel(EEGArray)
    DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).setname,suffix_edit);
    DataString{Numoferpset,2} = DataString_before{Numoferpset,2};
end
set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});
if handles.checkbox2_save_label.Value
    set(handles.uitable1_erpset_table,'Enable','off');
else
    set(handles.uitable1_erpset_table,'Enable','on');
end




function edit_suffix_name_Callback(hObject, eventdata, handles)

% Suffix_string = handles.edit_suffix_name.String;
% if isempty(Suffix_string)
%     msgboxText =  'You must enter a suffix at least!';
%     title = 'EStudio: f_ERP_save_multi_file() error';
%     errorfound(msgboxText, title);
%     return
% end
%
% if handles.checkbox1_suffix.Value
%
%     DataString_before = handles.uitable1_erpset_table.Data;
%     for Numoferpset = 1:size(DataString_before,1)
%         DataString{Numoferpset,1} = char(strcat(DataString_before{Numoferpset,1},'-',char(Suffix_string)));
%         DataString{Numoferpset,2} = DataString_before{Numoferpset,2};
%     end
%
%     set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
%     set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});
%     set(handles.uitable1_erpset_table,'Enable','off');
%     handles.suffix=Suffix_string;
% end

% --- Executes during object creation, after setting all properties.
function edit_suffix_name_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in checkbox2_save_label.
function checkbox2_save_label_Callback(hObject, eventdata, handles)

Values = handles.checkbox2_save_label.Value;

if Values
    set(handles.checkbox3_filename_erpname,'Enable','on');
    ALLERP = handles.ALLERP;
    EEGArray = handles.EEGArray;
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
        DataString{Numoferpset,2} = char(ALLERP(EEGArray(Numoferpset)).filename);
    end
    set(handles.uitable1_erpset_table,'Data',DataString);
else
    set(handles.checkbox3_filename_erpname,'Enable','off');
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString_before{Numoferpset,2} = '';
    end
    set(handles.uitable1_erpset_table,'Data',DataString_before);
    set(handles.uitable1_erpset_table,'Enable','on');
end
if handles.checkbox2_save_label.Value
    set(handles.uitable1_erpset_table,'Enable','on');
    set(handles.edit_path,'Enable','on');
    set(handles.pushbutton_path_browse,'Enable','on');
else
    set(handles.uitable1_erpset_table,'Enable','on');
    set(handles.edit_path,'Enable','off');
    set(handles.pushbutton_path_browse,'Enable','off');
end



% --- Executes on button press in checkbox3_filename_erpname.
function checkbox3_filename_erpname_Callback(hObject, eventdata, handles)
Value_filename_erpname = handles.checkbox3_filename_erpname.Value;

set(handles.uitable1_erpset_table,'Enable','off');
DataString_before = handles.uitable1_erpset_table.Data;

for Numoferpset = 1:size(DataString_before,1)
    
    DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
    fileName = char(DataString_before{Numoferpset,1});
    if isempty(fileName)
        fileName = strcat(num2str(Numoferpset),'set');
    end
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(EEGArray(Numoferpset)),'.erp'];
    else
        file_name = [file_name,'.erp'];
    end
    DataString{Numoferpset,2} = file_name;
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});





% --- Executes when entered data in editable cell(s) in uitable1_erpset_table.
function uitable1_erpset_table_CellEditCallback(hObject, eventdata, handles)

DataString = handles.uitable1_erpset_table.Data;
EEGArray = handles.EEGArray;
if size(DataString,1) < numel(EEGArray)
    msgboxText =  'EEG name and filename for one of erpsets are empty at least! Please give name to eegname and filename';
    title = 'EStudio: f_ERP_save_multi_file empty erpname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(EEGArray)
    if  isempty(DataString{Numofselected,1})
        msgboxText =  'Erpname for one of erpsets is empty at least! Please give name to that erpset';
        title = 'EStudio: f_ERP_save_multi_file empty eegname';
        errorfound(msgboxText, title);
        return
    end
end



% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% beep;
disp('User selected Cancel.');
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);




% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)

Data_String =handles.uitable1_erpset_table.Data;
ALLERP = handles.ALLERP;
EEGArray = handles.EEGArray;

if size(Data_String,1)< numel(EEGArray)%
    msgboxText =  'ERP name for one of erpsets is empty at least! Please give a name';
    title = 'EStudio: f_ERP_save_multi_file empty eegname';
    errorfound(msgboxText, title);
    return
end


if size(Data_String,1)> numel(EEGArray)%
    msgboxText =  'More eegname is given. Please delect it!!!';
    title = 'EStudio: f_ERP_save_multi_file empty erpname';
    errorfound(msgboxText, title);
    return
end



for Numofselected = 1:numel(EEGArray)
    if  isempty(Data_String{Numofselected,1})
        msgboxText =  'Erpname for one of erpsets is empty at least! Please give name to that erpset';
        title = 'EStudio: f_ERP_save_multi_file empty erpname';
        errorfound(msgboxText, title);
        return
    end
    
end

pathName = handles.edit_path.String;
if isempty(pathName)
    pathName =cd;
end

for Numoferpset = 1:numel(EEGArray)
    ALLERP(EEGArray(Numoferpset)).setname = Data_String{Numoferpset,1};
    fileName = char(Data_String{Numoferpset,2});
    if isempty(fileName)
        fileName = Data_String{Numoferpset,1};
    end
    
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(EEGArray(Numoferpset)),'.erp'];
    else
        file_name = [file_name,'.erp'];
    end
    
    ALLERP(EEGArray(Numoferpset)).filename = file_name;
    if handles.checkbox2_save_label.Value
        ALLERP(EEGArray(Numoferpset)).filepath = pathName;
    end
    
    if handles.checkbox2_save_label.Value
        ALLERP(EEGArray(Numoferpset)).saved = 'yes';
    else
        ALLERP(EEGArray(Numoferpset)).saved = 'no';
    end
    
end

FilePath = handles.checkbox2_save_label.Value;

handles.output = {ALLERP, FilePath};
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



function edit_path_Callback(hObject, eventdata, handles)


PathName = handles.edit_path.String;





% --- Executes during object creation, after setting all properties.
function edit_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_path_browse.
function pushbutton_path_browse_Callback(hObject, eventdata, handles)


pathName = handles.edit_path.String;
if isempty(pathName)
    pathName =cd;
end
title = 'Select one forlder for saving files in following procedures';
select_path = uigetdir(pathName,title);

if isequal(select_path,0)
    select_path = cd;
end
handles.edit_path.String = select_path;


