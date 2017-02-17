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

function varargout = geterpvaluesGUI2(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @geterpvaluesGUI2_OpeningFcn, ...
        'gui_OutputFcn',  @geterpvaluesGUI2_OutputFcn, ...
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
function geterpvaluesGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for geterpvaluesGUI2
handles.output     = [];
handles.indxline   = 1;
handles.listname   = [];
handles.listb      = '';
handles.indxlistb  = [];
handles.listch     = '';
handles.indxlistch = [];
handles.owfp       = 0;  % over write file permission. 1:allowed; 0:do not overwrite w/o asking.
handles.rise       = 1;
try
        cerpi = varargin{3};
catch
        cerpi = 0;
end

try
        ALLERP = varargin{1};
        if isstruct(ALLERP)
                handles.xmin  = ALLERP(cerpi).xmin;
                handles.xmax  = ALLERP(cerpi).xmax;
                handles.srate = ALLERP(cerpi).srate;
                handles.nsets = length(ALLERP);
        else
                handles.xmin  = [];
                handles.xmax  = [];
                handles.srate = [];
                handles.nsets = [];
        end
        datatype = checkdatatype(ALLERP(cerpi));
catch
        ALLERP = [];
        handles.xmin  = [];
        handles.xmax  = [];
        handles.srate = [];
        handles.nsets = [];
        datatype = 'ERP';
end
handles.datatype = datatype;
if strcmpi(datatype, 'ERP')
        kktime = 1000;
else %FFT
        kktime = 1;
        handles.srate = ALLERP(1).pnts/ALLERP(cerpi).xmax;
end
handles.kktime     = kktime;
try
        def = varargin{2};
        handles.def = def;
catch
        def = {1, 1, '', 0, 1, 1, 'instabl', 1, 3, 'pre', 0, 1, 5, 0, 0.5, NaN, 0, 1, '', 0, 1};
        
        %         def =
        %         optioni    = def{1}; %1 means from hard drive, 0 means from erpsets menu; 2 means current erpset (at erpset menu)
        %         erpset     = def{2}; % indices of erpset or filename of list of erpsets
        %         fname      = def{3};
        %         latency    = def{4};
        %         binArray   = def{5};
        %         chanArray  = def{6};
        %         op         = def{7}; % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
        %         coi        = def{8};
        %         dig        = def{9};
        %         blc        = def{10};
        %         binlabop   = def{11}; % 0: bin# as bin label for table, 1 bin label
        %         polpeak    = def{12}; % local peak polarity
        %         sampeak    = def{13}; % number of samples (one-side) for local peak detection criteria
        %         locpeakrep = def{14}; % 1 abs peak , 0 Nan
        %         frac       = def{15};
        %         fracmearep = def{16}; % def{19}; NaN
        %         send2ws    = def{17}; % 1 send to ws, 0 dont do
        %         foutput    = def{18}; % 1 = 1 measurement per line; 0 = 1 erpset per line
        %         mlabel     = def{19};
        %         inclate    = def{20};
        %         intfactor  = def{21};
        %
        %         if isempty(sampeak)
        %                 sampeak = 3;
        %         end
        handles.def = def;
end

handles.binmem    = def{5};
handles.chanmem   = def{6};
handles.ALLERP    = ALLERP;
handles.b2filter  = 0;
handles.cerpi     = cerpi;
handles.frac      = [];
handles.intfactor = [];

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

setall(hObject, eventdata, handles)

% help
helpbutton

% viewer
viewerbutton

%
% Set Measurement menu
%
set(handles.listbox_erpnames, 'Value',1)
set(handles.popupmenu_measurement, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_pol_amp, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_samp_amp, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_locpeakreplacement, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_fracreplacement, 'Backgroundcolor',[1 1 0.8])
set(handles.popupmenu_precision, 'Backgroundcolor',[1 1 0.8])
set(handles.text_fraca,'String', {''});
set(handles.text_fa3,'String',{''});
drawnow

% UIWAIT makes geterpvaluesGUI2 wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = geterpvaluesGUI2_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function menupeakoff(hObject, eventdata, handles)
set(handles.popupmenu_pol_amp, 'Enable', 'off')
set(handles.text_fa1, 'Enable', 'off')
set(handles.popupmenu_samp_amp, 'Enable', 'off')
set(handles.text_samp, 'Enable', 'off')
set(handles.text12, 'Enable', 'off')
set(handles.popupmenu_locpeakreplacement, 'Enable', 'off')
set(handles.text_fa1, 'Enable', 'off')
set(handles.text_fa2, 'Enable', 'off')
set(handles.text_fa3, 'Enable', 'off')
set(handles.text_fa4, 'Enable', 'off')

%--------------------------------------------------------------------------
function menupeakon(hObject, eventdata, handles)
set(handles.popupmenu_pol_amp, 'Enable', 'on')
set(handles.text_fa1, 'Enable', 'on')
set(handles.popupmenu_samp_amp, 'Enable', 'on')
set(handles.text_samp, 'Enable', 'on')
set(handles.text12, 'Enable', 'on')
set(handles.popupmenu_locpeakreplacement, 'Enable', 'on')
set(handles.text_fa1, 'Enable', 'on')
set(handles.text_fa2, 'Enable', 'on')



%--------------------------------------------------------------------------
function menufareaoff(hObject, eventdata, handles)
set(handles.text_fraca,'Enable','off')
set(handles.popupmenu_fraca,'String', {''})
set(handles.popupmenu_fraca,'Enable','off')
set(handles.text_punit,'Enable','off')
set(handles.popupmenu_fracreplacement,'Enable','off')
set(handles.text19, 'Enable', 'off')
set(handles.text_fa3, 'Enable', 'off')
set(handles.text_fa3,'String',{''});
set(handles.text_fa4, 'Enable', 'off')
set(handles.popupmenu_fraca, 'Enable', 'off')
set(handles.popupmenu_rise, 'Enable', 'off')
set(handles.text_fraca,'String', {''});

%--------------------------------------------------------------------------
function menufareaon(hObject, eventdata, handles)
set(handles.text_fraca,'Enable','on')
set(handles.text_punit,'Enable','on')
set(handles.popupmenu_fraca,'Enable','on')
set(handles.popupmenu_fracreplacement,'Enable','on')
set(handles.text19, 'Enable', 'on')
set(handles.text_fa3, 'Enable', 'on')
set(handles.text_fa3,'String',{'Measure'});
set(handles.text_fa4, 'Enable', 'on')
set(handles.popupmenu_fraca, 'Enable', 'on')
set(handles.popupmenu_rise, 'Enable', 'on')

fracarray = 0:100;
set(handles.popupmenu_fraca,'String', cellstr(num2str(fracarray')))
frac = handles.frac;
if isempty(frac)
        frac = 0.50;
end
fracpos = round(frac*100)+1;
set(handles.popupmenu_fraca,'Value', fracpos)

set(handles.text19, 'Enable', 'on')

%--------------------------------------------------------------------------
function edit_fname_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_browse_Callback(hObject, eventdata, handles)

%
% Save OUTPUT file
%
prename = get(handles.edit_fname,'String');

% if ispc
%         [filename, filepath, filterindex] = uiputfile({'*.xls';'*.txt';'*.dat';'*.*'}, 'Save Output file as', prename);
% else
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'}, 'Save Output file as', prename);
% end
if isequal(filename,0)
        disp('User selected Cancel')
        handles.owfp = 0;  % over write file permission
        guidata(hObject, handles);
        return
else
        [px, fname, ext] = fileparts(filename);
        
        if ispc
                if filterindex==2 || filterindex==4
                        ext2   = '.txt';
                elseif filterindex==3
                        ext2   = '.dat';
                else
                        ext2   = '.xls';
                end
        else
                if filterindex==1 || filterindex==3
                        ext2   = '.txt';
                else
                        ext2   = '.dat';
                end
        end
        
        fname = [ fname ext2];
        fullname = fullfile(filepath, fname);
        set(handles.edit_fname,'String', fullname);
        disp(['To Save Output file, user selected ', fullname])
        handle.fname     = fname;
        handle.pathname  = filepath;
        handles.owfp     = 1;  % over write file permission
        set(handles.edit_fname,'String', fullfile(filepath, fname));
        
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function edit_latency_Callback(hObject, eventdata, handles)
lat = str2num(get(handles.edit_latency, 'String'));
if ~isempty(lat)
        lat = unique_bc2(lat);
        set(handles.edit_latency, 'String', vect2colon(lat, 'Delimiter', 'off'));
end

%--------------------------------------------------------------------------
function edit_latency_CreateFcn(hObject, eventdata, handles)
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
% doc pop_geterpvalues
web https://github.com/lucklab/erplab/wiki/ERP-Measurement-Tool -browser

%--------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)
datatype = handles.datatype;
kktime = handles.kktime;
if kktime==1 % sec or Hz
        TimeOp = 0;
else % ms
        TimeOp = 1;
end

binArraystr  = get(handles.edit_bins, 'String');
chanArraystr = get(handles.edit_channels, 'String');
latestr      = get(handles.edit_latency, 'String');
listb        = handles.listb;
listch       = handles.listch;
xmin  = handles.xmin;
xmax  = handles.xmax;
fname = strtrim(get(handles.edit_fname, 'String'));
srate = handles.srate;

if get(handles.radiobutton_erpset, 'Value')
        erpset   = str2num(char(get(handles.edit_erpset, 'String')));
        [chkerp, xxx, msgboxText] = checkERPs(hObject, eventdata, handles);
        
        if chkerp>0
                title = 'ERPLAB: geterpvaluesGUI()';
                errorfound(sprintf(msgboxText), title);
                return % problem was found
        end
        foption = 0; %from erpsets
elseif get(handles.radiobutton_currenterpset, 'Value')
        foption = 2; %from current erpsets
        erpset  = handles.cerpi;
else
        erpset = get(handles.listbox_erpnames, 'String');
        nline  = length(erpset);
        
        if nline==1
                msgboxText =  'You have to specify at least one erpset!';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(binArraystr) && max(str2num(binArraystr))>length(listb)
                msgboxText = 'You have specified unexisting bin(s)';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(chanArraystr) && max(str2num(chanArraystr))>length(listch)
                msgboxText = 'You have specified unexisting channel(s)';
                title = 'ERPLAB: geterpvaluesGUI() -> missing input';
                errorfound(msgboxText, title);
                return
        end
        listname = handles.listname;
        
        if isempty(listname) && nline>1
                BackERPLABcolor = [1 0.9 0.3];    % yellow
                question = ['You have not yet saved your list.\n'...
                        'What would you like to do?'];
                title       = 'Save List of ERPsets';
                oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button      = questdlg(sprintf(question), title,'Save and Continue','Save As', 'Cancel','Save and Continue');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                
                if strcmpi(button,'Save As')
                        fullname = savelist(hObject, eventdata, handles);
                        listname = fullname;
                        set(handles.edit_filelist,'String', listname);
                        handles.listname = listname;
                        
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                elseif strcmpi(button,'Save and Continue')
                        fulltext = char(get(handles.listbox_erpnames,'String'));
                        listname = char(strtrim(get(handles.edit_filelist,'String')));
                        
                        if isempty(listname)
                                fullname = savelist(hObject, eventdata, handles);
                                listname = fullname;
                                set(handles.edit_filelist,'String', listname);
                        else
                                fid_list = fopen( listname , 'w');
                                for i=1:size(fulltext,1)-1
                                        fprintf(fid_list,'%s\n', fulltext(i,:));
                                end
                                fclose(fid_list);
                        end
                elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                        handles.output   = [];
                        handles.listname = [];
                        
                        % Update handles structure
                        guidata(hObject, handles);
                        return
                end
        end
        erpset = listname;
        foption = 1; % from list
end

%
% Viewer
%
viewmea = get(handles.togglebutton_viewer, 'Value'); % 0:no; 1:yes

%
% Send to workspace
%
send2ws = get(handles.checkbox_send2ws, 'Value'); % 0:no; 1:yes
owfp    = handles.owfp;  % over write file permission
appendfile = 0;

if viewmea
        %fname = 'no_save.viewer';
else
        if isempty(fname) && ~send2ws
                msgboxText =  'You have not yet written a file name for your outputs!';
                title = 'ERPLAB: geterpvaluesGUI() -> no file name';
                errorfound(msgboxText, title);
                return
        elseif isempty(fname) && send2ws
                fname = 'no_save.no_save';
        else
                [pu, fnameu, extu] = fileparts(fname);
                if strcmp(extu,'')
                        extu   = '.txt';
                end
                
                fname = fullfile(pu,[fnameu extu]);
                
                if exist(fname, 'file')~=0 && owfp==0
                        question = [fname ' already exists!\n'...
                                'What would you like to do?'];
                        title       = 'ERPLAB: Overwriting Confirmation';
                        BackERPLABcolor = [1 0.9 0.3];    % yellow
                        oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
                        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                        button      = questdlg(sprintf(question), title,'Append','Overwrite', 'Cancel','Append');
                        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                        
                        if strcmpi(button, 'Append')
                                appendfile = 1;
                        elseif strcmpi(button, 'Overwrite')
                                appendfile = 0;
                        else
                                return
                        end
                end
        end
end
if ~strcmp(chanArraystr, '') && ~isempty(chanArraystr) && ~strcmp(latestr, '') && ~isempty(latestr) && ~strcmp(binArraystr, '') && ~isempty(binArraystr)
        binArray   = str2num(binArraystr);
        chanArray  = str2num(chanArraystr);
        late       = str2num(latestr);
        nlate      = length(late);
        
        if nlate==2
                if late(1)<xmin*kktime && time2sample(TimeOp, abs(late(1)-xmin*kktime), srate)>2
                        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                msgboxText =  'The onset of your measurement window cannot be more than 2 samples earlier than the FFT window (%.1f Hz)\n';
                        else
                                msgboxText =  'The onset of your measurement window cannot be more than 2 samples earlier than the ERP window (%.1f ms)\n';
                        end
                        title = 'ERPLAB: measurement window';
                        errorfound(sprintf(msgboxText, xmin*kktime), title);
                        return
                end
                if late(2)>xmax*kktime && time2sample(TimeOp, abs(late(2)-xmax*kktime), srate)>2
                        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                msgboxText =  'The offset of your measurement window cannot be more than 2 samples later than the FFT window (%.1f Hz)\n';
                        else
                                msgboxText =  'The offset of your measurement window cannot be more than 2 samples later than the ERP window (%.1f ms)\n';
                        end
                        title = 'ERPLAB: measurement window';
                        errorfound(sprintf(msgboxText,xmax*kktime), title);
                        return
                end
                if late(1)>=late(2)
                        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                msgboxText =  ['For the measurement window, lower frequency limit must be on the left.\n'...
                                        'Additionally, lower frequency limit must be not less than 1 Hz(recommended)\n'];
                        else
                                msgboxText =  ['For the measurement window, lower time limit must be on the left.\n'...
                                        'Additionally, lower latency limit must be at least 1/fs seconds\n'...
                                        'lesser than the higher one.'];
                        end
                        title = 'ERPLAB: measurement window';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        elseif nlate==1
                if late<xmin*kktime || late>xmax*kktime
                        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                msgboxText =  'For measuring, frequency value cannot be lower than 1 (recommended) nor greater than the Nyquist frequency (fs/2).';
                        else
                                msgboxText =  'For measuring, latency value cannot be lower than pre-stimulus onset nor greater than the ERP window.';
                        end
                        title = 'ERPLAB: measurement window';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        end
        
        polpeak    = [];
        sampeak    = [];
        coi        = 0; % ignore overlapped components
        locpeakrep = 0;
        frac       = [];
        fracmearep = 0;
        measure_option = get(handles.popupmenu_measurement, 'Value');
        areatype       = get(handles.popupmenu_areatype,'Value');  % 1=total ; 2=pos; 3=neg
        
        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                msgboxText4peak = ['The requested measurement window is invalid given the number of points specified for finding a local peak '...
                        'and the epoch length of the FFT waveform.\n\n You have specified a local peak over ±%g points, which means that '...
                        'there must be %g sample points between the onset of your measurement window and the onset of the waveform, '...
                        'and/or %g sample points between the end of your measurement window and the end of the waveform.\n\n'...
                        'Because the waveform starts at %.1f Hz and ends at %.1f Hz, your measurement window cannot go beyond [%.1f  %.1f] Hz (unless you reduce '...
                        'the number of points required to define the local peak).'];
        else
                msgboxText4peak = ['The requested measurement window is invalid given the number of points specified for finding a local peak '...
                        'and the epoch length of the ERP waveform.\n\n You have specified a local peak over ±%g points, which means that '...
                        'there must be %g sample points between the onset of your measurement window and the onset of the waveform, '...
                        'and/or %g sample points between the end of your measurement window and the end of the waveform.\n\n'...
                        'Because the waveform starts at %.1f ms and ends at %.1f ms, your measurement window cannot go beyond [%.1f  %.1f] ms (unless you reduce '...
                        'the number of points required to define the local peak).'];
        end
        
        switch measure_option
                case 1  % instabl
                        if nlate~=1
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define only one frequency';
                                else
                                        msgboxText =  'You must define only one latency';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        moption = 'instabl';
                        fprintf('\nInstantaneous amplitude measurement in progress...\n');
                case 2  % meanbl
                        if nlate~=2
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define two frequencies';
                                else
                                        msgboxText =  'You must define two latencies';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        moption = 'meanbl';
                        fprintf('\nMean amplitude measurement in progress...\n');
                case 3  % peakampbl
                        if nlate~=2
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define two frequencies';
                                else
                                        msgboxText =  'You must define two latencies';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        moption = 'peakampbl';
                        polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
                        sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
                        locpeakrep = 2-get(handles.popupmenu_locpeakreplacement,'Value');
                        
                        cc1    = late(1)-sample2time(TimeOp, sampeak, srate) < xmin*kktime;
                        ccdiff = abs((late(1)-sample2time(TimeOp, sampeak, srate)) - xmin*kktime);
                        cc2    = time2sample(TimeOp, ccdiff, srate)>2;
                        cc3    = late(2)+sample2time(TimeOp, sampeak, srate)>xmax*kktime;
                        ccdiff = abs((late(2)+sample2time(TimeOp, sampeak, srate)) - xmax*kktime);
                        cc4    = time2sample(TimeOp, ccdiff, srate)>2;
                        
                        if (cc1 && cc2) || (cc3 && cc4)
                                msgboxText =  msgboxText4peak;
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText,sampeak, sampeak, sampeak, xmin*kktime, xmax*kktime, xmin*kktime+sample2time(TimeOp, sampeak,srate), xmax*kktime-sample2time(TimeOp, sampeak,srate)), title);
                                return
                        end
                        fprintf('\nLocal peak measurement in progress...\n');
                case 4  % peaklatbl
                        if nlate~=2
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define two frequencies';
                                else
                                        msgboxText =  'You must define two latencies';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        moption = 'peaklatbl';
                        polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
                        sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
                        locpeakrep = 2-get(handles.popupmenu_locpeakreplacement,'Value');
                        
                        cc1    = late(1)-sample2time(TimeOp, sampeak, srate) < xmin*kktime;
                        ccdiff = abs((late(1)-sample2time(TimeOp, sampeak, srate)) - xmin*kktime);
                        cc2    = time2sample(TimeOp, ccdiff, srate)>2;
                        cc3    = late(2)+sample2time(TimeOp, sampeak, srate)>xmax*kktime;
                        ccdiff = abs((late(2)+sample2time(TimeOp, sampeak, srate)) - xmax*kktime);
                        cc4    = time2sample(TimeOp, ccdiff, srate)>2;
                        
                        if (cc1 && cc2) || (cc3 && cc4)
                                msgboxText =  msgboxText4peak;
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText,sampeak, sampeak, sampeak, xmin*kktime, xmax*kktime, xmin*kktime+sample2time(TimeOp, sampeak,srate), xmax*kktime-sample2time(TimeOp, sampeak,srate)), kktime);
                                return
                        end
                        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                fprintf('\nLocal peak frequency measurement in progress...\n');
                        else
                                fprintf('\nLocal peak latency measurement in progress...\n');
                        end
                case 5  % fpeaklat
                        if nlate~=2
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define two frequencies';
                                else
                                        msgboxText =  'You must define two latencies';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        set(handles.text_fraca,'String', 'Fractional Peak')
                        moption = 'fpeaklat';
                        frac    = (get(handles.popupmenu_fraca,'Value') - 1)/100; % 0 to 1
                        polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
                        sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
                        locpeakrep = 2-get(handles.popupmenu_locpeakreplacement,'Value');
                        fracmearep = 2-get(handles.popupmenu_fracreplacement,'Value');
                        
                        cc1    = late(1)-sample2time(TimeOp, sampeak, srate) < xmin*kktime;
                        ccdiff = abs((late(1)-sample2time(TimeOp, sampeak, srate)) - xmin*kktime);
                        cc2    = time2sample(TimeOp, ccdiff, srate)>2;
                        cc3    = late(2)+sample2time(TimeOp, sampeak, srate)>xmax*kktime;
                        ccdiff = abs((late(2)+sample2time(TimeOp, sampeak, srate)) - xmax*kktime);
                        cc4    = time2sample(TimeOp, ccdiff, srate)>2;
                        
                        if (cc1 && cc2) || (cc3 && cc4)
                                msgboxText =  msgboxText4peak;
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText,sampeak, sampeak, sampeak, xmin*kktime, xmax*kktime, xmin*kktime+sample2time(TimeOp, sampeak,srate), xmax*kktime-sample2time(TimeOp, sampeak,srate)), title);
                                return
                        end
                        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                fprintf('\nFractional Peak Frequency measurement in progress...\n');
                        else
                                fprintf('\nFractional Peak Latency measurement in progress...\n');
                        end
                case 6  % inte/area value (fixed latencies)
                        if nlate~=2
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define two frequencies';
                                else
                                        msgboxText =  'You must define two latencies';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        switch areatype
                                case 1
                                        moption = 'areat';
                                        fprintf('\nTotal area measurement in progress...\n');
                                case 2
                                        moption = 'ninteg';
                                        fprintf('\nNumerical integration in progress...\n');
                                case 3
                                        moption = 'areap';
                                        fprintf('\nPositive area measurement in progress...\n');
                                case 4
                                        moption = 'arean';
                                        fprintf('\nNegative area measurement in progress...\n');
                        end
                        
                case 7   % inte/area value (auto latencies)                        
                        if ~strcmpi(datatype, 'ERP')
                                msgboxText = 'Sorry. This type of measurement is not allowed for Power Spectrum data';
                                title = 'ERPLAB: geterpvaluesGUI() -> invalid input';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        if nlate~=1
                                %if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                %        msgboxText =  'You must define only one frequency';
                                %else
                                        msgboxText =  'You must define only one latency';
                                %end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        switch areatype
                                case 1
                                        moption = 'areazt';
                                        fprintf('\nTotal area measurement in progress...\n');
                                case 2
                                        moption = 'nintegz';
                                        fprintf('\nNumerical integration (automatic limits) in progress...\n');
                                case 3
                                        moption = 'areazp';
                                        fprintf('\nPositive area measurement (automatic limits) in progress...\n');
                                case 4
                                        moption = 'areazn';
                                        fprintf('\nNegative area measurement (automatic limits) in progress...\n');
                        end
                        
                case 8   % fractional inte/area latency
                        if nlate~=2
                                if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
                                        msgboxText =  'You must define two frequencies';
                                else
                                        msgboxText =  'You must define two latencies';
                                end
                                title = 'ERPLAB: measurement window';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        
                        set(handles.text_fraca,'String', 'Fractional Area')
                        frac = (get(handles.popupmenu_fraca,'Value') - 1)/100; % 0 to 1
                        if strcmpi(datatype, 'ERP')
                                meawordx = 'Latency';
                        else
                                meawordx = 'Frequency';
                        end
                        switch areatype
                                case 1
                                        moption = 'fareatlat';
                                        fprintf('\nFractional Total Area %s measurement in progress...\n', meawordx);
                                case 2
                                        moption = 'fninteglat';
                                        fprintf('\nFractional Total Area %s measurement in progress...\n', meawordx);
                                case 3
                                        moption = 'fareaplat';
                                        fprintf('\nFractional Positive Area %s measurement in progress...\n', meawordx);
                                        
                                case 4
                                        moption = 'fareanlat';
                                        fprintf('\nFractional Negative Area %s measurement in progress...\n', meawordx);
                                otherwise
                                        error('wrong area type.')
                        end
                        fracmearep = 1+ (-1)^(get(handles.popupmenu_fracreplacement,'Value')); % when 1 means 0, when 2 means 2
        end
        
        %
        % Baseline range
        %
        blrnames = {'none','pre','post','all'};
        indxblr  = get(handles.popupmenu_baseliner, 'Value');
        
        if indxblr<5
                blc = blrnames{indxblr};
        else
                blcnumx = str2num(get(handles.edit_custombr,'String'));
                
                if isempty(blcnumx) %char
                        msgboxText = [ 'Invalid Baseline range!\n'...
                                'Please enter a numeric range'];
                        title = 'ERPLAB: geterpvaluesGUI() -> invalid input';
                        errorfound(sprintf(msgboxText), title);
                        return
                else %num
                        if length(blcnumx)~=2
                                msgboxText = [ 'Invalid Baseline range!\n'...
                                        'Please enter two numeric values'];
                                title = 'ERPLAB: geterpvaluesGUI() -> invalid input';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        if blcnumx(1)>blcnumx(2)
                                msgboxText = [ 'Invalid Baseline range!\n'...
                                        'Please enter two finite numeric values v1 and v2, where v1<v2.'];
                                title = 'ERPLAB: geterpvaluesGUI() -> invalid input';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        if nnz(isnan(blcnumx))>0 || nnz(isinf(blcnumx))>0
                                msgboxText = [ 'Invalid Baseline range!\n'...
                                        'Please enter two numeric values v1 and v2, where v1<v2.'];
                                title = 'ERPLAB: geterpvaluesGUI() -> invalid input';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        blcnum = blcnumx/kktime;               % from msec to secs  03-28-2009
                        
                        %
                        % Check & fix baseline range
                        %
                        if blcnum(1)<xmin
                                blcnum(1) = xmin;
                        end
                        if blcnum(2)>xmax
                                blcnum(2) = xmax;
                        end
                        blc = blcnum*kktime;  % sec to msec
                end
        end
        
        %
        % Format output
        %
        foutput = get(handles.popupmenu_formatout, 'Value') - 1;
        
        %
        % Measure's label
        %
        mlabel = get(handles.edit_label_mea,'String');
        mlabel = strtrim(mlabel);
        mlabel = strrep(mlabel, ' ', '_');
        dig    = get(handles.popupmenu_precision, 'Value');
        binlabop  = get(handles.checkbox_binlabel,'Value'); % bin label option for table
        inclate   = get(handles.checkbox_include_used_latencies, 'Value');
        intfactor = get(handles.popupmenu_interpofactor, 'Value');
        
        peakonset = get(handles.popupmenu_rise, 'Value');  % axs - get onset from menu value
        
        %
        % Output
        %
        outstr = {foption, erpset, fname, late, binArray, chanArray, moption,...
                coi, dig, blc, binlabop, polpeak, sampeak, locpeakrep, frac, fracmearep,...
                send2ws, appendfile, foutput, mlabel, inclate, intfactor, viewmea, peakonset};
        handles.output = outstr;
        
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        msgboxText =  'Please fill-up required fields';
        title = 'ERPLAB: geterpvaluesGUI() -> missing information';
        errorfound(msgboxText, title);
        return
