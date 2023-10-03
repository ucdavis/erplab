function varargout = f_change_chan_name_GUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_change_chan_name_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_change_chan_name_GUI_OutputFcn, ...
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

%-----------------------------------------------------------------------------------
function f_change_chan_name_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
    listname = varargin{1};
catch
    for ii = 1:100
        listname{ii,1} = num2str(ii);
    end
end
for ii = 1:numel(listname)
    listname1{ii,1}=  listname{ii};
end
listname = listname1;

try
    listnameOlder = varargin{2};
catch
    listnameOlder = listname;
end

for ii = 1:numel(listnameOlder)
    listnameOlder1{ii,1}=  listnameOlder{ii};
end
listnameOlder = listnameOlder1;

try
    titlename = varargin{3};
catch
    erplab_studio_default_values;
    version = erplabstudiover;
    titlename = ['ERPLAB',32,num2str(version),32,'Change Channel Name'];
end

[Numrows,Numcolumns]  = size(listname);
for Numofrows = 1:Numrows
    for Numofcolumns = 1:2
        try
            if Numofcolumns==2
                GridinforData{Numofrows,Numofcolumns} = char(listnameOlder{Numofrows,1});
            else
                GridinforData{Numofrows,Numofcolumns} = char(listname{Numofrows});
            end
        catch
            GridinforData{Numofrows,Numofcolumns} = 'None';
        end
    end
end



ColumnEditable =[0,1];
ColumnWidth = {300 300};
ColumnName{1,1} = char(['Current Name']);
ColumnName{1,2} = char(['New Name']);
columFormat = {'char','char'};

for Numofrow = 1:Numrows
    RowsName{Numofrow} = char(['Ch',num2str(Numofrow)]);
end

%
% Color GUI
%
handles = painterplab(handles);
% [version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
% set(handles.gui_chassis, 'Color', ColorBviewer_def);
%
% Set font size
%
handles = setfonterplab(handles);

% Update handles structure
handles = setfonterplabestudio(handles);



guidata(hObject, handles);
set(handles.uitable1_layout,'Data',GridinforData);
handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
handles.uitable1_layout.ColumnWidth = ColumnWidth;
handles.uitable1_layout.ColumnName = ColumnName;
handles.uitable1_layout.RowName = RowsName;
handles.uitable1_layout.ColumnFormat = columFormat;
set(handles.gui_chassis, 'Name', titlename, 'WindowStyle','modal');
handles.uitable1_layout.BackgroundColor = [1 1 1];
% UIWAIT makes f_change_chan_name_GUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%-----------------------------------------------------------------------------------
function varargout = f_change_chan_name_GUI_OutputFcn(hObject, eventdata, handles)
try
    varargout{1} = handles.output;
catch
    varargout{1} = [];
end
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%----------------------------------------------------------------------------------
% function listbox_list_Callback(hObject, eventdata, handles)
%
% %----------------------------------------------------------------------------------
% function listbox_list_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
% end

%----------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
%----------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

Data = get(handles.uitable1_layout, 'Data');

for ii = 1:size(Data,1)
    if isempty(Data{ii,2})
        Chanlabels{ii,1} = 'None';
    else
        Chanlabels{ii,1} = Data{ii,2} ;
    end
end

handles.output = Chanlabels;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%----------------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.gui_chassis);
else
    % The GUI is no longer waiting, just close it
    delete(handles.gui_chassis);
end


% --- Executes on button press in pushbutton_default.
function pushbutton_default_Callback(hObject, eventdata, handles)
Data = handles.uitable1_layout.Data;
for ii = 1:size(Data,1)
    Data{ii,2}=Data{ii,1};
end
set(handles.uitable1_layout,'Data',Data);

