% Author: Javier Lopez-Calderon % Sam London
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

function varargout = scalplotGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @scalplotGUI_OpeningFcn, ...
        'gui_OutputFcn',  @scalplotGUI_OutputFcn, ...
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
function scalplotGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for scalplotGUI
try
        plotset = evalin('base', 'plotset');
        
        if isfield(plotset.pscalp, 'posgui')
                if ~isempty(plotset.pscalp.posgui)
                        set(handles.gui_chassis,'Position', plotset.pscalp.posgui);
                end
        end
        if isfield(plotset.pscalp, 'binArray')
                binArray = plotset.pscalp.binArray;
        else
                binArray = [];
        end
catch
        plotset.ptime  = [];
        plotset.pscalp = [];
        assignin('base','plotset',plotset)
        binArray = [];
end

handles.output   = plotset;
handles.indxline = 1;
handles.ispdf    = 0;
handles.isagif   = 0;

try
        ERP   = varargin{1};
        nchan = ERP.nchan;
        nbin  = ERP.nbin; % Total number of bins
        splinefile = ERP.splinefile;
        xmax  = ERP.xmax;
        xmin  = ERP.xmin;
        datatype = checkdatatype(ERP);
catch
        ERP   = [];
        nchan = 0;
        nbin  = 0;
        splinefile = '';
        xmax  = 0.8;
        xmin  = -0.2;
        datatype = 'ERP';
end
if strcmpi(datatype, 'ERP')
        kktime = 1000;
else %FFT
        kktime = 1;
end
handles.kktime   = kktime;
handles.datatype = datatype;
try
        chanlocs = varargin{2};
catch
        chanlocs = [];
end

splineinfo.path = [];

handles.ERP        = ERP;
handles.xmax       = xmax;
handles.xmin       = xmin;
handles.nchan      = nchan;
handles.nbin       = nbin;
handles.chanlocs   = chanlocs;
handles.splinefile = splinefile; % from ERP
handles.splineinfo = splineinfo; % from memory
handles.binnum     = [];
handles.bindesc    = [];
handles.type       = [];
handles.latency    = [];
handles.electrodes = [];
handles.colorbar   = [];
handles.clrmap     = [];
handles.ismaxim    = [];
handles.smapstyle = 'both';

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   SCALP MAPPING GUI'])

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

for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end

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

% PDF button
% pdfbutton

% set all objects
setall(hObject, eventdata, handles)

% UIWAIT makes geterpvaluesGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = scalplotGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.ERP;

% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

%--------------------------------------------------------------------------
function edit_custom_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_custom_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_latencies_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_latencies_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)
ERP  = handles.ERP;
datatype = handles.datatype;
kktime = handles.kktime;
if get(handles.radio_3D, 'Value')
        if isempty(handles.splinefile) && isempty(ERP.splinefile)
                msgboxText =  ['You must specify a spline file for 3D scalp maps.\n\n'...
                        'Use the spline file button for loading/creating a spline file.'];
                title = 'ERPLAB: scalpplotGUI inputs';
                errorfound(sprintf(msgboxText), title);
                return
        elseif isempty(handles.splinefile) && ~isempty(ERP.splinefile)
                splineinfo.path    = ERP.splinefile;
                splineinfo.new     = 0;
                splineinfo.save    = 0;
                splineinfo.newname = [];
        elseif ~isempty(handles.splinefile) && isempty(ERP.splinefile)
                splineinfo.path    = handles.splinefile;
                splineinfo.new     = 0;
                splineinfo.save    = 0;
                splineinfo.newname = [];
                
                % %
                % % Open GUI
                % %
                % splineinfo = splinefileGUI(handles.splinefile);
                %
                % if isempty(splineinfo) || isempty(splineinfo.path)
                %         msgboxText =  'You must specify a name for the spline file.';
                %         title = 'ERPLAB: scalpplotGUI inputs';
                %         errorfound(msgboxText, title);
                %         return
                % end
        else
                splineinfo =   handles.splineinfo;
                splineinfo.new     = 0;
                splineinfo.save    = 0;
                splineinfo.newname = [];
                %                   splineinfo.path =   handles.splinefile;
                %                   splineinfo.new  = 0;
                %                   splineinfo.save = 0;
                %                   splineinfo.newname = [];
        end
