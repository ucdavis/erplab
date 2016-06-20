function varargout = calibrateGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @calibrateGUI_OpeningFcn, ...
        'gui_OutputFcn',  @calibrateGUI_OutputFcn, ...
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


% -------------------------------------------------------------------------------------------------------------
function calibrateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output    = [];
handles.listb     = [];
handles.indxlistb = [];

try
        %    { erpinput, calbin, calval, calwin });
        def = varargin{1};
        erpinput = def{1};
        calbin   = def{2};
        calval   = def{3};
        calwin   = def{4};
catch
        erpinput = 0;
        calbin   = 1;
        calval   = 10;
        calwin   = [0 300];
end
if ischar(erpinput)
        set(handles.radiobutton_currenterpset, 'Value', 0)
        set(handles.radiobutton_erpset, 'Value', 0)
        set(handles.radiobutton_folders, 'Value', 1)
        set(handles.edit_erpset, 'Enable', 'off')
        set(handles.pushbutton_browsefile, 'Enable', 'on')
        set(handles.listbox_erpnames, 'Enable', 'on')
        if exist(erpinput, 'file')==2
                set(handles.listbox_erpnames, 'String', erpinput)
                [filepath, filename, fext] = fileparts(erpinput);
                L   = load(fullfile(filepath, [filename fext]), '-mat');
                ERPcal = L.ERP;
        end
else
        if erpinput==0
                set(handles.radiobutton_currenterpset, 'Value', 1)
                set(handles.radiobutton_erpset, 'Value', 0)
                set(handles.radiobutton_folders, 'Value', 0)
                set(handles.edit_erpset, 'Enable', 'off')
                set(handles.pushbutton_browsefile, 'Enable', 'off')
                set(handles.listbox_erpnames, 'Enable', 'off')
                try
                        ERPcal = evalin('base', 'ERP');
                catch
                        ERPcal = [];
                        ERPcal.nbin = 0;
                end
        else
                set(handles.radiobutton_currenterpset, 'Value', 0)
                set(handles.radiobutton_erpset, 'Value', 1)
                set(handles.radiobutton_folders, 'Value', 0)
                set(handles.edit_erpset, 'Enable', 'on')
                set(handles.pushbutton_browsefile, 'Enable', 'off')
                set(handles.listbox_erpnames, 'Enable', 'off')
                try
                ALLERP = evalin('base', 'ALLERP');
                if length(erpinput)~=1
                        msgboxText =  'You must specify 1 ERPset index only';
                        title = 'ERPLAB: calibration ERPset';
                        errorfound(msgboxText, title);
                        ERPcal = [];
                        ERPcal.nbin = 0;
                else
                        if erpinput<1 || erpinput>length(ALLERP)
                                msgboxText =  'You have specified an unexisting ERPset.\n';
                                title = 'ERPLAB: calibration ERPset';
                                errorfound(sprintf(msgboxText), title);
                                ERPcal = [];
                                ERPcal.nbin = 0;
                        else
                                ERPcal = ALLERP(erpinput);
                        end
                end
                catch
                        ERPcal = [];
                        ERPcal.nbin = 0;
                end
        end
end

set(handles.edit_bins, 'String', num2str(calbin))
set(handles.edit_calval, 'String', num2str(calval))
set(handles.edit_calwin, 'String', num2str(calwin))
handles.ERPcal = ERPcal;

%
% Color GUI
%
handles = painterplab(handles);

%
% Set font size
%
handles = setfonterplab(handles);

version  = geterplabversion;
set(handles.gui_chassis,'Name', ['ERPLAB ' version '   -   ERP Calibration GUI   - '])

% Update handles structure
guidata(hObject, handles);
drawnow

if ~isempty(calbin)
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% UIWAIT makes calibrateGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


% -------------------------------------------------------------------------------------------------------------
function varargout = calibrateGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.gui_chassis);
pause(0.1)

% -------------------------------------------------------------------------------------------------------------
function radiobutton_currenterpset_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        %set(handles.radiobutton_currenterpset, 'Value', 1)
        set(handles.radiobutton_erpset, 'Value', 0)
        set(handles.radiobutton_folders, 'Value', 0)
        
        set(handles.edit_erpset, 'Enable', 'off')
        set(handles.pushbutton_browsefile, 'Enable', 'off')
        set(handles.listbox_erpnames, 'Enable', 'off')
        
        
        ERPcal = evalin('base', 'ERP');
        handles.ERPcal = ERPcal;
        % Update handles structure
        guidata(hObject, handles);
        
        calbin = str2num(get(handles.edit_bins, 'String'));
        if length(calbin)~=1
                msgboxText =  'You must specify 1 bin only';
                title = 'ERPLAB: calibration bin';
                errorfound(msgboxText, title);
                return
        end
        if calbin<1 || calbin>ERPcal.nbin
                msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
                title = 'ERPLAB: calibration bin';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~isempty(calbin)
                plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
        end
