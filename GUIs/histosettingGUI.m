function varargout = histosettingGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @histosettingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @histosettingGUI_OutputFcn, ...
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


% --- Executes just before histosettingGUI is made visible.
function histosettingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

try
        def       = varargin{1};
        binvalue  = def{1};
        normhisto = def{2};
        chisto    = def{3};
        fitnormd  = def{4};
        cfitnorm  = def{5};
        nvalue   = def{6};
catch
        binvalue  = 'auto';
        normhisto = 0;
        chisto    = [1 0.5 0.2];
        fitnormd  = 0;
        cfitnorm  = [1 0 0];
        nvalue   = 100;
end
if isempty(binvalue)
        binvalue = 'auto';
end
if isempty(normhisto)
        normhisto = 0;
end
if isempty(chisto)
        chisto = [1 0.5 0.2];
end
if isempty(cfitnorm)
        cfitnorm = [1 0 0];
end
if isempty(fitnormd)
        fitnormd = 0;
end
if isempty(nvalue)
        nvalue = 100;
end

handles.binvalue  = binvalue;
handles.normhisto = normhisto;
handles.chisto    = chisto;
handles.cfitnorm  = cfitnorm;
handles.fitnormd  = fitnormd;
handles.nvalue    = nvalue;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Histogram Settings GUI'],'WindowStyle','modal')

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

if ischar(binvalue)
        set(handles.edit_nbinh, 'String', binvalue)
else
        set(handles.edit_nbinh, 'String', vect2colon(binvalue,'Delimiter', 'off'))
end
set(handles.checkbox_normhist, 'Value', normhisto)
set(handles.checkbox_fitnormal,'Value', fitnormd)

% if normhisto
%         set(handles.checkbox_fitnormal, 'Enable', 'on')
%         set(handles.checkbox_fitnormal,'Value', fitnormd)
%         set(handles.pushbutton_colornormdist, 'Enable', 'on')  
% else
%         set(handles.checkbox_fitnormal, 'Value', 0)
%         set(handles.checkbox_fitnormal, 'Enable', 'off')
%         set(handles.pushbutton_colornormdist, 'Enable', 'off')        
% end

% UIWAIT makes histosettingGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% --- Outputs from this function are returned to the command line.
function varargout = histosettingGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%----------------------------------------------------------------
function edit_nbinh_Callback(hObject, eventdata, handles)

%----------------------------------------------------------------
function edit_nbinh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%----------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output= [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%----------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

binvalue  = get(handles.edit_nbinh, 'String');
if isempty(binvalue)
        msgboxText =  'You have to specify one value at list!';
        title = 'Error: histosettingGUI';
        errorfound(sprintf(msgboxText), title);
        return
end
binvalue = strrep(binvalue,'''','');
if ~strcmpi(binvalue,'auto') && isempty(str2num(binvalue))
        msgboxText =  ['%s is not a valid input.\n\n'...
                'Enter a single value, a monotonically non-decreasing vector, or ''auto''.\n'...
                'Or just click the "suggest" button.'];
        title = 'Error: histosettingGUI';
        errorfound(sprintf(msgboxText, binvalue), title);
        return
        
elseif ~strcmpi(binvalue,'auto') && ~isempty(str2num(binvalue))
        binvalue = str2num(binvalue);
end

normhisto = get(handles.checkbox_normhist, 'Value');
chisto    = handles.chisto;
fitnormd  = get(handles.checkbox_fitnormal, 'Value');
cfitnorm  = handles.cfitnorm;

erpworkingmemory('BinHisto', binvalue);
erpworkingmemory('NormHisto', normhisto);
erpworkingmemory('FitNormd', fitnormd);

handles.output = {binvalue, normhisto, chisto, fitnormd, cfitnorm};
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%----------------------------------------------------------------
function pushbutton_colorhist_Callback(hObject, eventdata, handles)
chisto = handles.chisto;
chisto = uisetcolor(chisto,'Histogram color') ;
erpworkingmemory('HistoColor', chisto);

handles.chisto = chisto;
% Update handles structure
guidata(hObject, handles);

%----------------------------------------------------------------
function checkbox_normhist_Callback(hObject, eventdata, handles)
% if get(hObject,'Value')
%         set(handles.checkbox_fitnormal, 'Enable', 'on')
%         set(handles.pushbutton_colornormdist, 'Enable', 'on')  
% else
%         set(handles.checkbox_fitnormal, 'Value', 0)
%         set(handles.checkbox_fitnormal, 'Enable', 'off')
%         set(handles.pushbutton_colornormdist, 'Enable', 'off')        
% end

%----------------------------------------------------------------
function checkbox_fitnormal_Callback(hObject, eventdata, handles)

%----------------------------------------------------------------
function pushbutton_colornormdist_Callback(hObject, eventdata, handles)
cfitnorm = handles.cfitnorm;
cfitnorm = uisetcolor(cfitnorm,'Curve color') ;
erpworkingmemory('FnormColor', cfitnorm);

handles.cfitnorm = cfitnorm;
% Update handles structure
guidata(hObject, handles);

%----------------------------------------------------------------
function pushbutton_autobinhisto_Callback(hObject, eventdata, handles)
nvalue = handles.nvalue;
binvalue = round(sqrt(nvalue));
handles.binvalue = binvalue;
% Update handles structure
guidata(hObject, handles);

set(handles.edit_nbinh, 'String', num2str(binvalue));

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        handles.output= [];
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end

% chisto   = erpworkingmemory('HistoColor'); % histogram color
% cfitnorm = erpworkingmemory('FnormColor'); % line color for fitted normal distribution
% fitnormd = erpworkingmemory('FitNormd'); % select window measurement by mouse option
