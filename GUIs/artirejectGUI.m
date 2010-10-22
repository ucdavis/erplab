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

function varargout = artirejectGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @artirejectGUI_OpeningFcn, ...
        'gui_OutputFcn',  @artirejectGUI_OutputFcn, ...
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
function artirejectGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% varargin   command line arguments to artirejectGUI (see VARARGIN)
% Choose default command line output for artirejectGUI
handles.output = hObject;

BACKEEGLABCOLOR     = [.66 .76 1];    % EEGLAB main window background

set(handles.figure1,'Color', BACKEEGLABCOLOR)
set(handles.text1,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text2,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text3,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text4,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text5,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text6,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text7,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text8,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text_erplab,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.text_arc,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.panel,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.panel_utilities,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.panel_settings,'BackgroundColor', BACKEEGLABCOLOR)
set(handles.listbox_tool_sky,'BackgroundColor', [1 1 0.8]) % listbox_tool_sky
set(handles.listbox_tool_earth,'BackgroundColor', [1 1 1]) % listbox_tool_sky
set(handles.text1,'FontSize', 11)
set(handles.text2,'FontSize', 11)
set(handles.text3,'FontSize', 11)
set(handles.text4,'FontSize', 11)
set(handles.text5,'FontSize', 11)
set(handles.text6,'FontSize', 11)
set(handles.text7,'FontSize', 11)
set(handles.text8,'FontSize', 11)

set(handles.edit_time_window,'String', '')
set(handles.edit_channels,'String', '')
set(handles.edit_voltage_threshold,'String', '')
set(handles.edit_cross_cov,'String', '')
set(handles.edit_blink_width,'String', '')
set(handles.edit_moving_window_width,'String', '')
set(handles.edit_moving_window_step,'String', '')
set(handles.edit_delta_blocking,'String', '')

set(handles.edit_time_window,'Enable', 'off')
set(handles.edit_channels,'Enable', 'off')
set(handles.edit_voltage_threshold,'Enable', 'off')
set(handles.edit_cross_cov,'Enable', 'off')
set(handles.edit_blink_width,'Enable', 'off')
set(handles.edit_moving_window_width,'Enable', 'off')
set(handles.edit_moving_window_step,'Enable', 'off')
set(handles.edit_delta_blocking,'Enable', 'off')

listool = {'jumping-like','step-like','voltage thresold','moving window','blink'};

ordertool = 1:10; % max tool

listtag = {'time_window','channels','voltage_threshold','cross_cov',...
        'blink_width','moving_window_width','moving_window_step','delta_blocking'};

set(handles.listbox_tool_sky,'String', listool)
set(handles.listbox_tool_earth,'String', {[]})

handles.strtool_earth = {};
handles.indxtool_earth = 0;
handles.indxtool_sky   = 1;
handles.listtag   = listtag;
handles.listool = listool;
handles.ordertool = ordertool;
handles.indxsetting = ones(100,3);

set(handles.listbox_tool_earth,'value', 1);
set(handles.listbox_tool_sky,'value',1);
set(handles.listbox_tool_sky,'FontSize', 11)
set(handles.listbox_tool_earth,'FontSize', 11)
set(handles.erase_tool, 'Enable', 'off')

%ERP = evalin('base', 'ERP');
erpversion = geterplabversion;
set(handles.text_erplab,'String', ['ERPLAB ' erpversion])

EEG = evalin('base', 'EEG');

% if isempty(EEG.data)
%         disp('pop_polydetrend() error: cannot filter an empty dataset')
%         return
% end

handles.EEG = EEG;

% Update handles structure
guidata(hObject, handles);
defaultvalues(hObject, eventdata, handles)

clc

% UIWAIT makes artirejectGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% -------------------------------------------------------------------------
function varargout = artirejectGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -------------------------------------------------------------------------
function listbox_tool_sky_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function listbox_tool_sky_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_tool_earth_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_tool_earth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_time_window_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_time_window_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_channels_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_channels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_cross_cov_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_cross_cov_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_blink_width_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_blink_width_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_moving_window_width_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_moving_window_width_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_moving_window_step_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_moving_window_step_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_voltage_threshold_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_voltage_threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_delta_blocking_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_delta_blocking_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function land_tool_Callback(hObject, eventdata, handles)

indxtool_earth = handles.indxtool_earth;
strtool_earth  = handles.strtool_earth;
listool = handles.listool;

indxtool_sky   = get(handles.listbox_tool_sky,'value');
strtool_sky    = get(handles.listbox_tool_sky,'String');

if ~isempty(strtool_earth)
        strtool_earth  = cat(2, strtool_earth, {strtool_sky{indxtool_sky}});
else
        strtool_earth = {strtool_sky{indxtool_sky}};
end

for t=1:5
        findrep = strcmpi(strtool_earth, listool{t});
        capindx = find(findrep);
        howmrep = length(capindx);
        
        if howmrep>10
                beep
                disp('error: maximum repetition per tool is 10')
                return
        end
        
end

indxtool_earth = length(strtool_earth);
set(handles.listbox_tool_earth,'Value', indxtool_earth, 'String', strtool_earth);

handles.strtool_earth = strtool_earth;
handles.indxtool_earth = indxtool_earth;

set(handles.erase_tool, 'Enable', 'on')

% Update handles structure
guidata(hObject, handles);

