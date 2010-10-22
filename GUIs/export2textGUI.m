%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% Copyright (C) 2008   Javier Lopez-Calderon  &  Steven Luck,
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

function varargout = export2textGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @export2textGUI_OpeningFcn, ...
        'gui_OutputFcn',  @export2textGUI_OutputFcn, ...
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
function export2textGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for export2textGUI
handles.output = [];

% Update handles structure
guidata(hObject, handles);

ERP = varargin{1};

%
% Prepare List of current Bins
%
if ~isempty(ERP)
        listb = [];
        nbin  = ERP.nbin; % Total number of channels
        
        for b=1:nbin
                listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
        end
        
        set(handles.popupmenu_bins,'String', listb)
        set(handles.edit_bins,'String', vect2colon(1:nbin, 'Delimiter','no'))
        drawnow
else
        set(handles.popupmenu_bins,'String', 'No Bins')
        drawnow
end

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB ' version '   -   Export ERP GUI'])
set(handles.popupmenu_tunits,'String',{'seconds';'milliseconds'})
set(handles.popupmenu_precision,'String', num2str([1:10]'))
set(handles.popupmenu_precision,'Value', 4)
set(handles.checkbox_time,'Value', 1)
set(handles.checkbox_elabels,'Value', 1)
set(handles.radiobutton_pr_ec,'Value', 1)

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes export2textGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = export2textGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

%--------------------------------------------------------------------------
function checkbox_time_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_elabels_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_tunits_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_tunits_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_precision_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_precision_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        handles.output = [];
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function pushbutton_export_Callback(hObject, eventdata, handles)

istime = get(handles.checkbox_time, 'value');
timeu  = get(handles.popupmenu_tunits, 'value');

if timeu == 1
        timeunit = 1E0;
else
        timeunit = 1E-3;
end

islabeled = get(handles.checkbox_elabels, 'value');
transpa   = get(handles.radiobutton_er_pc, 'value');
precision = get(handles.popupmenu_precision, 'value');
filename  = get(handles.edit_saveas, 'string');
bins      = str2num(get(handles.edit_bins, 'string'));

if strcmp(filename,'')
        msgboxText =  'You must enter an erpname!';
        title = 'ERPLAB: export2text empty filename';
        errorfound(msgboxText, title);
        return
end

if isempty(bins)
        msgboxText =  'You must enter at least 1 bin!';
        title = 'ERPLAB: export2text empty bin list';
        errorfound(msgboxText, title);
        return
end

answer = {istime, timeunit, islabeled, transpa, precision, bins, filename};
handles.output = answer;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

% -------------------------------------------------------------------------
function edit_saveas_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_saveas_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_Callback(hObject, eventdata, handles)

%
% Save OUTPUT file
%
prename = get(handles.edit_saveas,'String');
[fname, pathname, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save Output file as', prename);

if isequal(fname,0)
        disp('User selected Cancel')
        return
else
        
        [px, fname2, ext, versn] = fileparts(fname);
        
        if strcmp(ext,'')
                
                if filterindex==1 || filterindex==3
                        ext   = '.txt';
                else
                        ext   = '.dat';
                end
                
                fname = [ fname2 ext];
        end
        
        set(handles.edit_saveas,'String', fullfile(pathname, fname));
        disp(['To save ERP, user selected ', fullfile(pathname, fname)])
end

% -------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_bins_Callback(hObject, eventdata, handles)
numbin   = get(hObject, 'Value');
nums = get(handles.edit_bins, 'String');
nums = [nums ' ' num2str(numbin)];
set(handles.edit_bins, 'String', nums);