end

%--------------------------------------------------------------------------
function edit_channels_Callback(hObject, eventdata, handles)
channnums =  str2num(get(handles.edit_channels,'String'));
if ~isempty(channnums)
        channnums  = unique_bc2(channnums);
        listch     = handles.listch;
        indxlistch = channnums;
        indxlistch = indxlistch(indxlistch<=length(listch));
        handles.indxlistch = indxlistch;
        
        % Update handles structure
        guidata(hObject, handles);
        set(handles.edit_channels, 'String', vect2colon(channnums, 'Delimiter', 'off'));
end

%--------------------------------------------------------------------------
function edit_channels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_channels_Callback(hObject, eventdata, handles)
numch = get(hObject, 'Value');
nums  = get(handles.edit_channels, 'String');
nums  = [nums ' ' num2str(numch)];
set(handles.edit_channels, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_channels_CreateFcn(hObject, eventdata, handles)

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
function listbox_erpnames_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function listbox_erpnames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_adderpset_Callback(hObject, eventdata, handles)
[erpfname, erppathname] = uigetfile({  '*.erp','ERPLAB-files (*.erp)'; ...
        '*.mat','Matlab (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited file', ...
        'MultiSelect', 'on');

if isequal(erpfname,0)
        disp('User selected Cancel')
        return
else
        try
                %
                % test current directory
                %
                changecd(erppathname)
                
                if ~iscell(erpfname)
                        erpfname = {erpfname};
                end
                
                nerpn = length(erpfname);
                
                for i=1:nerpn
                        newline  = fullfile(erppathname, erpfname{i});
                        currline = get(handles.listbox_erpnames, 'Value');
                        fulltext = get(handles.listbox_erpnames, 'String');
                        
                        indxline = length(fulltext);
                        
                        if i==1 && length(fulltext)-1==0  % put this one on the list
                                ERP1 = load(newline, '-mat');
                                ERP  = ERP1.ERP;
                                
                                if ~iserpstruct(ERP)
                                        error('')
                                end
                                handles.srate = ERP.srate;
                                
                                %
                                % Prepare List of current Channels and bins
                                %
                                handles = preparelists(hObject, eventdata, handles, ERP);
                        end
                        if currline==indxline
                                % extra line forward
                                fulltext  = cat(1, fulltext, {'new erpset'});
                                set(handles.listbox_erpnames, 'Value', currline+1)
                        else
                                set(handles.listbox_erpnames, 'Value', currline)
                                resto = fulltext(currline:indxline);
                                fulltext  = cat(1, fulltext, {'new erpset'});
                                set(handles.listbox_erpnames, 'Value', currline+1)
                                [fulltext{currline+1:indxline+1}] = resto{:};
                        end
                        fulltext{currline} = newline;
                        set(handles.listbox_erpnames, 'String', fulltext)
                end
                
                handles.listname = [];
                indxline = length(fulltext);
                handles.indxline = indxline;
                handles.fulltext = fulltext;
                set(handles.button_savelistas, 'Enable','on')
                set(handles.edit_filelist,'String','');
                
                % Update handles structure
                guidata(hObject, handles);
        catch
                set(handles.listbox_erpnames, 'String', '');
                msgboxText =  'A file you are attempting to load is not an ERPset!';
                title = 'ERPLAB: geterpvaluesGUI2 inputs';
                errorfound(msgboxText, title);
                handles.listname = [];
                set(handles.button_savelist, 'Enable','off')
                
                % Update handles structure
                guidata(hObject, handles);
        end
end

%--------------------------------------------------------------------------
function button_delerpset_Callback(hObject, eventdata, handles)
fulltext = get(handles.listbox_erpnames, 'String');
indxline = length(fulltext);
fulltext = char(fulltext); % string matrix
currline = get(handles.listbox_erpnames, 'Value');

if currline>=1 && currline<indxline
        fulltext(currline,:) = [];
        fulltext = cellstr(fulltext); % cell string
        if length(fulltext)>1         % put this one first on the list
                newline = fulltext{1};
                ERP1 = load(newline, '-mat');
                ERP = ERP1.ERP;
                
                %
                % Prepare List of current Channels and bins
                %
                handles = preparelists(hObject, eventdata, handles, ERP);
        else
                handles = preparelists(hObject, eventdata, handles, []);
        end
        
        set(handles.listbox_erpnames, 'String', fulltext);
        listbox_erpnames_Callback(hObject, eventdata, handles)
        handles.fulltext = fulltext;
        indxline = length(fulltext);
        handles.listname = [];
        set(handles.edit_filelist,'String','');
        
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.button_savelistas, 'Enable','off')
end

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)
binnums =  str2num(get(handles.edit_bins,'String'));
if ~isempty(binnums)
        binnums   = unique_bc2(binnums);
        listb     = handles.listb;
        indxlistb = binnums;
        indxlistb = indxlistb(indxlistb<=length(listb));
        handles.indxlistb = indxlistb;
        
        % Update handles structure
        guidata(hObject, handles);
        set(handles.edit_bins, 'String', vect2colon(binnums, 'Delimiter', 'off'));