enablemenu(hObject, eventdata, handles)
checkreptool(hObject, eventdata, handles)
listbox_tool_earth_Callback(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function pushbutton2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function erase_tool_Callback(hObject, eventdata, handles)

indxtool_earth = handles.indxtool_earth;
strtool_earth  = handles.strtool_earth;
indxsetting = handles.indxsetting;

if indxtool_earth>=1
        strtool_earth{indxtool_earth}  = [];  
        aux = [];
        la  = length(strtool_earth);
        j=1;
        
        for i=1:la
                if ~isempty(strtool_earth{i})
                        aux{j} = strtool_earth{i};
                        j = j+1;
                else
                        indxtool_earth = indxtool_earth-1;
                end
        end
        
        strtool_earth  = [];
        strtool_earth  = aux;
        
        if indxtool_earth>1
                set(handles.listbox_tool_earth,'Value', indxtool_earth, 'String', strtool_earth);
        else
                set(handles.listbox_tool_earth,'Value', 1, 'String', strtool_earth);
        end
        
        if    indxtool_earth == 0 && la==1;
                set(handles.erase_tool, 'Enable', 'off')
        elseif   indxtool_earth == 0 && la>1;
                indxtool_earth = 1;
        end
        handles.strtool_earth  = strtool_earth;
        handles.indxtool_earth = indxtool_earth;        
end

% Update handles structure
guidata(hObject, handles);

enablemenu(hObject, eventdata, handles)
checkreptool(hObject, eventdata, handles)
listbox_tool_earth_Callback(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function listbox_tool_earth_Callback(hObject, eventdata, handles)

indxtool_earth   = get(handles.listbox_tool_earth,'Value');
handles.indxtool_earth = indxtool_earth;

% Update handles structure
guidata(hObject, handles);

enablemenu(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function listbox_tool_earth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton4_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton5_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton6_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton7_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton8_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton9_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function enablemenu(hObject, eventdata, handles)

indxtool_earth = handles.indxtool_earth;
strtool_earth  = handles.strtool_earth;

listtag = handles.listtag ;

InputValues = handles.InputValues;
switch isempty(strtool_earth)
        case 1
                
                for e=1:8
                        set(handles.(['edit_' listtag{e}]),'Enable', 'off')
                        set(handles.(['edit_' listtag{e}]),'String', '')
                end
                
        case 0
                switch strtool_earth{indxtool_earth}
                        case 'jumping-like'
                                
                                enableArray = {'on','on','off','on','off','off','off','off'};
                                for e=1:8
                                        set(handles.(['edit_' listtag{e}]),'Enable', enableArray{e})
                                        set(handles.(['edit_' listtag{e}]),'String', InputValues{1,1}{1,e})
                                end
                                
                        case 'step-like'
                                
                                enableArray = {'on','on','off','on','off','off','off','off'};
                                
                                for e=1:8
                                        set(handles.(['edit_' listtag{e}]),'Enable', enableArray{e})
                                        set(handles.(['edit_' listtag{e}]),'String', InputValues{1,2}{1,e})
                                end
                                
                        case 'voltage thresold'
                                
                                enableArray = {'on','on','on','off','off','on','on','off'};
                                for e=1:8
                                        set(handles.(['edit_' listtag{e}]),'Enable', enableArray{e})
                                        set(handles.(['edit_' listtag{e}]),'String', InputValues{1,3}{1,e})
                                end
                                
                        case 'moving window'
                                
                                enableArray = {'on','on','on','off','off','on','on','off'};
                                for e=1:8
                                        set(handles.(['edit_' listtag{e}]),'Enable', enableArray{e})
                                        set(handles.(['edit_' listtag{e}]),'String', InputValues{1,4}{1,e})
                                end
                                
                        case 'blink'
                                
                                enableArray = {'on','on','off','on','on','off','off','off'};
                                for e=1:8
                                        set(handles.(['edit_' listtag{e}]),'Enable', enableArray{e})
                                        set(handles.(['edit_' listtag{e}]),'String', InputValues{1,5}{1,e})
                                end
                end
end

% -------------------------------------------------------------------------
function defaultvalues(hObject, eventdata, handles)

EEG = handles.EEG;

for rt =1:10
        InputValues{rt,1} = {[num2str(EEG.xmin) ' ' num2str(EEG.xmax)],...
                num2str(EEG.nbchan), '--', '0.51','--','--', '--', '--'}; % jumping-like
        InputValues{rt,2} = {[num2str(EEG.xmin) ' ' num2str(EEG.xmax)],...
                num2str(EEG.nbchan), '--', '0.52','--','--', '--', '--'}; % step-like
        InputValues{rt,3} = {[num2str(EEG.xmin) ' ' num2str(EEG.xmax)],...
                num2str(EEG.nbchan), '30', '--','--','--', '--', '--'}; % voltage thresold
        InputValues{rt,4} = {[num2str(EEG.xmin) ' ' num2str(EEG.xmax)],...
                num2str(EEG.nbchan), '30', '--','--','40', '20', '--'}; % moving window
        InputValues{rt,5} = {[num2str(EEG.xmin) ' ' num2str(EEG.xmax)],...
                num2str(EEG.nbchan), '--', '0.6','0.4','--', '--', '3'}; % blink
end

% indexes and settings array

indxsetting = zeros(100,3);


handles.InputValues = InputValues ;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function checkreptool(hObject, eventdata, handles)

indxtool_earth = handles.indxtool_earth;
strtool_earth  = handles.strtool_earth;
listool = handles.listool;
listtag = handles.listtag ;
InputValues = handles.InputValues;

a=1;
for t=1:5
        findrep = strcmpi(strtool_earth, listool{t});
        capindx = find(findrep);
        howmrep = length(capindx);
        b = a + howmrep -1;
        
        indxsetting(a:b,:) = [capindx' repmat(t,howmrep,1) [1:howmrep]'];
        a = b+1;
end


handles.indxsetting = indxsetting;
% Update handles structure
guidata(hObject, handles);
