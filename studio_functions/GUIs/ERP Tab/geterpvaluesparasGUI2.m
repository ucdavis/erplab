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

function varargout = geterpvaluesparasGUI2(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @geterpvaluesparasGUI2_OpeningFcn, ...
    'gui_OutputFcn',  @geterpvaluesparasGUI2_OutputFcn, ...
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
function geterpvaluesparasGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for geterpvaluesparasGUI2
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
    def = varargin{1};
    handles.def = def;
catch
    def = {'fpeaklat', 3, 0, 1, 3, 0, 0.5, 0, 0, 1, 1, 1};
    handles.def = def;
end


try
    ERP = varargin{2};
    if isstruct(ERP)
        handles.xmin  = ERP.xmin;
        handles.xmax  = ERP.xmax;
        handles.srate = ERP.srate;
        
    else
        handles.xmin  = [];
        handles.xmax  = [];
        handles.srate = [];
        
    end
    datatype =ERP.datatype;
catch
    ERP = [];
    handles.xmin  = [];
    handles.xmax  = [];
    handles.srate = [];
    handles.nsets = [];
    datatype = 'ERP';
end

handles.datatype = datatype;
if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    return;
end
handles.kktime     = kktime;


handles.frac      = [];
handles.intfactor = [];

%
% Color GUI
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

% Update handles structure
guidata(hObject, handles);

setall(hObject, eventdata, handles)

% help
% helpbutton

% viewer
% viewerbutton

%
% Set Measurement menu
%
% set(handles.listbox_erpnames, 'Value',1)
% set(handles.popupmenu_measurement, 'Backgroundcolor',[1 1 0.8])
% set(handles.popupmenu_pol_amp, 'Backgroundcolor',[1 1 0.8])
% set(handles.popupmenu_samp_amp, 'Backgroundcolor',[1 1 0.8])
% set(handles.popupmenu_locpeakreplacement, 'Backgroundcolor',[1 1 0.8])
% set(handles.popupmenu_fracreplacement, 'Backgroundcolor',[1 1 0.8])
% set(handles.popupmenu_precision, 'Backgroundcolor',[1 1 0.8])
%set(handles.text_fraca,'String', {''});
%set(handles.text_fa3,'String',{''});
drawnow

% UIWAIT makes geterpvaluesparasGUI2 wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = geterpvaluesparasGUI2_OutputFcn(hObject, eventdata, handles)
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
set(handles.popupmenu_pol_amp, 'Enable', 'off')
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
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)
datatype = handles.datatype;
kktime = handles.kktime;
if kktime==1 % sec or Hz
    TimeOp = 0;
else % ms
    TimeOp = 1;
end

xmin  = handles.xmin;
xmax  = handles.xmax;

srate = handles.srate;


% Send to workspace
%
send2ws = get(handles.checkbox_send2ws, 'Value'); % 0:no; 1:yes
owfp    = handles.owfp;  % over write file permission
appendfile = 0;


% if ~strcmp(chanArraystr, '') && ~isempty(chanArraystr) && ~strcmp(latestr, '') && ~isempty(latestr) && ~strcmp(binArraystr, '') && ~isempty(binArraystr)
%         binArray   = str2num(binArraystr);
%         chanArray  = str2num(chanArraystr);
%         late       = str2num(latestr);
%         nlate      = length(late);
%


polpeak    = [];
sampeak    = [];
% coi        = 0; % ignore overlapped components
locpeakrep = 0;
frac       = [];
fracmearep = 0;
measure_option = get(handles.popupmenu_measurement, 'Value');
areatype       = get(handles.popupmenu_areatype,'Value');  % 1=total ; 2=pos; 3=neg



