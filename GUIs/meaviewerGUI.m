%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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

function varargout = meaviewerGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @meaviewerGUI_OpeningFcn, ...
        'gui_OutputFcn',  @meaviewerGUI_OutputFcn, ...
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

% --- Executes just before meaviewerGUI is made visible.
function meaviewerGUI_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for meaviewerGUI
handles.output = [];
defx   = erpworkingmemory('pop_geterpvalues');
% try
%         cerpi = evalin('base', 'CURRENTERP'); % current erp index
% catch
%         cerpi = 1;
% end
% handles.cerpi = cerpi;
try
        ALLERP = varargin{1};
catch
        ALLERP          = buildERPstruct;
        ALLERP.times    = -200:800;
        ALLERP.xmin     = -0.2;
        ALLERP.xmax     = 0.8;
        ALLERP.nchan    = 1;
        ALLERP.pnts     = length(ALLERP.times);
        ALLERP.nbin     = 1;
        ALLERP.bindata  = zeros(1, ALLERP.pnts, 1);
        ALLERP.srate    = 1000;
        ALLERP.bindescr = {'empty'};
        ALLERP.chanlocs.labels = 'empty';
end
% if strcmpi(datatype, 'ERP')
%     meaword = 'latenc';
% else
%     meaword = 'frequenc';
% end
if isempty(defx)
        if isempty(ALLERP)
                inp1   = 1; %from hard drive
                erpset = [];
        else
                inp1   = 0; %from erpset menu
                erpset = 1:length(ALLERP);
        end
        defx = {inp1 erpset '' 0 1 1 'instabl' 1 3 'pre' 0 1 5 0 0.5 0 0 0 '' 0 1};
end
try
        def         = varargin{2};
        AMP         = def{1};
        Lat         = def{2};
        binArray    = def{3};
        chanArray   = def{4};
        setArray    = def{5};
        latency     = def{6};
        moreoptions = def{7};
        
        blc        = moreoptions{1};
        moption    = moreoptions{2};
        tittle     = moreoptions{3};
        dig        = moreoptions{4};
        coi        = moreoptions{5};
        polpeak    = moreoptions{6};
        sampeak    = moreoptions{7};
        locpeakrep = moreoptions{8};
        frac       = moreoptions{9};
        fracmearep = moreoptions{10};
        intfactor  = moreoptions{11};
catch
        latency    = defx{4};
        moption    = defx{7};
        
        AMP        = [];
        Lat        = {{[-200 800]}};
        binArray   = 1:ALLERP(1).nbin;
        chanArray  = 1:ALLERP(1).nchan;
        setArray   = 1:length(ALLERP);
        %latency    = 0;
        blc        = 'pre';
        %moption    = 'instabl';
        tittle     = 'nada';
        dig        = 3;
        coi        = [];
        polpeak    = [];
        sampeak    = [];
        locpeakrep = [];
        frac       = [];
        fracmearep = [];
        intfactor  = 1;
end
if isfield(ALLERP(setArray(1)), 'datatype')
        datatype = ALLERP(setArray(1)).datatype;
else
        datatype = 'ERP';
end
if ~isempty(moption) && strcmpi(moption, 'instabl')
        if strcmpi(datatype, 'ERP')
                set(handles.checkbox_dmouse, 'String', 'Adjust measurement time by clicking with the mouse on the desired latency.')
        else
                set(handles.checkbox_dmouse, 'String', 'Adjust measurement frequency by clicking with the mouse on the desired frequency.')
        end
else
        set(handles.checkbox_dmouse, 'String', 'Adjust measurement window with the mouse by click, hold, drag and release')
end
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
        blc        = 'none';
        measurearray = {'Instantaneous power',...
                'Mean power between two fixed frequencies',...
                'Peak power',...
                'Peak frequency',...
                'Fractional Peak frequency',...
                'Numerical integration/Area between two fixed frequencies',...
                '---'...
                'Fractional Area frequency'};
end

handles.measurearray = measurearray;

meacodes    =      {'instabl', 'meanbl', 'peakampbl', 'peaklatbl', 'fpeaklat',...
        'areat', 'areap', 'arean','areazt','areazp','areazn','fareatlat',...
        'fareaplat','fninteglat','fareanlat', 'ninteg','nintegz' };

handles.meacodes    = meacodes;

set(handles.text_measurementv, 'String', measurearray);

[tfm, indxmeaX] = ismember_bc2({moption}, meacodes);

if ismember_bc2(indxmeaX,[6 7 8 16])
        meamenu = 6; %  'Numerical integration/Area between two fixed latencies',...
elseif ismember_bc2(indxmeaX,[9 10 11 17])
        if strcmpi(datatype, 'ERP')
                meamenu = 7; %  'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
        else
                meamenu = 1; % 'Instantaneous amplitude',...
        end
elseif ismember_bc2(indxmeaX,[12 13 14 15])
        meamenu = 8; %  'Fractional Area latency'
elseif ismember_bc2(indxmeaX,1)
        meamenu = 1; % 'Instantaneous amplitude',...
elseif ismember_bc2(indxmeaX,2)
        meamenu = 2; % 'mean amp
elseif ismember_bc2(indxmeaX,3)
        meamenu = 3; % 'peak amp',...
elseif ismember_bc2(indxmeaX,4)
        meamenu = 4; % 'peak lat',...
elseif ismember_bc2(indxmeaX,5)
        meamenu = 5; % 'Fractional Peak latency',..',...
else
        meamenu = 1; % 'Instantaneous amplitude',...
end

set(handles.text_measurementv, 'String', measurearray{meamenu});
% set(handles.text_measurementv, 'Value', meamenu);
% set(handles.text_measurementv, 'Enable', 'inactive');

cwm = erpworkingmemory('WMColor'); % window color for measurement
cvl = erpworkingmemory('VLColor'); % line color for measurement
mwm = erpworkingmemory('WMmouse'); % select window measurement by mouse option

if isempty(cwm)
        cwm = [0.8490    1.0000    0.1510];
end
if isempty(cvl)
        cvl = [1 0 0];
end
if isempty(mwm)
        mwm = 0;
end

handles.defx       = defx;
handles.cwm        = cwm;
handles.cvl        = cvl;
handles.ALLERP     = ALLERP;
handles.binArray   = binArray;
handles.chanArray  = chanArray;
handles.setArray   = setArray;
handles.ich        = 1;
handles.ibin       = 1;
handles.iset       = 1;
handles.orilatency = latency;
handles.blc        = blc;
handles.moption    = moption;
handles.tittle     = tittle;
handles.dig        = dig;
handles.coi        = coi;
handles.polpeak    = polpeak;
handles.sampeak    = sampeak;
handles.locpeakrep = locpeakrep;
handles.frac       = frac;
handles.fracmearep = fracmearep;
handles.intfactor  = intfactor;
handles.x1         = -1.75;
handles.x2         = 1.75;

%
% create random x-values for scatter plot
%
xscatt = rand(1,numel(AMP))*2.5-1.25;
handles.xscatt = xscatt;
indxsetstr     = {''};
% end
handles.indxsetstr = indxsetstr;

% handles.membin     = [];
% handles.memch      = [];
% handles.memset     = [];

binvalue  = erpworkingmemory('BinHisto');    % value(s) for bin in histogram
normhisto = erpworkingmemory('NormHisto');   % normalize histogram
chisto    = erpworkingmemory('HistoColor');  % histogram color
cfitnorm  = erpworkingmemory('FnormColor');  % line color for fitted normal distribution
fitnormd  = erpworkingmemory('FitNormd');    % fit nomal distribution

if isempty(binvalue)
        binvalue = 'auto';
end
if isempty(normhisto)
        normhisto = 0;
end
if isempty(chisto)
        chisto = [1 0.5 0.2];
end
if isempty(cfitnorm)
        cfitnorm = [1 0 0];
end
if isempty(fitnormd)
        fitnormd = 0;
end

handles.binvalue  = binvalue;
handles.normhisto = normhisto;
handles.chisto    = chisto;
handles.cfitnorm  = cfitnorm;
handles.fitnormd  = fitnormd;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   VIEWER FOR MEASUREMENTS GUI']); %, 'toolbar','figure')

ibin  = 1;
ich   = 1;
iset  = 1;
times = ALLERP(setArray(1)).times;
if strcmpi(datatype, 'ERP')
        xlim  = [min(times) max(times)];
        ylim  = [-20 20];
        enablepolabutt = 'on';