end
binArraystr    = strtrim(get(handles.edit_bins, 'String'));
latestr        = strtrim(get(handles.edit_latencies, 'String'));
binArray       = str2num(binArraystr);
latencyArray   = str2num(latestr);
%nlate = length(latencyArray);
customscale    = strtrim(get(handles.edit_custom, 'String'));
customscale    = regexprep(customscale,'''|"','');
nbin           = handles.nbin;
errorcusca     = 0;

if  ~isempty(latencyArray) && ~isempty(binArray)
        if max(binArray)>nbin
                msgboxText =  'Error: You have specified unexisting bins.';
                title = 'ERPLAB: scalplotGUI() error:';
                errorfound(msgboxText, title);
                return
        end
        if length(binArray)>length(unique_bc2(binArray))
                msgboxText =  'Error: You have specified repeated bins.';
                title = 'ERPLAB: scalplotGUI() error:';
                errorfound(msgboxText, title);
                return
        end
        indxh   = find(latencyArray>handles.xmax*kktime,1);
        if ~isempty(indxh)
                if strcmpi(datatype, 'ERP')
                        msgboxText =  ['Latency of ' num2str(latencyArray(indxh)) ' is greater than ERP.xmax = ' num2str(handles.xmax*kktime) ' msec!'];
                else %FFT
                        msgboxText =  ['Frequency of ' num2str(latencyArray(indxh)) ' is greater than ERP.xmax = ' num2str(handles.xmax*kktime) ' Hz!'];
                end
                title_msg  = 'ERPLAB: scalplotGUI() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        indxl  = find(latencyArray<handles.xmin*kktime,1);
        if ~isempty(indxl)
                if strcmpi(datatype, 'ERP')
                        msgboxText =  ['Latency of ' num2str(latencyArray(indxl)) ' is lesser than ERP.xmin = ' num2str(handles.xmin*kktime) ' msec!'];
                else %FFT
                        msgboxText =  ['Frequency of ' num2str(latencyArray(indxl)) ' is lesser than ERP.xmin = ' num2str(handles.xmin*kktime) ' Hz!'];
                end
                title_msg  = 'ERPLAB: scalplotGUI() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        meamenu = get(handles.popupmenu_measurement, 'Value');
        
        % % %         switch meamenu
        % % %                 case 1
        % % %                         measurement = 'insta';
        % % %                 case 2
        % % %                         measurement = 'mean';
        % % %                 case 3
        % % %                         measurement = 'area';
        % % %                 case 4
        % % %                         measurement = 'instalapla';
        % % %                 case 5
        % % %                         measurement = 'meanlapla';
        % % %                 case 6
        % % %                         measurement = 'rms';
        % % %                 otherwise
        % % %                         measurement = 'insta';
        % % %         end
        % % %         switch meamenu
        % % %                 case {2,3,5,6}
        % % %                         if size(latencyArray,2)<2
        % % %                                 msgboxText =  ['You must specify 2 latencies, at least, for getting %s-values.\n\n'...
        % % %                                         'For specifying two or more mean value maps, please use semicolon (;) to separate each latency range.'...
        % % %                                         'For instance, to plot mean value maps for 0 to 100 ms AND 400 to 500 ms just write 0 100;400 500'];
        % % %                                 title = 'ERPLAB: scalplotGUI() error:';
        % % %                                 errorfound(sprintf(msgboxText, measurement), title);
        % % %                                 return
        % % %                         end
        % % %                 case {1,4}
        % % %                         if size(latencyArray,1)>1
        % % %                                 msgboxText =  'For %s you must specify as many latencies as maps you''d like to plot.\nYou cannot use semicolon-separated values.\n';
        % % %                                 title = 'ERPLAB: scalplotGUI() error:';
        % % %                                 errorfound(sprintf(msgboxText, measurement), title);
        % % %                                 return
        % % %                         end
        % % %         end
        switch meamenu
                case 1
                        measurement = 'insta';
                case 2
                        measurement = 'mean';
                case 3
                        measurement = 'instalapla';
                case 4
                        measurement = 'meanlapla';
                case 5
                        measurement = 'rms';
                otherwise
                        measurement = 'insta';
        end
        switch meamenu
                case {2, 4, 5} % mean, meanlapla, rms
                        if size(latencyArray,2)<2
                                if strcmpi(datatype, 'ERP')
                                        msgboxText =  ['You must specify 2 latencies, at least, for getting %s-values.\n\n'...
                                                'For specifying two or more mean value maps, please use semicolon (;) to separate each latency range.'...
                                                'For instance, to plot mean value maps for 0 to 100 ms AND 400 to 500 ms just write 0 100;400 500'];
                                else %FFT
                                        msgboxText =  ['You must specify 2 frequencies, at least, for getting %s-values.\n\n'...
                                                'For specifying two or more mean value maps, please use semicolon (;) to separate each frequency range.'...
                                                'For instance, to plot mean value maps for 8 to 12 Hz AND 30 to 50 Hz just write 8 12;30 50'];
                                end
                                title = 'ERPLAB: scalplotGUI() error:';
                                errorfound(sprintf(msgboxText, measurement), title);
                                return
                        end
                case {1,3} % insta, instalapla
                        if size(latencyArray,1)>1
                                if strcmpi(datatype, 'ERP')
                                        msgboxText =  'For %s you must specify as many latencies as maps you''d like to plot.\nYou cannot use semicolon-separated values.\n';
                                else %FFT
                                        msgboxText =  'For %s you must specify as many frequencies as maps you''d like to plot.\nYou cannot use semicolon-separated values.\n';
                                end
                                title = 'ERPLAB: scalplotGUI() error:';
                                errorfound(sprintf(msgboxText, measurement), title);
                                return
                        end
        end
        
        %
        % Baseline
        %
        if get(handles.radiobutton_BLC_no, 'Value')
                baseline = 'none';
        end
        if get(handles.radiobutton_BLC_pre, 'Value')
                baseline = 'pre';
        end
        if get(handles.radiobutton_BLC_post, 'Value')
                baseline = 'post';
        end
        if get(handles.radiobutton_BLC_whole, 'Value')
                baseline = 'all';
        end
        if get(handles.radiobutton_BLC_custom, 'Value')
                numbl = str2num(get(handles.edit_customblc, 'String'));
                if isempty(numbl)
                        return
                else
                        if length(numbl)==2
                                baseline = [numbl(1) numbl(2)];
                        else
                                return
                        end
                end
        end
        if get(handles.radiobutton_maxmin, 'Value')
                cscale = 'maxmin';
        end
        if get(handles.radiobutton_absmax, 'Value')
                cscale = 'absmax';
        end
        if get(handles.radiobutton_custom, 'Value')
                if ~strcmp(customscale, '') && ~isempty(customscale) && ~strcmpi(customscale, 'auto')
                        cusca  = str2num(customscale);
                        ncusca = length(cusca);
                        if ncusca == 2
                                if cusca(1)<cusca(2)
                                        cscale = cusca;
                                else
                                        errorcusca = 1;
                                end
                        else
                                errorcusca = 1;
                        end
                elseif strcmpi(customscale, 'auto')
                        cscale = 'auto';
                else
                        errorcusca = 1;
                end
                if errorcusca
                        colorold = get(handles.edit_custom, 'BackgroundColor');
                        set(handles.edit_custom, 'BackgroundColor', [1 0 0]);
                        pause(0.5)
                        set(handles.edit_custom, 'BackgroundColor', colorold);
                        beep
                        return
                end
        end
        
        %
        % Show electrodes
        %
        showelec = get(handles.set_legends, 'Value');
        
        %
        % Animation
        %
        if get(handles.checkbox_animation, 'Value')
                if get(handles.checkbox_adjust1frame, 'Value')
                        isagif    = 2; % adjust first frame
                else
                        isagif    = 1;
                end
                
                FPS    = str2num(get(handles.edit_fps, 'String'));
                fnameagif = get(handles.edit_fname_animation, 'String');
                
                if isempty(FPS) || FPS<1 || FPS>1000
                        msgboxText =  'Error: You must specify a scalar value between 1 and 1000 inclusive';
                        title = 'ERPLAB: scalplotGUI() error:';
                        errorfound(msgboxText, title);
                        return
                end
                if isempty(strtrim(fnameagif))
                        msgboxText =  'Error: You must specify a valid file name for your animated GIF';
                        title = 'ERPLAB: scalplotGUI() error:';
                        errorfound(msgboxText, title);
                        return
                else
                        [pthxz, fnamez, ext] = fileparts(fnameagif);
                        if strcmp(ext,'')
                                ext   = '.gif';
                        end
                        fnameagif = fullfile(pthxz,[ fnamez ext]);
                end
        else
                isagif    = 0;
                FPS       = [];
                fnameagif = '';
        end
        
        %
        % Orientation view
        %
        viewselec = get(handles.popupmenu_orientation, 'Value');
        
        if get(handles.radio_2D, 'Value')==1  % 2D
                mtype = '2D';
                switch viewselec
                        case 1
                                mapview = '+X';
                        case 2
                                mapview = '-X';
                        case 3
                                mapview = '+Y';
                        case 4
                                mapview = '-Y';
                        otherwise
                                return
                end
                splineinfo.path =  ERP.splinefile;
                splineinfo.new  = 0;
                splineinfo.save = 0;
        else % 3D
                mtype = '3D';
                switch viewselec
                        case 1
                                mapview = 'front';
                        case 2
                                mapview = 'back';
                        case 3
                                mapview = 'right';
                        case 4
                                mapview = 'left';
                        case 5
                                mapview = 'top';
                        case 6
                                mapview = 'frontleft';
                        case 7
                                mapview = 'frontright';
                        case 8
                                mapview = 'backleft';
                        case 9
                                mapview = 'backright';
                        case 10
                                mapview = str2num(strtrim(get(handles.edit_customview, 'String')));
                        otherwise
                                return
                end
        end
else
        if strcmpi(datatype, 'ERP')
                msgboxText =  'You must specify Bin AND Latency(ies) for making a scalp map.';
        else % FFT
                msgboxText =  'You must specify Bin AND Frequency(ies) for making a scalp map.';
        end
        title = 'ERPLAB: scalpplotGUI empty input';
        errorfound(msgboxText, title);
        return
end

smapstylenum = get(handles.popupmenu_mapstyle, 'Value');
smapstylestr = cellstr(get(handles.popupmenu_mapstyle, 'String'));
smapstyle    = smapstylestr{smapstylenum};
mapoutside   = get(handles.checkbox_outside, 'Value');

%
% Prepares output
%
ispdf = 0;
plotset = evalin('base', 'plotset');
plotset.pscalp.binArray     = binArray;
plotset.pscalp.latencyArray = latencyArray;
plotset.pscalp.measurement  = measurement;
plotset.pscalp.baseline     = baseline;
plotset.pscalp.cscale       = cscale;
plotset.pscalp.ispdf        = ispdf;
plotset.pscalp.agif.value   = isagif;
plotset.pscalp.agif.fps     = FPS;
plotset.pscalp.agif.fname   = fnameagif;
plotset.pscalp.posgui       = get(handles.gui_chassis,'Position');
plotset.pscalp.mtype        = mtype; % map type  0=2D; 1=3D
plotset.pscalp.smapstyle    = smapstyle;   % map style: 'fill' 'both' 
plotset.pscalp.mapview      = mapview; 
plotset.pscalp.mapoutside   = mapoutside; 
plotset.pscalp.splineinfo   = splineinfo;
% legends
plotset.pscalp.plegend.binnum     = handles.Legbinnum;
plotset.pscalp.plegend.bindesc    = handles.Legbindesc;
plotset.pscalp.plegend.type       = handles.Legtype;
plotset.pscalp.plegend.latency    = handles.Leglatency;
plotset.pscalp.plegend.electrodes = handles.Legelectrodes;
plotset.pscalp.plegend.elestyle   = handles.Legelestyle;
plotset.pscalp.plegend.elec3D     = handles.Legelec3D;

plotset.pscalp.plegend.colorbar   = handles.Legcolorbar;
plotset.pscalp.plegend.colormap   = handles.Legcolormap;
plotset.pscalp.plegend.maximize   = handles.Legismaxim;

handles.output  = plotset;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);
%         end
% end

%--------------------------------------------------------------------------
function radiobutton_maxmin_Callback(hObject, eventdata, handles)
set(handles.edit_custom, 'Enable','off');
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function radiobutton_absmax_Callback(hObject, eventdata, handles)
set(handles.edit_custom, 'Enable','off');
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function radiobutton_custom_Callback(hObject, eventdata, handles)

set(handles.edit_custom, 'Enable','on');
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function edit_customblc_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_customblc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% %--------------------------------------------------------------------------
% function pushbutton_pdf_Callback(hObject, eventdata, handles)
% plotset = evalin('base', 'plotset');
% plotset.pscalp  = 'pdf';
% handles.output = plotset;
% guidata(hObject, handles);
% uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function radiobutton_BLC_custom_Callback(hObject, eventdata, handles)
set(handles.edit_customblc,'Enable', 'on')
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function radiobutton_BLC_no_Callback(hObject, eventdata, handles)
set(handles.edit_customblc,'Enable', 'off')
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function radiobutton_BLC_pre_Callback(hObject, eventdata, handles)
set(handles.edit_customblc,'Enable', 'off')
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function radiobutton_BLC_post_Callback(hObject, eventdata, handles)
set(handles.edit_customblc,'Enable', 'off')
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function radiobutton_BLC_whole_Callback(hObject, eventdata, handles)
set(handles.edit_customblc,'Enable', 'off')
set(hObject,'Value',1)

%--------------------------------------------------------------------------
function  setall(hObject, eventdata, handles)

plotset = handles.output;
if ~isfield(plotset, 'pscalp')
        plotset.pscalp = [];
end
datatype = handles.datatype;

% measurearray = {'Instantaneous amplitude','Mean amplitude between two fixed latencies',...
%         'Area between two fixed latencies', 'Instantaneous amplitude Laplacian', 'Mean amplitude Laplacian', 'Root mean square value'};
if strcmpi(datatype, 'ERP')
        measurearray = {'Instantaneous amplitude','Mean amplitude between two fixed latencies',...
                'Instantaneous amplitude Laplacian', 'Mean amplitude Laplacian', 'Root mean square value'};
else %FFT
        measurearray = {'Instantaneous power','Mean power between two fixed frequencies'};
end
set(handles.popupmenu_measurement, 'String', measurearray);
%set(handles.popupmenu_videospeed, 'String', {'0.1X','0.25X','0.5X', '0.75X','1X', '2X'});
%set(handles.popupmenu_videospeed, 'Value', 5); % 1X
set(handles.popupmenu_colormap,'String', 'jet|hsv|hot|cool|gray')
set(handles.popupmenu_mapstyle,'String', 'map|contour|both|fill|blank')

% 'map'      -> plot colored map only
% 'contour'  -> plot contour lines only
% 'both'     -> plot both colored map and contour lines
% 'fill'     -> plot constant color between contour lines
% 'blank'    -> plot electrode locations only {default: 'both'}
% 

%
% Set GUI
%
if isempty(plotset.pscalp)
        binArraystr = '1';
        latvals = 0;
        latrows = 1;
        latencyArraystr = vect2colon(latvals, 'Delimiter','off');
        measurement = 'insta';
        if strcmpi(datatype, 'ERP')
                baseline    = 'pre';
        else %FFT
                baseline = 'none';
        end
        cscale      = 'maxmin';
        mtype       = '2D';
        smapstyle   = 'both';
        mapview     = '+X';
        mapoutside  = 0; % no=0; yes=1;
        
        Legbinnum     = 1;
        Legbindesc    = 0;
        Legtype       = 0;
        Leglatency    = 1;
        Legelectrodes = 1;
        Legelestyle   = 'on';
        Legelec3D     = 'off';
        Legcolorbar   = 0; % no color bar by default
        Legismaxim    = 0; % no maximize figure by default
        Legcolormap   = 1; % jet color map
else
        binArraystr = vect2colon(plotset.pscalp.binArray,'Delimiter','off', 'Repeat', 'off');
        latvals = plotset.pscalp.latencyArray;
        latrows = size(latvals,1);
        
        if latrows>1
                latencyArraystr = num2str(latvals);
                bb = cellstr(latencyArraystr);
                xs = ''; for t=1:length(bb);xs = [xs bb{t} ' ; '];end
                latencyArraystr = regexprep(xs,';\s*$','');
        else
                latencyArraystr = vect2colon(latvals, 'Delimiter','off');
        end
        
        measurement   = plotset.pscalp.measurement;
        baseline      = plotset.pscalp.baseline;
        cscale        = plotset.pscalp.cscale;
        %clrbar       = plotset.pscalp.colorbar;
        %showelec     = plotset.pscalp.showelec;
        %binleg       = plotset.pscalp.binleg;
        mtype         = plotset.pscalp.mtype; % map type '2D' or '3D'
        smapstyle     = plotset.pscalp.smapstyle;
        mapview       = plotset.pscalp.mapview; 
        mapoutside    = plotset.pscalp.mapoutside;
        
        plegend       = plotset.pscalp.plegend; 
        Legbinnum     = plegend.binnum;
        Legbindesc    = plegend.bindesc;
        Legtype       = plegend.type ;
        Leglatency    = plegend.latency;
        Legelectrodes = plegend.electrodes;
        Legelestyle   = plegend.elestyle;
        Legelec3D     = plegend.elec3D;
        Legcolorbar   = plegend.colorbar;
        Legismaxim    = plegend.maximize;
        Legcolormap   = plegend.colormap; % jet color map
end

% % %
% % % Value to plot menu
% % %
% % if strcmpi(measurement,'insta')
% %         meamenu =1;
% % elseif strcmpi(measurement,'mean')
% %         meamenu =2;
% % elseif strcmpi(measurement,'area')
% %         meamenu =3;
% % elseif strcmpi(measurement,'instalapla') || strcmpi(measurement,'lapla')
% %         meamenu =4;
% % elseif strcmpi(measurement,'meanlapla')
% %         meamenu =5;
% % elseif strcmpi(measurement,'rms')
% %         meamenu =6;
% % else
% %         meamenu =1;
% % end

%
% Value to plot menu
%
if strcmpi(datatype, 'ERP')
        if strcmpi(measurement,'insta')
                meamenu =1;
        elseif strcmpi(measurement,'mean')
                meamenu =2;
        elseif strcmpi(measurement,'instalapla') || strcmpi(measurement,'lapla')
                meamenu =3;
        elseif strcmpi(measurement,'meanlapla')
                meamenu =4;
        elseif strcmpi(measurement,'rms')
                meamenu =5;
        else
                meamenu =1;
        end
else %FFT
        if strcmpi(measurement,'insta')
                meamenu =1;
        elseif strcmpi(measurement,'mean')
                meamenu =2;
        else
                meamenu =1;
        end
end

set(handles.popupmenu_measurement, 'Value', meamenu);
switch meamenu
        case {1,4}
                if strcmpi(datatype, 'ERP')
                        set(handles.text_example,'String','e.g. 300 or 100:50:350 to plot scalp maps at 300 or at 100,150,200,...,350 ms')
                else % FFT
                        set(handles.text_example,'String','e.g. 10 or 10:5:35 to plot scalp maps at 10 or at 10,15,20,...,35 Hz')
                end
        case {2,3,5,6}
                if strcmpi(datatype, 'ERP')
                        set(handles.text_example,'String','e.g., 300 400 ; 400 500 to plot scalp maps for 300-400, 400-500 ms)')
                else % FFT
                        set(handles.text_example,'String','e.g., 30 40 ; 40 50 to plot scalp maps for 30-40, 40-50 Hz)')
                end
end

% colormap
set(handles.popupmenu_colormap, 'Value', Legcolormap)
set(handles.checkbox_colorbar, 'Value', Legcolorbar)

% Map style
if strcmpi(mtype, '2D')
        smapstylestr  = cellstr(get(handles.popupmenu_mapstyle, 'String'));
        indxsmapstyle = find(ismember(smapstylestr, smapstyle));
        set(handles.popupmenu_mapstyle, 'Value', indxsmapstyle)
        set(handles.checkbox_outside, 'Value', mapoutside)
else
        set(handles.checkbox_outside, 'Value', 0)
        set(handles.checkbox_outside, 'Enable', 'off')
        set(handles.popupmenu_mapstyle, 'Enable', 'off')
end

%
% Baseline setting
%
if strcmpi(datatype, 'ERP')
        set(handles.radiobutton_BLC_no,'Enable','on');
        set(handles.radiobutton_BLC_pre,'Enable','on');
        set(handles.radiobutton_BLC_post,'Enable','on');
        set(handles.radiobutton_BLC_whole,'Enable','on');
        set(handles.radiobutton_BLC_custom,'Enable','on');
        if ischar(baseline)
                if strcmpi(baseline,'none')
                        set(handles.radiobutton_BLC_no,'Value',1);
                elseif strcmpi(baseline,'pre')
                        set(handles.radiobutton_BLC_pre,'Value',1);
                elseif strcmpi(baseline,'post')
                        set(handles.radiobutton_BLC_post,'Value',1);
                elseif strcmpi(baseline,'all')
                        set(handles.radiobutton_BLC_whole,'Value',1);
                else
                        numblc = str2num(baseline);
                        if isempty(numblc)
                                set(handles.radiobutton_BLC_pre,'Value',1); %default
                                set(handles.edit_customblc,'Enable', 'off')
                        else
                                if size(numblc,1)~=1 || size(numblc,2)~=2
                                        set(handles.radiobutton_BLC_pre,'Value',1); %default
                                        set(handles.edit_customblc,'Enable', 'off')
                                else
                                        set(handles.radiobutton_BLC_custom,'Value',1); %custom
                                        set(handles.edit_customblc,'String', baseline); %custom
                                end
                        end
                end
        else
                if size(baseline,1)~=1 || size(baseline,2)~=2
                        set(handles.radiobutton_BLC_pre,'Value',1); %default
                        set(handles.edit_customblc,'Enable', 'off')
                else
                        set(handles.radiobutton_BLC_custom,'Value',1); %custom
                        set(handles.edit_customblc,'String', num2str(baseline)); %custom
                end
        end
else %FFT
        set(handles.radiobutton_BLC_no,'Value',1);
        set(handles.radiobutton_BLC_pre,'Value',0);
        set(handles.radiobutton_BLC_post,'Value',0);
        set(handles.radiobutton_BLC_whole,'Value',0);
        set(handles.radiobutton_BLC_custom,'Value',0);
        
        set(handles.radiobutton_BLC_no,'Enable','off');
        set(handles.radiobutton_BLC_pre,'Enable','off');
        set(handles.radiobutton_BLC_post,'Enable','off');
        set(handles.radiobutton_BLC_whole,'Enable','off');
        set(handles.radiobutton_BLC_custom,'Enable','off');        
end

%
% Scale
%
if ischar(cscale)
        if strcmpi(cscale,'maxmin')
                set(handles.radiobutton_maxmin,'Value',1);
                set(handles.edit_custom,'Enable', 'off')
        elseif strcmpi(cscale,'absmax')
                set(handles.radiobutton_absmax,'Value',1);
                set(handles.edit_custom,'Enable', 'off')
        else
                numscale = str2num(cscale);
                if isempty(numscale)
                        set(handles.radiobutton_maxmin,'Value',1); %default
                        set(handles.edit_custom,'Enable', 'off')
                else
                        if size(numscale,1)~=1 || size(numscale,2)~=2
                                set(handles.radiobutton_maxmin,'Value',1); %default
                                set(handles.edit_custom,'Enable', 'off')
                        else
                                set(handles.radiobutton_custom,'Value',1); %custom
                                set(handles.edit_custom,'Enable', 'on')
                                set(handles.edit_custom,'String', cscale); %custom
                        end
                end
        end
else
        if size(cscale,1)~=1 || size(cscale,2)~=2
                set(handles.radiobutton_maxmin,'Value',1); %default
                set(handles.edit_custom,'Enable', 'off')
        else
                set(handles.radiobutton_custom,'Value',1); %custom
                set(handles.edit_custom,'Enable', 'on')
                set(handles.edit_custom,'String', num2str(cscale)); %custom
        end
end

set(handles.edit_bins,'String',binArraystr);
set(handles.edit_latencies,'String',latencyArraystr);

%
% 2D or 3D
%
if strcmpi(mtype,'2D')
        morimenu = {'+X','-X','+Y','-Y'};
        if ischar(mapview)
                mview = find(ismember_bc2(morimenu, mapview));
        else
                mview = 1;
        end
        set(handles.radio_2D, 'Value', 1);
        set(handles.radio_3D, 'Value', 0);
        set(handles.edit_customview, 'Enable', 'off')
        set(handles.pushbutton_splinefile, 'Enable', 'off')
else % 3D
        splinefile = handles.splinefile;
        if isempty(splinefile)
                set(handles.text_spline_warning, 'String','spline''s required!')
                set(handles.text_spline_warning, 'ForegroundColor', [0.71 0.1 0.1])
        end
        
        morimenu = {'front', 'back', 'right', 'left', 'top',...
                'frontleft', 'frontright', 'backleft', 'backright',...
                'custom'};
        if ischar(mapview)
                mview = find(ismember_bc2(morimenu, mapview));
                set(handles.edit_customview,'String','')
                set(handles.edit_customview, 'Enable','off' )
        else
                mview = length(morimenu);
                set(handles.edit_customview, 'Enable','on' )
                set(handles.edit_customview,'String', num2str(mapview))
                %set(handles.popupmenu_orientation,'Value', length(morimenu))
        end
        set(handles.radio_2D, 'Value', 0);
        set(handles.radio_3D, 'Value', 1);
end
if isempty(mview)
        mview =1;
else
        if mview==0
                mview=1;
        end
end

set(handles.popupmenu_orientation, 'String', morimenu);
set(handles.popupmenu_orientation, 'Value', mview);
popupmenu_orientation_Callback(hObject, eventdata, handles)

if strcmpi(datatype, 'ERP')
        if isfield(plotset.pscalp, 'agif')
                agif   = plotset.pscalp.agif.value;
                FPS    = plotset.pscalp.agif.fps;
                fnameagif = plotset.pscalp.agif.fname;
                
                if agif>0
                        set(handles.checkbox_animation,'Value', 1)
                        set(handles.checkbox_adjust1frame,'Enable', 'on')
                        set(handles.edit_fps,'Enable', 'on')
                        set(handles.edit_fps,'String', num2str(FPS))
                        set(handles.edit_fname_animation,'Enable', 'on')
                        set(handles.edit_fname_animation,'String', fnameagif)
                        set(handles.pushbutton_browse_animation,'Enable', 'on')
                        
                        if agif==2
                                set(handles.checkbox_adjust1frame,'Value', 1)
                        else
                                set(handles.checkbox_adjust1frame,'Value', 0)
                        end
                        set(handles.checkbox_adjust1frame,'Enable', 'on')
                else
                        set(handles.checkbox_animation,'Value', 0)
                        set(handles.checkbox_animation,'Value', 0)
                        set(handles.checkbox_adjust1frame,'Value', 0)
                        set(handles.checkbox_adjust1frame,'Enable', 'off')
                        set(handles.edit_fps,'Enable', 'off')
                        set(handles.edit_fname_animation,'Enable', 'off')
                        set(handles.pushbutton_browse_animation,'Enable', 'off')
                        set(handles.checkbox_adjust1frame,'Value', 0)
                        set(handles.checkbox_adjust1frame,'Enable', 'off')
                end
        else
                set(handles.checkbox_animation,'Value', 0)
                set(handles.checkbox_adjust1frame,'Value', 0)
                set(handles.checkbox_adjust1frame,'Enable', 'off')
                set(handles.edit_fps,'Enable', 'off')
                set(handles.edit_fname_animation,'Enable', 'off')
                set(handles.pushbutton_browse_animation,'Enable', 'off')
                set(handles.checkbox_adjust1frame,'Value', 0)
                set(handles.checkbox_adjust1frame,'Enable', 'off')
        end
else  %FFT
        set(handles.checkbox_animation,'Value', 0)
        set(handles.checkbox_adjust1frame,'Value', 0)
        set(handles.checkbox_adjust1frame,'Enable', 'off')
        set(handles.edit_fps,'Enable', 'off')
        set(handles.edit_fname_animation,'Enable', 'off')
        set(handles.pushbutton_browse_animation,'Enable', 'off')
        set(handles.checkbox_adjust1frame,'Value', 0)
        set(handles.checkbox_adjust1frame,'Enable', 'off')
end

handles.Legbinnum     = Legbinnum;
handles.Legbindesc    = Legbindesc;
handles.Legtype       = Legtype;
handles.Leglatency    = Leglatency;
handles.Legelectrodes = Legelectrodes;
handles.Legelestyle   = Legelestyle;
handles.Legelec3D     = Legelec3D;
handles.Legcolorbar   = Legcolorbar;
handles.Legcolormap   = Legcolormap;
handles.Legismaxim    = Legismaxim;

%Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function edit_exchan_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_exchan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_exchan_Callback(hObject, eventdata, handles)
numch = get(hObject, 'Value');
nums  = get(handles.edit_exchan, 'String');
nums  = [nums ' ' num2str(numch)];
set(handles.edit_exchan, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_exchan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_animation_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.edit_fps,'Enable', 'on')
        set(handles.edit_fname_animation,'Enable', 'on')
        set(handles.pushbutton_browse_animation,'Enable', 'on')
        set(handles.checkbox_adjust1frame,'Enable', 'on')
else
        set(handles.edit_fps,'Enable', 'off')
        set(handles.edit_fname_animation,'Enable', 'off')
        set(handles.pushbutton_browse_animation,'Enable', 'off')
        set(handles.checkbox_adjust1frame,'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_fname_animation_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fname_animation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browse_animation_Callback(hObject, eventdata, handles)

%
% Save GIF, mov, or mpg
%
prename = get(handles.edit_fname_animation,'String');
%[blfilename, blpathname, filterindex] = uiputfile({'*.gif';'*.*'},'Save animation as',prename);

[blfilename, blpathname, filterindex] = uiputfile( ...
        {'*.gif','Animated GIF (*.gif)';
        '*.mat', 'Matlab movie (*.mat)';...
        '*.avi','AVI file (*.avi)'},...
        'Save animation as', prename);

if isequal(blfilename,0)
        disp('User selected Cancel')
        return
else
        [px, fname, ext] = fileparts(blfilename);
        if  filterindex==1
                ext = '.gif';
        elseif  filterindex==2
                ext = '.mat';
        elseif  filterindex==3
                ext = '.avi';
        else
                ext = '.gif';
        end
        
        fname = [ fname ext];
        
        fullgifname = fullfile(blpathname, fname);
        set(handles.edit_fname_animation,'String', fullgifname);
        disp(['Animatation will be saved at ' fullgifname])
end

%--------------------------------------------------------------------------
function edit_fps_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fps_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
% function checkbox_colorbar_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_ploterp_Callback(hObject, eventdata, handles)
plotset = getplotset(hObject, eventdata, handles);
if isempty(plotset.ptime)
        return
else
        plotset.ptime.binArray = plotset.pscalp.binArray ;
        plotset.ptime.blcorr   =  plotset.pscalp.baseline;
        assignin('base','plotset', plotset);
        handles.eplot = 1;
        
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
end

%--------------------------------------------------------------------------
function set_legends_Callback(hObject, eventdata, handles)
binnum     = handles.Legbinnum;
bindesc    = handles.Legbindesc;
type       = handles.Legtype;
latency    = handles.Leglatency;
electrodes = handles.Legelectrodes;
elestyle   = handles.Legelestyle;
elec3D     = handles.Legelec3D;
% colorbar   = handles.Legcolorbar;
ismaxim    = handles.Legismaxim;

%values = [binnum bindesc type latency electrodes colorbar ismaxim];
values  = {binnum bindesc type latency electrodes elestyle elec3D ismaxim};
is2Dmap = get(handles.radio_2D, 'Value'); %check 2D map

%
% call gui
%
answer = includelabelscalpGUI(values, is2Dmap);
if isempty(answer)
        disp('User selected Cancel')
        return
end
% handles.output = [binnum bindesc type latency electrodes elestyle ismaxim];
handles.Legbinnum     = answer{1};
handles.Legbindesc    = answer{2};
handles.Legtype       = answer{3};
handles.Leglatency    = answer{4};
handles.Legelectrodes = answer{5};
handles.Legelestyle   = answer{6};
handles.Legelec3D     = answer{7};
% handles.Legcolorbar   = answer(6);
handles.Legismaxim    = answer{8};

%Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
% function checkbox_includenumberbin_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_CLERPF_Callback(hObject, eventdata, handles)
clerpf

%--------------------------------------------------------------------------
function checkbox_adjust1frame_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function radio_2D_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.text_spline_warning, 'String','')
        set(handles.radio_3D, 'Value',0)
        morimenu = {'+X','-X','+Y','-Y'};
        %morimenu = {'front', 'back', 'right', 'left', 'top',...
        %      'frontleft', 'frontright', 'backleft', 'backright',...
        %      'custom'};
        set(handles.popupmenu_orientation, 'Value', 1)
        set(handles.popupmenu_orientation, 'String', morimenu)
        set(handles.popupmenu_orientation, 'Enable', 'off')% sept 12, 2012. JLC
        set(handles.edit_customview, 'Enable', 'off')
        set(handles.pushbutton_splinefile, 'Enable', 'off')
        
        set(handles.checkbox_outside, 'Enable', 'on')
        set(handles.popupmenu_mapstyle, 'Enable', 'on')
else
        set(handles.radio_2D, 'Value',1)
end

%--------------------------------------------------------------------------
function radio_2D_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radio_3D_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        splinefile = handles.splinefile;
        if isempty(splinefile)
                set(handles.text_spline_warning, 'String','spline''s required!')
                set(handles.text_spline_warning, 'ForegroundColor', [0.71 0.1 0.1])
        end
        set(handles.radio_2D, 'Value',0)
        morimenu = {'front', 'back', 'right', 'left', 'top',...
                'frontleft', 'frontright', 'backleft', 'backright',...
                'custom'};
        set(handles.popupmenu_orientation, 'Enable', 'on') % sept 12, 2012. JLC
        set(handles.popupmenu_orientation, 'Value', 1)
        set(handles.popupmenu_orientation, 'String', morimenu)
        set(handles.pushbutton_splinefile, 'Enable', 'on')        
        
        set(handles.checkbox_outside, 'Value', 0)
        set(handles.checkbox_outside, 'Enable', 'off')
        set(handles.popupmenu_mapstyle, 'Enable', 'off')
        
        popupmenu_orientation_Callback(hObject, eventdata, handles)
else
        set(handles.radio_3D, 'Value',1)
end

%--------------------------------------------------------------------------
function radio_3D_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_orientation_Callback(hObject, eventdata, handles)
if get(handles.radio_3D, 'Value')
        pos   = get(handles.popupmenu_orientation, 'Value');
        lview = get(handles.popupmenu_orientation, 'String');
        strv  = lview{pos};
        
        if strcmpi(strv, 'custom')
                set(handles.edit_customview, 'Enable', 'on')
        else
                switch strv
                        case {'front','f'}
                                mview = [-180,30];
                        case {'back','b'}
                                mview = [0,30];
                        case {'left','l'}
                                mview =  [-90,30];
                        case {'right','r'}
                                mview =  [90,30];
                        case {'frontright','fr'}
                                mview =  [135,30];
                        case {'backright','br'}
                                mview =  [45,30];
                        case {'frontleft','fl'}
                                mview =  [-135,30];
                        case {'backleft','bl'}
                                mview =  [-45,30];
                        case 'top'
                                mview =  [0,90];
                        otherwise
                                mview =  [];
                end
                set(handles.edit_customview, 'String', vect2colon(mview, 'Delimiter', 'off'))
                set(handles.edit_customview, 'Enable', 'off')
        end
else
        set(handles.edit_customview, 'String', '')
        set(handles.popupmenu_orientation, 'Enable', 'off')% sept 12, 2012. JLC
end

%--------------------------------------------------------------------------
function popupmenu_orientation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_customview_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_customview_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_measurement_Callback(hObject, eventdata, handles)
v = get(hObject, 'Value');
datatype = handles.datatype;
% switch v
%         case {1,4}
%                 set(handles.text_example,'String','e.g. 300 or 100:50:350 to plot scalp maps at 300 or at 100,150,200,...,350 ms')
%                 set(handles.checkbox_realtime, 'Enable', 'on');
%         case {2,3,5,6}
%                 set(handles.text_example,'String','e.g., 300 400 ; 400 500 to plot scalp maps for 300-400, 400-500 ms)')
%                 set(handles.checkbox_realtime, 'Enable', 'off');
% end
switch v
        case {1,3}
                if strcmpi(datatype, 'ERP')
                        set(handles.text_example,'String','e.g. 300 or 100:50:350 to plot scalp maps at 300 or at 100,150,200,...,350 ms')
                        set(handles.checkbox_realtime, 'Enable', 'on');
                else %FFT
                        set(handles.text_example,'String','e.g. 8 or 8:2:16 to plot scalp maps at 8 or at 8,10,12,...,16 Hz')
                        set(handles.checkbox_realtime, 'Enable', 'off');
                end
        case {2,4,5}
                if strcmpi(datatype, 'ERP')
                        set(handles.text_example,'String','e.g., 300 400 ; 400 500 to plot scalp maps for 300-400, 400-500 ms)')
                else %FFT
                        set(handles.text_example,'String','e.g., 8 12 ; 30 50 to plot scalp maps for 8-12, 30-50 Hz)')
                end
                set(handles.checkbox_realtime, 'Enable', 'off');
end

%--------------------------------------------------------------------------
function popupmenu_measurement_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_mapstyle_Callback(hObject, eventdata, handles)
% smapstyle = get(handles.popupmenu_mapstyle, 'Value');
% handles.smapstyle = smapstyle;
% 
% % Update handles structure
% guidata(hObject, handles);

%--------------------------------------------------------------------------
function checkbox_outside_Callback(hObject, eventdata, handles)
% if get(hObject,'Value')
%         
% else
%         
% end

%--------------------------------------------------------------------------
function popupmenu_mapstyle_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_splinefile_Callback(hObject, eventdata, handles)
ERP = handles.ERP;
chanlocs   = handles.chanlocs;
splinefile = handles.splinefile;

if isempty(splinefile)
        x = handles.splineinfo;
        splnfile = x.path;
else
        splnfile = splinefile;
end

%
% open gui
%
splineinfo = splinefileGUI({splnfile});

if isempty(splineinfo)
        disp('User selected Cancel')
        return
end

splinefile = splineinfo.path;

if isempty(splinefile)
        msgboxText =  'You must specify a name for the spline file.';
        title = 'ERPLAB: scalpplotGUI inputs';
        errorfound(msgboxText, title);
        
        handles.splinefile  = splinefile;
        
        % Update handles structure
        guidata(hObject, handles);
        
        set(handles.text_spline_warning, 'String','spline''s required!')
        set(handles.text_spline_warning, 'ForegroundColor', [0.71 0.1 0.1])
        return
end
if splineinfo.save
        if isempty(ERP.splinefile)
                ERP.splinefile = splinefile;
                ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'History', 'off');
        else
                question = ['This ERPset already has spline file info.\n'...
                        'Would you like to replace it?'];
                title_msg   = 'ERPLAB: spline file';
                button   = askquest(sprintf(question), title_msg);
                
                if ~strcmpi(button,'yes')
                        disp('User selected Cancel')
                        return
                else
                        ERP.splinefile = splinefile;
                        ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'History', 'off');
                end
        end
        splineinfo.save = 0;
        %plotset = evalin('base', 'plotset');
        %plotset.pscalp.splineinfo = splineinfo;
        %assignin('base','plotset',plotset)
        erplab redraw
end
if isempty(splinefile) && isempty(ERP.splinefile)
        set(handles.text_spline_warning, 'String','spline''s required!')
        set(handles.text_spline_warning, 'ForegroundColor', [0.71 0.1 0.1])
else
        set(handles.text_spline_warning, 'String','')
end

handles.ERP = ERP;
handles.splineinfo  = splineinfo;
handles.splinefile  = splinefile;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function pushbutton_browsebin_Callback(hObject, eventdata, handles)
listb = handles.listb;
indxlistb = handles.indxlistb;
indxlistb = indxlistb(indxlistb<=length(listb));
titlename = 'Select Bin(s)';

if get(hObject, 'Value')
        %set(handles.pushbutton_browsechan, 'Enable', 'off')
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
                title = 'ERPLAB: scalpplotGUI input';
                errorfound(msgboxText, title);
                return
        end
end

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
web https://github.com/lucklab/erplab/wiki/Topographic-Mapping -browser

%--------------------------------------------------------------------------
function checkbox_realtime_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        lat = get(handles.edit_latencies, 'String');
        if isempty(lat)
                msgboxText =  'You must specify a latency vector first.';
                title = 'ERPLAB: scalpplotGUI input';
                errorfound(msgboxText, title);
                return
        end
        lat = str2num(lat);
        T = unique_bc2(diff(lat));
        if isempty(T)
                msgboxText =  'You must specify a latency vector first.';
                title = 'ERPLAB: scalpplotGUI input';
                errorfound(msgboxText, title);
                return
        end
        if length(T)>1
                msgboxText =  ['The latency vector does not have a fixed step to determine its periodicity.\n\n'...
                        'You may use colon notation, e.g. start:step:end, to specify your latency vector.\n'...
                        'This may work better to generate the time of each frame.'];
                title = 'ERPLAB: scalpplotGUI input';
                errorfound(sprintf(msgboxText), title);
                return
        end
        f = round(1/(T/1000));
        set(handles.edit_fps, 'String', num2str(f));
        set(handles.edit_fps,'Enable', 'off')
else
        set(handles.edit_fps,'Enable', 'on')
end

%--------------------------------------------------------------------------
function checkbox_colorbar_Callback(hObject, eventdata, handles)
% checkbox_cbar
colorbar  = get(hObject, 'Value');
handles.Legcolorbar = colorbar;
% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function popupmenu_colormap_Callback(hObject, eventdata, handles)
Legcolormap = get(handles.popupmenu_colormap, 'Value');
handles.Legcolormap = Legcolormap;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function popupmenu_colormap_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
plotset = evalin('base', 'plotset');
plotset.pscalp = [];
handles.output = plotset;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        plotset = evalin('base', 'plotset');
        plotset.pscalp = [];
        handles.output = plotset;
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end
