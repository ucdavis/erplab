function varargout = f_BEST_save_multi_file(varargin)
% F_BEST_SAVE_MULTI_FILE MATLAB code for f_BEST_save_multi_file.fig
%      F_BEST_SAVE_MULTI_FILE, by itself, creates a new F_BEST_SAVE_MULTI_FILE or raises the existing
%      singleton*.
%
%      H = F_BEST_SAVE_MULTI_FILE returns the handle to a new F_BEST_SAVE_MULTI_FILE or the handle to
%      the existing singleton*.
%
%      F_BEST_SAVE_MULTI_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_BEST_SAVE_MULTI_FILE.M with the given input arguments.
%
%      F_BEST_SAVE_MULTI_FILE('Property','Value',...) creates a new F_BEST_SAVE_MULTI_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_BEST_save_multi_file_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_BEST_save_multi_file_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_BEST_save_multi_file

% Last Modified by GUIDE v2.5 25-Jun-2024 08:23:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_BEST_save_multi_file_OpeningFcn, ...
    'gui_OutputFcn',  @f_BEST_save_multi_file_OutputFcn, ...
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


% --- Executes just before f_BEST_save_multi_file is made visible.
function f_BEST_save_multi_file_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_BEST_save_multi_file

try
    ALLBEST  = varargin{1};
    BESTArray = varargin{2};
    suffix = varargin{3};

catch
    suffix  = '';
    BEST = [];
    BEST.bestname = 'No bestset was selected';
    BEST.filename ='No bestset was selected';
    BEST.event = [];
    BEST.chanlocs = [];
    BEST.nbchan = 0;
    ALLBEST(1) = BEST;
    BESTArray = 1;

end
try
    ERPIndex = varargin{4};
catch
    ERPIndex=1;
end
handles.ERPIndex = ERPIndex;
% handles.erpnameor = erpname;
handles.output = [];
handles.suffix = suffix;

handles.ALLBEST = ALLBEST;
handles.BESTArray =BESTArray;


erplab_default_values;
version = erplabver;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Save multiple bestsets GUI'])


% set(handles.checkbox1_suffix,'Value',1);
set(handles.edit_suffix_name,'String',suffix);
set(handles.checkbox2_save_label,'Value',0);

ColumnName_table = {'BEST name','File name'};