else
        set(handles.radiobutton_currenterpset, 'Value', 1)
end

% -------------------------------------------------------------------------------------------------------------
function radiobutton_erpset_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_currenterpset, 'Value', 0)
        %set(handles.radiobutton_erpset, 'Value', 1)
        set(handles.radiobutton_folders, 'Value', 0)
        
        set(handles.edit_erpset, 'Enable', 'on')
        set(handles.pushbutton_browsefile, 'Enable', 'off')
        set(handles.listbox_erpnames, 'Enable', 'off')
        
        
        indx   = str2num(get(handles.edit_erpset,'String'));
        if isempty(indx); axes(handles.axes_calerp);plot(0,0);return;end
        ALLERP = evalin('base', 'ALLERP');
        if length(indx)~=1
                msgboxText =  'You must specify 1 ERPset index only';
                title = 'ERPLAB: calibration ERPset';
                errorfound(msgboxText, title);
                return
        end
        if indx<1 || indx>length(ALLERP)
                msgboxText =  'You have specified an unexisting ERPset.\n';
                title = 'ERPLAB: calibration ERPset';
                errorfound(sprintf(msgboxText), title);
                return
        end
        ERPcal = ALLERP(indx);
        handles.ERPcal = ERPcal;
        % Update handles structure
        guidata(hObject, handles);
        
        calbin = str2num(get(handles.edit_bins, 'String'));
        if length(calbin)~=1
                msgboxText =  'You must specify 1 bin only';
                title = 'ERPLAB: calibration bin';
                errorfound(msgboxText, title);
                return
        end
        if calbin<1 || calbin>ERPcal.nbin
                msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
                title = 'ERPLAB: calibration bin';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~isempty(calbin)
                plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
        end
else
        set(handles.radiobutton_erpset, 'Value', 1)
end

% -------------------------------------------------------------------------------------------------------------
function radiobutton_folders_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
        set(handles.radiobutton_currenterpset, 'Value', 0)
        set(handles.radiobutton_erpset, 'Value', 0)
        %set(handles.radiobutton_folders, 'Value', 1)
        
        set(handles.edit_erpset, 'Enable', 'off')
        set(handles.pushbutton_browsefile, 'Enable', 'on')
        set(handles.listbox_erpnames, 'Enable', 'on')
        
        filename   = get(handles.listbox_erpnames,'String');
        if isempty(filename); axes(handles.axes_calerp);plot(0,0);return;end
        if exist(filename, 'file')~=2
                msgboxText =  'ERPset file does not exist!';
                title = 'ERPLAB: calibration ERPset';
                errorfound(msgboxText, title);
                return
        end
        
        [fpath, fname, fext] = fileparts(filename);
        
        L   = load(fullfile(fpath, [fname fext]), '-mat');
        ERPcal = L.ERP;
        handles.ERPcal = ERPcal;
        % Update handles structure
        guidata(hObject, handles);
        drawnow
        
        calbin = str2num(get(handles.edit_bins, 'String'));
        if length(calbin)~=1
                msgboxText =  'You must specify 1 bin only';
                title = 'ERPLAB: calibration bin';
                errorfound(msgboxText, title);
                return
        end
        if calbin<1 || calbin>ERPcal.nbin
                msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
                title = 'ERPLAB: calibration bin';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~isempty(calbin)
                plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
        end
        
else
        set(handles.radiobutton_folders, 'Value', 1)
end

% -------------------------------------------------------------------------------------------------------------
function listbox_erpnames_Callback(hObject, eventdata, handles)
filename   = get(handles.listbox_erpnames,'String');
if isempty(filename); return;end
if exist(filename, 'file')~=2
        msgboxText =  'ERPset file does not exist!';
        title = 'ERPLAB: calibration ERPset';
        errorfound(msgboxText, title);
        return
end

[fpath, fname, fext] = fileparts(filename);

