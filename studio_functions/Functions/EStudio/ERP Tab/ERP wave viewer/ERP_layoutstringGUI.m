function varargout = ERP_layoutstringGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ERP_layoutstringGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ERP_layoutstringGUI_OutputFcn, ...
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
function ERP_layoutstringGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
    plotArrayFormt = varargin{1};
catch
    for ii = 1:100
        plotArrayFormt{ii,1} = ['chan-',num2str(ii)];
    end
end

for jj = 1:length(plotArrayFormt)
    plotArrayFormtnew(jj,1) = {char(plotArrayFormt{jj})};
end
plotArrayFormt = plotArrayFormtnew;
plotArray = plotArrayFormt;

handles.plotArrayFormt = plotArrayFormt;

plotBoxdef = f_getrow_columnautowaveplot(plotArray);
try
    plotBox = varargin{3};
catch
    plotBox = plotBoxdef;
end
Numrows = plotBox(1);
Numcolumns = plotBox(2);
% GridinforDatadef = cell(Numrows,Numcolumns);
count = 0;
for Numofrows = 1:Numrows
    for Numofcolumns = 1:Numcolumns
        count = count +1;
        if count> numel(plotArray)
            GridinforDatadef{Numofrows,Numofcolumns} = '';
        else
            GridinforDatadef{Numofrows,Numofcolumns} = char(plotArray{count});
        end
    end
end

try
    GridinforData = varargin{2};
catch
    GridinforData = GridinforDatadef;
end
handles.GridinforData = GridinforData;
handles.GridinforData_def = GridinforData;
if isempty(GridinforData)
    GridinforData = GridinforDatadef;
end
if size(GridinforData,1)~= Numrows || size(GridinforData,2)~= Numcolumns
    GridinforData = GridinforDatadef;
end
FonsizeDefault = f_get_default_fontsize();
% tablePosition = handles.uitable1_layout.Position;
for Numofcolumns = 1:Numcolumns
    columFormat{Numofcolumns} = 'char';
    ColumnEditable(Numofcolumns) =1;
    ColumnName{1,Numofcolumns} = char(['C',num2str(Numofcolumns)]);
end

for Numofrows = 1:Numrows
    RowName{1,Numofrows} = char(['R',num2str(Numofrows)]);
end
set(handles.uitable1_layout,'Data',GridinforData);
handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
handles.uitable1_layout.ColumnName = ColumnName;
handles.uitable1_layout.RowName = RowName;
handles.uitable1_layout.ColumnFormat = columFormat;
handles.uitable1_layout.FontSize = FonsizeDefault;
handles.uitable1_layout.CellEditCallback = {@MakerLabels,handles};


% oldcolor1 = get(0,'DefaultUicontrolBackgroundColor');
% BackERPLABcolor1 = [0.95 0.95 0.95]; 
%  set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor1);
%  handles.defbgc = oldcolor1;
[plotArrayFormt] = f_MarkLabels_ERP_Waveiwer(GridinforData,plotArrayFormt);
handles.listbox_Labels.String  = '';
handles.listbox_Labels.String = plotArrayFormt;
%
% Color GUI
%
% handles = painterplab(handles);
[version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
set(handles.gui_chassis, 'Color', ColorBviewer_def);
handles.textrow5.BackgroundColor = ColorBviewer_def;
handles.text6_columns.BackgroundColor = ColorBviewer_def;
handles.text7_message.BackgroundColor = ColorBviewer_def;
handles.listbox_Labels.Min = 0;
handles.listbox_Labels.Max =1;
% handles.listbox_Labels.Enable = 'off';
handles.listbox_Labels.Value = 1;

handles.text_rownum.String = num2str(Numrows);
handles.edit1_columnsNum.String = num2str(Numcolumns);
handles.text7_message.String = sprintf([' In the righ panel:\n Items with blue color mean they are unused.\n Items with red color mean they are repeatedly used.\n Items with black color mean they are used one time. ']);

Data = handles.uitable1_layout.Data;
LabelStr=handles.plotArrayFormt;
Data = f_checktable(Data,LabelStr);
try
    SingleCell = LabelStr{handles.listbox_Labels.Value};
catch
    SingleCell = LabelStr{1};
end
Data = f_add_bgcolor_cell(Data,SingleCell);
handles.uitable1_layout.Data=Data;

%
% Set font size
%
 handles = setfonterplab(handles);

% Update handles structure

guidata(hObject, handles);

set(handles.gui_chassis, 'Name', 'Plot Organization > Customize Grid Layout', 'WindowStyle','modal');

% UIWAIT makes ERP_layoutstringGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%-----------------------------------------------------------------------------------
function varargout = ERP_layoutstringGUI_OutputFcn(hObject, eventdata, handles)
try
    varargout{1} = handles.output;
catch
    varargout{1} = [];
end
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)



%----------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


%----------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
Data = handles.uitable1_layout.Data;
LabelStr=handles.plotArrayFormt;
Data = f_checktable(Data,LabelStr);
handles.output = Data;

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


% --- Executes on button press in pushbutton_clearall.
function pushbutton_clearall_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
%%clear all labels
Data = handles.uitable1_layout.Data;
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        Data{ii,jj} = '';
    end
