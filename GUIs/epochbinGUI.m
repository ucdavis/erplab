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

function varargout = epochbinGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @epochbinGUI_OpeningFcn, ...
        'gui_OutputFcn',  @epochbinGUI_OutputFcn, ...
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
function epochbinGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for epochbinGUI
handles.output = [];
try
        def = varargin{1};
        xrangle = def{1};
        xmin = xrangle(1);
        xmax = xrangle(2);
        blc  = def{2};
catch
        xmin = -200;
        xmax = 800;
        blc = 'pre';
end
handles.xmin = xmin;
handles.xmax = xmax;
handles.blc  = blc;

% % % set(handles.checkbox_blc,'Value', 1)
set(handles.edit_epoch,'String', num2str([xmin xmax]));
if isnumeric(blc)
        set(handles.radiobutton_custom,'Value', 1)
        set(handles.edit_custom,'String', num2str(blc));
else
        set(handles.edit_custom,'Enable','off')
        switch blc
                case 'pre'
                        set(handles.radiobutton_pre,'Value', 1)
                case 'post'
                        set(handles.radiobutton_post,'Value', 1)
                case 'all'
                        set(handles.radiobutton_all,'Value', 1)
                case 'none'
                        set(handles.radiobutton_none,'Value', 1)
                otherwise
                        set(handles.radiobutton_custom,'Value', 1)
        end
end

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   EXTRACT BINEPOCHS GUI'])

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

tooltip1  = ['<html><i>If you are going to estimate power spectrum at some point later then<br>increase the size of your epochs''s window a 5% (of the originally planned width)<br>'...
        'on each side. This strategy offsets the minimal weight applied to the<br>end of the epoch due to the Hamming window function.'];

set(handles.edit_hint, 'tooltip',tooltip1);

% Update handles structure
guidata(hObject, handles);

% help
helpbutton

% UIWAIT makes epochbinGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = epochbinGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.5)

%--------------------------------------------------------------------------
function edit_custom_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_custom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_epoch_Callback(hObject, eventdata, handles)

% if strcmp(get(hObject,'String'),'')
% % % %         set(handles.checkbox_blc,'Value',0)
% end

%--------------------------------------------------------------------------
function edit_epoch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% handles    structure with handles and user data (see GUIDATA)
handles.output = [];

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_epochbin
web https://github.com/lucklab/erplab/wiki/Epoching-Bins -browser

%--------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)

epoch = str2num(get(handles.edit_epoch,'String'));

if isempty(epoch)
        msgboxText =  'Wrong epoch range!';
        title = 'ERPLAB: Bin-based epoch inputs';
        errorfound(msgboxText, title);
        return
else
        repoch = size(epoch,1);
        cepoch = size(epoch,2);
        blc = handles.blc;
        
        cusbutt = get(handles.radiobutton_custom,'Value');
        
        %
        % Checks updated custom blc values
        %
        if cusbutt
                blctest  = str2num(get(handles.edit_custom,'String'));
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
                custupdated =1;
        end
        if repoch==1 && cepoch==2 && custupdated
                if epoch(1)>=epoch(2)
                        msgboxText{1} =  'For epoch range, lower time limit must be on the left';
                        msgboxText{2} =  'Additionally, lower time limit must be at least 1/sample rate second lesser than the higher one.';
                        title = 'ERPLAB: Bin-based epoch inputs';
                        errorfound(msgboxText, title);
                        return
                end
                if epoch(1)>0 || epoch(2)<0
                        msgboxText =  'Epoch range must span across time zero';
                        title = 'ERPLAB: Bin-based epoch inputs';
                        errorfound(msgboxText, title);
                        return
                end
                if epoch(1)>=0 && strcmpi(blc,'pre')
                        msgboxText =  'There is no pre-stimulus interval';
                        title = 'ERPLAB: Bin-based epoch inputs';
                        errorfound(msgboxText, title);
                        return
                end
                if epoch(2)<=0 && strcmpi(blc,'post')
                        msgboxText =  'There is no post-stimulus interval';
                        title = 'ERPLAB: Bin-based epoch inputs';
                        errorfound(msgboxText, title);
                        return
                end
                
                %
                %  Go ahead!
                %
                handles.output = {epoch, blc};
                
                % Update handles structure
                guidata(hObject, handles);
                uiresume(handles.gui_chassis);
        else
                if custupdated
                        msgboxText =  'Wrong epoch range!';
                        title = 'ERPLAB: Bin-based epoch inputs';
                        errorfound(msgboxText, title);
                else
                        msgboxText =  'Wrong baseline range!';
                        title = 'ERPLAB: Bin-based epoch inputs';
                        errorfound(msgboxText, title);
                end
                return
        end
end

%--------------------------------------------------------------------------
function radiobutton_none_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc = 'none';
handles.blc = blc;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function radiobutton_pre_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc = 'pre';
handles.blc = blc;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function radiobutton_post_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc = 'post';
handles.blc = blc;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function radiobutton_all_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','off')
set(handles.edit_custom,'String','')
blc = 'all';
handles.blc = blc;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function radiobutton_custom_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
        set(hObject,'Value',1)
end
set(handles.edit_custom,'Enable','on')
blc = get(handles.edit_epoch,'String');
handles.blc = blc;
% Update handles structure
guidata(hObject, handles);

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

% % % %--------------------------------------------------------------------------
% % % function checkbox_blc_Callback(hObject, eventdata, handles)
% % %
% % % if get(hObject,'Value')% && repoch==1 && cepoch==2
% % %         set(handles.radiobutton_none,'Enable','on')
% % %         set(handles.radiobutton_pre,'Enable','on')
% % %         set(handles.radiobutton_post,'Enable','on')
% % %         set(handles.radiobutton_all,'Enable','on')
% % %         set(handles.radiobutton_custom,'Enable','on')
% % %         set(handles.edit_custom,'Enable','on')
% % % else
% % %         set(handles.checkbox_blc,'Value',0)
% % %
% % %         set(handles.radiobutton_none,'Value',1)
% % %         set(handles.radiobutton_pre,'Value',0)
% % %         set(handles.radiobutton_post,'Value',0)
% % %         set(handles.radiobutton_all,'Value',0)
% % %         set(handles.radiobutton_custom,'Value',0)
% % %         set(handles.edit_custom,'String','')
% % %
% % %         set(handles.radiobutton_none,'Enable','off')
% % %         set(handles.radiobutton_pre,'Enable','off')
% % %         set(handles.radiobutton_post,'Enable','off')
% % %         set(handles.radiobutton_all,'Enable','off')
% % %         set(handles.radiobutton_custom,'Enable','off')
% % %         set(handles.edit_custom,'Enable','off')
% % %
% % %         blc = 'none';
% % %         handles.blc = blc;
% % %         % Update handles structure
% % %         guidata(hObject, handles);
% % % end
