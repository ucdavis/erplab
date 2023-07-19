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
f = waitbar(0.1,'Loading Custom Grid Locations GUI...');
handles.output = [];
try
    plotArrayFormt = varargin{1};
catch
    for ii = 1:100
        plotArrayFormt{ii,1} = ['chan-',num2str(ii)];
        %  plotArrayFormt{ii,1} = [num2str(ii)];
    end
end
plotArrayFormtnew =cell(1000000,1);
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

try
    AllabelArray = varargin{4};
catch
    AllabelArray =plotArrayFormt;
end
handles.AllabelArray = AllabelArray;

% usedIndex = zeros(length(AllabelArray),1);
% for jj = 1:length(AllabelArray)
%     for ii = 1:length(plotArrayFormt)
%         if strcmp(AllabelArray{jj},plotArrayFormt{ii})
%             usedIndex(jj) = 1;
%         end
%     end
% end
% handles.usedIndex = usedIndex;

% f = waitbar(0.2,'Loading Custtom Grid Layout GUI...');
Numrows = plotBox(1);
Numcolumns = plotBox(2);
% GridinforDatadef = cell(Numrows,Numcolumns);
% count = 0;
% for Numofrows = 1:Numrows
%     for Numofcolumns = 1:Numcolumns
%         count = count +1;
%         if count> numel(plotArray)
%             GridinforDatadef{Numofrows,Numofcolumns} = '';
%         else
%             GridinforDatadef{Numofrows,Numofcolumns} = char(plotArray{count});
%         end
%     end
% end

try
    GridinforData = varargin{2};
catch
    %     GridinforData = GridinforDatadef;
    GridinforData ='';
end
handles.GridinforData = GridinforData;
handles.GridinforData_def = GridinforData;
% if isempty(GridinforData)
%     GridinforData = GridinforDatadef;
% end
% if size(GridinforData,1)~= Numrows || size(GridinforData,2)~= Numcolumns
%     GridinforData = GridinforDatadef;
% end

% FonsizeDefault = f_get_default_fontsize();
% % tablePosition = handles.uitable1_layout.Position;
% for Numofcolumns = 1:Numcolumns
%     columFormat{Numofcolumns} = 'char';
%     ColumnEditable(Numofcolumns) =1;
%     ColumnName{1,Numofcolumns} = char(['C',num2str(Numofcolumns)]);
% end
%
% for Numofrows = 1:Numrows
%     RowName{1,Numofrows} = char(['R',num2str(Numofrows)]);
% end
% set(handles.uitable1_layout,'Data',GridinforData);
% handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
% handles.uitable1_layout.ColumnName = ColumnName;
% handles.uitable1_layout.RowName = RowName;
% handles.uitable1_layout.ColumnFormat = columFormat;
% handles.uitable1_layout.FontSize = FonsizeDefault;
% handles.uitable1_layout.CellEditCallback = {@MakerLabels,handles};

% f = waitbar(0.7,'Loading Custtom Grid Layout GUI...');

% [plotArrayFormt] = f_MarkLabels_gridlocations_ERP_Waveiwer(GridinforData,usedIndex,AllabelArray);
% handles.listbox_Labels.String  = '';
% handles.listbox_Labels.String = plotArrayFormt;
% %
% Color GUI
%
% handles = painterplab(handles);
[version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
set(handles.gui_chassis, 'Color', ColorBviewer_def);
handles.textrow5.BackgroundColor = ColorBviewer_def;
handles.text6_columns.BackgroundColor = ColorBviewer_def;
handles.text7_message.BackgroundColor = ColorBviewer_def;
% handles.listbox_Labels.Min = 0;
% handles.listbox_Labels.Max =1;
% handles.listbox_Labels.Enable = 'off';
% handles.listbox_Labels.Value = 1;

handles.text_rownum.String = num2str(Numrows);
handles.edit1_columnsNum.String = num2str(Numcolumns);
handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);

% Data = handles.uitable1_layout.Data;
%
% Data = f_checktable_gridlocations_waviewer(Data,AllabelArray);
% try
%     SingleCell = AllabelArray{handles.listbox_Labels.Value};
% catch
%     SingleCell = AllabelArray{1};
% end
% Data = f_add_bgcolor_cell(Data,SingleCell);
% handles.uitable1_layout.Data=Data;
%%

handles = Datacreate(plotBox,GridinforData,plotArrayFormt,AllabelArray,handles);

%
% Set font size
%
handles = setfonterplab(handles);