end

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

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
                title = 'ERPLAB: geterpvalues GUI input';
                errorfound(msgboxText, title);
                return
        end
end

%--------------------------------------------------------------------------
function pushbutton_browsechan_Callback(hObject, eventdata, handles)
listch     = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename  = 'Select Channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                        set(handles.edit_channels, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.indxlistch = ch;
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

%--------------------------------------------------------------------------
function edit_custom_Callback(hObject, eventdata, handles)
blcstr = get(handles.edit_custom,'String');
blc    = str2num(blcstr);

if isempty(blc)
        msgboxText =  'Invalid baseline! You have to enter 2 numeric values, in ms.';
        title = 'ERPLAB: geterpvalues GUI invalid baseline input';
        errorfound(msgboxText, title);
        return
else
        if size(blc,1)>1 || size(blc,2)~=2
                msgboxText =  'Invalid baseline! You have to enter 2 numeric values, in ms.';
                title = 'ERPLAB: geterpvalues GUI invalid baseline input';
                errorfound(msgboxText, title);
                return
        end
end

%--------------------------------------------------------------------------
function edit_custom_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_savelistas_Callback(hObject, eventdata, handles)
fulltext = char(get(handles.listbox_erpnames,'String'));

if length(fulltext)>1
        fullname = savelist(hObject, eventdata, handles);
        
        if isempty(fullname)
                return
        end
        
        set(handles.edit_filelist, 'String', fullname )
        set(handles.button_savelist, 'Enable', 'on')
        handles.listname = fullname;
        
        % Update handles structure
        guidata(hObject, handles);
