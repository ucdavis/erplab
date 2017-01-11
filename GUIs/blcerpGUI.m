%
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

function varargout = blcerpGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @blcerpGUI_OpeningFcn, ...
        'gui_OutputFcn',  @blcerpGUI_OutputFcn, ...
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

% -------------------------------------------------------------------------
function blcerpGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for blcerpGUI
handles.output = [];

try
        ERP = varargin{1};
        xmin = 1000*ERP.xmin;
        xmax = 1000*ERP.xmax;        
catch
        ERP  = [];
        xmin = -200;
        xmax = 800;
end
try
        Titlegui = varargin{2};
catch
        Titlegui = 'Testing this GUI...';
end
try
        interval = varargin{3};
catch
        interval = 'pre';
end
set(handles.uipanel_blc,'Title', Titlegui)

if strcmpi(interval,'pre')
        intvl = [xmin 0];
        set(handles.edit_custom,'Enable','off')
        set(handles.radiobutton_pre,'Value', 1)
elseif strcmpi(interval,'post')
        intvl = [0 xmax];
        set(handles.edit_custom,'Enable','off')
        set(handles.radiobutton_post,'Value', 1)
elseif strcmpi(interval,'all')
        intvl = [xmin xmax];
        set(handles.edit_custom,'Enable','off')
        set(handles.radiobutton_all,'Value', 1)
else
        if ischar(interval)
                intvl  = str2num(interval); % interv in ms
        else
                intvl  = interval;
        end
        if length(intvl)~=2
                intvl = [];
        else
                set(handles.edit_custom,'Enable','on')
                set(handles.radiobutton_custom,'Value', 1)
        end
end
if ~isempty(intvl)
        blcstr = sprintf('%.1f  %.1f',intvl);
        set(handles.edit_custom,'String',blcstr);
else
        set(handles.edit_custom,'Enable','off')
        set(handles.radiobutton_none,'Value', 1)
end

handles.xmin = xmin;
handles.xmax = xmax;
handles.blc  = interval;

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
helpbutton

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   ' upper(Titlegui) ' GUI'])

% UIWAIT makes blcerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -------------------------------------------------------------------------
function varargout = blcerpGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------
function edit_custom_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_custom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_blcerp
% fctn = dbstack;
% fctn = fctn(end).name;
% doc(fctn) 
web https://github.com/lucklab/erplab/wiki/ERP-Bin-Operations -browser

% -------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)

xmin  = handles.xmin;
xmax  = handles.xmax;
epoch = [xmin xmax];

if isempty(epoch)
        msgboxText =  'Wrong epoch range!';
        title = 'ERPLAB: Bin-based epoch inputs';
        errorfound(msgboxText, title);
        return
else        
        repoch  = size(epoch,1); % rows for epoch 
        cepoch  = size(epoch,2); % columns for epoch 
        blc     = handles.blc;        
        cusbutt = get(handles.radiobutton_custom,'Value');
        
        %
        % Checks updated custom blc values
        %
        if cusbutt
                blctest  = get(handles.edit_custom,'String');
                if isempty(blctest)
                        msgboxText = 'You must enter 2 values first.';
                        title = 'ERPLAB: Time range inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                blctest  = str2num(blctest);                
                if isempty(blctest)
                        if strcmpi(get(handles.edit_custom,'String'),'none')
                                custupdated = 1;
                                blc = 'none';
                        elseif strcmpi(get(handles.edit_custom,'String'),'pre')
                                custupdated = 1;
                                blc = 'pre';
                        elseif strcmpi(get(handles.edit_custom,'String'),'post')
                                custupdated = 1;
                                blc = 'post';
                        elseif strcmpi(get(handles.edit_custom,'String'),'all')|| strcmpi(get(handles.edit_custom,'String'),'whole')
                                custupdated = 1;
                                blc = 'all';
                        else
                                custupdated = 0;
                        end
                else
                        rblc = size(blctest,1);
                        cblc = size(blctest,2);
                        extvalcond = max(epoch)>=max(blctest) && min(epoch)<=min(blctest);
                        custupdated = rblc==1 && cblc==2 && extvalcond;
                        blc = blctest;
                end
        else
                custupdated = 1;
        end
        
        if repoch==1 && cepoch==2 && custupdated
                if isnumeric(blc) && blc(1)>=blc(2)
                        msgboxText = ['For time range, lower limit must be on the left.\n'...
                                      'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                        title = 'ERPLAB: Time range inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                if epoch(1)>0 || epoch(2)<0
                        msgboxText =  'Epoch range must span across time zero.';
                        title = 'ERPLAB: Time range inputs';
                        errorfound(msgboxText, title);
                        return
                end
                if epoch(1)>=0 && ~isnumeric(blc) && strcmpi(blc,'pre')
                        msgboxText =  'There is no pre-stimulus interval.';
                        title = 'ERPLAB: Time range inputs';
                        errorfound(msgboxText, title);
                        return
                end
                if epoch(2)<=0 && ~isnumeric(blc) && strcmpi(blc,'post')
                        msgboxText =  'There is no post-stimulus interval.';
                        title = 'ERPLAB: Time range inputs';
                        errorfound(msgboxText, title);
                        return
                end                
                
                handles.output = {blc};
                
                % Update handles structure
                guidata(hObject, handles);
                uiresume(handles.gui_chassis);                
        else
                if custupdated
                        msgboxText =  'Wrong time range! Please, enter 2 values.';
                        title = 'ERPLAB: Time range inputs';
                        errorfound(msgboxText, title);
                else
                        msgboxText =  'Wrong baseline range! Please, enter 2 values.';
                        title = 'ERPLAB: Time range inputs';
                        errorfound(msgboxText, title);
                end
                return
        end
end

% -------------------------------------------------------------------------
function radiobutton_none_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc = 'none';
set(handles.edit_custom,'String','');
handles.blc = blc;

% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
function radiobutton_pre_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
  
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc    = 'pre';
xmin   = handles.xmin;
blcstr = sprintf('%.1f  %g',[xmin 0]);
set(handles.edit_custom,'String',blcstr);
handles.blc = blc;

% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
function radiobutton_post_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc    = 'post';
xmax   = handles.xmax;
blcstr = sprintf('%g  %.1f',[0 xmax]);
set(handles.edit_custom,'String',blcstr);
handles.blc = blc;

% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
function radiobutton_all_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc  = 'all';
xmin = handles.xmin;
xmax = handles.xmax;
blcstr = sprintf('%.1f  %.1f',[xmin xmax]);
set(handles.edit_custom,'String',blcstr);
handles.blc = blc;

% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
function radiobutton_custom_Callback(hObject, eventdata, handles)

if ~get(hObject,'Value')
        set(hObject,'Value',1)
end

set(handles.edit_custom,'Enable','on')
xmin = handles.xmin;
xmax = handles.xmax;
blc  = [xmin xmax];
handles.blc = blc;

% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
function checkbox_blc_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_none,'Enable','on')
        set(handles.radiobutton_pre,'Enable','on')
        set(handles.radiobutton_post,'Enable','on')
        set(handles.radiobutton_all,'Enable','on')
        set(handles.radiobutton_custom,'Enable','on')
        set(handles.edit_custom,'Enable','on')
else
        set(handles.radiobutton_none,'Enable','off')
        set(handles.radiobutton_pre,'Enable','off')
        set(handles.radiobutton_post,'Enable','off')
        set(handles.radiobutton_all,'Enable','off')
        set(handles.radiobutton_custom,'Enable','off')
        set(handles.edit_custom,'Enable','off')
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