% Update handles structure

guidata(hObject, handles);

set(handles.gui_chassis, 'Name', 'Plot Organization > Customize Grid Locations', 'WindowStyle','modal');
waitbar(1,f,'Loading Custom Grid Locations GUI: Complete');
try
    close(f);
catch
end
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
AllabelArray=handles.AllabelArray;
Data = f_checktable_gridlocations_waviewer(Data,AllabelArray);

Labels_used = unique_str(Data);
if ~isempty(Labels_used)
    Labels_new ='';
    count = 0;
    for ii = 1:length(Labels_used)
        if ~isempty(Labels_used{ii,1})
            count = count+1;
            Labels_new{count,1} = char(Labels_used{ii,1});
            
        end
    end
    Labels_used = Labels_new;
end

Labels_usedIndex = [];
if ~isempty(Labels_used) && ~isempty(AllabelArray)
    count = 0;
    for ii = 1:length(AllabelArray)
        for jj = 1:length(Labels_used)
            if strcmp(AllabelArray{ii},Labels_used{jj})
                count = count+1;
                Labels_usedIndex(count) = ii;
            end
        end
    end
end
handles.output = {Data,Labels_used,Labels_usedIndex};
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
AllabelArray = handles.AllabelArray ;
usedIndex =  handles.usedIndex;
[LabelStr] = f_MarkLabels_gridlocations_ERP_Waveiwer(Data,usedIndex,AllabelArray);
handles.listbox_Labels.String=LabelStr;
handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);
guidata(hObject, handles);


% --- Executes on selection change in listbox_Labels.
function listbox_Labels_Callback(hObject, eventdata, handles)
handles.text7_message.String = '';
handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);

Data = handles.uitable1_layout.Data;

AllabelArray = handles.AllabelArray ;
Data = f_checktable_gridlocations_waviewer(Data,AllabelArray);
try
    SingleCell = AllabelArray{handles.listbox_Labels.Value};
catch
    SingleCell = AllabelArray{1};
end
Data = f_add_bgcolor_cell(Data,SingleCell);
handles.uitable1_layout.Data=Data;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function listbox_Labels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MakerLabels(~,~, handles)
Data = handles.uitable1_layout.Data;
%%check the changed labels
AllabelArray = handles.AllabelArray ;
[Data, EmptyStr] = f_checktable_gridlocations_waviewer(Data,AllabelArray);
handles.uitable1_layout.Data = Data;
handles.GridinforData = Data;
usedIndex =  handles.usedIndex;
[LabelStr] = f_MarkLabels_gridlocations_ERP_Waveiwer(Data,usedIndex,AllabelArray);
handles.listbox_Labels.String=LabelStr;
if  ~strcmp(EmptyStr,',') && ~strcmp(string(EmptyStr)," ") && ~isempty(EmptyStr)
    handles.text7_message.String = sprintf([EmptyStr,32,'do(es)not match with items in the right panel.']);
else
    handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);
end



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

AllabelArray = handles.AllabelArray ;
usedIndex =  handles.usedIndex;
[LabelStr] = f_MarkLabels_gridlocations_ERP_Waveiwer(GridinforData,usedIndex,AllabelArray);
handles.listbox_Labels.String=LabelStr;
handles.text_rownum.String = num2str(Numrows);
handles.edit1_columnsNum.String = num2str(Numcolumns);
handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);
Data = handles.uitable1_layout.Data;

Data = f_checktable_gridlocations_waviewer(Data,AllabelArray);
try
    SingleCell = AllabelArray{handles.listbox_Labels.Value};
catch
    SingleCell = AllabelArray{1};
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

AllabelArray = handles.AllabelArray;
count1 = 0;
for Numofrow = 1:RowsNum
    for Numofcolumn = 1:columNum
        count1 = count1+1;
        try
            DataNew{Numofrow,Numofcolumn} = DataOld{count1} ;
        catch
            DataNew{Numofrow,Numofcolumn}='';
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
DataNew = f_checktable_gridlocations_waviewer(DataNew,AllabelArray);
usedIndex =  handles.usedIndex;
[LabelStr] = f_MarkLabels_gridlocations_ERP_Waveiwer(DataNew,usedIndex,AllabelArray);
handles.listbox_Labels.String=LabelStr;
handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);
try
    SingleCell = AllabelArray{handles.listbox_Labels.Value};
catch
    SingleCell = AllabelArray{1};
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