else
        xlim  = [0 30];
        ylim  = [0 15];
        enablepolabutt = 'off';
end

set(handles.edit_ylim, 'String', num2str(ylim))
set(handles.edit_xlim, 'String', sprintf('%g %g', round(xlim)))
set(handles.edit_bin, 'String', num2str(ibin))
set(handles.edit_channel, 'String', num2str(ich))
set(handles.edit_file, 'String', num2str(iset))
frdm = erpworkingmemory('freedom');
if isempty(frdm);frdm=0;end
if frdm==0 %JLC
        set(handles.edit_bin, 'Enable', 'inactive')
        set(handles.edit_channel, 'Enable', 'inactive')
        set(handles.edit_file, 'Enable', 'inactive')
end
handles.frdm = frdm;
word = 'positive';
set(handles.togglebutton_y_axis_polarity, 'String', sprintf('<HTML><center><b>%s</b> is up', word));
set(handles.togglebutton_y_axis_polarity, 'Enable', enablepolabutt);
handles.ydir = 'normal';
set(handles.checkbox_butterflybin,'Value', 0)
set(handles.checkbox_butterflychan,'Value', 0)
set(handles.checkbox_butterflyset,'Value', 0)
if length(binArray)==1
        set(handles.checkbox_butterflybin, 'Enable', 'off')
        if frdm; set(handles.edit_bin, 'Enable', 'off');end
        set(handles.pushbutton_right_bin, 'Enable', 'off')
        set(handles.pushbutton_left_bin, 'Enable', 'off')
end
if length(chanArray)==1
        set(handles.checkbox_butterflychan, 'Enable', 'off')
        if frdm; set(handles.edit_channel, 'Enable', 'off');end
        set(handles.pushbutton_right_channel, 'Enable', 'off')
        set(handles.pushbutton_left_channel, 'Enable', 'off')
end
if length(setArray)==1
        set(handles.checkbox_butterflyset, 'Enable', 'off')
        if frdm; set(handles.edit_file, 'Enable', 'off');end
        set(handles.pushbutton_right_file, 'Enable', 'off')
        set(handles.pushbutton_left_file, 'Enable', 'off')
end
handles.datatype = datatype;

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);


% help
% helpbutton

%
% Drag
%
set(handles.checkbox_dmouse,'Value', 0)
set(handles.radiobutton_histo,'Value', 0)
set(handles.radiobutton_histo,'Enable', 'off')
set(handles.pushbutton_histosetting,'Enable', 'off')
set(handles.radiobutton_scatter,'Value', 0)
set(handles.radiobutton_scatter,'Enable', 'off')
set(handles.checkbox_fileindx,'Value', 0)
set(handles.checkbox_fileindx,'Enable', 'off')
set(handles.checkbox_scatterlabels, 'Value',0)
set(handles.checkbox_scatterlabels, 'Enable', 'off')
set(handles.pushbutton_narrow, 'Enable', 'off')
set(handles.pushbutton_wide, 'Enable', 'off')
set(handles.checkbox_3sigma, 'Value',0)
set(handles.checkbox_3sigma, 'Enable', 'off')
% set(handles.togglebutton_y_axis_polarity, 'Enable', 'on');
set(handles.gui_chassis,'DoubleBuffer','on')

if isempty(AMP)
        [ AMP, Lat, latency ] = getnewvals(hObject, handles, latency);
        handles.AMP        = AMP;
        handles.Lat        = Lat;
        handles.latency    = latency;
else
        handles.AMP        = AMP;
        handles.Lat        = Lat;
        handles.latency    = latency;
        
end
% Update handles structure
guidata(hObject, handles);

%
% Plot figure
%
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% UIWAIT makes meaviewerGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

% --- Outputs from this function are returned to the command line.
function varargout = meaviewerGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------
function pushbutton_left_bin_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ibin   = ibin-1;

if ibin<1
        return; %ibin = 1;
end
handles.ibin  = ibin;

% Update handles structure
guidata(hObject, handles);

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)



% -------------------------------------------------------------------------
function pushbutton_right_bin_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
binArray  = handles.binArray;
ich    = handles.ich;
ibin   = handles.ibin; % pointer of bin
iset   = handles.iset;
ibin   = ibin+1;

if ibin>length(binArray)
        return; %ibin = length(binArray);
end
handles.ibin      = ibin;

% Update handles structure
guidata(hObject, handles);

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)



% -------------------------------------------------------------------------
function pushbutton_left_channel_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ich    = ich-1;

if ich<1
        return; %ich = 1;
end
handles.ich = ich;

% Update handles structure
guidata(hObject, handles);

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)


% -------------------------------------------------------------------------
function pushbutton_right_channel_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
chanArray = handles.chanArray;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ich    = ich+1;

if ich>length(chanArray)
        return; %ich = length(chanArray);
end
handles.ich = ich;

% Update handles structure
guidata(hObject, handles);

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)


% -------------------------------------------------------------------------
function pushbutton_left_file_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
iset   = iset-1;

if iset<1
        return; %iset = 1;
end
handles.iset = iset;

% Update handles structure
guidata(hObject, handles);

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)


% -------------------------------------------------------------------------
function pushbutton_right_file_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
setArray = handles.setArray;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
iset   = iset+1;

if iset>length(setArray)
        return; %iset = length(setArray);
end
handles.iset      = iset;

% Update handles structure
guidata(hObject, handles);

ylim = str2num(get(handles.edit_ylim, 'String' ));
xlim = str2num(get(handles.edit_xlim, 'String' ));
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)


% -------------------------------------------------------------------------
function checknan(handles, val)
if any(isnan(val))
        cvl    = handles.cvl;
        ylim   = str2num(get(handles.edit_ylim, 'String' ));
        xlim   = str2num(get(handles.edit_xlim, 'String' ));
        set(handles.edit_report, 'BackgroundColor', 'r')
        line([xlim(1) xlim(2)], [ylim(2) ylim(1)], 'Color', cvl) % JLC. Feb 13, 2013
        line([xlim(1) xlim(2)], [ylim(1) ylim(2)], 'Color', cvl) % JLC. Feb 13, 2013
else
        set(handles.edit_report, 'BackgroundColor', 'w')
end

% -------------------------------------------------------------------------
function pushbutton_gotomea_Callback(hObject, eventdata, handles)
if get(handles.checkbox_dmouse, 'Value')
        latency = handles.latency;
        handles.output = {1 latency};
        
        defx = handles.defx;
        defx{4} = latency;
        
        erpworkingmemory('pop_geterpvalues', defx);
        
else
        handles.output = {1 []};
end

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------
function pushbutton6_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_xlim_Callback(hObject, eventdata, handles)

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if length(xlim)~=2 || length(ylim)~=2 || any(isnan(xlim)) || any(isnan(ylim)) || any(isinf(xlim)) || any(isinf(ylim)) || xlim(1)>=xlim(2) || ylim(1)>=ylim(2)
        msgboxText =  'Invalid scale!\n You must enter 2 numeric values on each range.\tThe first one must be lower than the second one.';
        title = 'ERPLAB: meaviewerGUI, invalid baseline input';
        errorfound(sprintf(msgboxText), title);
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function edit_xlim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_ylim_Callback(hObject, eventdata, handles)

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if length(xlim)~=2 || length(ylim)~=2 || any(isnan(xlim)) || any(isnan(ylim)) || any(isinf(xlim)) || any(isinf(ylim)) || xlim(1)>=xlim(2) || ylim(1)>=ylim(2)
        msgboxText =  'Invalid scale!\n You must enter 2 numeric values on each range.\tThe first one must be lower than the second one.';
        title = 'ERPLAB: meaviewerGUI, invalid baseline input';
        errorfound(sprintf(msgboxText), title);
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function edit_ylim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function pushbutton_update_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if length(xlim)~=2 || length(ylim)~=2 || any(isnan(xlim)) || any(isnan(ylim)) || any(isinf(xlim)) || any(isinf(ylim)) || xlim(1)>=xlim(2) || ylim(1)>=ylim(2)
        msgboxText =  'Invalid scale!\n You must enter 2 numeric values on each range.\tThe first one must be lower than the second one.';
        title = 'ERPLAB: meaviewerGUI, invalid baseline input';
        errorfound(sprintf(msgboxText), title);
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function checkbox_butterflychan_Callback(hObject, eventdata, handles)
chanArray = handles.chanArray;
if get(hObject, 'Value')
        set(handles.edit_channel, 'String', vect2colon(chanArray, 'Delimiter', 'off'))
        if handles.frdm; set(handles.edit_channel, 'Enable', 'off');end
        set(handles.pushbutton_right_channel, 'Enable', 'off')
        set(handles.pushbutton_left_channel, 'Enable', 'off')
        set(handles.radiobutton_histo,'Enable', 'on')
        set(handles.radiobutton_scatter,'Enable', 'on')