switch measure_option
    case 1  % instabl
        %         if nlate~=1
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define only one frequency';
        %             else
        %                 msgboxText =  'You must define only one latency';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
        moption = 'instabl';
        fprintf('\nInstantaneous amplitude measurement in progress...\n');
    case 2  % meanbl
        %         if nlate~=2
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define two frequencies';
        %             else
        %                 msgboxText =  'You must define two latencies';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
        moption = 'meanbl';
        fprintf('\nMean amplitude measurement in progress...\n');
    case 3  % peakampbl
        %         if nlate~=2
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define two frequencies';
        %             else
        %                 msgboxText =  'You must define two latencies';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
        moption = 'peakampbl';
        polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
        sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
        locpeakrep = 2-get(handles.popupmenu_locpeakreplacement,'Value');
        
        %         cc1    = late(1)-sample2time(TimeOp, sampeak, srate) < xmin*kktime;
        %         ccdiff = abs((late(1)-sample2time(TimeOp, sampeak, srate)) - xmin*kktime);
        %         cc2    = time2sample(TimeOp, ccdiff, srate)>2;
        %         cc3    = late(2)+sample2time(TimeOp, sampeak, srate)>xmax*kktime;
        %         ccdiff = abs((late(2)+sample2time(TimeOp, sampeak, srate)) - xmax*kktime);
        %         cc4    = time2sample(TimeOp, ccdiff, srate)>2;
        
        %         if (cc1 && cc2) || (cc3 && cc4)
        %             msgboxText =  msgboxText4peak;
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText,sampeak, sampeak, sampeak, xmin*kktime, xmax*kktime, xmin*kktime+sample2time(TimeOp, sampeak,srate), xmax*kktime-sample2time(TimeOp, sampeak,srate)), title);
        %             return
        %         end
        fprintf('\nLocal peak measurement in progress...\n');
    case 4  % peaklatbl
        %         if nlate~=2
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define two frequencies';
        %             else
        %                 msgboxText =  'You must define two latencies';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
        moption = 'peaklatbl';
        polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
        sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
        locpeakrep = 2-get(handles.popupmenu_locpeakreplacement,'Value');
        
        %         cc1    = late(1)-sample2time(TimeOp, sampeak, srate) < xmin*kktime;
        %         ccdiff = abs((late(1)-sample2time(TimeOp, sampeak, srate)) - xmin*kktime);
        %         cc2    = time2sample(TimeOp, ccdiff, srate)>2;
        %         cc3    = late(2)+sample2time(TimeOp, sampeak, srate)>xmax*kktime;
        %         ccdiff = abs((late(2)+sample2time(TimeOp, sampeak, srate)) - xmax*kktime);
        %         cc4    = time2sample(TimeOp, ccdiff, srate)>2;
        
        %         if (cc1 && cc2) || (cc3 && cc4)
        %             msgboxText =  msgboxText4peak;
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText,sampeak, sampeak, sampeak, xmin*kktime, xmax*kktime, xmin*kktime+sample2time(TimeOp, sampeak,srate), xmax*kktime-sample2time(TimeOp, sampeak,srate)), kktime);
        %             return
        %         end
        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
            fprintf('\nLocal peak frequency measurement in progress...\n');
        else
            fprintf('\nLocal peak latency measurement in progress...\n');
        end
    case 5  % fpeaklat
        %         if nlate~=2
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define two frequencies';
        %             else
        %                 msgboxText =  'You must define two latencies';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
        set(handles.text_fraca,'String', 'Fractional Peak')
        moption = 'fpeaklat';
        frac    = (get(handles.popupmenu_fraca,'Value') - 1)/100; % 0 to 1
        polpeak = 2-get(handles.popupmenu_pol_amp,'Value');
        sampeak = get(handles.popupmenu_samp_amp,'Value') - 1;
        locpeakrep = 2-get(handles.popupmenu_locpeakreplacement,'Value');
        fracmearep = 2-get(handles.popupmenu_fracreplacement,'Value');
        
        %         cc1    = late(1)-sample2time(TimeOp, sampeak, srate) < xmin*kktime;
        %         ccdiff = abs((late(1)-sample2time(TimeOp, sampeak, srate)) - xmin*kktime);
        %         cc2    = time2sample(TimeOp, ccdiff, srate)>2;
        %         cc3    = late(2)+sample2time(TimeOp, sampeak, srate)>xmax*kktime;
        %         ccdiff = abs((late(2)+sample2time(TimeOp, sampeak, srate)) - xmax*kktime);
        %         cc4    = time2sample(TimeOp, ccdiff, srate)>2;
        
        %         if (cc1 && cc2) || (cc3 && cc4)
        %             msgboxText =  msgboxText4peak;
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText,sampeak, sampeak, sampeak, xmin*kktime, xmax*kktime, xmin*kktime+sample2time(TimeOp, sampeak,srate), xmax*kktime-sample2time(TimeOp, sampeak,srate)), title);
        %             return
        %         end
        if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
            fprintf('\nFractional Peak Frequency measurement in progress...\n');
        else
            fprintf('\nFractional Peak Latency measurement in progress...\n');
        end
    case 6  % inte/area value (fixed latencies)
        %         if nlate~=2
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define two frequencies';
        %             else
        %                 msgboxText =  'You must define two latencies';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
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
        %         if nlate~=1
        %             %if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %             %        msgboxText =  'You must define only one frequency';
        %             %else
        %             msgboxText =  'You must define only one latency';
        %             %end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
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
        %         if nlate~=2
        %             if strcmpi(datatype, 'TFFT') || strcmpi(datatype, 'EFFT') % Hz
        %                 msgboxText =  'You must define two frequencies';
        %             else
        %                 msgboxText =  'You must define two latencies';
        %             end
        %             title = 'ERPLAB: measurement window';
        %             errorfound(sprintf(msgboxText), title);
        %             return
        %         end
        
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


