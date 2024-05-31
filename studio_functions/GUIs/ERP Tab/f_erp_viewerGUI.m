function varargout = f_erp_viewerGUI(varargin)
% F_ERP_VIEWERGUI MATLAB code for f_erp_viewerGUI.fig
%      F_ERP_VIEWERGUI, by itself, creates a new F_ERP_VIEWERGUI or raises the existing
%      singleton*.
%
%      H = F_ERP_VIEWERGUI returns the handle to a new F_ERP_VIEWERGUI or the handle to
%      the existing singleton*.
%
%      F_ERP_VIEWERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_VIEWERGUI.M with the given input arguments.
%
%      F_ERP_VIEWERGUI('Property','Value',...) creates a new F_ERP_VIEWERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_erp_viewerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_erp_viewerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%  Copyright 2009-2020 The MathWorks, Inc.

% Edit the above text to modify the response to help f_erp_viewerGUI

% Last Modified by GUIDE v2.5 09-Apr-2024 14:56:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_erp_viewerGUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_erp_viewerGUI_OutputFcn, ...
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


% --- Executes just before f_erp_viewerGUI is made visible.
function f_erp_viewerGUI_OpeningFcn(hObject, eventdata, handles, varargin)

try
    ALLERP  = varargin{1};
    CurrentERP = varargin{2};
    BinArray = varargin{3};
    ChanArray = varargin{4};
catch
    ALLERP = [];
    CurrentERP  = [];
    BinArray = [];
    ChanArray = [];
end

handles.ALLERP=ALLERP;
handles.CurrentERP=CurrentERP;
handles.BinArray=BinArray;
handles.ChanArray = ChanArray;
handles.ERP =[];

handles.output = [];
if ~isempty(ALLERP)
    if isempty(CurrentERP) || any(CurrentERP>length(ALLERP)) || numel(CurrentERP)~=1
        CurrentERP=length(ALLERP);
        handles.CurrentERP=CurrentERP;
    end
    OutputViewerparerp = f_preparms_mtviewer_erptab(ALLERP(CurrentERP),0);
    handles.timeStart =OutputViewerparerp{3};
    handles.timEnd =OutputViewerparerp{4};
    handles.xtickstep=OutputViewerparerp{5};
    bindata = [];
    for Numoferp = 1:numel(CurrentERP)
        ERP = ALLERP(CurrentERP);
        bindata(:,:,:,Numoferp) = ERP.bindata(ChanArray,:,BinArray);
    end
    y_scale_def = [floor(1.1*min(bindata(:))),ceil(1.1*max(bindata(:)))];
    
    handles.Yscale = y_scale_def;
    handles.Min_vspacing = OutputViewerparerp{7};
    handles.Fillscreen = OutputViewerparerp{8};
    handles.positive_up = OutputViewerparerp{10};
    handles.moption= OutputViewerparerp{12};
    handles.latency= OutputViewerparerp{13};
    handles.blc = OutputViewerparerp{14};
    handles.intfactor =  OutputViewerparerp{15};
    handles.Resolution =OutputViewerparerp{16};
    handles.Matlab_ver = OutputViewerparerp{22};
    handles.GridposArray = OutputViewerparerp{24};
    ChanArray11 = ChanArray(1);
    ChanArray11 = vect2colon(ChanArray11,'Sort', 'off');
    ChanArray11 = erase(ChanArray11,{'[',']'});
    handles.edit_chans.String =  ChanArray11;
    BinArray1 = BinArray(1);
    BinArray1 = vect2colon(BinArray1,'Sort', 'off');
    BinArray1 = erase(BinArray1,{'[',']'});
    handles.edit_bin.String = BinArray1;
    CurrentERP = CurrentERP(1);
    ERPArray1 = vect2colon(CurrentERP,'Sort', 'off');
    ERPArray1 = erase(ERPArray1,{'[',']'});
    handles.edit5_erpset.String = ERPArray1;
    handles.CurrentERP=CurrentERP;
end

%%for bins
handles.radiobutton_parbin.Value=1;
handles.checkbox1_bin.Value=0;
handles.edit_bin.Enable = 'on';
handles.pushbutton_binsmall.Enable = 'on';
handles.pushbutton_binlarge.Enable = 'on';
handles.pushbutton_browse_bin.Enable = 'on';

%%for chans
handles.radiobutton_chanpor.Value=1;
handles.checkbox_chan.Value=0;
handles.edit_chans.Enable = 'on';
handles.pushbutton8_chansmall.Enable = 'on';
handles.pushbutton_chanlarge.Enable = 'on';
handles.pushbutton_chanborwse.Enable = 'on';
handles.radiobutton_chanoverlay.Value=0;
handles.radiobutton_chan_separate.Value=1;
handles.radiobutton_chanoverlay.Enable = 'off';
handles.radiobutton_chan_separate.Enable = 'off';
%%erpsets
handles.radiobutton_erppor.Value=1;
handles.checkbox_erp.Value=0;
handles.edit5_erpset.Enable = 'on';
handles.pushbutton_erpsetsmall.Enable = 'on';
handles.pushbutton_erpsetlarge.Enable = 'on';
handles.pushbutton_erpset_browse.Enable = 'on';
if ~isempty(ALLERP)
    checkindex = checkerpsets(ALLERP);
    if ~isempty(checkindex)
        handles.checkbox_erp.Enable='off';
        handles.text_warningmessage.String  = [checkindex,', and you therfore donot allow to select all for ERPsets'];
    end
end
handles.ALLERP = ALLERP;
ALLERP = handles.ALLERP;

handles.positive_up=1;
handles.radiobutton7.Value=1;
handles.radiobutton7.BackgroundColor = [0.7020 0.7647 0.8392];
handles.radiobutton6.Value=0;


erplab_default_values;
version = erplabver;
set(handles.figure1,'Name', ['EStudio ' version '   -   Viewer for Measurement GUI'])
handles.figure1.Color = [0.7020 0.7647 0.8392];

handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

if isempty(ALLERP)
    return;
end


handles= plot_wave_viewer(hObject,handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes f_erp_viewerGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = f_erp_viewerGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;




function edit1_time_range_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
timeRange  = str2num(handles.edit1_time_range.String);
if isempty(timeRange) || numel(timeRange)~=2
    handles.edit1_time_range.String = num2str([handles.timeStart,handles.timEnd]);
    handles.text_warningmessage.String  = ['Time range must have two values'];
    return;
end
if timeRange(1)>=ERP.times(end)
    handles.edit1_time_range.String = num2str([handles.timeStart,handles.timEnd]);
    handles.text_warningmessage.String  = ['Left edge of Time range must be smaller than',32,num2str(ERP.times(end))];
    return;
end
if timeRange(2)<=ERP.times(1)
    handles.edit1_time_range.String = num2str([handles.timeStart,handles.timEnd]);
    handles.text_warningmessage.String  = ['Right edge of Time range must be lager than',32,num2str(ERP.times(1))];
    return;
end
if timeRange(1) > timeRange(2)
    handles.edit1_time_range.String = num2str([handles.timeStart,handles.timEnd]);
    handles.text_warningmessage.String  = ['Right edge of Time range must be lager than the left one'];
    return;
end
handles.timeStart= timeRange(1);
handles.timEnd = timeRange(2);
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit1_time_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_yrange_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
yScale = str2num(handles.edit2_yrange.String);
if isempty(yScale) || numel(yScale)~=2
    handles.text_warningmessage.String  = ['Inputs for  Y range are invalid'];
    handles.edit2_yrange.String = num2str(handles.Yscale);
    return;
end
handles.Yscale = yScale;
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit2_yrange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_polarity_up.
function pushbutton_polarity_up_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end

handles.positive_up=1;
handles.pushbutton_polarity_up.Value=1;
handles.radiobutton6.Value=0;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);



%----previous bin
function pushbutton_binsmall_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end

BinArray_edit = str2num(handles.edit_bin.String);
if numel(BinArray_edit)~=1
    handles.text_warningmessage.String  = ['Please enter a single value for bin first before using "<".'];
    return;
end
BinArray = handles.BinArray;
BinArray =reshape(BinArray,1,numel(BinArray));
[~,binpos] = find(BinArray ==BinArray_edit);
if isempty(binpos)
    BinArray_edit = BinArray(1);
    binpos = 1;
end

binpos = binpos-1;
if binpos<1
    binpos = 1;
end
% handles.BinArray = BinArraynew;
if numel(BinArray_edit)~=1
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
else
    if binpos==1
        handles.pushbutton_binsmall.Enable = 'off';
        handles.pushbutton_binlarge.Enable = 'on';
    elseif binpos == numel(BinArray)
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'off';
    else
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'on';
    end
end
binpos = vect2colon(BinArray(binpos),'Sort', 'off');
binpos = erase(binpos,{'[',']'});
handles.edit_bin.String = binpos;

guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);

% -- next bin
function pushbutton_binlarge_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end

BinArray_edit = str2num(handles.edit_bin.String);
if numel(BinArray_edit)~=1
    handles.text_warningmessage.String  = ['Please enter a single value for bin first before using ">".'];
    return;
end

BinArray = handles.BinArray;
BinArray =reshape(BinArray,1,numel(BinArray));
[~,binpos] = find(BinArray ==BinArray_edit);
if isempty(binpos)
    BinArray_edit = BinArray(1);
    binpos = 1;
end


binpos = binpos+1;
if binpos> numel(BinArray)
    binpos = numel(BinArray);
end


if numel(binpos)~=1
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
else
    if binpos==1
        handles.pushbutton_binsmall.Enable = 'off';
        handles.pushbutton_binlarge.Enable = 'on';
    elseif binpos == numel(BinArray)
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'off';
    else
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'on';
    end
end
BinArraynew = BinArray(binpos);
BinArraynew = vect2colon(BinArraynew,'Sort', 'off');
BinArraynew = erase(BinArraynew,{'[',']'});
handles.edit_bin.String = BinArraynew;
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


function edit_bin_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end

BinArray = str2num(handles.edit_bin.String);
if isempty(BinArray) || any(BinArray<=0) || any(BinArray>ERP.nbin)
    BinArray1 = vect2colon(handles.BinArray,'Sort', 'off');
    BinArray1 = erase(BinArray1,{'[',']'});
    handles.edit_bin.String =BinArray1;
    handles.text_warningmessage.String  = ['Input(s) for bin must be between 1 and ',32,num2str(ERP.nbin)];
    return;
end
handles.BinArray = BinArray;
if numel(BinArray)~=1
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
else
    if BinArray==1
        handles.pushbutton_binsmall.Enable = 'off';
        handles.pushbutton_binlarge.Enable = 'on';
    elseif BinArray == ERP.nbin
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'off';
    else
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'on';
    end
end
if  numel(BinArray)~=ERP.nbin
    handles.checkbox1_bin.Value=0;
else
    handles.checkbox1_bin.Value=1;
end
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_bin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1_bin.
function checkbox1_bin_Callback(hObject, eventdata, handles)

handles.checkbox1_bin.Value=1;
handles.radiobutton_parbin.Value=0;
handles.pushbutton_binsmall.Enable = 'off';
handles.pushbutton_binlarge.Enable = 'off';
handles.edit_bin.Enable = 'on';
handles.pushbutton_browse_bin.Enable = 'off';
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
BinArray = vect2colon(handles.BinArray,'Sort', 'off');
BinArray = erase(BinArray,{'[',']'});
handles.edit_bin.String = BinArray;

guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- previous channel
function pushbutton8_chansmall_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
ChanArray_edit = str2num(handles.edit_chans.String);
if numel(ChanArray_edit)~=1
    handles.text_warningmessage.String  = ['Please enter a single value for channel first before using "<".'];
    return;
end

ChanArray = handles.ChanArray;
ChanArray =reshape(ChanArray,1,numel(ChanArray));
[~,chanpos] = find(ChanArray ==ChanArray_edit);
if isempty(chanpos)
    ChanArray_edit = ChanArray(1);
    chanpos = 1;
end


chanpos = chanpos-1;
if chanpos<1
    chanpos=1;
end

