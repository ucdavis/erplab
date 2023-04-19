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
    plotArray = varargin{1};
catch
    for ii = 1:100
        plotArray{ii,1} = ['chan-',num2str(ii)];
    end
end
for jj = 1:length(plotArray)
    plotArrayFormt(jj,1) = {char(plotArray{jj})};
end
plotArrayFormt(length(plotArrayFormt)+1) = {'None'};

try
    plotArrayFormtOlder = varargin{2};
catch
    plotArrayFormtOlder = plotArrayFormt;
end

handles.plotArrayFormtOlder = plotArrayFormtOlder;

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
            GridinforDatadef{Numofrows,Numofcolumns} = char('None');
        else
            GridinforDatadef{Numofrows,Numofcolumns} = char(plotArray{count});
        end
    end
end

try
    GridinforData = varargin{4};
catch
    GridinforData = GridinforDatadef;
end
if isempty(GridinforData)
   GridinforData = GridinforDatadef; 
end

if size(GridinforData,1)~= Numrows || size(GridinforData,2)~= Numcolumns
    GridinforData = GridinforDatadef;
end

% tablePosition = handles.uitable1_layout.Position;
for Numofcolumns = 1:Numcolumns
    if size(plotArrayFormt,1) > size(plotArrayFormt,2)
        columFormat{Numofcolumns} = plotArrayFormt';
    else
        columFormat{Numofcolumns} = plotArrayFormt;
    end
    ColumnEditable(Numofcolumns) =1;
    ColumnName{1,Numofcolumns} = char(['C',num2str(Numofcolumns)]);
    %     ColumnWidth{Numofcolumns} =tablePosition(3)/(Numcolumns+0.2);
end

for Numofrows = 1:Numrows
    RowName{1,Numofrows} = char(['R',num2str(Numofrows)]);
end
set(handles.uitable1_layout,'Data',GridinforData);
handles.uitable1_layout.ColumnEditable = logical(ColumnEditable);
% handles.uitable1_layout.ColumnWidth = ColumnWidth;
handles.uitable1_layout.ColumnName = ColumnName;
handles.uitable1_layout.RowName = RowName;
handles.uitable1_layout.ColumnFormat = columFormat;

%
% Color GUI
%
% handles = painterplab(handles);
[version reldate,ColorBdef,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
set(handles.gui_chassis, 'Color', ColorBviewer_def);
%
% Set font size
%
% handles = setfonterplab(handles);

% Update handles structure



guidata(hObject, handles);

set(handles.gui_chassis, 'Name', 'Plot Organinzation > Grid Layout', 'WindowStyle','modal');

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
plotArrayFormt = handles.plotArrayFormt;
handles.output = {Data,plotArrayFormt};

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


% --- Executes on button press in pushbutton_edit.
function pushbutton_edit_Callback(hObject, eventdata, handles)
plotArrayFormt = handles.plotArrayFormt;
plotArrayFormtOld=handles.plotArrayFormtOlder;
for ii = 1:length(plotArrayFormtOld)-1
    plotArrayFormtOldin{ii,1} = plotArrayFormtOld{ii};
end
[Numrows,Numcolumns]= size(plotArrayFormt);

if Numrows ==1 && Numcolumns>=2
    for Numofcolumns = 1:Numcolumns-1
        plotArrayFormtin{Numofcolumns,1} =   char(plotArrayFormt{Numofcolumns});
    end
elseif Numrows >=2 && Numcolumns==1
    for Numofrows = 1:Numrows-1
        plotArrayFormtin{Numofrows,1} =   char(plotArrayFormt{Numofrows});
    end
else
    return;
end
try
    ERPwaviewerin = evalin('base','ALLERPwaviewer');
    PLOTORG(1) =    ERPwaviewerin.plot_org.Grid;
    PLOTORG(2) = ERPwaviewerin.plot_org.Overlay ;
    PLOTORG(3) = ERPwaviewerin.plot_org.Pages;
catch
    PLOTORG = [1 2 3];
end
changedoutput = editlayoutstringGUI(plotArrayFormtOldin,plotArrayFormtin,PLOTORG);

if isempty(changedoutput)
    return;
end
try
    for Numofrows = 1:size(changedoutput)
        changeStr{Numofrows} = char(changedoutput{Numofrows,2});
    end
catch
    for Numofrows = 1:size(changedoutput)
        changeStr{Numofrows} = char(changedoutput{Numofrows,1});
    end
end

if ~isempty(changeStr)
    columFormat =  handles.uitable1_layout.ColumnFormat;
    columFormatOld = columFormat{1};
    GridinforDataOld = handles.uitable1_layout.Data;
    [Numrows,Numcolumns] = size(GridinforDataOld);
    for Numofrow = 1:Numrows
        for Numofcolumn = 1:Numcolumns
            SingleStr =  char(GridinforDataOld{Numofrow,Numofcolumn});
            [C,IA] = ismember_bc2(SingleStr,columFormatOld);
            if C ==1
                if IA < length(columFormatOld)
                    try
                        GridinforDataOld{Numofrow,Numofcolumn} = char(changeStr{IA});
                    catch
                        GridinforDataOld{Numofrow,Numofcolumn} = char('');
                    end
                elseif IA == length(columFormatOld)
                    GridinforDataOld{Numofrow,Numofcolumn}  = char('None');
                end
            else
                GridinforDataOld{Numofrow,Numofcolumn}  = char('None');
            end
        end
    end
    handles.uitable1_layout.Data = GridinforDataOld;
    changeStr{length(changeStr)+1} = char('None');
    for Numofcolumns = 1:Numcolumns
       handles.uitable1_layout.ColumnFormat{Numofcolumns} = changeStr;
    end
    handles.plotArrayFormt = changeStr;
end
guidata(hObject, handles);
% uiresume(handles.gui_chassis);