else
        if handles.frdm; set(handles.edit_channel, 'Enable', 'on');end
        %chanArray = handles.chanArray;
        chinput   = str2num(get(handles.edit_channel, 'String'));
        
        if length(chinput)>1 && ~handles.frdm
                chinput = chinput(1);
                [xxx, ich] = closest(chanArray, chinput);
                handles.ich=ich;
                set(handles.edit_channel, 'String', num2str(chinput))
        end
        if length(chinput)<=1
                set(handles.pushbutton_right_channel, 'Enable', 'on')
                set(handles.pushbutton_left_channel, 'Enable', 'on')
        else
                set(handles.pushbutton_right_channel, 'Enable', 'off')
                set(handles.pushbutton_left_channel, 'Enable', 'off')
        end
        if  ~get(handles.checkbox_butterflybin, 'Value') && ~get(handles.checkbox_butterflychan, 'Value') && ~get(handles.checkbox_butterflyset, 'Value') % none checked
                set(handles.radiobutton_histo,'Value', 0)
                set(handles.radiobutton_histo,'Enable', 'off')
                set(handles.pushbutton_histosetting,'Enable', 'off')
                set(handles.radiobutton_scatter,'Value', 0)
                set(handles.radiobutton_scatter,'Enable', 'off')
                set(handles.checkbox_scatterlabels, 'Value',0)
                set(handles.checkbox_scatterlabels, 'Enable', 'off')
                set(handles.checkbox_3sigma, 'Value',0)
                set(handles.checkbox_3sigma, 'Enable', 'off')
                set(handles.checkbox_dmouse,'Enable', 'on')
        end
end
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function checkbox_butterflybin_Callback(hObject, eventdata, handles)
binArray = handles.binArray;
if get(hObject, 'Value')
        set(handles.edit_bin, 'String', vect2colon(binArray, 'Delimiter', 'off'))
        if handles.frdm; set(handles.edit_bin, 'Enable', 'off');end
        set(handles.pushbutton_right_bin, 'Enable', 'off')
        set(handles.pushbutton_left_bin, 'Enable', 'off')
        set(handles.radiobutton_histo,'Enable', 'on')
        %set(handles.pushbutton_histosetting,'Enable', 'on')
        set(handles.radiobutton_scatter,'Enable', 'on')
else
        if handles.frdm; set(handles.edit_bin, 'Enable', 'on');end
        bininput   = str2num(get(handles.edit_bin, 'String'));
        if length(bininput)>1 && ~handles.frdm
                bininput = bininput(1);
                [xxx, ibin] = closest(binArray, bininput);
                handles.ibin=ibin;
                set(handles.edit_bin, 'String', num2str(bininput))
                % Update handles structure
                guidata(hObject, handles);
        end
        if length(bininput)<=1
                set(handles.pushbutton_right_bin, 'Enable', 'on')
                set(handles.pushbutton_left_bin, 'Enable', 'on')
        else
                set(handles.pushbutton_right_bin, 'Enable', 'off')
                set(handles.pushbutton_left_bin, 'Enable', 'off')
        end
        if  ~get(handles.checkbox_butterflybin, 'Value') && ~get(handles.checkbox_butterflychan, 'Value') && ~get(handles.checkbox_butterflyset, 'Value') % none checked
                set(handles.radiobutton_histo,'Value', 0)
                set(handles.radiobutton_histo,'Enable', 'off')
                set(handles.pushbutton_histosetting,'Enable', 'off')
                set(handles.radiobutton_scatter,'Value', 0)
                set(handles.radiobutton_scatter,'Enable', 'off')
                set(handles.checkbox_scatterlabels, 'Value',0)
                set(handles.checkbox_scatterlabels, 'Enable', 'off')
                set(handles.checkbox_3sigma, 'Value',0)
                set(handles.checkbox_3sigma, 'Enable', 'off')
                set(handles.checkbox_dmouse,'Enable', 'on')
        end
end
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function checkbox_butterflyset_Callback(hObject, eventdata, handles)
setArray = handles.setArray;
if get(hObject, 'Value')
        set(handles.edit_file, 'String', vect2colon(setArray, 'Delimiter', 'off'))
        if handles.frdm; set(handles.edit_file, 'Enable', 'off');end
        set(handles.pushbutton_right_file, 'Enable', 'off')
        set(handles.pushbutton_left_file, 'Enable', 'off')
        set(handles.radiobutton_histo,'Enable', 'on')
        set(handles.radiobutton_scatter,'Enable', 'on')
        
        if get(handles.radiobutton_scatter, 'Value')
                set(handles.checkbox_fileindx,'Enable', 'on')
                set(handles.checkbox_scatterlabels, 'Enable', 'on')
                set(handles.pushbutton_narrow, 'Enable', 'on')
                set(handles.pushbutton_wide, 'Enable', 'on')
                set(handles.checkbox_3sigma, 'Enable', 'on')
        else
                set(handles.checkbox_fileindx,'Enable', 'off')
                set(handles.pushbutton_narrow, 'Enable', 'off')
                set(handles.pushbutton_wide, 'Enable', 'off')
        end
else
        if handles.frdm; set(handles.edit_file, 'Enable', 'on');end
        setinput  = str2num(get(handles.edit_file, 'String'));
        if length(setinput)>1 && ~handles.frdm
                setinput = setinput(1);
                [xxx, iset] = closest(setArray, setinput);
                handles.iset=iset;
                set(handles.edit_file, 'String', num2str(setinput))
        end
        if length(setinput)<=1
                set(handles.pushbutton_right_file, 'Enable', 'on')
                set(handles.pushbutton_left_file, 'Enable', 'on')
        else
                set(handles.pushbutton_right_file, 'Enable', 'off')
                set(handles.pushbutton_left_file, 'Enable', 'off')
        end
        if  ~get(handles.checkbox_butterflybin, 'Value') && ~get(handles.checkbox_butterflychan, 'Value') && ~get(handles.checkbox_butterflyset, 'Value') % none checked
                set(handles.radiobutton_histo,'Value', 0)
                set(handles.radiobutton_histo,'Enable', 'off')
                set(handles.pushbutton_histosetting,'Enable', 'off')
                set(handles.radiobutton_scatter,'Value', 0)
                set(handles.radiobutton_scatter,'Enable', 'off')
                set(handles.checkbox_scatterlabels, 'Value',0)
                set(handles.checkbox_scatterlabels, 'Enable', 'off')
                set(handles.checkbox_3sigma, 'Value',0)
                set(handles.checkbox_3sigma, 'Enable', 'off')
                set(handles.checkbox_dmouse,'Enable', 'on')
                set(handles.pushbutton_narrow, 'Enable', 'off')
                set(handles.pushbutton_wide, 'Enable', 'off')
        end
        set(handles.checkbox_fileindx,'Value', 0)
        set(handles.checkbox_fileindx,'Enable', 'off')
end

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function semibutterflychan(hObject, eventdata, handles)

chanArray = handles.chanArray;
chinput   = str2num(get(handles.edit_channel, 'String'));

if length(chinput)<=1
        return
end
chinput = chinput(ismember_bc2(chinput, chanArray));


% [c, ich] = closest(chanArray, chinput);
% handles.ich       = ich;
%
% % Update handles structure
% guidata(hObject, handles);

set(handles.edit_channel, 'String', vect2colon(chinput, 'Delimiter', 'off'))
% set(handles.edit_channel, 'Enable', 'off')
set(handles.pushbutton_right_channel, 'Enable', 'off')
set(handles.pushbutton_left_channel, 'Enable', 'off')
set(handles.radiobutton_histo,'Enable', 'on')
set(handles.radiobutton_scatter,'Enable', 'on')

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function semibutterflybin(hObject, eventdata, handles)

binArray = handles.binArray;
bininput   = str2num(get(handles.edit_bin, 'String'));

if length(bininput)<=1
        return
end
bininput = bininput(ismember_bc2(bininput, binArray));


% [c, ich] = closest(chanArray, chinput);
% handles.ich       = ich;
%
% % Update handles structure
% guidata(hObject, handles);

