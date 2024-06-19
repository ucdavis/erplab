function varargout = f_EEG_saveas_multi_bestfile(varargin)
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_EEG_saveas_multi_bestfile

% Last Modified by GUIDE v2.5 18-Jun-2024 19:50:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_EEG_saveas_multi_bestfile_OpeningFcn, ...
    'gui_OutputFcn',  @f_EEG_saveas_multi_bestfile_OutputFcn, ...
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


% --- Executes just before f_EEG_saveas_multi_bestfile is made visible.
function f_EEG_saveas_multi_bestfile_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_EEG_saveas_multi_bestfile

try
    ALLEEG  = varargin{1};
    EEGArray = varargin{2};
    suffix = varargin{3};
catch
    suffix  = '';
    EEGLAB = [];
    EEGLAB.setname = 'No eegset was selected';
    EEGLAB.filename ='No eegset was selected.best';
    EEGLAB.event = [];
    EEGLAB.chanlocs = [];
    EEGLAB.nbchan = 0;
    ALLEEG(1) = EEGLAB;
    EEGArray = 1;
end
try
    pathName =  varargin{4};
catch
    pathName = [cd,filesep];
end
% handles.setnameor = setname;
handles.output = [];
handles.suffix = suffix;

handles.ALLEEG = ALLEEG;
handles.EEGArray =EEGArray;
handles.pathName= pathName;
erplab_default_values;
version = erplabver;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Save BESTsets as GUI'])

handles.edit_path.String = pathName;
handles.edit_path.Enable = 'off';
% set(handles.checkbox1_suffix,'Value',1);
set(handles.edit_suffix_name,'String',suffix);
set(handles.checkbox2_save_label,'Value',0,'Enable','on');

ColumnName_table = {'BEST name','File name'};

set(handles.uitable1_erpset_table,'ColumnName',cellstr(ColumnName_table));
set(handles.uitable1_erpset_table,'RowName',cellstr(num2str(EEGArray')));
handles.uitable1_erpset_table.ColumnEditable(1) = true;
handles.uitable1_erpset_table.ColumnEditable(2) = true;
for Numoferpset = 1:numel(EEGArray)
    DataString{Numoferpset,1} = strcat(ALLEEG(EEGArray(Numoferpset)).setname,suffix);
    DataString{Numoferpset,2} = '';%[strcat(ALLEEG(EEGArray(Numoferpset)).setname,suffix),'.best'];
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{350 350});
set(handles.uitable1_erpset_table,'Enable','on');
set(handles.checkbox3_filename_setname,'Enable','off','Value',1);
set(handles.pushbutton_path_browse,'Enable','off');


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
% handles.checkbox3_filename_setname.BackgroundColor = [1 1 1];
% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_EEG_saveas_multi_bestfile_OutputFcn(hObject, eventdata, handles)

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
ALLEEG = handles.ALLEEG;
EEGArray = handles.EEGArray;
suffix_edit = handles.edit_suffix_name.String;


DataString_before = handles.uitable1_erpset_table.Data;
for Numoferpset = 1:numel(EEGArray)
    
    DataString{Numoferpset,1} = strcat(DataString_before{Numoferpset,1},suffix_edit);
    if handles.checkbox3_filename_setname.Value==1
        DataString{Numoferpset,2} =  [DataString{Numoferpset,1},'.best'];
    else
        DataString{Numoferpset,2} = DataString_before{Numoferpset,2};
    end
end
set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
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
    set(handles.checkbox3_filename_setname,'Enable','on');
    ALLEEG = handles.ALLEEG;
    EEGArray = handles.EEGArray;
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numoferpset = 1:size(DataString_before,1)
        DataString{Numoferpset,1} = DataString_before{Numoferpset,1};
        DataString{Numoferpset,2} = [char(DataString{Numoferpset,1}),'.best'];
    end
    set(handles.uitable1_erpset_table,'Data',DataString);
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = true;
else
    set(handles.checkbox3_filename_setname,'Enable','off');
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



% --- Executes on button press in checkbox3_filename_setname.
function checkbox3_filename_setname_Callback(hObject, eventdata, handles)
Value_filename_setname = handles.checkbox3_filename_setname.Value;

% set(handles.uitable1_erpset_table,'Enable','off');
DataString_before = handles.uitable1_erpset_table.Data;
if Value_filename_setname==1
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
end





% --- Executes when entered data in editable cell(s) in uitable1_erpset_table.
function uitable1_erpset_table_CellEditCallback(hObject, eventdata, handles)

DataString = handles.uitable1_erpset_table.Data;
EEGArray = handles.EEGArray;
if size(DataString,1) < numel(EEGArray)
    msgboxText =  'BEST name and filename for one of bestsets are empty at least! Please give name to bestname and filename';
    title = 'EStudio: f_EEG_saveas_multi_bestfile empty bestname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(EEGArray)
    if  isempty(DataString{Numofselected,1})
        msgboxText =  'BEST setname for one of bestsets is empty at least! Please give name to that bestset';
        title = 'EStudio: f_EEG_saveas_multi_bestfile empty bestname';
        errorfound(msgboxText, title);
        return
    end
end

if handles.checkbox3_filename_setname.Value==1
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
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);




% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)