dig    = get(handles.popupmenu_precision, 'Value');
binlabop  = get(handles.checkbox_binlabel,'Value'); % bin label option for table
inclate   = get(handles.checkbox_include_used_latencies, 'Value');
intfactor = get(handles.popupmenu_interpofactor, 'Value');

peakonset = get(handles.popupmenu_rise, 'Value');  % axs - get onset from menu value

%
% Output
%
outstr = {moption, dig, binlabop, polpeak, sampeak, locpeakrep, frac, fracmearep,...
    send2ws, inclate, intfactor, peakonset};
handles.output = outstr;

guidata(hObject, handles);
uiresume(handles.gui_chassis);


%--------------------------------------------------------------------------
function popupmenu_precision_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_precision_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% -------------------------------------------------------------------------
function pushbutton_run_CreateFcn(hObject, eventdata, handles)



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
% formatout = get(handles.popupmenu_formatout,'Value');
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
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.text_punit,'String','% of peak')
        set(handles.text_tip_inputlat, 'String',['(use one ' meawordx 'y)']);
        set(handles.popupmenu_areatype,'Enable','off')
    case {2,6} % mean, area, integral between fixed latencies
        menupeakoff(hObject, eventdata, handles)
        menufareaoff(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.text_punit,'String','% of peak')
        set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
        if currentm==6
            set(handles.popupmenu_areatype,'Enable','on')
        else
            set(handles.popupmenu_areatype,'Enable','off')
        end
    case {3,4} % 'Peak amplitude', 'Peak latency'
        menupeakon(hObject, eventdata, handles)
        menufareaoff(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.text_punit,'String','% of peak')
        %         set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
        set(handles.popupmenu_areatype,'Enable','off')
        set(handles.popupmenu_fracreplacement, 'String', {'fractional absolute peak','"not a number" (NaN)'});
    case 5 % 'Fractional Peak latency'
        menupeakon(hObject, eventdata, handles)
        menufareaon(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        fracpos = round(frac*100)+1;
        set(handles.popupmenu_fraca,'Value', fracpos)
        set(handles.text_punit,'String','% of peak')
        %         set(handles.text_tip_inputlat, 'String',['(use two ' meawordx 'ies)']);
        set(handles.text_fraca,'String', 'Fractional Peak');
        set(handles.popupmenu_areatype,'Enable','off');
        set(handles.popupmenu_fracreplacement, 'String', {'"not a number" (NaN)','show error message'});
    case {7} % area, integral automatic limits
        menupeakoff(hObject, eventdata, handles)
        menufareaoff(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', '--------')
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.popupmenu_rise, 'Enable', 'off')
        set(handles.text_punit,'String','% of area')
        %         set(handles.text_tip_inputlat, 'String',['(use one "seed" ' meawordx 'y)']);
        if currentm==7
            set(handles.popupmenu_areatype,'Enable','on')
        else
            set(handles.popupmenu_areatype,'Enable','off')
        end
    case 8 % 'Fractional Area latency'
        menupeakoff(hObject, eventdata, handles)
        menufareaon(hObject, eventdata, handles)
        %punit_str = get(handles.text_punit, 'String');
        set(handles.popupmenu_rise, 'String', '--------')
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.popupmenu_rise, 'Enable', 'off')
        set(handles.text_punit,'String','% of area')
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
function text_tip_inputlat_CreateFcn(hObject, eventdata, handles)

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
% function radiobutton_erpset_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
% function radiobutton_folders_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function setall(hObject, eventdata, handles)