set(handles.edit_bin, 'String', vect2colon(bininput, 'Delimiter', 'off'))
% set(handles.edit_channel, 'Enable', 'off')
set(handles.pushbutton_right_bin, 'Enable', 'off')
set(handles.pushbutton_left_bin, 'Enable', 'off')
set(handles.radiobutton_histo,'Enable', 'on')
set(handles.radiobutton_scatter,'Enable', 'on')

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function semibutterflyfile(hObject, eventdata, handles)

setArray = handles.setArray;
setinput   = str2num(get(handles.edit_file, 'String'));

if length(setinput)<=1
        return
end
setinput = setinput(ismember_bc2(setinput, setArray));


% [c, ich] = closest(chanArray, chinput);
% handles.ich       = ich;
%
% % Update handles structure
% guidata(hObject, handles);

set(handles.edit_file, 'String', vect2colon(setinput, 'Delimiter', 'off'))
% set(handles.edit_channel, 'Enable', 'off')
set(handles.pushbutton_right_file, 'Enable', 'off')
set(handles.pushbutton_left_file, 'Enable', 'off')
set(handles.radiobutton_histo,'Enable', 'on')
set(handles.radiobutton_scatter,'Enable', 'on')

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function edit_bin_Callback(hObject, eventdata, handles)
bin       = str2num(get(handles.edit_bin, 'String'));
if length(bin)>1
        semibutterflybin(hObject, eventdata, handles)
        return
else
        set(handles.pushbutton_right_bin, 'Enable', 'on')
        set(handles.pushbutton_left_bin, 'Enable', 'on')
        %set(handles.radiobutton_histo,'Enable', 'off')
        %set(handles.radiobutton_scatter,'Enable', 'off')
end

binArray  = handles.binArray;
[c, ibin] = closest(binArray, bin);
handles.ibin = ibin;

% Update handles structure
guidata(hObject, handles);

set(handles.edit_bin, 'String', num2str(ibin))

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
iset   = handles.iset;
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% -------------------------------------------------------------------------
function edit_bin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_channel_Callback(hObject, eventdata, handles)
chan       = str2num(get(handles.edit_channel, 'String'));
if length(chan)>1
        semibutterflychan(hObject, eventdata, handles)
        return
else
        set(handles.pushbutton_right_channel, 'Enable', 'on')
        set(handles.pushbutton_left_channel, 'Enable', 'on')
        %set(handles.radiobutton_histo,'Enable', 'off')
        %set(handles.radiobutton_scatter,'Enable', 'off')
end

chanArray  = handles.chanArray;
[c, ich] = closest(chanArray, chan);
handles.ich       = ich;

% Update handles structure
guidata(hObject, handles);

set(handles.edit_channel, 'String', num2str(ich))
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)
% -------------------------------------------------------------------------
function edit_channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_file_Callback(hObject, eventdata, handles)
setx      = str2num(get(handles.edit_file, 'String'));
if length(setx)>1
        semibutterflyfile(hObject, eventdata, handles)
        return
else
        set(handles.pushbutton_right_file, 'Enable', 'on')
        set(handles.pushbutton_left_file, 'Enable', 'on')
        %set(handles.radiobutton_histo,'Enable', 'off')
        %set(handles.radiobutton_scatter,'Enable', 'off')
end
if isempty(setx)
        if strcmpi(get(handles.edit_file, 'String'), 'all')
                set(handles.checkbox_butterflyset, 'Value', 1)
                if handles.frdm; set(handles.edit_file, 'Enable', 'off');end
                set(handles.pushbutton_right_file, 'Enable', 'off')
                set(handles.pushbutton_left_file, 'Enable', 'off')
                iset = handles.iset;
        else
                setArray = handles.setArray;
                iset = handles.iset;
                msgboxText =  'Invalid input';
                title = 'ERPLAB: meaviewerGUI';
                errorfound(sprintf(msgboxText), title);
                set(handles.edit_file, 'String', num2str(setArray(iset)))
                set(handles.checkbox_butterflyset, 'Value', 0)
                return
        end
else
        setArray  = handles.setArray;
        [c, iset] = closest(setArray, setx);
        handles.iset      = iset;
        
        % Update handles structure
        guidata(hObject, handles);
        set(handles.edit_file, 'String', num2str(iset))
end

tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)
% -------------------------------------------------------------------------
function edit_file_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function edit_report_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function edit_report_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_color_window_Callback(hObject, eventdata, handles)
cwm = handles.cwm;
cwm = uisetcolor(cwm,'Window color') ;
erpworkingmemory('WMColor', cwm);
handles.cwm = cwm;
% Update handles structure
guidata(hObject, handles);
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));
if isempty(xlim) || isempty(ylim)
        return
end
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function pushbutton_color_val_Callback(hObject, eventdata, handles)
cvl = handles.cvl;
cvl = uisetcolor( cvl,'Value line color') ;
erpworkingmemory('VLColor', cvl);
handles.cvl = cvl;
% Update handles structure
guidata(hObject, handles);
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

% PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
% PPPPPPPPPPPPPPPPPPPPPPPPPPP   PLOT  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
% PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
function mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)
% nhisto    = 10; % temporary
ydir      = handles.ydir;
binArray  = handles.binArray;
chanArray = handles.chanArray;
setArray  = handles.setArray;

binput   = [];
chinput  = [];
setinput = [];

if get(handles.checkbox_butterflybin, 'Value')
        jbin = binArray;
else
        binput = str2num(get(handles.edit_bin, 'String'));
        
        if length(binput)>1
                jbin = binput;
        else
                jbin = binArray(ibin)  ;
        end
end
if get(handles.checkbox_butterflychan, 'Value')
        jchannel = chanArray;
else
        chinput = str2num(get(handles.edit_channel, 'String'));
        
        if length(chinput)>1
                jchannel = chinput;
        else
                jchannel = chanArray(ich);
        end
end
if get(handles.checkbox_butterflyset, 'Value')
        jseta      = setArray;
else
        setinput = str2num(get(handles.edit_file, 'String'));
        
        if length(setinput)>1
                jseta = setinput;
        else
                jseta      = setArray(iset);
        end
end

nvalue = length(jbin)*length(jchannel)*length(jseta);

if nvalue>1
        set(handles.uipanel_distplots, 'Title', sprintf('Distribution Plots (N=%g)', nvalue));
else
        set(handles.uipanel_distplots, 'Title', 'Distribution Plots');
end

ALLERP    = handles.ALLERP;
AMP       = handles.AMP;
Lat       = handles.Lat;
latency   = handles.latency;
truelat   = latency;
blc       = handles.blc;
meacodes  = handles.meacodes;
moption   = handles.moption;
mearea    = { 'areat', 'areap', 'arean','areazt','areazp','areazn', 'ninteg','nintegz'};
dig       = handles.dig;
times     = ALLERP(setArray(1)).times;
intfactor = handles.intfactor;
pnts    = ALLERP(setArray(1)).pnts;
timeor  = ALLERP(setArray(1)).times; % original time vector
p1      = timeor(1);
p2      = timeor(end);

if intfactor~=1
        timex = linspace(p1,p2,round(pnts*intfactor));
else
        timex = timeor;
end