else
        set(handles.button_savelistas,'Enable','off')
        msgboxText =  'You have not specified any ERPset!';
        title = 'ERPLAB: averager GUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function button_loadlist_Callback(hObject, eventdata, handles)
[listname, lispath] = uigetfile({  '*.txt','Text File (*.txt)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an edited list', ...
        'MultiSelect', 'off');

if isequal(listname,0)
        disp('User selected Cancel')
        return
else
        fullname = fullfile(lispath, listname);
        disp(['For erpset list user selected  <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
end
try
        fid_list = fopen( fullname );
catch
        fprintf('WARNING: %s was not found or is corrupted\n', fullname)
        return
end
formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
lista = formcell{:};
% extra line forward
lista   = cat(1, lista, {'new erpset'});
lentext = length(lista);
fclose(fid_list);

if lentext>1
        try
                filereadin = strtrim(lista{1});
                ERP1 = load(filereadin, '-mat');
                ERP  = ERP1.ERP;
                
                if ~iserpstruct(ERP)
                        error('')
                end
                
                handles.srate = ERP.srate;
                
                %
                % Prepare List of current Channels and bins
                %
                handles = preparelists(hObject, eventdata, handles, ERP);
                
                set(handles.listbox_erpnames,'String',lista);
                set(handles.edit_filelist,'String',fullname);
                listname = fullname;
                handles.listname = listname;
                set(handles.button_savelistas, 'Enable','on')
                
                % Update handles structure
                guidata(hObject, handles);
        catch
                msgboxText =  'This list is anything but an ERPset list!';
                title = 'ERPLAB: geterpvaluesGUI inputs';
                errorfound(msgboxText, title)
                handles.listname = [];
                set(handles.button_savelist, 'Enable','off')
                
                % Update handles structure
                guidata(hObject, handles);
        end
else
        msgboxText =  'This list is empty!';
        title = 'ERPLAB: geterpvaluesGUI inputs';
        errorfound(msgboxText, title);
        handles.listname = [];
        set(handles.button_savelist, 'Enable','off')
        
        % Update handles structure
        guidata(hObject, handles);
end

%--------------------------------------------------------------------------
function edit_erpset_Callback(hObject, eventdata, handles)
if get(handles.radiobutton_erpset, 'Value')
        indx = str2num(get(handles.edit_erpset, 'String'));
        if ~isempty(indx)
                indx = unique_bc2(indx);
                set(handles.edit_erpset, 'String', vect2colon(indx, 'Delimiter', 'off'));
        else
                return
        end
        [chkerp, erp_ini] = checkERPs(hObject, eventdata, handles);
        if chkerp>0
                return % problem was found
        end
        ALLERP = handles.ALLERP;
        handles = preparelists(hObject, eventdata, handles, ALLERP(erp_ini));
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [chkerp, erp_ini, msgboxText] = checkERPs(hObject, eventdata, handles)
chkerp = 0; % no problem
msgboxText = '';
erp_ini    = [];
ALLERP = handles.ALLERP;
nerp   = handles.nsets;

%
% Read first ERPset
%
if get(handles.radiobutton_erpset, 'Value')==1;
        indexerp = unique_bc2(str2num(get(handles.edit_erpset, 'String')));
        if isempty(indexerp)
                chkerp  = 1; % not numeric
                return
        end
        erp_ini = indexerp(1);
else
        erp_ini = 1;
end
if max(indexerp)>nerp
        msgboxText =  ['ERPset indexing out of range!\n\n'...
                'You only have ' num2str(nerp) ' ERPsets loaded on your ERPset Menu.'];
        chkerp  = 2; % indexing out of range
        return
end
if min(indexerp)<1
        msgboxText =  ['Invalid ERPset indexing!\n\n'...
                'You may use any integer value between 1 and ' num2str(nerp)];
        chkerp  = 3; % indexing lesser than 1
        return
end

nerp2      = length(indexerp);

for k=1:nerp2
        try
                kbin(k)   = ALLERP(indexerp(k)).nbin;
                kchan(k)  = ALLERP(indexerp(k)).nchan;
                kdtype{k} = ALLERP(indexerp(k)).datatype;
        catch
                msgboxText = 'ERPset %g has a invalid number of bins/channel or different data type.\n';
                chkerp  = 4; % invalid number of bins/channel
                break
        end
end
if chkerp==4
        return
end

bintest   = length(unique(kbin));
chantest  = length(unique(kchan));
dtypetest = length(unique(kdtype));

%
% bins
%
if bintest>1
        fprintf('Detail:\n')
        fprintf('-------\n')
        
        for j=1:nerp2
                fprintf('Erpset #%g = %g bins\n', indexerp(j),ALLERP(indexerp(j)).nbin)
        end
        msgboxText =  ['Number of bins across ERPsets is different!\n\n'...
                'See detail at command window.\n'];
        chkerp  = 5; % Number of bins across ERPsets is different!
        return
else
        nbin = unique_bc2(kbin);
end

%
% channels
%
if chantest>1
        fprintf('Detail:\n')
        fprintf('-------\n')
        
        for j=1:nerp2
                fprintf('Erpset #%g = %g channnels\n', indexerp(j),ALLERP(indexerp(j)).nchan)
        end
        msgboxText =  ['Number of channels across ERPsets is different!\n\n'...
                'See detail at command window.\n'];
        chkerp  = 6; % Number of channels across ERPsets is different
        return
else
        nchan = unique_bc2(kchan);
end

%
% datatype
%
if dtypetest>1
        fprintf('Detail:\n')
        fprintf('-------\n')
        
        for j=1:nerp2
                fprintf('Erpset #%g has data type ''%s''\n', indexerp(j),ALLERP(indexerp(j)).datatype)
        end
        msgboxText =  ['Type of data across ERPsets is different!\n\n'...
                'See detail at command window.\n'];
        chkerp  = 10; % data type across ERPsets is different
        return
end

indxbin  = str2num(get(handles.edit_bins, 'String'));
indxchan = str2num(get(handles.edit_channels, 'String'));

if max(indxbin)>nbin
        msgboxText = 'You have specified unexisting bin(s)';
        chkerp     = 7; % unexisting bin(s)
        return
end
if max(indxchan)>nchan
        msgboxText = 'You have specified unexisting channel(s)';
        chkerp     = 8; % unexisting channel(s)
        return
end

errorlabel = 0;
kbinlabel  = cell(1);

for k=1:nerp2
        kbinlabel{k} = [ALLERP(indexerp(k)).bindescr{:}];
        if k>1
                if ~strcmpi(kbinlabel{k},kbinlabel{k-1})
                        errorlabel = 1;
                        break
                end
        end
end
if errorlabel==1
        fprintf('Detail:\n')
        fprintf('-------\n')
        
        for j=1:nerp2
                fprintf('Erpset #%g :\n', indexerp(j));
                fprintf('\t%s\n', ALLERP(indexerp(j)).bindescr{:});
        end
        msgboxText =  ['Bin labels across ERPsets are different!\n'...
                '(See detail at command window)\n\n'...
                'What would you like to do?'];
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        title       = 'Save List of ERPsets';
        oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button      = questdlg(sprintf(msgboxText), title,'Cancel','Terminate', 'Continue', 'Continue');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        
        if strcmpi(button,'Continue')
                chkerp  = 0;
                return
        elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                chkerp  = 9; % Bin labels across ERPsets are different
                return
        elseif strcmpi(button,'Terminate')
                
                handles.output = [];
                % Update handles structure
                guidata(hObject, handles);
                uiresume(handles.gui_chassis);
        end
end

%--------------------------------------------------------------------------
function edit_erpset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_currenterpset_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.edit_erpset,'Enable','off')
        set(handles.togglebutton_edit_list,'Enable','off')
        set(handles.radiobutton_folders,'Value',0)
        set(handles.radiobutton_erpset,'Value',0)
        set(handles.listbox_erpnames,'Enable','off')
        set(handles.button_adderpset,'Enable','off')
        set(handles.button_delerpset,'Enable','off')
        set(handles.button_savelist,'Enable','off')
        set(handles.button_clearfile,'Enable','off')
        set(handles.button_savelistas,'Enable','off')
        set(handles.button_loadlist,'Enable','off')
        set(handles.edit_filelist,'Enable','off')
        set(handles.pushbutton_flush,'Enable','off')
        ALLERP = handles.ALLERP;
        cerpi  = handles.cerpi;
        set(handles.radiobutton_currenterpset, 'String', sprintf('Current ERPset: [%g] %s', cerpi, ALLERP(cerpi).erpname))
        set(handles.edit_erpset, 'String', '')
        
        %
        % Prepare List of current Channels and bins
        %
        handles = preparelists(hObject, eventdata, handles, ALLERP(cerpi));
        
        % Update handles structure
        guidata(hObject, handles);
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_erpset_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.edit_erpset,'Enable','on')
        set(handles.radiobutton_folders,'Value',0)
        set(handles.radiobutton_currenterpset,'Value',0)
        set(handles.listbox_erpnames,'Enable','off')
        set(handles.button_adderpset,'Enable','off')
        set(handles.button_delerpset,'Enable','off')
        set(handles.button_savelist,'Enable','off')
        set(handles.button_clearfile,'Enable','off')
        set(handles.button_savelistas,'Enable','off')
        set(handles.button_loadlist,'Enable','off')
        set(handles.edit_filelist,'Enable','off')
        set(handles.pushbutton_flush,'Enable','off')
        set(handles.togglebutton_edit_list,'Enable','off')
        set(handles.radiobutton_currenterpset, 'String', 'Current ERPset:')
        
        if isempty(get(handles.edit_erpset,'String'))
                nsets = handles.nsets;
                set(handles.edit_erpset,'String', vect2colon(1:nsets, 'Delimiter','off'))
        end
        
        %
        % Prepare List of current Channels and bins
        %
        ALLERP = handles.ALLERP;
        handles = preparelists(hObject, eventdata, handles, ALLERP(1));
        
        % Update handles structure
        guidata(hObject, handles);
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_folders_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_erpset,'Value',0)
        set(handles.radiobutton_currenterpset,'Value',0)
        set(handles.edit_erpset,'Enable','off')
        set(handles.listbox_erpnames,'Enable','on')
        set(handles.button_adderpset,'Enable','on')
        set(handles.button_delerpset,'Enable','on')
        
        if ~isempty(get(handles.edit_filelist,'String'))
                set(handles.button_savelist,'Enable','on')
                set(handles.button_clearfile,'Enable','on')
        end
        
        set(handles.button_savelistas,'Enable','on')
        set(handles.button_loadlist,'Enable','on')
        set(handles.edit_filelist,'Enable','on')
        set(handles.pushbutton_flush,'Enable','on')
        set(handles.togglebutton_edit_list,'Enable','on')
        set(handles.radiobutton_currenterpset, 'String', 'Current ERPset:')
        set(handles.edit_erpset, 'String', '')
        fulltext = get(handles.listbox_erpnames, 'String');
        
        if length(fulltext)>1  % put this one on the list
                try
                        ERP1 = load(fulltext{1}, '-mat');
                        ERP  = ERP1.ERP;
                        
                        if iserpstruct(ERP)
                                %
                                % Prepare List of current Channels and bins
                                %
                                handles = preparelists(hObject, eventdata, handles, ERP);
                        else
                                handles = preparelists(hObject, eventdata, handles, []);
                        end
                catch
                        handles = preparelists(hObject, eventdata, handles, []);
                end
        else
                handles = preparelists(hObject, eventdata, handles, []);
                
                % Update handles structure
                guidata(hObject, handles);
        end
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function fullname = savelist(hObject, eventdata, handles)
fullname = '';
fulltext = char(get(handles.listbox_erpnames,'String'));