end
handles.GridinforData = Data;
handles.uitable1_layout.Data = Data;
LabelStr=handles.plotArrayFormt;
[LabelStr] = f_MarkLabels_ERP_Waveiwer(Data,LabelStr);
handles.listbox_Labels.String=LabelStr;
guidata(hObject, handles);
% uiresume(handles.gui_chassis);
handles.text7_message.String = sprintf([' In the righ panel:\n Items with blue color mean they are unused.\n Items with red color mean they are repeatedly used.\n Items with black color mean they are used one time. ']);
guidata(hObject, handles);


% --- Executes on selection change in listbox_Labels.
function listbox_Labels_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
handles.text7_message.String = sprintf([' In the righ panel:\n Items with blue color mean they are unused.\n Items with red color mean they are repeatedly used.\n Items with black color mean they are used one time. ']);
Data = handles.uitable1_layout.Data;
LabelStr=handles.plotArrayFormt;
Data = f_checktable(Data,LabelStr);
try
    SingleCell = LabelStr{handles.listbox_Labels.Value};
catch
    SingleCell = LabelStr{1};
end
Data = f_add_bgcolor_cell(Data,SingleCell);
handles.uitable1_layout.Data=Data;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox_Labels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MakerLabels(~,~, handles)
Data = handles.uitable1_layout.Data;
LabelStr=handles.plotArrayFormt;
%%check the changed labels
Data = f_checktable(Data,LabelStr);

handles.GridinforData = Data;
handles.uitable1_layout.Data = Data;
[LabelStr] = f_MarkLabels_ERP_Waveiwer(Data,LabelStr);
handles.listbox_Labels.String=LabelStr;
Data = handles.GridinforData;
LabelStr=handles.plotArrayFormt;
try
    SingleCell = LabelStr{handles.listbox_Labels.Value};
catch
    SingleCell = LabelStr{1};
end
Data = f_add_bgcolor_cell(Data,SingleCell);
handles.uitable1_layout.Data=Data;
% guidata(hObject, handles);


% --- Executes on button press in pushbutton_default.
function pushbutton_default_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
GridinforData = handles.GridinforData_def;
[Numrows,Numcolumns] = size(GridinforData);
for Numofcolumns = 1:Numcolumns
    columFormat{Numofcolumns} = 'char';
    ColumnEditable(Numofcolumns) =1;
    ColumnName{1,Numofcolumns} = char(['C',num2str(Numofcolumns)]);
end

for Numofrows = 1:Numrows
    RowName{1,Numofrows} = char(['R',num2str(Numofrows)]);
end
set(handles.uitable1_layout,'Data',GridinforData);
handles.GridinforData = GridinforData;
handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
handles.uitable1_layout.ColumnName = ColumnName;
handles.uitable1_layout.RowName = RowName;
handles.uitable1_layout.ColumnFormat = columFormat;
LabelStr=handles.plotArrayFormt;
[LabelStr] = f_MarkLabels_ERP_Waveiwer(GridinforData,LabelStr);
handles.listbox_Labels.String=LabelStr;
handles.text_rownum.String = num2str(Numrows);
handles.edit1_columnsNum.String = num2str(Numcolumns);
handles.text7_message.String = sprintf([' In the righ panel:\n Items with blue color mean they are unused.\n Items with red color mean they are repeatedly used.\n Items with black color mean they are used one time. ']);
Data = handles.uitable1_layout.Data;
LabelStr=handles.plotArrayFormt;
Data = f_checktable(Data,LabelStr);
try
    SingleCell = LabelStr{handles.listbox_Labels.Value};
catch
    SingleCell = LabelStr{1};
end
Data = f_add_bgcolor_cell(Data,SingleCell);
handles.uitable1_layout.Data=Data;

guidata(hObject, handles);



function edit1_columnsNum_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
columNum =  str2num(get(hObject,'String'));
Data= handles.uitable1_layout.Data;
if isempty(columNum) || columNum<=0
    handles.text7_message.String = '"Columns" should be a positive number.';
    handles.edit1_columnsNum.String  = size(Data,2);
    return;
end
RowsNum = str2num(handles.text_rownum.String);
if isempty(RowsNum) || RowsNum<=0
    RowsNum = size(Data,1);
end
cuntNum = 0;
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        cuntNum = cuntNum+1;
        DataOld{cuntNum} = char(Data{ii,jj});
    end
end

LabelStr=handles.plotArrayFormt;
count1 = 0;
for Numofrow = 1:RowsNum
    for Numofcolumn = 1:columNum
        count1 = count1+1;
        try
            DataNew{Numofrow,Numofcolumn} = DataOld{count1} ;
        catch
            try
                DataNew{Numofrow,Numofcolumn} = char(LabelStr{count1});
            catch
                DataNew{Numofrow,Numofcolumn}='';
            end
        end
    end
end
for Numofcolumn = 1:columNum
    columFormat{Numofcolumn} = 'char';
    ColumnEditable(Numofcolumn) =1;
    ColumnName{1,Numofcolumn} = char(['C',num2str(Numofcolumn)]);