%
% Colors
%
cwm = handles.cwm;
cvl = handles.cvl;
% fctr = length(jseta)*length(jchannel)*length(jbin);
iptch  = 1;
lt     = 1;
latmin = zeros(1, length(jbin)*length(jchannel)*length(jseta));
latmax = zeros(1, length(jbin)*length(jchannel)*length(jseta));
axes(handles.axes1);
fntsz = get(handles.edit_report, 'FontSize');
set(handles.edit_report, 'FontSize', fntsz*1.5 )
set(handles.edit_report, 'String', sprintf('\nWorking...\n'))
drawnow
% tic
for seta = jseta
        kset = find(setArray==seta,1);
        for channel = jchannel
                kch  = find(chanArray==channel,1);
                for bin = jbin
                        kbin = find(binArray==bin,1);
                        lat4mea   = Lat{1, 1, kset}; % kset is ok
                        lat4mea   = lat4mea{kbin, kch};
                        val(iptch)= AMP(kbin, kch, kset); % kbin, kch, kset are ok
                        indxsetstr{iptch} = num2str(seta); % stores set index
                        
                        %
                        % get data
                        %
                        data   = ALLERP(seta).bindata(channel, :, bin);
                        
                        if intfactor~=1
                                data  = spline(timeor, data, timex); % re-sampled data
                        end
                        
                        %
                        % Baseline
                        %
                        blv    = blvalue2(data, timex, blc);
                        data   = data - blv;
                        
                        if ~get(handles.radiobutton_histo, 'Value') && ~get(handles.radiobutton_scatter, 'Value')
                                
                                %
                                % Plot
                                %
                                plot(timex, data, 'LineWidth', 1, 'Color', [0 0.1 0.5]);
                                
                                if  iptch==1
                                        axis([xlim ylim])
                                        set(handles.axes1,'ydir', ydir);
                                        hold on
                                end
                                
                                %
                                % Line for value
                                %
                                latetype = 0; % when lat is from measurement window
                                switch moption
                                        case 'instabl'
                                                line(xlim, [val(iptch) val(iptch) ], 'Color', cvl, 'LineStyle',':')
                                                line([latency(1)-(xlim(2)-xlim(1))*0.025 latency(1)+(xlim(2)-xlim(1))*0.025], [val(iptch)  val(iptch) ], 'Color', cvl)
                                        case {'meanbl', 'areat', 'areap', 'arean', 'ninteg'}
                                                line(xlim, [val(iptch)  val(iptch) ], 'Color', cvl, 'LineStyle',':')
                                                line([latency(1) latency(2)], [val(iptch)  val(iptch) ], 'Color', cvl)
                                        case {'areazt','areazp','areazn', 'nintegz'}
                                                line(xlim, [val(iptch)  val(iptch) ], 'Color', cvl, 'LineStyle',':')
                                                line([lat4mea(1) lat4mea(2)], [val(iptch)  val(iptch) ], 'Color', cvl)
                                                latetype = 1; % use true lat istead
                                                truelat  = lat4mea;
                                        case 'peakampbl'
                                                line(xlim, [val(iptch)  val(iptch) ], 'Color', cvl, 'LineStyle',':')
                                                line([lat4mea(1)-(xlim(2)-xlim(1))*0.025 lat4mea(1)+(xlim(2)-xlim(1))*0.025], [val(iptch)  val(iptch) ], 'Color', cvl)
                                                truelat = lat4mea;
                                        otherwise
                                end
                                
                                %
                                % Paint area
                                %
                                if ismember_bc2(moption, mearea)  || ismember_bc2(moption, {'fareatlat', 'fareaplat','fninteglat','fareanlat'})
                                        if latetype ==0
                                                latx = latency;
                                        else
                                                latx = lat4mea;
                                        end
                                        
                                        [xxx, latsamp] = closest(timex, latx);
                                        datax = data(latsamp(1):latsamp(2));
                                        
                                        if ismember_bc2(moption, {'areap', 'areazp', 'fareaplat'}) % positive area
                                                datax(datax<0) = 0;
                                                area(timex(latsamp(1):latsamp(2)), datax, 'FaceColor', 'b')
                                        elseif ismember_bc2(moption, {'arean', 'areazn', 'fareanlat'}) % negative area
                                                datax(datax>0) = 0;
                                                area(timex(latsamp(1):latsamp(2)), datax, 'FaceColor', 'r')
                                        elseif ismember_bc2(moption, {'ninteg','nintegz', 'fninteglat'}) % integration
                                                datatemp = datax;
                                                datatemp(datatemp<0) = 0;
                                                area(timex(latsamp(1):latsamp(2)), datatemp, 'FaceColor', 'b')
                                                datatemp = datax;
                                                datatemp(datatemp>0) = 0;
                                                area(timex(latsamp(1):latsamp(2)), datatemp, 'FaceColor', 'r')
                                        else
                                                area(timex(latsamp(1):latsamp(2)), datax, 'FaceColor', [0.2000 0.1 0])
                                        end
                                end
                                
                                %
                                % Line(s) for latency(ies) and window for measurement
                                %
                                if length(latency)==1
                                        if ismember_bc2(moption,  {'areazt','areazp','areazn', 'nintegz'})
                                                line([latency latency], ylim, 'Color', cvl)
                                                latmin(lt) = lat4mea(1);
                                                latmax(lt) = lat4mea(2);
                                                
                                                if (iptch==1 && length([jbin jchannel jseta])==3) || (iptch==length(jbin)*length(jchannel)*length(jseta) && length([jbin jchannel jseta])>3)
                                                        pp = patch([min(latmin) max(latmax) max(latmax) min(latmin)],[ylim(1) ylim(1) ylim(2) ylim(2)], cwm);
                                                        set(pp,'FaceAlpha',0.4, 'EdgeAlpha', 0.4, 'EdgeColor', cwm);
                                                end
                                                
                                                %
                                                % workaround (redraw axis)
                                                %
                                                line([0 0], ylim, 'Color', 'k')
                                                line(xlim, [0 0], 'Color', 'k')
                                                lt = lt + 1;
                                        else
                                                line([latency latency], ylim, 'Color', cvl)
                                        end
                                elseif length(latency)==2
                                        if iptch==1
                                                pp = patch([latency(1) latency(2) latency(2) latency(1)],[ylim(1) ylim(1) ylim(2) ylim(2)], cwm);
                                                set(pp,'FaceAlpha',0.4, 'EdgeAlpha', 0.4, 'EdgeColor', cwm);
                                        end
                                        if ismember_bc2(moption, {'peakampbl'})
                                                if length(lat4mea)~=1
                                                        %                       line([xlim(1) xlim(2)], [ylim(2) ylim(1)], 'Color', cvl) % JLC. Feb 13, 2013
                                                        %                       line([xlim(1) xlim(2)], [ylim(1) ylim(2)], 'Color', cvl) % JLC. Feb 13, 2013
                                                else
                                                        
                                                        %lat4mea
                                                        
                                                        
                                                        line([lat4mea lat4mea], ylim, 'Color', cvl)
                                                end
                                        elseif ismember_bc2(moption, {'peaklatbl', 'fareatlat', 'fareaplat','fninteglat','fareanlat'})
                                                
                                                %val(iptch)
                                                
                                                
                                                line([val(iptch)  val(iptch) ], ylim, 'Color', cvl)
                                                
                                                
                                                
                                        elseif ismember_bc2(moption,  {'fpeaklat'}) % fractional peak latency
                                                line([val(iptch)  val(iptch) ], ylim, 'Color', cvl) % fractional peak lat
                                                line([lat4mea lat4mea], ylim, 'Color', cvl,'LineStyle',':')  % peak lat
                                        end
                                end
                        end
                        iptch = iptch+1;
                end
        end
end

set(handles.edit_report, 'String', '')
set(handles.edit_report, 'FontSize', fntsz)

