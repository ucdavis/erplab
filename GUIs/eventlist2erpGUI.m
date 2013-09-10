function varargout = eventlist2erpGUI(varargin)
% EVENTLIST2ERPGUI M-file for eventlist2erpGUI.fig
%      EVENTLIST2ERPGUI, by itself, creates a new EVENTLIST2ERPGUI or raises the existing
%      singleton*.
%
%      H = EVENTLIST2ERPGUI returns the handle to a new EVENTLIST2ERPGUI or the handle to
%      the existing singleton*.
%
%      EVENTLIST2ERPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTLIST2ERPGUI.M with the given input arguments.
%
%      EVENTLIST2ERPGUI('Property','Value',...) creates a new EVENTLIST2ERPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eventlist2erpGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eventlist2erpGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eventlist2erpGUI

% Last Modified by GUIDE v2.5 26-Aug-2013 12:59:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @eventlist2erpGUI_OpeningFcn, ...
        'gui_OutputFcn',  @eventlist2erpGUI_OutputFcn, ...
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

%--------------------------------------------------------------------------
function eventlist2erpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for eventlist2erpGUI
handles.output = hObject;
ERP = varargin{1};

if isfield(ERP, 'EVENTLIST')
        if ~isempty(ERP.EVENTLIST)
                nel = length(ERP.EVENTLIST);
        else
                title      = 'ERPLAB: eventlist2erpGUI()';
                question{1} = 'EVENTLIST structure is empty in this ERPset';
                question{2} = 'Do you want to continue anyway?';                
                button = askquest(question, title);
                
                if ~strcmpi(button,'yes')
                        disp('User selected Cancel')
                        return
                end
                nel = 0;
        end
else
        title      = 'ERPLAB: eventlist2erpGUI()';
        question{1} = 'EVENTLIST structure was not found in this ERPset';
        question{2} = 'Do you want to continue anyway?';        
        button = askquest(question, title);
        
        if ~strcmpi(button,'yes')
                disp('User selected Cancel')
                return
        end
        nel = 0;
end

handles.nel = nel;

if nel==0
        text_message1 = sprintf('This ERPset contains %g EVENTLIST', nel);
        text_message2 = '';
        set(handles.text_message1, 'String', text_message1)
        set(handles.radiobutton_make1, 'Enable', 'off')
        set(handles.radiobutton_replace, 'Enable', 'off')
        set(handles.edit_replace, 'Enable', 'off')
        set(handles.text_replace, 'Enable', 'off')
elseif nel==1
        text_message1 = sprintf('This ERPset contains %g EVENTLIST', nel);
        text_message2 = 'What would you like to do with the imported EVENTLIST?';
        set(handles.text_message1, 'String', text_message1)
        set(handles.radiobutton_replace, 'Enable', 'off')
        set(handles.edit_replace, 'Enable', 'off')
        set(handles.text_replace, 'Enable', 'off')
else
        text_message1 = sprintf('This ERPset contains %g EVENTLISTs (1-%g)', nel, nel);
        text_message2 = 'What would you like to do with the imported EVENTLIST?';
        set(handles.text_message1, 'String', text_message1)
end

set(handles.text_message2, 'String', text_message2)
text_message3 = sprintf('Append imported EVENTLIST as #%g', nel+1);
set(handles.radiobutton_append, 'String', text_message3)
set(handles.radiobutton_append, 'Value', 1)

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Import EVENTLIST from Text to ERP GUI'])

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

% UIWAIT makes eventlist2erpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = eventlist2erpGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.5)

%--------------------------------------------------------------------------
function radiobutton_make1_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.radiobutton_replace, 'Value', 0)
        set(handles.radiobutton_append, 'Value', 0)
else
        set(handles.radiobutton_make1, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_replace_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.radiobutton_make1, 'Value', 0)
        set(handles.radiobutton_append, 'Value', 0)
else
        set(handles.radiobutton_replace, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_append_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
        set(handles.radiobutton_replace, 'Value', 0)
        set(handles.radiobutton_make1, 'Value', 0)
else
        set(handles.radiobutton_append, 'Value', 1)
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

eventlistname = get(handles.edit_eventlistname, 'String');
nel = handles.nel;

if isempty(strtrim(eventlistname))
        msgboxText{1} =  'Error: You must choose an EVENTLIST text file.';
        title = 'ERPLAB: eventlist2erpGUI';
        errorfound(msgboxText, title);
        return
end

if get(handles.radiobutton_make1, 'Value')
        option = 0;
        index  = [];
        
elseif get(handles.radiobutton_replace, 'Value')
        
        option = 1;
        index = str2num(get(handles.edit_replace, 'String'));
        
        if isempty(index) || index<1 || index>nel
                msgboxText{1} =  'Error: invalid EVENTLIST index.';
                title = 'ERPLAB: eventlist2erpGUI';
                errorfound(msgboxText, title);
                return
        end
        
elseif get(handles.radiobutton_append, 'Value')
        option = 2;
        index  = [];
        
else
        return
end

outputarray = {eventlistname, option, index};
handles.output = outputarray;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function edit_replace_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_replace_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_eventlistname_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_eventlistname_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)

[bdfilename,bdfpathname] = uigetfile({'*.txt';'*.dat';'*.*'},'Select an EVENTLIST text file');

if isequal(bdfilename,0)
        disp('User selected Cancel')
        return
else
        set(handles.edit_eventlistname, 'String', fullfile(bdfpathname, bdfilename));
        
        % Update handles structure
        guidata(hObject, handles);
        
        flinkname = fullfile(bdfpathname, bdfilename);
        disp(['For EVENTLIST text file, user selected <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