AllabelArray = handles.AllabelArray;
count1 = 0;
for Numofrow = 1:RowsNum
    RowName{1,Numofrow} = char(['R',num2str(Numofrow)]);
    for Numofcolumn = 1:columNum
        count1 = count1+1;
        try
            DataNew{Numofrow,Numofcolumn} = DataOld{count1} ;
        catch
            DataNew{Numofrow,Numofcolumn}='';
        end
    end
end
handles.GridinforData = DataNew;
handles.uitable1_layout.RowName = RowName;
handles.uitable1_layout.Data = [];
handles.uitable1_layout.Data=DataNew;
DataNew = f_checktable_gridlocations_waviewer(DataNew,AllabelArray);
usedIndex =  handles.usedIndex;
[LabelStr] = f_MarkLabels_gridlocations_ERP_Waveiwer(DataNew,usedIndex,AllabelArray);
handles.listbox_Labels.String=LabelStr;

handles.text7_message.String = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);
try
    SingleCell = AllabelArray{handles.listbox_Labels.Value};
catch
    SingleCell = AllabelArray{1};
end
DataNew = f_add_bgcolor_cell(DataNew,SingleCell);
handles.uitable1_layout.Data=DataNew;
guidata(hObject, handles);



%%Mark the labels with different colors(blue: unused; black:used;  red:Repeated;* means items were selected in the main GUI)
% function [LabelStrout] = f_MarkLabels_gridlocations_ERP_Waveiwer(Gridata,LabelStr,AllabelArray)
% usedIndex = zeros(length(AllabelArray),1);
% for jj = 1:length(AllabelArray)
%     for ii = 1:length(LabelStr)
%         if strcmp(AllabelArray{jj},LabelStr{ii})
%             usedIndex(jj) = 1;
%         end
%     end
% end
%
% LabelsFlag = [0 0 0];
% for ii = 1:length(AllabelArray)
%     code1 = 0;
%     for jj = 1:size(Gridata,1)
%         for kk = 1:size(Gridata,2)
%             if strcmp(AllabelArray{ii},Gridata{jj,kk})
%                 code1 = code1+1;
%             end
%         end
%     end
%
%     if usedIndex(ii)==1%% the item will be marked with * if the labels was selected
%         %         AllabelArray{ii} = strcat(AllabelArray{ii},'*');
%         Numstr = strcat('*',num2str(ii));
%     else
%         Numstr = strcat(num2str(ii));
%     end
%
%     if code1 ==0
%         LabelStrout{ii} =  ['<HTML><FONT color="blue">',Numstr,'.',32,AllabelArray{ii},'</Font></html>'];
%         LabelsFlag(1) = 1;
%     elseif code1 >1
%         LabelStrout{ii} =  ['<HTML><FONT color="red">',Numstr,'.',32,AllabelArray{ii},'</Font></html>'];
%         LabelsFlag(3) = 1;
%     else
%         LabelStrout{ii} =  ['<HTML><FONT color="black">',Numstr,'.',32,AllabelArray{ii},'</Font></html>'];
%         LabelsFlag(2) = 1;
%     end
% end


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


% function [Data, EPStr]= f_checktable_gridlocations_waviewer(Data,LabelStr)
% countEp = 0;
% EPStr = '';
% for ii = 1:size(Data,1)
%     for jj = 1:size(Data,2)
%         count = 0;
%         for kk = 1:length(LabelStr)
%             Data1=  strrep(Data{ii,jj},'<html><table border=0 width=400 bgcolor=#FFFF00><TR><TD>','');
%             Data1 = strrep(Data1,'</TD></TR> </table>','');
%             Data{ii,jj} = char(Data1);
%             if strcmp(strtrim(char(LabelStr{kk})),strtrim(char(Data{ii,jj})))
%                 Data{ii,jj} = char(LabelStr{kk});
%                 count = count +1;
%             end
%         end
%         if count==0
%             countEp = countEp+1;
%             if countEp==1
%                 if ischar(Data{ii,jj})
%                     if ~isempty(Data{ii,jj})
%                     EPStr = char(Data{ii,jj});
%                     end
%                 elseif isnumeric(Data{ii,jj})
%                     if ~isempty(Data{ii,jj})
%                     EPStr = num2str(Data{ii,jj});
%                     end
%                 end
%             else
%                 if ischar(Data{ii,jj})
%                     if ~isempty(Data{ii,jj})
%                     EPStr = strcat(EPStr,',',char(Data{ii,jj}));
%                     end
%                 elseif isnumeric(Data{ii,jj})
%                     if ~isempty(Data{ii,jj})
%                     EPStr = strcat(EPStr,',',num2str(Data{ii,jj}));
%                     end
%                 end
%             end
%             Data{ii,jj} = '';
%         end
%     end
% end



