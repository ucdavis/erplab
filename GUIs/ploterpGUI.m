% - This function is part of ERPLAB Toolbox -
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

function varargout = ploterpGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @ploterpGUI_OpeningFcn, ...
        'gui_OutputFcn',  @ploterpGUI_OutputFcn, ...
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
function ploterpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
try
        ERP   = varargin{1};
        nbin  = ERP.nbin;
        nchan = ERP.nchan;
        datatype = checkdatatype(ERP);
catch
    ERP   = [];
        nbin  = 1;
        nchan = 1;
        datatype = 'ERP';
end
if strcmpi(datatype, 'ERP')
        kktime = 1000;
else
        kktime = 1;
end

handles.kktime     = kktime;
handles.output     = [];
handles.ispdf      = 0;
handles.scalp      = 0;
handles.ismini     = 0;
handles.mxscale    = [];
handles.myscale    = [];
handles.timeticks  = [];
handles.linespeci  = [];
handles.linewidth  = [];
handles.styleline  = [];
handles.yticks     = [];
handles.ERP        = ERP;
handles.minorticks = [];
handles.counterbinwin  = [];
handles.counterchanwin = [];
handles.listch     = '';
handles.indxlistch = [];
handles.listb      = '';
handles.indxlistb  = [];
handles.nchan      = nchan;
handles.nbin       = nbin;

handles.stdalpha = 0.7;

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);
handles.datatype = datatype;

% Set GUI baseline to a default of zero for non-ERP-like data
[datatype, datatype2] = checkdatatype(ERP);
if strcmpi(datatype2,ERP) == 1
    radiobutton_BLC_no_Callback(hObject, eventdata, handles)
end





% Update handles structure
guidata(hObject, handles);





%
% Set all objects
%
setall(hObject, eventdata, handles)

% help
helpbutton
% pdfbutton
drawnow

% UIWAIT makes ploterpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);

%--------------------------------------------------------------------------
function varargout = ploterpGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
% try
plotset = evalin('base', 'plotset');
ispdf = handles.ispdf;
datatype = handles.datatype;
if ispdf
        %plotset = evalin('base', 'plotset');
        if strcmpi(datatype, 'ERP')
                plotset.ptime = 'pdf';
        else
                plotset.pfrequ = 'pdf';
        end
        handles.output = plotset;
end
scalp = handles.scalp;
if scalp
        %plotset = evalin('base', 'plotset');
        if strcmpi(datatype, 'ERP')
                plotset.ptime  = 'scalp';
        else
                plotset.pfrequ  = 'scalp';
        end
        handles.output = plotset;
        varargout{1}   = handles.output;
        ERP = handles.ERP;
        varargout{2} = ERP;
        
        % The figure can be deleted now
        delete(handles.gui_chassis);
        %ERP = evalin('base', 'ERP');
        ERP = pop_scalplot(ERP);
        return
end
% ismini = handles.ismini;
% if ismini
%         %plotset = evalin('base', 'plotset');
%         plotset.ptime = 'mini';
%         handles.output = plotset;
% end
varargout{1} = handles.output;
varargout{2} = handles.ERP;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)
% catch
%         % The figure can be deleted now
%         varargout{1} = [];
%         varargout{2} = [];
%         %delete(get(0,'CurrentFigure'));
%         perpgui    = findobj('Tag', 'ploterp_fig');
%         if ~isempty(perpgui)
%                 delete(perpgui);
%         end
%         pause(0.01)
% end

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)
if get(handles.radiobutton_yauto, 'Value')
        yscaleauto(hObject, eventdata, handles)
end

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_chans_Callback(hObject, eventdata, handles)
chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);
if get(handles.radiobutton_yauto, 'Value')
        yscaleauto(hObject, eventdata, handles)
end

%
% Creates square subploting
%
pbox = squareplot(chanArray, hObject, eventdata, handles);
set(handles.popupmenu_rows, 'Value', pbox(1))
set(handles.popupmenu_columns, 'Value', pbox(2))

%--------------------------------------------------------------------------
function edit_chans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function listbox1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function listbox1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function listbox2_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function listbox2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_time_range_Callback(hObject, eventdata, handles)
timex = str2num(get(handles.edit_time_range, 'String'));
if length(timex)~=2
        msgboxText =  'Please, enter two values';
        title = 'ERPLAB: pop_ploterps() wrong number of inputs.';
        errorfound(msgboxText, title);
        return
end

%--------------------------------------------------------------------------
function edit_time_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_BLC_no_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_BLC_pre, 'Value', 0)
        set(handles.radiobutton_BLC_post, 'Value', 0)
        set(handles.radiobutton_BLC_whole, 'Value', 0)
        set(handles.radiobutton_BLC_custom, 'Value', 0)
        BackERPLABcolor = handles.BackERPLABcolor;
        set(handles.edit_custom, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_custom, 'Enable', 'inactive')
        set(handles.edit_custom, 'String', 'none')
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_BLC_pre_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_BLC_no, 'Value', 0)
        set(handles.radiobutton_BLC_post, 'Value', 0)
        set(handles.radiobutton_BLC_whole, 'Value', 0)
        set(handles.radiobutton_BLC_custom, 'Value', 0)
        BackERPLABcolor = handles.BackERPLABcolor;
        set(handles.edit_custom, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_custom, 'Enable', 'inactive')
        ERP = handles.ERP;
        kktime = handles.kktime;
        set(handles.edit_custom, 'String', sprintf('%.1f  %g',ceil(ERP.xmin*kktime), 0))
        
        %adjust yscale for prestim 
        
        
        
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_BLC_post_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_BLC_no, 'Value', 0)
        set(handles.radiobutton_BLC_pre, 'Value', 0)
        set(handles.radiobutton_BLC_whole, 'Value', 0)
        set(handles.radiobutton_BLC_custom, 'Value', 0)
        BackERPLABcolor = handles.BackERPLABcolor;
        set(handles.edit_custom, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_custom, 'Enable', 'inactive')
        ERP = handles.ERP;
        kktime = handles.kktime;
        set(handles.edit_custom, 'String', sprintf('%g  %.1f', 0, floor(ERP.xmax*kktime)))
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_BLC_whole_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_BLC_no, 'Value', 0)
        set(handles.radiobutton_BLC_pre, 'Value', 0)
        set(handles.radiobutton_BLC_post, 'Value', 0)
        set(handles.radiobutton_BLC_custom, 'Value', 0)
        BackERPLABcolor = handles.BackERPLABcolor;
        set(handles.edit_custom, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_custom, 'Enable', 'inactive')
        ERP = handles.ERP;
        kktime = handles.kktime;
        set(handles.edit_custom, 'String', sprintf('%.1f  %.1f',ceil(ERP.xmin*kktime), floor(ERP.xmax*kktime)))
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function radiobutton_BLC_custom_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_BLC_no, 'Value', 0)
        set(handles.radiobutton_BLC_pre, 'Value', 0)
        set(handles.radiobutton_BLC_post, 'Value', 0)
        set(handles.radiobutton_BLC_whole, 'Value', 0)
        set(handles.edit_custom, 'BackgroundColor', [1 1 1])
        set(handles.edit_custom, 'Enable', 'on')
else
        set(hObject, 'Value', 1)
end

%--------------------------------------------------------------------------
function edit_custom_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_custom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_rows_Callback(hObject, eventdata, handles)
isMGFP       = get(handles.checkbox_MGFP, 'Value');
chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);
row = get(handles.popupmenu_rows, 'Value');
col = ceil((numel(chanArray)+isMGFP)/row);
if col<=0
        col=1;
end
set(handles.popupmenu_columns, 'Value', col);

%--------------------------------------------------------------------------
function popupmenu_rows_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_columns_Callback(hObject, eventdata, handles)
isMGFP       = get(handles.checkbox_MGFP, 'Value');
chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);
col = get(handles.popupmenu_columns, 'Value');
row = ceil((numel(chanArray)+isMGFP)/col);
if row<=0
        row=1;
end
set(handles.popupmenu_rows, 'Value', row);

%--------------------------------------------------------------------------
function popupmenu_columns_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_font_channel_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_font_channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_font_legend_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_font_legend_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_stdev_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        ERP = handles.ERP;
        if isempty(ERP.binerror)
                msgboxText =  '%s has no measure of dispersion.\n';
                title = 'ERPLAB: pop_ploterps() missing info:';
                errorfound(sprintf(msgboxText, ERP.erpname), title);
                set(handles.checkbox_stdev,'Value', 0)
                set(handles.popupmenu_std_factor,'Enable','off')
                set(handles.popupmenu_transpa,'Enable','off')
                return
        else
                set(handles.checkbox_stdev,'Value', 1)
                set(handles.popupmenu_std_factor,'Enable','on')
                set(handles.popupmenu_transpa,'Enable','on')
                set(handles.popupmenu_transpa,'Value', round(handles.stdalpha*10)+1)
                valf = get(handles.popupmenu_std_factor,'Value');
                if valf==1
                        set(handles.popupmenu_std_factor,'Value',2)
                end
        end
