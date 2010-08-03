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
        plotset = evalin('base', 'plotset');
catch
        plotset.ptime  = [];
        plotset.pscalp = [];
        assignin('base','plotset',plotset)
end

handles.output = plotset;
handles.ispdf  = 0;
handles.scalp  = 0;

% Update handles structure
guidata(hObject, handles);

%
% Name & version
%
version = geterplabversion;
set(handles.figure1,'Name', ['ERPLAB BETA ' version '   -   ERP Plotting GUI'],...
        'tag','ploterp','NextPlot','new')

setall(hObject, eventdata, handles)
drawnow

% UIWAIT makes ploterpGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = ploterpGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure

ispdf = handles.ispdf;
if ispdf
        plotset = evalin('base', 'plotset');
        plotset.ptime = 'pdf';
        handles.output = plotset;
end

scalp = handles.scalp;
if scalp
        plotset = evalin('base', 'plotset');
        plotset.ptime = 'scalp';
        handles.output = plotset;
        varargout{1} = handles.output;
        
        % The figure can be deleted now
        delete(handles.figure1);
        ERP = evalin('base', 'ERP');
        pop_scalplot(ERP);
        return
end

varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);
pause(0.5)

%--------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_chans_Callback(hObject, eventdata, handles)

chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);

%
% Creates square subploting
%
box = squareplot(chanArray, hObject, eventdata, handles);

set(handles.popupmenu_rows, 'Value', box(1))
set(handles.popupmenu_columns, 'Value', box(2))

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
        set(handles.edit_custom, 'String', sprintf('%.1f  %g',ceil(ERP.xmin*1000), 0))
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
        set(handles.edit_custom, 'String', sprintf('%g  %.1f', 0, floor(ERP.xmax*1000)))
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
        set(handles.edit_custom, 'String', sprintf('%.1f  %.1f',ceil(ERP.xmin*1000), floor(ERP.xmax*1000)))
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

chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);
row = get(handles.popupmenu_rows, 'Value');
col = ceil(numel(chanArray)/row);
set(handles.popupmenu_columns, 'Value', col);

%--------------------------------------------------------------------------
function popupmenu_rows_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_columns_Callback(hObject, eventdata, handles)

chanArraystr = get(handles.edit_chans, 'String');
chanArray    = str2num(chanArraystr);
col = get(handles.popupmenu_columns, 'Value');
row = ceil(numel(chanArray)/col);
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
function popupmenu_line_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_line_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_stdev_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
       ERP = handles.ERP;
       if isempty(ERP.binerror)
              msgboxText{1} =  ['Permission Denied: ' ERP.erpname ' has no measures of dispersion.'];
              title = 'ERPLAB: pop_ploterps() missing info:';
              errorfound(msgboxText, title)
              set(handles.checkbox_stdev,'Value', 0)
              return              
       else
              set(handles.checkbox_stdev,'Value', 1)
       end
end

%--------------------------------------------------------------------------
function checkbox_toolbar_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_plot_Callback(hObject, eventdata, handles)

plotset = getplotset(hObject, eventdata, handles);

if isempty(plotset.ptime)
        return
else
        handles.output = plotset;
        
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
end

%--------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
plotset = evalin('base', 'plotset');
plotset.ptime=[];
handles.output = plotset;

% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function edit_yscale_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_yscale_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function radiobutton_auto_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        BackERPLABcolor = handles.BackERPLABcolor;
        set(handles.edit_yscale, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_yscale, 'Enable', 'inactive')
else
        set(handles.edit_yscale, 'BackgroundColor', [1 1 1])
        set(handles.edit_yscale, 'Enable', 'on')
end

%--------------------------------------------------------------------------
function togglebutton_up_Callback(hObject, eventdata, handles)

pos = '<HTML><center><b>+</b>';
neg = '<HTML><center><b>-</b>';
if get(hObject, 'Value')
        set(hObject, 'string',[neg '<br>' pos]);
else
        set(hObject, 'string',[pos '<br>' neg]);
