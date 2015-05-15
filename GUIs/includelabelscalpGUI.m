% Author: Javier Lopez-Calderon
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

function varargout = includelabelscalpGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @includelabelscalpGUI_OpeningFcn, ...
        'gui_OutputFcn',  @includelabelscalpGUI_OutputFcn, ...
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
function includelabelscalpGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];
%values = [binnum bindesc type latency electrodes colorbar];
try
        val = varargin{1};
catch
        val = {1 0 0 1 1 'on' 'off' 0};
end
try
        is2Dmap = varargin{2}; % check 2D map
catch
        is2Dmap = 1;
end

binnum     = val{1};
bindesc    = val{2};
type       = val{3};
latency    = val{4};
electrodes = val{5};
elestyle   = val{6};
elec3D     = val{7};
% colorbar   = val(6);
ismaxim    = val{8};

set(handles.checkbox_binnumber,'Value', binnum)
set(handles.checkbox_bindescription,'Value', bindesc)
set(handles.checkbox_tvalue,'Value', type)
set(handles.checkbox_latency,'Value', latency)

% if is2Dmap
if electrodes && ~strcmpi(elec3D, 'on')
        switch elestyle
                case 'on'
                        set(handles.checkbox_electrodes,'Value', 1)
                        set(handles.radiobutton_excludepoints,'Value', 0)
                        set(handles.radiobutton_showenumber,'Value', 0)
                        set(handles.radiobutton_showelabel,'Value', 0)
                        set(handles.radiobutton_excludepoints,'Enable', 'off')
                case 'off'
                        set(handles.checkbox_electrodes,'Value', 0)
                        set(handles.radiobutton_excludepoints,'Value', 0)
                        set(handles.radiobutton_showenumber,'Value', 0)
                        set(handles.radiobutton_showelabel,'Value', 0)
                        
                        set(handles.radiobutton_excludepoints,'Enable', 'off')
                        set(handles.radiobutton_showenumber,'Enable', 'off')
                        set(handles.radiobutton_showelabel,'Enable', 'off')
                case 'numbers'
                        set(handles.checkbox_electrodes,'Value', 1)
                        set(handles.radiobutton_excludepoints,'Value', 1)
                        set(handles.radiobutton_showenumber,'Value', 1)
                        set(handles.radiobutton_showelabel,'Value', 0)
                case 'labels'
                        set(handles.checkbox_electrodes,'Value', 1)
                        set(handles.radiobutton_excludepoints,'Value', 1)
                        set(handles.radiobutton_showenumber,'Value', 0)
                        set(handles.radiobutton_showelabel,'Value', 1)
                case 'ptsnumbers'
                        set(handles.checkbox_electrodes,'Value', 1)
                        set(handles.radiobutton_excludepoints,'Value', 0)
                        set(handles.radiobutton_showenumber,'Value', 1)
                        set(handles.radiobutton_showelabel,'Value', 0)
                case 'ptslabels'
                        set(handles.checkbox_electrodes,'Value', 1)
                        set(handles.radiobutton_excludepoints,'Value', 0)
                        set(handles.radiobutton_showenumber,'Value', 0)
                        set(handles.radiobutton_showelabel,'Value', 1)
                otherwise
                        set(handles.checkbox_electrodes,'Value', 0)
                        set(handles.radiobutton_excludepoints,'Value', 0)
                        set(handles.radiobutton_showenumber,'Value', 0)
                        set(handles.radiobutton_showelabel,'Value', 0)
                        
                        set(handles.radiobutton_excludepoints,'Enable', 'off')
                        set(handles.radiobutton_showenumber,'Enable', 'off')
                        set(handles.radiobutton_showelabel,'Enable', 'off')
        end
        
        %         if ~elecexcpnts && ~elecshownum && ~elecshowlab
        %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
        %                 elestyle = 'on';
        %         elseif ~elecexcpnts && elecshownum && ~elecshowlab
        %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
        %                 elestyle = 'numbers';
        %         elseif ~elecexcpnts && ~elecshownum && elecshowlab
        %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
        %                 elestyle = 'labels';
        %         elseif elecexcpnts && elecshownum && ~elecshowlab
        %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
        %                 elestyle = 'ptsnumbers';
        %         elseif elecexcpnts && ~elecshownum && elecshowlab
        %                 %'on','off','labels','numbers','ptslabels','ptsnumbers'
        %                 elestyle = 'ptslabels';
        %         else
        %                 return
        %         end