else
        set(handles.popupmenu_std_factor,'Enable', 'off')
        set(handles.popupmenu_transpa,'Enable','off')
end

%--------------------------------------------------------------------------
function checkbox_toolbar_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_help_Callback(hObject, eventdata, handles)
% doc pop_ploterps
web https://github.com/lucklab/erplab/wiki/Plotting-ERP-Waveforms -browser

%--------------------------------------------------------------------------
function pushbutton_plot_Callback(hObject, eventdata, handles)
binArray   = str2num(get(handles.edit_bins, 'String'));
chanArray  = str2num(get(handles.edit_chans, 'String'));
datatype   = handles.datatype;

[chk, msgboxText] = chckbinandchan(handles.ERP, binArray, chanArray);
if chk>0
        title = 'ERPLAB: ploterp GUI input';
        errorfound(msgboxText, title);
        return
end

plotset = getplotset(hObject, eventdata, handles);

if strcmpi(datatype, 'ERP')        
        if isempty(plotset.ptime)
                return
        end
else
        if isempty(plotset.pfrequ) %FFT
                return
        end
end

handles.output = plotset;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


%--------------------------------------------------------------------------
function edit_yscale_Callback(hObject, eventdata, handles)
yyscale = str2num(get(handles.edit_yscale, 'String'));
if length(yyscale)~=2
        msgboxText =  'Please, enter two values.';
        title = 'ERPLAB: pop_ploterps() wrong number of inputs.';
        errorfound(msgboxText, title);
        return
end
if yyscale(1)>yyscale(2)
        yyscale  = circshift(yyscale',1)';
        set(handles.edit_yscale, 'String', num2str(yyscale)); % XL
        %
        % Y polarity button
        %
        if ~get(handles.togglebutton_y_axis_polarity, 'Value')
                word = 'negative';
                set(handles.togglebutton_y_axis_polarity, 'Value',1);
                set(handles.togglebutton_y_axis_polarity, 'string', sprintf('<HTML><center><b>%s</b> is up', word));
        end
end

%--------------------------------------------------------------------------
function edit_yscale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_yauto_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        ERP       = handles.ERP;
        kktime = handles.kktime;
        chanArray = str2num(get(handles.edit_chans, 'String'));
        binArray  = str2num(get(handles.edit_bins, 'String'));
        fs        = ERP.srate;
        
        [chk, msgboxText] = chckbinandchan(ERP, binArray, chanArray);
        if chk>0
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                set(handles.radiobutton_yauto, 'Value',0)
                drawnow
                return
        end
        xxlim      = str2num(get(handles.edit_time_range, 'String'));
        if isempty(xxlim)
                msgboxText =  'You have not specified a time range';
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                set(handles.radiobutton_yauto, 'Value',0)
                drawnow
                return
        end
        if xxlim(1)<round(ERP.xmin*kktime)
                aux_xxlim(1) = round(ERP.xmin*kktime);
        else
                aux_xxlim(1) = xxlim(1);
        end
        if xxlim(2)>round(ERP.xmax*kktime)
                aux_xxlim(2) = round(ERP.xmax*kktime);
        else
                aux_xxlim(2) = xxlim(2);
        end
        
        [xp1, xp2, checkw] = window2sample(ERP, aux_xxlim(1:2) , fs, 'relaxed');
        
        if checkw==1
                msgboxText =  'Time window cannot be larger than epoch.';
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                set(handles.radiobutton_yauto, 'Value',0)
                drawnow
                return
        elseif checkw==2
                msgboxText =  'Too narrow time window';
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                set(handles.radiobutton_yauto, 'Value',0)
                drawnow
                return
        end
        
        BackERPLABcolor = handles.BackERPLABcolor;
        set(handles.edit_yscale, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_yscale, 'Enable', 'inactive')
        yscaleauto(hObject, eventdata, handles)
else
        set(handles.edit_yscale, 'BackgroundColor', [1 1 1])
        set(handles.edit_yscale, 'Enable', 'on')
end

%--------------------------------------------------------------------------
function togglebutton_y_axis_polarity_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        word = 'negative';
else
        word = 'positive';
end
set(hObject, 'string', sprintf('<HTML><center><b>%s</b> is up', word));

%--------------------------------------------------------------------------
function pbox = squareplot(chanArray, hObject, eventdata, handles)
newnch = numel(chanArray);
if get(handles.checkbox_MGFP, 'Value')
        newnch = newnch + 1;
end
dsqr   = round(sqrt(newnch));
sqrdif = dsqr^2 - newnch;
if sqrdif<0
        pbox(1) = dsqr + 1;
else
        pbox(1) = dsqr;
end
pbox(2) = dsqr;
if pbox(1)<=0  % JLC. 11/05/13
        pbox(1)=1;
end
if pbox(2)<=0  % JLC. 11/05/13
        pbox(2)=1;
end

%--------------------------------------------------------------------------
function checkbox_MGFP_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
        set(handles.edit_MGFP_chans,'Enable','on')
        set(handles.pushbutton_sameaschan,'Enable','on')
else
        set(handles.edit_MGFP_chans,'String','')
        set(handles.edit_MGFP_chans,'Enable','off')
        set(handles.pushbutton_sameaschan,'Enable','off')
end
chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);

%
% Creates square subploting
%
pbox = squareplot(chanArray, hObject, eventdata, handles);
set(handles.popupmenu_rows, 'Value', pbox(1))
set(handles.popupmenu_columns, 'Value', pbox(2))

%--------------------------------------------------------------------------
function edit_MGFP_chans_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_MGFP_chans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_includenumberbin_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_show_number_ch_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_plotallchannels_Callback(hObject, eventdata, handles)
nchan = handles.nchan;
if get(hObject, 'Value')
        set(handles.edit_chans, 'String', vect2colon([1:nchan], 'Delimiter', 'off'));
        set(handles.edit_chans, 'Enable', 'off');
        set(handles.pushbutton_browsechan, 'Enable', 'off');
        
        if get(handles.radiobutton_yauto, 'Value')
                yscaleauto(hObject, eventdata, handles)
        end
else
        set(handles.edit_chans, 'Enable', 'on');
        set(handles.pushbutton_browsechan, 'Enable', 'on');
end

chanArray = str2num(get(handles.edit_chans, 'String'));
if isempty(chanArray)
        chanArray=1:nchan;
end

%
% Creates square subploting
%
pbox = squareplot(chanArray, hObject, eventdata, handles);
set(handles.popupmenu_rows, 'Value', pbox(1))
set(handles.popupmenu_columns, 'Value', pbox(2))

%--------------------------------------------------------------------------
function checkbox_plotallbins_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        ERP = handles.ERP;
        nbin = ERP.nbin;
        set(handles.edit_bins, 'String', vect2colon([1:nbin], 'Delimiter', 'off'));
        set(handles.edit_bins, 'Enable', 'off');
        set(handles.pushbutton_browsebin, 'Enable', 'off');
        
        if get(handles.radiobutton_yauto, 'Value')
                yscaleauto(hObject, eventdata, handles)
        end
else
        set(handles.edit_bins, 'Enable', 'on');
        set(handles.pushbutton_browsebin, 'Enable', 'on');
end

