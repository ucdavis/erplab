% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function varargout = colorlineGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @colorlineGUI_OpeningFcn, ...
      'gui_OutputFcn',  @colorlineGUI_OutputFcn, ...
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
function colorlineGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% handles.output = [];
handles.fulltext =[];
handles.output   =[];

try
      def      = varargin{1};
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
if isempty(def)
      defcolor = repmat({'k' 'r' 'b' 'g' 'c' 'm' 'y' },1, nbin);% sorted according 1st erplab's version
      defs     = {'-' '-.' '--' ':'};                           % sorted according 1st erplab's version
      d = repmat(defs',1,length(defcolor));
      defstyle = reshape(d',1,length(defcolor)*length(defs));
else
      defcolor = regexp(def,'\w*','match');
      defcolor = [defcolor{:}];
      defstyle = regexp(def,'\W*','match');
      defstyle = [defstyle{:}];
      if isempty(defcolor)
            defcolor = repmat({'k' 'r' 'b' 'g' 'c' 'm' 'y' },1, nbin);% sorted according 1st erplab's version
      end
      if isempty(defstyle)
            defs     = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
            d = repmat(defs',1,length(defcolor));
            defstyle = reshape(d',1,length(defcolor)*length(defs));
      end
end

COLORDATA  = colores(defcolor);
STYLEDATA  = estilos(defstyle);
set(handles.popupmenu_lwidth,'Value', lwidth)

%basecolor = {'black' 'red' 'blue' 'green' 'cyan' 'magenta' 'yellow'};
%colorchar    = {'k' 'r' 'b' 'g' 'c' 'm' 'y'}; % sorted according 1st erplab's version

%set(handles.listbox_color, 'String', defcolor);
handles.defcolor = defcolor;
handles.defstyle = defstyle;
handles.COLORDATA = COLORDATA;
handles.STYLEDATA = STYLEDATA;
handles.nbin = nbin;
setlistbox_color(hObject, handles, COLORDATA, nbin )
setlistbox_style(hObject, handles, STYLEDATA, nbin )

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Color line GUI'], 'WindowStyle','modal')

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
function varargout = colorlineGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

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
                  COLORDATA(i).colorhtmlcode = '#FFFF00';     % or gold #FDD017
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
                  STYLEDATA(i).line     = '.';
                  STYLEDATA(i).style    = '-';
            case '-.'
                  STYLEDATA(i).line     = '- . ';
                  STYLEDATA(i).style    = '-.';
            case '--'
                  STYLEDATA(i).line    = '-  ';
                  STYLEDATA(i).style    = '--';
            case ':'
                  STYLEDATA(i).line    = '.  ';
                  STYLEDATA(i).style    = ':';
            otherwise
                  STYLEDATA(i).line     = '.';
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
            item = 'empty';
            item = [item(1:maxdig) ':'];
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
            item = 'empty';
            item = [item(1:maxdig) ':'];
      end
      %strhtml{i} = sprintf('%s%s', item, repmat(STYLEDATA(i).line,1,16));
            strhtml{i} = sprintf('<html><font color="#777777">%s<font color="#000000">%s', item,...
            repmat(STYLEDATA(i).line,1,32));
      
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
lwidth = get(handles.popupmenu_lwidth,'Value');
COLORDATA = handles.COLORDATA;
STYLEDATA = handles.STYLEDATA;
output    = cellstr([char({COLORDATA.colorchar}') char({STYLEDATA(1:length(COLORDATA)).style}')])';
%[xxx indx] = ismember(colorlist, {COLORDATA.colorname});
%handles.output = {COLORDATA(indx).colorchar};
handles.output = [output lwidth];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% --------------------------------------------------------------------------------------------
function popupmenu_lwidth_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------------------------
function popupmenu_lwidth_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------------------------------
function listbox_style_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------------------------------
function listbox_style_CreateFcn(hObject, eventdata, handles)

% Hint: listbox_color controls usually have a white background on Windows.
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