end

%--------------------------------------------------------------------------
function box = squareplot(chanArray, hObject, eventdata, handles)

newnch = numel(chanArray);

if get(handles.checkbox_MGFP, 'Value')
        newnch = newnch + 1;
end

dsqr   = round(sqrt(newnch));
sqrdif = dsqr^2 - newnch;

if sqrdif<0
        box(1) = dsqr + 1;
else
        box(1) = dsqr;
end
box(2) = dsqr;

%--------------------------------------------------------------------------
function pushbutton_pdf_Callback(hObject, eventdata, handles)

ispdf = 1;
handles.ispdf = ispdf;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

%--------------------------------------------------------------------------
function checkbox_includenumberbin_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function checkbox_MGFP_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
        set(handles.edit_MGFP_chans,'Enable','on')
        set(handles.popupmenu_MGFP_chans,'Enable','on')
else
        set(handles.edit_MGFP_chans,'String','')
        set(handles.edit_MGFP_chans,'Enable','off')
        set(handles.popupmenu_MGFP_chans,'Enable','off')
end

%--------------------------------------------------------------------------
function edit_MGFP_chans_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_MGFP_chans_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function checkbox_show_number_ch_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_chans_Callback(hObject, eventdata, handles)

counterchanwin = handles.counterchanwin;
nchan = size(get(handles.popupmenu_chans, 'String'),1); %chans at popmenu

if counterchanwin>1
        chanArray    = str2num(get(handles.edit_chans, 'String'));
        channum      = get(handles.popupmenu_chans, 'Value');
        chanArray    = [chanArray channum];
        chanArraystr = vect2colon(chanArray, 'Sort', 'no', 'Delimiter','no');
        set(handles.edit_chans, 'String', chanArraystr);
        
        if length(str2num(chanArraystr))>nchan
                counterchanwin = 0;
        end
else
        channum      = get(handles.popupmenu_chans, 'Value');
        chanArraystr = [num2str(channum) ' '];
        set(handles.edit_chans, 'String', chanArraystr);
end

chanArray    = str2num(chanArraystr);

%
% Creates square subploting
%
box = squareplot(chanArray, hObject, eventdata, handles);
set(handles.popupmenu_rows, 'Value', box(1))
set(handles.popupmenu_columns, 'Value', box(2))
counterchanwin = counterchanwin+1;
handles.counterchanwin = counterchanwin;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function popupmenu_chans_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_bins_Callback(hObject, eventdata, handles)

counterbinwin = handles.counterbinwin;
nbin = size(get(handles.popupmenu_bins, 'String'),1);

if counterbinwin>1
        
        binArray    = str2num(get(handles.edit_bins, 'String'));
        binnum      = get(handles.popupmenu_bins, 'Value');
        binArray    = [binArray binnum];
        binArraystr = vect2colon(binArray, 'Delimiter','no');
        set(handles.edit_bins, 'String', binArraystr);
        
        if length(str2num(binArraystr))>nbin
                counterbinwin = 0;
        end
else
        binnum      = get(handles.popupmenu_bins, 'Value');
        binArraystr = [num2str(binnum) ' '];
        set(handles.edit_bins, 'String', binArraystr);
end

counterbinwin = counterbinwin+1;
handles.counterbinwin = counterbinwin;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function popupmenu_bins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_MGFP_chans_Callback(hObject, eventdata, handles)

nchan        = size(get(handles.popupmenu_MGFP_chans, 'String'),1);
chanArray    = str2num(get(handles.edit_MGFP_chans, 'String'));
channum      = get(handles.popupmenu_MGFP_chans, 'Value');
chanArray    = [chanArray channum];
chanArray    = chanArray(chanArray<=nchan);
chanArraystr = vect2colon(chanArray, 'Sort', 'no', 'Delimiter','no');
set(handles.edit_MGFP_chans, 'String', chanArraystr);

