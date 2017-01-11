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
try
      ERP = varargin{1};
catch
      ERP = [];
end
try
        def = varargin{2};
catch
        def = {1,1000, 1, 1, 4, 1, ''};
end

istime    = def{1};
tunit     = def{2};
islabeled = def{3};
transpa   = def{4};
prec      = def{5};
binArray  = def{6};
filename  = def{7};

if tunit == 1
        tunitx = 1;
else
        tunitx = 2;
end

%
% Bin description
%
listb = {''};
if ~isempty(ERP)
        nbin  = ERP.nbin; % Total number of bins
        for b=1:nbin
                listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
        end
end
%%%set(handles.popupmenu_bins,'String', listb)
handles.listb      = listb;
handles.indxlistb  = binArray;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Export ERP GUI'])

set(handles.edit_saveas, 'String', filename)
set(handles.edit_bins, 'String', vect2colon(binArray, 'Delimiter', 'off'))
set(handles.popupmenu_tunits,'String',{'seconds';'milliseconds'})
set(handles.popupmenu_tunits,'Value', tunitx)
set(handles.popupmenu_precision,'String', num2str([1:10]'))
set(handles.popupmenu_precision,'Value', prec)
set(handles.checkbox_time,'Value', istime)
set(handles.checkbox_elabels,'Value', islabeled)
set(handles.radiobutton_pr_ec,'Value', prec)

if transpa==0
        set(handles.radiobutton_pr_ec,'Value', 1)
        set(handles.radiobutton_er_pc,'Value', 0)  
else
        set(handles.radiobutton_pr_ec,'Value', 0)
        set(handles.radiobutton_er_pc,'Value', 1)        
end


helpbutton

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

% UIWAIT makes export2textGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = export2textGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);

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
function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_export2text
web 'https://github.com/lucklab/erplab/wiki/Exporting,-Editing,-and-Importing-EVENTLISTS' -browser
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

if isempty(filename)
        msgboxText =  'You must enter a filename!';
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
uiresume(handles.gui_chassis);

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
        
        [px, fname2, ext] = fileparts(fname);
        
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

% % % %--------------------------------------------------------------------------
% % % function popupmenu_bins_Callback(hObject, eventdata, handles)
% % % numbin   = get(hObject, 'Value');
% % % nums = get(handles.edit_bins, 'String');
% % % nums = [nums ' ' num2str(numbin)];
% % % set(handles.edit_bins, 'String', nums);

%--------------------------------------------------------------------------
function pushbutton_browsebin_Callback(hObject, eventdata, handles)
listb = handles.listb;
indxlistb = handles.indxlistb;
indxlistb = indxlistb(indxlistb<=length(listb));
titlename = 'Select Bin(s)';

if get(hObject, 'Value')
        if ~isempty(listb)
                bin = browsechanbinGUI(listb, indxlistb, titlename);
                if ~isempty(bin)
                        set(handles.edit_bins, 'String', vect2colon(bin, 'Delimiter', 'off'));
                        handles.indxlistb = bin;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No bin information was found';
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                return
        end
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
