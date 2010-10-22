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

function varargout = errorGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @errorGUI_OpeningFcn, ...
        'gui_OutputFcn',  @errorGUI_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
if nargin && ischar(varargin{1})
        if isempty(strfind(varargin{1},' ')) && isempty(str2num(varargin{1}))
                gui_State.gui_Callback = str2func(varargin{1});
        end
end

if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
        gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%--------------------------------------------------------------------------
function errorGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];

% Update handles structure
guidata(hObject, handles);

message = varargin{1};
title   = varargin{2};
imagein = varargin{3};
map     = varargin{4};

if nargin<6
        showfig = 1;
else
        showfig = varargin{6};
end
if nargin<5
        bcolor = [1 0 0];
else
        bcolor = varargin{5};
end

fprintf('%s\n', repmat('*',1,50));

if iscell(message)
        message = [message{:}];
end

fprintf('Full error message: \n %s\n', message);
message = regexprep(message,'<.*>|Error using ==>','');
bottomline = 'If you think this is a bug, please report the error to erplab@erpinfo.org and not to the EEGLAB developers.';
disp(bottomline)
fprintf('%s\n', repmat('*',1,50));
set(handles.text_message, 'String', message)
set(handles.text_message, 'Backgroundcolor', bcolor, 'FontSize', 12,'ForegroundColor', 'k')
set(handles.text_bottom, 'String', bottomline)
set(handles.text_bottom, 'Backgroundcolor', bcolor, 'FontSize', 10,'ForegroundColor', 'k')
set(handles.main_figure_error,'Name', title,'WindowStyle','modal', 'Units', 'pixels')
set(handles.main_figure_error,'Color', bcolor)

if showfig
        axes(handles.axes_pict)
        sizep     = size(imagein);   % Determine the size of the image file
        set(handles.axes_pict,'Units', 'pixels');
        canvasize = get(handles.axes_pict,'Position'); % size of the image
        factors   = sizep(1)/canvasize(4);
        xoffset   = (canvasize(3)-sizep(2)/factors)/2;
        image(imagein)
        colormap(map)
        set(handles.axes_pict, 'Visible', 'off','Position', [xoffset canvasize(2) sizep(2)/factors sizep(1)/factors])
else
        set(handles.axes_pict, 'Visible', 'off')        
end

drawnow

% UIWAIT makes errorGUI wait for user response (see UIRESUME)
uiwait(handles.main_figure_error);

%--------------------------------------------------------------------------
function varargout = errorGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.main_figure_error);
pause(0.1)

%--------------------------------------------------------------------------
function text_message_CreateFcn(hObject, eventdata, handles)
%--------------------------------------------------------------------------
function axes_pict_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function main_figure_error_CloseRequestFcn(hObject, eventdata, handles)
handles.output = '';
% Update handles structure
guidata(hObject, handles);

if isequal(get(handles.main_figure_error, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.main_figure_error);
else
        % The GUI is no longer waiting, just close it
        delete(handles.main_figure_error);
end

%--------------------------------------------------------------------------
% --- Executes on button press in button_OK.
function button_ok_Callback(hObject, eventdata, handles)

handles.output = 'ok';

% Update handles structure
guidata(hObject, handles);
uiresume(handles.main_figure_error);

%--------------------------------------------------------------------------
function text_bottom_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function main_figure_error_CreateFcn(hObject, eventdata, handles)