if numel(chanpos)~=1
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
else
    if chanpos==1
        handles.pushbutton8_chansmall.Enable = 'off';
        handles.pushbutton_chanlarge.Enable = 'on';
    elseif chanpos==numel(ChanArray)
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'off';
    else
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'on';
    end
end

ChanArray11 = vect2colon(ChanArray(chanpos),'Sort', 'off');
ChanArray11 = erase(ChanArray11,{'[',']'});
handles.edit_chans.String =  ChanArray11;
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- next channel
function pushbutton_chanlarge_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
ChanArray_edit = str2num(handles.edit_chans.String);
if numel(ChanArray_edit)~=1
    handles.text_warningmessage.String  = ['Please enter a single value for channel first before using ">".'];
    return;
end

ChanArray = handles.ChanArray;
ChanArray =reshape(ChanArray,1,numel(ChanArray));
[~,chanpos] = find(ChanArray ==ChanArray_edit);
if isempty(chanpos)
    ChanArray_edit = ChanArray(1);
    chanpos = 1;
end
chanpos = chanpos+1;
if chanpos>numel(ChanArray)
    chanpos = numel(ChanArray);
end

if numel(chanpos)~=1
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
else
    if chanpos==1
        handles.pushbutton8_chansmall.Enable = 'off';
        handles.pushbutton_chanlarge.Enable = 'on';
    elseif chanpos==numel(ChanArray)
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'off';
    else
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'on';
    end
end

ChanArray11 = vect2colon(ChanArray(chanpos),'Sort', 'off');
ChanArray11 = erase(ChanArray11,{'[',']'});
handles.edit_chans.String =  ChanArray11;
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);



function edit_chans_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
ChanArray = str2num(handles.edit_chans.String);
if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>ERP.nchan)
    handles.text_warningmessage.String  = ['Inputs for channels must be between 1 and',32,num2str(ERP.nchan)];
    
    ChanArray11 = vect2colon(handles.ChanArray,'Sort', 'off');
    ChanArray11 = erase(ChanArray11,{'[',']'});
    handles.edit_chans.String = ChanArray11;
    return;
end
handles.ChanArray = ChanArray;
ChanArray11 = vect2colon(ChanArray,'Sort', 'off');
ChanArray11 = erase(ChanArray11,{'[',']'});
handles.edit_chans.String = ChanArray11;
if numel(ChanArray)~=1
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
else
    if ChanArray==1
        handles.pushbutton8_chansmall.Enable = 'off';
        handles.pushbutton_chanlarge.Enable = 'on';
    elseif ChanArray ==ERP.nchan
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'off';
    else
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'on';
    end
end
if numel(ChanArray)~=ERP.nchan
    handles.checkbox_chan.Value=0;
else
    handles.checkbox_chan.Value=1;
end
guidata(hObject, handles);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_chans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_chan.
function checkbox_chan_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
handles.radiobutton_chanpor.Value=0;
handles.checkbox_chan.Value=1;
handles.pushbutton8_chansmall.Enable = 'off';
handles.pushbutton_chanlarge.Enable = 'off';
handles.pushbutton_chanborwse.Enable = 'off';
handles.edit_chans.Enable = 'on';
handles.radiobutton_chanoverlay.Enable = 'on';
handles.radiobutton_chan_separate.Enable = 'on';
if isempty(ALLERP) || isempty(ERP)
    return;
end

ChanArray11 = vect2colon(handles.ChanArray,'Sort', 'off');
ChanArray11 = erase(ChanArray11,{'[',']'});
handles.edit_chans.String = ChanArray11;
% handles.ChanArray = 1:ERP.nchan;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- previous ERPset
function pushbutton_erpsetsmall_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
ERPArray =  str2num(handles.edit5_erpset.String);
if numel(ERPArray)~=1
    handles.text_warningmessage.String  = ['Please enter a single value for ERPsets first before using "<".'];
    return;
end
ERPArray_new = ERPArray-1;
if ERPArray_new<1
    ERPArray_new=1;
end

if ERPArray_new==1
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'on';
elseif ERPArray_new==length(ALLERP)
    handles.pushbutton_erpsetsmall.Enable = 'on';
    handles.pushbutton_erpsetlarge.Enable = 'off';
else
    handles.pushbutton_erpsetsmall.Enable = 'on';
    handles.pushbutton_erpsetlarge.Enable = 'on';
end
handles.CurrentERP = ERPArray_new;
handles.edit5_erpset.String = num2str(ERPArray_new);
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);

% --- Next erpset
function pushbutton_erpsetlarge_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
ERPArray =  str2num(handles.edit5_erpset.String);
if numel(ERPArray)~=1
    handles.text_warningmessage.String  = ['Please enter a single value for ERPsets first before using "<".'];
    return;
end
ERPArray_new = ERPArray+1;
if ERPArray_new > length(ALLERP)
    ERPArray_new=length(ALLERP);
end
if ERPArray_new==1
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'on';
elseif ERPArray_new==length(ALLERP)
    handles.pushbutton_erpsetsmall.Enable = 'on';
    handles.pushbutton_erpsetlarge.Enable = 'off';
else
    handles.pushbutton_erpsetsmall.Enable = 'on';
    handles.pushbutton_erpsetlarge.Enable = 'on';
end
handles.edit5_erpset.String = num2str(ERPArray_new);
handles.CurrentERP = ERPArray_new;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);



function edit5_erpset_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end
ERPArray = str2num(handles.edit5_erpset.String);
if isempty(ERPArray) || any(ERPArray(:)>length(ALLERP)) || any(ERPArray(:)<1)
    handles.text_warningmessage.String  = ['Index of ERPset must be single value and not more than',32,num2str(length(ALLERP))];
    handles.edit5_erpset.String = num2str(handles.CurrentERP);
    return;
end
handles.CurrentERP = ERPArray;
if numel(ERPArray)==1
    if ERPArray==1
        handles.pushbutton_erpsetsmall.Enable = 'off';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    elseif ERPArray==length(ALLERP)
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'off';
    else
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    end
else
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'off';
end

checkindex = checkerpsets(ALLERP(ERPArray));
if ~isempty(checkindex)
    handles.text_warningmessage.String = [checkindex,'. You cannot display multiple ERPsets simultaneously'];
    ERPArray = ERPArray(1);
    handles.CurrentERP = ERPArray;
    handles.edit5_erpset.String = str2num(ERPArray);
    if ERPArray==1
        handles.pushbutton_erpsetsmall.Enable = 'off';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    elseif ERPArray==length(ALLERP)
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'off';
    else
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    end
    
end

handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit5_erpset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_erp.
function checkbox_erp_Callback(hObject, eventdata, handles)
handles.checkbox_erp.Value=1;
handles.radiobutton_erppor.Value=0;
handles.edit5_erpset.Enable = 'off';
handles.pushbutton_erpsetsmall.Enable = 'off';
handles.pushbutton_erpsetlarge.Enable = 'off';
handles.pushbutton_erpset_browse.Enable = 'off';

ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end
ERPArray = str2num(handles.edit5_erpset.String);
if isempty(ERPArray) || any(ERPArray(:)>length(ALLERP))
    ERPArray=1;
    handles.edit5_erpset.String = '1';
end
checkindex = checkerpsets(ALLERP);

if ~isempty(checkindex)
    handles.text_warningmessage.String = [checkindex,'. You cannot display multiple ERPsets simultaneously'];
    handles.checkbox_erp.Value=0;
    handles.radiobutton_erppor.Value=1;
    handles.edit5_erpset.Enable = 'on';
    handles.pushbutton_erpsetsmall.Enable = 'on';
    handles.pushbutton_erpsetlarge.Enable = 'on';
    handles.pushbutton_erpset_browse.Enable = 'on';
    if isempty(ERPArray)
        ERPArray=1;
    else
        ERPArray = ERPArray(1);
    end
    handles.edit5_erpset.String = num2str(ERPArray);
    handles.CurrentERP = ERPArray;
    if ERPArray==1
        handles.pushbutton_erpsetsmall.Enable = 'off';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    elseif ERPArray==length(ALLERP)
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'off';
    else
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    end
    return;
end

ERPArray = [1:length(ALLERP)];
handles.edit5_erpset.String = num2str(ERPArray);
ERPArray = vect2colon(ERPArray,'Sort', 'off');
ERPArray = erase(ERPArray,{'[',']'});
handles.edit5_erpset.String = ERPArray;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


function checkindex = checkerpsets(ALLERP)
if isempty(ALLERP)
    return;
end
checkindex = '';

for Numoferp = 1:length(ALLERP)
    Numchan(Numoferp) = ALLERP(Numoferp).nchan;
    Numbin(Numoferp) = ALLERP(Numoferp).nbin;
    Numpnts(Numoferp) = ALLERP(Numoferp).pnts;
    Numsrate(Numoferp) = ALLERP(Numoferp).srate;
    Numxmin(Numoferp) = ALLERP(Numoferp).xmin;
    Numxmax(Numoferp) = ALLERP(Numoferp).xmax;
end
if numel(unique(Numchan))~=1
    checkindex  = 'Number of channels varies across ERPsets';
    return;
end

if numel(unique(Numbin))~=1
    checkindex  = 'Number of bins varies across ERPsets';
    return;
end

if numel(unique(Numpnts))~=1
    checkindex  = 'Number of sample points varies across ERPsets';
    return;
end

if numel(unique(Numsrate))~=1
    checkindex  = 'Sampling rate varies across ERPsets';
    return;
end

if numel(unique(Numxmin))~=1
    checkindex  = 'Minimal value of the epoch varies across ERPsets';
    return;
end

if numel(unique(Numxmax))~=1
    checkindex  = 'Maximal value of the epoch varies across ERPsets';
    return;
end



% --- Executes on button press in pushbutton_matlabfig.
function pushbutton_matlabfig_Callback(hObject, eventdata, handles)

f_plot_wave_viewer_popup(hObject,handles);


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% handles.output = [];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);
delete(handles.figure1);



% -----------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    %The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';
    %Update handles structure
    guidata(hObject, handles);
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end



function handles = plot_wave_viewer(hObject,handles)
try ALLERP = handles.ALLERP;catch ALLERP = [];  end

if isempty(ALLERP)
    return;
end
handles.ALLERP=ALLERP;
%%current erp
ERPArray=str2num(handles.edit5_erpset.String);
if isempty(ERPArray)  || any(ERPArray(:)> length(ALLERP)) || any(ERPArray(:)<1)
    ERPArray = 1;
    handles.CurrentERP = ERPArray;
end
checkindex = checkerpsets(ALLERP(ERPArray));
if ~isempty(checkindex)
    handles.text_warningmessage.String = [checkindex,'. You cannot display multiple ERPsets simultaneously'];
    handles.checkbox_erp.Value=0;
    handles.radiobutton_erppor.Value=1;
    ERPArray = ERPArray(1);
end

handles.edit5_erpset.String = num2str(ERPArray);
if numel(ERPArray)==1
    if ERPArray==1
        handles.pushbutton_erpsetsmall.Enable = 'off';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    elseif ERPArray==length(ALLERP)
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'off';
    else
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    end
else
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'off';
end
if numel(ERPArray)== numel(ALLERP)
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'off';
end
ERP = ALLERP(ERPArray(1));
if numel(ERPArray)==1
    handles.text_erpname.String = ERP.erpname;
else
    handles.text_erpname.String = 'Multiple ERPsets were slected';
end

%%channels
ChanArray_new = str2num(handles.edit_chans.String);
nbchan = ERP.nchan;
handles.ERP = ERP;
ChanArray = handles.ChanArray;
ChanArray =reshape(ChanArray,1,numel(ChanArray));
if isempty(ChanArray_new) || any(ChanArray_new>nbchan) || any(ChanArray_new<=0)
    ChanArray_new =ChanArray;
    handles.ChanArray = ChanArray_new;
end

if handles.radiobutton_chanpor.Value==1
    [~,chanpos] = find(ChanArray ==ChanArray_new);
else
    chanpos=1;
end
if isempty(chanpos)
    ChanArray_new = ChanArray(1);
    handles.edit_chans.String = num2str( ChanArray(1));
    chanpos = 1;