Data_String =handles.uitable1_erpset_table.Data;
ALLEEG = handles.ALLEEG;
EEGArray = handles.EEGArray;

if size(Data_String,1)< numel(EEGArray)%
    msgboxText =  'BEST name for one of BESTsets is empty at least! Please give a name';
    title = 'EStudio: f_EEG_saveas_multi_bestfile empty BESTname';
    errorfound(msgboxText, title);
    return
end


if size(Data_String,1)> numel(EEGArray)%
    msgboxText =  'More bestname is given. Please delect it!!!';
    title = 'EStudio: f_EEG_saveas_multi_bestfile empty BESTname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(EEGArray)
    if  isempty(Data_String{Numofselected,1})
        msgboxText =  'BEST name for one of bestsets is empty at least! Please give name to that bestset';
        title = 'EStudio: f_EEG_saveas_multi_bestfile empty bestname';
        errorfound(msgboxText, title);
        return
    end
    
end

pathName = handles.edit_path.String;
if isempty(pathName)
    pathName =cd;
end

for Numoferpset = 1:numel(EEGArray)
    ALLEEG(EEGArray(Numoferpset)).setname = Data_String{Numoferpset,1};
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
    
    if handles.checkbox2_save_label.Value
        ALLEEG(EEGArray(Numoferpset)).filepath = pathName;
        ALLEEG(EEGArray(Numoferpset)).filename = file_name;
    else
        ALLEEG(EEGArray(Numoferpset)).filepath ='';
        ALLEEG(EEGArray(Numoferpset)).filename = '';
    end
    
    if handles.checkbox2_save_label.Value
        ALLEEG(EEGArray(Numoferpset)).saved = 'yes';
    else
        ALLEEG(EEGArray(Numoferpset)).saved = 'no';
    end
end

FilePath = handles.checkbox2_save_label.Value;

handles.output = {ALLEEG, FilePath};
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
handles.pathName= PathName;




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
handles.pathName= select_path;
handles.edit_path.String = select_path;


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.checkbox3_filename_setname,'Enable','off','Value',1);
handles.edit_path.String = '';
handles.edit_path.Enable = 'off';
set(handles.edit_path,'Enable','off');
set(handles.pushbutton_path_browse,'Enable','off');
set(handles.checkbox2_save_label,'Value',0,'Enable','on');

suffix = handles.suffix;
ALLEEG = handles.ALLEEG;
EEGArray = handles.EEGArray;
for Numoferpset = 1:numel(EEGArray)
    DataString{Numoferpset,1} = strcat(ALLEEG(EEGArray(Numoferpset)).setname,suffix);
    DataString{Numoferpset,2} = '';
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