%--------------------------------------------------------------------------
function popupmenu_legepos_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_legepos_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_ibckground_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_ibckground_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)
plotset = evalin('base', 'plotset');
plotset.ptime  = [];
plotset.pfrequ = [];
assignin('base','plotset', plotset);
setall(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_scalp_Callback(hObject, eventdata, handles)
plotset  = getplotset(hObject, eventdata, handles);
datatype = handles.datatype;

if strcmpi(datatype, 'ERP')       
        if isempty(plotset.ptime)
                return
        else
                plotset.pscalp.binArray     = plotset.ptime.binArray;
                plotset.pscalp.latencyArray = 0;
                plotset.pscalp.exchanArray  = [];
                plotset.pscalp.measurement  = 'insta';
                plotset.pscalp.baseline = 'pre';
                plotset.pscalp.cscale   = 'maxmin';
                
                %plotset.pscalp.colorbar = 1;
                plotset.pscalp.ispdf    = 0;
                
                %plotset.pscalp.binleg   = 1;
                %plotset.pscalp.showelec = 1;
                %plotset.pscalp.ismaxim  = 0;
                plotset.pscalp.mtype   = '2D'; % map type  0=2D; 1=3D
                plotset.pscalp.smapstyle = 'both';   % map style: 'fill' 'both' 

                plotset.pscalp.mapview = 0; % numeric
                plotset.pscalp.mapoutside = 0;
                
                %       plegend       = plotset.pscalp.plegend; % numeric
                plotset.pscalp.plegend.binnum     = 1;
                plotset.pscalp.plegend.bindesc    = 0;
                plotset.pscalp.plegend.type       = 1;
                plotset.pscalp.plegend.latency    = 1;
                plotset.pscalp.plegend.electrodes = 1;
                
                plotset.pscalp.plegend.elestyle   = 'on';
                plotset.pscalp.plegend.elec3D     = 'off';
                
                plotset.pscalp.plegend.colorbar   = 1;
                plotset.pscalp.plegend.maximize   = 0;
                plotset.pscalp.plegend.colormap   = 1;
                
                assignin('base','plotset', plotset);
                handles.scalp = 1;
                %Update handles structure
                guidata(hObject, handles);
                uiresume(handles.gui_chassis);
        end
else
        if isempty(plotset.pfrequ)
                return
        else
                plotset.pscalp.binArray     = plotset.pfrequ.binArray;
                plotset.pscalp.latencyArray = 10;
                plotset.pscalp.exchanArray  = [];
                plotset.pscalp.measurement  = 'insta';
                plotset.pscalp.baseline = 'none';
                plotset.pscalp.cscale   = 'maxmin';
                
                %plotset.pscalp.colorbar = 1;
                plotset.pscalp.ispdf    = 0;
                
                %plotset.pscalp.binleg   = 1;
                %plotset.pscalp.showelec = 1;
                %plotset.pscalp.ismaxim  = 0;
                plotset.pscalp.mtype   = '2D'; % map type  0=2D; 1=3D
                plotset.pscalp.smapstyle = 'both';   % map style: 'fill' 'both' 
                plotset.pscalp.mapview = 0; % numeric
                plotset.pscalp.smapstyle = 'both';   % map style: 'fill' 'both' 
                
                %       plegend       = plotset.pscalp.plegend; % numeric
                plotset.pscalp.plegend.binnum     = 1;
                plotset.pscalp.plegend.bindesc    = 1;
                plotset.pscalp.plegend.type       = 1;
                plotset.pscalp.plegend.latency    = 1;
                plotset.pscalp.plegend.electrodes = 1;
                
                plotset.pscalp.plegend.elestyle   = 'on';
                plotset.pscalp.plegend.elec3D     = 'off';
                
                plotset.pscalp.plegend.colorbar   = 1;
                plotset.pscalp.plegend.maximize   = 0;
                plotset.pscalp.plegend.colormap   = 1;
                
                assignin('base','plotset', plotset);
                handles.scalp = 1;
                %Update handles structure
                guidata(hObject, handles);
                uiresume(handles.gui_chassis);
        end
end

%--------------------------------------------------------------------------
function plotset = getplotset(hObject, eventdata, handles)
ERP      = handles.ERP;
[datatype datatype2] = checkdatatype(ERP);

if strcmpi(datatype, 'ERP')
        kktime = 1000;
else
        kktime = 1;
end

kktime     = handles.kktime;
plotset    = evalin('base', 'plotset');
binArray   = str2num(get(handles.edit_bins, 'String'));
chanArray  = str2num(get(handles.edit_chans, 'String'));
xautoticks = get(handles.checkbox_autotimeticks, 'Value');
yautoticks = get(handles.checkbox_autoyticks, 'Value');
ibckground = get(handles.popupmenu_ibckground, 'Value')-1;

%
% X scale
%
timew = str2num(get(handles.edit_time_range, 'String')); % XL

if xautoticks
        timeticks = str2num(char(default_time_ticks(ERP, timew)));
else
        timeticks = handles.timeticks;
end

linewidth = handles.linewidth;
pstyle    = get(handles.popupmenu_plotstyle, 'Value');

if size(timew,1)~=1  || size(timew,2)~=2
        if strcmpi(datatype, 'ERP')
                msgboxText =  'Wrong time range to plot!';
                plotset.ptime = [];
        else
                msgboxText =  'Wrong frequency range to plot!';
                plotset.pfrequ = [];
        end
        title      = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);        
        return
end
if timew(1)==timew(2)
        if strcmpi(datatype, 'ERP')
                msgboxText =  'Wrong time range to plot!';
                plotset.ptime = [];
        else
                msgboxText =  'Wrong frequency range to plot!';
                plotset.pfrequ = [];
        end
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);        
        return