end

if numel(ChanArray_new)~=1
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
else
    if chanpos==1
        handles.pushbutton8_chansmall.Enable = 'off';
        handles.pushbutton_chanlarge.Enable = 'on';
    elseif chanpos==numel(ChanArray)
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'off';
    else
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'on';
    end
end
if numel(ChanArray_new) == numel(handles.ChanArray)
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
end

ChanArray11 = vect2colon(ChanArray_new,'Sort', 'off');
ChanArray11 = erase(ChanArray11,{'[',']'});
handles.edit_chans.String =  ChanArray11;

chanOverlay = handles.radiobutton_chanoverlay.Value;

%%bin
nbin = ERP.nbin;
BinArray_edit =str2num(handles.edit_bin.String);
if isempty(BinArray_edit) || any(BinArray_edit>nbin) || any(BinArray_edit<=0)
    BinArray_edit = [1:nbin];
    handles.BinArray = BinArray;
end
BinArray = handles.BinArray;
BinArray =reshape(BinArray,1,numel(BinArray));
if handles.radiobutton_erppor.Value==1
    [~,binpos] = find(BinArray==BinArray_edit);
else
    BinArray = [];
    binpos =1;
end
if isempty(binpos)
    BinArray_edit = BinArray(1);
    handles.edit_bin.String = num2str(BinArray_edit);
    binpos = 1;
end

if numel(BinArray_edit)~=1
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
else
    if binpos==1
        handles.pushbutton_binsmall.Enable = 'off';
        handles.pushbutton_binlarge.Enable = 'on';
    elseif binpos == numel(BinArray)
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'off';
    else
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'on';
    end
end

if numel(BinArray_edit)== numel(handles.BinArray)
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
end
BinArray1 = vect2colon(BinArray_edit,'Sort', 'off');
BinArray1 = erase(BinArray1,{'[',']'});
handles.edit_bin.String = BinArray1;

%%-----------------------create the panel----------------------------------
FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def)
    ColorB_def = [0.7020 0.77 0.85];
end
handles.ViewContainer = handles.uipanel1_viewer;
handles.plotgrid = uiextras.VBox('Parent',handles.ViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);

handles.plot_wav_legend = uiextras.HBox( 'Parent', handles.plotgrid,'BackgroundColor',[1 1 1]);
handles.ViewAxes_legend = uix.ScrollingPanel( 'Parent', handles.plot_wav_legend,'BackgroundColor',[1 1 1]);
handles.plot_wav = uiextras.HBox( 'Parent', handles.plotgrid,'BackgroundColor',[1 1 1]);
handles.ViewAxes = uix.ScrollingPanel( 'Parent', handles.plot_wav,'BackgroundColor',[1 1 1]);


handles.erptabwaveiwer = axes('Parent', handles.ViewAxes,'Color','none','Box','on','FontWeight','normal');
hold(handles.erptabwaveiwer,'on');
handles.erptabwaveiwer_legend = axes('Parent', handles.ViewAxes_legend,'Color','none','Box','off');
hold(handles.erptabwaveiwer_legend,'on');
set(handles.erptabwaveiwer_legend, 'XTick', [], 'YTick', []);
handles.ERP_M_T_Viewer = uiextras.HBox( 'Parent', handles.plotgrid,'BackgroundColor',ColorB_def);

timeStart =handles.timeStart;
timEnd =handles.timEnd;
if isempty(timeStart)|| numel(timeStart)~=1 || timeStart>=ERP.times(end)
    timeStart=ERP.times(1);
    timEnd = ERP.times(end);
    handles.timeStart=timeStart;
    handles.timEnd=timEnd;
end
if isempty(timEnd)|| numel(timEnd)~=1 || timEnd<=ERP.times(1)
    timeStart=ERP.times(1);
    timEnd = ERP.times(end);
    handles.timeStart=timeStart;
    handles.timEnd=timEnd;
end
handles.edit1_time_range.String = num2str([timeStart,timEnd]);

xtickstep=handles.xtickstep;
[~, chanLabels, ~, ~, ~] = readlocs(ERP.chanlocs);
Yscale = handles.Yscale;
bindata = [];
ChanArray = str2num(handles.edit_chans.String);
BinArray = str2num(handles.edit_bin.String);
for Numoferp = 1:numel(ERPArray)
    ERP = ALLERP(ERPArray(Numoferp));
    bindata(:,:,:,Numoferp) = ERP.bindata(ChanArray,:,BinArray);
end
y_scale_def = [floor(1.1*min(bindata(:))),ceil(1.1*max(bindata(:)))];
if isempty(Yscale) || numel(Yscale)~=2
    Yscale= y_scale_def;
    handles.Yscale=Yscale;
end
handles.edit2_yrange.String = num2str(Yscale);

Min_vspacing = handles.Min_vspacing;
positive_up = handles.positive_up;
moption= handles.moption;
latency= handles.latency;
Min_time = ERP.times(1);
Max_time = ERP.times(end);
blc = handles.blc;
intfactor =  handles.intfactor;
Resolution =handles.Resolution;
BinchanOverlay = 0;
columNum=1;
if chanOverlay==0
    rowNums=numel(ChanArray);
else
    rowNums=1;
end

handles.GridposArray = zeros(rowNums,columNum);
for ii = 1:rowNums
    handles.GridposArray(ii,1) =   ChanArray(ii);
end
GridposArray = handles.GridposArray;



%%----------------------measurement name-----------------------------------
measurearray = {'Instantaneous amplitude',...
    'Mean amplitude between two fixed latencies',...
    'Peak amplitude',...
    'Peak latency',...
    'Fractional Peak latency',...
    'Numerical integration/Area between two fixed latencies',...
    'Fractional Area latency'};
meacodes    =      {'instabl', 'meanbl', 'peakampbl', 'peaklatbl', 'fpeaklat',...
    'areat', 'areap', 'arean','fareatlat',...
    'fareaplat','fninteglat','fareanlat', 'ninteg'};

[tfm, indxmeaX] = ismember_bc2({moption}, meacodes);

if ismember_bc2(indxmeaX,[6 7 8 13])%'areat','areap', 'arean','ninteg',
    meamenu = 6; %  'Numerical integration/Area between two fixed latencies',...
    % elseif ismember_bc2(indxmeaX,[9 10 11 17])%
    %     meamenu = 7; %  'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
elseif ismember_bc2(indxmeaX,[9 10 11 12])%'fareatlat','fareaplat','fninteglat','fareanlat',
    meamenu = 7; %  'Fractional Area latency'
elseif ismember_bc2(indxmeaX,1)%'instabl'
    meamenu = 1; % 'Instantaneous amplitude',...
elseif ismember_bc2(indxmeaX,2)%'meanbl',
    meamenu = 2; % 'mean amp
elseif ismember_bc2(indxmeaX,3)%'peakampbl',
    meamenu = 3; % 'peak amp',...
elseif ismember_bc2(indxmeaX,4)%'peaklatbl'
    meamenu = 4; % 'peak lat',...
elseif ismember_bc2(indxmeaX,5)%'fpeaklat'
    meamenu = 5; % 'Fractional Peak latency',..',...
else
    meamenu = 1; % 'Instantaneous amplitude',...%'instabl',
end
mls = sprintf('%s\n%s',measurearray{meamenu},['Measurement Window:',32,num2str(handles.latency)]);

set(handles.text_measure_type, 'String', mls);
offset = f_plotaberpwave(ALLERP,ERPArray,ERP,ChanArray,BinArray,timeStart,timEnd,xtickstep,Yscale,columNum,...
    positive_up,chanOverlay,rowNums,GridposArray,handles.erptabwaveiwer,handles.erptabwaveiwer_legend);
% set(handles.erptabwaveiwer,'BackgroundColor',[1 1 1]);
Res = handles.ViewContainer.Position;
handles.Res = Res;
splot_n = numel(ChanArray);

pb_height = Min_vspacing*Res(4);  %px

ndata = BinArray;


pnts    = ERP.pnts;
timeor  = ERP.times; % original time vector
p1      = timeor(1);
p2      = timeor(end);
if intfactor~=1
    timex = linspace(p1,p2,round(pnts*intfactor));
else
    timex = timeor;
end
[xxx, latsamp, latdiffms] = closest(timex, [Min_time Max_time]);
tmin = latsamp(1);
tmax = latsamp(2);
if tmin < 1
    tmin = 1;
end
if tmax > numel(timex)
    tmax = numel(timex);
end
Plot_erp_data_TRAN = [];
for Numofsub = 1:numel(ERPArray)
    ERP1 = ALLERP(ERPArray(Numofsub));
    if intfactor~=1
        for Numoftwo = 1:size(ERP1.bindata,3)
            for Numofone = 1:size(ERP1.bindata,1)
                data = squeeze(ERP1.bindata(Numofone,:,Numoftwo));
                data  = spline(timeor, data, timex); % re-sampled data
                blv    = blvalue2(data, timex, blc);
                data   = data - blv;
                Plot_erp_data_TRAN(Numofone,:,Numoftwo) = data;
            end
        end
        Bindata(:,:,:,Numofsub) = Plot_erp_data_TRAN;
    else
        Bindata(:,:,:,Numofsub) = ERP1.bindata;
    end
end

plot_erp_data = nan(splot_n,tmax-tmin+1,numel(ndata));
for Numofsub = 1:numel(ERPArray)
    for i = 1:splot_n
        for i_bin = 1:numel(ndata)
            plot_erp_data(i,:,i_bin,Numofsub) = Bindata(ChanArray(i),tmin:tmax,BinArray(i_bin),Numofsub)'*positive_up; %
        end
    end
end

[Numchan,Numsamp,Numbin,Numerp] = size(plot_erp_data);
if chanOverlay==1
    %     plot_erp_data = permute(plot_erp_data,[2 1 3 4]);
    %     plot_erp_data = reshape(plot_erp_data,1,Numsamp,Numchan*Numbin*Numerp);
    plot_erp_data11 = [];
    count = 0;
    for Numoferp = 1:Numerp
        for Numofchan = 1: Numchan
            for Numofbin = 1:Numbin
                count = count+1;
                plot_erp_data11(1,:,count) = squeeze(plot_erp_data(Numofchan,:,Numofbin,Numoferp));
            end
        end
    end
    plot_erp_data = plot_erp_data11;
else
    %     plot_erp_data = reshape(plot_erp_data,Numchan,Numsamp,Numbin*Numerp);
    plot_erp_data11 = [];
    count = 0;
    for Numoferp = 1:Numerp
        for Numofbin = 1:Numbin
            count = count+1;
            plot_erp_data11(:,:,count) = squeeze(plot_erp_data(:,:,Numofbin,Numoferp));
        end
    end
    plot_erp_data = plot_erp_data11;
end

[~,~,Num_plot] = size(plot_erp_data);
line_colors = get_colors(Num_plot);

% line_colors = repmat(line_colors,[splot_n 1]); %repeat the colors once for every plot
% return;
for i = 1:size(plot_erp_data,1)
    plot_erp_data(i,:,:) = plot_erp_data(i,:,:) + ones(size(plot_erp_data(i,:,:)))*offset(i);
end
if chanOverlay==1
    offset = zeros(size(plot_erp_data,3),1);
end
%
%%%Mark the area/latency/amplitude of interest within the defined window.
ERP_mark_area_latency(handles.erptabwaveiwer,timex(tmin:tmax),moption,plot_erp_data,latency,...
    line_colors,offset,positive_up,ERP,ChanArray,BinArray,Yscale,ALLERP,ERPArray,chanOverlay);%cwm = [0 0 0];% white: Background color for measurement window
set(handles.erptabwaveiwer,'color',[1 1 1]);
% %%%-------------------Display results obtained from "Measurement Tool" Panel---------------------------------
offset1 = zeros(numel(ChanArray),1);
for Numofsub = 1:numel(ERPArray)
    ERP1 =  ALLERP(ERPArray(Numofsub));
    [~,~,~,Amp1,Lat1]= f_ERP_plot_wav(ERP1,offset1,ChanArray,BinArray);
    Amp(:,:,Numofsub) = Amp1;
    Lat(:,:,Numofsub) = Lat1;
