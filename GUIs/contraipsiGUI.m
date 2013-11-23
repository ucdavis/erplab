%
% Author: Johanna Kreither & Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

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

function varargout = contraipsiGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @contraipsiGUI_OpeningFcn, ...
        'gui_OutputFcn',  @contraipsiGUI_OutputFcn, ...
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
function contraipsiGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
        chanlocs = varargin{1};
        bindescr = varargin{2};
catch
        chanlocs = [];
        bindescr = [];
end
try
        def = erpworkingmemory('contraipsiGUI');
        leftchanArray  = def{1};
        rightchanArray = def{2};
        leftbinArray   = def{3};
        rightbinArray  = def{4};
        shortbinlabels = def{5};
        middlechanArray= def{6};
catch
        def = {[11 13 15] [10 12 14] [1 3] [2 4] {'Condition_1' 'Condition_2'} []};
        leftchanArray  = def{1};
        rightchanArray = def{2};
        leftbinArray   = def{3};
        rightbinArray  = def{4};
        shortbinlabels = def{5};
        middlechanArray = [];
end

ERPX = buildERPstruct([]);
ERPX.chanlocs = chanlocs;
ERPX.bindescr = bindescr;
nchan = length(chanlocs);
ERPX.nchan = nchan;
nbin  = length(bindescr);

listch = {[]};

if isempty(chanlocs)
        set(handles.pushbutton_autochan, 'Enable', 'off')
else
        for ch =1:nchan
                listch{ch} = [num2str(ch) ' = ' chanlocs(ch).labels ];
        end
end

%
% Prepare List of current Bins
%
listb = {[]};

for b=1:nbin
        listb{b} = ['BIN' num2str(b) ' = ' bindescr{b} ];
end

%
% Middle channels
%
if isempty(middlechanArray)
        set(handles.checkbox_include_midchans, 'Value', 0)
        set(handles.edit_middlechans, 'Enable', 'off')
        set(handles.pushbutton_autochanmid, 'Enable', 'off')
        set(handles.pushbutton_browse_middlechans, 'Enable', 'off')
else        
        leftchanArray  = leftchanArray(~ismember_bc2(leftchanArray, middlechanArray));
        rightchanArray = rightchanArray(~ismember_bc2(rightchanArray, middlechanArray));
        set(handles.checkbox_include_midchans, 'Value', 1)
        set(handles.edit_middlechans, 'String', num2str(middlechanArray))
end
handles.leftchanArray   = leftchanArray;
handles.rightchanArray  = rightchanArray;
handles.leftbinArray    = leftbinArray;
handles.rightbinArray   = rightbinArray;
handles.middlechanArray = middlechanArray;
handles.shortbinlabels  = shortbinlabels;
handles.listch = listch;
handles.listb = listb;

version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   Contra Ipsi GUI'])
handles = painterplab(handles);
handles.ERPX = ERPX;
thval = 15;

if length(leftchanArray)>thval || length(rightchanArray)>thval
        Lchstr = vect2colon(leftchanArray, 'Delimiter', 'off');
        Rchstr = vect2colon(rightchanArray, 'Delimiter', 'off');
else
        Lchstr = num2str(leftchanArray);
        Rchstr = num2str(rightchanArray);
end
if length(leftbinArray)>thval || length(rightbinArray)>thval
        Lbinstr = vect2colon(leftbinArray, 'Delimiter', 'off');
        Rbinstr = vect2colon(rightbinArray, 'Delimiter', 'off');
else
        Lbinstr = num2str(leftbinArray);
        Rbinstr = num2str(rightbinArray);
end

set(handles.edit_leftchanArray, 'String', Lchstr);
set(handles.edit_rightchanArray, 'String', Rchstr);
set(handles.edit_leftstimbinArray, 'String', Lbinstr);
set(handles.edit_rightstimbinArray, 'String', Rbinstr);
set(handles.edit_binshortlabel, 'String', sprintf('%s ',shortbinlabels{:}));

%
% Set font size
%
handles = setfonterplab(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes contraipsiGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% -----------------------------------------------------------------------
function varargout = contraipsiGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.2)

% -----------------------------------------------------------------------
function edit_leftchanArray_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_leftchanArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function edit_rightchanArray_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_rightchanArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function edit_leftstimbinArray_Callback(hObject, eventdata, handles)
w = str2num(get(hObject,'String'));
y = str2num(get(handles.edit_rightstimbinArray,'String'));
if ~isempty(w) && ~isempty(y) && (length(w)==length(y))
        set(handles.text_blabels, 'String', sprintf('Write %g short labels for describing each couple of bins (Optional)', length(w)))
