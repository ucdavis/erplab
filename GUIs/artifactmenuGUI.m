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

function varargout = artifactmenuGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @artifactmenuGUI_OpeningFcn, ...
        'gui_OutputFcn',  @artifactmenuGUI_OutputFcn, ...
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

% -----------------------------------------------------------------------
function artifactmenuGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

try
        prompt     = varargin{1};
        dlg_title  = varargin{2};
        def        = varargin{3};% memory
        defx       = varargin{4};% in case of reset
        chanlabels =  varargin{5};
catch
        prompt     = {'Test Period (ms)', 'Voltage Threshold (uV)', 'Moving Windows Full Width (ms)',...
                'Window Step (ms)','Channel(s)'};
        dlg_title  =  'Input threshold';
        def        = {[0 0] 0 0 0 0 0};
        defx       = def  ;
        chanlabels =  [];
end
viewer  = erpworkingmemory('artifact_viewer');
if ~isempty(viewer)
        set(handles.checkbox_viewer, 'Value', viewer{:});
else
        set(handles.checkbox_viewer, 'Value', 1); % default: ON
end

lprompt = length(prompt);
handles.lprompt = lprompt;
handles.defx    = defx;
fontsz  = 10;

for i=1:lprompt
        set(handles.(['text' num2str(i)]),'String', prompt{i},'FontSize', fontsz)
        
        if i==1
                strx = sprintf('%.1f  %.1f', def{i});
        else
                strx = vect2colon(def{i},'Delimiter','off');
        end
        
        set(handles.(['edit' num2str(i)]),'String', strx);
end
for i=lprompt+1:5
        set(handles.(['text' num2str(i)]),'String','');
        set(handles.(['text' num2str(i)]),'Visible','off');        
        set(handles.(['edit' num2str(i)]),'String','');
        set(handles.(['edit' num2str(i)]),'Visible','off');
end
for j=1:8
        handles.flg(j) = 0;
end
for i=2:8
        set(handles.(['flag_' num2str(i)]),'Value', 0);
end

flagx = def{end};

if flagx>1
        set(handles.(['flag_' num2str(flagx)]),'value', 1);
        handles.flg(flagx) = 1;
end

set(handles.flag_1,'Value',1)
set(handles.flag_1,'Enable','inactive')
set(handles.gui_chassis, 'Name', dlg_title)


%
% Prepare List of current Channels
%
listch = {''};
nchan  = length(chanlabels); % Total number of channels
if isempty(chanlabels)
        for e = 1:nchan
                chanlabels{e} = ['Ch' num2str(e)];
        end
end
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' chanlabels{ch} ];
end

handles.listch     = listch;
handles.indxlistch = def{lprompt}; % channel array

%
% Paint GUI
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

% UIWAIT makes artifactmenuGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = artifactmenuGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit3_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit4_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function flag_8_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_8,'value', 1);
        handles.flg(8) = 1;
else
        handles.flg(8) = 0;
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_7_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_7,'value', 1);
        handles.flg(7) = 1;
else
        handles.flg(7) = 0;
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_6_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_6,'value', 1);
        handles.flg(6) = 1;
else
        handles.flg(6) = 0;
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_5_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_5,'value', 1);
        handles.flg(5) = 1;
else
        handles.flg(5) = 0;
end

guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_4_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_4,'value', 1);
        handles.flg(4) = 1;
else
        handles.flg(4) = 0;
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_3_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_3,'value', 1);
        handles.flg(3) = 1;
else
        handles.flg(3) = 0;
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_2_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        for i=2:8
                set(handles.(['flag_' num2str(i)]), 'value',0);
        end
        set(handles.flag_2,'value', 1);
        handles.flg(2) = 1;
else
        handles.flg(2) = 0;
end

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function flag_1_Callback(hObject, eventdata, handles)
% RESERVED!

%--------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)

lprompt = handles.lprompt;
defx = handles.defx;
def = defx;

for i=1:lprompt
        
        if i==1
                strx = sprintf('%.1f  %.1f', def{i});
        else
                strx = vect2colon(def{i},'Delimiter','off');
        end
        
        set(handles.(['edit' num2str(i)]),'String', strx);
end
for i=2:8
        set(handles.(['flag_' num2str(i)]),'Value', 0);
end

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
%fctn = dbstack;
%fctn = fctn(end).name;
%doc(fctn) 
web https://github.com/lucklab/erplab/wiki/Artifact-Detection-in-Epoched-Data -browser

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% % % %--------------------------------------------------------------------------
% % % function popupmenu_channels_Callback(hObject, eventdata, handles)
% % % lprompt = handles.lprompt;
% % % % nchan   = handles.nchan;
% % % numch = get(hObject, 'Value');
% % % nums  = str2num(get(handles.(['edit' num2str(lprompt)]),'String'));
% % % nums  = [nums numch];
% % % if isempty(nums)
% % %         msgboxText{1} =  'Invalid channel indexing.';
% % %         title = 'ERPLAB: basicfilterGUI() error:';
% % %         errorfound(msgboxText, title);
% % %         return
% % % end
% % % chxstr = vect2colon(nums,'Delimiter','off', 'Repeat', 'off');
% % % set(handles.(['edit' num2str(lprompt)]),'String', chxstr)
% % % 
% % % %--------------------------------------------------------------------------
% % % function popupmenu_channels_CreateFcn(hObject, eventdata, handles)
% % % 
% % % % Hint: popupmenu controls usually have a white background on Windows.
% % % %       See ISPC and COMPUTER.
% % % if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
% % %     set(hObject,'BackgroundColor','white');
% % % end

%--------------------------------------------------------------------------
function pushbutton_accept_Callback(hObject, eventdata, handles)

lprompt = handles.lprompt;
outputv = cell(1);
viewer  = get(handles.checkbox_viewer, 'Value');

for k=1:lprompt
        outputv{k} = str2num(get(handles.(['edit' num2str(k)]), 'String'));
end

flagout = [];

for i=2:8
        if get(handles.(['flag_' num2str(i)]),'Value')
                flagout = i;
        end;
end

outputv{end+1} = [1 flagout]; % flag 1 is set by default (always) 
outputv{end+1} = viewer;      % open viewer
handles.output = outputv;

erpworkingmemory('artifact_viewer', {viewer});

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function checkbox_viewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_browsechan_Callback(hObject, eventdata, handles)
lprompt    = handles.lprompt;
listch     = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select Channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                        %set(handles.edit_channels, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        set(handles.(['edit' num2str(lprompt)]),'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.indxlistch = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: basicfilter GUI input';
                errorfound(msgboxText, title);
                return
        end
end

%--------------------------------------------------------------------------
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