end

RowName = {};
count = 0;
for Numofsub = 1:numel(ERPArray)
    for Numofbin = 1:numel(BinArray)
        count = count+1;
        RowName{count} = strcat('Set:',32,num2str(ERPArray(Numofsub)));
    end
end

ColumnName{1} = '#Bin';
for Numofsel_chan = 1:numel(ChanArray)
    ColumnName{Numofsel_chan+1} = ['<html><font size= >',num2str(ChanArray(Numofsel_chan)),'.',32,chanLabels{ChanArray(Numofsel_chan)}];
    
end
line_colors_ldg = get_colors(Num_plot);

if ismember_bc2(moption, {'instabl','peaklatbl','fpeaklat','fareatlat','fninteglat','fareaplat','fareanlat','meanbl','peakampbl','areat','ninteg','areap','arean','ninteg','areazt','nintegz','areazp','areazn'})
    Data_display = Amp(BinArray,ChanArray,:);
else
    Data_display = Lat(BinArray,ChanArray,:);
end
if ismember_bc2(moption,{'arean','areazn'})
    Data_display= -1.*Data_display;
end

Data_display_tra = {};
count = 0;
for Numofsub = 1:numel(ERPArray)
    for Numofbin = 1:numel(BinArray)
        count = count+1;
        Data_display1(count,:) = Data_display(Numofbin,:,Numofsub);
        Data_display_tra{count,1} = sprintf(['<html><tr><td align=center width=9999><FONT color="black">%.',num2str(0),'f'], BinArray(Numofbin));
    end
end

for Numofone = 1:size(Data_display1,1)
    for Numoftwo = 1:size(Data_display1,2)
        if ~isnan(Data_display1(Numofone,Numoftwo))
            Data_display_tra{Numofone,Numoftwo+1} = sprintf(['<html><tr><td align=center width=9999><FONT color="black">%.',num2str(Resolution),'f'], Data_display1(Numofone,Numoftwo));
        else
            Data_display_tra{Numofone,Numoftwo+1} = ['<html><tr><td align=center width=9999><FONT color="black">NaN'];
        end
    end
end

handles.ERP_M_T_Viewer_table = uitable(handles.ERP_M_T_Viewer,'Data',Data_display_tra,'Units','Normalize');
handles.ERP_M_T_Viewer_table.RowName = RowName;
handles.ERP_M_T_Viewer_table.ColumnName = ColumnName;


if numel(ChanArray)<12
    ColumnWidth = {};
    for Numofchan =1:numel(ChanArray)+1
        ColumnWidth{Numofchan} = handles.ERP_M_T_Viewer.Position(3)/(numel(ChanArray)+1);
    end
    handles.ERP_M_T_Viewer_table.ColumnWidth = ColumnWidth;
elseif numel(ChanArray) ==1
    handles.ERP_M_T_Viewer_table.ColumnWidth = {handles.ERP_M_T_Viewer.Position(3)};
end


handles.plotgrid.Heights(1) = 70; % set the first element (pageinfo) to 30px high
handles.plotgrid.Heights(2) = -1; % set the second element (x axis) to 30px high
handles.plotgrid.Heights(3) = 100;
handles.plotgrid.Units = 'pixels';

if Num_plot*pb_height<(handles.plotgrid.Position(4)-handles.plotgrid.Heights(1))
    pb_height = (handles.plotgrid.Position(4)-handles.plotgrid.Heights(1)-handles.plotgrid.Heights(2))/Num_plot;
end
handles.ViewAxes.Heights = Num_plot*pb_height;
handles.ERP_M_T_Viewer_table.FontSize = FonsizeDefault;
handles.text_warningmessage.String ='';
guidata(hObject, handles);


function OffSetY = f_plotaberpwave(ALLERP,ERPArray,ERP,ChanArray,BinArray,timeStart,timEnd,xtickstep,qYScales,columNum,...
    positive_up,chanOverlay,rowNums,GridposArray,waveview,legendview)
OffSetY = [];
FonsizeDefault = f_get_default_fontsize();
%%matlab version
matlab_ver = version('-release');
Matlab_ver = str2double(matlab_ver(1:4));

qtimeRange = [timeStart timEnd];

qPLOTORG = [1 2 3];
[~, qplotArrayStr, ~, ~, ~]  = readlocs(ERP.chanlocs(ChanArray));
qLegendName= ERP.bindescr(BinArray);
for Numoferp = 1:numel(ERPArray)
    ERP1 = ALLERP(ERPArray(Numoferp));
    [ERPdatadef1,legendNamedef,ERPerrordatadef,timeRangedef] = f_geterpdata(ERP1,1,qPLOTORG,1);
    ERPdatadef(:,:,:,Numoferp) = ERPdatadef1;
end
bindata = ERPdatadef(ChanArray,:,BinArray,:);
[Numchan,Numsamp,Numbin,Numerp] = size(bindata);

if chanOverlay==1
    plotArray=1;
    bindata = permute(bindata,[2 1 3 4]);
    bindata = reshape(bindata,1,Numsamp,Numchan*Numbin*Numerp);
    qplotArrayStr{1,1} = 'No label';
else
    plotArray = ChanArray;
    bindata = reshape(bindata,Numchan,Numsamp,Numbin*Numerp);
    count = 0;
    for Numofsub = 1:numel(ERPArray)
        for Numofbin = 1:numel(BinArray)
            count = count+1;
            qLegendName1{count} = ['ERPset',32,num2str(Numofsub),':',qLegendName{Numofbin}];
        end
    end
    qLegendName = qLegendName1;
end


if isempty(timeRangedef)
    timeRangedef = ERP.times;
end
fs= ERP.srate;
% qYScales = [-YtickInterval,YtickInterval];
Ypert =20;
%%get y axis
y_scale_def = [1.1*min(bindata(:)),1.1*max(bindata(:))];
if numel(qYScales)==2 && qYScales(1) <qYScales(2)
    yscaleall = qYScales(end)-qYScales(1);
else
    yscaleall = 2*max(abs(qYScales));
    qYScales = [-max(abs(qYScales)),max(abs(qYScales))];
end

for Numofrows = 1:rowNums
    OffSetY(Numofrows) = yscaleall*(rowNums-Numofrows)*(Ypert/100+1);
end

qYticksdef = str2num(char(default_amp_ticks_viewer(qYScales)));
qYticks = [qYScales(1),0, qYScales(2)];
if isempty(qYticks) || numel(qYticks)<2
    qYticks = qYticksdef;
end


%%gap between columns
Xpert = 20;
try
    StepX = (ERP.times(end)-ERP.times(1))*(Xpert/100);
catch
    beep;
    disp('ERP.times only has one element.');
    return;
end
StepXP = ceil(StepX/(1000/fs));

qPolarityWave = positive_up;

NumOverlay = size(bindata,3);

isxaxislabel=1;

%%line color
qLineColorspec = get_colors(NumOverlay);
%%xticks
[timeticksdef stepX]= default_time_ticks_studio(ERP, qtimeRange);
timeticksdef = str2num(char(timeticksdef));
qtimeRangedef = round(qtimeRange/100)*100;
qXticks = xtickstep+qtimeRangedef(1);
for ii=1:1000
    xtickcheck = qXticks(end)+xtickstep;
    if xtickcheck>qtimeRangedef(2)
        break;
    else
        qXticks(numel(qXticks)+1) =xtickcheck;
    end
end
if isempty(qXticks)|| stepX==xtickstep
    qXticks =  timeticksdef;
end
%%remove the margins of a plot
ax = waveview;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%%check elements in qGridposArray
if chanOverlay==1
    GridposArray(1,1)=1;
else
    plotArray = reshape(plotArray,1,[]);
    for Numofrows = 1:size(GridposArray,1)
        for Numofcolumns = 1:size(GridposArray,2)
            SingleGridpos = GridposArray(Numofrows,Numofcolumns);
            if SingleGridpos~=0
                ExistGridops = f_existvector(plotArray,SingleGridpos);
                if ExistGridops==1
                    GridposArray(Numofrows,Numofcolumns) =0;
                else
                    [xpos,ypos]=  find(plotArray==SingleGridpos);
                    GridposArray(Numofrows,Numofcolumns) =ypos;
                end
            end
        end
    end
end
fontnames = 'Helvetica';

