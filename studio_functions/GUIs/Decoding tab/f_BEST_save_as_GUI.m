function varargout = f_BEST_save_as_GUI(varargin)
% F_BEST_SAVE_AS_GUI MATLAB code for f_BEST_save_as_GUI.fig
%      F_BEST_SAVE_AS_GUI, by itself, creates a new F_BEST_SAVE_AS_GUI or raises the existing
%      singleton*.
%
%      H = F_BEST_SAVE_AS_GUI returns the handle to a new F_BEST_SAVE_AS_GUI or the handle to
%      the existing singleton*.
%
%      F_BEST_SAVE_AS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_BEST_SAVE_AS_GUI.M with the given input arguments.
%
%      F_BEST_SAVE_AS_GUI('Property','Value',...) creates a new F_BEST_SAVE_AS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_BEST_save_as_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_BEST_save_as_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_BEST_save_as_GUI

% Last Modified by GUIDE v2.5 20-Jun-2024 10:16:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_BEST_save_as_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_BEST_save_as_GUI_OutputFcn, ...
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


% --- Executes just before f_BEST_save_as_GUI is made visible.
function f_BEST_save_as_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_BEST_save_as_GUI

try
    ALLERP  = varargin{1};
    EEGArray = varargin{2};
    suffix = varargin{3};
    
catch
    suffix  = '';
    EEGLAB = [];
    EEGLAB.bestname = 'No bestset was selected';
    EEGLAB.filename ='No bestset was selected';
    EEGLAB.event = [];
    EEGLAB.chanlocs = [];
    EEGLAB.nbchan = 0;
    ALLERP(1) = EEGLAB;
    EEGArray = 1;
    
end
try
    ERPIndex = varargin{4};
catch
    ERPIndex=1;
end
try
    filepath = varargin{5};
catch
    filepath =  [cd,filesep];
end
handles.filepath = filepath;
handles.ERPIndex = ERPIndex;
% handles.erpnameor = erpname;
handles.output = [];
handles.suffix = suffix;

handles.ALLERP = ALLERP;
handles.EEGArray =EEGArray;

erplab_default_values;
version = erplabver;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Save bestsets as GUI'])


% set(handles.checkbox1_suffix,'Value',1);
set(handles.edit_suffix_name,'String',suffix);
set(handles.checkbox2_save_label,'Value',1);
set(handles.checkbox2_save_label,'Enable','off');
ColumnName_table = {'BEST name','File name'};

set(handles.uitable1_erpset_table,'ColumnName',cellstr(ColumnName_table));
set(handles.uitable1_erpset_table,'RowName',cellstr(num2str(EEGArray')));
handles.uitable1_erpset_table.ColumnEditable(1) = true;
handles.uitable1_erpset_table.ColumnEditable(2) = true;
for Numoferpset = 1:numel(EEGArray)
    %     if ERPIndex==1
    DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).bestname,suffix);
    %     else
    %         DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).setname,suffix);
    %     end
    %     if ERPIndex==1
    DataString{Numoferpset,2} = [strcat(ALLERP(EEGArray(Numoferpset)).bestname,suffix),'.best'];
    %     else
    %         DataString{Numoferpset,2} = [strcat(ALLERP(EEGArray(Numoferpset)).setname,suffix),'.set'];
    %     end
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{350 350});
set(handles.uitable1_erpset_table,'Enable','on');
set(handles.checkbox3_filename_erpname,'Enable','on','Value',1);
set(handles.edit_path,'Enable','on','String',filepath);
set(handles.pushbutton_path_browse,'Enable','on');


% handles.uitable1_erpset_table.DisplayDataChangedFcn = {@tableDisplayDataChangedFcn,hObject,handles};
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
% handles.checkbox3_filename_erpname.BackgroundColor = [1 1 1];
% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_BEST_save_as_GUI_OutputFcn(hObject, eventdata, handles)

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

DataString_before = handles.uitable1_erpset_table.Data;
for Numoferpset = 1:numel(EEGArray)
    DataString{Numoferpset,1} = strcat( ALLERP(EEGArray(Numoferpset)).bestname,suffix_edit);
    if handles.checkbox3_filename_erpname.Value==1
        DataString{Numoferpset,2}   =  [DataString{Numoferpset,1},'.best'];
    else
        DataString{Numoferpset,2} = DataString_before{Numoferpset,2};
    end
end
set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
% set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});
set(handles.uitable1_erpset_table,'Enable','on');




function edit_suffix_name_Callback(hObject, eventdata, handles)




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
        fileName = ALLERP(EEGArray(Numoferpset)).filename;
        [pathstr, file_name, ext] = fileparts(fileName);
        
        DataString{Numoferpset,2} = [file_name,'.best'];
    end
    set(handles.uitable1_erpset_table,'Data',DataString);
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = true;
else
    set(handles.checkbox3_filename_erpname,'Enable','off');
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString_before{Numoferpset,2} = '';
    end
    set(handles.uitable1_erpset_table,'Data',DataString_before);
    set(handles.uitable1_erpset_table,'Enable','on');
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = false;
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