if any(isnan(val))
        iststrnan   = indxsetstr(isnan(val));
        nanindxfile = unique_bc2(str2num(char(iststrnan))');
else
        nanindxfile = [];
        iststrnan   = {[]};
end
if get(handles.radiobutton_histo, 'Value')
        if any(isnan(val))
                indxok  = find(~isnan(val));
                
                if isempty(indxok)
                        msgboxText = 'Unfortunately, you only got NaN values...';
                        title = 'ERPLAB: Error, only NaN values were found';
                        errorfound(msgboxText, title);
                        return
                end
                val     = val(indxok);
        end
        
        nhisto    = handles.binvalue;
        if ischar(nhisto) && strcmpi(nhisto,'auto')
                nhisto = round(sqrt(length(val)));
        elseif ischar(nhisto) && ~strcmpi(nhisto,'auto')
                msgboxText =  [nhisto ' is not a valid input.\n\n'...
                        'Enter a single value, a monotonically non-decreasing vector, or ''auto''.\n'...
                        'Or just click the "suggest" button.'];
                title = 'ERPLAB: meaviewerGUI, wrong inputs';
                errorfound(msgboxText, title);
                return
        end
        
        normhisto = handles.normhisto;
        chisto    = handles.chisto;
        fitnormd  = handles.fitnormd;
        cfitnorm  = handles.cfitnorm;
        [valhist, binhist] = hist(val, nhisto);
        areahisto = sum(valhist)*mean(diff(binhist));
        
        if normhisto
                val2plot  = valhist/areahisto;
                areahisto = 1; % for fitting a normalized pdf
        else
                val2plot = valhist;
        end
        if  length(val2plot)==1   && (isnan(val2plot) || isinf(val2plot)) && normhisto
                msgboxText = 'Oops! There are not enough measurement points to make a normalized histogram...';
                title = 'ERPLAB: meaviewerGUI, few inputs';
                errorfound(msgboxText, title);
                return
        elseif length(val2plot)==1 && (isnan(val2plot) || isinf(val2plot)) && ~normhisto
                msgboxText = 'Oops! There are not enough measurement points to make a histogram...';
                title = 'ERPLAB: meaviewerGUI, few inputs';
                errorfound(msgboxText, title);
                return
        elseif length(val2plot)==1  && ~isnan(val2plot) && ~isinf(val2plot)
                hview = bar(binhist, val2plot);
                axis([binhist-2 binhist+2 -0.15*min(val2plot) 1.15*max(val2plot)])
        else
                hview = bar(binhist, val2plot, 'hist');
                xh  = [min(binhist) max(binhist)];
                cxh = abs(diff(xh))/2;
                axis([xh(1)-cxh xh(2)+cxh -0.15*min(val2plot) 1.15*max(val2plot)])
        end
        
        set(hview,'FaceColor', chisto); %[1 0.5 0.2]
        
        if fitnormd %&& normhisto
                hold on
                mu = mean(val);
                sg = std(val);
                npnd = length(binhist)*10; % 10 time the number of histo's bins
                xnd    = linspace(mu-4*sg,mu+4*sg,npnd);
                pdfxnd = areahisto*(1/sqrt(2*pi)/sg*exp(-(xnd-mu).^2/(2*sg^2)));
                pfnorm = plot(xnd,pdfxnd);
                set(pfnorm,'Color',cfitnorm,'LineWidth',1)
                hold off
        end
elseif get(handles.radiobutton_scatter, 'Value') % JLC scatter plot
        chisto  = handles.chisto;
        xscatt  = handles.xscatt; % x-ccord for scatter plot
        if any(isnan(val))
                indxok  = find(~isnan(val));
                if isempty(indxok)
                        msgboxText = 'Unfortunately, you only got NaN values...'
                        title = 'ERPLAB: Error, only NaN values were found';
                        errorfound(msgboxText, title);
                        return
                end
                val     = val(indxok);
                xsct    = xscatt(indxok);
                iststr  = indxsetstr(indxok);
        else
                nv       = length(val);    % number of current values to plot
                xsct     = xscatt(1:nv);   % set indices for scatter plot current values
                iststr   = indxsetstr(1:nv);
        end
        
        mu     = mean(val);
        me     = median(val);
        
        x1 = handles.x1;
        x2 = handles.x2;
        y1 = mean(val) - std(val);
        y2 = mean(val) + std(val);
        y3 = mean(val) - 2*std(val);
        y4 = mean(val) + 2*std(val);
        y6 = mean(val) - 3*std(val);
        y7 = mean(val) + 3*std(val);
        cla
        try
                rectangle('Position',[x1,y1,x2-x1,abs(y2-y1)], 'EdgeColor', [0.5 0.5 0.5])
                rectangle('Position',[x1,y3,x2-x1,abs(y1-y3)], 'EdgeColor', [0.5 0.5 0.5])
                rectangle('Position',[x1,y2,x2-x1,abs(y4-y2)], 'EdgeColor', [0.5 0.5 0.5])
                if get(handles.checkbox_3sigma, 'Value')
                        rectangle('Position',[x1,y6,x2-x1,abs(y4-y6)], 'EdgeColor', [0.5 0.5 0.5])
                        rectangle('Position',[x1,y4,x2-x1,abs(y7-y4)], 'EdgeColor', [0.5 0.5 0.5])
                end
        catch
                set(handles.radiobutton_histo, 'Value', 0)
                return
        end
        if get(handles.checkbox_scatterlabels, 'Value')
                labfont = 10;
                text(x2+0.15,mu,'\mu','FontSize',labfont)
                text(x1-2,me,'median','FontSize',labfont)
                text(x2+0.15,y2,'\mu+\sigma','FontSize',labfont)
                text(x2+0.15,y4,'\mu+2\sigma','FontSize',labfont)
                text(x2+0.15,y1,'\mu-\sigma','FontSize',labfont)
                text(x2+0.15,y3,'\mu-2\sigma','FontSize',labfont)
                
                if get(handles.checkbox_3sigma, 'Value')
                        text(x2+0.15,y7,'\mu+3\sigma','FontSize',labfont)
                        text(x2+0.15,y6,'\mu-3\sigma','FontSize',labfont)
                end
        end
        
        line([x1 x2], [mu mu]) % mean in blue
        line([x1 x2], [me me], 'Color',[1 0 0], 'LineStyle', '--') % median in red
        hold on
        
        if get(handles.checkbox_3sigma, 'Value')
                ysc = [min([min(val) y6])-abs(0.15*max(val)) 1.15*max([max(val) y7])];
        else
                ysc = [min([min(val) y3])-abs(0.15*max(val)) 1.15*max([max(val) y4])];
        end
        if get(handles.checkbox_fileindx, 'Value') % identify file index
                isetfont = 10;
                plot(xsct, val, 'r.')
                text(xsct,val,iststr,'FontSize',isetfont)
        else
                plot(xsct, val, 'ro','MarkerEdgeColor','k', 'MarkerFaceColor',chisto,'MarkerSize',8);
        end
        
        axis([-10 10 ysc])
        set(gca,'XTick',[])
        hold off
else
        %
        % workaround (redraw axis)
        %
        line([0 0], ylim, 'Color', 'k')
        line(xlim, [0 0], 'Color', 'k')
        checknan(handles, val)
end
hold off
drawnow

nbinput   = length(binput);
nchinput  = length(chinput);
nsetinput = length(setinput);

if ~get(handles.checkbox_butterflybin, 'Value') && nbinput<=1
        set(handles.edit_bin, 'String', num2str(jbin))
        handles.ibin = ibin;
        % Update handles structure
        guidata(hObject, handles);
end
if ~get(handles.checkbox_butterflychan, 'Value') && nchinput<=1
        set(handles.edit_channel, 'String', num2str(jchannel))
        handles.ich = ich;
        % Update handles structure
        guidata(hObject, handles);
end
if ~get(handles.checkbox_butterflyset, 'Value') && nsetinput<=1
        set(handles.edit_file, 'String', num2str(jseta))
        handles.iset = iset;
        % Update handles structure
        guidata(hObject, handles);
end
%
% Files
%
setlabelx = '';
if get(handles.checkbox_butterflyset, 'Value')
        if length(setArray)>10
                var1 = vect2colon(setArray, 'Delimiter', 'off');
        else
                var1 = num2str(setArray);
        end
elseif nsetinput>0
        if nsetinput>10
                var1 = vect2colon(jseta, 'Delimiter', 'off');
        else
                var1 = num2str(jseta);
                if nsetinput==1
                        setlabelx = sprintf('(%s)', ALLERP(seta).erpname);
                end
        end
else
        var1 = ALLERP(seta).erpname;
end
%
% Bins
%
binlabelx = '';
if  get(handles.checkbox_butterflybin, 'Value')
        if length(binArray)>10
                var2 = vect2colon(binArray, 'Delimiter', 'off');
        else
                var2 = num2str(binArray);
        end
elseif nbinput>0
        if nbinput>10
                var2 = vect2colon(jbin, 'Delimiter', 'off');
        else
                var2 = num2str(jbin);
                if nbinput==1
                        binlabelx = sprintf('(%s)', ALLERP(seta).bindescr{bin});
                end
        end
else
        var2 = ALLERP(seta).bindescr{bin};
end

%
% Channels
%
chanlabelx = '';
if get(handles.checkbox_butterflychan, 'Value')
        if length(chanArray)>10
                var3 = vect2colon(chanArray, 'Delimiter', 'off');
        else
                var3 = num2str(chanArray);
        end
elseif nchinput>0
        if nchinput>10
                var3 = vect2colon(jchannel, 'Delimiter', 'off');
        else
                var3 = num2str(jchannel);
                if nchinput==1
                        chanlabelx = sprintf('(%s)', ALLERP(seta).chanlocs(channel).labels);
                end
        end
else
        var3 = ALLERP(seta).chanlocs(channel).labels;
end
if  ~get(handles.checkbox_butterflybin, 'Value') && ~get(handles.checkbox_butterflychan, 'Value') && ~get(handles.checkbox_butterflyset, 'Value') &&...
                nsetinput<=1 &&  nbinput<=1 && nchinput<=1
        % none checked
        strfrmt = ['File   : %s %s\nBin    : %s %s\nChannel: %s %s\nMeasu  : %s\nWindow : %s\nLate   : %s\nValue  : %.' num2str(dig) 'f\n'];
        values2print = {var1, setlabelx, var2, binlabelx, var3,  chanlabelx, tittle, sprintf('%.2f\t', latency), sprintf('%.2f\t', truelat), val};
else
        strfrmt = ['File   : %s %s\nBin    : %s %s\nChannel: %s %s\nMeasu  : %s\nWindow : %s\nLate   : %s\nMean Value  : %.' num2str(dig) 'f  +/- %.' num2str(dig) 'f\n'];
        values2print = {var1, setlabelx, var2, binlabelx, var3,  chanlabelx, tittle, sprintf('%.2f\t', latency), sprintf('%.2f\t', truelat), mean(val), std(val)};
end

repo = sprintf(strfrmt, values2print{:});
if ~isempty(nanindxfile) && length(jseta)>1
        repo = sprintf('%sNaN values found at files: %s', repo, num2str(nanindxfile));
end
set(handles.edit_report, 'String', repo)

%--------------------------------------------------------------------------
function togglebutton_y_axis_polarity_Callback(hObject, eventdata, handles)
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        set(hObject, 'string', sprintf('<HTML><center><b>%s</b> is up', 'positive'));
        set(hObject, 'Value', 1)
        return
end
if get(hObject, 'Value')
        word = 'negative';
        %set(handles.axes1,'ydir','reverse');
        handles.ydir = 'reverse';
else
        word = 'positive';
        %set(handles.axes1,'ydir','normal');
        handles.ydir = 'normal';
end
set(hObject, 'string', sprintf('<HTML><center><b>%s</b> is up', word));

%Update handles structure
guidata(hObject, handles);

if get(handles.checkbox_dmouse, 'Value') % trick
        set(handles.gui_chassis,'WindowButtonDownFcn', {@mbuttondwn, hObject, eventdata, handles});
end

tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function checkbox_dmouse_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        erpworkingmemory('WMmouse', 1);
        %
        % Drag
        %
        % set(handles.gui_chassis,'WindowButtonUpFcn', {@mbuttonup, handles, hObject});
        set(handles.gui_chassis,'WindowButtonDownFcn', {@mbuttondwn, hObject, eventdata, handles});
else
        set(handles.gui_chassis,'WindowButtonDownFcn', []);
        erpworkingmemory('WMmouse', 0);
        latency = handles.orilatency;
        handles.latency = latency;
        
        % Update handles structure
        guidata(hObject, handles);
        pause(0.1)
        
        tittle = handles.tittle;
        ich    = handles.ich;
        ibin   = handles.ibin;
        iset   = handles.iset;
        
        mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)