hplot = [];
countPlot = 0;
for Numofrows = 1:rowNums
    for Numofcolumns = 1:columNum
        try
            plotdatalabel = GridposArray(Numofrows,Numofcolumns);
        catch
            plotdatalabel = 0;
        end
        
        try
            labelcbe = qplotArrayStr{plotdatalabel};
            if isempty(labelcbe)
                labelcbe  = '';
            end
        catch
            labelcbe = 'no';
        end
        if chanOverlay==1
            labelcbe  = '';
        end
        try
            plotbindata =  bindata(plotdatalabel,:,:,:);
        catch
            plotbindata = [];
        end
        
        if plotdatalabel ~=0 && plotdatalabel<= numel(plotArray) && ~isempty(plotbindata)
            countPlot =countPlot +1;
            if qPolarityWave==1
                data4plot = squeeze(bindata(plotdatalabel,:,:,1));
            else
                data4plot = squeeze(bindata(plotdatalabel,:,:,1))*(-1);
            end
            
            data4plot = reshape(data4plot,numel(timeRangedef),NumOverlay);
            for Numofoverlay = 1:NumOverlay
                [Xtimerange, bindatatrs] = f_adjustbindtabasedtimedefd(squeeze(data4plot(:,Numofoverlay)), timeRangedef,qtimeRange,fs);
                PosIndexsALL = [Numofrows,columNum];
                if isxaxislabel==2
                    [~,XtimerangetrasfALL,~,~,~] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexsALL,StepXP);
                else
                    [~,XtimerangetrasfALL,~] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexsALL,StepX,fs);
                end
                PosIndexs = [Numofrows,Numofcolumns];
                if isxaxislabel==2
                    [bindatatrs,Xtimerangetrasf,qXtickstransf,TimeAdjustOut,XtimerangeadjustALL] = f_adjustdata_xyrange_xyticks_overlay(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexs,StepXP);
                else
                    [bindatatrs,Xtimerangetrasf,qXtickstransf] = f_adjustdata_xyrange_xyticks(bindatatrs,Xtimerange,qXticks,OffSetY,columNum,PosIndexs,StepX,fs);
                end
                hplot(Numofoverlay) = plot(waveview,Xtimerangetrasf, bindatatrs,'LineWidth',1,...
                    'Color', qLineColorspec(Numofoverlay,:));
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust y axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props = get(waveview);
            if qPolarityWave==1
                props.YTick = qYticks+OffSetY(Numofrows);
            else
                props.YTick =  fliplr (-1*qYticks)+OffSetY(Numofrows);
            end
            props.YTickLabel = cell(numel(props.YTick),1);
            
            
            for Numofytick = 1:numel(props.YTick)
                props.YTickLabel(Numofytick) = {num2str(props.YTick(Numofytick))};
            end
            
            [x,y_0] = find(Xtimerange==0);
            if isempty(y_0)
                y_0 = 1;
            end
            myY_Crossing = Xtimerangetrasf(y_0);
            tick_top = 0;
            
            if countPlot ==1
                ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
            else
                try
                    ytick_bottom = ytick_bottom;
                    ytick_bottomratio = ytick_bottomratio;
                catch
                    ytick_bottom = -props.TickLength(1)*diff(props.XLim);
                    ytick_bottomratio = abs(ytick_bottom)/diff(props.XLim);
                end
            end
            %%add  yunits
            if ~isempty(props.YTick)
                ytick_y = repmat(props.YTick, 2, 1);
                ytick_x = repmat([tick_top;ytick_bottom] +myY_Crossing, 1, length(props.YTick));
                line(waveview,ytick_x(:,:), ytick_y(:,:), 'color', 'k','LineWidth',1);
                try
                    [~,y_below0] =find(qYticks<0);
                    if isempty(y_below0) && qYScales(1)<0
                        line(waveview,ytick_x(:,:), ones(2,1)*(qYScales(1)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                    [~,y_over0] =find(qYticks>0);
                    if isempty(y_over0) && qYScales(2)>0
                        line(waveview,ytick_x(:,:), ones(2,1)*(qYScales(2)+OffSetY(Numofrows)), 'color', 'k','LineWidth',1);
                    end
                catch
                end
            end
            
            if ~isempty(qYScales)  && numel(qYScales)==2 %qYScales(end))+OffSetY(1)
                if  qPolarityWave==1
                    qYScalestras = qYScales;
                else
                    qYScalestras =   fliplr (-1*qYScales);
                end
                plot(waveview,ones(numel(qYScalestras),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
            else
                if ~isempty(y_scale_def) && numel(unique(y_scale_def))==2
                    if  qPolarityWave==0
                        qYScalestras = y_scale_def;
                    else
                        qYScalestras =   fliplr (-1*y_scale_def);
                    end
                    plot(waveview,ones(numel(qYScales),1)*myY_Crossing, qYScalestras+OffSetY(Numofrows),'k','LineWidth',1);
                else
                end
            end
            
            qYtickdecimal=1;
            nYTicks = length(props.YTick);
            for iCount = 1:nYTicks
                if qPolarityWave==1
                    ytick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],str2num(char(props.YTickLabel(iCount, :)))-OffSetY(Numofrows));
                else
                    qyticktras =   fliplr(-1*qYticks);
                    ytick_label= sprintf(['%.',num2str(qYtickdecimal),'f'],-qyticktras(iCount));
                end
                %                 end
                if str2num(char(ytick_label)) ==0 || (str2num(char(ytick_label))<0.0001 && str2num(char(ytick_label))>0) || (str2num(char(ytick_label))>-0.0001 && str2num(char(ytick_label))<0)
                    ytick_label = '';
                end
                text(waveview,myY_Crossing-2*abs(ytick_bottom),props.YTick(iCount),  ...
                    ytick_label, ...
                    'HorizontalAlignment', 'right', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', FonsizeDefault, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'FontName', fontnames, ...
                    'Color',[0 0 0]);%
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%----------------------Adjust x axis------------------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            props.XTick = qXtickstransf;
            props.XTickLabel = cell(numel(qXticks),1);
            for Numofytick = 1:numel(props.XTick)
                props.XTickLabel(Numofytick) = {num2str(qXticks(Numofytick))};
            end
            myX_Crossing = OffSetY(Numofrows);
            if countPlot ==1
                xtick_bottom = -props.TickLength(2)*max(props.YLim);
                if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                    xtick_bottom = -ytick_bottomratio*max(props.YLim);
                end
            else
                try
                    xtick_bottom = xtick_bottom;
                catch
                    xtick_bottom = -props.TickLength(2)*max(props.YLim);
                    if abs(xtick_bottom)/max(props.YLim) > ytick_bottomratio
                        xtick_bottom = -ytick_bottomratio*max(props.YLim);
                    end
                end
            end
            if ~isempty(props.XTick)
                xtick_x = repmat(props.XTick, 2, 1);
                xtick_y = repmat([xtick_bottom; tick_top]*0.5 + myX_Crossing, 1, length(props.XTick));
                line(waveview,xtick_x, xtick_y, 'color', 'k','LineWidth',1);
            end
            [x_xtick,y_xtick] = find(props.XTick==0);
            if ~isempty(y_xtick)
                props.XTick(y_xtick) = 2*xtick_bottom;
            end
            plot(waveview,Xtimerangetrasf, myX_Crossing.*ones(numel(Xtimerangetrasf),1),'k','LineWidth',1);
            nxTicks = length(props.XTick);
            qXticklabel = 'on';
            for iCount = 1:nxTicks
                xtick_label = (props.XTickLabel(iCount, :));
                if strcmpi(qXticklabel,'on')
                    if strcmpi(xtick_label,'0')
                        xtick_label = '';
                    end
                else
                    xtick_label = '';
                end
                text(waveview,props.XTick(iCount), xtick_bottom*0.5 + myX_Crossing, ...
                    xtick_label, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Top', ...
                    'FontSize', FonsizeDefault, ...
                    'FontAngle', props.FontAngle, ...
                    'FontUnits', props.FontUnits,...
                    'FontName', fontnames, ...
                    'Color',[0 0 0]);%'FontName', qXlabelfont, ...
            end
            %%-----------------minor X---------------
            set(waveview,'xlim',[Xtimerange(1),Xtimerangetrasf(end)]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%------------------channel/bin/erpset label-----------------%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ypercentage =100;
            ypos_LABEL = (qYScalestras(end)-qYScalestras(1))*(ypercentage)/100+qYScalestras(1);
            xpercentage = 0;
            xpos_LABEL = (Xtimerangetrasf(end)-Xtimerangetrasf(1))*xpercentage/100 + Xtimerangetrasf(1);
            labelcbe =  strrep(char(labelcbe),'_','\_');
            try
                labelcbe = regexp(labelcbe, '\;', 'split');
            catch
            end
            text(waveview,xpos_LABEL,ypos_LABEL+OffSetY(Numofrows), char(labelcbe),'FontName', fontnames,'HorizontalAlignment', 'center');%'FontWeight', 'bold',
        else
        end
        try
            if 2<columNum && columNum<5
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/20,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/20]);
            elseif columNum==1
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/40,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/40]);
            elseif columNum==2
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/30,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/30]);
            else
                set(waveview,'xlim',[Xtimerange(1)-(Xtimerange(end)-Xtimerange(1))/10,XtimerangetrasfALL(end)+(Xtimerange(end)-Xtimerange(1))/10]);
            end
        catch
        end
    end%% end of columns
    ylim([min(OffSetY(:))+min([qYScales(1),y_scale_def(1)]),max(OffSetY(:))+1.1*max([qYScales(end),y_scale_def(2)])]);
    if qPolarityWave==-1
        ylimleftedge = 1.1*min([min(OffSetY(:))+qYScales(1),-abs(y_scale_def(2))]);
        ylim([ylimleftedge, max(OffSetY(:))+1.1*max([abs(qYScales(1)),abs(y_scale_def(1))])]);
    end
