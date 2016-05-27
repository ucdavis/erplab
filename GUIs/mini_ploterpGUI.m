function varargout = mini_ploterpGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mini_ploterpGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mini_ploterpGUI_OutputFcn, ...
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


% --- Executes just before mini_ploterpGUI is made visible.
function mini_ploterpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

try
      plotset = evalin('base', 'plotset');
      posminigui = plotset.ptime.posminigui;
catch
        plotset.ptime  = [];
        plotset.pscalp = [];
        posminigui     = [];
end
if isempty(posminigui)
        posminigui  = get(handles.figure_miniplot_gui,'Position');
end
%
% Name & version
%
% version = geterplabversion;
set(handles.figure_miniplot_gui,'Name', 'Mini ERP Plotting GUI',...
      'tag','ploterp_fig','NextPlot','new')

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

set(handles.figure_miniplot_gui,'Position', posminigui)
% set(handles.figure_miniplot_gui,'WindowStyle', 'modal')



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mini_ploterpGUI wait for user response (see UIRESUME)
uiwait(handles.figure_miniplot_gui);

%--------------------------------------------------------------------------
function varargout = mini_ploterpGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure_miniplot_gui);
pause(0.1)

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
plotset = evalin('base', 'plotset');
plotset.ptime.posminigui = get(handles.figure_miniplot_gui,'Position');
assignin('base','plotset', plotset);
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure_miniplot_gui);

%--------------------------------------------------------------------------
function pushbutton_maximize_Callback(hObject, eventdata, handles)
handles.output = {1};
plotset = evalin('base', 'plotset');
plotset.ptime.posminigui = get(handles.figure_miniplot_gui,'Position');
assignin('base','plotset', plotset);
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure_miniplot_gui);

%--------------------------------------------------------------------------
function figure_miniplot_gui_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure_miniplot_gui, 'waitstatus'), 'waiting')
      %The GUI is still in UIWAIT, us UIRESUME
      plotset = evalin('base', 'plotset');
      plotset.ptime.posminigui = get(handles.figure_miniplot_gui,'Position');
      assignin('base','plotset', plotset);
      plotset.ptime  = [];
      handles.output = [];
      %Update handles structure
      guidata(hObject, handles);
      uiresume(handles.figure_miniplot_gui);
else
      % The GUI is no longer waiting, just close it
      delete(handles.figure_miniplot_gui);
end
