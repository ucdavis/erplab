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
                        set(handles.figure_main,'Position', plotset.pscalp.posgui);
                end
        end
catch
        plotset.ptime  = [];
        plotset.pscalp = [];
        assignin('base','plotset',plotset)
end

handles.output   = plotset;
handles.indxline = 1;
handles.ispdf    = 0;
handles.isagif   = 0;

try
        ERP   = varargin{1};
        nchan = ERP.nchan;
        nbin  = ERP.nbin; % Total number of bins
catch
        ERP   = [];
        nchan = 0;
        nbin  = 0;
end

handles.nchan = nchan;
handles.nbin  = nbin;

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure_main,'Name', ['ERPLAB ' version '   -   SCALP MAPPING GUI'])

%
% Set GUI
%
if isempty(plotset.pscalp)
        set(handles.edit_latencies,'String','0');
        set(handles.radiobutton_insta,'Value',1);
        set(handles.radiobutton_BLC_pre,'Value',1);
        set(handles.edit_customblc,'Enable', 'off')
        set(handles.edit_custom,'Enable', 'off')
        set(handles.checkbox_agif,'Value', 0)
        set(handles.checkbox_colorbar,'Value', 1)
        set(handles.edit_delayt,'Enable', 'off')
        set(handles.edit_fnameagif,'Enable', 'off')
        set(handles.pushbutton_browseagif,'Enable', 'off')
else
        setall(hObject, eventdata, handles)
end

%
% Prepare List of current Bins
%
if ~isempty(ERP)
        listb = [];

        for b=1:nbin
                listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
        end

        set(handles.popupmenu_bins,'String', listb)
        drawnow
else
        set(handles.popupmenu_bins,'String', 'No Bins')
        drawnow
end

for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end

%
% Color GUI
%
handles = painterplab(handles);

% UIWAIT makes geterpvaluesGUI wait for user response (see UIRESUME)
uiwait(handles.figure_main);

%--------------------------------------------------------------------------
function varargout = scalplotGUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure_main);
pause(0.5)

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
function popupmenu_bins_Callback(hObject, eventdata, handles)

numbin   = get(hObject, 'Value');
nums = get(handles.edit_bins, 'String');
nums = [nums ' ' num2str(numbin)];
set(handles.edit_bins, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_bins_CreateFcn(hObject, eventdata, handles)

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
uiresume(handles.figure_main);

%--------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, eventdata, handles)