% ALLERP   = handles.ALLERP;
% if isstruct(ALLERP)
%         nsets    = length(ALLERP);
%         nbin = ALLERP(1).nbin;
%         nchan = ALLERP(1).nchan;
% else
%         nsets = 0;
%         nbin  = 1;
%         nchan = 1;
% end
datatype = handles.datatype;
set(handles.popupmenu_samp_amp,'String',cellstr(num2str([0:40]')))
set(handles.popupmenu_precision,'String', num2str([1:6]'))
kktime = handles.kktime;



set(handles.popupmenu_rise,'BackgroundColor',[1 1 1])
set(handles.popupmenu_fraca,'BackgroundColor',[1 1 1])
set(handles.popupmenu_fracreplacement,'BackgroundColor',[1 1 1])
set(handles.popupmenu_locpeakreplacement,'BackgroundColor',[1 1 1])
set(handles.popupmenu_areatype,'BackgroundColor',[1 1 1])

set(handles.popupmenu_interpofactor,'BackgroundColor',[1 1 1])
set(handles.popupmenu_precision,'BackgroundColor',[1 1 1])


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
set(handles.popupmenu_measurement, 'String', measurearray,'Enable','off');
set(handles.popupmenu_locpeakreplacement, 'String', {'absolute peak','"not a number" (NaN)','show error message'});
set(handles.popupmenu_fracreplacement, 'String', {'closest value','"not a number" (NaN)','show error message'});


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
    op         = def{1};  % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
    dig        = def{2};  %Resolution
    binlabop   = def{3}; % 0: bin# as bin label for table, 1 bin label
    polpeak    = def{4}; % local peak polarity
    sampeak    = def{5}; % number of samples (one-side) for local peak detection criteria
    locpeakrep = def{6}; % 1 abs peak , 0 Nan
    frac       = def{7};
    fracmearep = def{8}; % def{19}; NaN
    send2ws    = def{9}; % 1 send to ws, 0 dont do
    inclate    = def{10};
    intfactor  = def{11};
    if isempty(sampeak)
        sampeak = 3;
    end
    
else
    
    %%def = {'fareaplat', 3, 0, 1, 3, 0, 0.5, NaN, 0, 0, 1, 1};
    op         = 'meanbl';  % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
    dig        = 3;  %Resolution
    binlabop   = 0; % 0: bin# as bin label for table, 1 bin label
    polpeak    = 1; % local peak polarity
    sampeak    = 3; % number of samples (one-side) for local peak detection criteria
    locpeakrep = 0; % 1 abs peak , 0 Nan
    frac       = 0.5;
    fracmearep = 0; % def{19}; NaN
    send2ws    = 0; % 1 send to ws, 0 dont do
    inclate    = 1;
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
% Type of output
%
% 1 = one measurement per line; 0 = one erpset per line
%
set(handles.checkbox_include_used_latencies, 'Value', inclate);

set(handles.checkbox_send2ws, 'Value', send2ws);
set(handles.checkbox_binlabel, 'Value', binlabop); %0: use bin number as binlabel; 1:use bin descr as binlabel

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
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.text_punit,'String','% of peak')
        set(handles.popupmenu_areatype,'Enable','off')
        %                 set(handles.text_tip_inputlat, 'String',['(use one ' mwordx 'y)']);
    case {2,6} % mean, area, integral between fixed latencies
        menupeakoff(hObject, eventdata, handles)
        menufareaoff(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.text_punit,'String','% of peak')
        if indxmea==6
            set(handles.popupmenu_areatype,'Value',areatype)
        end
        set(handles.popupmenu_areatype,'Enable','off')
        
    case {3,4} % 'Peak amplitude', 'Peak latency'
        menupeakon(hObject, eventdata, handles)
        menufareaoff(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.text_punit,'String','% of peak')
        %                 set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
        set(handles.popupmenu_pol_amp,'Value',2-polpeak,'Enable','off')
        %set(handles.popupmenu_samp_amp,'value',sampeak+1);
        set(handles.popupmenu_locpeakreplacement,'value',2-locpeakrep);
        set(handles.popupmenu_areatype,'Enable','off');
        %         set(handles.popupmenu_fracreplacement, 'String', {'fractional absolute peak','"not a number" (NaN)'});
    case 5     % 'Fractional Peak latency'
        menupeakon(hObject, eventdata, handles)
        menufareaon(hObject, eventdata, handles)
        set(handles.popupmenu_rise, 'String', {'(pre-peak) onset','(post-peak) offset'})
        set(handles.popupmenu_rise, 'Value', 1)
        fracpos = round(frac*100)+1;
        set(handles.popupmenu_fraca,'Value', fracpos)
        set(handles.text_punit,'String','% of peak')
        %         set(handles.text_tip_inputlat, 'String',['(use two ' mwordx 'ies)']);
        set(handles.text_fraca,'String', 'Fractional Peak')
        set(handles.popupmenu_pol_amp,'Value',2-polpeak,'Enable','off')
        %set(handles.popupmenu_samp_amp,'value',sampeak+1);
        set(handles.popupmenu_locpeakreplacement,'value',2-locpeakrep);
        set(handles.popupmenu_fracreplacement,'value',2-fracmearep);
        set(handles.popupmenu_areatype,'Enable','off');
        %         set(handles.popupmenu_fracreplacement, 'String', {'"not a number" (NaN)','show error message'});
        
        if strcmpi(fracmearep,'NaN')
            set(handles.popupmenu_fracreplacement, 'Value', 1);
        else
            set(handles.popupmenu_fracreplacement, 'Value', 2);
        end
    case 7     % area and integral with auto limits
        menupeakoff(hObject, eventdata, handles);
        menufareaoff(hObject, eventdata, handles);
        set(handles.popupmenu_rise, 'String', '--------');
        set(handles.popupmenu_rise, 'Value', 1);
        set(handles.popupmenu_rise, 'Enable', 'off');
        set(handles.popupmenu_areatype,'Enable','on');
        set(handles.popupmenu_areatype,'Value',areatype);
        
    case 8     % fractional area
        menupeakoff(hObject, eventdata, handles)
        menufareaon(hObject, eventdata, handles)
        fracpos = round(frac*100)+1;
        set(handles.popupmenu_rise, 'String', '--------')
        set(handles.popupmenu_rise, 'Value', 1)
        set(handles.popupmenu_rise, 'Enable', 'off')
        set(handles.text_punit,'String','% of area')
        set(handles.popupmenu_fraca,'Value', fracpos);
        
        
        set(handles.text_fa3,'Enable', 'on')
        set(handles.text_fraca,'String', 'Fractional Area')
        set(handles.popupmenu_areatype,'Enable','on')
        set(handles.popupmenu_areatype,'Value',areatype)
        set(handles.popupmenu_fracreplacement, 'String', {'show error message','"not a number" (NaN)'});
        if strcmpi(fracmearep,'NaN')
            set(handles.popupmenu_fracreplacement, 'Value', 2);
        else
            set(handles.popupmenu_fracreplacement, 'Value', 1);
        end
        
    otherwise
        menupeakoff(hObject, eventdata, handles)
        menufareaoff(hObject, eventdata, handles)
end

set(handles.popupmenu_precision, 'Value', dig)
set(handles.checkbox_send2ws, 'Value', send2ws);

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
erplab_studio_default_values;
version = erplabstudiover;
set(handles.gui_chassis,'Name', ['EStudio ' version '   -   ERP Measurement Tool > Type > Option'])
handles.frac = frac;


% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function gui_chassis_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_send2ws_Callback(hObject, eventdata, handles)



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
    %         set(handles.edit_label_mea,'Enable', 'on')
else
    set(hObject,'Value',1)
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
% function togglebutton_viewer_Callback(hObject, eventdata, handles)
% if get(hObject, 'Value')
%         pushbutton_run_Callback(hObject, eventdata, handles)
% end

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


% --- Executes during object creation, after setting all properties.
function checkbox_include_used_latencies_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_include_used_latencies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function checkbox_include_used_latencies_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_include_used_latencies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_include_used_latencies.
function checkbox_include_used_latencies_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_include_used_latencies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_include_used_latencies


% --- Executes on button press in checkbox_binlabel.
function checkbox_binlabel_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_binlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_binlabel