end%% end of rows
set(waveview, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
set(legendview, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
if ~isempty(hplot)
    if chanOverlay==0
        for Numofoverlay = 1:numel(hplot)
            qLegendName{Numofoverlay} = strrep(qLegendName{Numofoverlay},'_','\_');
        end
        p  = get(legendview,'position');
        h_legend = legend(legendview,hplot,qLegendName);
        rowNumlg = ceil(sqrt(length(qLegendName)));
        set(h_legend,'NumColumns',1,'FontName', fontnames, 'Color', [1 1 1], 'position', p,'FontSize',FonsizeDefault,'box','off');
    else
        %         qLegendName = {'There are no legend names becuase you selected "Overlay" for chans'};
        %         text(legendview,0.5,0.8,qLegendName ,...
        %             'FontSize',FonsizeDefault+2,'HorizontalAlignment', 'center',  'Color', [1 0 0]);
    end
end

% guidata(hObject, handles);

function f_plot_wave_viewer_popup(hObject,handles)
ALLERP = handles.ALLERP;

if isempty(ALLERP)
    return;
end
handles.ALLERP=ALLERP;
%%current erp
ERPArray=str2num(handles.edit5_erpset.String);
if isempty(ERPArray)  || any(ERPArray(:)> length(ALLERP)) || any(ERPArray(:)<1)
    ERPArray = 1;
    handles.CurrentERP = ERPArray;
end
checkindex = checkerpsets(ALLERP(ERPArray));
if ~isempty(checkindex)
    handles.text_warningmessage.String = [checkindex,'. You cannot display multiple ERPsets simultaneously'];
    handles.checkbox_erp.Value=0;
    handles.radiobutton_erppor.Value=1;
    ERPArray = ERPArray(1);
end

handles.edit5_erpset.String = num2str(ERPArray);
if numel(ERPArray)==1
    if ERPArray==1
        handles.pushbutton_erpsetsmall.Enable = 'off';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    elseif ERPArray==length(ALLERP)
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'off';
    else
        handles.pushbutton_erpsetsmall.Enable = 'on';
        handles.pushbutton_erpsetlarge.Enable = 'on';
    end
else
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'off';
end
if numel(ERPArray)== numel(ALLERP)
    handles.pushbutton_erpsetsmall.Enable = 'off';
    handles.pushbutton_erpsetlarge.Enable = 'off';
end
ERP = ALLERP(ERPArray(1));
if numel(ERPArray)==1
    handles.text_erpname.String = ERP.erpname;
else
    handles.text_erpname.String = 'Multiple ERPsets were slected';
end

%%channels
ChanArray_new = str2num(handles.edit_chans.String);
nbchan = ERP.nchan;
handles.ERP = ERP;
ChanArray = handles.ChanArray;
ChanArray =reshape(ChanArray,1,numel(ChanArray));
if isempty(ChanArray_new) || any(ChanArray_new>nbchan) || any(ChanArray_new<=0)
    ChanArray_new =ChanArray;
    handles.ChanArray = ChanArray_new;
end


[~,chanpos] = find(sort(ChanArray) ==sort(ChanArray_new));
if isempty(chanpos)
    ChanArray_new = ChanArray(1);
    handles.edit_chans.String = num2str( ChanArray(1));
    chanpos = 1;
end

if numel(ChanArray_new)~=1
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
else
    if chanpos==1
        handles.pushbutton8_chansmall.Enable = 'off';
        handles.pushbutton_chanlarge.Enable = 'on';
    elseif chanpos==numel(ChanArray)
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'off';
    else
        handles.pushbutton8_chansmall.Enable = 'on';
        handles.pushbutton_chanlarge.Enable = 'on';
    end
end
if numel(ChanArray_new) == numel(ChanArray)
    handles.pushbutton8_chansmall.Enable = 'off';
    handles.pushbutton_chanlarge.Enable = 'off';
end
ChanArray = ChanArray_new;
ChanArray11 = vect2colon(ChanArray_new,'Sort', 'off');
ChanArray11 = erase(ChanArray11,{'[',']'});
handles.edit_chans.String =  ChanArray11;


%%bin
nbin = ERP.nbin;
BinArray_edit =str2num(handles.edit_bin.String);
if isempty(BinArray_edit) || any(BinArray_edit>nbin) || any(BinArray_edit<=0)
    BinArray_edit = [1:nbin];
    handles.BinArray = BinArray;
end
BinArray = handles.BinArray;
BinArray =reshape(BinArray,1,numel(BinArray));
[~,binpos] = find(sort(BinArray) ==sort(BinArray_edit));
if isempty(binpos)
    BinArray_edit = BinArray(1);
    handles.edit_bin.String = num2str(BinArray_edit);
    binpos = 1;
end

if numel(BinArray_edit)~=1
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
else
    if binpos==1
        handles.pushbutton_binsmall.Enable = 'off';
        handles.pushbutton_binlarge.Enable = 'on';
    elseif binpos == numel(BinArray)
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'off';
    else
        handles.pushbutton_binsmall.Enable = 'on';
        handles.pushbutton_binlarge.Enable = 'on';
    end
end

if numel(BinArray_edit)== numel(BinArray)
    handles.pushbutton_binsmall.Enable = 'off';
    handles.pushbutton_binlarge.Enable = 'off';
end
BinArray =BinArray_edit;
BinArray1 = vect2colon(BinArray_edit,'Sort', 'off');
BinArray1 = erase(BinArray1,{'[',']'});
handles.edit_bin.String = BinArray1;

%%-----------------------create the panel----------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.7020 0.77 0.85];
end
if isempty(ColorB_def)
    ColorB_def = [0.7020 0.77 0.85];
end

Position = handles.erptabwaveiwer.OuterPosition;
chanOverlay = handles.radiobutton_chanoverlay.Value;

if chanOverlay==0
    rowNums=numel(ChanArray);
else
    rowNums=1;
end


FigureName= figure( 'Name',[ERP.erpname] , ...
    'NumberTitle', 'off','Color',[1 1 1]);
FigureName.Position(3:4) = Position(3:4);
FigureName.Position(1:2) = [0 0];
erptabwaveiwer_legend = subplot(ceil(rowNums*5)+1, 1, 1,'align');

hbig = subplot(ceil(rowNums*5)+1,1,[2:ceil(rowNums*5)+1]);
hold(hbig,'on');
set(erptabwaveiwer_legend, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none','box','off');


timeStart =handles.timeStart;
timEnd =handles.timEnd;
if isempty(timeStart)|| numel(timeStart)~=1 || timeStart>=ERP.times(end)
    timeStart=ERP.times(1);
    timEnd = ERP.times(end);
    handles.timeStart=timeStart;
    handles.timEnd=timEnd;
end
if isempty(timEnd)|| numel(timEnd)~=1 || timEnd<=ERP.times(1)
    timeStart=ERP.times(1);
    timEnd = ERP.times(end);
    handles.timeStart=timeStart;
    handles.timEnd=timEnd;
end
handles.edit1_time_range.String = num2str([timeStart,timEnd]);

xtickstep=handles.xtickstep;
[~, chanLabels, ~, ~, ~] = readlocs(ERP.chanlocs);
Yscale = handles.Yscale;
bindata = ERP.bindata(ChanArray,:,BinArray);
y_scale_def = [1.1*min(bindata(:)),1.1*max(bindata(:))];
if isempty(Yscale) || numel(Yscale)~=2
    Yscale= y_scale_def;
    handles.Yscale=Yscale;
end
handles.edit2_yrange.String = num2str(Yscale);

Min_vspacing = handles.Min_vspacing;
Fillscreen = handles.Fillscreen;
positive_up = handles.positive_up;
moption= handles.moption;
latency= handles.latency;
Min_time = ERP.times(1);
Max_time = ERP.times(end);
blc = handles.blc;
intfactor =  handles.intfactor;
Resolution =handles.Resolution;
BinchanOverlay = 0;
columNum=1;

handles.GridposArray = zeros(rowNums,columNum);
for ii = 1:rowNums
    handles.GridposArray(ii,1) =   ChanArray(ii);
end
GridposArray = handles.GridposArray;

%%----------------------measurement name-----------------------------------
offset = f_plotaberpwave(ALLERP,ERPArray,ERP,ChanArray,BinArray,timeStart,timEnd,xtickstep,Yscale,columNum,...
    positive_up,chanOverlay,rowNums,GridposArray,hbig,erptabwaveiwer_legend);

splot_n = numel(ChanArray);

ndata = BinArray;
pnts    = ERP.pnts;
timeor  = ERP.times; % original time vector
p1      = timeor(1);
p2      = timeor(end);
if intfactor~=1
    timex = linspace(p1,p2,round(pnts*intfactor));
else
    timex = timeor;
end
[xxx, latsamp, latdiffms] = closest(timex, [Min_time Max_time]);
tmin = latsamp(1);
tmax = latsamp(2);
if tmin < 1
    tmin = 1;
end
if tmax > numel(timex)
    tmax = numel(timex);
end
Plot_erp_data_TRAN = [];
for Numofsub = 1:numel(ERPArray)
    ERP1 = ALLERP(ERPArray(Numofsub));
    if intfactor~=1
        for Numoftwo = 1:size(ERP1.bindata,3)
            for Numofone = 1:size(ERP1.bindata,1)
                data = squeeze(ERP1.bindata(Numofone,:,Numoftwo));
                data  = spline(timeor, data, timex); % re-sampled data
                blv    = blvalue2(data, timex, blc);
                data   = data - blv;
                Plot_erp_data_TRAN(Numofone,:,Numoftwo) = data;
            end
        end
        Bindata(:,:,:,Numofsub) = Plot_erp_data_TRAN;
    else
        Bindata(:,:,:,Numofsub) = ERP1.bindata;
    end
end

plot_erp_data = nan(splot_n,tmax-tmin+1,numel(ndata));
for Numofsub = 1:numel(ERPArray)
    for i = 1:splot_n
        for i_bin = 1:numel(ndata)
            plot_erp_data(i,:,i_bin,Numofsub) = Bindata(ChanArray(i),tmin:tmax,BinArray(i_bin),Numofsub)'*positive_up; %
        end
    end
end

[Numchan,Numsamp,Numbin,Numerp] = size(plot_erp_data);
if chanOverlay==1
    plot_erp_data11 = [];
    count = 0;
    for Numoferp = 1:Numerp
        for Numofchan = 1: Numchan
            for Numofbin = 1:Numbin
                count = count+1;
                plot_erp_data11(1,:,count) = squeeze(plot_erp_data(Numofchan,:,Numofbin,Numoferp));
            end
        end
    end
    plot_erp_data = plot_erp_data11;
else
    plot_erp_data11 = [];
    count = 0;
    for Numoferp = 1:Numerp
        for Numofbin = 1:Numbin
            count = count+1;
            plot_erp_data11(:,:,count) = squeeze(plot_erp_data(:,:,Numofbin,Numoferp));
        end
    end
    plot_erp_data = plot_erp_data11;
end

[~,~,Num_plot] = size(plot_erp_data);
line_colors = get_colors(Num_plot);

if chanOverlay==1
    offset = zeros(size(plot_erp_data,3),1);
end

for i = 1:size(plot_erp_data,1)
    plot_erp_data(i,:,:) = plot_erp_data(i,:,:) + ones(size(plot_erp_data(i,:,:)))*offset(i);
end

%
%%%Mark the area/latency/amplitude of interest within the defined window.
ERP_mark_area_latency(hbig,timex(tmin:tmax),moption,plot_erp_data,latency,line_colors,offset,...
    positive_up,ERP,ChanArray,BinArray,Yscale,ALLERP,ERPArray,chanOverlay);%cwm = [0 0 0];% white: Background color for measurement window



function colors = get_colors(ncolors)
% Each color gets 1 point divided into up to 2 of 3 groups (RGB).
degree_step = 6/ncolors;
angles = (0:ncolors-1)*degree_step;
colors = nan(numel(angles),3);
for i = 1:numel(angles)
    if angles(i) < 1
        colors(i,:) = [1 (angles(i)-floor(angles(i))) 0]*0.75;
    elseif angles(i) < 2
        colors(i,:) = [(1-(angles(i)-floor(angles(i)))) 1 0]*0.75;
    elseif angles(i) < 3
        colors(i,:) = [0 1 (angles(i)-floor(angles(i)))]*0.75;
    elseif angles(i) < 4
        colors(i,:) = [0 (1-(angles(i)-floor(angles(i)))) 1]*0.75;
    elseif angles(i) < 5
        colors(i,:) = [(angles(i)-floor(angles(i))) 0 1]*0.75;
    else
        colors(i,:) = [1 0 (1-(angles(i)-floor(angles(i))))]*0.75;
    end
end




function ERP_mark_area_latency(r_ax,timex,moption,plot_erp_data,latency,line_colors,offset,...
    positive_up,ERP,ChanArray,BinArray,Yscale,ALLERP,ERPArray,chanOverlay)

cwm_backgb=[0.7 0.7 0.7];
cwm  =[0 0 0];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot area within the defined time-window%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set area within the defined time-window for 1.Fractional area latency, 2. Numerical integration/Area between two fixed latencies
mearea    = { 'areat', 'areap', 'arean','areazt','areazp','areazn', 'ninteg','nintegz'};
plot_erp_data = permute(plot_erp_data,[2 1 3]);
[~,Num_data,Num_plot] = size(plot_erp_data);

if ismember_bc2(moption, mearea)  || ismember_bc2(moption, {'fareatlat', 'fareaplat','fninteglat','fareanlat'})
    if numel(latency) ==2
        latx = latency;
        [xxx, latsamp] = closest(timex, latx);
        datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
        datax = permute(datax,[1 3 2]);
    end
    
    Time_res = timex(2)-timex(1);
    
    if ismember_bc2(moption, {'areap', 'fareaplat'}) % positive area
        
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexx = timex(latsamp(1):latsamp(2));
                dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                data_check  = dataxx-offset(Numofstione);
                if positive_up==1
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                elseif positive_up ==-1
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                else
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                end
                
                if ~isempty(dataxx) && numel(dataxx)>=2
                    %%Check isolated point
                    Check_outlier =[];
                    count = 0;
                    
                    if (timexx(2)-timexx(1)>Time_res)
                        count= count +1;
                        Check_outlier(count) = 1;
                    end
                    if numel(dataxx)>=3
                        for Numofsample = 2:length(timexx)-1
                            if (timexx(Numofsample+1)-timexx(Numofsample)>Time_res) &&  (timexx(Numofsample)-timexx(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outlier(count) = Numofsample;
                            end
                        end
                    end
                    dataxx(Check_outlier) = [];
                    timexx(Check_outlier) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexx)-1
                        if timexx(Numofsample+1)-timexx(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        inBetweenRegionX2 = [timexx(Check_isolated(1)+1:end),fliplr(timexx(Check_isolated(1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            inBetweenRegionX = [timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        end
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        inBetweenRegionX2 = [timexx(Check_isolated(Numofrange+1)+1:end),fliplr(timexx(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    else
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end
                
            end
            
        end
        
    elseif ismember_bc2(moption, {'arean', 'fareanlat'}) % negative area
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexx = timex(latsamp(1):latsamp(2));
                dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                data_check  = dataxx-offset(Numofstione);
                if positive_up==1
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                elseif positive_up ==-1
                    dataxx(data_check<0) = [];
                    timexx(data_check<0) = [];
                else
                    dataxx(data_check>0) = [];
                    timexx(data_check>0) = [];
                end
                
                %%Check isolated point
                if ~isempty(dataxx) && numel(dataxx)>=2
                    Check_outlier =[];
                    count = 0;
                    
                    if (timexx(2)-timexx(1)>Time_res)
                        count= count +1;
                        Check_outlier(count) = 1;
                    end
                    if numel(dataxx)>=3
                        for Numofsample = 2:length(timexx)-1
                            if (timexx(Numofsample+1)-timexx(Numofsample)>Time_res) &&  (timexx(Numofsample)-timexx(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outlier(count) = Numofsample;
                            end
                        end
                    end
                    dataxx(Check_outlier) = [];
                    timexx(Check_outlier) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexx)-1
                        if timexx(Numofsample+1)-timexx(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexx(Check_isolated(1)+1:end),fliplr(timexx(Check_isolated(1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            inBetweenRegionX = [timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        end
                        inBetweenRegionX1 = [timexx(1:Check_isolated(1)),fliplr(timexx(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxx(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexx(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexx(Check_isolated(Numofrange+1)+1:end),fliplr(timexx(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxx(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexx(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                    else
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end
            end
        end
        
    elseif ismember_bc2(moption, {'ninteg', 'fninteglat'}) % integration(area for negative substracted from area for positive)
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexxp = timex(latsamp(1):latsamp(2));
                dataxxp = squeeze(datax(:,Numofstitwo,Numofstione));
                timexxn = timex(latsamp(1):latsamp(2));
                dataxxn = squeeze(datax(:,Numofstitwo,Numofstione));
                data_check  = dataxxn-offset(Numofstione);
                if positive_up==1
                    dataxxp(data_check<0) = [];
                    timexxp(data_check<0) = [];
                    dataxxn(data_check>0) = [];
                    timexxn(data_check>0) = [];
                elseif positive_up ==-1
                    dataxxp(data_check>0) = [];
                    timexxp(data_check>0) = [];
                    dataxxn(data_check<0) = [];
                    timexxn(data_check<0) = [];
                else
                    dataxxp(data_check<0) = [];
                    timexxp(data_check<0) = [];
                    dataxxn(data_check>0) = [];
                    timexxn(data_check>0) = [];
                end
                
                if ~isempty(dataxxp) && numel(dataxxp)>=2
                    %%Check isolated point
                    Check_outlierp =[];
                    count = 0;
                    
                    if (timexxp(2)-timexxp(1)>Time_res)
                        count= count +1;
                        Check_outlierp(count) = 1;
                    end
                    if numel(dataxxp)>=3
                        for Numofsample = 2:length(timexxp)-1
                            if (timexxp(Numofsample+1)-timexxp(Numofsample)>Time_res) &&  (timexxp(Numofsample)-timexxp(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outlierp(count) = Numofsample;
                            end
                        end
                    end
                    dataxxp(Check_outlierp) = [];
                    timexxp(Check_outlierp) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexxp)-1
                        if timexxp(Numofsample+1)-timexxp(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionXp1 = [timexxp(1:Check_isolated(1)),fliplr(timexxp(1:Check_isolated(1)))];
                        inBetweenRegionYp1 = [squeeze(dataxxp(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionXp1, inBetweenRegionYp1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionXp2 = [timexxp(Check_isolated(1)+1:end),fliplr(timexxp(Check_isolated(1)+1:end))];
                        inBetweenRegionYp2 = [squeeze(dataxxp(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionXp2, inBetweenRegionYp2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            inBetweenRegionX = [timexxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        end
                        inBetweenRegionX1 = [timexxp(1:Check_isolated(1)),fliplr(timexxp(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxxp(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexxp(Check_isolated(Numofrange+1)+1:end),fliplr(timexxp(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxxp(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxp(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                    else
                        inBetweenRegionX = [timexxp,fliplr(timexxp)];
                        inBetweenRegionY = [squeeze(dataxxp)',fliplr(offset(Numofstione)*ones(1,numel(timexxp)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end%Positive part end
                
                if ~isempty(dataxxn) && numel(dataxxn)>=2
                    %%Check isolated point
                    Check_outliern =[];
                    count = 0;
                    
                    if (timexxn(2)-timexxn(1)>Time_res)
                        count= count +1;
                        Check_outliern(count) = 1;
                    end
                    if numel(dataxxn)>=3
                        for Numofsample = 2:length(timexxn)-1
                            if (timexxn(Numofsample+1)-timexxn(Numofsample)>Time_res) &&  (timexxn(Numofsample)-timexxn(Numofsample-1)< Time_res)
                                count = count+1;
                                Check_outliern(count) = Numofsample;
                            end
                        end
                    end
                    dataxxn(Check_outliern) = [];
                    timexxn(Check_outliern) = [];
                    
                    Check_isolated =[];
                    count = 0;
                    for Numofsample = 1:length(timexxn)-1
                        if timexxn(Numofsample+1)-timexxn(Numofsample)>Time_res
                            count = count+1;
                            Check_isolated(count) = Numofsample;
                        end
                    end
                    if numel(Check_isolated) ==1
                        inBetweenRegionXp1 = [timexxn(1:Check_isolated(1)),fliplr(timexxn(1:Check_isolated(1)))];
                        inBetweenRegionYp1 = [squeeze(dataxxn(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionXp1, inBetweenRegionYp1,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionXp2 = [timexxn(Check_isolated(1)+1:end),fliplr(timexxn(Check_isolated(1)+1:end))];
                        inBetweenRegionYp2 = [squeeze(dataxxn(Check_isolated(1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(Check_isolated(1)+1:end))))];
                        fill(r_ax,inBetweenRegionXp2, inBetweenRegionYp2,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    elseif numel(Check_isolated) >1
                        for Numofrange = 1:numel(Check_isolated)-1
                            
                            inBetweenRegionX = [timexxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)),fliplr(timexxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))];
                            inBetweenRegionY = [squeeze(dataxxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(Check_isolated(Numofrange)+1:Check_isolated(Numofrange+1)))))];
                            fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                            
                        end
                        inBetweenRegionX1 = [timexxn(1:Check_isolated(1)),fliplr(timexxn(1:Check_isolated(1)))];
                        inBetweenRegionY1 = [squeeze(dataxxn(1:Check_isolated(1)))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(1:Check_isolated(1)))))];
                        fill(r_ax,inBetweenRegionX1, inBetweenRegionY1,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                        
                        inBetweenRegionX2 = [timexxn(Check_isolated(Numofrange+1)+1:end),fliplr(timexxn(Check_isolated(Numofrange+1)+1:end))];
                        inBetweenRegionY2 = [squeeze(dataxxn(Check_isolated(Numofrange+1)+1:end))',fliplr(offset(Numofstione)*ones(1,numel(timexxn(Check_isolated(Numofrange+1)+1:end))))];
                        fill(r_ax,inBetweenRegionX2, inBetweenRegionY2,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    else
                        inBetweenRegionX = [timexxn,fliplr(timexxn)];
                        inBetweenRegionY = [squeeze(dataxxn)',fliplr(offset(Numofstione)*ones(1,numel(timexxn)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:).*0.3,'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
                    end
                end%%Negative part end
            end
        end
        
    elseif ismember_bc2(moption, {'areat', 'fareatlat'})%  negative values become positive
        for Numofstione = 1:size(datax,3)
            for Numofstitwo = 1:size(datax,2)
                timexx = timex(latsamp(1):latsamp(2));
                dataxx = squeeze(datax(:,Numofstitwo,Numofstione));
                inBetweenRegionX = [timexx,fliplr(timexx)];
                inBetweenRegionY = [squeeze(dataxx)',fliplr(offset(Numofstione)*ones(1,numel(timexx)))];
                fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(Numofstitwo,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(Numofstitwo,:,:));
            end
        end
        
    elseif ismember_bc2(moption,  {'areazt','areazp','areazn', 'nintegz'})
        if chanOverlay==1
            offset = zeros(numel(ChanArray),1);
        end
        countcolor=0;
        for Numoferp = 1:numel(ERPArray)
            ERP1 = ALLERP(ERPArray(Numoferp));
            bindata = ERP1.bindata(ChanArray,:,BinArray);
            [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(ERP1,offset,ChanArray,BinArray);
            
            if strcmp(moption,'areazt')%% all area were included
                for Numofbin = 1:numel(BinArray)
                    if chanOverlay==0
                        countcolor = countcolor+1;
                    end
                    for Numofchan = 1:numel(ChanArray)
                        if chanOverlay==1
                            countcolor = countcolor+1;
                        end
                        latx = Lat{Numofbin,Numofchan};
                        [xxx, latsamp] = closest(timex, latx);
                        
                        timexx = timex(latsamp(1):latsamp(2));
                        dataxx = squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx),fliplr(offset(Numofchan)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(countcolor,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                    end
                end
                
            elseif strcmp(moption,'areazp')%% Only positive area was included
                for Numofbin = 1:numel(BinArray)
                    if chanOverlay==0
                        countcolor = countcolor+1;
                    end
                    for Numofchan = 1:numel(ChanArray)
                        if chanOverlay==1
                            countcolor = countcolor+1;
                        end
                        
                        latx = Lat{Numofbin,Numofchan};
                        [xxx, latsamp] = closest(timex, latx);
                        datax = plot_erp_data(latsamp(1):latsamp(2),:,:);
                        timexx = timex(latsamp(1):latsamp(2));
                        timexx_unsl = timex(latsamp(1):latsamp(2));
                        dataxx = squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        data_check_unsl = squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        data_check  = dataxx -offset(Numofchan);
                        if positive_up==1
                            dataxx(data_check<0) = [];
                            timexx(data_check<0) = [];
                            data_check_unsl(data_check>0) =[];
                            timexx_unsl(data_check>0) = [];
                        elseif positive_up ==-1
                            dataxx(data_check>0) = [];
                            timexx(data_check>0) = [];
                            data_check_unsl(data_check<0) =[];
                            timexx_unsl(data_check<0) = [];
                        else
                            dataxx(data_check<0) = [];
                            timexx(data_check<0) = [];
                            data_check_unsl(data_check>0) =[];
                            timexx_unsl(data_check>0) = [];
                        end
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx),fliplr(offset(Numofchan)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(countcolor,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                        inBetweenRegionX_unsl = [timexx_unsl,fliplr(timexx_unsl)];
                        inBetweenRegionY_unsl = [squeeze(data_check_unsl),fliplr(offset(Numofchan)*ones(1,numel(timexx_unsl)))];
                        fill(r_ax,inBetweenRegionX_unsl, inBetweenRegionY_unsl,[1 1 1],'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                    end
                end
                
            elseif strcmp(moption,'areazn')%% Only positive area was included
                for Numofbin = 1:numel(BinArray)
                    if chanOverlay==0
                        countcolor = countcolor+1;
                    end
                    for Numofchan = 1:numel(ChanArray)
                        if chanOverlay==1
                            countcolor = countcolor+1;
                        end
                        
                        latx = Lat{Numofbin,Numofchan};
                        [xxx, latsamp] = closest(timex, latx);
                        timexx = timex(latsamp(1):latsamp(2));
                        timexx_unsl = timex(latsamp(1):latsamp(2));
                        dataxx = squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        data_check_unsl = squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        data_check  = dataxx -offset(Numofchan);
                        if positive_up==1
                            dataxx(data_check>0) = [];
                            timexx(data_check>0) = [];
                            data_check_unsl(data_check<0) =[];
                            timexx_unsl(data_check<0) = [];
                        elseif positive_up ==-1
                            dataxx(data_check<0) = [];
                            timexx(data_check<0) = [];
                            data_check_unsl(data_check>0) =[];
                            timexx_unsl(data_check>0) = [];
                        else
                            dataxx(data_check>0) = [];
                            timexx(data_check>0) = [];
                            data_check_unsl(data_check<0) =[];
                            timexx_unsl(data_check<0) = [];
                        end
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx),fliplr(offset(Numofchan)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(countcolor,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                        inBetweenRegionX_unsl = [timexx_unsl,fliplr(timexx_unsl)];
                        inBetweenRegionY_unsl = [squeeze(data_check_unsl),fliplr(offset(Numofchan)*ones(1,numel(timexx_unsl)))];
                        fill(r_ax,inBetweenRegionX_unsl, inBetweenRegionY_unsl,[1 1 1],'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                    end
                end
                
            elseif strcmp(moption,'nintegz')%% Only positive area was included
                for Numofbin = 1:numel(BinArray)
                    if chanOverlay==0
                        countcolor = countcolor+1;
                    end
                    for Numofchan = 1:numel(ChanArray)
                        if chanOverlay==1
                            countcolor = countcolor+1;
                        end
                        
                        latx = Lat{Numofbin,Numofchan};
                        [xxx, latsamp] = closest(timex, latx);
                        timexx = timex(latsamp(1):latsamp(2));
                        timexx_unsl = timex(latsamp(1):latsamp(2));
                        dataxx =  squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        data_check_unsl =  squeeze(bindata(Numofchan,latsamp(1):latsamp(2),Numofbin))+offset(Numofchan);
                        data_check  = dataxx -offset(Numofchan);
                        if positive_up==1
                            dataxx(data_check<0) = [];
                            timexx(data_check<0) = [];
                            data_check_unsl(data_check>0) =[];
                            timexx_unsl(data_check>0) = [];
                        elseif positive_up ==-1
                            dataxx(data_check>0) = [];
                            timexx(data_check>0) = [];
                            data_check_unsl(data_check<0) =[];
                            timexx_unsl(data_check<0) = [];
                        else
                            dataxx(data_check<0) = [];
                            timexx(data_check<0) = [];
                            data_check_unsl(data_check>0) =[];
                            timexx_unsl(data_check>0) = [];
                        end
                        inBetweenRegionX = [timexx,fliplr(timexx)];
                        inBetweenRegionY = [squeeze(dataxx),fliplr(offset(Numofchan)*ones(1,numel(timexx)))];
                        fill(r_ax,inBetweenRegionX, inBetweenRegionY,line_colors(countcolor,:,:),'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                        inBetweenRegionX_unsl = [timexx_unsl,fliplr(timexx_unsl)];%
                        inBetweenRegionY_unsl = [squeeze(data_check_unsl),fliplr(offset(Numofchan)*ones(1,numel(timexx_unsl)))];
                        fill(r_ax,inBetweenRegionX_unsl, inBetweenRegionY_unsl,line_colors(countcolor,:,:)*0.5,'FaceAlpha',0.3,'EdgeColor',line_colors(countcolor,:,:));
                    end
                end
            end
        end%%loop for erpsets
        
    end
end

% return;

if length(latency)==1
    if ismember_bc2(moption,  {'areazt','areazp','areazn', 'nintegz'})%% Four options for Numerical integration/Area between two (automatically detected)zero-crossing latencies
        xline(r_ax,latency, 'Color', cwm,'LineWidth' ,1);
    else
        xline(r_ax,latency, 'Color', cwm,'LineWidth' ,1);
    end
    if  ismember_bc2(moption, 'instabl')
        count111 = 0;
        for Numoferp = 1:numel( ERPArray)
            ERP1 = ALLERP(ERPArray(Numoferp));
            if chanOverlay==1
                offset = zeros(numel(ChanArray),1);
            end
            [new_erp_data, Amp_out,Lat]= f_ERP_plot_wav(ERP1,offset,ChanArray,BinArray);
            for Numofstitwo = 1:size(Amp_out,1)
                count111 = count111+1;
                for Numofstione = 1:size(Amp_out,2)
                    plot(r_ax,latency,squeeze(Amp_out(Numofstitwo,Numofstione)),'Color',line_colors(count111,:,:),'LineWidth' ,1);
                end
            end
        end
    end
elseif length(latency)==2
    countcolor = 0;
    line_colors1 = [];
    if chanOverlay==1
        offset = zeros(numel(ChanArray),1);
    end
    
    Max_values = 1.1*max([max(plot_erp_data(:)),Yscale(2)]);
    Min_values = 1.1*min([min((plot_erp_data(:))),Yscale(1)]);
    plot_area_up = area(r_ax,[latency latency(2) latency(1)],[Min_values,Max_values Min_values,Max_values]);
    plot_area_low = area(r_ax,[latency latency(2) latency(1)],[0,Min_values 0,Min_values]);
    set(plot_area_up,'FaceAlpha',0.2, 'EdgeAlpha', 0.1, 'EdgeColor', cwm,'FaceColor',cwm_backgb);
    set(plot_area_low,'FaceAlpha',0.2, 'EdgeAlpha', 0.1, 'EdgeColor', cwm,'FaceColor',cwm_backgb);
    
    for Numoferp = 1:numel(ERPArray)
        ERP1 = ALLERP(ERPArray(Numoferp));
        bindata = ERP1.bindata(ChanArray,:,BinArray);
        [~, Amp_out,Lat]= f_ERP_plot_wav(ERP1,offset,ChanArray,BinArray);
        %         Amp_out = Amp_out*positive_up;
        if ismember_bc2(moption, {'peakampbl'})%Local Peak amplitude
            for Numofbin = 1:numel(BinArray)
                if chanOverlay==0
                    countcolor = countcolor+1;
                end
                for Numofchan = 1:numel(ChanArray)
                    if chanOverlay==1
                        countcolor = countcolor+1;
                    end
                    Amp_all = squeeze(bindata(Numofchan,:,Numofbin))*positive_up +offset(Numofchan);
                    [xxx, latsamp, latdiffms] = closest(timex, Lat{Numofbin,Numofchan});
                    if ~isnan(Lat{Numofbin,Numofchan})
                        line(r_ax, [Lat{Numofbin,Numofchan} Lat{Numofbin,Numofchan}],[offset(Numofchan),Amp_all(latsamp)],'Color',line_colors(countcolor,:,:),'LineWidth',1,'LineStyle','-.');
                    end
                end
            end
        elseif ismember_bc2(moption, { 'fareatlat', 'fareaplat','fninteglat','fareanlat'})%fractional area latency
            for Numofbin = 1:numel(BinArray)
                if chanOverlay==0
                    countcolor = countcolor+1;
                end
                for Numofchan = 1:numel(ChanArray)
                    if chanOverlay==1
                        countcolor = countcolor+1;
                    end
                    Amp_all = squeeze(bindata(Numofchan,:,Numofbin))*positive_up +offset(Numofchan);
                    if ~isnan(Amp_out(Numofbin,Numofchan))
                        [xxx, latsamp, latdiffms] = closest(timex, Amp_out(Numofbin,Numofchan));
                        line(r_ax, [Amp_out(Numofbin,Numofchan) Amp_out(Numofbin,Numofchan)],sort([offset(Numofchan),Amp_all(latsamp)]),'Color',line_colors(countcolor,:,:),'LineWidth',1,'LineStyle','-.');
                    end
                end
            end
            
        elseif ismember_bc2(moption,  {'peaklatbl','fpeaklat'}) % fractional peak latency && Local peak latency
            for Numofbin = 1:numel(BinArray)
                if chanOverlay==0
                    countcolor = countcolor+1;
                end
                for Numofchan = 1:numel(ChanArray)
                    if chanOverlay==1
                        countcolor = countcolor+1;
                    end
                    Amp_all = squeeze(bindata(Numofchan,:,Numofbin))*positive_up +offset(Numofchan);
                    if ~isnan(Amp_out(Numofbin,Numofchan))
                        if ismember_bc2(moption,  {'fpeaklat'})
                            [xxx, latsamp, latdiffms] = closest(timex,Lat{Numofbin,Numofchan});
                            line(r_ax, [Lat{Numofbin,Numofchan} Lat{Numofbin,Numofchan}],sort([offset(Numofchan),Amp_all(latsamp)]),'Color',line_colors(countcolor,:,:),'LineWidth',1,'LineStyle','-.');
                        elseif ismember_bc2(moption,  {'peaklatbl'})
                            [xxx, latsamp, latdiffms] = closest(timex,Amp_out(Numofbin,Numofchan));
                            line(r_ax, [Amp_out(Numofbin,Numofchan) Amp_out(Numofbin,Numofchan)],sort([offset(Numofchan),Amp_all(latsamp)]),'Color',line_colors(countcolor,:,:),'LineWidth',1,'LineStyle','-.');
                        end
                        
                    end
                end
            end
            
        end
    end
    
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton_parbin.
function radiobutton_parbin_Callback(hObject, eventdata, handles)
handles.checkbox1_bin.Value=0;
handles.radiobutton_parbin.Value=1;
handles.pushbutton_binsmall.Enable = 'on';
handles.pushbutton_binlarge.Enable = 'on';
handles.edit_bin.Enable = 'on';
handles.pushbutton_browse_bin.Enable = 'on';

ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end

BinArray = str2num(handles.edit_bin.String);
if isempty(BinArray) || any(BinArray>ERP.nbin)
    BinArray = handles.BinArray;
end

handles.pushbutton_binsmall.Enable = 'on';
handles.pushbutton_binlarge.Enable = 'on';
handles.edit_bin.String = num2str(BinArray(1));

handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);



% --- Executes on button press in pushbutton_browse_bin.
function pushbutton_browse_bin_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
BinArray = handles.BinArray;
BinArray =reshape(BinArray,1,numel(BinArray));


BinArray_edit = str2num(handles.edit_bin.String);
if isempty(BinArray_edit) || any(BinArray_edit>numel(BinArray))
    BinArray_edit = BinArray(1);
end

for Numofbin = 1:numel(BinArray)
    listname{Numofbin} = [num2str(BinArray(Numofbin)),'.',ERP.bindescr{BinArray(Numofbin)}];
end

BinArray = handles.BinArray;
BinArray =reshape(BinArray,1,numel(BinArray));
[~,binpos] = find(BinArray ==BinArray_edit);
if isempty(binpos)
    BinArray_edit = BinArray(1);
    binpos = 1;
    handles.edit_bin.String = num2str(BinArray_edit);
end

indxlistb  =binpos;
titlename = 'Select one bin:';
bin_select = browsechanbinGUI(listname, indxlistb, titlename);
if isempty(bin_select)
    return;
end

handles.edit_bin.String = num2str(BinArray(bin_select(1)));
handles.pushbutton_binsmall.Enable = 'on';
handles.pushbutton_binlarge.Enable = 'on';


handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton_chanpor.
function radiobutton_chanpor_Callback(hObject, eventdata, handles)

handles.radiobutton_chanpor.Value=1;
handles.checkbox_chan.Value=0;
handles.pushbutton8_chansmall.Enable = 'on';
handles.pushbutton_chanlarge.Enable = 'on';
handles.pushbutton_chanborwse.Enable = 'on';
handles.edit_chans.Enable = 'on';


ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
chan_select = str2num(handles.edit_chans.String);
if isempty(chan_select) || any(chan_select>ERP.nchan)
    chan_select = handles.ChanArray(1);
end

handles.edit_chans.String = num2str(chan_select(1));
handles.radiobutton_chanoverlay.Value = 0;
handles.radiobutton_chan_separate.Value = 1;
handles.radiobutton_chanoverlay.Enable = 'off';
handles.radiobutton_chan_separate.Enable = 'off';
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_chanborwse.
function pushbutton_chanborwse_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
try
    ERP = ALLERP(handles.CurrentERP);
catch
    ERP=[];
end
if isempty(ALLERP) || isempty(ERP)
    return;
end
ChanArray = handles.ChanArray;
ChanArray =reshape(ChanArray,1,numel(ChanArray));
chanArray_edit = str2num(handles.edit_chans.String);
if isempty(chanArray_edit) || any(chanArray_edit>numel(ChanArray))
    chanArray_edit = ChanArray(1);
end

for Numofchan = 1:numel(ChanArray)
    listname{Numofchan} = [num2str(ChanArray(Numofchan)),'.',ERP.chanlocs(ChanArray(Numofchan)).labels];
end


[~,chanpos] = find(ChanArray ==chanArray_edit);
if isempty(chanpos)
    chanArray_edit = ChanArray(1);
    chanpos = 1;
    handles.edit_chans.String = num2str(ChanArray(1));
end

indxlistb  =chanpos;

titlename = 'Select one chan:';
chan_select = browsechanbinGUI(listname, indxlistb, titlename);
if isempty(chan_select)
    return;
end

handles.edit_chans.String = num2str(ChanArray(chan_select(1)));
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);





% --- Executes on button press in radiobutton_chanoverlay.
function radiobutton_chanoverlay_Callback(hObject, eventdata, handles)
handles.radiobutton_chanoverlay.Value = 1;
handles.radiobutton_chan_separate.Value = 0;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in radiobutton_chan_separate.
function radiobutton_chan_separate_Callback(hObject, eventdata, handles)
handles.radiobutton_chanoverlay.Value = 0;
handles.radiobutton_chan_separate.Value = 1;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton_erpset_browse.
function pushbutton_erpset_browse_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end
ERPArray = str2num(handles.edit5_erpset.String);
if isempty(ERPArray) || any(ERPArray(:)>length(ALLERP))
    ERPArray = length(ALLERP);
end
for Numoferp = 1:length(ALLERP)
    listname{Numoferp} = ['ERPset:',32,num2str(Numoferp)];
end

indxlistb  =ERPArray;
titlename = 'Select one erpset:';
erpset_select = browsechanbinGUI(listname, indxlistb, titlename);
if isempty(erpset_select)
    return;
end

ERPArray = erpset_select(1);
handles.edit5_erpset.String = num2str(ERPArray);
handles.CurrentERP = ERPArray;

handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton_erppor.
function radiobutton_erppor_Callback(hObject, eventdata, handles)
handles.checkbox_erp.Value=0;
handles.radiobutton_erppor.Value=1;
handles.checkbox_erp.Enable = 'on';
handles.edit5_erpset.Enable = 'on';
handles.pushbutton_erpsetsmall.Enable = 'on';
handles.pushbutton_erpsetlarge.Enable = 'on';
handles.pushbutton_erpset_browse.Enable = 'on';
ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end

ERPArray = str2num(handles.edit5_erpset.String);
if isempty(ERPArray) || any(ERPArray(:)>length(ALLERP))
    ERPArray=1;
end

handles.edit5_erpset.String = num2str(ERPArray(1));
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


function pushbutton_polarity_up_DeleteFcn(hObject, eventdata, handles)

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end

handles.positive_up=-1;
handles.radiobutton7.Value=0;
handles.radiobutton6.Value=1;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
ALLERP = handles.ALLERP;
if isempty(ALLERP)
    return;
end

handles.positive_up=1;
handles.radiobutton7.Value=1;
handles.radiobutton6.Value=0;
handles= plot_wave_viewer(hObject,handles);
guidata(hObject, handles);