binArraystr    = strtrim(get(handles.edit_bins, 'String'));
latestr        = strtrim(get(handles.edit_latencies, 'String'));
customscale    = strtrim(get(handles.edit_custom, 'String'));
customscale    = regexprep(customscale,'''|"','');
nbin           = handles.nbin;
errorcusca     = 0;

if  ~strcmp(latestr, '') && ~isempty(latestr) && ...
                ~strcmp(binArraystr, '') && ~isempty(binArraystr)

        binArray    = str2num(binArraystr);

        if max(binArray)>nbin
                msgboxText{1} =  'Error: You have specified unexisting bins.';
                title = 'ERPLAB: scalplotGUI() error:';
                errorfound(msgboxText, title);
                return
        end

        if length(binArray)>length(unique(binArray))
                msgboxText{1} =  'Error: You have specified repeated bins.';
                title = 'ERPLAB: scalplotGUI() error:';
                errorfound(msgboxText, title);
                return
        end

        latencyArray = str2num(latestr);
        nlate = length(latencyArray);

        if (get(handles.radiobutton_mean, 'Value') && nlate<2) || ...
                        (get(handles.radiobutton_area, 'Value') && nlate<1)

                colorold = get(handles.edit_latencies, 'BackgroundColor');
                set(handles.edit_latencies, 'BackgroundColor', [1 0 0]);
                pause(0.1)
                set(handles.edit_latencies, 'BackgroundColor', colorold);
                %beep
        else

                if get(handles.radiobutton_insta, 'Value')
                        measurement = 'insta';
                end
                if get(handles.radiobutton_mean, 'Value')
                        measurement = 'mean';
                end
                if get(handles.radiobutton_area, 'Value')
                        measurement = 'area';
                end
                if get(handles.radiobutton_laplacian, 'Value')
                        measurement = 'lapla';
                end
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
                % Color Bar
                %
                clrbar = get(handles.checkbox_colorbar, 'Value');

                %
                % Show electrodes
                %
                showelec = get(handles.checkbox_electrodes, 'Value');

                %
                % Show bin number at legend
                %
                binleg = get(handles.checkbox_includenumberbin, 'Value');

                if get(handles.checkbox_agif, 'Value')
                        
                        if get(handles.checkbox_adjust1frame, 'Value')
                                isagif    = 2; % adjust first frame
                        else
                                isagif    = 1;
                        end
                        
                        delayt    = str2num(get(handles.edit_delayt, 'String'));
                        fnameagif = get(handles.edit_fnameagif, 'String');
                        
                        if isempty(delayt) || delayt<0 || delayt>655
                                msgboxText{1} =  'Error: You must specify a scalar value between 0 and 655 inclusive';
                                title = 'ERPLAB: scalplotGUI() error:';
                                errorfound(msgboxText, title);
                                return
                        end

                        if isempty(strtrim(fnameagif))
                                msgboxText{1} =  'Error: You must specify a valid file name for your animated GIF';
                                title = 'ERPLAB: scalplotGUI() error:';
                                errorfound(msgboxText, title);
                                return
                        else
                                [pthxz, fnamez, ext, versn] = fileparts(fnameagif);

                                if strcmp(ext,'')
                                        ext   = '.gif';
                                end

                                fnameagif = fullfile(pthxz,[ fnamez ext]);
                        end
                else
                        isagif    = 0;
                        delayt    = [];
                        fnameagif = '';
                end

                %
                % Prepares output
                %
                ispdf = 0;
                plotset = evalin('base', 'plotset');
                plotset.pscalp.binArray     = binArray;
                plotset.pscalp.latencyArray = latencyArray;
                plotset.pscalp.measurement = measurement;
                plotset.pscalp.baseline    = baseline;
                plotset.pscalp.cscale      = cscale;
                plotset.pscalp.colorbar    = clrbar;
                plotset.pscalp.ispdf       = ispdf;
                plotset.pscalp.agif.value  = isagif;
                plotset.pscalp.agif.delay  = delayt;
                plotset.pscalp.agif.fname  = fnameagif;
                plotset.pscalp.binleg      = binleg;
                plotset.pscalp.showelec    = showelec;
                plotset.pscalp.posgui      = get(handles.figure_main,'Position');
                handles.output             = plotset;

                % Update handles structure
                guidata(hObject, handles);
                uiresume(handles.figure_main);
        end
end

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

%--------------------------------------------------------------------------
function pushbutton_pdf_Callback(hObject, eventdata, handles)

plotset = evalin('base', 'plotset');
plotset.pscalp  = 'pdf';
handles.output = plotset;
guidata(hObject, handles);
uiresume(handles.figure_main);

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
function radiobutton_area_Callback(hObject, eventdata, handles)

set(hObject,'Value',1)
set(handles.text_example,'String','e.g. -100 0 or 120 200;300 400')

%--------------------------------------------------------------------------
function radiobutton_insta_Callback(hObject, eventdata, handles)

set(hObject,'Value',1)
set(handles.text_example,'String','e.g. 300 or -100:10:0 or 120 400')

%--------------------------------------------------------------------------
function radiobutton_mean_Callback(hObject, eventdata, handles)

set(hObject,'Value',1)
set(handles.text_example,'String','e.g. -100 0 or 120 200;300 400')

%--------------------------------------------------------------------------
function  setall(hObject, eventdata, handles)

plotset = handles.output;
binArraystr     = vect2colon(plotset.pscalp.binArray,'Delimiter','no');
latvals = plotset.pscalp.latencyArray;
latrows = size(latvals,1);

if latrows>1
        latencyArraystr = num2str(latvals);
        bb = cellstr(latencyArraystr);
        xs = ''; for t=1:length(bb);xs = [xs bb{t} ' ; '];end
        latencyArraystr = regexprep(xs,';\s*$','');
else
        latencyArraystr = vect2colon(latvals);
end

measurement = plotset.pscalp.measurement;
baseline    = plotset.pscalp.baseline;
cscale      = plotset.pscalp.cscale;
clrbar      = plotset.pscalp.colorbar;
showelec    = plotset.pscalp.showelec;
binleg      = plotset.pscalp.binleg;

if strcmpi(measurement,'insta')
        set(handles.radiobutton_insta,'Value',1);
        set(handles.text_example,'String','e.g. 300 or -100:10:0 or 120 400')
elseif strcmpi(measurement,'mean')
        set(handles.radiobutton_mean,'Value',1);
        set(handles.text_example,'String','e.g. -100 0 or 120 200;300 400')
elseif strcmpi(measurement,'area')
        set(handles.radiobutton_area,'Value',1);
        set(handles.text_example,'String','e.g. -100 0 or 120 200;300 400')
elseif strcmpi(measurement,'lapla')
        set(handles.radiobutton_laplacian,'Value',1);
else
        set(handles.radiobutton_insta,'Value',1); %default
        set(handles.text_example,'String','e.g. 300 or -100:10:0 or 120 400')
end

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

if ischar(cscale)
        if strcmpi(cscale,'maxmin')
                set(handles.radiobutton_maxmin,'Value',1);
        elseif strcmpi(cscale,'absmax')
                set(handles.radiobutton_absmax,'Value',1);
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
                set(handles.edit_custom,'String', num2str(cscale)); %custom
        end
end

if clrbar==1
        set(handles.checkbox_colorbar, 'Value', 1);
else
        set(handles.checkbox_colorbar, 'Value', 0);
end

if showelec==1
        set(handles.checkbox_electrodes, 'Value', 1);
else
        set(handles.checkbox_electrodes, 'Value', 0);
end

if binleg==1
        set(handles.checkbox_includenumberbin, 'Value', 1);
else
        set(handles.checkbox_includenumberbin, 'Value', 0);
end

set(handles.edit_bins,'String',binArraystr);
set(handles.edit_latencies,'String',latencyArraystr);

if isfield(plotset.pscalp, 'agif')
        
        agif      = plotset.pscalp.agif.value;
        delayt    = plotset.pscalp.agif.delay;
        fnameagif = plotset.pscalp.agif.fname;
        
        if agif>0
                set(handles.checkbox_agif,'Value', 1)
                
                set(handles.checkbox_adjust1frame,'Enable', 'on')
                set(handles.edit_delayt,'Enable', 'on')
                set(handles.edit_delayt,'String', num2str(delayt))
                set(handles.edit_fnameagif,'Enable', 'on')
                set(handles.edit_fnameagif,'String', fnameagif)
                set(handles.pushbutton_browseagif,'Enable', 'on')
                
                if agif==2
                        set(handles.checkbox_adjust1frame,'Value', 1)
                else
                        set(handles.checkbox_adjust1frame,'Value', 0)
                end
                
                set(handles.checkbox_adjust1frame,'Enable', 'on')
                
        else
                set(handles.checkbox_agif,'Value', 0)
                
                set(handles.checkbox_agif,'Value', 0)
                set(handles.checkbox_adjust1frame,'Value', 0)
                set(handles.checkbox_adjust1frame,'Enable', 'off')
                set(handles.edit_delayt,'Enable', 'off')
                set(handles.edit_fnameagif,'Enable', 'off')
                set(handles.pushbutton_browseagif,'Enable', 'off')
                set(handles.checkbox_adjust1frame,'Value', 0)
                set(handles.checkbox_adjust1frame,'Enable', 'off')
        end
else
        set(handles.checkbox_agif,'Value', 0)
        set(handles.checkbox_adjust1frame,'Value', 0)
        set(handles.checkbox_adjust1frame,'Enable', 'off')
        set(handles.edit_delayt,'Enable', 'off')
        set(handles.edit_fnameagif,'Enable', 'off')
        set(handles.pushbutton_browseagif,'Enable', 'off')
        set(handles.checkbox_adjust1frame,'Value', 0)
        set(handles.checkbox_adjust1frame,'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_exchan_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_exchan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_exchan_Callback(hObject, eventdata, handles)

numch   = get(hObject, 'Value');

nums = get(handles.edit_exchan, 'String');
nums = [nums ' ' num2str(numch)];
set(handles.edit_exchan, 'String', nums);

%--------------------------------------------------------------------------
function popupmenu_exchan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_agif_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.edit_delayt,'Enable', 'on')
        set(handles.edit_fnameagif,'Enable', 'on')
        set(handles.pushbutton_browseagif,'Enable', 'on')
        set(handles.checkbox_adjust1frame,'Enable', 'on')
        
else
        set(handles.edit_delayt,'Enable', 'off')
        set(handles.edit_fnameagif,'Enable', 'off')
        set(handles.pushbutton_browseagif,'Enable', 'off')
        set(handles.checkbox_adjust1frame,'Enable', 'off')
end

%--------------------------------------------------------------------------
function edit_fnameagif_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_fnameagif_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_browseagif_Callback(hObject, eventdata, handles)

%
% Save GIF
%
prename = get(handles.edit_fnameagif,'String');
[blfilename, blpathname, filterindex] = uiputfile({'*.gif';'*.*'},'Save Animated GIF as',prename);

if isequal(blfilename,0)
        disp('User selected Cancel')
        return
else

        [px, fname, ext, versn] = fileparts(blfilename);

        if strcmp(ext,'')
                if filterindex==1
                        ext   = '.gif';
                end
        end

        fname = [ fname ext];
        fullgifname = fullfile(blpathname, fname);
        set(handles.edit_fnameagif,'String', fullgifname);
        disp(['Animated GIF will be saved at ' fullgifname])
end

%--------------------------------------------------------------------------
function edit_delayt_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_delayt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_colorbar_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function figure_main_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure_main, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        plotset = evalin('base', 'plotset');
        plotset.pscalp = [];
        handles.output = plotset;
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure_main);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure_main);
end

%--------------------------------------------------------------------------
function checkbox_electrodes_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_includenumberbin_Callback(hObject, eventdata, handles)


function pushbutton_CLERPF_Callback(hObject, eventdata, handles)
clerpf


function checkbox_adjust1frame_Callback(hObject, eventdata, handles)
