function varargout = gui_optionsAreaMeasurement(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_optionsAreaMeasurement_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_optionsAreaMeasurement_OutputFcn, ...
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

%-------------------------------------------------------------------------------------------------------
function gui_optionsAreaMeasurement_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];
%values
try
        def  = varargin{1};
        def2 = varargin{2};
        typeofpeakval = def{1};
        numsampleval  = def{2};
        locpeakrepval = def{3};
        fracval       = def{4};
        fracrepval    = def{5};
        srate         = def2{1};
        intfactor     = def2{2};
catch
        typeofpeakval = 1;
        numsampleval  = 6;
        locpeakrepval = 1;
        fracval       = 1;
        fracrepval    = 1;
        srate         = 1000;
        intfactor     = 1;
end
% strings
typeofpeaklist = {'Positive' 'Negative'};
numsamplelist  = num2cell(0:50);
locpeakreplist = {'absolute peak','"not a number" (NaN)','show error message'};
fraclist       = num2cell(0:100);
fracreplist    = {'closest value','"not a number" (NaN)','show error message'};
% set strings
set(handles.popupmenu_typeofpeak, 'String', typeofpeaklist)
set(handles.popupmenu_neighborhood, 'String', numsamplelist)
set(handles.popupmenu_replacelocpeak, 'String', locpeakreplist)
set(handles.popupmenu_fracpeak, 'String', fraclist)
set(handles.popupmenu_replacefracpeak, 'String', fracreplist)
% set values
set(handles.popupmenu_typeofpeak, 'Value', typeofpeakval)
set(handles.popupmenu_neighborhood, 'Value', numsampleval)
set(handles.popupmenu_replacelocpeak, 'Value', locpeakrepval)
set(handles.popupmenu_fracpeak, 'Value', fracval)
set(handles.popupmenu_replacefracpeak, 'Value', fracrepval)
pnts  = get(handles.popupmenu_neighborhood,'Value')-1;
if isempty(srate)
        msecstr = sprintf('pnts ( ? ms)');
else
        msecstr = sprintf('pnts (%4.1f ms)', (pnts/srate*intfactor)*1000);
end
set(handles.text_neighborhoodms,'String',msecstr)

% GUI
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   MEASUREMENT OPTIONS'])
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_optionsAreaMeasurement wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%-------------------------------------------------------------------------------------------------------
function varargout = gui_optionsAreaMeasurement_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%-------------------------------------------------------------------------------------------------------
function popupmenu_typeofpeak_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------
function popupmenu_typeofpeak_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------------
function popupmenu_neighborhood_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------
function popupmenu_neighborhood_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------------
function popupmenu_replacelocpeak_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------
function popupmenu_replacelocpeak_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------------
function popupmenu_fracpeak_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------
function popupmenu_fracpeak_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------------
function popupmenu_replacefracpeak_Callback(hObject, eventdata, handles)

%-------------------------------------------------------------------------------------------------------
function popupmenu_replacefracpeak_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%-------------------------------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)

typeofpeakval = get(handles.popupmenu_typeofpeak, 'Value');      % 1, 2
numsampleval  = get(handles.popupmenu_neighborhood, 'Value')-1;  % 0,1,2,3,...,50
locpeakrepval = get(handles.popupmenu_replacelocpeak, 'Value');  % 1,2,3
fracval       = get(handles.popupmenu_fracpeak, 'Value')-1;        % 1,2,3,...,100
fracrepval    = get(handles.popupmenu_replacefracpeak, 'Value'); % 1,2

handles.output = [typeofpeakval, numsampleval, locpeakrepval, fracval, fracrepval];
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