set(handles.uitable1_erpset_table,'ColumnName',cellstr(ColumnName_table));
set(handles.uitable1_erpset_table,'RowName',cellstr(num2str(BESTArray')));
handles.uitable1_erpset_table.ColumnEditable(1) = true;
handles.uitable1_erpset_table.ColumnEditable(2) = false;
for Numofbestset = 1:numel(BESTArray)
    DataString{Numofbestset,1} = strcat(ALLBEST(BESTArray(Numofbestset)).bestname,suffix);
    DataString{Numofbestset,2} = '';
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{350 350});
set(handles.uitable1_erpset_table,'Enable','on');
set(handles.checkbox3_filename_erpname,'Enable','off');
set(handles.edit_path,'Enable','off','String','');
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
% handles.checkbox3_filename_erpname.BackgroundColor = [1 1 1];
% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_BEST_save_multi_file_OutputFcn(hObject, eventdata, handles)

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
ALLBEST = handles.ALLBEST;
BESTArray = handles.BESTArray;
suffix_edit = handles.edit_suffix_name.String;

DataString_before = handles.uitable1_erpset_table.Data;
for Numofbestset = 1:numel(BESTArray)
    DataString{Numofbestset,1} = strcat(ALLBEST(BESTArray(Numofbestset)).bestname,suffix_edit);
    if handles.checkbox3_filename_erpname.Value==0
        DataString{Numofbestset,2} = DataString_before{Numofbestset,2};
    else
        DataString{Numofbestset,2} =  [DataString{Numofbestset,1},'.best'];
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
    set(handles.checkbox3_filename_erpname,'Enable','on');
    ALLBEST = handles.ALLBEST;
    BESTArray = handles.BESTArray;
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numofbestset = 1:size(DataString_before,1)
        DataString{Numofbestset,1} = DataString_before{Numofbestset,1};
        fileName = ALLBEST(BESTArray(Numofbestset)).filename;
        if isempty(fileName) || ~(ischar(fileName) || isstring(fileName))
            % filename not set (e.g. BEST created in memory), fall back to erpname
            fileName = ALLBEST(BESTArray(Numofbestset)).erpname;
            if isempty(fileName) || ~(ischar(fileName) || isstring(fileName))
                fileName = '';
            end
        end
        [~, file_name, ~] = fileparts(fileName);

        DataString{Numofbestset,2} = [file_name,'.best'];
    end
    set(handles.uitable1_erpset_table,'Data',DataString);
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = true;
else
    set(handles.checkbox3_filename_erpname,'Enable','off');
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numofbestset = 1:size(DataString_before,1)
        DataString_before{Numofbestset,2} = '';
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

for Numofbestset = 1:size(DataString_before,1)
    DataString{Numofbestset,1} = DataString_before{Numofbestset,1};
    fileName = char(DataString_before{Numofbestset,1});
    if isempty(fileName)
        fileName = strcat(num2str(Numofbestset),'.best');
    end
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(BESTArray(Numofbestset)),'.best'];
    else
        file_name = [file_name,'.best'];
    end
    DataString{Numofbestset,2} = file_name;
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
% set(handles.uitable1_erpset_table,'ColumnWidth',{350 350});
if handles.checkbox3_filename_erpname.Value==0
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = false;
else
    handles.uitable1_erpset_table.ColumnEditable(1) = true;
    handles.uitable1_erpset_table.ColumnEditable(2) = true;
end





% --- Executes when entered data in editable cell(s) in uitable1_erpset_table.
function uitable1_erpset_table_CellEditCallback(hObject, eventdata, handles)

DataString = handles.uitable1_erpset_table.Data;
BESTArray = handles.BESTArray;
if size(DataString,1) < numel(BESTArray)
    msgboxText =  'BEST name and filename for one of bestsets are empty at least! Please give name to bestname and filename';
    title = 'EStudio: f_BEST_save_multi_file empty erpname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(BESTArray)
    if  isempty(DataString{Numofselected,1})
        msgboxText =  'Bestname for one of bestsets is empty at least! Please give name to that bestset';
        title = 'EStudio: f_BEST_save_multi_file empty eegname';
        errorfound(msgboxText, title);
        return
    end
end

if handles.checkbox3_filename_erpname.Value==1
    DataString_before = handles.uitable1_erpset_table.Data;

    for Numofbestset = 1:size(DataString_before,1)
        DataString{Numofbestset,1} = DataString_before{Numofbestset,1};
        fileName = char(DataString_before{Numofbestset,1});
        if isempty(fileName)
            fileName = strcat(num2str(Numofbestset),'.best');
        end
        [pathstr, file_name, ext] = fileparts(fileName);
        if isempty(file_name)
            file_name = [num2str(BESTArray(Numofbestset)),'.best'];
        else
            file_name = [file_name,'.best'];
        end
        DataString{Numofbestset,2} = file_name;
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
ALLBEST = handles.ALLBEST;
BESTArray = handles.BESTArray;

if size(Data_String,1)< numel(BESTArray)%
    msgboxText =  'BEST name for one of bestsets is empty at least! Please give a name';
    title = 'EStudio: f_BEST_save_multi_file empty bestname';
    errorfound(msgboxText, title);
    return
end


if size(Data_String,1)> numel(BESTArray)%
    msgboxText =  'More bestname is given. Please delect it!!!';
    title = 'EStudio: f_BEST_save_multi_file empty bestname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(BESTArray)
    if  isempty(Data_String{Numofselected,1})
        msgboxText =  'BEST name for one of bestsets is empty at least! Please give name to that bestset';
        title = 'EStudio: f_BEST_save_multi_file empty bestname';
        errorfound(msgboxText, title);
        return
    end
end

pathName = handles.edit_path.String;
if isempty(pathName)
    pathName =cd;
end

for Numofbestset = 1:numel(BESTArray)

    ALLBEST(BESTArray(Numofbestset)).bestname = Data_String{Numofbestset,1};

    fileName = char(Data_String{Numofbestset,2});
    if isempty(fileName)
        fileName = Data_String{Numofbestset,1};
    end

    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
        file_name = [num2str(BESTArray(Numofbestset)),'.best'];
    else
        file_name = [file_name,'.best'];
    end

    ALLBEST(BESTArray(Numofbestset)).filename = file_name;
    if handles.checkbox2_save_label.Value
        ALLBEST(BESTArray(Numofbestset)).filepath = pathName;
    end

    if handles.checkbox2_save_label.Value
        ALLBEST(BESTArray(Numofbestset)).saved = 'yes';
    else
        ALLBEST(BESTArray(Numofbestset)).saved = 'no';
    end

end

FilePath = handles.checkbox2_save_label.Value;

handles.output = {ALLBEST, FilePath};
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