L   = load(fullfile(fpath, [fname fext]), '-mat');
ERPcal = L.ERP;
handles.ERPcal = ERPcal;
% Update handles structure
guidata(hObject, handles);
drawnow

calbin = str2num(get(handles.edit_bins, 'String'));
if length(calbin)~=1
        msgboxText =  'You must specify 1 bin only';
        title = 'ERPLAB: calibration bin';
        errorfound(msgboxText, title);
        return
end
if calbin<1 || calbin>ERPcal.nbin
        msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
        title = 'ERPLAB: calibration bin';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~isempty(calbin)
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function listbox_erpnames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function edit4_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------------------------------------------
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------------------------------------------
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function edit_erpset_Callback(hObject, eventdata, handles)
indx   = str2num(get(handles.edit_erpset,'String'));
if isempty(indx); axes(handles.axes_calerp);plot(0,0); return;end
ALLERP = evalin('base', 'ALLERP');
if length(indx)~=1
        msgboxText =  'You must specify 1 ERPset index only';
        title = 'ERPLAB: calibration ERPset';
        errorfound(msgboxText, title);
        return
end
if indx<1 || indx>length(ALLERP)
        msgboxText =  'You have specified an unexisting ERPset.\n';
        title = 'ERPLAB: calibration ERPset';
        errorfound(sprintf(msgboxText), title);
        return
end

ERPcal = ALLERP(indx);
handles.ERPcal = ERPcal;

% Update handles structure
guidata(hObject, handles);

calbin = str2num(get(handles.edit_bins, 'String'));
if length(calbin)~=1
        msgboxText =  'You must specify 1 bin only';
        title = 'ERPLAB: calibration bin';
        errorfound(msgboxText, title);
        return
end
if calbin<1 || calbin>ERPcal.nbin
        msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
        title = 'ERPLAB: calibration bin';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~isempty(calbin)
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function listb = getlistofbins(ERPi)

%
% Prepare List of current Bins
%
listb = {[]};
nbin  = ERPi.nbin;
for b=1:nbin
        listb{b}= ['BIN' num2str(b) ' = ' ERPi.bindescr{b} ];
end

% -------------------------------------------------------------------------------------------------------------
function edit_erpset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function edit_calval_Callback(hObject, eventdata, handles)
calbin = str2num(get(handles.edit_bins, 'String'));
if ~isempty(calbin)
        ERPcal    = handles.ERPcal;
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function edit_calval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function edit_calwin_Callback(hObject, eventdata, handles)
calbin = str2num(get(handles.edit_bins, 'String'));
if ~isempty(calbin)
        ERPcal    = handles.ERPcal;
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function edit_calwin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function pushbutton_browsebin_Callback(hObject, eventdata, handles)
ERPcal    = handles.ERPcal;
listb     = getlistofbins(ERPcal);
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
calbin = str2num(get(handles.edit_bins, 'String'));
if ~isempty(calbin)
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function edit_bins_Callback(hObject, eventdata, handles)
calbin = str2num(get(handles.edit_bins, 'String'));
if ~isempty(calbin)
        if length(calbin)~=1
                msgboxText =  'You must specify 1 bin only';
                title = 'ERPLAB: calibration bin';
                errorfound(msgboxText, title);
                return
        end
        ERPcal    = handles.ERPcal;
        if calbin<1 || calbin>ERPcal.nbin
                msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
                title = 'ERPLAB: calibration bin';
                errorfound(sprintf(msgboxText), title);
                return
        end
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function edit_bins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)

ERPcal    = handles.ERPcal;

%
% Calibration bin
%
calbin = str2num(get(handles.edit_bins, 'String'));
if length(calbin)~=1
        msgboxText =  'You must specify 1 bin only';
        title = 'ERPLAB: calibration bin';
        errorfound(msgboxText, title);
        return
end
if calbin<1 || calbin>ERPcal.nbin
        msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
        title = 'ERPLAB: calibration bin';
        errorfound(sprintf(msgboxText), title);
        return
end

%
% Calibration window
%
calwin = str2num(get(handles.edit_calwin, 'String'));
if length(calwin)~=2
        msgboxText =  'You must specify 2 values for a calibration window';
        title = 'ERPLAB: calibration window';
        errorfound(msgboxText, title);
        return
end

%
% Calibration value
%
calval = str2num(get(handles.edit_calval, 'String'));
if length(calval)~=1
        msgboxText =  'You must specify 1 values for calibration';
        title = 'ERPLAB: calibration window';
        errorfound(msgboxText, title);
        return