else
        %elestyle = 'off';
        set(handles.checkbox_electrodes,'Value', 0)
end
if is2Dmap
        set(handles.checkbox_3Delec,'Value', 0)
        set(handles.checkbox_3Delec,'Enable', 'off')
else
        if strcmpi(elec3D, 'on')
                set(handles.checkbox_3Delec,'Value', 1)
                set(handles.checkbox_electrodes,'Value', 1)                
                
                set(handles.radiobutton_excludepoints,'Value', 0)
                set(handles.radiobutton_showenumber,'Value', 0)
                set(handles.radiobutton_showelabel,'Value', 0)
                
                %set(handles.checkbox_electrodes,'Enable', 'off')
                set(handles.radiobutton_excludepoints,'Enable', 'off')
                set(handles.radiobutton_showenumber,'Enable', 'off')
                set(handles.radiobutton_showelabel,'Enable', 'off')
        end
end
% else
%         if strcmpi(elec3D, 'on')
%                 set(handles.checkbox_3Delec,'Value', 1)
%                 set(handles.checkbox_electrodes,'Value', 1)
%         else
%                 if electrodes
%                         set(handles.checkbox_3Delec,'Enable', 'on')
%                         set(handles.checkbox_3Delec,'Value', 0)
%                         set(handles.checkbox_electrodes,'Value', 1)
%                 else
%                         set(handles.checkbox_3Delec,'Enable', 'off')
%                         set(handles.checkbox_electrodes,'Value', 0)
%                 end
%         end
%
% % % %         %set(handles.checkbox_electrodes,'Value', 0)
% % % %         set(handles.radiobutton_excludepoints,'Value', 0)
% % % %         set(handles.radiobutton_showenumber,'Value', 0)
% % % %         set(handles.radiobutton_showelabel,'Value', 0)
% % % %
% % % %         %set(handles.checkbox_electrodes,'Enable', 'off')
% % % %         set(handles.radiobutton_excludepoints,'Enable', 'off')
% % % %         set(handles.radiobutton_showenumber,'Enable', 'off')
% % % %         set(handles.radiobutton_showelabel,'Enable', 'off')
% end

% plotset.pscalp.plegend.elestyle   = handles.Legelestyle;

% set(handles.checkbox_cbar,'Value', colorbar)
set(handles.checkbox_maximize,'Value', ismaxim)

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

handles.is2Dmap = is2Dmap;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes includelabelscalpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -----------------------------------------------------------------------
function varargout = includelabelscalpGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -----------------------------------------------------------------------
function checkbox_binnumber_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_bindescription_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_tvalue_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_latency_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_electrodes_Callback(hObject, eventdata, handles)

is2Dmap = handles.is2Dmap;

if get(hObject, 'value')
%         if is2Dmap
                set(handles.radiobutton_excludepoints,'Enable', 'off')
                set(handles.radiobutton_showenumber,'Enable', 'on')
                set(handles.radiobutton_showelabel,'Enable', 'on')
%         else
%                 set(handles.radiobutton_excludepoints,'Enable', 'off')
%                 set(handles.radiobutton_showenumber,'Enable', 'off')
%                 set(handles.radiobutton_showelabel,'Enable', 'off') 
                set(handles.checkbox_3Delec,'Enable', 'on') 
%         end
else
        set(handles.radiobutton_excludepoints,'Value', 0)
        set(handles.radiobutton_showenumber,'Value', 0)
        set(handles.radiobutton_showelabel,'Value', 0)
        set(handles.checkbox_3Delec,'Value', 0) 
        
        set(handles.radiobutton_excludepoints,'Enable', 'off')
        set(handles.radiobutton_showenumber,'Enable', 'off')
        set(handles.radiobutton_showelabel,'Enable', 'off')
        set(handles.checkbox_3Delec,'Enable', 'off') 
end
% -----------------------------------------------------------------------
function radiobutton_excludepoints_Callback(hObject, eventdata, handles)
% if get(hObject, 'value')
%
% else
%
% end