end

%--------------------------------------------------------------------------
function mbuttondwn(h, xxx, hObject, eventdata, handles)
if get(handles.checkbox_dmouse,'Value')
        latency = handles.latency;
        
        C = get(gca, 'CurrentPoint');
        x = C(1,1);
        
        props.WindowButtonUpFcn  = get(h,'WindowButtonUpFcn');
        setappdata(h,'meaviewerGUICallbacks',props);
        
        if length(latency)>1
                latency = [x latency(2)];
        else
                latency = x;
        end
        handles.latency = latency;
        
        % Update handles structure
        guidata(hObject, handles);
        
        set(h,'WindowButtonUpFcn',{@mbuttonup, hObject, eventdata, handles})
end

%--------------------------------------------------------------------------
function mbuttonup(h, xxx, hObject, eventdata, handles)
if get(handles.checkbox_dmouse,'Value')
        latency = handles.latency;
        C = get(gca, 'CurrentPoint');
        x = C(1,1);
        
        props = getappdata(h,'meaviewerGUICallbacks');
        set(h,props);
        if length(latency)>1
                latency = sort([latency(1) x]);
        else
                latency = x;
        end
        
        [ AMP, Lat, latency ] = getnewvals(hObject, handles, latency);
        
        handles.AMP = AMP;
        handles.Lat = Lat;
        handles.latency = latency;
        
        % Update handles structure
        guidata(hObject, handles);
        pause(0.1)
        
        tittle = handles.tittle;
        %         ich    = handles.ich;
        %         ibin   = handles.ibin;
        %         iset   = handles.iset;
        
        %
        % info
        %
        binArray  = handles.binArray;
        chanArray = handles.chanArray;
        setArray  = handles.setArray;
        xbin = str2num(get(handles.edit_bin, 'String'));
        xch  = str2num(get(handles.edit_channel, 'String'));
        xset = str2num(get(handles.edit_file, 'String'));
        ibin = find(ismember_bc2(binArray,xbin)); %find(binArray==xbin,1);
        ich  = find(ismember_bc2(chanArray,xch)); %find(chanArray==xch,1);
        iset = find(ismember_bc2(setArray,xset)); %find(setArray==xset,1);
        
        mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)
end

%--------------------------------------------------------------------------
function radiobutton_histo_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.pushbutton_color_val, 'Enable', 'off');
        set(handles.pushbutton_color_window, 'Enable', 'off');
        set(handles.togglebutton_y_axis_polarity, 'Enable', 'off');
        %set(handles.pushbutton_update, 'Enable', 'off');
        set(handles.edit_ylim, 'Enable', 'off');
        set(handles.edit_xlim, 'Enable', 'off');
        set(handles.checkbox_dmouse, 'Value', 0);
        set(handles.checkbox_dmouse, 'Enable', 'off');
        set(handles.radiobutton_scatter, 'Value', 0);
        set(handles.checkbox_fileindx,'Value', 0)
        set(handles.checkbox_fileindx,'Enable', 'off')
        set(handles.checkbox_scatterlabels, 'Value',0)
        set(handles.checkbox_scatterlabels, 'Enable', 'off')
        set(handles.checkbox_3sigma, 'Value',0)
        set(handles.checkbox_3sigma, 'Enable', 'off')
        set(handles.pushbutton_narrow, 'Enable', 'off')
        set(handles.pushbutton_wide, 'Enable', 'off')
        set(handles.pushbutton_histosetting,'Enable','on')
else
        datatype = handles.datatype;
        set(handles.pushbutton_color_val, 'Enable', 'on');
        set(handles.pushbutton_color_window, 'Enable', 'on');
        if strcmpi(datatype, 'ERP')
                set(handles.togglebutton_y_axis_polarity, 'Enable', 'on');
        end
        %set(handles.pushbutton_update, 'Enable', 'on');
        set(handles.edit_ylim, 'Enable', 'on');
        set(handles.edit_xlim, 'Enable', 'on');
        set(handles.checkbox_dmouse, 'Enable', 'on');
        mwm = erpworkingmemory('WMmouse');
        if mwm
                set(handles.checkbox_dmouse, 'Value', 1);
        end
        set(handles.pushbutton_histosetting,'Enable','off')
end
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function radiobutton_scatter_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.pushbutton_color_val, 'Enable', 'off');
        set(handles.pushbutton_color_window, 'Enable', 'off');
        set(handles.togglebutton_y_axis_polarity, 'Enable', 'off');
        %set(handles.pushbutton_update, 'Enable', 'off');
        set(handles.edit_ylim, 'Enable', 'off');
        set(handles.edit_xlim, 'Enable', 'off');
        set(handles.checkbox_dmouse, 'Value', 0);
        set(handles.checkbox_dmouse, 'Enable', 'off');
        set(handles.radiobutton_histo, 'Value', 0);
        set(handles.checkbox_scatterlabels, 'Value',0)
        set(handles.checkbox_scatterlabels, 'Enable', 'on')
        set(handles.checkbox_3sigma, 'Value',0)
        set(handles.checkbox_3sigma, 'Enable', 'on')
        set(handles.pushbutton_narrow, 'Enable', 'on')
        set(handles.pushbutton_wide, 'Enable', 'on')
        if get(handles.checkbox_butterflyset, 'Value')
                set(handles.checkbox_fileindx,'Value', 0)
                set(handles.checkbox_fileindx,'Enable', 'on')
        end
        set(handles.pushbutton_histosetting,'Enable','off')