end

% -----------------------------------------------------------------------
function edit_leftstimbinArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function edit_rightstimbinArray_Callback(hObject, eventdata, handles)
w = str2num(get(hObject,'String'));
y = str2num(get(handles.edit_leftstimbinArray,'String'));
if ~isempty(w) && ~isempty(y) && (length(w)==length(y))
        set(handles.text_blabels, 'String', sprintf('Write %g short labels for describing each couple of bins (Optional)', length(w)))
end
% -----------------------------------------------------------------------
function edit_rightstimbinArray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function pushbutton_browsechan_left_Callback(hObject, eventdata, handles)
listch     = handles.listch;

leftchanArray  = handles.leftchanArray;
% rightchanArray = handles.rightchanArray;
%leftbinArray   = handles.leftbinArray;
%rightbinArray  = handles.rightbinArray;
%shortbinlabels = handles.shortbinlabels;

leftchanArray  = leftchanArray(leftchanArray<=length(listch));
%rightchanArray = rightchanArray(rightchanArray<=length(listch));
%leftbinArray   = leftbinArray(leftbinArray<=length(listch));
%rightbinArray  = rightbinArray(rightbinArray<=length(listch));
%shortbinlabels = shortbinlabels(shortbinlabels<=length(listch));

%indxlistch = handles.indxlistch;
%indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select left-side channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, leftchanArray, titlename);
                if ~isempty(ch)
                        set(handles.edit_leftchanArray, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.leftchanArray = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

% -----------------------------------------------------------------------
function pushbutton_browsechan_right_Callback(hObject, eventdata, handles)
listch     = handles.listch;

%leftchanArray  = handles.leftchanArray;
rightchanArray = handles.rightchanArray;
%leftbinArray   = handles.leftbinArray;
%rightbinArray  = handles.rightbinArray;
%shortbinlabels = handles.shortbinlabels;

%leftchanArray  = leftchanArray(leftchanArray<=length(listch));
rightchanArray = rightchanArray(rightchanArray<=length(listch));
%leftbinArray   = leftbinArray(leftbinArray<=length(listch));;
%rightbinArray  = rightbinArray(rightbinArray<=length(listch));;
%shortbinlabels = shortbinlabels(shortbinlabels<=length(listch));;

%indxlistch = handles.indxlistch;
%indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select right-side channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, rightchanArray, titlename);
                if ~isempty(ch)
                        set(handles.edit_rightchanArray, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.rightchanArray = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

% -----------------------------------------------------------------------
function pushbutton_autochan_Callback(hObject, eventdata, handles)
ERPX = handles.ERPX;
if isempty(ERPX.chanlocs)
        return
end
[LH RH] = splitbrain2(ERPX);

handles.rightchanArray = RH;
handles.leftchanArray  = LH;

set(handles.edit_leftchanArray, 'String', vect2colon(LH, 'Delimiter', 'off'));
set(handles.edit_rightchanArray, 'String', vect2colon(RH, 'Delimiter', 'off'));

% Update handles structure
guidata(hObject, handles);

% -----------------------------------------------------------------------
function pushbutton_browsebin_left_Callback(hObject, eventdata, handles)

listb     = handles.listb;

%leftchanArray  = handles.leftchanArray;
% rightchanArray = handles.rightchanArray;
leftbinArray   = handles.leftbinArray;
%rightbinArray  = handles.rightbinArray;
%shortbinlabels = handles.shortbinlabels;

%leftchanArray  = leftchanArray(leftchanArray<=length(listch));
% rightchanArray = rightchanArray(rightchanArray<=length(listch));
leftbinArray   = leftbinArray(leftbinArray<=length(listb));
%rightbinArray  = rightbinArray(rightbinArray<=length(listch));;
%shortbinlabels = shortbinlabels(shortbinlabels<=length(listch));;

%indxlistch = handles.indxlistch;
%indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select left bin(s)';

if get(hObject, 'Value')
        if ~isempty(listb)
                bn = browsechanbinGUI(listb, leftbinArray, titlename);
                if ~isempty(bn)
                        set(handles.edit_leftstimbinArray, 'String', vect2colon(bn, 'Delimiter', 'off'));
                        handles.leftbinArray = bn;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No bin information was found';
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

% -----------------------------------------------------------------------
function pushbutton_browsebin_right_Callback(hObject, eventdata, handles)
listb     = handles.listb;

%leftchanArray  = handles.leftchanArray;
% rightchanArray = handles.rightchanArray;
% leftbinArray   = handles.leftbinArray;
rightbinArray  = handles.rightbinArray;
%shortbinlabels = handles.shortbinlabels;

%leftchanArray  = leftchanArray(leftchanArray<=length(listch));
% rightchanArray = rightchanArray(rightchanArray<=length(listch));
% leftbinArray   = leftbinArray(leftbinArray<=length(listb));
rightbinArray  = rightbinArray(rightbinArray<=length(listb));
%shortbinlabels = shortbinlabels(shortbinlabels<=length(listch));;

%indxlistch = handles.indxlistch;
%indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select right bin(s)';

if get(hObject, 'Value')
        if ~isempty(listb)
                bn = browsechanbinGUI(listb, rightbinArray, titlename);
                if ~isempty(bn)
                        set(handles.edit_rightstimbinArray, 'String', vect2colon(bn, 'Delimiter', 'off'));
                        handles.rightbinArray = bn;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No bin information was found';
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function pushbutton_ok_Callback(hObject, eventdata, handles)
leftchanArray  = str2num(get(handles.edit_leftchanArray, 'String'));
rightchanArray = str2num(get(handles.edit_rightchanArray, 'String'));
leftbinArray   = str2num(get(handles.edit_leftstimbinArray, 'String'));
rightbinArray  = str2num(get(handles.edit_rightstimbinArray, 'String'));
shortbinlabels = get(handles.edit_binshortlabel, 'String');

if get(handles.checkbox_include_midchans, 'Value')
        middlechanArray = str2num(get(handles.edit_middlechans, 'String'));
else
        middlechanArray = [];
end
if isempty(leftchanArray) || isempty(rightchanArray) || isempty(leftbinArray) || isempty(rightbinArray)
        msgboxText =  'You must fill left and right channels windows!';
        etitle = 'ERPLAB: contraipsiGUI few inputs';
        errorfound(msgboxText, etitle);
        return
end
values = [leftchanArray rightchanArray leftbinArray rightbinArray];
if any(values<1)
        msgboxText =  'Wrong value(s) found.\nUse positive integers, excluding 0';
        etitle = 'ERPLAB: contraipsiGUI invalid inputs';
        errorfound(msgboxText, etitle);
        return
end
if any(mod(values, 1)>0)
        msgboxText =  'Wrong value(s) found.\nUse positive integers, excluding 0';
        etitle = 'ERPLAB: contraipsiGUI invalid inputs';
        errorfound(msgboxText, etitle);
        return
end
if length(leftchanArray)~=length(rightchanArray)
        msgboxText =  'You must specify as many left channels as right ones';
        etitle = 'ERPLAB: contraipsiGUI mismatching inputs';
        errorfound(msgboxText, etitle);
        return
end
if length(leftbinArray)~=length(rightbinArray)
        msgboxText =  'You must specify as many left bins as right ones';
        etitle = 'ERPLAB: contraipsiGUI mismatching inputs';
        errorfound(msgboxText, etitle);
        return
end
if ~isempty(shortbinlabels)
        shortbinlabels = regexp(shortbinlabels, '\w*', 'match');
        if length(shortbinlabels)~=length(leftbinArray)
                msgboxText =  'You must specify as many labels as left-right bin couples you described above';
                etitle = 'ERPLAB: contraipsiGUI mismatching inputs';
                errorfound(msgboxText, etitle);
                return
        end
end

leftchanArray  = [leftchanArray middlechanArray];
rightchanArray = [rightchanArray middlechanArray];

Equbins = BuiltContraIpsiEquations(leftchanArray, rightchanArray, leftbinArray, rightbinArray, shortbinlabels);
handles.output = {Equbins};

def{1} = leftchanArray;
def{2} = rightchanArray;
def{3} = leftbinArray;
def{4} = rightbinArray;
def{5} = shortbinlabels;
def{6} = middlechanArray;
erpworkingmemory('contraipsiGUI', def);

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -----------------------------------------------------------------------
function Equbins = BuiltContraIpsiEquations(leftchanArray, rightchanArray, leftbinArray, rightbinArray, shortbinlabels)
% Equbins{1} = sprintf('Lch = [%s]', num2str(leftchanArray));
% Equbins{2} = sprintf('Rch = [%s]', num2str(rightchanArray));
Equbins{1} = sprintf('Lch = %s', vect2colon(leftchanArray));
Equbins{2} = sprintf('Rch = %s', vect2colon(rightchanArray));
nbin = length(leftbinArray);
m = 1; p = 1;
for k=1:length(leftbinArray)
        if ~isempty(shortbinlabels)
                lb = [shortbinlabels{k} ' '];
        else
                lb ='';
        end
        Equbins{2+m}   = sprintf('nbin%g = 0.5*bin%g@Rch + 0.5*bin%g@Lch label %sContra', m, leftbinArray(k), rightbinArray(k), lb);
        Equbins{2+m+1} = sprintf('nbin%g = 0.5*bin%g@Lch + 0.5*bin%g@Rch label %sIpsi', m+1, leftbinArray(k), rightbinArray(k), lb);
        if k==1
                Equbins{2+p+nbin*2}   = '# For creating contra-minus-ipsi waveforms from the bins above,';
                Equbins{2+p+nbin*2+1} = '# run (only) the formulas described here below in a second call';
                Equbins{2+p+nbin*2+2} = '# of "ERP binoperator"  (remove the # symbol before run them)';
        end
        %Equbins{2+p+nbin*2+3} = sprintf('#nbin%g = bin%g - bin%g label %s Contra-Ipsi', p+nbin*2, m, m+1, lb);
        Equbins{2+p+nbin*2+3} = sprintf('#bin%g = bin%g - bin%g label %s Contra-Ipsi', p+2*nbin, m, m+1, lb);
        m = m+2;
        p = p+1;
end

Equbins = [ {'prepareContraIpsi'} Equbins];


% -----------------------------------------------------------------------
function edit_binshortlabel_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_binshortlabel_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
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

% -----------------------------------------------------------------------
function edit_middlechans_Callback(hObject, eventdata, handles)

% -----------------------------------------------------------------------
function edit_middlechans_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -----------------------------------------------------------------------
function checkbox_include_midchans_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        %set(handles.checkbox_include_midchans, 'Value', 0)
        set(handles.edit_middlechans, 'Enable', 'on')
        set(handles.pushbutton_autochanmid, 'Enable', 'on')
        set(handles.pushbutton_browse_middlechans, 'Enable', 'on')
else
        set(handles.edit_middlechans, 'Enable', 'off')
        set(handles.pushbutton_autochanmid, 'Enable', 'off')
        set(handles.pushbutton_browse_middlechans, 'Enable', 'off')
end

% -----------------------------------------------------------------------
function pushbutton_browse_middlechans_Callback(hObject, eventdata, handles)
listch     = handles.listch;

%leftchanArray  = handles.leftchanArray;
middlechanArray = handles.middlechanArray;
%leftbinArray   = handles.leftbinArray;
%rightbinArray  = handles.rightbinArray;
%shortbinlabels = handles.shortbinlabels;

%leftchanArray  = leftchanArray(leftchanArray<=length(listch));
middlechanArray = middlechanArray(middlechanArray<=length(listch));
%leftbinArray   = leftbinArray(leftbinArray<=length(listch));;
%rightbinArray  = rightbinArray(rightbinArray<=length(listch));;
%shortbinlabels = shortbinlabels(shortbinlabels<=length(listch));;

%indxlistch = handles.indxlistch;
%indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select middle channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, middlechanArray, titlename);
                if ~isempty(ch)
                        set(handles.edit_middlechans, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.middlechanArray = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

% % -----------------------------------------------------------------------
% function pushbutton_autochan_Callback(hObject, eventdata, handles)
% ERPX = handles.ERPX;
% [LH RH] = splitbrain2(ERPX);
%
% handles.rightchanArray = RH;
% handles.leftchanArray  = LH;
%
% set(handles.edit_leftchanArray, 'String', vect2colon(LH, 'Delimiter', 'off'));
% set(handles.edit_rightchanArray, 'String', vect2colon(RH, 'Delimiter', 'off'));
%
% % Update handles structure
% guidata(hObject, handles);

% -----------------------------------------------------------------------
function pushbutton_autochanmid_Callback(hObject, eventdata, handles)
ERPX = handles.ERPX;
if isempty(ERPX.chanlocs)
        return
end
[a b ZH] = splitbrain2(ERPX);
handles.middlechanArray = ZH;
set(handles.edit_middlechans, 'String', num2str(ZH));

% Update handles structure
guidata(hObject, handles);