%--------------------------------------------------------------------------
function popupmenu_MGFP_chans_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function popupmenu_legepos_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function popupmenu_legepos_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        %The GUI is still in UIWAIT, us UIRESUME
        plotset = evalin('base', 'plotset');
        plotset.ptime  = [];
        handles.output = plotset;
        %Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
else
        % The GUI is no longer waiting, just close it
        delete(handles.figure1);
end

%--------------------------------------------------------------------------
function pushbutton_reset_Callback(hObject, eventdata, handles)

plotset = evalin('base', 'plotset');
plotset.ptime = [];
assignin('base','plotset', plotset);
setall(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function pushbutton_scalp_Callback(hObject, eventdata, handles)

plotset = getplotset(hObject, eventdata, handles);

if isempty(plotset.ptime)
        return
else
        plotset.pscalp.binArray = plotset.ptime.binArray;
        plotset.pscalp.latencyArray = 0;
        plotset.pscalp.exchanArray  = [];
        plotset.pscalp.measurement  = 'insta';
        plotset.pscalp.baseline = 'pre';
        plotset.pscalp.cscale   = 'maxmin';
        plotset.pscalp.colorbar = 1;
        plotset.pscalp.ispdf    = 0;
        plotset.pscalp.binleg   = 1;
        plotset.pscalp.showelec = 1;
        plotset.pscalp.ismaxim  = 0;
        
        assignin('base','plotset', plotset);
        
        handles.scalp = 1;
        %Update handles structure
        guidata(hObject, handles);
        
        uiresume(handles.figure1);
end

%--------------------------------------------------------------------------
function plotset = getplotset(hObject, eventdata, handles)

binArray  = str2num(get(handles.edit_bins, 'String'));
chanArray = str2num(get(handles.edit_chans, 'String'));
ERP = handles.ERP;

if ~isempty(binArray) && ~isempty(chanArray)
        
        timew = str2num(get(handles.edit_time_range, 'String')); % XL
        
        if size(timew,1)~=1  || size(timew,2)~=2
                msgboxText{1} =  'Wrong time range to plot!';
                title = 'ERPLAB: ploterpGUI inputs';
                errorfound(msgboxText, title)
                plotset = evalin('base', 'plotset');
                plotset.ptime = [];
                return
        end
        if timew(1)==timew(2)
                msgboxText{1} =  'Wrong time range to plot!';
                title = 'ERPLAB: ploterpGUI inputs';
                errorfound(msgboxText, title)
                plotset = evalin('base', 'plotset');
                plotset.ptime = [];
                return
        end
        if timew(1)>timew(2)
                msgboxText{1} =  'Inverted time range to plot!';
                msgboxText{2} =  'Values will be adjusted.';
                title = 'ERPLAB: ploterpGUI inputs';
                errorfound(msgboxText, title)
                timew  = circshift(timew',1)'; %
                
        end
        if timew(1)<ERP.xmin*1000 && abs((timew(1)/1000-ERP.xmin)*ERP.srate)>2
                msgboxText{1} =  'Wrong lower time value to plot!';
                msgboxText{2} =  'Value will be adjusted.';
                title = 'ERPLAB: ploterpGUI inputs';
                errorfound(msgboxText, title)
                timew(1)=ceil(ERP.xmin*1000);
        end
        if timew(2)>ERP.xmax*1000 && abs((timew(2)/1000-ERP.xmax)*ERP.srate)>2
                msgboxText{1} =  'Wrong upper time value to plot!';
                msgboxText{2} =  'Values will be adjusted.';
                title = 'ERPLAB: ploterpGUI inputs';
                errorfound(msgboxText, title)
                timew(2)=floor(ERP.xmax*1000);
        end
        
        if length(chanArray)~=length(unique(chanArray))
                fprintf('\n\nWARNING: You have included repeated channels for plotting.\n\n')
        end
        
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
                        if ~ismember(lower(blcorr),{'no' 'pre' 'post' 'all'})
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText =  'Wrong baseline range!';
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(msgboxText, title)
                                set(handles.radiobutton_BLC_custom, 'Value', 0);
                                set(handles.radiobutton_BLC_pre, 'Value', 1);
                                plotset = evalin('base', 'plotset');
                                plotset.ptime = [];
                                return
                        end
                        
                else
                        if size(cmpbasel,1)~=1  || size(cmpbasel,2)~=2
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText =  'Wrong baseline range!';
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(msgboxText, title)
                                set(handles.radiobutton_BLC_custom, 'Value', 0);
                                set(handles.radiobutton_BLC_no, 'Value', 1);
                                plotset = evalin('base', 'plotset');
                                plotset.ptime = [];
                                return
                        end
                        if cmpbasel(1)>cmpbasel(2)
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText{1} =  'Inverted baseline range!';
                                msgboxText{2} =  'Values will be adjusted.';
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(msgboxText, title)
                                cmpbasel  = circshift(cmpbasel',1)'; %
                        end
                        if abs((cmpbasel(2)/1000-cmpbasel(1)/1000)*ERP.srate)<1
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                title = 'ERPLAB: ploterpGUI inputs';
                                question{1} = 'You are specifying 1 point per baseline correction!';
                                question{2} = 'Do you want to continue anyway?';
                                
                                button = askquest(question, title);
                                
                                if ~strcmpi(button,'yes')
                                        disp('User selected Cancel')
                                        plotset = evalin('base', 'plotset');
                                        plotset.ptime = [];
                                        return
                                end
                        end
                        if cmpbasel(1)<ERP.xmin*1000
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText{1} =  'Wrong lower baseline value!';
                                msgboxText{2} =  'Value will be adjusted.';
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(msgboxText, title)
                                cmpbasel(1)=ceil(ERP.xmin*1000);
                        end
                        if cmpbasel(2)>ERP.xmax*1000
                                set(handles.edit_custom, 'String','none');
                                set(handles.edit_custom, 'Enable','off');
                                msgboxText = ['Wrong upper baseline value!\n'...
                                              'Value will be adjusted.'];
                                title = 'ERPLAB: ploterpGUI inputs';
                                errorfound(sprintf(msgboxText), title);
                                cmpbasel(2) = floor(ERP.xmax*1000);                                
                        end
                        blcorr = num2str(cmpbasel);
                end
        end
        
        yscale = str2num(get(handles.edit_yscale, 'String')); % YL
        
        if get(handles.togglebutton_up, 'Value')
                isyinv = 1;  % is inverted, positive down
        else
                isyinv = 0;  % is not inverted, positive up
        end
        
        linewidth  = get(handles.popupmenu_line, 'Value');
        fschan     = get(handles.popupmenu_font_channel, 'Value');
        fslege     = get(handles.popupmenu_font_legend, 'Value');
        meap       = get(handles.checkbox_toolbar, 'Value');
        errorstd   = get(handles.checkbox_stdev, 'Value');
        box(1)     = get(handles.popupmenu_rows, 'Value');
        box(2)     = get(handles.popupmenu_columns, 'Value');
        
        counterwin = [handles.counterbinwin handles.counterchanwin];
        holdch = 0;
        yauto  = get(handles.radiobutton_auto, 'Value');
        binleg = get(handles.checkbox_includenumberbin, 'Value');
        
        
        chanleg= ~get(handles.checkbox_show_number_ch, 'Value'); %@@@@@@@@@@@@@@@@@@@@
        
        
        MGFP   = get(handles.checkbox_MGFP, 'Value');
        chanArray_MGFP = str2num(get(handles.edit_MGFP_chans, 'String'));
        
        if MGFP && isempty(chanArray_MGFP)
                MGFP = 0;
        end
        
        legepos  = get(handles.popupmenu_legepos, 'Value');
        istopo   = get(handles.checkbox_topoplot, 'Value');
        ismaxim  = get(handles.checkbox_maximize, 'Value');
        
        %
        % width and height for topoplot
        %
        axsizeW  = str2num(get(handles.edit_topowidth, 'String'));
        if isempty(axsizeW) && istopo
              msgboxText = ['For topographic view, you must specify a value for width.\n'...
                    'Value should be within 0 < width <= 1'];
              title = 'ERPLAB: ploterpGUI inputs';
              errorfound(sprintf(msgboxText), title);
        end
        if (axsizeW>1 || axsizeW<=0)  && istopo
              msgboxText = ['For topographic view, you must specify a value for width.\n'...
                    'Value should be within 0 < width <= 1'];
              title = 'ERPLAB: ploterpGUI inputs';
              errorfound(sprintf(msgboxText), title);
        end
        
        axsizeH  = str2num(get(handles.edit_topoheight, 'String'));
        
        if isempty(axsizeH) && istopo
              msgboxText = ['For topographic view, you must specify a value for height.\n'...
                    'Value should be within 0 < width <= 1'];
              title = 'ERPLAB: ploterpGUI inputs';
              errorfound(sprintf(msgboxText), title);
        end
        if (axsizeH>1 || axsizeH<=0)  && istopo
              msgboxText = ['For topographic view, you must specify a value for height.\n'...
                    'Value should be within 0 < width <= 1'];
              title = 'ERPLAB: ploterpGUI inputs';
              errorfound(sprintf(msgboxText), title);
        end
        
       % if istopo
              axsize = [axsizeW axsizeH];
        %else
              
        %end
                
        plotset = evalin('base', 'plotset');
        
        plotset.ptime.binArray       = binArray;
        plotset.ptime.chanArray      = chanArray;
        plotset.ptime.chanArray_MGFP = chanArray_MGFP;
        plotset.ptime.blcorr         = blcorr;
        plotset.ptime.xscale         = timew;
        plotset.ptime.yscale         = yscale;
        plotset.ptime.linewidth      = linewidth;
        plotset.ptime.isiy           = isyinv;
        plotset.ptime.fschan         = fschan;
        plotset.ptime.fslege         = fslege;
        plotset.ptime.meap           = meap;
        plotset.ptime.errorstd       = errorstd;
        plotset.ptime.box            = box;
        plotset.ptime.counterwin     = counterwin;
        plotset.ptime.holdch         = holdch;
        plotset.ptime.yauto          = yauto;
        plotset.ptime.binleg         = binleg;
        
        plotset.ptime.chanleg        = chanleg; % @@@@@@@@@@@@@@@@@@@
        
        plotset.ptime.isMGFP         = MGFP;
        plotset.ptime.legepos        = legepos;
        plotset.ptime.istopo         = istopo;
        plotset.ptime.ismaxim        = ismaxim;
        plotset.ptime.posgui         = get(handles.figure1,'Position');  
        plotset.ptime.axsize         = axsize;
else
        plotset = evalin('base', 'plotset');
        if isempty(binArray)
                set(handles.edit_bins, 'BackgroundColor', [1 0 0]);pause(0.5)
                set(handles.edit_bins, 'BackgroundColor', [1 1 1])
                plotset.ptime.binArray  = 1:ERP.nbin;
        end
        
        if isempty(chanArray)
                set(handles.edit_chans, 'BackgroundColor', [1 0 0]);pause(0.5)
                set(handles.edit_chans, 'BackgroundColor', [1 1 1])
                plotset.ptime.chanArray = 1:ERP.nchan;
                box = squareplot(1:ERP.nchan, hObject, eventdata, handles);
                plotset.ptime.box = box;
        end
        return
end

%--------------------------------------------------------------------------
function setall(hObject, eventdata, handles)

ERP = evalin('base', 'ERP');
handles.ERP = ERP;

try
        plotset = evalin('base', 'plotset');
        ptime   = plotset.ptime;
        pscalp  = plotset.pscalp;
        
        plotset.ptime.binArray  = plotset.ptime.binArray(plotset.ptime.binArray<=ERP.nbin);
        plotset.ptime.chanArray = plotset.ptime.chanArray(plotset.ptime.chanArray<=ERP.nchan);
        plotset.ptime.chanArray_MGFP = plotset.ptime.chanArray_MGFP(plotset.ptime.chanArray_MGFP<=ERP.nchan);
        
        if plotset.ptime.xscale(1) < ERP.xmin*1000
                plotset.ptime.xscale(1) = ceil(ERP.xmin*1000);
        end
        
        if plotset.ptime.xscale(2) > ERP.xmax*1000
                plotset.ptime.xscale(2) = floor(ERP.xmax*1000);
        end
                posgui  = plotset.ptime.posgui;
                set(handles.figure1,'Position', posgui)
catch
        ptime  = [];
        plotset.ptime  = ptime;
        assignin('base','plotset', plotset);
end

BackERPLABcolor = geterplabcolor;
handles.BackERPLABcolor = BackERPLABcolor;
set(handles.checkbox_includenumberbin, 'Value', 1)

l1 = '<HTML><center><b>Convert</b>';
l2 = '<HTML><center><b>existing plot</b>';
l3 = '<HTML><center><b>to PDF</b>';
set(handles.pushbutton_pdf, 'string',[l1 '<br>' l2 '<br>' l3]);

if ~ispc
        set(handles.pushbutton_pdf, 'ForegroundColor', [0 0 0])
end

if ~isempty(ptime)
        
        binArray   = plotset.ptime.binArray;
        chanArray  = plotset.ptime.chanArray;
        chanArray_MGFP = plotset.ptime.chanArray_MGFP;
        blcorr     = plotset.ptime.blcorr;
        xscale     = plotset.ptime.xscale;
        yscale     = plotset.ptime.yscale;
        linewidth  = plotset.ptime.linewidth;
        isiy       = plotset.ptime.isiy;
        fschan     = plotset.ptime.fschan;
        fslege     = plotset.ptime.fslege;
        meap       = plotset.ptime.meap;
        errorstd   = plotset.ptime.errorstd;
        box        = plotset.ptime.box;
        counterwin = plotset.ptime.counterwin;
        holdch     = plotset.ptime.holdch;
        yauto      = plotset.ptime.yauto;
        binleg     = plotset.ptime.binleg;
        
        chanleg    = plotset.ptime.chanleg; % @@@@@@@@@@@@@@@@@@@
        
        
        isMGFP     = plotset.ptime.isMGFP;
        ismaxim    = plotset.ptime.ismaxim;
        istopo     = plotset.ptime.istopo;
        axsize     = plotset.ptime.axsize;        
        
        if isMGFP==0
              chanArray_MGFP =[];
        end
        if isempty(axsize) %&& istopo==1
              axsize = [0.05 0.08];              
        end
        
        legepos = plotset.ptime.legepos;
        counterbinwin  = counterwin(1);
        counterchanwin = counterwin(2);
        
else
        binArray   = 1:ERP.nbin;
        chanArray  = 1:ERP.nchan;
        chanArray_MGFP = [];
        blcorr     = 'pre';  %by default
        xscale     = [ceil(1000*ERP.xmin) floor(1000*ERP.xmax)];
        yscale     = [-10 10];
        linewidth  = 1;
        isiy       = 0;
        fschan     = 10;
        fslege     = 10;
        meap       = 1;
        errorstd   = 0;
        holdch     = 0;
        yauto      = 1;
        binleg     = 1;
        
        chanleg    = 1; % 1 means show chan labels  @@@@@@@@@@@@@@@@@@@@
        
        
        isMGFP     = 0;
        legepos    = 1;
        ismaxim    = 0;
        istopo     = 0;
        axsize     = [];
        
        counterbinwin  = 1;
        counterchanwin = 1;
        
        set(handles.popupmenu_columns, 'String', num2str([1:256]'))
        set(handles.popupmenu_rows, 'String', num2str([1:256]'))
        set(handles.radiobutton_auto, 'Value', 1)
        
        %
        % Creates square subploting %%%%%%%%%%%%%%%%%%%%
        %
        box = squareplot(chanArray, hObject, eventdata, handles);
end

handles.counterbinwin  = counterbinwin;
handles.counterchanwin = counterchanwin;
set(handles.radiobutton_auto, 'Value', yauto)
set(handles.checkbox_includenumberbin, 'Value', binleg)
set(handles.checkbox_show_number_ch, 'Value', ~chanleg)

%
% Toolbar
%
set(handles.checkbox_toolbar, 'Value', meap)

%
% Topographic plot
%
set(handles.checkbox_topoplot,'Value', istopo)
if istopo
      set(handles.checkbox_toolbar,'Value', 1)
      set(handles.checkbox_toolbar,'Enable', 'off')
      
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
      set(handles.checkbox_toolbar,'Enable', 'on')
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

if errorstd && isbinerror && ~istopo
      set(handles.checkbox_stdev,'Enable','on')      
      set(handles.checkbox_stdev,'Value', 1)
else
      set(handles.checkbox_stdev,'Value', 0)
      set(handles.checkbox_stdev,'Enable','off')      
end

%
% Mean global field power
%
set(handles.checkbox_MGFP, 'Value', isMGFP)
if isMGFP
       set(handles.edit_MGFP_chans,'Enable','on')
       set(handles.popupmenu_MGFP_chans,'Enable','on')
else
       set(handles.edit_MGFP_chans,'Enable','off')
       set(handles.popupmenu_MGFP_chans,'Enable','off')
end

%
% Maximize figure
%
set(handles.checkbox_maximize, 'Value', ismaxim)

%
% Y axis direction
%
pos = '<HTML><center><b>+</b>';
neg = '<HTML><center><b>-</b>';
if isiy
       set(handles.togglebutton_up, 'string',[neg '<br>' pos]); % positive down
       set(handles.togglebutton_up, 'Value', 1);
else
       set(handles.togglebutton_up, 'string',[pos '<br>' neg]); % positive up
       set(handles.togglebutton_up, 'Value', 0);
end

%
% Baseline correction memory-setting
%
cmpbasel = str2num(blcorr);

if isempty(cmpbasel)
        
        switch blcorr
                case 'no'
                        set(handles.radiobutton_BLC_no,'Value', 1)
                        set(handles.radiobutton_BLC_pre,'Value', 0)
                        set(handles.radiobutton_BLC_post,'Value', 0)
                        set(handles.radiobutton_BLC_whole,'Value', 0)
                        set(handles.radiobutton_BLC_custom, 'Value', 0)
                        set(handles.edit_custom, 'String', 'none')
                case 'pre'
                        set(handles.radiobutton_BLC_no,'Value', 0)
                        set(handles.radiobutton_BLC_pre,'Value', 1)
                        set(handles.radiobutton_BLC_post,'Value', 0)
                        set(handles.radiobutton_BLC_whole,'Value', 0)
                        set(handles.radiobutton_BLC_custom, 'Value', 0)
                        set(handles.edit_custom, 'String', sprintf('%.1f  %g', ceil(ERP.xmin*1000), 0))
                        
                case 'post'
                        set(handles.radiobutton_BLC_no,'Value', 0)
                        set(handles.radiobutton_BLC_pre,'Value', 0)
                        set(handles.radiobutton_BLC_post,'Value', 1)
                        set(handles.radiobutton_BLC_whole,'Value', 0)
                        set(handles.radiobutton_BLC_custom, 'Value', 0)
                        set(handles.edit_custom, 'String', sprintf('%g  %.1f',0, ERP.xmax*1000))
                case 'all'
                        set(handles.radiobutton_BLC_no,'Value', 0)
                        set(handles.radiobutton_BLC_pre,'Value', 0)
                        set(handles.radiobutton_BLC_post,'Value', 0)
                        set(handles.radiobutton_BLC_whole,'Value', 1)
                        set(handles.radiobutton_BLC_custom, 'Value', 0)
                        set(handles.edit_custom, 'String', sprintf('%.1f  %.1f',ceil(ERP.xmin*1000), floor(ERP.xmax*1000)))
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

trangestr = sprintf('%.1f %.1f', xscale);
set(handles.edit_time_range,'String', trangestr)

%
% Prepare List of current Channels
%
listch = [];
nchan = ERP.nchan; % Total number of channels

if ~isfield(ERP.chanlocs,'labels')
        for e=1:nchan
                ERP.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end

for ch =1:nchan
        listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels ];
end

set(handles.edit_chans,'String', vect2colon(chanArray, 'Sort', 'no', 'Delimiter','no'))
set(handles.popupmenu_chans,'String', listch)
set(handles.edit_MGFP_chans,'String', vect2colon(chanArray_MGFP, 'Sort', 'no', 'Delimiter','no'))
set(handles.popupmenu_MGFP_chans,'String', listch)

listb = [];
nbin  = ERP.nbin; % Total number of bins

for b=1:nbin
        listb{b}= ['BIN' num2str(b) ' = ' ERP.bindescr{b} ];
end

set(handles.popupmenu_bins,'String', listb)
set(handles.edit_bins,'String', vect2colon(binArray, 'Delimiter','no'))
set(handles.popupmenu_rows, 'Value', box(1))
set(handles.popupmenu_columns, 'Value', box(2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if get(handles. radiobutton_auto, 'Value')
        set(handles.edit_yscale, 'BackgroundColor', BackERPLABcolor)
        set(handles.edit_yscale, 'Enable', 'inactive')
end

yscalestr = sprintf('%.2f %.2f', yscale);
set(handles.edit_yscale, 'String', yscalestr)
set(handles.popupmenu_font_channel, 'Value', fschan)
set(handles.popupmenu_font_legend, 'Value', fslege)
set(handles.popupmenu_legepos, 'Value', legepos)
set(handles.popupmenu_line, 'Value', linewidth)

%
% Color GUI
%
handles = painterplab(handles);

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
function checkbox_topoplot_Callback(hObject, eventdata, handles)

if get(hObject, 'Value')
      set(handles.popupmenu_line,'Enable', 'off')
      set(handles.popupmenu_rows,'Enable', 'off')
      set(handles.popupmenu_columns,'Enable', 'off')
      set(handles.popupmenu_font_channel,'Enable', 'off')
      set(handles.popupmenu_font_legend,'Enable', 'off')
      set(handles.checkbox_toolbar,'Value', 1)
      set(handles.checkbox_toolbar,'Enable', 'off')
      set(handles.checkbox_stdev,'Enable', 'off')
      set(handles.checkbox_MGFP,'Enable', 'off')
      set(handles.edit_MGFP_chans,'Enable', 'off')
      set(handles.popupmenu_MGFP_chans,'Enable', 'off')
      set(handles.checkbox_includenumberbin,'Enable', 'off')
      set(handles.popupmenu_legepos,'Enable', 'off')     
      set(handles.edit_topowidth,'Enable', 'on')
      set(handles.edit_topoheight,'Enable', 'on')
else
      ERP = handles.ERP;
      set(handles.popupmenu_line,'Enable', 'on')
      set(handles.popupmenu_rows,'Enable', 'on')
      set(handles.popupmenu_columns,'Enable', 'on')
      set(handles.popupmenu_font_channel,'Enable', 'on')
      set(handles.popupmenu_font_legend,'Enable', 'on')
      set(handles.checkbox_toolbar,'Enable', 'on')
      
      if isempty(ERP.binerror)
            set(handles.checkbox_stdev,'Enable', 'off')
      else
            set(handles.checkbox_stdev,'Enable', 'on')
      end
      
      set(handles.checkbox_MGFP,'Enable', 'on')
      set(handles.edit_MGFP_chans,'Enable', 'on')
      set(handles.popupmenu_MGFP_chans,'Enable', 'on')
      set(handles.checkbox_includenumberbin,'Enable', 'on')
      set(handles.popupmenu_legepos,'Enable', 'on')  
      set(handles.edit_topowidth,'Enable', 'off')
      set(handles.edit_topoheight,'Enable', 'off')
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