end
if timew(1)>timew(2)
        if strcmpi(datatype, 'ERP')
                msgboxText = ['Inverted time range to plot!\n'...
                        'Values will be adjusted.'];
        else
                msgboxText = ['Inverted frequency range to plot!\n'...
                        'Values will be adjusted.'];
        end
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        timew  = circshift(timew',1)';
end
if ~isempty(timeticks)
        if pstyle==4 % topo
                %                   title = 'ERPLAB: ploterpGUI inputs';
                %                   question = ['Sorry, time ticks for topographic plotting are not available\n'...
                %                         'at current ERPLAB version\n'...
                %                         'Ticks values will be ignored.\n\n'...
                %                         'Do you want to continue anyway?'];
                %                   button = askquest(sprintf(question), title);
                %
                %                   if ~strcmpi(button,'yes')
                %                         disp('User selected Cancel')
                %                         plotset.ptime = [];
                %                         return
                %                   end
        else
                if ~issorted(timeticks) ||  isrepeated(timeticks)
                        msgboxText = 'Tick values must be monotonically increasing!\n';
                        title = 'ERPLAB: ploterpGUI inputs';
                        errorfound(sprintf(msgboxText), title);
                        if strcmpi(datatype, 'ERP')
                                plotset.ptime = [];
                        else
                                plotset.pfrequ = [];
                        end
                        return
                end
        end
end

if strcmpi(datatype, 'ERP')  
        if get(handles.radiobutton_BLC_no, 'Value')
                blcorr = 'no';
        end
        if get(handles.radiobutton_BLC_pre, 'Value')
                blcorr = 'pre';   
        end
        if get(handles.radiobutton_BLC_post, 'Value')
                blcorr = 'post';
        end
        if get(handles.radiobutton_BLC_whole, 'Value')
                blcorr = 'all';
        end
        if get(handles.radiobutton_BLC_custom, 'Value')
                blcorr = get(handles.edit_custom, 'String');
                cmpbasel = str2num(blcorr);
                if isempty(cmpbasel)
                        if strcmpi(blcorr,'none')
                                blcorr = 'no';
                        end
                        if ~ismember_bc2(lower(blcorr),{'no' 'pre' 'post' 'all'})
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText =  'Wrong baseline range!';
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(msgboxText, title);
                                set(handles.radiobutton_BLC_custom, 'Value', 0);
                                set(handles.radiobutton_BLC_pre, 'Value', 1);
                                plotset.ptime = [];
                                return
                        end
                else
                        if size(cmpbasel,1)~=1  || size(cmpbasel,2)~=2
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText =  'Wrong baseline range!';
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(msgboxText, title);
                                set(handles.radiobutton_BLC_custom, 'Value', 0);
                                set(handles.radiobutton_BLC_no, 'Value', 1);
                                %plotset = evalin('base', 'plotset');
                                plotset.ptime = [];
                                return
                        end
                        if cmpbasel(1)>cmpbasel(2)
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText = ['Inverted baseline range!.\n'...
                                        'Values will be adjusted.'];
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(sprintf(msgboxText), title);
                                cmpbasel  = circshift(cmpbasel',1)'; %
                        end
                        if abs((cmpbasel(2)/kktime-cmpbasel(1)/kktime)*ERP.srate)<1
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                title = 'ERPLAB: ploterpGUI inputs';
                                question = ['You are specifying 1 point per baseline correction!\n'...
                                        'Do you want to continue anyway?'];
                                button = askquest(sprintf(question), title);
                                
                                if ~strcmpi(button,'yes')
                                        disp('User selected Cancel')
                                        %plotset = evalin('base', 'plotset');
                                        plotset.ptime = [];
                                        return
                                end
                        end
                        if cmpbasel(1)<ERP.xmin*kktime
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText = ['Wrong lower baseline value!\n'...
                                        'Value will be adjusted.'];
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(sprintf(msgboxText), title);
                                cmpbasel(1)=ceil(ERP.xmin*kktime);
                        end
                        if cmpbasel(2)>ERP.xmax*kktime
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText = ['Wrong upper baseline value!\n'...
                                        'Value will be adjusted.'];
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(sprintf(msgboxText), title);
                                cmpbasel(2) = floor(ERP.xmax*kktime);
                        end
                        blcorr = num2str(cmpbasel);
                end
        end
else % For non-ERP secondary datatypes (power, SEM), set no baseline default
        blcorr = 'no';
end

%
% Y scale
%
yyscale = str2num(get(handles.edit_yscale, 'String')); % YL

if yautoticks
        yticks = str2num(char(default_amp_ticks(ERP, binArray, yyscale)));
        yticks = unique(yticks); 
else
        yticks = unique(handles.yticks);
end
if size(yyscale,1)~=1 || size(yyscale,2)~=2
        if strcmpi(datatype, 'ERP')
                msgboxText =  'Wrong time range to plot!';
                plotset.ptime = [];
        else
                msgboxText =  'Wrong frequency range to plot!';
                plotset.pfrequ = [];
        end
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);      
        return
end
if yyscale(1)==yyscale(2)
        if strcmpi(datatype, 'ERP')
                msgboxText =  ['Wrong Y range to plot!\n'...
                        'Y limits must be different, dude.'];
                plotset.ptime = [];
        else
                msgboxText =  ['Wrong Y range to plot!\n'...
                        'Y limits must be different, dude.'];
                plotset.pfrequ = [];
        end
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        %plotset = evalin('base', 'plotset');
        
        return
end
if yyscale(1)>yyscale(2)
        msgboxText = ['Inverted scale range to plot!\n'...
                'Values will be adjusted.'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        yyscale  = circshift(yyscale',1)'; %        
end
if ~isempty(yticks)
        if pstyle==4 % topo
                %                   title = 'ERPLAB: ploterpGUI inputs';
                %                   question = ['Sorry, Y ticks for topographic plotting are not available\n'...
                %                         'at current ERPLAB version\n'...
                %                         'Ticks values will be ignored.\n\n'...
                %                         'Do you want to continue anyway?'];
                %                   button = askquest(sprintf(question), title);
                %
                %                   if ~strcmpi(button,'yes')
                %                         disp('User selected Cancel')
                %                         plotset.ptime = [];
                %                         return
                %                   end
        else
                if ~issorted(yticks)   ||  isrepeated(yticks)
                        if strcmpi(datatype, 'ERP')
                                msgboxText = 'Tick values must be monotonically increasing!\n';
                                plotset.ptime = [];
                        else
                                msgboxText = 'Tick values must be monotonically increasing!\n';
                                plotset.pfrequ = [];
                        end
                        title = 'ERPLAB: ploterpGUI inputs';
                        errorfound(sprintf(msgboxText), title);                        
                        return
                end
        end
end
if get(handles.togglebutton_y_axis_polarity, 'Value')
        isiy = 1;  % is inverted, positive down
else
        isiy = 0;  % is not inverted, positive up
end

fschan     = get(handles.popupmenu_font_channel, 'Value');
fslege     = get(handles.popupmenu_font_legend, 'Value');
fsaxtick   = get(handles.popupmenu_font_axistick, 'Value');
pstyle     = get(handles.popupmenu_plotstyle, 'Value');
errorstd   = get(handles.checkbox_stdev, 'Value');

if errorstd==1
        valf = get(handles.popupmenu_std_factor,'Value');
        if valf>1
                errorstd = get(handles.popupmenu_std_factor, 'Value')-1;
        end
end

stdalpha       = (get(handles.popupmenu_transpa,'Value')-1)/10;
pbox(1)        = get(handles.popupmenu_rows, 'Value');
pbox(2)        = get(handles.popupmenu_columns, 'Value');
counterwin     = [handles.counterbinwin handles.counterchanwin];
holdch         = 0;
yauto          = get(handles.radiobutton_yauto, 'Value');
binleg         = get(handles.checkbox_includenumberbin, 'Value');
chanleg        = ~get(handles.checkbox_show_number_ch, 'Value');
isMGFP         = get(handles.checkbox_MGFP, 'Value');
chanArray_MGFP = str2num(get(handles.edit_MGFP_chans, 'String'));
plotallbin     = get(handles.checkbox_plotallbins, 'Value');;
plotallch      = get(handles.checkbox_plotallchannels, 'Value');

if isMGFP && isempty(chanArray_MGFP)
        %isMGFP = 0;
        msgboxText = ['It looks like you want to include a mean global field power (MGFP) channel.\n'...
                'However, there is no specified channels for doing so...'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        if strcmpi(datatype, 'ERP')
                plotset.ptime = [];
        else
                plotset.pfrequ = [];
        end
        return
end

legepos  = get(handles.popupmenu_legepos, 'Value');
ismaxim  = get(handles.checkbox_maximize, 'Value');

%
% width and height for topoplot
%
axsizeW  = str2num(get(handles.edit_topowidth, 'String'));

if isempty(axsizeW) && pstyle==4 % topo
        msgboxText = ['For topographic view, you must specify a value for width.\n'...
                'Value should be within 0 < width <= 1'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
end
if (axsizeW>1 || axsizeW<=0)  && pstyle==4 % topo
        msgboxText = ['For topographic view, you must specify a value for width.\n'...
                'Value should be within 0 < width <= 1'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
end

axsizeH  = str2num(get(handles.edit_topoheight, 'String'));

if isempty(axsizeH) && pstyle==4 % topo
        msgboxText = ['For topographic view, you must specify a value for height.\n'...
                'Value should be within 0 < width <= 1'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
end
if (axsizeH>1 || axsizeH<=0)  && pstyle==4 % topo
        msgboxText = ['For topographic view, you must specify a value for height.\n'...
                'Value should be within 0 < width <= 1'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
end

% if istopo
axsize = [axsizeW axsizeH];
%else
minorticks = handles.minorticks; %[get(handles.checkbox_minorticksX, 'Value') get(handles.checkbox_minorticksY, 'Value')];
linespeci  = handles.linespeci;
%end
xxscale = [timew timeticks];
yyscale = [yyscale yticks];
posgui  = get(handles.gui_chassis,'Position');
posfig  = [];


%if user previously selected to input custom scales
if ~get(handles.radiobutton_yauto, 'Value')
    custom_yscale = {yyscale}; %first 2 cells dedicated to this in erpworkingmemory
    erpworkingmemory('pop_ploterpGUI', custom_yscale); 
end


%
% Set read values in plotset
%
if strcmpi(datatype, 'ERP')
        setplotset_time % call script
else
        setplotset_frequ % call script
end

%--------------------------------------------------------------------------
function setall(hObject, eventdata, handles)
try
        ERP = handles.ERP;
        if isempty(ERP)
                ERP = buildERPstruct([]);
                ERP.xmin  = 0;
                ERP.xmax  = 0;
                ERP.nbin  = 0;
                ERP.nchan = 0;
                handles.ERP = ERP;
        end
        CURRENTERP =  evalin('base', 'CURRENTERP');
catch %ME
        ERP = buildERPstruct([]);
        ERP.xmin  = 0;
        ERP.xmax  = 0;
        ERP.nbin  = 0;
        ERP.nchan = 0;
        handles.ERP = ERP;
        CURRENTERP = 0;
end
handles.ispdf = 0;
datatype = handles.datatype;
kktime   = handles.kktime;

%
% Name & version
%
version = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   ERP Plotting GUI  -  ' ERP.erpname],...
        'tag','ploterp_fig','NextPlot','new')

try
        plotset = evalin('base', 'plotset');
catch
        plotset.ptime  = [];
        plotset.pfrequ = [];
        plotset.pscalp = [];
end
try
        if ERP.nchan<1
                plotset.ptime  = [];
                plotset.pfrequ = [];
        end
catch
        plotset.ptime  = [];
        plotset.pfrequ = [];
end

BackERPLABcolor = geterplabcolor;
handles.BackERPLABcolor = BackERPLABcolor;
set(handles.checkbox_includenumberbin, 'Value', 1)

% if ~ispc
%         set(handles.pushbutton_pdf, 'ForegroundColor', [0 0 0])
% end
if strcmpi(datatype, 'ERP')
        if ~isempty(plotset.ptime)
                
                %
                % Get the plotset struct
                %
                getplotset_time
                defs   = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
                defcol = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w' };
                
                if isempty(linespeci)
                        colorline = [];
                        styleline = [];
                else
                        colorline = regexp(linespeci,'\w*','match');
                        colorline = [colorline{:}];
                        styleline = regexp(linespeci,'\W*','match');
                        styleline = [styleline{:}];
                end
                if isempty(colorline)
                        colorline  = repmat(defcol,1, ERP.nbin*length(defs));% sorted according 1st erplab's version
                        d = repmat(defs',1, ERP.nbin*length(defcol));
                        styleline = reshape(d',1, numel(d));
                else
                        defcol = unique_bc2(colorline);
                        if isempty(styleline)
                                d = repmat(defs',1, ERP.nbin*length(defcol));
                                styleline = reshape(d',1, numel(d));
                        else
                                for i=1:length(styleline)
                                        if isempty(styleline{i})
                                                styleline{i} = '-';
                                        end
                                end
                        end
                end
                if isMGFP==0
                        chanArray_MGFP =[];
                end
                if isempty(axsize) %&& istopo==1
                        axsize = [0.05 0.08];
                end
        else
                %
                % ticks for time
                %
                xtickarray = str2num(char(default_time_ticks(ERP)));
                xxs1       = ceil(kktime*ERP.xmin);
                xxs2       = floor(kktime*ERP.xmax);
                
                % Default values
                binArray       = 1:ERP.nbin;
                plotallbin     = 1;
                chanArray      = 1:ERP.nchan;
                plotallch      = 1;
                chanArray_MGFP = [];
                blcorr         = 'pre';  %by default
                xxscale        = [xxs1 xxs2 xtickarray];
                [ytarr, miny, maxy] = default_amp_ticks(ERP, binArray);
                ytickarray        = str2num(char(ytarr));
                yyscale        = [miny maxy ytickarray];
                linewidth      = 1;
                isiy           = 0;
                fschan         = 10;
                fslege         = 12;
                fsaxtick       = 10;
                %meap          = 1;
                pstyle         = 3; % 1 =matlab style 1; 2 =matlab style 2; 3= classic; 4= topographic
                errorstd       = 0; % pointer for std factor
                stdalpha       = 0.7; % transparency for plotting standard error
                pbox           = squareplot(chanArray, hObject, eventdata, handles);
                %counterbinwin  = 1;
                counterwin     = [1 1];
                holdch         = 0; % to draw different channels for same bin in one figure
                yauto          = 1;
                xautoticks     = 1;
                yautoticks     = 1;
                binleg         = 1;
                chanleg        = 1; % 1 means show chan labels
                isMGFP         = 0;
                ismaxim        = 1; % maximize figure
                %istopo         = 0;
                axsize         = [];
                minorticks     = [0 0];
                legepos        = 1; % legend position=bottom, by default
                linespeci      = [];
                posgui         = get(handles.gui_chassis,'Position');
                posfig         = [];
                posminigui     = [];
                ibckground     = 0; % do not invert {default}

                
                defs       = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
                defcol     = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w'};
                colorline  = repmat(defcol,1, ERP.nbin*length(defs));% sorted according 1st erplab's version
                d = repmat(defs',1, ERP.nbin*length(defcol));
                styleline = reshape(d',1, numel(d));
                %       set(handles.popupmenu_columns, 'String', num2str([1:256]'))
                %       set(handles.popupmenu_rows, 'String', num2str([1:256]'))
                set(handles.radiobutton_yauto, 'Value', 1)
        end
        
        %
        % store default values at plotset
        %
        setplotset_time % call script
        assignin('base','plotset', plotset);
        
else
        if ~isempty(plotset.pfrequ)
                
                %
                % Get the plotset struct
                %
                getplotset_frequ
                defs   = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
                defcol = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w'};
                
                if isempty(linespeci)
                        colorline = [];
                        styleline = [];
                else
                        colorline = regexp(linespeci,'\w*','match');
                        colorline = [colorline{:}];
                        styleline = regexp(linespeci,'\W*','match');
                        styleline = [styleline{:}];
                end
                if isempty(colorline)
                        colorline  = repmat(defcol,1, ERP.nbin*length(defs));% sorted according 1st erplab's version
                        d = repmat(defs',1, ERP.nbin*length(defcol));
                        styleline = reshape(d',1, numel(d));
                else
                        defcol = unique_bc2(colorline);
                        if isempty(styleline)
                                d = repmat(defs',1, ERP.nbin*length(defcol));
                                styleline = reshape(d',1, numel(d));
                        else
                                for i=1:length(styleline)
                                        if isempty(styleline{i})
                                                styleline{i} = '-';
                                        end
                                end
                        end
                end
                if isMGFP==0
                        chanArray_MGFP =[];
                end
                if isempty(axsize) %&& istopo==1
                        axsize = [0.05 0.08];
                end
        else
                %
                % ticks for time
                %
                xtickarray = str2num(char(default_time_ticks(ERP)));
                xxs1       = ceil(kktime*ERP.xmin);
                xxs2       = floor(kktime*ERP.xmax)/8;
                
                % Default values
                binArray       = 1:ERP.nbin;
                plotallbin     = 1;
                chanArray      = 1:ERP.nchan;
                plotallch      = 1;
                chanArray_MGFP = [];
                blcorr         = 'none';  %by default
                xxscale        = [xxs1 xxs2 xtickarray];
                %[ytarr, miny, maxy] = default_amp_ticks(ERP, binArray);
                %[ytarr, miny, maxy] = default_amp_ticks(ERP, binArray);
                %ytickarray        = str2num(char(ytarr));
                yyscale        = [0 10 10 20 30 40];
                linewidth      = 1;
                isiy           = 0;
                fschan         = 10;
                fslege         = 12;
                fsaxtick       = 10;
                %meap          = 1;
                pstyle         = 1; % 1 =matlab style 1; 2 =matlab style 2; 3= classic; 4= topographic
                errorstd       = 0; % pointer for std factor
                stdalpha       = 0.7; % transparency for plotting standard error
                pbox           = squareplot(chanArray, hObject, eventdata, handles);
                %counterbinwin  = 1;
                counterwin     = [1 1];
                holdch         = 0; % to draw different channels for same bin in one figure
                yauto          = 1;
                xautoticks     = 1;
                yautoticks     = 1;
                binleg         = 1;
                chanleg        = 1; % 1 means show chan labels
                isMGFP         = 0;
                ismaxim        = 1; % maximize figure
                %istopo         = 0;
                axsize         = [];
                minorticks     = [0 0];
                legepos        = 1; % legend position=bottom, by default
                linespeci      = [];
                posgui         = get(handles.gui_chassis,'Position');
                posfig         = [];
                posminigui     = [];
                ibckground     = 0; % do not invert {default}
                
                defs       = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
                defcol     = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w'};
                colorline  = repmat(defcol,1, ERP.nbin*length(defs));% sorted according 1st erplab's version
                d = repmat(defs',1, ERP.nbin*length(defcol));
                styleline = reshape(d',1, numel(d));
                %       set(handles.popupmenu_columns, 'String', num2str([1:256]'))
                %       set(handles.popupmenu_rows, 'String', num2str([1:256]'))
                set(handles.radiobutton_yauto, 'Value', 1)
        end
        
        %
        % store default values at plotset
        %
        setplotset_frequ % call script
        assignin('base','plotset', plotset);
end

set(handles.popupmenu_columns, 'String', num2str([1:256]'))
set(handles.popupmenu_rows, 'String', num2str([1:256]'))

%
% Fonts
%
set(handles.popupmenu_font_channel, 'String', num2str([1:20]'))
set(handles.popupmenu_font_legend, 'String', num2str([1:20]'))
set(handles.popupmenu_font_axistick, 'String', num2str([1:20]'))

%
% Plot channels and bins
%
if ~isempty(chanArray)
        chanArray = chanArray(chanArray<=ERP.nchan);
end
if ~isempty(binArray)
        binArray = binArray(binArray<=ERP.nbin);
end
if (all(ismember_bc2(1:ERP.nchan, chanArray)) && ERP.nchan==length(chanArray)) || plotallch
        set(handles.checkbox_plotallchannels, 'Value', 1)
        set(handles.edit_chans,'String', vect2colon([1:ERP.nchan], 'Delimiter','off', 'Repeat', 'off'))
        set(handles.edit_chans, 'Enable', 'off');
        set(handles.pushbutton_browsechan, 'Enable', 'off');
        
else
        if ~isempty(chanArray)
                set(handles.edit_chans,'String', vect2colon(chanArray, 'Delimiter','off', 'Repeat', 'off'))
        else
                set(handles.edit_chans,'String', 'what''s up')
        end
end
if (all(ismember_bc2(1:ERP.nbin, binArray)) && ERP.nbin==length(binArray)) || plotallbin
        set(handles.checkbox_plotallbins, 'Value', 1)
        set(handles.edit_bins,'String', vect2colon([1:ERP.nbin], 'Delimiter','off', 'Repeat', 'off'))
        set(handles.edit_bins, 'Enable', 'off');
        set(handles.pushbutton_browsebin, 'Enable', 'off');
else
        if ~isempty(binArray)
                set(handles.edit_bins,'String', vect2colon(binArray, 'Delimiter','off', 'Repeat', 'off'))
        else
                set(handles.edit_bins,'String', 'what''s up')
        end
end

chanArray =  str2num(get(handles.edit_chans,'String'));
binArray  =  str2num(get(handles.edit_bins,'String'));

%
% Mean global field power
%
set(handles.checkbox_MGFP, 'Value', isMGFP)
if isMGFP
        set(handles.edit_MGFP_chans,'Enable','on')
        set(handles.pushbutton_sameaschan,'Enable','on')
else
        set(handles.edit_MGFP_chans,'Enable','off')
        set(handles.pushbutton_sameaschan,'Enable','off')
end
if ~isempty(chanArray) && ((isMGFP==1 && (pbox(1)*pbox(2))<(length(chanArray)+1)) || (isMGFP==0 && (pbox(1)*pbox(2))<(length(chanArray))))
        
        %
        % Creates square subploting
        %
        pbox = squareplot(chanArray, hObject, eventdata, handles);
        set(handles.popupmenu_rows, 'Value', pbox(1))
        set(handles.popupmenu_columns, 'Value', pbox(2))
end

%
% MGFP
%
set(handles.edit_MGFP_chans,'String', vect2colon(chanArray_MGFP, 'Delimiter','off', 'Repeat', 'off'))
counterbinwin  = counterwin(1);
counterchanwin = counterwin(2);

set(handles.gui_chassis,'Position', posgui)
set(handles.radiobutton_yauto, 'Value', yauto)
set(handles.checkbox_autotimeticks, 'Value', xautoticks)
set(handles.checkbox_autoyticks, 'Value', yautoticks)
set(handles.checkbox_includenumberbin, 'Value', binleg)
set(handles.checkbox_show_number_ch, 'Value', ~chanleg)
set(handles.text_erpset,'String', CURRENTERP)

%
% Auto-Ticks
%
if xautoticks==1
        set(handles.pushbutton_timeticks,'Enable','off');
end
if yautoticks==1
        set(handles.pushbutton_yticks,'Enable','off');
end

%
% ERP plot style
%
set(handles.popupmenu_plotstyle, 'Value', pstyle)

if pstyle==4 % topo
        set(handles.edit_topowidth,'Enable','on');
        set(handles.edit_topoheight,'Enable','on');
        
        if ~isempty(axsize)
                axsizestrW = sprintf('%.3f',axsize(1));
                axsizestrH = sprintf('%.3f',axsize(2));
        else
                axsizestrW = sprintf('0.05'); % again...
                axsizestrH = sprintf('0.08'); % again...
        end
        set(handles.edit_topowidth,'String', axsizestrW)
        set(handles.edit_topoheight,'String',axsizestrH)
else
        %set(handles.checkbox_toolbar,'Enable', 'on')
        set(handles.edit_topowidth,'Enable','off');
        set(handles.edit_topoheight,'Enable','off');
        
        if ~isempty(axsize)
                axsizestrW = sprintf('%.3f',axsize(1));
                axsizestrH = sprintf('%.3f',axsize(2));
        else
                axsizestrW = sprintf('0.05'); % again...
                axsizestrH = sprintf('0.08'); % again...
        end
        
        set(handles.edit_topowidth,'String', axsizestrW)
        set(handles.edit_topoheight,'String',axsizestrH)
end

%
% error plot (std)
%
isbinerror = ~isempty(ERP.binerror); %is there info about binerror?
set(handles.popupmenu_std_factor,'String', cellstr(num2str([0:10]'))')
set(handles.popupmenu_transpa,'String', cellstr(num2str([0:0.1:1]'))')

if isbinerror && pstyle~=4 % no topo
        set(handles.checkbox_stdev,'Enable','on')
        set(handles.popupmenu_std_factor,'Enable','on')
        set(handles.popupmenu_transpa,'Enable','on')
        if errorstd>=1
                set(handles.checkbox_stdev,'Value', 1)
                set(handles.popupmenu_std_factor,'Value', errorstd+1)
                set(handles.popupmenu_transpa,'Value', round(stdalpha*10)+1)
        else
                set(handles.checkbox_stdev,'Value', 0)
                set(handles.popupmenu_std_factor,'Value', 1)
                set(handles.popupmenu_transpa,'Value', 1)
                set(handles.popupmenu_std_factor,'Enable', 'off')
                set(handles.popupmenu_transpa,'Enable','off')
        end
else
        set(handles.checkbox_stdev,'Value', 0)
        set(handles.checkbox_stdev,'Enable','off')
        set(handles.popupmenu_std_factor,'Value', 1)
        set(handles.popupmenu_std_factor,'Enable','off')
        set(handles.popupmenu_transpa,'Value',1)
        set(handles.popupmenu_transpa,'Enable','off')
end

%
% Maximize figure
%
set(handles.checkbox_maximize, 'Value', ismaxim)

%
% Invert background color
%
set(handles.popupmenu_ibckground, 'Value', ibckground+1)

%
% Axis polarity
%
if strcmpi(datatype, 'ERP')
        set(handles.togglebutton_y_axis_polarity, 'Enable', 'on');
        if ~isiy
                word = 'positive';
                set(handles.togglebutton_y_axis_polarity, 'Value', 0);
        else
                word = 'negative';
                set(handles.togglebutton_y_axis_polarity, 'Value', 1);
        end
        set(handles.togglebutton_y_axis_polarity, 'string', sprintf('<HTML><center><b>%s</b> is up', word));        
        set(handles.text_X_range, 'String', 'Time range (min max, in ms)');
        set(handles.checkbox_autotimeticks, 'String', 'auto time-ticks');
else
        word = 'positive';
        set(handles.togglebutton_y_axis_polarity, 'Value', 0);
        set(handles.togglebutton_y_axis_polarity, 'string', sprintf('<HTML><center><b>%s</b> is up', word));
        set(handles.togglebutton_y_axis_polarity, 'Enable', 'off');        
        set(handles.text_X_range, 'String', 'Freq range (min max, in Hz)');
        set(handles.checkbox_autotimeticks, 'String', 'auto freq-ticks');
end

%
% Baseline correction memory-setting
%
if strcmpi(datatype, 'ERP')
        set(handles.radiobutton_BLC_no,'Enable', 'on')
        set(handles.radiobutton_BLC_pre,'Enable', 'on')
        set(handles.radiobutton_BLC_post,'Enable', 'on')
        set(handles.radiobutton_BLC_whole,'Enable', 'on')
        set(handles.radiobutton_BLC_custom,'Enable', 'on')
        set(handles.edit_custom, 'Enable', 'on')        
        cmpbasel = str2num(blcorr);
        
        if isempty(cmpbasel)
                switch blcorr
                        case 'no'
                                set(handles.radiobutton_BLC_no,'Value', 1)
                                set(handles.radiobutton_BLC_pre,'Value', 0)
                                set(handles.radiobutton_BLC_post,'Value', 0)
                                set(handles.radiobutton_BLC_whole,'Value', 0)
                                set(handles.radiobutton_BLC_custom,'Value', 0)
                                set(handles.edit_custom, 'String', 'none')
                        case 'pre'
                                set(handles.radiobutton_BLC_no,'Value', 0)
                                set(handles.radiobutton_BLC_pre,'Value', 1)
                                set(handles.radiobutton_BLC_post,'Value', 0)
                                set(handles.radiobutton_BLC_whole,'Value', 0)
                                set(handles.radiobutton_BLC_custom,'Value', 0)
                                set(handles.edit_custom, 'String', sprintf('%.1f  %g', ceil(ERP.xmin*kktime), 0))
                        case 'post'
                                set(handles.radiobutton_BLC_no,'Value', 0)
                                set(handles.radiobutton_BLC_pre,'Value', 0)
                                set(handles.radiobutton_BLC_post,'Value', 1)
                                set(handles.radiobutton_BLC_whole,'Value', 0)
                                set(handles.radiobutton_BLC_custom, 'Value', 0)
                                set(handles.edit_custom, 'String', sprintf('%g  %.1f',0, ERP.xmax*kktime))
                        case 'all'
                                set(handles.radiobutton_BLC_no,'Value', 0)
                                set(handles.radiobutton_BLC_pre,'Value', 0)
                                set(handles.radiobutton_BLC_post,'Value', 0)
                                set(handles.radiobutton_BLC_whole,'Value', 1)
                                set(handles.radiobutton_BLC_custom, 'Value', 0)
                                set(handles.edit_custom, 'String', sprintf('%.1f  %.1f',ceil(ERP.xmin*kktime), floor(ERP.xmax*kktime)))
                end
                set(handles.edit_custom, 'BackgroundColor', BackERPLABcolor)
                set(handles.edit_custom, 'Enable', 'inactive')
        else
                set(handles.radiobutton_BLC_no,'Value', 0)
                set(handles.radiobutton_BLC_pre,'Value', 0)
                set(handles.radiobutton_BLC_post,'Value', 0)
                set(handles.radiobutton_BLC_whole,'Value', 0)
                set(handles.radiobutton_BLC_custom, 'Value', 1)
                set(handles.edit_custom, 'BackgroundColor', [1 1 1])
                set(handles.edit_custom, 'Enable', 'on')
                blcorr = regexprep(blcorr, '(\s+)\1', ' ');
                set(handles.edit_custom,'String', blcorr)
        end
else
        set(handles.radiobutton_BLC_no,'Value', 1)
        set(handles.radiobutton_BLC_pre,'Value', 0)
        set(handles.radiobutton_BLC_post,'Value', 0)
        set(handles.radiobutton_BLC_whole,'Value', 0)
        set(handles.radiobutton_BLC_custom,'Value', 0)
        set(handles.edit_custom, 'String', 'none')
        
        set(handles.radiobutton_BLC_no,'Enable', 'off')
        set(handles.radiobutton_BLC_pre,'Enable', 'off')
        set(handles.radiobutton_BLC_post,'Enable', 'off')
        set(handles.radiobutton_BLC_whole,'Enable', 'off')
        set(handles.radiobutton_BLC_custom,'Enable', 'off')
        set(handles.edit_custom, 'Enable', 'off')
end


if get(handles.radiobutton_BLC_pre, 'Value')
    %AMS: default BLC is "pre"
    %find y scales for pre-stim baselined data
    
    nbin = length(binArray);
    nch  = length(chanArray);
    fs   = ERP.srate;
    
    indxtimelock = find(ERP.times==0) ;   % zero-time locked
    aa = 1;
    
    % Read data
    dataaux = ERP.bindata;
    kk=1;
    for i=1:nch
        for j=1:nbin
            baseline(kk) = mean(ERP.bindata(chanArray(i),aa:indxtimelock,binArray(j)));  % baseline mean
            dataaux(chanArray(i),:,binArray(j)) = ERP.bindata(chanArray(i),:,binArray(j)) - baseline(kk);
            kk = kk + 1;
        end
    end
    
    ERP_blc.bindata = dataaux;
    
    [ytarr, miny, maxy] = default_amp_ticks(ERP_blc, binArray);
    ytickarray = str2num(char(ytarr));
    yyscale = [miny maxy ytickarray];
    
    clearvars dataaux ERP_blc;
end


%
% X scale & ticks
%
if length(xxscale)>=2 && xxscale(1)==0 && xxscale(2)==0
        xxscale(1) = ERP.xmin*kktime;
        xxscale(2) = ERP.xmax*kktime;
end
val_edit_time_range = sprintf('%.1f %.1f', xxscale(1), xxscale(2));
if length(xxscale)>2
        timeticks = xxscale(3:end);
        val_edit_time_ticks = sprintf('%s', vect2colon(xxscale(3:end),'Delimiter','off', 'Repeat', 'off'));
else
        val_edit_time_ticks = '';
        timeticks = [];
end

set(handles.edit_time_range,'String', val_edit_time_range)
handles.timeticks = timeticks;

%
%  Y scale
%

%if user previously selected to input custom scales
if ~get(handles.radiobutton_yauto, 'Value')
    yyscale = erpworkingmemory('pop_ploterpGUI'); 
    yyscale = cell2mat(yyscale);
end


yscalestr1 = sprintf('%.4f %.4f', yyscale(1), yyscale(2));
if length(yyscale)>2
        yticks = yyscale(3:end);
        yscalestr2 = sprintf('%s',vect2colon(yyscale(3:end),'Delimiter','off', 'Repeat', 'off'));
else
        yticks = [];
        yscalestr2 = ''; % sprintf('%.1f %.1f', yyscale);
end

set(handles.edit_yscale, 'String', yscalestr1)
handles.yticks = yticks;
handles.minorticks = minorticks;

%
% line specifications
%
linespeci = cellstr([char(colorline') char(styleline')])';
handles.linespeci = linespeci;
handles.linewidth = linewidth;

%
% Prepare List of current Channels
%
nchan  = ERP.nchan; % Total number of channels
if ~isfield(ERP.chanlocs,'labels')
        for e=1:nchan
                ERP.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = {''};
for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end
handles.listch     = listch;
handles.indxlistch = chanArray;

%
% Plot style
%
erpsty = {'Matlab 1', 'Matlab 2', 'Classic ERP', 'Topographic' };
set(handles.popupmenu_plotstyle,'String', erpsty)

%
% Bin description
%
listb = {''};
nbin  = ERP.nbin; % Total number of bins
for b=1:nbin
        listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
end
%%%set(handles.popupmenu_bins,'String', listb)
handles.listb      = listb;
handles.indxlistb  = binArray;

%
% Box
%
set(handles.popupmenu_rows, 'Value', pbox(1))
set(handles.popupmenu_columns, 'Value', pbox(2))

%
% Auto-Y
%
if get(handles.radiobutton_yauto, 'Value')
        set(handles.edit_yscale, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_yscale, 'Enable', 'inactive')
end

% %if user previously selected to input custom scales
% if ~get(handles.radiobutton_yauto, 'Value')
%     
%     
% end


set(handles.popupmenu_font_channel, 'Value', fschan)
set(handles.popupmenu_font_legend, 'Value', fslege)
set(handles.popupmenu_font_axistick, 'Value', fsaxtick);
set(handles.popupmenu_legepos, 'Value', legepos)
% set(handles.popupmenu_line, 'Value', linewidth)

%
% Counter
%
handles.counterbinwin  = counterbinwin;
handles.counterchanwin = counterchanwin;

%
% local memory for x,y scales
%
handles.mxscale =  xxscale;
handles.myscale =  yyscale;

%
% Color GUI
%
handles = painterplab(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function popupmenu_std_factor_Callback(hObject, eventdata, handles)
valf = get(handles.popupmenu_std_factor,'Value');
if valf==1
        set(handles.checkbox_stdev,'Value', 0)
        set(handles.popupmenu_std_factor,'Enable', 'off')
end

%--------------------------------------------------------------------------
function popupmenu_std_factor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_maximize_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_CLERPF_Callback(hObject, eventdata, handles)
clerpf

%--------------------------------------------------------------------------
function edit_topowidth_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_topowidth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_topoheight_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edit_topoheight_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_appenderp_Callback(hObject, eventdata, handles)
ALLERP = evalin('base', 'ALLERP');
ERP = pop_appenderp(ALLERP);
handles.ERP=ERP;
% Update handles structure
guidata(hObject, handles);

setall(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_binoperations_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_chanoperations_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_timeticks_Callback(hObject, eventdata, handles)
%
% X scale
%
timew = str2num(get(handles.edit_time_range, 'String')); % XL
if size(timew,1)~=1  || size(timew,2)~=2
        msgboxText =  'Wrong time range to plot!';
        title      = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);
        return
end
if timew(1)==timew(2)
        msgboxText =  'Wrong time range to plot!';
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);
        return
end
if timew(1)>timew(2)
        msgboxText = ['Inverted time range to plot!\n'...
                'Values will be adjusted.'];
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        timew  = circshift(timew',1)';
        set(handles.edit_time_range, 'String', num2str([timew(1) timew(2)])); % XL
end

prompt    = {'Enter times''s ticks in ms. e.g. 100 200 300 or 100:100:300'};
dlg_title = 'ERPLAB: Time ticks';
ERP = handles.ERP;

%
% Deafault ticks
%
def = default_time_ticks(ERP, timew);

timeticks  = handles.timeticks;
minorticks = handles.minorticks;

if isempty(timeticks)
        memov = def;
else
        memov = vect2colon(timeticks,'Delimiter','off', 'Repeat', 'off');
end
if isempty(minorticks)
        op01  = 0 ;
else
        op01  = minorticks(1);
end

%
% Open input GUI
%
answ = inputvalueGUI(prompt,dlg_title, memov, def, op01);

if isempty(answ)
        disp('User selected Cancel')
        return
end
answer = answ{1};
incmt  = answ{2}; % include minor ticks

if isempty(strtrim(answer))
        disp('User selected Cancel')
        return
end

timeticks = str2num(answer);
minorticks(1) = incmt;

if isempty(timeticks)
        msgboxText = 'Tick values must be a numeric array.\n';
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~issorted(timeticks) ||  isrepeated(timeticks)
        msgboxText = 'Tick values must be monotonically increasing!\n';
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        return
end

handles.timeticks  = timeticks;
handles.minorticks = minorticks;

%Update handles structure
guidata(hObject, handles);
% expression = answer{1};

%--------------------------------------------------------------------------
function pushbutton_yticks_Callback(hObject, eventdata, handles)
%
% Y scale
%
yyscale     = str2num(get(handles.edit_yscale, 'String')); % XL
if size(yyscale,1)~=1  || size(yyscale,2)~=2
        msgboxText =  'Wrong scale range to plot!';
        title      = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);
        return
end
if yyscale(1)==yyscale(2)
        msgboxText =  'Wrong scale range to plot!';
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(msgboxText, title);
        return
end
if yyscale(1)>yyscale(2)
        yyscale  = circshift(yyscale',1)';
        set(handles.edit_yscale, 'String', num2str(yyscale)); % XL
        
        %
        % Y polarity button
        %
        if ~get(handles.togglebutton_y_axis_polarity, 'Value')
                word = 'negative';
                set(handles.togglebutton_y_axis_polarity, 'Value',1);
                set(handles.togglebutton_y_axis_polarity, 'string', sprintf('<HTML><center><b>%s</b> is up', word));
        end
end

prompt    = {'Enter Y''s ticks. e.g. -20 -10 0 10 20  or -20:10:20'};
dlg_title = 'ERPLAB: Y scale ticks';
% num_lines = 1;
ERP = handles.ERP;
binArray   = str2num(get(handles.edit_bins, 'String'));
if get(handles.radiobutton_yauto, 'Value');
        def = default_amp_ticks(ERP, binArray);
else
        def = default_amp_ticks(ERP, binArray, yyscale);
end

yticks  = handles.yticks;
minorticks = handles.minorticks;

if isempty(yticks)
        memov = def;
else
        memov = vect2colon(yticks,'Delimiter','off', 'Repeat', 'off');
end
if isempty(minorticks)
        op01  = 0 ;
else
        op01  = minorticks(2);
end

%
% Open input GUI
%
answ = inputvalueGUI(prompt,dlg_title, memov, def, op01);

if isempty(answ)
        disp('User selected Cancel')
        return
end

answer = answ{1};
incmt  = answ{2}; % include minor ticks

if isempty(strtrim(answer))
        disp('User selected Cancel')
        return
end

yticks = str2num(answer);
minorticks(2) = incmt;

if isempty(yticks)
        msgboxText = 'Tick values must be a numeric array.\n';
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        %plotset = evalin('base', 'plotset');
        %plotset.ptime = [];
        return
end
if ~issorted(yticks) ||  isrepeated(yticks)
        msgboxText = 'Tick values must be monotonically increasing!\n';
        title = 'ERPLAB: ploterpGUI inputs';
        errorfound(sprintf(msgboxText), title);
        return
end

handles.yticks = yticks;
handles.minorticks = minorticks;

%Update handles structure
guidata(hObject, handles);
% expression = answer{1};

%--------------------------------------------------------------------------
function pushbutton_linespec_Callback(hObject, eventdata, handles)
nbin      = handles.nbin;
defspec   = handles.linespeci;
linewidth = handles.linewidth;

%
% Call GUI
%
answer = linespecGUI(defspec, nbin, linewidth);
if isempty(answer)
        return
end

linespeci = answer{1};
linewidth = answer{2};

handles.linespeci = linespeci;
handles.linewidth = linewidth;
%Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function popupmenu_plotstyle_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')==4 % topo
        %set(handles.popupmenu_line,'Enable', 'off')
        set(handles.popupmenu_rows,'Enable', 'off')
        set(handles.popupmenu_columns,'Enable', 'off')
        set(handles.popupmenu_font_channel,'Enable', 'off')
        set(handles.popupmenu_font_legend,'Enable', 'off')
        set(handles.popupmenu_font_axistick, 'Enable','off');
        %set(handles.checkbox_toolbar,'Value', 1)
        %set(handles.checkbox_toolbar,'Enable', 'off')
        set(handles.checkbox_stdev,'Enable', 'off')
        set(handles.checkbox_MGFP,'Enable', 'off')
        set(handles.pushbutton_sameaschan,'Enable','off')
        set(handles.edit_MGFP_chans,'Enable', 'off')
        set(handles.checkbox_includenumberbin,'Enable', 'off')
        set(handles.popupmenu_legepos,'Enable', 'off')
        set(handles.edit_topowidth,'Enable', 'on')
        set(handles.edit_topoheight,'Enable', 'on')
        wxscale = str2num(get(handles.edit_time_range, 'String'));
        wyscale = str2num(get(handles.edit_yscale, 'String'));
        handles.mxscale =  wxscale;
        handles.myscale =  wyscale;
        set(handles.edit_time_range, 'String', sprintf('%.1f %.1f', wxscale(1), wxscale(2)));
        set(handles.edit_yscale, 'String', sprintf('%.4f %.4f', wyscale(1), wyscale(2)));
        
        % Update handles structure
        guidata(hObject, handles);
else
        mxscale  =  handles.mxscale;
        myscale  =  handles.myscale;
        
        %
        % X scale
        %
        trangestr = sprintf('%.1f %.1f', mxscale(1), mxscale(2));
        set(handles.edit_time_range,'String', trangestr)
        yscalestr = sprintf('%.4f %.4f', myscale(1), myscale(2));
        set(handles.edit_yscale, 'String', yscalestr)
        ERP = handles.ERP;
        %       set(handles.popupmenu_line,'Enable', 'on')
        set(handles.popupmenu_rows,'Enable', 'on')
        set(handles.popupmenu_columns,'Enable', 'on')
        set(handles.popupmenu_font_channel,'Enable', 'on')
        set(handles.popupmenu_font_legend,'Enable', 'on')
        set(handles.popupmenu_font_axistick, 'Enable','on');
        %set(handles.checkbox_toolbar,'Enable', 'on')
        
        if isempty(ERP.binerror)
                set(handles.checkbox_stdev,'Enable', 'off')
        else
                set(handles.checkbox_stdev,'Enable', 'on')
        end
        
        set(handles.checkbox_MGFP,'Enable', 'on')
        set(handles.pushbutton_sameaschan,'Enable','on')
        set(handles.edit_MGFP_chans,'Enable', 'on')
        set(handles.checkbox_includenumberbin,'Enable', 'on')
        set(handles.popupmenu_legepos,'Enable', 'on')
        set(handles.edit_topowidth,'Enable', 'off')
        set(handles.edit_topoheight,'Enable', 'off')
end

%--------------------------------------------------------------------------
function popupmenu_plotstyle_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_autoyticks_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.pushbutton_yticks, 'Enable', 'off')
        %
        % Deafault ticks
        %
        ERP      = handles.ERP;
        binArray = str2num(get(handles.edit_bins, 'String'));
        yyscale  = str2num(get(handles.edit_yscale, 'String'));
        
        %if get(handles.radiobutton_yauto, 'Value');
        %        def = default_amp_ticks(ERP, binArray);
        %else
        def = default_amp_ticks(ERP, binArray, yyscale);
        %end
        
        handles.yticks  = str2num(def{:});
        
        %Update handles structure
        guidata(hObject, handles);
else
        set(handles.pushbutton_yticks, 'Enable', 'on')
end

%--------------------------------------------------------------------------
function checkbox_autotimeticks_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.pushbutton_timeticks, 'Enable', 'off')
        %
        % Deafault ticks
        %
        ERP   = handles.ERP;
        timew = str2num(get(handles.edit_time_range, 'String'));
        def   = default_time_ticks(ERP, timew);
        handles.timeticks  = str2num(def{:});
        
        %Update handles structure
        guidata(hObject, handles);
else
        set(handles.pushbutton_timeticks, 'Enable', 'on')
end

%--------------------------------------------------------------------------
function pushbutton_browsechan_Callback(hObject, eventdata, handles)
listch = handles.listch;
indxlistch = handles.indxlistch;
indxlistch = indxlistch(indxlistch<=length(listch));
titlename = 'Select Channel(s)';

if get(hObject, 'Value')
        if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                        set(handles.edit_chans, 'String', vect2colon(ch, 'Delimiter', 'off'));
                        handles.indxlistch = ch;
                        % Update handles structure
                        guidata(hObject, handles);
                        
                        if get(handles.radiobutton_yauto, 'Value')
                                yscaleauto(hObject, eventdata, handles)
                        end
                else
                        disp('User selected Cancel')
                        return
                end
        else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                return
        end
end

%--------------------------------------------------------------------------
function pushbutton_sameaschan_Callback(hObject, eventdata, handles)
ch = str2num(get(handles.edit_chans, 'String'));
if ~isempty(ch)
        set(handles.edit_MGFP_chans, 'String', vect2colon(ch, 'Delimiter', 'off'));
end

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
                        
                        if get(handles.radiobutton_yauto, 'Value')
                                yscaleauto(hObject, eventdata, handles)
                        end
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
function [chk, msgboxText] = chckbinandchan(ERP, binArray, chanArray)
chk=0;
msgboxText = '';
if isempty(binArray)
        msgboxText =  'You have not specified any bin';
        chk = 1;
        return
end
if any(binArray<=0)
        msgboxText =  sprintf('Invalid bin index.\nPlease specify only positive integer values.');
        chk = 1;
        return
end
if any(binArray>ERP.nbin)
        msgboxText =  sprintf('Bin index out of range!\nYou only have %g bins in this ERPset',ERP.nbin);
        chk = 1;
        return
end
if length(binArray)~=length(unique_bc2(binArray))
        msgboxText = 'You have specified repeated bins for plotting.';
        chk = 1;
        return
end
if isempty(chanArray)
        msgboxText =  'You have not specified any channel';
        chk = 1;
        return
end
if any(chanArray<=0)
        msgboxText =  sprintf('Invalid channel index.\nPlease specify only positive integer values.');
        chk = 1;
        return
end
if any(chanArray>ERP.nchan)
        msgboxText =  sprintf('Channel index out of range!\nYou only have %g channels in this ERPset', ERP.nchan);
        chk = 1;
        return
end
if length(chanArray)~=length(unique_bc2(chanArray))
        msgboxText = 'You have specified repeated channels for plotting.';
        chk = 1;
        return
end

%--------------------------------------------------------------------------
function yscaleauto(hObject, eventdata, handles)
drawnow
pause(0.1)
ERP       = handles.ERP;
chanArray = str2num(get(handles.edit_chans, 'String'));
binArray  = str2num(get(handles.edit_bins, 'String'));
xxlim     = str2num(get(handles.edit_time_range, 'String'));
[yylim, serror] = erpAutoYLim(ERP, binArray, chanArray, xxlim)
set(handles.edit_yscale, 'String', sprintf('%.4f %.4f', yylim(1), yylim(2)));

%--------------------------------------------------------------------------
function popupmenu_font_axistick_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_font_axistick_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_transpa_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_transpa_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
datatype = handles.datatype;
plotset  = evalin('base', 'plotset');
if strcmpi(datatype, 'ERP')
        plotset.ptime.posgui = get(handles.gui_chassis,'Position');
        assignin('base','plotset', plotset);
        plotset.ptime=[];
else
        plotset.pfrequ.posgui = get(handles.gui_chassis,'Position');
        assignin('base','plotset', plotset);
        plotset.pfrequ=[];
end

handles.output = plotset;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        datatype = handles.datatype;
        plotset  = evalin('base', 'plotset');
        if strcmpi(datatype, 'ERP')
                plotset.ptime.posgui = get(handles.gui_chassis,'Position');
                assignin('base','plotset', plotset);
                plotset.ptime=[];
        else
                plotset.pfrequ.posgui = get(handles.gui_chassis,'Position');
                assignin('base','plotset', plotset);
                plotset.pfrequ=[];
        end
        
        handles.output = plotset;
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end


% --- Executes on key press with focus on pushbutton_plot and none of its controls.
function pushbutton_plot_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