function Labels_used = unique_str(Data)
Labels_used{1,1} = Data{1,1};
for ii = 1:size(Data,1)
    for jj = 1:size(Data,2)
        if ismember_bc2(Data{ii,jj}, Labels_used)
        else
            if ~isempty(char(Data{ii,jj}))
                Labels_used{length(Labels_used)+1,1} = Data{ii,jj};
            end
        end
    end
end


% --- Executes on button press in pushbutton6_import.
function pushbutton6_import_Callback(hObject, eventdata, handles)

[filename, filepath] = uigetfile('*.txt', ...
    'Load Gird Locations', ...
    'MultiSelect', 'off');
if isequal(filename,0)
    disp('User selected Cancel');
    return;
end
try
    %     DataInput = importdata([filepath,filename]);%%There are some errors
    %     when using importdata
    DataInput =  readcell([filepath,filename]);
    CellNum=2;
catch
    
    DataInput =  readcell([filepath,filename]);
    handles.text7_message.String = sprintf(['Cannot import:',filepath,filename]);
    return;
    CellNum=2;
end
if isempty(DataInput)
    handles.text7_message.String = sprintf(['The file is empty.']);
    return;
end

DataOutput = f_gridlocation_transcell(DataInput,CellNum);

AllabelArray = handles.AllabelArray;
[Data,EmptyStr] = f_checktable_gridlocations_waviewer(DataOutput,AllabelArray);
handles.GridinforData = Data;
try
    SingleCell = AllabelArray{handles.listbox_Labels.Value};
catch
    SingleCell = AllabelArray{1};
end
DataNew = f_add_bgcolor_cell(Data,SingleCell);

handles.uitable1_layout.Data = DataNew;
handles.edit1_columnsNum.String = num2str(size(Data,2));
handles.text_rownum.String  = num2str(size(Data,1));
Numcolumns =size(Data,2);
Numrows = size(Data,1);
for Numofcolumns = 1:Numcolumns
    columFormat{Numofcolumns} = 'char';
    ColumnEditable(Numofcolumns) =1;
    ColumnName{1,Numofcolumns} = char(['C',num2str(Numofcolumns)]);
end

for Numofrows = 1:Numrows
    RowName{1,Numofrows} = char(['R',num2str(Numofrows)]);
end
handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
handles.uitable1_layout.ColumnName = ColumnName;
handles.uitable1_layout.RowName = RowName;
handles.uitable1_layout.ColumnFormat = columFormat;
if   ~strcmp(EmptyStr,',') && ~strcmp(string(EmptyStr)," ") && ~isempty(EmptyStr)
    handles.text7_message.String = sprintf([EmptyStr,32,'do(es)not match with items in the right panel.']);
end
DataNew=handles.GridinforData;
usedIndex =  handles.usedIndex;
[LabelStr] = f_MarkLabels_gridlocations_ERP_Waveiwer(DataNew,usedIndex,AllabelArray);
handles.listbox_Labels.String=LabelStr;






function DataOutput = f_gridlocation_transcell(DataInput,CellNum)
if CellNum~=1
    if strcmpi(DataInput{1,size(DataInput,2)},'<missing>')
        for ii = 1:size(DataInput,1)
            for jj = 1:size(DataInput,2)-1
                DataInputTras{ii,jj} = DataInput{ii,jj};
            end
        end
        DataInput = DataInputTras;
    end
    if strcmpi(DataInput{size(DataInput,1),1},'<missing>')
        for ii = 1:size(DataInput,1)-1
            for jj = 1:size(DataInput,2)
                DataInputTras1{ii,jj} = DataInput{ii,jj};
            end
        end
        DataInput = DataInputTras1;
    end
end