% set(handles.uitable1_erpset_table,'Enable','off');
DataString_before = handles.uitable1_erpset_table.Data;

for Numoferpset = 1:size(DataString_before,1)
    DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
    fileName = char(DataString_before{Numoferpset,1});
    if isempty(fileName)
        fileName = strcat(num2str(Numoferpset),'.best');
    end
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(EEGArray(Numoferpset)),'.best'];
    else
        file_name = [file_name,'.best'];
    end
    DataString{Numoferpset,2} = file_name;
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
% set(handles.uitable1_erpset_table,'ColumnWidth',{350 350});

handles.uitable1_erpset_table.ColumnEditable(1) = true;
handles.uitable1_erpset_table.ColumnEditable(2) = true;




% --- Executes when entered data in editable cell(s) in uitable1_erpset_table.
function uitable1_erpset_table_CellEditCallback(hObject, eventdata, handles)

DataString = handles.uitable1_erpset_table.Data;
EEGArray = handles.EEGArray;
if size(DataString,1) < numel(EEGArray)
    msgboxText =  'BESTset name and filename is missing for one of or more of the sets! Please name bestset and filename.';
    title = 'EStudio: f_BEST_save_as_GUI empty bestname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(EEGArray)
    if  isempty(DataString{Numofselected,1})
        msgboxText =  'BESTset name is missing for one for one of or more of the sets! Please name bestset.';
        title = 'EStudio: f_BEST_save_as_GUI empty bestname';
        errorfound(msgboxText, title);
        return
    end
end

if handles.checkbox3_filename_erpname.Value==1
    DataString_before = handles.uitable1_erpset_table.Data;
    
    for Numoferpset = 1:size(DataString_before,1)
        DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
        fileName = char(DataString_before{Numoferpset,1});
        if isempty(fileName)
            fileName = strcat(num2str(Numoferpset),'.best');
        end
        [pathstr, file_name, ext] = fileparts(fileName);
        if isempty(file_name)
            file_name = [num2str(EEGArray(Numoferpset)),'.best'];
        else
            file_name = [file_name,'.best'];
        end
        DataString{Numoferpset,2} = file_name;
    end
    
    set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
end
guidata(hObject, handles);



% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
guidata(hObject, handles);
uiresume(handles.gui_chassis);




% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)

Data_String =handles.uitable1_erpset_table.Data;
ALLERP = handles.ALLERP;
EEGArray = handles.EEGArray;

if size(Data_String,1)< numel(EEGArray)%
    msgboxText =  'BESTset name is missing for one for one of or more of the sets! Please name bestset.';
    title = 'EStudio: f_BEST_save_as_GUI empty bestname';
    errorfound(msgboxText, title);
    return
end


if size(Data_String,1)> numel(EEGArray)%
    msgboxText =  'More bestname is given. Please delect it!!!';
    title = 'EStudio: f_BEST_save_as_GUI empty bestname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(EEGArray)
    if  isempty(Data_String{Numofselected,1})
        msgboxText =  BESTset name is missing for one for one of or more of the sets! Please name bestset.;
        title = 'EStudio: f_BEST_save_as_GUI empty bestname';
        errorfound(msgboxText, title);
        return
    end
    
end

pathName = handles.edit_path.String;
if isempty(pathName)
    pathName =cd;
end

for Numoferpset = 1:numel(EEGArray)
    %     if handles.ERPIndex==1
    ALLERP(EEGArray(Numoferpset)).bestname = Data_String{Numoferpset,1};
    %     else
    %         ALLERP(EEGArray(Numoferpset)).setname = Data_String{Numoferpset,1};
    %     end
    fileName = char(Data_String{Numoferpset,2});
    if isempty(fileName)
        fileName = Data_String{Numoferpset,1};
    end
    
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(EEGArray(Numoferpset)),'.best'];
    else
        file_name = [file_name,'.best'];
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
handles.filepath = PathName;




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
title = 'Select one folder to save your files to.';
select_path = uigetdir(pathName,title);

if isequal(select_path,0)
    select_path = [cd,filesep];
end
handles.filepath = select_path;
handles.edit_path.String = select_path;


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)

suffix = handles.suffix;

ALLERP = handles.ALLERP;
EEGArray = handles.EEGArray;
ERPIndex = handles.ERPIndex;
set(handles.checkbox3_filename_erpname,'Enable','on','Value',1);
for Numoferpset = 1:numel(EEGArray)
    %     if ERPIndex==1
    DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).bestname,suffix);
    %     else
    %         DataString{Numoferpset,1} = strcat(ALLERP(EEGArray(Numoferpset)).bestname,suffix);
    %     end
    %     if ERPIndex==1
    DataString{Numoferpset,2} = [strcat(ALLERP(EEGArray(Numoferpset)).bestname,suffix),'.best'];
    %     else
    %         DataString{Numoferpset,2} = [strcat(ALLERP(EEGArray(Numoferpset)).setname,suffix),'.best'];
    %     end
end
set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
