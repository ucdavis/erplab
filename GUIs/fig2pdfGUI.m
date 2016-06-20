% *** This function is part of ERPLAB Toolbox ***
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

function varargout = fig2pdfGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @fig2pdfGUI_OpeningFcn, ...
        'gui_OutputFcn',  @fig2pdfGUI_OutputFcn, ...
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


%------------------------------------------------------------------------------------------
function fig2pdfGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = [];

% def = {{'ERP_figure'}, 'saveas', [], 'pdf', 300};

try
        def = varargin{1};
        tag = def{1};
        savetype   = def{2};
        path4fig   = def{3};
        format4fig = def{4};
        resol      = def{5};
catch
        tag        = {'ERP_figure' 'Scalp_figure'};
        savetype   = 'saveas';
        path4fig   = '';
        format4fig = 'pdf';
        resol      = 300;
end
if ismember_bc2('ERP_figure', tag)
        set(handles.checkbox_erp, 'Value', 1)
        set(handles.edit_tag, 'Enable', 'off')
        set(handles.edit_tag, 'String', '')
end
if ismember_bc2('Scalp_figure', tag)
        set(handles.checkbox_scalp, 'Value', 1)
        set(handles.edit_tag, 'Enable', 'off')
        set(handles.edit_tag, 'String', '')
end
if ~ismember_bc2('Scalp_figure', tag) && ~ismember_bc2('ERP_figure', tag)
        set(handles.checkbox_other, 'Value', 1)
        set(handles.edit_tag, 'Enable', 'on')
        set(handles.edit_tag, 'String', tag)
end

set(handles.popupmenu_format, 'String', {'PDF (*.pdf)', 'EPS (*.eps)', 'JPG (*.jpg)', 'TIFF (*.tiff)'})
resolval = {'72','150','300','600','1200'};
set(handles.popupmenu_jpgres, 'String', resolval)
indxres  =  find(ismember_bc2(resolval, num2str(resol)));
set(handles.popupmenu_jpgres, 'Value', indxres)

if strcmpi(savetype, 'auto')
        if strcmpi(format4fig, 'pdf')
                v=1;
        elseif strcmpi(format4fig, 'eps')
                v=2;
        elseif strcmpi(format4fig, 'jpg')
                v=3;
        elseif strcmpi(format4fig, 'tiff')
                v=4;
        else
                v=1;
        end
        set(handles.edit_path, 'String', path4fig)
        set(handles.popupmenu_format, 'Enable', 'on')
        set(handles.popupmenu_format, 'Value', v)
        set(handles.pushbutton_browsepath, 'Enable', 'on')
        set(handles.radiobutton_opensaveas, 'Value', 0)
        set(handles.radiobutton_autoname, 'Value', 1)        
else
        set(handles.radiobutton_opensaveas, 'Value', 1)
        set(handles.radiobutton_autoname, 'Value', 0)
        set(handles.popupmenu_format, 'Value', 1)
        set(handles.popupmenu_format, 'Enable', 'off')
        set(handles.edit_path, 'String', '')
        set(handles.edit_path, 'Enable', 'off')
        set(handles.pushbutton_browsepath, 'Enable', 'off')
end

version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Print to file GUI'])

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

handles.path4fig = path4fig;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fig2pdfGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%------------------------------------------------------------------------------------------
function varargout = fig2pdfGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)


%------------------------------------------------------------------------------------------
function checkbox_erp_Callback(hObject, eventdata, handles)
if ~get(hObject, 'Value')
        if ~get(handles.checkbox_scalp, 'Value') && ~get(handles.checkbox_other, 'Value')
                set(handles.checkbox_erp, 'Value', 1)
        end
end

%------------------------------------------------------------------------------------------
function checkbox_scalp_Callback(hObject, eventdata, handles)
if ~get(hObject, 'Value')
        if ~get(handles.checkbox_erp, 'Value') && ~get(handles.checkbox_other, 'Value')
                set(handles.checkbox_scalp, 'Value', 1)
        end
end

%------------------------------------------------------------------------------------------
function checkbox_other_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.edit_tag, 'Enable', 'on')
else
        if ~get(handles.checkbox_erp, 'Value') && ~get(handles.checkbox_scalp, 'Value')
                set(handles.checkbox_other, 'Value', 1)
        else
                set(handles.edit_tag, 'Enable', 'off')
        end
end

%------------------------------------------------------------------------------------------
function edit_tag_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------------------
function edit_tag_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------------------------
function radiobutton_autoname_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.edit_path, 'Enable', 'on')
        set(handles.edit_path, 'String', '')
        set(handles.popupmenu_format, 'Enable', 'on')
        set(handles.popupmenu_format, 'Value', 1)
        set(handles.pushbutton_browsepath, 'Enable', 'on')
        set(handles.radiobutton_opensaveas, 'Value', 0)
else
        set(handles.radiobutton_autoname, 'Value', 1)
end
%------------------------------------------------------------------------------------------
function radiobutton_opensaveas_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_autoname, 'Value', 0)
        set(handles.popupmenu_format, 'Value', 1)
        set(handles.popupmenu_format, 'Enable', 'off')
        set(handles.edit_path, 'String', '')
        set(handles.edit_path, 'Enable', 'off')
        set(handles.pushbutton_browsepath, 'Enable', 'off')
else
        set(handles.radiobutton_opensaveas, 'Value', 1)
end

%------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%------------------------------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)
if ~get(handles.checkbox_erp, 'Value') && ~get(handles.checkbox_scalp, 'Value') && ~get(handles.checkbox_other, 'Value')
        return
end
if ~get(handles.radiobutton_autoname, 'Value') && ~get(handles.radiobutton_opensaveas, 'Value')
        return
end
figtype = cell(1);
if get(handles.checkbox_erp, 'Value')
        figtype = [figtype 'ERP_figure'];
end
if get(handles.checkbox_scalp, 'Value')
        figtype = [figtype 'Scalp_figure'];
end
if get(handles.checkbox_other, 'Value')
        ft = get(handles.edit_tag, 'String');
        if isempty(ft)
                return
        end
        ft = cellstr(ft);
        ft = regexp(ft{:},' ', 'split');
        ft = regexprep(ft,'''', '');
        figtype = [figtype ft];
end
if get(handles.radiobutton_autoname, 'Value')
        saveasmode = 'auto';
        filepath   = get(handles.edit_path, 'String');
        fileformat = get(handles.popupmenu_format, 'Value');
        
        if fileformat==1
                fformat = 'pdf';
        elseif fileformat==2
                fformat = 'eps';
        elseif fileformat==3
                fformat = 'jpg';
        elseif fileformat==4
                fformat = 'tiff';
        else
                fformat = 'pdf';
        end        
else
        saveasmode = 'saveas';
        filepath   = [];
        fformat    = 'pdf';
end

resindx = get(handles.popupmenu_jpgres, 'Value');
resstr  = get(handles.popupmenu_jpgres, 'String');
resolution = str2num(resstr{resindx});
figtype = figtype(~cellfun(@isempty, figtype));

handles.output = {figtype, saveasmode, filepath, fformat, resolution};
% D20= sacramento

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


%------------------------------------------------------------------------------------------
function edit_path_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------------------
function edit_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------------------------
function pushbutton_browsepath_Callback(hObject, eventdata, handles)
path4fig = handles.path4fig;
if isempty(path4fig)
        path4fig = cd;
end
pathname = uigetdir(path4fig);

set(handles.edit_path, 'String', pathname)
%------------------------------------------------------------------------------------------
function popupmenu_format_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------------------------
function popupmenu_format_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_jpgres_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_jpgres_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