end
handles.GridinforData = DataNew;
handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
handles.uitable1_layout.ColumnName = ColumnName;
handles.uitable1_layout.ColumnFormat = columFormat;
handles.uitable1_layout.Data=DataNew;
LabelStr=handles.plotArrayFormt;
DataNew = f_checktable(DataNew,LabelStr);
[LabelStr] = f_MarkLabels_ERP_Waveiwer(DataNew,LabelStr);
handles.listbox_Labels.String=LabelStr;
handles.text7_message.String = sprintf([' In the righ panel:\n Items with blue color mean they are unused.\n Items with red color mean they are repeatedly used.\n Items with black color mean they are used one time. ']);

LabelStr=handles.plotArrayFormt;
try
    SingleCell = LabelStr{handles.listbox_Labels.Value};
catch
    SingleCell = LabelStr{1};
end
Data = f_add_bgcolor_cell(DataNew,SingleCell);
handles.uitable1_layout.Data=Data;
guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function edit1_columnsNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_rownum_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
RowsNum =  str2num(get(hObject,'String'));
Data= handles.uitable1_layout.Data;
if isempty(RowsNum) || RowsNum<=0
    handles.text7_message.String = '"Rows" should be a positive number.';
    handles.text_rownum.String  = size(Data,1);
    return;
end
columNum = str2num(handles.edit1_columnsNum.String);
if isempty(columNum) || columNum<=0
    columNum = size(Data,2);
end
cuntNum = 0;
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        cuntNum = cuntNum+1;
        DataOld{cuntNum} = char(Data{ii,jj});
    end
end

LabelStr=handles.plotArrayFormt;
count1 = 0;
for Numofrow = 1:RowsNum
    RowName{1,Numofrow} = char(['R',num2str(Numofrow)]);
    for Numofcolumn = 1:columNum
        count1 = count1+1;
        try
            DataNew{Numofrow,Numofcolumn} = DataOld{count1} ;
        catch
            try
                DataNew{Numofrow,Numofcolumn} = char(LabelStr{count1});
            catch
                DataNew{Numofrow,Numofcolumn}='';
            end
        end
    end
end
handles.GridinforData = DataNew;
handles.uitable1_layout.RowName = RowName;
handles.uitable1_layout.Data = [];
handles.uitable1_layout.Data=DataNew;
LabelStr=handles.plotArrayFormt;
DataNew = f_checktable(DataNew,LabelStr);
[LabelStr] = f_MarkLabels_ERP_Waveiwer(DataNew,LabelStr);
handles.listbox_Labels.String=LabelStr;

handles.text7_message.String = sprintf([' In the righ panel:\n Items with blue color mean they are unused.\n Items with red color mean they are repeatedly used.\n Items with black color mean they are used one time. ']);
% Data = handles.uitable1_layout.Data;
LabelStr=handles.plotArrayFormt;
try
    SingleCell = LabelStr{handles.listbox_Labels.Value};
catch
    SingleCell = LabelStr{1};
end
DataNew = f_add_bgcolor_cell(DataNew,SingleCell);
handles.uitable1_layout.Data=DataNew;
guidata(hObject, handles);



%%Mark the labels with different colors(blue: unused; black:used;  red:Repeated)
function [LabelStr] = f_MarkLabels_ERP_Waveiwer(Gridata,LabelStr)
LabelsFlag = [0 0 0];
for ii = 1:length(LabelStr)
    code1 = 0;
    for jj = 1:size(Gridata,1)
        for kk = 1:size(Gridata,2)
            if strcmp(LabelStr{ii},Gridata{jj,kk})
                code1 = code1+1;
            end
        end
    end
    if code1 ==0
        LabelStr{ii} =  ['<HTML><FONT color="blue">',num2str(ii),'.',32,LabelStr{ii},'</Font></html>'];
        LabelsFlag(1) = 1;
    elseif code1 >1
        LabelStr{ii} =  ['<HTML><FONT color="red">',num2str(ii),'.',32,LabelStr{ii},'</Font></html>'];
        LabelsFlag(3) = 1;
    else
        LabelStr{ii} =  ['<HTML><FONT color="black">',num2str(ii),'.',32,LabelStr{ii},'</Font></html>'];
        LabelsFlag(2) = 1;
    end
end


function Data = f_add_bgcolor_cell(Data,SingleCell)
colergen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table>'];
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        if strcmp(Data{ii,jj},SingleCell)
            hex_color_here = ['#' dec2hex(255,2) dec2hex(255,2) dec2hex(0,2)];
            Data{ii,jj} = colergen(hex_color_here,Data{ii,jj});
        end
    end
    
end


function Data = f_checktable(Data,LabelStr)
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        count = 0;
        for kk = 1:length(LabelStr)
            Data1=  strrep(Data{ii,jj},'<html><table border=0 width=400 bgcolor=#FFFF00><TR><TD>','');
            Data1 = strrep(Data1,'</TD></TR> </table>','');
            Data{ii,jj} = char(Data1);
            if strcmp(LabelStr{kk},Data{ii,jj})
                count = count +1;
            end
        end
        if count==0
            Data{ii,jj} = '';
        end
    end
end