else
        datatype = handles.datatype;
        set(handles.pushbutton_color_val, 'Enable', 'on');
        set(handles.pushbutton_color_window, 'Enable', 'on');
        if strcmpi(datatype, 'ERP')
                set(handles.togglebutton_y_axis_polarity, 'Enable', 'on');
        end
        %set(handles.pushbutton_update, 'Enable', 'on');
        set(handles.edit_ylim, 'Enable', 'on');
        set(handles.edit_xlim, 'Enable', 'on');
        set(handles.checkbox_dmouse, 'Enable', 'on');
        mwm = erpworkingmemory('WMmouse');
        if mwm
                set(handles.checkbox_dmouse, 'Value', 1);
        end
        set(handles.checkbox_fileindx,'Value', 0)
        set(handles.checkbox_fileindx,'Enable', 'off')
        set(handles.checkbox_scatterlabels, 'Value',0)
        set(handles.checkbox_scatterlabels, 'Enable', 'off')
        set(handles.checkbox_3sigma, 'Value',0)
        set(handles.checkbox_3sigma, 'Enable', 'off')
        set(handles.pushbutton_narrow, 'Enable', 'off')
        set(handles.pushbutton_wide, 'Enable', 'off')
end
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function pushbutton_narrow_Callback(hObject, eventdata, handles)
x1 = handles.x1;
x2 = handles.x2;
x1 = x1+1;
x2 = x2-1;
if x1>-1.75
        return
end
if x2<1.75
        return
end
handles.x1 = x1;
handles.x2 = x2;

handles.xscatt = handles.xscatt*0.75;

%Update handles structure
guidata(hObject, handles);
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function pushbutton_wide_Callback(hObject, eventdata, handles)

x1 = handles.x1;
x2 = handles.x2;
x1 = x1-1;
x2 = x2+1;
if x1<-8
        return
end
if x2>8
        return
end
handles.x1 = x1;
handles.x2 = x2;
handles.xscatt = handles.xscatt*1.33;

%Update handles structure
guidata(hObject, handles);
tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function checkbox_scatterlabels_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function checkbox_3sigma_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function checkbox_fileindx_Callback(hObject, eventdata, handles)
tittle = handles.tittle;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

if isempty(xlim) || isempty(ylim)
        return
end

ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

%--------------------------------------------------------------------------
function pushbutton_histosetting_Callback(hObject, eventdata, handles)

binvalue  = handles.binvalue;
normhisto = handles.normhisto;
chisto    = handles.chisto;
fitnormd  = handles.fitnormd;
cfitnorm  = handles.cfitnorm;
xbin = str2num(get(handles.edit_bin, 'String'));
xch  = str2num(get(handles.edit_channel, 'String'));
xset = str2num(get(handles.edit_file, 'String'));
nvalue = length(xbin)*length(xch)*length(xset);

%
% Call GUI
%
answer = histosettingGUI({binvalue, normhisto, chisto, fitnormd, cfitnorm, nvalue});

if isempty(answer)
        disp('User selected Cancel')
        return
end

handles.binvalue  = answer{1};
handles.normhisto = answer{2};
handles.chisto    = answer{3};
handles.fitnormd  = answer{4};
handles.cfitnorm  = answer{5};

%Update handles structure
guidata(hObject, handles);

tittle = handles.tittle;
ich    = handles.ich;
ibin   = handles.ibin;
iset   = handles.iset;
ylim   = str2num(get(handles.edit_ylim, 'String' ));
xlim   = str2num(get(handles.edit_xlim, 'String' ));

mplotdata(hObject, handles, ibin, ich, iset, xlim, ylim, tittle)

















%--------------------------------------------------------------------------
function [ Amp, Lat, latency] = getnewvals(hObject, handles, latency)

fntsz = get(handles.edit_report, 'FontSize');
set(handles.edit_report, 'FontSize', fntsz)
set(handles.edit_report, 'String', sprintf('\nRemeasuring values...\nThis process might take a while. Please wait...\n'))
drawnow

ALLERP    = handles.ALLERP;
binArray  = handles.binArray;
chanArray = handles.chanArray;
setArray  = handles.setArray;
nfile     = length(setArray);
moption   = handles.moption;
blc       = handles.blc;
coi       = handles.coi;
polpeak   = handles.polpeak;
sampeak   = handles.sampeak;
locpeakrep  = handles.locpeakrep;
frac        = handles.frac;
fracmearep  = handles.fracmearep;
intfactor   = handles.intfactor;
datatype    = handles.datatype;

[xxx, latsamp] = closest(ALLERP(setArray(end)).times, latency);

if strcmpi(datatype, 'ERP')
        fs = ALLERP(setArray(end)).srate;
        latency = (((latsamp-1)*1000)/fs) + ALLERP(setArray(end)).xmin*1000;
else
        bx = unique(diff(ALLERP(setArray(end)).times));
        latency = (latsamp-1)*bx(1);
end

Amp   = zeros(length(binArray), length(chanArray), length(setArray));
Lat   = {[]};

for k=1:nfile
        ERP = ALLERP(setArray(k));
        [A, lat4mea]  = geterpvalues(ERP, latency, binArray, chanArray, moption, blc, coi, polpeak, sampeak, locpeakrep, frac, fracmearep, intfactor);
        
        %
        % Store values
        %
        Amp(:,:,k) = A;  % bin x channel x erpset
        Lat{:,:,k} = lat4mea;  % bin x channel x erpset
end

set(handles.edit_report, 'FontSize', fntsz )
pause(0.1)

%
% create random x-values for scatter plot
%
xscatt = rand(1,numel(Amp))*2.5-1.25;
handles.xscatt = xscatt;
% chan indices
indxsetstr = cellstr(num2str(setArray'))';
handles.indxsetstr = indxsetstr;

%Update handles structure
guidata(hObject, handles);

% -----------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

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

%--------------------------------------------------------------------------
function popupmenu_measurementv_Callback(hObject, eventdata, handles)

% meamenu   = get(handles.text_measurementv, 'String');
% currmea   = get(handles.text_measurementv, 'Value');
% moption   = meamenu{currmea};

%--------------------------------------------------------------------------
function text_measurementv_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_createplot_Callback(hObject, eventdata, handles)
% h1=handles.axes1;
% %
% % Create figure
% %
% hbig = figure('Name','ERP VIEWER',...
%         'NumberTitle','on', 'Tag', 'Viewer_figure');erplab_figtoolbar(hbig);
% % objects=allchild(h1);
% copyobj(h1,hbig);
% opengl software
OFF_STD = 0.25; % std dev of figure offset
MIN_OFF = 0.15; % minimum offset for new figure
BORDER  = 0.04;  % screen edge tolerance

fig=handles.gui_chassis;
sel=handles.axes1;
%
% Get position for new figure
%
set(sel,'Units','normalized');
place = get(sel,'Position');
cmap  = colormap;
% newxy = (OFF_STD*randn(1,2))+place(1,1:2);
% newx  = newxy(1);newy=newxy(2);
%
% if abs(newx-place(1,1))<MIN_OFF, newx=place(1,1)+sign(newx-place(1,1))*MIN_OFF;end
% if abs(newy-place(1,1))<MIN_OFF, newy=place(1,1)+sign(newy-place(1,1))*MIN_OFF;end
% if newx<BORDER, newx=BORDER; end
% if newy<BORDER, newy=BORDER; end
% if newx+place(3)>1-BORDER, newx=1-BORDER-place(3); end
% if newy+place(4)>1-BORDER, newy=1-BORDER-place(4); end

% newfig = figure('Units','Normalized','Position',[newx,newy,place(1,3:4)]);
newfig = figure('Units','Normalized','Position', place, 'Name','ERP VIEWER', 'NumberTitle','on', 'Tag', 'Viewer_figure');

%
% Copy object to new figure
%
set(newfig,'Color',[1 1 1]);
copyobj(sel,newfig);
set(gca,'Position',[0.130 0.110 0.775 0.815]);
set(gca,'Box', 'off')
colormap(cmap);
erplab_figtoolbar(newfig)

% %
% % Increase font size
% %
% set(findobj('parent',newfig,'type','axes'),'FontSize',14);
% set(get(gca,'XLabel'),'FontSize',16)
% set(get(gca,'YLabel'),'FontSize',16)
% set(get(gca,'Title'),'Fontsize',16);
%
% Add xtick and ytick labels if missing
%
% if strcmp(get(gca,'Box'),'on')
%    set(gca,'xticklabelmode','auto')
%    set(gca,'xtickmode','auto')
%    set(gca,'yticklabelmode','auto')
%    set(gca,'ytickmode','auto')
% end
%
% Turn on zoom in the new figure
%
% zoom on;
pause(0.2)

latency = handles.latency;
handles.output = NaN;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