end

%
% Calibration file
%
if get(handles.radiobutton_currenterpset, 'Value') && ~get(handles.radiobutton_erpset, 'Value') && ~get(handles.radiobutton_folders, 'Value')
        erpinput = 0; % current erp
elseif ~get(handles.radiobutton_currenterpset, 'Value') && get(handles.radiobutton_erpset, 'Value') && ~get(handles.radiobutton_folders, 'Value')
        indx   = str2num(get(handles.edit_erpset,'String'));
        if length(indx)~=1
                msgboxText =  'You must specify 1 ERPset index only';
                title = 'ERPLAB: calibration ERPset';
                errorfound(msgboxText, title);
                return
        end
        erpinput = indx; % erpset from menu
elseif ~get(handles.radiobutton_currenterpset, 'Value') && ~get(handles.radiobutton_erpset, 'Value') && get(handles.radiobutton_folders, 'Value')
        filename   = get(handles.listbox_erpnames,'String');
        if exist(filename, 'file')~=2
                msgboxText =  'ERPset file does not exist!';
                title = 'ERPLAB: calibration ERPset';
                errorfound(msgboxText, title);
                return
        end
        erpinput = filename;
else
        error('Cuec!')
end

handles.output = {erpinput, calbin, calval, calwin};

% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);

% -------------------------------------------------------------------------------------------------------------
function pushbutton_browsefile_Callback(hObject, eventdata, handles)
[filename, filepath] = uigetfile({'*.erp','ERP (*.erp)';...
        '*.mat','ERP (*.mat)'}, ...
        'Load ERP', ...
        'MultiSelect', 'off');
if isequal(filename,0)
        disp('User selected Cancel')
        return
end

set(handles.listbox_erpnames, 'String', fullfile(filepath, filename))
% ERPcal = pop_loaderp( 'filename', filename, 'filepath', filepath);
L   = load(fullfile(filepath, filename), '-mat');
ERPcal = L.ERP;
handles.ERPcal = ERPcal;
% Update handles structure
guidata(hObject, handles);

calbin = str2num(get(handles.edit_bins, 'String'));
if length(calbin)~=1
        msgboxText =  'You must specify 1 bin only';
        title = 'ERPLAB: calibration bin';
        errorfound(msgboxText, title);
        return
end
if calbin<1 || calbin>ERPcal.nbin
        msgboxText =  'You have specified an unexisting bin.\nUse the browser for assistance.';
        title = 'ERPLAB: calibration bin';
        errorfound(sprintf(msgboxText), title);
        return
end
if ~isempty(calbin)
        plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
end

% -------------------------------------------------------------------------------------------------------------
function plotcalerp(hObject, eventdata, handles, ERPcal, calbin)
try
        % ERPcal = handles.ERPcal;
        axes(handles.axes_calerp);
        plot(0,0);
        if isempty(ERPcal);return;end
        nchan  = ERPcal.nchan;
        timex  = ERPcal.times;
        set(gcf,'renderer','zbuffer')
        axes(handles.axes_calerp);
        plot(0,0);
        
        hold on
        for k=1:nchan
                hf(k) = plot(timex, ERPcal.bindata(k, :, calbin), 'k');
        end
        hold off
        xlim([ERPcal.xmin ERPcal.xmax]*1000)
        
        calval = str2num(get(handles.edit_calval, 'String'));
        if isempty(calval); return;end
        ylim([-abs(calval) abs(calval)]*1.25)
        line([ERPcal.xmin ERPcal.xmax]*1000, [calval calval], 'Color', 'r')
        
        calwin = str2num(get(handles.edit_calwin, 'String'));
        if isempty(calwin); return;end
        yylim = get(gca, 'YLim');
        cwm = [0.8490    1.0000    0.1510];
        pp = patch([min(calwin) max(calwin) max(calwin) min(calwin)],[yylim(1) yylim(1) yylim(2) yylim(2)], cwm);
        set(pp,'FaceAlpha',0.4, 'EdgeAlpha', 0.4, 'EdgeColor', cwm);
catch
        % ERPcal = handles.ERPcal;
        axes(handles.axes_calerp);
        plot(0,0);
end

%--------------------------------------------------------------------------
function gui_chassis_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.gui_chassis, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.gui_chassis);
else
        % The GUI is no longer waiting, just close it
        delete(handles.gui_chassis);
end

%--------------------------------------------------------------------------
function edit8_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit8_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end