%
% Save OUTPUT file
%
[filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save erpset list as');

if isequal(filename,0)
        disp('User selected Cancel')
        return
else
        [px, fname, ext] = fileparts(filename);
        
        if strcmp(ext,'')
                if filterindex==1 || filterindex==3
                        ext   = '.txt';
                else
                        ext   = '.dat';
                end
        end
        
        fname = [ fname ext];
        fullname = fullfile(filepath, fname);
        disp(['To Save erpset list, user selected ', fullname])
        
        fid_list   = fopen( fullname , 'w');
        
        for i=1:size(fulltext,1)-1
                fprintf(fid_list,'%s\n', fulltext(i,:));
        end
        
        fclose(fid_list);
end

% -------------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function handles = preparelists(hObject, eventdata, handles, ERPi)

%
% Prepare List of current Channels and bins
%
if ~isempty(ERPi)
        ERPi   = ERPi(1);
        listch = [];
        nchan  = ERPi.nchan; %
        nbin   = ERPi.nbin;  %
        xmin   = ERPi.xmin;  %
        xmax   = ERPi.xmax;  %
        srate  = ERPi.srate; %
        
        if isempty(ERPi.chanlocs)
                for e=1:nchan
                        ERPi.chanlocs(e).labels = ['Ch' num2str(e)];
                end
        end
        
        listch = {[]};
        for ch =1:nchan
                listch{ch} = [num2str(ch) ' = ' ERPi.chanlocs(ch).labels ];
        end
        
        %
        % Prepare List of current Bins
        %
        listb = {[]};
        for b=1:nbin
                listb{b}= ['BIN' num2str(b) ' = ' ERPi.bindescr{b} ];
        end
        
        %def = handles.def;
        
        binx  = str2num(get(handles.edit_bins,'String'));
        chanx = str2num(get(handles.edit_channels,'String'));
        
        if isempty(binx)
                binArray  = handles.binmem;
        else
                binArray  = binx;
        end
        if isempty(chanx)
                chanArray  = handles.chanmem;
        else
                chanArray  = chanx;
        end
        if ~isempty(binArray) && ~isempty(chanArray)
                selchan   = chanArray(chanArray>=1 & chanArray<=nchan);
                selbin    = binArray(binArray>=1 & binArray<=nbin);
        else
                selchan = 1:nchan;
                selbin  = 1:nbin;
        end
        
        set(handles.edit_bins,'String', vect2colon(selbin, 'Delimiter','off', 'Repeat', 'off'))
        set(handles.edit_channels,'String', vect2colon(selchan, 'Delimiter','off', 'Repeat', 'off'))
else
        nchan = 0;
        nbin  = 0;
        xmin  = [];
        xmax  = [];
        srate = [];
        %set(handles.edit_bins,'String', '')
        %set(handles.edit_channels,'String', '')
        listb = '';
        listch = '';
        selchan = [];
        selbin  = [];
end

handles.nchan = nchan;
handles.nbin  = nbin;
handles.xmin  = xmin;
handles.xmax  = xmax;
handles.srate = srate;
handles.listb = listb;
handles.listch = listch;
handles.indxlistb = selbin;
handles.indxlistch = selchan;
handles.binmem  = selbin;
handles.chanmem = selchan;

% Update handles structure
guidata(hObject, handles);
drawnow

% -------------------------------------------------------------------------
function checkbox_binlabel_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function checkbox_binlabel_CreateFcn(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function pushbutton_run_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function button_savelist_Callback(hObject, eventdata, handles)
fulltext = char(strtrim(get(handles.listbox_erpnames,'String')));

if length(fulltext)>1
        fullname = get(handles.edit_filelist, 'String');
        if ~strcmp(fullname,'')
                fid_list   = fopen( fullname , 'w');
                for i=1:size(fulltext,1)
                        fprintf(fid_list,'%s\n', fulltext(i,:));
                end
                
                fclose(fid_list);
                handles.listname = fullname;
                
                % Update handles structure
                guidata(hObject, handles);
                disp(['Saving equation list at <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        else
                button_savelistas_Callback(hObject, eventdata, handles)
                return
        end
else
        set(handles.button_savelistas,'Enable','off')
        msgboxText =  'You have not written any formula yet!';
        title = 'ERPLAB: chanoperGUI few inputs';
        errorfound(msgboxText, title);
        set(handles.button_savelistas,'Enable','on')
        return
end

%--------------------------------------------------------------------------
function button_clearfile_Callback(hObject, eventdata, handles)
set(handles.edit_filelist,'String','');
set(handles.button_savelist, 'Enable', 'off')
handles.listname = [];
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function edit_filelist_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_filelist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_pol_amp_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_pol_amp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_samp_amp_Callback(hObject, eventdata, handles)
kktime = handles.kktime;
srate = handles.srate;
pnts  = get(handles.popupmenu_samp_amp,'Value')-1;
intfactor = get(handles.popupmenu_interpofactor,'Value');
if isempty(srate)
        msecstr = sprintf('pnts ( ? ms)');
else
        msecstr = sprintf('pnts (%4.1f ms)', (pnts/srate*intfactor)*kktime);
end
set(handles.text_samp,'String',msecstr)

%--------------------------------------------------------------------------
function popupmenu_samp_amp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_measurement_Callback(hObject, eventdata, handles)
meamenu   = get(handles.popupmenu_measurement, 'String');
currentm  = get(handles.popupmenu_measurement, 'Value');
if currentm==7
        mnamex = 'Numerical integration/Area between two (automatically detected) zero-crossing latencies';
        question = [ '%s\n\nThis tool is still in alpha phase.\n'...
                'Use it under your responsibility.'];
        title       = 'ERPLAB: Overwriting Confirmation';
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
end

areatype  = get(handles.popupmenu_areatype,'Value');
formatout = get(handles.popupmenu_formatout,'Value');
version   = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   ERP Measurements GUI   -   ' meamenu{currentm}])

datatype = handles.datatype;
if strcmpi(datatype, 'ERP')
        meawordx = 'latenc';
else
        meawordx = 'frequenc';
end

%
%  NEW MENU
%

% 1 = 'Instantaneous amplitude',
% 2 = 'Mean amplitude between two fixed latencies',...
% 3 = 'Peak amplitude'
% 4 = 'Peak latency'
% 5 = 'Fractional Peak latency',...
% 6 = 'Numerical integration/Area between two fixed latencies'
% 7 = 'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
% 8 = 'Fractional Area latency'

switch currentm
        case 1 % 'Instantaneous amplitude'
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use one ' meawordx 'y)']);
                set(handles.popupmenu_areatype,'Enable','off')
        case {2,6} % mean, area, integral between fixed latencies
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
                if currentm==6
                        set(handles.popupmenu_areatype,'Enable','on')
                else
                        set(handles.popupmenu_areatype,'Enable','off')
                end
        case {3,4} % 'Peak amplitude', 'Peak latency'
                menupeakon(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
                set(handles.popupmenu_areatype,'Enable','off')
                set(handles.popupmenu_fracreplacement, 'String', {'fractional absolute peak','"not a number" (NaN)'});
        case 5 % 'Fractional Peak latency'
                menupeakon(hObject, eventdata, handles)
                menufareaon(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
                set(handles.text_fraca,'String', 'Fractional Peak')
                set(handles.popupmenu_areatype,'Enable','off')
        case {7} % area, integral automatic limits
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use one "seed" ' meawordx 'y)']);
                if currentm==7
                        set(handles.popupmenu_areatype,'Enable','on')
                else
                        set(handles.popupmenu_areatype,'Enable','off')
                end
        case 8 % 'Fractional Area latency'
                menupeakoff(hObject, eventdata, handles)
                menufareaon(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
                set(handles.text_fraca,'String', 'Fractional Area')
                set(handles.popupmenu_areatype,'Enable','on')
                set(handles.popupmenu_fracreplacement, 'String', {'show error message','"not a number" (NaN)'});
        otherwise % 'test'
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
end

%--------------------------------------------------------------------------
function popupmenu_measurement_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_locpeakreplacement_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_locpeakreplacement_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function uipanel9_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel1_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel2_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_cancel_CreateFcn(hObject, eventdata, handles)

% %--------------------------------------------------------------------------
% function text_tip_inputlat_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel4_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel6_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel8_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel12_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function uipanel13_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_erpset_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radiobutton_folders_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function setall(hObject, eventdata, handles)

ALLERP   = handles.ALLERP;
if isstruct(ALLERP)
        nsets    = length(ALLERP);
        nbin = ALLERP(1).nbin;
        nchan = ALLERP(1).nchan;
else
        nsets = 0;
        nbin  = 1;
        nchan = 1;
end
datatype = handles.datatype;
set(handles.popupmenu_samp_amp,'String',cellstr(num2str([0:40]')))
set(handles.popupmenu_precision,'String', num2str([1:6]'))
kktime = handles.kktime;

%
%  NEW MENU
%

% 1 = 'Instantaneous amplitude',
% 2 = 'Mean amplitude between two fixed latencies',...
% 3 = 'Peak amplitude'
% 4 = 'Peak latency'
% 5 = 'Fractional Peak latency',...
% 6 = 'Numerical integration/Area between two fixed latencies'
% 7 = 'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
% 8 = 'Fractional Area latency'

%
% New Are type menu
%
% 1 = 'Rectified area (negative values become positive)'
% 2 = 'Numerical integration (negative substracted from positive)'
% 3 = 'Only positive area'
% 4 = 'Only negative area'
%

if strcmpi(datatype, 'ERP')
        measurearray = {'Instantaneous amplitude',...
                'Mean amplitude between two fixed latencies',...
                'Peak amplitude',...
                'Peak latency',...
                'Fractional Peak latency',...
                'Numerical integration/Area between two fixed latencies',...
                'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
                'Fractional Area latency'};
else
        measurearray = {'Instantaneous power',...
                'Mean power between two fixed frequencies',...
                'Peak power',...
                'Peak frequency',...
                'Fractional Peak frequency',...
                'Numerical integration/Area between two fixed frequencies',...
                '------------------------------------------------------'...
                'Fractional Area frequency'};
end
set(handles.popupmenu_measurement, 'String', measurearray);
set(handles.popupmenu_locpeakreplacement, 'String', {'absolute peak','"not a number" (NaN)','show error message'});
set(handles.popupmenu_fracreplacement, 'String', {'closest value','"not a number" (NaN)','show error message'});

%
% Output style
%
styleout = {'One ERPset per line (wide format)', 'One measurement per line (long format)'};
set(handles.popupmenu_formatout, 'String', styleout);

%
% Type of Area
%
% areatype = {'Total area', 'Only positive area', 'Only negative area'};
areatype = {'Rectified area (negative values become positive)', 'Numerical integration (area for negatives substracted from area for positives)',...
        'Area for positive waveforms (negative values will be zeroed)', 'Area for negative waveforms (positive values will be zeroed)'};
set(handles.popupmenu_areatype, 'String', areatype);

% Interpolation factor
set(handles.popupmenu_interpofactor, 'String', cellstr(num2str([1:10]'))')

%
% GUI's working memory
%
def = handles.def;
% def{:}

if ~isempty(def)
        optioni    = def{1};  %1 means from hard drive, 0 means from erpsets menu; 2 means current erpset (at erpset menu)
        erpset     = def{2};  % indices of erpset or filename of list of erpsets
        fname      = def{3};
        latency    = def{4};
        binArray   = def{5};
        chanArray  = def{6};
        op         = def{7};  % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
        coi        = def{8};
        dig        = def{9};
        
        if strcmpi(datatype, 'ERP')
                blc        = def{10};
        else
                blc = 'none';
        end
        binlabop   = def{11}; % 0: bin# as bin label for table, 1 bin label
        polpeak    = def{12}; % local peak polarity
        sampeak    = def{13}; % number of samples (one-side) for local peak detection criteria
        locpeakrep = def{14}; % 1 abs peak , 0 Nan
        frac       = def{15};
        fracmearep = def{16}; % def{19}; NaN
        send2ws    = def{17}; % 1 send to ws, 0 dont do
        foutput    = def{18}; % 1 = 1 measurement per line; 0 = 1 erpset per line
        mlabel     = def{19};
        inclate    = def{20};
        intfactor  = def{21};
        
        if isempty(sampeak)
                sampeak = 3;
        end
else
        optioni    = 1; %1 means from hard drive, 0 means from erpsets menu; 2 means current erpset (at erpset menu)
        erpset     = 1; % indices of erpset or filename of list of erpsets
        fname      = '';
        latency    = 0;
        binArray   = 1:nbin;
        chanArray  = 1:nchan;
        op         = 'instabl'; % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
        coi        = 0; % ignore overlapped components
        dig        = 3;
        if strcmpi(datatype, 'ERP')
                blc        = 'pre';
        else
                blc        = 'none';
        end
        binlabop   = 0; % 0: bin# as bin label for table, 1 bin label
        polpeak    = 1; % local peak polarity
        sampeak    = 3; % number of samples (one-side) for local peak detection criteria
        locpeakrep = 1; % 1 abs peak , 0 Nan
        send2ws    = 0; % 1 send to ws, 0 dont do
        foutput    = 1; % 1 = 1 measurement per line; 0 = 1 erpset per line
        mlabel     = '';
        inclate    = 0;
        frac       = 0.50;
        fracmearep = 1; %NaN
        intfactor  = 1;
end
if isempty(frac)
        frac = 0.50;
end

%
% New menu
%
[tfm, indxmeaX] = ismember_bc2({op}, {'instabl', 'meanbl', 'peakampbl', 'peaklatbl', 'fpeaklat',...
        'areat', 'areap', 'arean','areazt','areazp','areazn','fareatlat', 'fninteglat',...
        'fareaplat','fareanlat', 'ninteg','nintegz' } );

%
% fix index for menu
%
areatype=1; % 1=total; 2=integral; 3=pos; 4= neg
fracmenuindex = 2-fracmearep;

if ismember(indxmeaX,[6 7 8 16])
        indxmea = 6;
        areatype = find(indxmeaX==[6 16 7 8]);  % 1,2,3,4
elseif ismember(indxmeaX,[9 10 11 17])
        areatype = find(indxmeaX==[9 17 10 11]);  % 1,2,3,4
        
        if strcmpi(datatype, 'ERP')
                indxmea = 7;
        else
                indxmea = 1;
        end
elseif ismember(indxmeaX,[12 13 14 15])
        areatype = find(indxmeaX==[12 13 14 15]);  % 1,2,3,4
        indxmea = 8;
        fracmenuindex = round(2^(fracmearep/2)); % when 0 means 1, when 2 means 2;
else
        indxmea = indxmeaX;
end

%
% Baseline reference. (Fixed bug about custom base line. First reported by Andrew Hill)
%
measurearray = {'None','Pre','Post','Whole','Custom'};
set(handles.popupmenu_baseliner, 'String', measurearray);
if strcmpi(datatype, 'ERP')
        mwordx = 'latenc';
        if ischar(blc)
                [tfm, indxblc] = ismember_bc2({blc}, {'none', 'pre', 'post', 'whole', 'all'} );
                if indxblc == 5
                        indxblc = 4;
                elseif indxblc==0
                        indxblc = 1;
                end
        else
                indxblc = 5;
        end
        
        %
        % Set blc buttons
        %
        set(handles.popupmenu_baseliner, 'Value', indxblc)
        if indxblc==5
                set(handles.edit_custombr,'Enable','on')
                try
                        blcstrm = num2str(blc);
                catch
                        blcstrm = '?????';
                end
                set(handles.edit_custombr,'String', blcstrm)
        else
                set(handles.edit_custombr,'Enable','off')
        end
        
        set(handles.text_meawinunit, 'String', 'ms');
        
        
else
        mwordx = 'frequenc';
        set(handles.popupmenu_baseliner, 'Value', 1);
        set(handles.popupmenu_baseliner, 'Enable', 'off');
        set(handles.text_meawinunit, 'String', 'Hz');
        set(handles.edit_custombr,'Enable','off')
end

%
% Type of output
%
% 1 = one measurement per line; 0 = one erpset per line
%
if foutput==0
        set(handles.popupmenu_formatout, 'Value', 1);
        %set(handles.edit_label_mea,'Enable', 'off')
        set(handles.checkbox_include_used_latencies, 'Enable', 'off');
else
        set(handles.popupmenu_formatout, 'Value', 2);
        set(handles.edit_label_mea,'Enable', 'on')
        set(handles.edit_label_mea,'String', mlabel)
        set(handles.checkbox_include_used_latencies, 'Enable', 'on');
        set(handles.checkbox_include_used_latencies, 'Value', inclate);
end

% interpolation
set(handles.popupmenu_interpofactor, 'Value', intfactor);

%
% Measurements
%
set(handles.popupmenu_measurement,'value', indxmea);
set(handles.popupmenu_fracreplacement,'value', fracmenuindex);

%
%  NEW MENU (indxmea)
%
% 1 = 'Instantaneous amplitude',
% 2 = 'Mean amplitude between two fixed latencies',...
% 3 = 'Peak amplitude'
% 4 = 'Peak latency'
% 5 = 'Fractional Peak latency',...
% 6 = 'Numerical integration/Area between two fixed latencies'
% 7 = 'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
% 8 = 'Fractional Area latency'

set(handles.popupmenu_samp_amp,'value',sampeak+1);

switch indxmea
        case 1     % 'Instantaneous amplitude'
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.popupmenu_areatype,'Enable','off')
                set(handles.text_tip_inputlat, 'String',['(use one ' mwordx 'y)']);
        case {2,6} % mean, area, integral between fixed latencies
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
                if indxmea==6
                        set(handles.popupmenu_areatype,'Enable','on')
                        set(handles.popupmenu_areatype,'Value',areatype)
                else
                        set(handles.popupmenu_areatype,'Enable','off')
                end
        case {3,4} % 'Peak amplitude', 'Peak latency'
                menupeakon(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
                set(handles.popupmenu_pol_amp,'value',2-polpeak)
                %set(handles.popupmenu_samp_amp,'value',sampeak+1);
                set(handles.popupmenu_locpeakreplacement,'value',2-locpeakrep);
                set(handles.popupmenu_areatype,'Enable','off')
        case 5     % 'Fractional Peak latency'
                menupeakon(hObject, eventdata, handles)
                menufareaon(hObject, eventdata, handles)
                fracpos = round(frac*100)+1;
                set(handles.popupmenu_fraca,'Value', fracpos)
                set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
                set(handles.text_fraca,'String', 'Fractional Peak')
                set(handles.popupmenu_pol_amp,'value',2-polpeak)
                %set(handles.popupmenu_samp_amp,'value',sampeak+1);
                set(handles.popupmenu_locpeakreplacement,'value',2-locpeakrep);
                %set(handles.popupmenu_fracreplacement,'value',2-fracmearep);
                set(handles.popupmenu_areatype,'Enable','off')
        case 7     % area and integral with auto limits
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use one "seed" ' mwordx 'y)']);
                set(handles.popupmenu_areatype,'Enable','on')
                set(handles.popupmenu_areatype,'Value',areatype)
                
        case 8     % fractional area
                menupeakoff(hObject, eventdata, handles)
                menufareaon(hObject, eventdata, handles)
                fracpos = round(frac*100)+1;
                set(handles.popupmenu_fraca,'Value', fracpos)
                set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
                set(handles.text_fraca,'String', 'Fractional Area')
                set(handles.popupmenu_areatype,'Enable','on')
                set(handles.popupmenu_areatype,'Value',areatype)
                set(handles.popupmenu_fracreplacement, 'String', {'"not a number" (NaN)', 'show error message'});
        otherwise
                menupeakoff(hObject, eventdata, handles)
                menufareaoff(hObject, eventdata, handles)
                set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
end

set(handles.edit_latency, 'String',  sprintf('%.2f  ', unique_bc2(latency)))
set(handles.popupmenu_precision, 'Value', dig)

if binlabop==0
        set(handles.checkbox_binlabel, 'Value', 0) % use bin number as binlabel
else
        set(handles.checkbox_binlabel, 'Value', 1) % use bin descr as binlabel
end

set(handles.edit_fname, 'String', fname);
set(handles.checkbox_send2ws, 'Value', send2ws);

if nsets>0 && (optioni==0 || optioni==2)
        if optioni==0
                set(handles.radiobutton_currenterpset, 'Value', 0);
                set(handles.radiobutton_erpset, 'Value', 1);
                set(handles.radiobutton_erpset, 'Enable', 'on');
                set(handles.edit_erpset, 'String', vect2colon(erpset, 'Delimiter','off', 'Repeat', 'off'));
                indxload = erpset(1);
        else
                set(handles.radiobutton_currenterpset, 'Value', 1);
                set(handles.radiobutton_erpset, 'Value', 0);
                set(handles.radiobutton_erpset, 'Value', 0);
                set(handles.edit_erpset, 'Enable', 'off');
                cerpi = handles.cerpi;
                indxload = cerpi;
                set(handles.radiobutton_currenterpset, 'String', sprintf('Current ERPset: [%g] %s', indxload, ALLERP(indxload).erpname))
        end
        
        set(handles.radiobutton_folders, 'Value', 0);
        set(handles.listbox_erpnames, 'Enable', 'off');
        set(handles.button_adderpset, 'Enable', 'off');
        set(handles.button_delerpset, 'Enable', 'off');
        set(handles.button_savelistas, 'Enable', 'off');
        set(handles.button_savelist, 'Enable', 'off');
        set(handles.button_clearfile, 'Enable', 'off');
        set(handles.button_loadlist, 'Enable', 'off');
        set(handles.listbox_erpnames, 'String', {'new erpset'});
        set(handles.edit_filelist,'String', '')
        set(handles.pushbutton_flush,'Enable','off')
        set(handles.togglebutton_edit_list,'Enable','off')
        
        %
        % Prepare List of current Channels and bins
        %
        handles = preparelists(hObject, eventdata, handles, ALLERP(indxload));
else
        set(handles.radiobutton_folders, 'Value', 1);
        set(handles.radiobutton_erpset, 'Value', 0);
        set(handles.radiobutton_currenterpset, 'Value', 0);
        set(handles.edit_erpset, 'Enable', 'off');
        set(handles.pushbutton_flush,'Enable','on')
        
        if nsets==0
                set(handles.radiobutton_erpset, 'Enable', 'off');
                set(handles.radiobutton_currenterpset, 'Enable', 'off');
                set(handles.edit_erpset, 'String', 'no erpset');
        else
                set(handles.edit_erpset, 'String', vect2colon(1:nsets, 'Delimiter','off', 'Repeat', 'off'));
        end
        
        %{option erpset fname latency binArray chanArray op coi dig blc binlabop polpeak sampeak localp}
        
        if ~isempty(erpset) && ischar(erpset)
                try
                        fid_list = fopen( erpset );
                        formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
                        lista    = formcell{:};
                        
                        % extra line forward
                        lista   = cat(1, lista, {'new erpset'});
                        lentext = length(lista);
                        fclose(fid_list);
                        
                        if lentext>1
                                try
                                        ERP1 = load(strtrim(lista{1}), '-mat');
                                        ERP  = ERP1.ERP;
                                        
                                        if ~iserpstruct(ERP)
                                                error('')
                                        end
                                        
                                        handles.srate = ERP.srate;
                                        %
                                        % Prepare List of current Channels and bins
                                        %
                                        handles = preparelists(hObject, eventdata, handles, ERP);
                                        
                                        set(handles.listbox_erpnames,'String',lista);
                                        listname = erpset;
                                        handles.listname = listname;
                                        set(handles.button_savelistas, 'Enable','on')
                                        set(handles.edit_filelist,'String', erpset)
                                        
                                        %                                         % Update handles structure
                                        %                                         guidata(hObject, handles);
                                catch
                                        handles.listname = [];
                                        set(handles.button_savelist, 'Enable','off')
                                        
                                        %                                         % Update handles structure
                                        %                                         guidata(hObject, handles);
                                end
                        else
                                handles.listname = [];
                                set(handles.button_savelist, 'Enable','off')
                                
                                %                                 % Update handles structure
                                %                                 guidata(hObject, handles);
                        end
                catch
                        set(handles.listbox_erpnames, 'String', {'new erpset'});
                        set(handles.edit_filelist,'String', '')
                        handles.listname = [];
                        set(handles.button_savelist, 'Enable','off')
                        %
                        %                         % Update handles structure
                        %                         guidata(hObject, handles);
                        handles = preparelists(hObject, eventdata, handles, []);
                end
        else
                set(handles.listbox_erpnames, 'String', {'new erpset'});
                set(handles.edit_filelist,'String', '')
        end
end

srate = handles.srate;
try
        msecstr = sprintf('pnts (%4.1f ms)', (sampeak/srate*intfactor)*kktime);
catch
        msecstr = 'pnts (... ms)';
end

set(handles.text_samp,'String',msecstr)

%
% Name & version
%
meamenu  = get(handles.popupmenu_measurement, 'String');
currentm = get(handles.popupmenu_measurement, 'Value');
version  = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   ERP Measurements GUI   -   ' meamenu{currentm}])
handles.frac = frac;

handles.binmem     = binArray;
handles.chanmem    = chanArray;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function gui_chassis_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_send2ws_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_flush_Callback(hObject, eventdata, handles)
button_clearfile_Callback(hObject, eventdata, handles)
set(handles.listbox_erpnames, 'String', '');
if get(handles.togglebutton_edit_list,'Value') % edit
        set(handles.listbox_erpnames, 'String', 'new erpset');
else
        set(handles.listbox_erpnames, 'String', {'new erpset'});
        set(handles.listbox_erpnames, 'Value', 1);
end
return

%--------------------------------------------------------------------------
function radiobutton_f0_1erp_per_line_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_f1_1mea_per_line,'Value',0)
        %set(handles.edit_label_mea,'Enable', 'off')
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function radiobutton_f1_1mea_per_line_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.radiobutton_f0_1erp_per_line,'Value',0)
        set(handles.edit_label_mea,'Enable', 'on')
else
        set(hObject,'Value',1)
end

%--------------------------------------------------------------------------
function edit_label_mea_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_label_mea_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_interpofactor_Callback(hObject, eventdata, handles)
kktime = handles.kktime;
srate = handles.srate;
pnts  = get(handles.popupmenu_samp_amp,'Value')-1;
intfactor = get(handles.popupmenu_interpofactor,'Value');
if isempty(srate)
        msecstr = sprintf('pnts ( ? ms)');
else
        msecstr = sprintf('pnts (%4.1f ms)', (pnts/srate*intfactor)*kktime);
end
set(handles.text_samp,'String',msecstr)

%--------------------------------------------------------------------------
function popupmenu_interpofactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit10_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_fraca_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_fraca_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_custombr_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_custombr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_baseliner_Callback(hObject, eventdata, handles)
indxblc = get(handles.popupmenu_baseliner, 'Value');
if indxblc==5
        set(handles.edit_custombr,'Enable','on')
else
        set(handles.edit_custombr,'Enable','off')
end

%--------------------------------------------------------------------------
function popupmenu_baseliner_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_formatout_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==2
        set(handles.edit_label_mea,'Enable','on')
        set(handles.checkbox_include_used_latencies,'Enable','on')
        mtype    = get(handles.popupmenu_measurement,'Value');
        areatype = get(handles.popupmenu_areatype,'Value');
        meatxt   = get(handles.edit_label_mea,'String');
else
        %set(handles.edit_label_mea,'Enable','off')
        set(handles.checkbox_include_used_latencies,'Enable','off')
end

%--------------------------------------------------------------------------
function popupmenu_formatout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_fracreplacement_Callback(hObject, eventdata, handles)
% if get(hObject,'Value')==1
%       set(handles. popupmenu_fracreplacement,'Value',2)
% end

%--------------------------------------------------------------------------
function popupmenu_fracreplacement_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_areatype_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_areatype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_include_used_latencies_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function togglebutton_edit_list_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        %list = get(handles.listbox_erpnames, 'String')
        set(handles.listbox_erpnames, 'Value',1)
        set(handles.listbox_erpnames, 'Style','edit')
        set(handles.listbox_erpnames, 'Max',2)
        set(handles.listbox_erpnames, 'HorizontalAlignment','left')
        set(handles.listbox_erpnames, 'Foregroundcolor',[0 0 0.72])
        
        set(handles.button_delerpset,'Enable','off')
        set(handles.button_adderpset,'Enable','off')
        set(handles.button_savelistas,'Enable','off')
        set(handles.button_savelist,'Enable','off')
        set(handles.button_clearfile,'Enable','off')
        set(handles.button_loadlist,'Enable','off')
else
        %list = get(handles.listbox_erpnames, 'String')
        set(handles.listbox_erpnames, 'Style','listbox')
        set(handles.listbox_erpnames, 'Value',1)
        set(handles.listbox_erpnames, 'Foregroundcolor',[0 0 0])
        set(handles.button_delerpset,'Enable','on')
        set(handles.button_adderpset,'Enable','on')
        set(handles.button_savelistas,'Enable','on')
        set(handles.button_savelist,'Enable','on')
        set(handles.button_clearfile,'Enable','on')
        set(handles.button_loadlist,'Enable','on')
end

%--------------------------------------------------------------------------
function togglebutton_viewer_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        pushbutton_run_Callback(hObject, eventdata, handles)
end

%--------------------------------------------------------------------------
function uipanel_inputlat_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end


% --- Executes on selection change in popupmenu_rise.
function popupmenu_rise_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_rise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_rise contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_rise


% --- Executes during object creation, after setting all properties.
function popupmenu_rise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_rise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_punit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_punit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text_fa1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_fa1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function text_fraca_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_fa1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