% -----------------------------------------------------------------------
function radiobutton_showenumber_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_showelabel,'Value', 0)
        set(handles.radiobutton_excludepoints,'Enable', 'on')
else
        %set(handles.radiobutton_showenumber,'Value', 1
        if ~get(handles.radiobutton_showenumber,'Value')
                set(handles.radiobutton_excludepoints,'Value', 0)
                set(handles.radiobutton_excludepoints,'Enable', 'off')
        end
end
% 'on','off','labels','numbers','ptslabels','ptsnumbers'

% -----------------------------------------------------------------------
function radiobutton_showelabel_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_showenumber,'Value', 0)
        set(handles.radiobutton_excludepoints,'Enable', 'on')
else
        %set(handles.radiobutton_showelabel,'Value', 1)
        if ~get(handles.radiobutton_showelabel,'Value')
                set(handles.radiobutton_excludepoints,'Value', 0)
                set(handles.radiobutton_excludepoints,'Enable', 'off')
        end
end

% -----------------------------------------------------------------------
% function checkbox_cbar_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function checkbox_maximize_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

binnum     = get(handles.checkbox_binnumber,'Value');
bindesc    = get(handles.checkbox_bindescription,'Value');
type       = get(handles.checkbox_tvalue,'Value');
latency    = get(handles.checkbox_latency,'Value');
electrodes = get(handles.checkbox_electrodes,'Value');

elecexcpnts = get(handles.radiobutton_excludepoints,'Value');
elecshownum = get(handles.radiobutton_showenumber,'Value');
elecshowlab = get(handles.radiobutton_showelabel,'Value');

if electrodes
        if ~elecexcpnts && ~elecshownum && ~elecshowlab
                %'on','off','labels','numbers','ptslabels','ptsnumbers'
                elestyle = 'on';
        elseif ~elecexcpnts && elecshownum && ~elecshowlab
                %'on','off','labels','numbers','ptslabels','ptsnumbers'
                elestyle = 'ptsnumbers';
        elseif ~elecexcpnts && ~elecshownum && elecshowlab
                %'on','off','labels','numbers','ptslabels','ptsnumbers'
                elestyle = 'ptslabels';
        elseif elecexcpnts && elecshownum && ~elecshowlab
                %'on','off','labels','numbers','ptslabels','ptsnumbers'
                elestyle = 'numbers';
        elseif elecexcpnts && ~elecshownum && elecshowlab
                %'on','off','labels','numbers','ptslabels','ptsnumbers'
                elestyle = 'labels';
        else
                return
        end
else
        elestyle = 'off';
end

el3D = get(handles.checkbox_3Delec,'Value');
if el3D
        elec3D = 'on';
else
        elec3D = 'off';
end

% colorbar   = get(handles.checkbox_cbar,'Value');
ismaxim    = get(handles.checkbox_maximize,'Value');

% handles.output = [binnum bindesc type latency electrodes colorbar ismaxim];
handles.output = {binnum bindesc type latency electrodes elestyle elec3D ismaxim};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function checkbox_3Delec_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        %set(handles.checkbox_electrodes,'Value', 0)
        set(handles.radiobutton_excludepoints,'Value', 0)
        set(handles.radiobutton_showenumber,'Value', 0)
        set(handles.radiobutton_showelabel,'Value', 0)
        
        %set(handles.checkbox_electrodes,'Enable', 'off')
        set(handles.radiobutton_excludepoints,'Enable', 'off')
        set(handles.radiobutton_showenumber,'Enable', 'off')
        set(handles.radiobutton_showelabel,'Enable', 'off')
else
        %set(handles.radiobutton_excludepoints,'Value', 0)
        %set(handles.radiobutton_showenumber,'Value', 0)
        %set(handles.radiobutton_showelabel,'Value', 0)
        
        %set(handles.checkbox_electrodes,'Enable', 'off')
        set(handles.radiobutton_excludepoints,'Enable', 'off')
        set(handles.radiobutton_showenumber,'Enable', 'on')
        set(handles.radiobutton_showelabel,'Enable', 'on')
end

% -----------------------------------------------------------------------
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



