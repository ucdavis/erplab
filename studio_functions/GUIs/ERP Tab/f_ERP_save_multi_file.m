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

% Last Modified by GUIDE v2.5 13-Jun-2022 18:55:22

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
    Selected_ERP_label = varargin{2};
    suffix = varargin{3};
catch
    suffix  = '';
    ERPLAB = [];
    ERPLAB.erpname = 'No erpset was selected';
    ERPLAB.filename ='No erpset was selected';
    ERPLAB.event = [];
    ERPLAB.chanlocs = [];
    ERPLAB.nbchan = 0;
    ALLERP(1) = ERPLAB;
    Selected_ERP_label = 1;
end

% handles.erpnameor = erpname;
handles.output = [];
handles.suffix = suffix;

handles.ALLERP = ALLERP;
handles.Selected_ERP_label =Selected_ERP_label;

erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   Save multiple Erpsets GUI'])


% set(handles.checkbox1_suffix,'Value',1);
set(handles.edit_suffix_name,'String',suffix);
set(handles.checkbox2_save_label,'Value',0);

ColumnName_table = {'ERP name','File name'};

set(handles.uitable1_erpset_table,'ColumnName',cellstr(ColumnName_table));
set(handles.uitable1_erpset_table,'RowName',cellstr(num2str(Selected_ERP_label')));


for Numofselectederp = 1:numel(Selected_ERP_label)
    DataString{Numofselectederp,1} = strcat(ALLERP(Selected_ERP_label(Numofselectederp)).erpname,suffix);
    DataString{Numofselectederp,2} = '';
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});
set(handles.uitable1_erpset_table,'Enable','on');
set(handles.checkbox3_filename_erpname,'Enable','off');

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
Selected_ERP_label = handles.Selected_ERP_label;
suffix_edit = handles.edit_suffix_name.String;

if isempty(suffix_edit)
    msgboxText =  'You must enter a suffix at least!';
    title = 'EStudio: f_ERP_save_multi_file() error';
    errorfound(msgboxText, title);
    return
end


DataString_before = handles.uitable1_erpset_table.Data;
for Numofselectederp = 1:numel(Selected_ERP_label)
    DataString{Numofselectederp,1} = strcat(ALLERP(Selected_ERP_label(Numofselectederp)).erpname,suffix_edit);
    DataString{Numofselectederp,2} = DataString_before{Numofselectederp,2};
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
%     for Numofselectederp = 1:size(DataString_before,1)
%         DataString{Numofselectederp,1} = char(strcat(DataString_before{Numofselectederp,1},'-',char(Suffix_string)));
%         DataString{Numofselectederp,2} = DataString_before{Numofselectederp,2};
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
    Selected_ERP_label = handles.Selected_ERP_label;
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numofselectederp = 1:size(DataString_before,1)
        DataString{Numofselectederp,1} = DataString_before{Numofselectederp,1};
        DataString{Numofselectederp,2} = char(ALLERP(Selected_ERP_label(Numofselectederp)).filename);
    end
    set(handles.uitable1_erpset_table,'Data',DataString);
else
    set(handles.checkbox3_filename_erpname,'Enable','off');
    DataString_before = handles.uitable1_erpset_table.Data;
    for Numofselectederp = 1:size(DataString_before,1)
        DataString_before{Numofselectederp,2} = '';
    end
    set(handles.uitable1_erpset_table,'Data',DataString_before);
    set(handles.uitable1_erpset_table,'Enable','on');
end
if handles.checkbox2_save_label.Value
    set(handles.uitable1_erpset_table,'Enable','off');
else
    set(handles.uitable1_erpset_table,'Enable','on');
end



% --- Executes on button press in checkbox3_filename_erpname.
function checkbox3_filename_erpname_Callback(hObject, eventdata, handles)
Value_filename_erpname = handles.checkbox3_filename_erpname.Value;

set(handles.uitable1_erpset_table,'Enable','off');
DataString_before = handles.uitable1_erpset_table.Data;

for Numofselectederp = 1:size(DataString_before,1)
    
    DataString{Numofselectederp,1} = DataString_before{Numofselectederp,1};
    fileName = char(DataString_before{Numofselectederp,1});
    if isempty(fileName)
        fileName = strcat(num2str(Numofselectederp),'erp');
    end
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
     file_name = [num2str(Selected_ERP_label(Numofselectederp)),'_ERP.erp'];
    else
     file_name = [file_name,'.erp'];  
    end
    DataString{Numofselectederp,2} = file_name;
end

set(handles.uitable1_erpset_table,'Data',cellstr(DataString));
set(handles.uitable1_erpset_table,'ColumnWidth',{248 248});





% --- Executes when entered data in editable cell(s) in uitable1_erpset_table.
function uitable1_erpset_table_CellEditCallback(hObject, eventdata, handles)

DataString = handles.uitable1_erpset_table.Data;
Selected_ERP_label = handles.Selected_ERP_label;
if size(DataString,1) < numel(Selected_ERP_label)
    msgboxText =  'Erpname and filename for one of erpsets are empty at least! Please give name to erpname and filename';
    title = 'EStudio: f_ERP_save_multi_file empty erpname';
    errorfound(msgboxText, title);
    return
end

for Numofselected = 1:numel(Selected_ERP_label)
    if  isempty(DataString{Numofselected,1})
        msgboxText =  'Erpname for one of erpsets is empty at least! Please give name to that erpset';
        title = 'EStudio: f_ERP_save_multi_file empty erpname';
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
% suffix = strtrim(get(handles.edit_suffix_name, 'String'));
% if handles.checkbox1_suffix.Value
%     if isempty(suffix)
%         msgboxText =  'You must enter suffix at least!';
%         title = 'EStudio: f_ERP_save_multi_file empty erpname';
%         errorfound(msgboxText, title);
%         return
%     end
% end

Data_String =handles.uitable1_erpset_table.Data;
ALLERP = handles.ALLERP;
Selected_ERP_label = handles.Selected_ERP_label;

if size(Data_String,1)< numel(Selected_ERP_label)%
    msgboxText =  'Erpname for one of erpsets is empty at least! Please give a name';
    title = 'EStudio: f_ERP_save_multi_file empty erpname';
    errorfound(msgboxText, title);
    return
end


if size(Data_String,1)> numel(Selected_ERP_label)%
    msgboxText =  'More erpname is given. Please delect it!!!';
    title = 'EStudio: f_ERP_save_multi_file empty erpname';
    errorfound(msgboxText, title);
    return
end



for Numofselected = 1:numel(Selected_ERP_label)
    if  isempty(Data_String{Numofselected,1})
        msgboxText =  'Erpname for one of erpsets is empty at least! Please give name to that erpset';
        title = 'EStudio: f_ERP_save_multi_file empty erpname';
        errorfound(msgboxText, title);
        return
    end
    
end



for Numofselectederp = 1:numel(Selected_ERP_label)
    ALLERP(Selected_ERP_label(Numofselectederp)).erpname = Data_String{Numofselectederp,1};
    fileName = char(Data_String{Numofselectederp,2});
    if isempty(fileName)
      fileName = Data_String{Numofselectederp,1};  
    end
    
    [pathstr, file_name, ext] = fileparts(fileName);
    if isempty(file_name)
     file_name = [num2str(Selected_ERP_label(Numofselectederp)),'_ERP.erp'];
    else
     file_name = [file_name,'.erp'];  
    end
    
    ALLERP(Selected_ERP_label(Numofselectederp)).filename = file_name;
    if handles.checkbox2_save_label.Value
        ALLERP(Selected_ERP_label(Numofselectederp)).filepath = cd;
    end
    
    if handles.checkbox2_save_label.Value
        ALLERP(Selected_ERP_label(Numofselectederp)).saved = 'yes';
    else
        ALLERP(Selected_ERP_label(Numofselectederp)).saved = 'no';
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
