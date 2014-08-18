% - This function is part of ERPLAB Toolbox -

function varargout = linespecGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @linespecGUI_OpeningFcn, ...
      'gui_OutputFcn',  @linespecGUI_OutputFcn, ...
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

% --------------------------------------------------------------------------------------------
function linespecGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% handles.output = [];
handles.fulltext =[];
handles.output   =[];

try
      def = varargin{1};
catch
      def = [];
end
try
        nbin = varargin{2};
catch
        nbin = 1;
end
try
        lwidth = varargin{3};
catch
        lwidth = 1;
end

defs       = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
defcol     = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w' };

if isempty(def)
        %       defcolor = repmat({'k' 'r' 'b' 'g' 'c' 'm' 'y' },1, nbin);% sorted according 1st erplab's version
        %       defs     = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
        %       d = repmat(defs',1,length(defcolor));
        %       defstyle = reshape(d',1,length(defcolor)*length(defs));
        

        defcolor  = repmat(defcol,1, 1*length(defs));% sorted according 1st erplab's version
        d = repmat(defs',1, 1*length(defcol));
        defstyle = reshape(d',1, numel(d));
else
        defcolor = regexp(def,'\w*','match');
        defcolor = [defcolor{:}];
        defstyle = regexp(def,'\W*','match');
        defstyle = [defstyle{:}];
        if isempty(defcolor)
                defcolor  = repmat(defcol,1, ERP.nbin*length(defs));% sorted according 1st erplab's version
                d = repmat(defs',1, ERP.nbin*length(defcol));
                defstyle = reshape(d',1, numel(d));
        end
        if isempty(defstyle)
                d = repmat(defs',1, ERP.nbin*length(defcol));
                defstyle = reshape(d',1, numel(d));
        end
end

COLORDATA  = colores(defcolor);
STYLEDATA  = estilos(defstyle);
set(handles.popupmenu_lwidth,'String', {1:20})
set(handles.popupmenu_lwidth,'Value', lwidth)

handles.defcolor  = defcolor;
handles.defstyle  = defstyle;
handles.COLORDATA = COLORDATA;
handles.STYLEDATA = STYLEDATA;
handles.nbin = nbin;

setlistbox_color(hObject, handles, COLORDATA, nbin )
setlistbox_style(hObject, handles, STYLEDATA, nbin )

for k=1:length(defcol)
      switch defcol{k}
            case 'k'
                  cwrd = 'BLACK';
            case 'r'
                  cwrd = 'RED';
            case 'b'
                  cwrd = 'BLUE';
            case 'g'
                  cwrd = 'GREEN';
            case 'c'
                  cwrd = 'CYAN';
            case 'm'
                  cwrd = 'MAGENTA';
            case 'y'
                  cwrd = 'YELLOW';
            case 'w'
                  cwrd = 'WHITE';
            otherwise
                  error('color error...')
      end
        set(handles.(['pushbutton_color' num2str(k)]),'UserData', cwrd)
        setcolorbuttons(k, cwrd, hObject, eventdata, handles);
end

% defs       = {'-' '-.' '--' ':'};
% solid   dash-dot   dashed   dotted
for k=1:length(defs)
        switch defs{k}
                case '-'
                        lwrd = 'solid';
                case '-.'
                        lwrd = 'dash-dot';
                case '--'
                        lwrd = 'dashed';
                case ':'
                        lwrd = 'dotted';
                otherwise
                        error('line error...')
        end        
        set(handles.(['pushbutton_line' num2str(k)]),'String', defs{k})
        set(handles.(['pushbutton_line' num2str(k)]),'UserData', lwrd)
        %setlinebuttons(k, lwrd, hObject, eventdata, handles);
end

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Line specifications GUI'],'WindowStyle','modal')

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

% help
% helpbutton

drawnow
uiwait(handles.gui_chassis);

% --------------------------------------------------------------------------------------------
function varargout = linespecGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% --------------------------------------------------------------------------------------------
function setcolorbuttons(ind, colorword, hObject, eventdata, handles)
try
      [img,map]    = imread(['erplab_' colorword '.jpg']);
      colormap(map)      
      [row,column] = size(img);      
      p = get(handles.(['pushbutton_color' num2str(ind)]),'Position');  
      w = p(3); % width
      h = p(4); % hight    
      steprow   = ceil(row/(5*h));
      stecolu   = ceil(column/(10*w));
      imgbutton = img(1:steprow:end,1:stecolu:end,:);
      set(handles.(['pushbutton_color' num2str(ind)]),'String','')
      set(handles.(['pushbutton_color' num2str(ind)]),'CData',imgbutton);
      set(handles.(['pushbutton_color' num2str(ind)]),'Position', [p(1) p(2) p(3)*1.25 p(4)*1.25]); 
catch
      %set(handles.pushbutton_help,'String','Help');
      set(handles.(['pushbutton_color' num2str(ind)]),'String', lower(colorword(1:2)));
end

% % --------------------------------------------------------------------------------------------
% function setlinebuttons(ind, lineword, hObject, eventdata, handles)
% try
%       [img,map]    = imread(['erplab_' colorword '.jpg']);
%       colormap(map)      
%       [row,column] = size(img);      
%       p = get(handles.(['pushbutton_color' num2str(ind)]),'Position');  
%       w = p(3); % width
%       h = p(4); % hight    
%       steprow   = ceil(row/(5*h));
%       stecolu   = ceil(column/(10*w));
%       imgbutton = img(1:steprow:end,1:stecolu:end,:);
%       set(handles.(['pushbutton_color' num2str(ind)]),'String','')
%       set(handles.(['pushbutton_color' num2str(ind)]),'CData',imgbutton);
%       set(handles.(['pushbutton_color' num2str(ind)]),'Position', [p(1) p(2) p(3)*1.25 p(4)*1.25]); 
% catch
%       %set(handles.pushbutton_help,'String','Help');
%       set(handles.(['pushbutton_color' num2str(ind)]),'String', lower(colorword(1:2)));
% end

% --------------------------------------------------------------------------------------------
function COLORDATA  = colores(defcolor)
% COLORDATA = struct(1);
for i=1:length(defcolor);
      %COLORDATA(i).colorname    = defcolor{i};
      COLORDATA(i).colorchar    = defcolor{i};
      
      switch defcolor{i}
            case 'k'
                  COLORDATA(i).colorname    = 'black';
                  COLORDATA(i).colorhtmlcode = '#000000';
            case 'r'
                  COLORDATA(i).colorname     = 'red';
                  COLORDATA(i).colorhtmlcode = '#FF0000';
            case 'b'
                  COLORDATA(i).colorname    = 'blue';
                  COLORDATA(i).colorhtmlcode = '#0000FF';
            case 'g'
                  COLORDATA(i).colorname    = 'green';
                  COLORDATA(i).colorhtmlcode = '#009000';
            case 'c'
                  COLORDATA(i).colorname    = 'cyan';
                  COLORDATA(i).colorhtmlcode = '#00FFFF';
            case 'm'
                  COLORDATA(i).colorname    = 'magenta';
                  COLORDATA(i).colorhtmlcode = '#FF00FF';
            case 'y'
                  COLORDATA(i).colorname    = 'yellow';
                  %COLORDATA(i).colorhtmlcode = '#FFFF00';     %
                  COLORDATA(i).colorhtmlcode = '#FFD700';     % or gold #FDD017
            case 'w'
                  COLORDATA(i).colorname    = 'white';
                  COLORDATA(i).colorhtmlcode = '#F1F1F1';     % winter white?
            otherwise
                  COLORDATA(i).colorname    = 'black';
                  COLORDATA(i).colorhtmlcode = '#000000';
      end
end
% --------------------------------------------------------------------------------------------
function STYLEDATA  = estilos(defstyle)
% STYLEDATA = struct(1);
for i=1:length(defstyle);
      %STYLEDATA(i).colorname    = defcolor{i};
      %STYLEDATA(i).colorchar    = defcolor{i};      
      switch defstyle{i}
            case {'-',''}
                  STYLEDATA(i).line     = 'solid';
                  STYLEDATA(i).style    = '-';
            case '-.'
                  STYLEDATA(i).line     = 'dash-dot';
                  STYLEDATA(i).style    = '-.';
            case '--'
                  STYLEDATA(i).line    = 'dashed';
                  STYLEDATA(i).style    = '--';
            case ':'
                  STYLEDATA(i).line    = 'dotted';
                  STYLEDATA(i).style    = ':';
            otherwise
                  STYLEDATA(i).line     = 'dot';
                  STYLEDATA(i).style    = '-';  
      end
end

% --------------------------------------------------------------------------------------------
function setlistbox_color(hObject, handles, COLORDATA, nbin )
strhtml = cell(1);
maxdig  = length(num2str(length(COLORDATA)))+1;
for i=1:length(COLORDATA)
      % strhtml{i} = sprintf('<html><font color="%s">%s', colorhtmlcode{i}, upper(colorhtmlbase{i}));
      numstr = num2str(i);
      if i<=nbin
            item = ['L' repmat('0',1,maxdig-length(numstr))  numstr ':'];
      else
            item = ['empty..:'];
            %item = [item(1:maxdig+1) ':']
      end
      strhtml{i} = sprintf('<html><font color="#777777">%s<font color="%s">%s', item,...
            COLORDATA(i).colorhtmlcode, upper(COLORDATA(i).colorname));
end
set( handles.listbox_color, 'String', strhtml)

%handles.COLORDATA = COLORDATA;
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------------------------------
function setlistbox_style(hObject, handles, STYLEDATA, nbin )
strhtml = cell(1);
maxdig  = length(num2str(length(STYLEDATA)))+1;
for i=1:length(STYLEDATA)
      % strhtml{i} = sprintf('<html><font color="%s">%s', colorhtmlcode{i}, upper(colorhtmlbase{i}));
      numstr = num2str(i);
      if i<=nbin
             item = ['L' repmat('0',1,maxdig-length(numstr))  numstr ':'];
      else
            item = 'empty..:';
            %item = [item(1:maxdig+1) ':'];
      end
      %strhtml{i} = sprintf('%s%s', item, repmat(STYLEDATA(i).line,1,16));
            strhtml{i} = sprintf('<html><font color="#777777">%s<font color="#000000">%s', item,...
            STYLEDATA(i).line);
      
end
set( handles.listbox_style, 'String', strhtml)

%handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------------------------------
function listbox_color_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------------------------
function listbox_color_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------------------------------
function pushbutton_up_color_Callback(hObject, eventdata, handles)
COLORDATA = handles.COLORDATA;
nbin = handles.nbin;
currline = get(handles.listbox_color, 'Value'); % current line

ncolor = length(COLORDATA);
if nnz(~bitand(currline>1,currline<=ncolor))==0
      aux = COLORDATA(currline);
      COLORDATA(currline) = COLORDATA(currline-1);
      COLORDATA(currline-1) = aux;
      setlistbox_color(hObject, handles, COLORDATA, nbin )
      set(handles.listbox_color, 'Value', currline-1); % current line
end

handles.COLORDATA = COLORDATA;
% Update handles structure
guidata(hObject, handles);

% fulltext = get(handles.listbox_color, 'String');
% fulltext = regexprep(fulltext,'<html><font color="#00000F">.*<font color="#.*">?','');
% indxline = length(fulltext);
% fulltext = char(fulltext); % string matrix
% currline = get(handles.listbox_color, 'Value'); % current line
%
% if nnz(~bitand(currline>1,currline<=indxline))==0
%
%       aux = fulltext(currline,:);
%       fulltext(currline,:) = fulltext(currline-1,:);
%       fulltext(currline-1,:) = aux;
%       %fulltext(currline,:) = [];
%       fulltext = cellstr(fulltext); % cell string
%
%       set(handles.listbox_color, 'String', fulltext);
%       %handles.lastlineclicked = {};
%
%       % Update handles structure
%       %guidata(hObject, handles);
%
%       %set(handles.edit_numeric, 'string','')
%       %set(handles.edit_string, 'string','')
%       %set(handles.edit_binindex, 'string','')
%       %set(handles.edit_bindescription, 'string','')
%       %indxline = length(fulltext);
%       currline = currline-1;
%       if currline<1
%             currline = 1;
%       end
%
%       set(handles.listbox_color, 'Value', currline);
%       %listbox_Callback(hObject, eventdata, handles)
%
%
%
%
%
%
%
%
%       handles.fulltext = fulltext;
%       %handles.listname = [];
%
%       % Update handles structure
%       guidata(hObject, handles);
% end

% --------------------------------------------------------------------------------------------
function pushbutton_down_color_Callback(hObject, eventdata, handles)
COLORDATA = handles.COLORDATA;
nbin = handles.nbin;
currline = get(handles.listbox_color, 'Value'); % current line

ncolor = length(COLORDATA);
if nnz(~bitand(currline>=1,currline<ncolor))==0
      aux = COLORDATA(currline);
      COLORDATA(currline) = COLORDATA(currline+1);
      COLORDATA(currline+1) = aux;
      setlistbox_color(hObject, handles, COLORDATA, nbin )
      set(handles.listbox_color, 'Value', currline+1); % current line
end

handles.COLORDATA = COLORDATA;
% Update handles structure
guidata(hObject, handles);

% fulltext = get(handles.listbox_color, 'String');
% indxline = length(fulltext);
% fulltext = char(fulltext); % string matrix
% currline = get(handles.listbox_color, 'Value'); % current line
%
% if nnz(~bitand(currline>=1,currline<indxline))==0
%
%       aux = fulltext(currline,:);
%       fulltext(currline,:) = fulltext(currline+1,:);
%       fulltext(currline+1,:) = aux;
%       %fulltext(currline,:) = [];
%       fulltext = cellstr(fulltext); % cell string
%
%       set(handles.listbox_color, 'String', fulltext);
%       %handles.lastlineclicked = {};
%
%       % Update handles structure
%       %guidata(hObject, handles);
%
%       %set(handles.edit_numeric, 'string','')
%       %set(handles.edit_string, 'string','')
%       %set(handles.edit_binindex, 'string','')
%       %set(handles.edit_bindescription, 'string','')
%       indxline = length(fulltext);
%       currline = currline + 1;
%       if currline>indxline
%             currline = indxline;
%       end
%
%       set(handles.listbox_color, 'Value', currline);
%       %listbox_Callback(hObject, eventdata, handles)
%
%       handles.fulltext = fulltext;
%       %handles.listname = [];
%
%       % Update handles structure
%       guidata(hObject, handles);
% end

% --------------------------------------------------------------------------------------------
function pushbutton_default_color_Callback(hObject, eventdata, handles)
nbin      = handles.nbin;
defcolor  = handles.defcolor;
COLORDATA = colores(defcolor);
setlistbox_color(hObject, handles, COLORDATA, nbin )
handles.COLORDATA = COLORDATA;
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------------------------------
function pushbutton_up_style_Callback(hObject, eventdata, handles)
STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
currline = get(handles.listbox_style, 'Value'); % current line
ncolor = length(STYLEDATA);
if nnz(~bitand(currline>1,currline<=ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = STYLEDATA(currline-1);
      STYLEDATA(currline-1) = aux;
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      set(handles.listbox_style, 'Value', currline-1); % current line
end

handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------------------------------
function pushbutton_down_style_Callback(hObject, eventdata, handles)
STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
currline = get(handles.listbox_style, 'Value'); % current line

ncolor = length(STYLEDATA);
if nnz(~bitand(currline>=1,currline<ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = STYLEDATA(currline+1);
      STYLEDATA(currline+1) = aux;
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      set(handles.listbox_style, 'Value', currline+1); % current line
end
handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);
% --------------------------------------------------------------------------------------------
function pushbutton_default_style_Callback(hObject, eventdata, handles)
nbin      = handles.nbin;
defstyle  = handles.defstyle;
STYLEDATA = estilos(defstyle);
setlistbox_style(hObject, handles, STYLEDATA, nbin )
handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);
handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_top_color_Callback(hObject, eventdata, handles)
COLORDATA = handles.COLORDATA;
nbin = handles.nbin;
currline = get(handles.listbox_color, 'Value'); % current line
ncolor = length(COLORDATA);
if nnz(~bitand(currline>1,currline<=ncolor))==0
      aux = COLORDATA(currline);
      COLORDATA(currline) = [];
      COLORDATA = [aux COLORDATA];
      setlistbox_color(hObject, handles, COLORDATA, nbin )
      set(handles.listbox_color, 'Value', 1); % current line
end

handles.COLORDATA = COLORDATA;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_top_style_Callback(hObject, eventdata, handles)
STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
currline = get(handles.listbox_style, 'Value'); % current line
ncolor = length(STYLEDATA);
if nnz(~bitand(currline>1,currline<=ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = [];
      STYLEDATA = [aux STYLEDATA];
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      set(handles.listbox_style, 'Value', 1); % current line
end

handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color1_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = 'BLUE';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);
% % %     '<html><font color="#777777">empty..:<font color="#FF00FF">MAGENTA'

%--------------------------------------------------------------------------
function pushbutton_color2_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = '';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color3_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = '';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color4_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = '';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color5_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = '';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color6_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = '';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color7_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)
% % % colorbtn = '';
% % colorbtn = get(hObject, 'UserData');
% % % v = get(handles.listbox_color, 'Value');
% % currline = get(handles.listbox_color, 'Value'); % current line
% % s = get(handles.listbox_color, 'String');
% % w = regexp(s, '\w+$', 'match');
% % w = [w{:}];
% % ind = find(ismember(w, colorbtn), 1, 'last');
% % 
% % COLORDATA = handles.COLORDATA;
% % nbin = handles.nbin;
% % % currline = get(handles.listbox_color, 'Value'); % current line
% % 
% % ncolor = length(COLORDATA);
% % 
% % if nnz(~bitand(currline>=1,currline<=ncolor))==0
% %       aux = COLORDATA(currline);
% %       COLORDATA(currline) = COLORDATA(ind);
% %       COLORDATA(ind) = aux;
% %       setlistbox_color(hObject, handles, COLORDATA, nbin )
% %       %set(handles.listbox_color, 'Value', 1);
% % end
% % handles.COLORDATA = COLORDATA;
% % % Update handles structure
% % guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_color8_Callback(hObject, eventdata, handles)
ReplaceColoratList(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function ReplaceColoratList(hObject, eventdata, handles)
% colorbtn = '';
colorbtn = get(hObject, 'UserData');
% v = get(handles.listbox_color, 'Value');
currline = get(handles.listbox_color, 'Value'); % current line
s = get(handles.listbox_color, 'String');
w = regexp(s, '\w+$', 'match');
w = [w{:}];
ind = find(ismember(w, colorbtn), 1, 'last');

COLORDATA = handles.COLORDATA;
nbin = handles.nbin;
% currline = get(handles.listbox_color, 'Value'); % current line

ncolor = length(COLORDATA);

if nnz(~bitand(currline>=1,currline<=ncolor))==0
      aux = COLORDATA(currline);
      COLORDATA(currline) = COLORDATA(ind);
      COLORDATA(ind) = aux;
      setlistbox_color(hObject, handles, COLORDATA, nbin )
      %set(handles.listbox_color, 'Value', 1);
end
handles.COLORDATA = COLORDATA;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_line1_Callback(hObject, eventdata, handles)
linebtn = get(hObject, 'UserData');
% v = get(handles.listbox_color, 'Value');
currline = get(handles.listbox_style, 'Value'); % current line
s = get(handles.listbox_style, 'String');
% w = regexp(s, '\w+$', 'match');
w = regexp(s, '\w+-*\w*$', 'match');
w = [w{:}];
ind = find(ismember(w, linebtn), 1, 'last');

STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
% currline = get(handles.listbox_style, 'Value'); % current line

ncolor = length(STYLEDATA);

if nnz(~bitand(currline>=1,currline<=ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = STYLEDATA(ind);
      STYLEDATA(ind) = aux;
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      %set(handles.listbox_style, 'Value', 1); % current line
end

handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_line2_Callback(hObject, eventdata, handles)
linebtn = get(hObject, 'UserData');
% v = get(handles.listbox_color, 'Value');
currline = get(handles.listbox_style, 'Value'); % current line
s = get(handles.listbox_style, 'String');
% w = regexp(s, '\w+$', 'match');
w = regexp(s, '\w+-*\w*$', 'match');
w = [w{:}];
ind = find(ismember(w, linebtn), 1, 'last');

STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
% currline = get(handles.listbox_style, 'Value'); % current line

ncolor = length(STYLEDATA);

if nnz(~bitand(currline>=1,currline<=ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = STYLEDATA(ind);
      STYLEDATA(ind) = aux;
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      %set(handles.listbox_style, 'Value', 1); % current line
end

handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_line3_Callback(hObject, eventdata, handles)
linebtn = get(hObject, 'UserData');
% v = get(handles.listbox_color, 'Value');
currline = get(handles.listbox_style, 'Value'); % current line
s = get(handles.listbox_style, 'String');
% w = regexp(s, '\w+$', 'match');
w = regexp(s, '\w+-*\w*$', 'match');
w = [w{:}];
ind = find(ismember(w, linebtn), 1, 'last');

STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
% currline = get(handles.listbox_style, 'Value'); % current line

ncolor = length(STYLEDATA);

if nnz(~bitand(currline>=1,currline<=ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = STYLEDATA(ind);
      STYLEDATA(ind) = aux;
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      %set(handles.listbox_style, 'Value', 1); % current line
end

handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);


%--------------------------------------------------------------------------
function pushbutton_line4_Callback(hObject, eventdata, handles)
linebtn = get(hObject, 'UserData');
% v = get(handles.listbox_color, 'Value');
currline = get(handles.listbox_style, 'Value'); % current line
s = get(handles.listbox_style, 'String');
% w = regexp(s, '\w+$', 'match');
w = regexp(s, '\w+-*\w*$', 'match');
w = [w{:}];
ind = find(ismember(w, linebtn), 1, 'last');

STYLEDATA = handles.STYLEDATA;
nbin = handles.nbin;
% currline = get(handles.listbox_style, 'Value'); % current line

ncolor = length(STYLEDATA);

if nnz(~bitand(currline>=1,currline<=ncolor))==0
      aux = STYLEDATA(currline);
      STYLEDATA(currline) = STYLEDATA(ind);
      STYLEDATA(ind) = aux;
      setlistbox_style(hObject, handles, STYLEDATA, nbin )
      %set(handles.listbox_style, 'Value', 1); % current line
end

handles.STYLEDATA = STYLEDATA;
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output= [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --------------------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

%colorlist = get( handles.listbox_color, 'String');
%colorlist = lower(regexprep(colorlist,'<html><font color=".*?">','','ignorecase')');
%colorlist = lower(regexprep(colorlist,'<html><font color="#00000F">.*<font color="#.*">?','');
%'<html><font color="#00000F">.*<font color="#.*">?','');
lwidth    = get(handles.popupmenu_lwidth,'Value');
COLORDATA = handles.COLORDATA;
STYLEDATA = handles.STYLEDATA;
output    = cellstr([char({COLORDATA.colorchar}') char({STYLEDATA(1:length(COLORDATA)).style}')])';
%[xxx indx] = ismember_bc2(colorlist, {COLORDATA.colorname});
%handles.output = {COLORDATA(indx).colorchar};
handles.output = {output lwidth};
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --------------------------------------------------------------------------------------------
function listbox_style_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------------------------
function listbox_style_CreateFcn(hObject, eventdata, handles)

% Hint: listbox_color controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------------------------------
function popupmenu_lwidth_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------------------------
function popupmenu_lwidth_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
      % The GUI is still in UIWAIT, us UIRESUME
      uiresume(handles.gui_chassis);
else
      % The GUI is no longer waiting, just close it
      delete(handles.gui_chassis);
end