DataOutput = cell(size(DataInput,1),size(DataInput,2));
if CellNum==1
    if iscell(DataInput)
        for ii =1:size(DataInput,1)
            chanlabels=regexp(DataInput{ii,1},'.*?\s+', 'match');
            DataNum(ii) = length(chanlabels);
        end
        for  ii =1:size(DataInput,1)
            for jj = 1:max(DataNum(:))
                DataOutput{ii,jj} = char('');
            end
        end
        for ii =1:size(DataInput,1)
            chanlabels=regexp(DataInput{ii,1},'.*?\s+', 'match');
            for jj = 1:length(chanlabels)
                if ischar(chanlabels{jj})
                    DataOutput{ii,jj} = strtrim(char(chanlabels{jj}));
                elseif isnumeric(chanlabels{jj})
                    DataOutput{ii,jj} = num2str(chanlabels{jj});
                else
                end
            end
        end
        return;
    end
else
    for ii = 1:size(DataInput,1)
        for jj = 1:size(DataInput,2)
            if ~ismissing(DataInput{ii,jj})
                if ~isempty(DataInput{ii,jj})
                    if ischar(DataInput{ii,jj})
                        DataOutput{ii,jj} = char(DataInput{ii,jj});
                    elseif isnumeric(DataInput{ii,jj})
                        if isnan(DataInput{ii,jj})
                            DataOutput{ii,jj} = char('');
                        else
                            DataOutput{ii,jj} = char(num2str(DataInput{ii,jj}));
                        end
                    else
                        DataOutput{ii,jj} = char('');
                    end
                else
                    DataOutput{ii,jj} = char('');
                end
            else
                DataOutput{ii,jj} = char('');
            end
        end
    end
    return;
end

if isnumeric(DataInput)
    for ii = 1:size(DataInput,1)
        for jj = 1:size(DataInput,2)
            DataOutput{ii,jj} = num2str(DataInput(ii,jj));
        end
    end
    return;
end






% --- Executes on button press in pushbutton8_Export.
function pushbutton8_Export_Callback(hObject, eventdata, handles)

pathstr = pwd;
namedef ='GridLocations';
[erpfilename, erppathname, indxs] = uiputfile({'*.txt'}, ...
    ['Save Grid Locations as'],...
    fullfile(pathstr,namedef));
if isequal(erpfilename,0)
    disp('User selected Cancel')
    return
end

[pathstr, erpfilename, ext] = fileparts(erpfilename) ;
ext = '.txt';
erpFilename = char(strcat(erppathname,erpfilename,ext));

AllabelArray = handles.AllabelArray;
fileID = fopen(erpFilename,'w');
Data = handles.uitable1_layout.Data;
Data = f_checktable_gridlocations_waviewer(Data,AllabelArray);
[nrows,ncols] = size(Data);
Data = f_gridlocation_respace_addnan(Data);
formatSpec ='';
for jj = 1:ncols
    formatSpec = strcat(formatSpec,'%s\t',32);
end
formatSpec = strcat(formatSpec,'\n');

for row = 1:nrows
    fprintf(fileID,formatSpec,Data{row,:});
end
fclose(fileID);


function data = f_gridlocation_respace_addnan(data)
[nrows,ncols] =size(data);
for ii = 1:nrows
    for jj = 1:ncols
        labx =  data{ii,jj};
        labx= strrep(char(labx),' ','');
        if ~isempty(labx)
            labx = regexprep(labx,'\\|\/|\*|\#|\$|\@','_');
        else
            labx = 'NaN';
        end
        data{ii,jj} = labx;
    end
end





function handles = Datacreate(plotBox,GridinforData,plotArrayFormt,AllabelArray,handles)
Numrows = plotBox(1);
Numcolumns =  plotBox(2);
FonsizeDefault = f_get_default_fontsize();

usedIndex = zeros(length(AllabelArray),1);
for jj = 1:length(AllabelArray)
    for ii = 1:length(plotArrayFormt)
        if strcmp(AllabelArray{jj},plotArrayFormt{ii})
            usedIndex(jj) = 1;
        end
    end
end
handles.usedIndex = usedIndex;

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

[plotArrayFormt] = f_MarkLabels_gridlocations_ERP_Waveiwer(GridinforData,usedIndex,AllabelArray);
handles.listbox_Labels.String  = '';
handles.listbox_Labels.String = plotArrayFormt;

Data = handles.uitable1_layout.Data;

Data = f_checktable_gridlocations_waviewer(Data,AllabelArray);
try
    SingleCell = AllabelArray{handles.listbox_Labels.Value};
catch
    SingleCell = AllabelArray{1};
end
Data = f_add_bgcolor_cell(Data,SingleCell);
handles.uitable1_layout.Data=Data;
handles.listbox_Labels.Min = 0;
handles.listbox_Labels.Max =1;
handles.listbox_Labels.Value = 1;
%


