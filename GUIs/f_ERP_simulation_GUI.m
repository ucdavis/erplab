function varargout = f_ERP_simulation_GUI(varargin)
% F_ERP_SIMULATION_GUI MATLAB code for f_ERP_simulation_GUI.fig
%      F_ERP_SIMULATION_GUI, by itself, creates a new F_ERP_SIMULATION_GUI or raises the existing
%      singleton*.
%
%      H = F_ERP_SIMULATION_GUI returns the handle to a new F_ERP_SIMULATION_GUI or the handle to
%      the existing singleton*.
%
%      F_ERP_SIMULATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_ERP_SIMULATION_GUI.M with the given input arguments.
%
%      F_ERP_SIMULATION_GUI('Property','Value',...) creates a new F_ERP_SIMULATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f_ERP_simulation_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f_ERP_simulation_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f_ERP_simulation_GUI

% Last Modified by GUIDE v2.5 26-Mar-2023 21:17:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f_ERP_simulation_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @f_ERP_simulation_GUI_OutputFcn, ...
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


% --- Executes just before f_ERP_simulation_GUI is made visible.
function f_ERP_simulation_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for f_ERP_simulation_GUI

try
    def  = varargin{1};
catch
    def  = {1,1,100,50,1000,-200,799,1,1000,0,1,0,1,0,1,10,0};
    %%Basic option, amp, mean, SD, Tau, epoch start, epoch
    %%stop, sample rate option, srate value, whitenoiseop,
    %%ampwhite, pinkop,amppink,sinop,sinamp,sinfre,random number generator
end
if isempty(def)
    def  = {1,1,100,50,1000,-200,799,1,1000,0,1,0,1,0,1,10,0};
end

try
    ALLERP = varargin{2};
catch
    ALLERP = [];
end

try
    CURRENTERP = varargin{3};
catch
    CURRENTERP = [];
end


try
    ChanArray  = varargin{4};
catch
    ChanArray = [];
end

try
    BinArray = varargin{5};
catch
    BinArray = [];
end


% handles.erpnameor = erpname;
handles.output = [];
handles.ALLERP = ALLERP;
handles.CURRENTERP = CURRENTERP;
handles.ChanArray = ChanArray;
handles.BinArray = BinArray;

% erpmenu  = findobj('tag', 'erpsets');

% if ~isempty(erpmenu)
%     handles.menuerp = get(erpmenu);
%     set(handles.menuerp.Children, 'Enable','off');
% end

erplab_studio_default_values;
version = geterplabversion;

set(handles.gui_chassis,'Name', ['ERPLAB', version, '   -   Create artificial ERP waveform GUI'])
% set(handles.edit_erpname, 'String', '_processed');

handles = painterplab(handles);

handles = setfonterplab(handles);

Bacfunc_Flag = def{1};
if Bacfunc_Flag ==2%%Select Impulse signal
    %%Exgaussian
    set(handles.radiobutton_exgaus,'Value',0);
    set(handles.radiobutton_exgaus,'Enable','on');
    set(handles.edit5_exgau_amp,'Enable','off');
    set(handles.edit_exgau_mean,'Enable','off');
    set(handles.edit_exgau_sd,'Enable','off');
    set(handles.edit8_exgua_tau,'Enable','off');
    
    %%Impulse
    set(handles.radiobutton_impulse,'Value',1);
    
    set(handles.edit_impulse_peak_amp,'Enable','on');
    Amp  =  def{2};
    if ~isnumeric(Amp) || numel(Amp)>1
        Amp = [];
    end
    set(handles.edit_impulse_peak_amp,'String',num2str(Amp));
    
    set(handles.edit_impulse_lat,'Enable','on');
    Lat_im = def{3};
    if ~isnumeric(Lat_im) || numel(Lat_im)>1
        Lat_im = [];
    end
    set(handles.edit_impulse_lat,'String',num2str(Lat_im));
    
    %%Square signal
    set(handles.radiobutton_square,'Value',0);
    set(handles.edit_square_peak_amp,'Enable','off');
    set(handles.edit_square_onset,'Enable','off');
    set(handles.edit_square_offset,'Enable','off');
elseif Bacfunc_Flag ==3%%select boxcar function
    
    set(handles.radiobutton_exgaus,'Value',0);
    set(handles.radiobutton_exgaus,'Enable','on');
    set(handles.edit5_exgau_amp,'Enable','off');
    set(handles.edit_exgau_mean,'Enable','off');
    set(handles.edit_exgau_sd,'Enable','off');
    set(handles.edit8_exgua_tau,'Enable','off');
    
    %%Impulse
    set(handles.radiobutton_impulse,'Value',0);
    set(handles.edit_impulse_peak_amp,'Enable','off');
    set(handles.edit_impulse_lat,'Enable','off');
    
    %%Square signal
    set(handles.radiobutton_square,'Value',1);
    Amp  =  def{2};
    if ~isnumeric(Amp) || numel(Amp)>1
        Amp = [];
    end
    set(handles.edit_square_peak_amp,'String',num2str(Amp));
    set(handles.edit_square_peak_amp,'Enable','on');
    set(handles.edit_square_onset,'Enable','on');
    
    Lat_onset  =  def{3};
    if ~isnumeric(Lat_onset) || numel(Lat_onset)>1
        Lat_onset = [];
    end
    set(handles.edit_square_onset,'String',num2str(Lat_onset));
    
    Lat_offset  =  def{4};
    if ~isnumeric(Lat_offset) || numel(Lat_offset)>1
        Lat_offset = [];
    end
    set(handles.edit_square_offset,'Enable','on');
    set(handles.edit_square_offset,'String',num2str(Lat_offset));
else
    %%Exgaussian
    set(handles.radiobutton_exgaus,'Value',1);
    set(handles.radiobutton_exgaus,'Enable','on');
    set(handles.edit5_exgau_amp,'Enable','on');
    set(handles.edit_exgau_mean,'Enable','on');
    set(handles.edit_exgau_sd,'Enable','on');
    set(handles.edit8_exgua_tau,'Enable','on');
    Amp = def{2};
    if ~isnumeric(Amp) || numel(Amp)>1
        Amp = [];
    end
    set(handles.edit5_exgau_amp,'String',num2str(Amp));
    
    Mean = def{3};
    if ~isnumeric(Mean) || numel(Mean)>1
        Mean = [];
    end
    set(handles.edit_exgau_mean,'String',num2str(Mean));
    
    Exg_SD = def{4};
    if ~isnumeric(Exg_SD) || numel(Exg_SD)>1
        Exg_SD = [];
    end
    set(handles.edit_exgau_sd,'String',num2str(Exg_SD));
    
    Exg_tau = def{5};
    if ~isnumeric(Exg_tau) || numel(Exg_tau)>1
        Exg_tau = [];
    end
    set(handles.edit8_exgua_tau,'String',num2str(Exg_tau));
    %%Impulse
    set(handles.radiobutton_impulse,'Value',0);
    set(handles.edit_impulse_peak_amp,'Enable','off');
    set(handles.edit_impulse_lat,'Enable','off');
    
    %%Square signal
    set(handles.radiobutton_square,'Value',0);
    set(handles.edit_square_peak_amp,'Enable','off');
    set(handles.edit_square_onset,'Enable','off');
    set(handles.edit_square_offset,'Enable','off');
    
end

%%set for epoch
EpochStart = def{6};
if ~isnumeric(EpochStart) || numel(EpochStart)>1
    EpochStart = [];
end

EpochStop = def{7};
if ~isnumeric(EpochStop) || numel(EpochStop)>1
    EpochStop = [];
end

srate = def{9};
if ~isnumeric(srate) || numel(srate)>1 || srate<=0
    srate = [];
end

if ~isempty(ALLERP)
    if  ~isempty(CURRENTERP) && CURRENTERP>0 && CURRENTERP<= length(ALLERP)
        ERP = ALLERP(CURRENTERP);
    else
        ERP =  ALLERP(length(ALLERP));
        handles.CURRENTERP = length(ALLERP);
    end
    try
        EpochStart = ERP.times(1);
        EpochStop = ERP.times(end);
        srate = ERP.srate;
    catch
    end
end
set(handles.edit_epoch_start,'String',num2str(EpochStart));
set(handles.edit_epochstop,'String',num2str(EpochStop));

srateValue = def{8};
if srateValue==1
    set(handles.radiobutton_srate,'Value',1);
    set(handles.edit_srate,'Enable','on');
    set(handles.edit_srate,'String',num2str(srate));
    if ~isempty(srate)
        set(handles.edit_speriod,'String',num2str(1000/srate));
    end
    set(handles.radiobutton_speriod,'Value',0);
    set(handles.edit_speriod,'Enable','off');
else
    set(handles.radiobutton_srate,'Value',0);
    set(handles.edit_srate,'Enable','off');
    set(handles.radiobutton_speriod,'Value',1);
    set(handles.edit_speriod,'Enable','on');
    set(handles.edit_speriod,'String',num2str(srate));
    if ~isempty(srate)
        set(handles.edit_srate,'String',num2str(1000/srate));
    end
end


%%--------------------------Noise------------------------------------------
%white noise
try
    WhiteNoiseop = def{10};
catch
    WhiteNoiseop =0;
end
if WhiteNoiseop==1
    set(handles.radiobutton_whitenoise,'Value',1);
    set(handles.edit_whitenoise_amp,'Enable','on');
else
    set(handles.radiobutton_whitenoise,'Value',0);
    set(handles.edit_whitenoise_amp,'Enable','off');
end
try
    WhiteNoiseamp = def{11};
catch
    WhiteNoiseamp = [];
end
if isempty(WhiteNoiseamp)|| ~isnumeric(WhiteNoiseamp) || numel(WhiteNoiseamp)~=1
    WhiteNoiseamp = [];
end
set(handles.edit_whitenoise_amp,'String',num2str(WhiteNoiseamp));

%%pinknoise
try
    pinkNoiseop = def{12};
catch
    pinkNoiseop =0;
end
if pinkNoiseop==1
    set(handles.radiobutton_pink_niose,'Value',1);
    set(handles.edit_pinknoise_amp,'Enable','on');
else
    set(handles.radiobutton_pink_niose,'Value',0);
    set(handles.edit_pinknoise_amp,'Enable','off');
end

try
    pinkNoiseamp = def{13};
catch
    pinkNoiseamp = [];
end
if isempty(pinkNoiseamp)|| ~isnumeric(pinkNoiseamp) || numel(pinkNoiseamp)~=1
    pinkNoiseamp = [];
end
set(handles.edit_pinknoise_amp,'String',num2str(pinkNoiseamp));

%%sin noise
try
    sinNoiseop = def{14};
catch
    sinNoiseop =0;
end
if sinNoiseop==1
    set(handles.radiobutton_siniose,'Value',1);
    set(handles.edit_siniose_amp,'Enable','on');
    set(handles.edit_siniose_Hz,'Enable','on');
else
    set(handles.radiobutton_siniose,'Value',0);
    set(handles.edit_siniose_amp,'Enable','off');
    set(handles.edit_siniose_Hz,'Enable','off');
end
try
    sinAmp = def{15};
catch
    sinAmp = [];
end
if isempty(sinAmp)|| ~isnumeric(sinAmp) || numel(sinAmp)~=1
    sinAmp = [];
end
set(handles.edit_siniose_amp,'String',num2str(sinAmp));
try
    sinFre = def{16};
catch
    sinFre = [];
end
if isempty(sinFre) || ~isnumeric(sinFre) || numel(sinFre)~=1
    sinFre = [];
end
set(handles.edit_siniose_Hz,'String',num2str(sinFre));

if ~isempty(ALLERP)
    handles.checkbox_ERP_op.Value =1;
    handles.edit_epoch_start.Enable = 'off';
    handles.edit_epochstop.Enable = 'off';
    handles.radiobutton_srate.Enable = 'off';
    handles.edit_srate.Enable = 'off';
    handles.radiobutton_speriod.Enable = 'off';
    handles.edit_speriod.Enable = 'off';
    
    if  ~isempty(CURRENTERP) && isnumeric(CURRENTERP)
        if numel(CURRENTERP)~=1
            CURRENTERP = CURRENTERP(1);
        end
        if CURRENTERP>0 && CURRENTERP<= length(ALLERP)
        else
            CURRENTERP = length(ALLERP);
        end
    else
        CURRENTERP = length(ALLERP);
    end
    handles.edit_erpset.String = num2str(CURRENTERP);
    handles.CURRENTERP = CURRENTERP;
    
    ERP = ALLERP(CURRENTERP);
    if ~isempty(ChanArray) && isnumeric(ChanArray)
        if numel(ChanArray)~=1
            ChanArray = ChanArray(1);
        end
        if  ChanArray>0 && ChanArray<=ERP.nchan
        else
            ChanArray =1;
        end
    else
        ChanArray =1;
    end
    handles.ChanArray  = ChanArray;
    handles.edit_channel.String = num2str(ChanArray);
    
    %%bin for real ERPset
    if ~isempty(BinArray) && isnumeric(BinArray)
        if numel(BinArray)~=1
            BinArray = BinArray(1);
        end
        if BinArray>1 && BinArray<= ERP.nbin
        else
            BinArray =1;
        end
    else
        BinArray =1;
    end
    
    handles.BinArray = BinArray;
    handles.edit_bin.String = num2str(BinArray);
else
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
end


%%seeds for white and pink noise
SimulationSeed = erpworkingmemory('SimulationSeed');
handles.SimulationSeed = SimulationSeed;

rng(0,'twister');
SimulationSeed = rng;
erpworkingmemory('SimulationSeed',SimulationSeed);
%phase for sin noise
SimulationPhase = erpworkingmemory('SimulationPhase');
handles.SimulationPhase = SimulationPhase;

SimulationPhase = 0;
erpworkingmemory('SimulationPhase',SimulationPhase);


plotsimulationwave(hObject, eventdata, handles);


% set(handles.current_erp_label,'String', ['Enter suffix, which will be added onto the name of each selected ERPset'],...
%     'FontWeight','Bold', 'FontSize', 16);

%
% % Color GUI
% %
handles = painterplabstudio(handles);
%
% %
% % Set font size
% %
handles = setfonterplabestudio(handles);

handles.checkbox_newnoise.BackgroundColor = [1 1 1];
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes savemyerpGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);




% --- Outputs from this function are returned to the command line.
function varargout = f_ERP_simulation_GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = [];
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1)




% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = [];
% beep;
% disp('User selected Cancel')
% Update handles structure
guidata(hObject, handles);
uiresume(handles.gui_chassis);


% --- Executes on button press in pushbutton4_okay.
function pushbutton4_okay_Callback(hObject, eventdata, handles)

BasicFunOp = 1;
Amp_bas = [];
Mean_bas = [];
SD_bas = [];
Tau_bas = [];
EpochStart = [];
EpochStop = [];
srateOp = 1;
srate = [];
WhiteOp = 0;
WhiteAmp = [];
pinkOp = 0;
pinkAmp = [];
sinOp = 0;
sinAmp = [];
sinFre = [];


EpochStart = str2num(handles.edit_epoch_start.String);
EpochStop = str2num(handles.edit_epochstop.String);
if handles.radiobutton_srate.Value
    srateOp = 1;
    srate = str2num(handles.edit_srate.String);
    if isempty(srate) || numel(srate)~=1
        msgboxText =  'Please define one numeric for sampling rate!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if srate<=0
        msgboxText =  'Sampling rate must be a positive numeric!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
else%% sampling period
    srateOp=2;
    Speriod =  str2num(handles.edit_speriod.String);
    
    if isempty(Speriod) || numel(Speriod)~=1
        msgboxText =  'Please define one numeric for sampling period!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if Speriod<=0
        msgboxText =  'Sampling period must be a positive numeric!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    srate = 1000/Speriod;
end

if isempty(EpochStart) || numel(EpochStart)~=1
    msgboxText =  'Please define one numeric for epoch start!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end

if isempty(EpochStop) || numel(EpochStop)~=1
    msgboxText =  'Please define one numeric for epoch stop!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end

if EpochStop<=EpochStart
    msgboxText =  'Please start time of epoch must be smaller than stop time of epoch!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end


if 1000/srate>= (EpochStop-EpochStart)
    msgboxText =  ['Please sampling period must be much smaller than ',32,num2str(EpochStop-EpochStart)];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end


Times = [];
if EpochStart>=0
    count =0;
    tIndex(1,1) =0;
    for ii = 1:10000
        count = count+1000/srate;
        if count<=EpochStop
            tIndex(1,ii) = count;
        else
            break;
        end
    end
    [xxx, latsamp, latdiffms] = closest(tIndex, [EpochStart,EpochStop]);
    Times = tIndex(latsamp(1):end);
    if Times(1)<EpochStart
        Times(1) = [];
    end
elseif EpochStop<=0
    count =0;
    tIndex(1,1) =0;
    for ii = 2:10000
        count = count-1000/srate;
        if count>=EpochStart
            tIndex(1,ii) = count;
        else
            break;
        end
    end
    tIndex = sort(tIndex);
    [xxx, latsamp, latdiffms] = closest(tIndex, [EpochStart,EpochStop]);
    
    Times = tIndex(1:latsamp(2));
    if Times(end)> EpochStop
        Times(end) = [];
    end
elseif EpochStart<0 && EpochStop>0
    tIndex1(1,1)  = 0;
    count =0;
    for ii = 1:10000
        count = count-1000/srate;
        if count>=EpochStart
            tIndex1(1,ii+1) = count;
        else
            break;
        end
    end
    tIndex2=[];
    count1 =1000/srate;
    for ii = 1:10000
        count1 = count1+1000/srate;
        if count1<=EpochStop
            tIndex2(1,ii) = count1;
        else
            break;
        end
    end
    Times = [sort(tIndex1),tIndex2];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%---------------------------Basic function--------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if handles.radiobutton_exgaus.Value ==1
    BasicFunOp =1;
    PeakAmp =   str2num(handles.edit5_exgau_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "peak amplitude" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    Meanamp = str2num(handles.edit_exgau_mean.String);
    if isempty(Meanamp) || numel(Meanamp)~=1
        msgboxText =  'Please define one numeric for "mean" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    Tau =  str2num(handles.edit8_exgua_tau.String);
    if isempty(Tau) || numel(Tau)~=1
        msgboxText =  'Please define one numeric for "Tau" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    SD_exgau = str2num(handles.edit_exgau_sd.String);
    if isempty(SD_exgau) || numel(SD_exgau)~=1
        msgboxText =  'Please define one numeric for "SD" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    Amp_bas = PeakAmp;
    Mean_bas = Meanamp;
    SD_bas = SD_exgau;
    Tau_bas = Tau;
    
elseif  handles.radiobutton_impulse.Value==1
    BasicFunOp=2;
    PeakAmp =   str2num(handles.edit_impulse_peak_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "peak amplitude" of impulse function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    Latency = str2num(handles.edit_impulse_lat.String);
    if isempty(Latency) || numel(Latency)~=1
        msgboxText =  'Please define one numeric for "latency" of impulse function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if Latency<Times(1)
        Latency=Times(1);
    end
    if Latency>Times(end)
        Latency=Times(end);
    end
    Amp_bas = PeakAmp;
    Mean_bas = Latency;
elseif handles.radiobutton_square.Value ==1
    BasicFunOp=3;
    PeakAmp =   str2num(handles.edit_square_peak_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "peak amplitude" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    onsetLat = str2num(handles.edit_square_onset.String);
    if isempty(onsetLat) || numel(onsetLat)~=1
        msgboxText =  'Please define one numeric for "onset" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    offsetLat = str2num(handles.edit_square_offset.String);
    if isempty(offsetLat) || numel(offsetLat)~=1
        msgboxText =  'Please define one numeric for "offset" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if offsetLat<= onsetLat
        msgboxText =  'Please "offset" should be larger than "onset" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    Amp_bas = PeakAmp;
    Mean_bas = onsetLat;
    SD_bas = offsetLat;
end



%%---------------------------Noise signal----------------------------------
if handles.radiobutton_siniose.Value
    sinOp = 1;
    PeakAmp =   str2num(handles.edit_siniose_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "amplitude" of sinusoidal noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    FreHz =  str2num(handles.edit_siniose_Hz.String);
    if isempty(FreHz) || numel(FreHz)~=1
        msgboxText =  'Please define one numeric for "frequency" of sinusoidal noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    sinAmp =PeakAmp;
    sinFre = FreHz;
else
    sinOp = 0;
end

%%white noise
if handles.radiobutton_whitenoise.Value==1
    WhiteOp = 1;
    PeakAmp =   str2num(handles.edit_whitenoise_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "amplitude" of white noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    WhiteAmp =PeakAmp;
else
    WhiteOp = 0;
end

if handles.radiobutton_pink_niose.Value==1
    pinkOp =1;
    PeakAmp =   str2num(handles.edit_pinknoise_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "amplitude" of pink noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    pinkAmp =PeakAmp;
else
    pinkOp =0;
end

NewnoiseFlag = handles.checkbox_newnoise.Value;

handles.output = {BasicFunOp,Amp_bas,Mean_bas,SD_bas,Tau_bas,EpochStart,EpochStop,...
    srateOp,srate,WhiteOp,WhiteAmp,pinkOp,pinkAmp,sinOp,sinAmp,sinFre,NewnoiseFlag};
% Update handles structure
guidata(hObject, handles);

uiresume(handles.gui_chassis);




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


% --- Executes during object deletion, before destroying properties.

% hObject    handle to edit_erpname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton_exgaus.
function radiobutton_exgaus_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

%%Exgaussian
set(handles.radiobutton_exgaus,'Value',1);
set(handles.radiobutton_exgaus,'Enable','on');
set(handles.edit5_exgau_amp,'Enable','on');
set(handles.edit_exgau_mean,'Enable','on');
set(handles.edit_exgau_sd,'Enable','on');
set(handles.edit8_exgua_tau,'Enable','on');

%%Impulse
set(handles.radiobutton_impulse,'Value',0);
set(handles.edit_impulse_peak_amp,'Enable','off');
set(handles.edit_impulse_lat,'Enable','off');

%%Square signal
set(handles.radiobutton_square,'Value',0);
set(handles.edit_square_peak_amp,'Enable','off');
set(handles.edit_square_onset,'Enable','off');
set(handles.edit_square_offset,'Enable','off');
plotsimulationwave(hObject, eventdata, handles);



function edit5_exgau_amp_Callback(hObject, eventdata, handles)
Amp = str2num(handles.edit5_exgau_amp.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit5_exgau_amp.String = '';
end
plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit5_exgau_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5_exgau_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_exgau_mean_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_exgau_mean.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_exgau_mean.String = '';
end


EpochStart = str2num(handles.edit_epoch_start.String);
if isempty(EpochStart)
    msgboxText =  'Please define a value for epoch start first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_exgau_mean.String = '';
    return;
    
end
EpochStop =str2num(handles.edit_epochstop.String);
if isempty(EpochStop)
    msgboxText =  'Please define a value for epoch stop first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_exgau_mean.String = '';
    return;
end

if Amp< EpochStart
    msgboxText =  ['Gaussian mean should be larger than',32,num2str(EpochStart),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_exgau_mean.String = '';
    return;
end

if Amp > EpochStop
    msgboxText =  ['Gaussian mean should be smaller than',32,num2str(EpochStop),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_exgau_mean.String = '';
    return;
end

plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit_exgau_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_exgau_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_exgau_sd_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_exgau_sd.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_exgau_sd.String = '';
end

if Amp<=0
    msgboxText =  'SD for Ex-Gaussian function should be a positive value!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_exgau_sd.String = '';
    return;
end

plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit_exgau_sd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_exgau_sd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_exgua_tau_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit8_exgua_tau.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit8_exgua_tau.String = '';
end
plotsimulationwave(hObject, eventdata, handles);




% --- Executes during object creation, after setting all properties.
function edit8_exgua_tau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8_exgua_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_impulse.
function radiobutton_impulse_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

%%Exgaussian
set(handles.radiobutton_exgaus,'Value',0);
set(handles.radiobutton_exgaus,'Enable','on');
set(handles.edit5_exgau_amp,'Enable','off');
set(handles.edit_exgau_mean,'Enable','off');
set(handles.edit_exgau_sd,'Enable','off');
set(handles.edit8_exgua_tau,'Enable','off');

%%Impulse
set(handles.radiobutton_impulse,'Value',1);
set(handles.edit_impulse_peak_amp,'Enable','on');
set(handles.edit_impulse_lat,'Enable','on');

%%Square signal
set(handles.radiobutton_square,'Value',0);
set(handles.edit_square_peak_amp,'Enable','off');
set(handles.edit_square_onset,'Enable','off');
set(handles.edit_square_offset,'Enable','off');
plotsimulationwave(hObject, eventdata, handles);


function edit_impulse_peak_amp_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_impulse_peak_amp.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_impulse_peak_amp.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit_impulse_peak_amp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_impulse_lat_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Lat = str2num(handles.edit_impulse_lat.String);
if isempty(Lat) || numel(Lat)~=1
    handles.edit_impulse_lat.String = '';
    return;
end

EpochStart = str2num(handles.edit_epoch_start.String);
if isempty(EpochStart)
    msgboxText =  'Please define a value for epoch start first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
   handles.edit_impulse_lat.String = '';
    return;
    
end
EpochStop =str2num(handles.edit_epochstop.String);
if isempty(EpochStop)
    msgboxText =  'Please define a value for epoch stop first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
   handles.edit_impulse_lat.String = '';
    return;
end

if Lat< EpochStart
    msgboxText =  ['Latency for Impulse function should be larger than',32,num2str(EpochStart),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_impulse_lat.String = '';
    return;
end

if Lat > EpochStop
    msgboxText =  ['Latency for Impulse function should be smaller than',32,num2str(EpochStop),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_impulse_lat.String = '';
    return;
end


plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit_impulse_lat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_square.
function radiobutton_square_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

%%Exgaussian
set(handles.radiobutton_exgaus,'Value',0);
set(handles.radiobutton_exgaus,'Enable','on');
set(handles.edit5_exgau_amp,'Enable','off');
set(handles.edit_exgau_mean,'Enable','off');
set(handles.edit_exgau_sd,'Enable','off');
set(handles.edit8_exgua_tau,'Enable','off');

%%Impulse
set(handles.radiobutton_impulse,'Value',0);
set(handles.edit_impulse_peak_amp,'Enable','off');
set(handles.edit_impulse_lat,'Enable','off');

%%Square signal
set(handles.radiobutton_square,'Value',1);
set(handles.edit_square_peak_amp,'Enable','on');
set(handles.edit_square_onset,'Enable','on');
set(handles.edit_square_offset,'Enable','on');
plotsimulationwave(hObject, eventdata, handles);



function edit_square_peak_amp_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_square_peak_amp.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_square_peak_amp.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit_square_peak_amp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_square_onset_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

LatencyOnset = str2num(handles.edit_square_onset.String);
if isempty(LatencyOnset) || numel(LatencyOnset)~=1
    handles.edit_square_onset.String = '';
    return;
end


EpochStart = str2num(handles.edit_epoch_start.String);
if isempty(EpochStart)
    msgboxText =  'Please define a value for epoch start first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
     handles.edit_square_onset.String = '';
    return;
    
end
EpochStop =str2num(handles.edit_epochstop.String);
if isempty(EpochStop)
    msgboxText =  'Please define a value for epoch stop first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_square_onset.String = '';
    return;
end

if LatencyOnset< EpochStart
    msgboxText =  ['Onset for Boxcar for Impulse function should be larger than',32,num2str(EpochStart),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
     handles.edit_square_onset.String = '';
    return;
end

if LatencyOnset > EpochStop
    msgboxText =  ['Onset for Boxcar function should be smaller than',32,num2str(EpochStop),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
   handles.edit_square_onset.String = '';
    return;
end


LatencyOffset = str2num(handles.edit_square_offset.String);
if LatencyOnset> LatencyOffset
    msgboxText =  'Offset for Boxcar should be larger than Onset!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_square_onset.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit_square_onset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_square_onset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_square_offset_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

LatencyOffset = str2num(handles.edit_square_offset.String);
if isempty(LatencyOffset) || numel(LatencyOffset)~=1
    handles.edit_square_offset.String = '';
    return;
end

EpochStart = str2num(handles.edit_epoch_start.String);
if isempty(EpochStart)
    msgboxText =  'Please define a value for epoch start first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
     handles.edit_square_offset.String = '';
    return;
    
end
EpochStop =str2num(handles.edit_epochstop.String);
if isempty(EpochStop)
    msgboxText =  'Please define a value for epoch stop first!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_square_offset.String = '';
    return;
end

if LatencyOffset< EpochStart
    msgboxText =  ['Offset for Boxcar for Impulse function should be larger than',32,num2str(EpochStart),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
     handles.edit_square_offset.String = '';
    return;
end

if LatencyOffset > EpochStop
    msgboxText =  ['Offset for Boxcar function should be smaller than',32,num2str(EpochStop),'ms'];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
  handles.edit_square_offset.String = '';
    return;
end




LatencyOnset = str2num(handles.edit_square_onset.String);
if LatencyOnset>LatencyOffset
    msgboxText =  'Offset for Boxcar should be larger than Onset!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    
    
    handles.edit_square_offset.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_square_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_square_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radiobutton_siniose.
function radiobutton_siniose_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

%%sin noise
Value = handles.radiobutton_siniose.Value;
if Value==1
    Enable = 'on';
else
    Enable = 'off';
end
% set(handles.radiobutton_siniose,'Enable',Enable);
set(handles.edit_siniose_Hz,'Enable',Enable);
set(handles.edit_siniose_amp,'Enable',Enable);
plotsimulationwave(hObject, eventdata, handles);



function edit_siniose_Hz_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

FreValue = str2num(handles.edit_siniose_Hz.String);
if isempty(FreValue) || numel(FreValue)~=1 || FreValue<=0
    msgboxText =  'Please define a positive numeric for frequency of sinusoidal noise!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    
    handles.edit_siniose_Hz.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_siniose_Hz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_siniose_amp_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_siniose_amp.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_siniose_amp.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_siniose_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_siniose_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_whitenoise.
function radiobutton_whitenoise_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Value = handles.radiobutton_whitenoise.Value;
if Value==1
    Enable = 'on';
else
    Enable = 'off';
end

% set(handles.radiobutton_whitenoise,'Enable',Enable);
set(handles.edit_whitenoise_amp,'Enable',Enable);
plotsimulationwave(hObject, eventdata, handles);


function edit_whitenoise_amp_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_whitenoise_amp.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_whitenoise_amp.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_whitenoise_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_whitenoise_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_pink_niose.
function radiobutton_pink_niose_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Value = handles.radiobutton_pink_niose.Value;
if Value==1
    Enable = 'on';
else
    Enable = 'off';
end
% set(handles.radiobutton_pink_niose,'Enable',Enable);
set(handles.edit_pinknoise_amp,'Enable',Enable);
plotsimulationwave(hObject, eventdata, handles);




function edit_pinknoise_amp_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

Amp = str2num(handles.edit_pinknoise_amp.String);
if isempty(Amp) || numel(Amp)~=1
    handles.edit_pinknoise_amp.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_pinknoise_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pinknoise_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_epoch_start_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

EpochStart =str2num(handles.edit_epoch_start.String);
if ~isnumeric(EpochStart) || numel(EpochStart)>1
    handles.edit_epoch_start.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_epoch_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_epoch_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_epochstop_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

EpochStop =str2num(handles.edit_epochstop.String);
if ~isnumeric(EpochStop) || numel(EpochStop)>1
    handles.edit_epochstop.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_epochstop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_srate.
function radiobutton_srate_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

set(handles.radiobutton_srate,'Value',1);
set(handles.edit_srate,'Enable','on');
set(handles.radiobutton_speriod,'Value',0);
set(handles.edit_speriod,'Enable','off');
srate = str2num(handles.edit_srate.String);
plotsimulationwave(hObject, eventdata, handles);


function edit_srate_Callback(hObject, eventdata, handles)
handles.text_message.String = '';
srate = str2num(handles.edit_srate.String);
if ~isempty(srate) && numel(srate)==1 && srate>0
    set(handles.edit_speriod,'String',num2str(1000/srate));
elseif isempty(srate) || srate<=0
    handles.edit_srate.String = '';
    msgboxText =  'Sampling rate should be a positive numeric!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_srate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_speriod.
function radiobutton_speriod_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

set(handles.radiobutton_srate,'Value',0);
set(handles.edit_srate,'Enable','off');
set(handles.radiobutton_speriod,'Value',1);
set(handles.edit_speriod,'Enable','on');
plotsimulationwave(hObject, eventdata, handles);



function edit_speriod_Callback(hObject, eventdata, handles)
handles.text_message.String = '';

speriod = str2num(handles.edit_speriod.String);
if ~isempty(speriod) && numel(speriod)==1 && speriod>0
    set(handles.edit_srate,'String',num2str(1000/speriod));
elseif isempty(speriod)|| speriod<=0
    handles.edit_srate.String = '';
    msgboxText =  'Sampling period should be a positive numeric!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    handles.edit_speriod.String = '';
    return;
end
plotsimulationwave(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_speriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_speriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit_exgua_onset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_exgua_onset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function ERP =  plotsimulationwave(hObject, eventdata, handles);

%%------------------match with real ERPset?--------------------------------
MatchFlag = handles.checkbox_ERP_op.Value;
ALLERP = handles.ALLERP;
ERP = [];
ERPArray = [];
ChannelArray = [];
binArray = [];
% NoiseupdateFlag = handles.checkbox_newnoise.Value;

if MatchFlag==1 && ~isempty(ALLERP)
    %%check ERPset
    ERPArray = str2num(handles.edit_erpset.String);
    if ~isempty(ERPArray)
        if numel(ERPArray)~=1
            ERPArray = ERPArray(1);
        end
        if ERPArray>0 && ERPArray <=length(ALLERP)
        else
            ERPArray = length(ALLERP);
        end
    else
        ERPArray = length(ALLERP);
    end
    handles.edit_erpset.String= num2str(ERPArray);
    ERP = ALLERP(ERPArray);
    %%check channels
    ChannelArray = str2num(handles.edit_channel.String);
    if isempty(ChannelArray)
        ChannelArray =1;
    else
        if numel(ChannelArray)~=1
            ChannelArray = ChannelArray(1);
        end
        if ChannelArray>0 && ChannelArray<= ERP.nchan
        else
            ChannelArray =1;
        end
    end
    handles.edit_channel.String = num2str(ChannelArray);
    %%check bins
    binArray =  str2num(handles.edit_bin.String);
    if isempty(binArray)
        binArray =1;
    else
        if numel(binArray)~=1
            binArray = binArray(1);
        end
        if binArray>0 && binArray<=ERP.nbin
        else
            binArray =1;
        end
    end
    handles.edit_bin.String = num2str(binArray);
end

EpochStart = str2num(handles.edit_epoch_start.String);
EpochStop = str2num(handles.edit_epochstop.String);
if handles.radiobutton_srate.Value
    srate = str2num(handles.edit_srate.String);
    if isempty(srate) || numel(srate)~=1
        msgboxText =  'Please define one numeric for sampling rate!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if srate<=0
        msgboxText =  'Sampling rate must be a positive numeric!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
else%% sampling period
    Speriod =  str2num(handles.edit_speriod.String);
    
    if isempty(Speriod) || numel(Speriod)~=1
        msgboxText =  'Please define one numeric for sampling period!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if Speriod<=0
        msgboxText =  'Sampling period must be a positive numeric!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    srate = 1000/Speriod;
end

if isempty(EpochStart) || numel(EpochStart)~=1
    msgboxText =  'Please define one numeric for epoch start!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end

if isempty(EpochStop) || numel(EpochStop)~=1
    msgboxText =  'Please define one numeric for epoch stop!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end

if EpochStop<=EpochStart
    msgboxText =  'Start time of epoch must be smaller than stop time of epoch!';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end


if 1000/srate>= (EpochStop-EpochStart)
    msgboxText =  ['Please sampling period must be much smaller than ',32,num2str(EpochStop-EpochStart)];
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end

Times = [];
if ~isempty(ERP) && ~isempty(ChannelArray) && ~isempty(binArray)
    Times = ERP.times;
else
    if EpochStart>=0
        count =0;
        tIndex(1,1) =0;
        for ii = 1:10000
            count = count+1000/srate;
            if count<=EpochStop
                tIndex(1,ii) = count;
            else
                break;
            end
        end
        
        [xxx, latsamp, latdiffms] = closest(tIndex, [EpochStart,EpochStop]);
        Times = tIndex(latsamp(1):end);
        if Times(1)<EpochStart
            Times(1) = [];
        end
        
    elseif EpochStop<=0
        count =0;
        tIndex(1,1) =0;
        for ii = 2:10000
            count = count-1000/srate;
            if count>=EpochStart
                tIndex(1,ii) = count;
            else
                break;
            end
        end
        tIndex = sort(tIndex);
        [xxx, latsamp, latdiffms] = closest(tIndex, [EpochStart,EpochStop]);
        
        Times = tIndex(1:latsamp(2));
        if Times(end)> EpochStop
            Times(end) = [];
        end
    elseif EpochStart<0 && EpochStop>0
        tIndex1(1,1)  = 0;
        count =0;
        for ii = 1:10000
            count = count-1000/srate;
            if count>=EpochStart
                tIndex1(1,ii+1) = count;
            else
                break;
            end
        end
        tIndex2=[];
        count1 =0;
        for ii = 1:10000
            count1 = count1+1000/srate;
            if count1<=EpochStop
                tIndex2(1,ii) = count1;
            else
                break;
            end
        end
        Times = [sort(tIndex1),tIndex2];
    end
end

[x1,y1]  = find(roundn(Times,-3)==roundn(EpochStart,-3));


[x2,y2]  = find(roundn(Times,-3)==roundn(EpochStop,-3));
if isempty(y1) || isempty(y2)
    Mesg = 'Warning: The exact time periods you have specified cannot be exactly created with the specified sampling rate. We will round to the nearest possible time values when the ERPset is created.';
    handles.text_message.String = Mesg;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
else
    handles.text_message.String = '';
end

Desiredsignal = zeros(1,numel(Times));
Desirednosizesin = zeros(1,numel(Times));
Desirednosizewhite = zeros(1,numel(Times));
Desirednosizepink = zeros(1,numel(Times));
RealData = nan(1,numel(Times));

% plot(handles.axes1,Times,Desiredsignal,'k','linewidth',1.5);

%%---------------------------Simulated signal------------------------------
if handles.radiobutton_exgaus.Value ==1
    Gua_PDF = zeros(1,numel(Times));
    PeakAmp =   str2num(handles.edit5_exgau_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "peak amplitude" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    Meanamp = str2num(handles.edit_exgau_mean.String);
    if isempty(Meanamp) || numel(Meanamp)~=1
        msgboxText =  'Please define one numeric for "mean" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    
    Tau =  str2num(handles.edit8_exgua_tau.String);
    if isempty(Tau) || numel(Tau)~=1
        msgboxText =  'Please define one numeric for "Tau" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    
    SD = str2num(handles.edit_exgau_sd.String);
    if isempty(SD) || numel(SD)~=1
        msgboxText =  'Please define one numeric for "SD" of Ex-Gaussian function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    SD = SD/100;
    Tau = Tau/1000;
    if Tau~=0
        Mu =  Meanamp/100-Times(1)/100;
        if Mu<0
            Mu =  Meanamp/100;
        end
        if Tau<0
            Mu = abs((Times(end)/100-Times(1)/100)-Mu);
        end
        LegthSig = (Times(end)-Times(1))/100;
        Sig = 0: LegthSig/numel(Times):LegthSig-LegthSig/numel(Times);
        Gua_PDF = f_exgauss_pdf(Sig, Mu, SD, abs(Tau));
        if Tau<0
            Gua_PDF = fliplr(Gua_PDF);
        end
        
    elseif Tau==0 %%Gaussian signal
        Times_new = Times/1000;
        Gua_PDF = f_gaussian(Times_new,abs(PeakAmp),Meanamp/1000,SD/10);
    end
    
    Max = max(abs( Gua_PDF(:)));
    Gua_PDF = PeakAmp*Gua_PDF./Max;
    if PeakAmp~=0
        Desiredsignal = Gua_PDF;
    end
    
elseif  handles.radiobutton_impulse.Value==1
    PeakAmp =   str2num(handles.edit_impulse_peak_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "peak amplitude" of impulse function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    Latency = str2num(handles.edit_impulse_lat.String);
    if isempty(Latency) || numel(Latency)~=1
        msgboxText =  'Please define one numeric for "latency" of impulse function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if Latency<Times(1)
        Latency=Times(1);
    end
    if Latency>Times(end)
        Latency=Times(end);
    end
    [xxx, latsamp, latdiffms] = closest(Times, Latency);
    Desiredsignal(latsamp) = PeakAmp;
    
elseif handles.radiobutton_square.Value ==1
    PeakAmp =   str2num(handles.edit_square_peak_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "peak amplitude" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    onsetLat = str2num(handles.edit_square_onset.String);
    if isempty(onsetLat) || numel(onsetLat)~=1
        msgboxText =  'Please define one numeric for "onset" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    offsetLat = str2num(handles.edit_square_offset.String);
    if isempty(offsetLat) || numel(offsetLat)~=1
        msgboxText =  'Please define one numeric for "offset" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    if offsetLat< onsetLat
        msgboxText =  'Please "offset" should be larger than "onset" of boxcar function!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    [xxx, latsamp, latdiffms] = closest(Times, [onsetLat,offsetLat]);
    Desiredsignal(latsamp(1):latsamp(2)) = PeakAmp;
end



%%---------------------------Noise signal----------------------------------
SimulationSeed = handles.SimulationSeed;
try
    SimulationSeed_Type = SimulationSeed.Type;
    SimulationSeed_seed=SimulationSeed.Seed;
catch
    SimulationSeed_Type = 'twister';
    SimulationSeed_seed = 0;
end
%phase for sin noise
SimulationPhase = handles.SimulationPhase;
if isempty(SimulationPhase) ||  ~isnumeric(SimulationPhase)
    SimulationPhase = 0;
end
if numel(SimulationPhase)~=1
    SimulationPhase = SimulationPhase(1);
end
if SimulationPhase<0 || SimulationPhase>1
    SimulationPhase = 0;
end

if handles.radiobutton_siniose.Value
    PeakAmp =   str2num(handles.edit_siniose_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "amplitude" of sinusoidal noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    FreHz =  str2num(handles.edit_siniose_Hz.String);
    if isempty(FreHz) || numel(FreHz)~=1 || FreHz<=0
        msgboxText =  'Please define one positive numeric for "frequency" of sinusoidal noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    X =  Times/1000;
    
    Desirednosizesin = PeakAmp*sin(2*FreHz*pi*(X)+2*pi*SimulationPhase);
end


if handles.radiobutton_whitenoise.Value==1
    PeakAmp =   str2num(handles.edit_whitenoise_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "amplitude" of white noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    try
        rng(SimulationSeed_seed,SimulationSeed_Type);
    catch
        rng(0,'twister');
    end
    Desirednosizewhite =  randn(1,numel(Times));%%white noise
    Desirednosizewhite = PeakAmp*Desirednosizewhite;
end

if handles.radiobutton_pink_niose.Value==1
    PeakAmp =   str2num(handles.edit_pinknoise_amp.String);
    if isempty(PeakAmp) || numel(PeakAmp)~=1
        msgboxText =  'Please define one numeric for "amplitude" of pink noise!';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    try
        rng(SimulationSeed_seed,SimulationSeed_Type);
    catch
        rng(0,'twister');
    end
    Desirednosizepink = f_pinknoise(numel(Times));
    
    Desirednosizepink = reshape(Desirednosizepink,1,numel(Desirednosizepink));
    Desirednosizepink = PeakAmp*Desirednosizepink;
end


Sig = Desirednosizesin+Desiredsignal+Desirednosizepink+Desirednosizewhite;
if ~isempty(ERP) && ~isempty(ChannelArray) && ~isempty(binArray)
    try
        RealData = squeeze(ERP.bindata(ChannelArray,:,binArray));
        plot(handles.axes1,Times,[Sig;RealData],'linewidth',1.5);
        legend({'Simulated data',['Real data at',32,ERP.chanlocs(ChannelArray).labels]},'fontsize',14);
        legend('boxoff');
    catch
    end
else
    plot(handles.axes1,Times,Sig,'k','linewidth',1.5);
    legend({'Simulated data'},'fontsize',14);
    legend('boxoff');
end

xlim([Times(1),Times(end)]);
xlabel(['Time/ms']);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function edit_exgua_onset_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to edit_exgua_onset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_ERP_op.
function checkbox_ERP_op_Callback(hObject, eventdata, handles)
Value = handles.checkbox_ERP_op.Value;
if Value==1
    handles.edit_erpset.Enable = 'on';
    handles.pushbutton_erpset.Enable = 'on';
    handles.edit_channel.Enable = 'on';
    handles.pushbutton_channel.Enable = 'on';
    handles.edit_bin.Enable = 'on';
    handles.pushbutton_bin.Enable = 'on';
    
    ALLERP = handles.ALLERP;
    CURRENTERP = handles.CURRENTERP;
    if isempty(ALLERP)
        msgboxText =  'ALLERP is empty and cannot match simulation with real data';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    %%disable "Basic information for simulation". That is, the parameters
    %%must be the same to the real ERPset
    handles.edit_epoch_start.Enable = 'off';
    handles.edit_epochstop.Enable = 'off';
    handles.radiobutton_srate.Enable = 'off';
    handles.edit_srate.Enable = 'off';
    handles.radiobutton_speriod.Enable = 'off';
    handles.edit_speriod.Enable = 'off';
    
    %%change the epoch start, epoch stop, and sampling rate based on the
    %%changed ERPsets
    EpochStart =[];
    EpochStop = [];
    srate =[];
    if ~isempty(ALLERP)
        if  ~isempty(CURRENTERP) && CURRENTERP>0 && CURRENTERP<= length(ALLERP)
            ERP = ALLERP(CURRENTERP);
        else
            ERP =  ALLERP(length(ALLERP));
            handles.CURRENTERP = length(ALLERP);
        end
        try
            EpochStart = ERP.times(1);
            EpochStop = ERP.times(end);
            srate = ERP.srate;
        catch
        end
    end
    
    if ~isempty(EpochStart) && ~isempty(EpochStop) && ~isempty(srate)
        handles.edit_epoch_start.String = num2str(EpochStart);
        handles.edit_epochstop.String = num2str(EpochStop);
        if srate~=0
            handles.edit_srate.String = num2str(srate);
            handles.edit_speriod.String = num2str(1000/srate);
        end
    end
else
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    
    handles.edit_epoch_start.Enable = 'on';
    handles.edit_epochstop.Enable = 'on';
    handles.radiobutton_srate.Enable = 'on';
    handles.edit_srate.Enable = 'on';
    handles.radiobutton_speriod.Enable = 'on';
    handles.edit_speriod.Enable = 'on';
    
    if handles.radiobutton_srate.Value==1
        set(handles.radiobutton_srate,'Value',1);
        set(handles.edit_srate,'Enable','on');
        set(handles.radiobutton_speriod,'Value',0);
        set(handles.edit_speriod,'Enable','off');
    else
        set(handles.radiobutton_srate,'Value',0);
        set(handles.edit_srate,'Enable','off');
        set(handles.radiobutton_speriod,'Value',1);
        set(handles.edit_speriod,'Enable','on');
    end
    
end
plotsimulationwave(hObject, eventdata, handles);


function edit_erpset_Callback(hObject, eventdata, handles)
ERPsetArray = str2num(handles.edit_erpset.String);
if ~isempty(handles.ALLERP)
    if isempty(ERPsetArray)
        msgboxText =  'Real ERP: Index of ERPset should be a positive numeric';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    else
        if numel(ERPsetArray)~=1
            ERPsetArray = ERPsetArray(1);
        end
        if ERPsetArray> length(handles.ALLERP)
            ERPsetArray = length(handles.ALLERP);
            msgboxText =  'Real ERP: Input should be smaller than the length of ALLERP.';
            handles.text_message.String = msgboxText;
            handles.text_message.ForegroundColor = 'k';
            handles.text_message.FontSize = 12;
            handles.edit_erpset.String = num2str(handles.CURRENTERP);
            return;
        end
        CURRENTERP = ERPsetArray;
        ALLERP = handles.ALLERP;
        handles.CURRENTERP = ERPsetArray;
        ERP =handles.ALLERP(ERPsetArray);
        EpochStart =[];
        EpochStop = [];
        srate =[];
        if ~isempty(ALLERP)
            if  ~isempty(CURRENTERP) && CURRENTERP>0 && CURRENTERP<= length(ALLERP)
                ERP = ALLERP(CURRENTERP);
            else
                ERP =  ALLERP(length(ALLERP));
                handles.CURRENTERP = length(ALLERP);
            end
            try
                EpochStart = ERP.times(1);
                EpochStop = ERP.times(end);
                srate = ERP.srate;
            catch
            end
        end
        
        if ~isempty(EpochStart) && ~isempty(EpochStop) && ~isempty(srate)
            handles.edit_epoch_start.String = num2str(EpochStart);
            handles.edit_epochstop.String = num2str(EpochStop);
            if srate~=0
                handles.edit_srate.String = num2str(srate);
                handles.edit_speriod.String = num2str(1000/srate);
            end
        end
        
    end
else
    handles.checkbox_ERP_op.Value =0;
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    
    msgboxText =  'Real ERP: ALLERPset is empty and cannot match simulation with it';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);




% --- Executes during object creation, after setting all properties.
function edit_erpset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_erpset.
function pushbutton_erpset_Callback(hObject, eventdata, handles)

if ~isempty(handles.ALLERP)
    ERPsetArray = handles.CURRENTERP;
    if isempty(ERPsetArray)
        msgboxText =  'Real ERP: Index of ERPset is empty';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    else
        if numel(ERPsetArray)~=1
            ERPsetArray = ERPsetArray(1);
        end
        if ERPsetArray> length(handles.ALLERP)
            ERPsetArray = length(handles.ALLERP);
            msgboxText =  'Real ERP: Input should be smaller than the length of ALLERP.';
            handles.text_message.String = msgboxText;
            handles.text_message.ForegroundColor = 'k';
            handles.text_message.FontSize = 12;
            handles.edit_erpset.String = num2str(handles.CURRENTERP);
            return;
        end
        ALLERP = handles.ALLERP;
        for Numoferpset = 1:length(ALLERP)
            listname{Numoferpset} = char(strcat(num2str(Numoferpset),'.',ALLERP(Numoferpset).erpname));
        end
        indxlistb  =ERPsetArray;
        
        titlename = 'Select one ERPset:';
        ERPsetArray = browsechanbinGUI(listname, indxlistb, titlename);
        
        if ~isempty(ERPsetArray)
            if numel(ERPsetArray)~=1
                ERPsetArray =ERPsetArray(1);
            end
            CURRENTERP = ERPsetArray;
            ALLERP = handles.ALLERP;
            handles.CURRENTERP = ERPsetArray;
            ERP =handles.ALLERP(ERPsetArray);
            EpochStart =[];
            EpochStop = [];
            srate =[];
            if  ~isempty(CURRENTERP) && CURRENTERP >0 && CURRENTERP<= length(ALLERP)
                ERP = ALLERP(CURRENTERP);
            else
                ERP =  ALLERP(length(ALLERP));
                handles.CURRENTERP = length(ALLERP);
            end
            try
                EpochStart = ERP.times(1);
                EpochStop = ERP.times(end);
                srate = ERP.srate;
            catch
            end
            if ~isempty(EpochStart) && ~isempty(EpochStop) && ~isempty(srate)
                handles.edit_epoch_start.String = num2str(EpochStart);
                handles.edit_epochstop.String = num2str(EpochStop);
                if srate~=0
                    handles.edit_srate.String = num2str(srate);
                    handles.edit_speriod.String = num2str(1000/srate);
                end
            end
            handles.edit_erpset.String = num2str(CURRENTERP);
        else%%the user did not select one ERPset
            msgboxText =  'Real ERP: User selected cancel.';
            handles.text_message.String = msgboxText;
            handles.text_message.ForegroundColor = 'k';
            handles.text_message.FontSize = 12;
            return;
        end
        
    end
else
    handles.checkbox_ERP_op.Value =0;
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    
    msgboxText =  'Real ERP: ALLERPset is empty and cannot match simulation with it';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);




%%edit channels
function edit_channel_Callback(hObject, eventdata, handles)
if ~isempty(handles.ALLERP)
    channelArray = str2num(handles.edit_channel.String);
    if isempty(channelArray)
        msgboxText =  'Real ERP: Please input one positive numeric for "Channel".';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    if numel(channelArray)~=1
        channelArray = channelArray(1);
    end
    if channelArray<=0
        msgboxText =  'Real ERP: Please input one positive numeric for "Channel".';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    ALLERP =  handles.ALLERP;
    CURRENTERP= handles.CURRENTERP;
    if isempty(CURRENTERP)
        CURRENTERP =  length(ALLERP);
    end
    if numel(CURRENTERP)~=1
        CURRENTERP  = CURRENTERP(1);
    end
    if CURRENTERP> length(ALLERP) || CURRENTERP<=0
        CURRENTERP =  length(ALLERP);
    end
    handles.CURRENTERP=CURRENTERP;
    handles.edit_erpset.String = num2str(CURRENTERP);
    ERP = ALLERP(CURRENTERP);
    if channelArray > ERP.nchan
        channelArray =1;
    end
    handles.edit_channel.String = num2str(channelArray);
else
    handles.checkbox_ERP_op.Value =0;
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    msgboxText =  'Real ERP: ALLERPset is empty and cannot match simulation with it';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_channel.
function pushbutton_channel_Callback(hObject, eventdata, handles)

if ~isempty(handles.ALLERP)
    ALLERP =  handles.ALLERP;
    CURRENTERP= handles.CURRENTERP;
    if isempty(CURRENTERP)
        CURRENTERP =  length(ALLERP);
    end
    if numel(CURRENTERP)~=1
        CURRENTERP  = CURRENTERP(1);
    end
    if CURRENTERP> length(ALLERP) || CURRENTERP<=0
        CURRENTERP =  length(ALLERP);
    end
    handles.CURRENTERP=CURRENTERP;
    handles.edit_erpset.String = num2str(CURRENTERP);
    ERP = ALLERP(CURRENTERP);
    channelArray = str2num(handles.edit_channel.String);
    if isempty(channelArray)
        channelArray=1;
    end
    if numel(channelArray)~=1
        channelArray = channelArray(1);
    end
    if channelArray<=0
        channelArray=1;
    end
    if max(channelArray(:)) >ERP.nchan
        channelArray =1;
    end
    
    for Numofchan = 1:ERP.nchan
        listb{Numofchan}= strcat(num2str(Numofchan),'.',ERP.chanlocs(Numofchan).labels);
    end
    titlename = 'Select One Channel:';
    channelArray = browsechanbinGUI(listb, channelArray, titlename);
    if ~isempty(channelArray)
        if numel(channelArray)~=1
            channelArray = channelArray(1);
        end
        handles.edit_channel.String = num2str(channelArray);
    else
        msgboxText =  'Real ERP: User selected cancel.';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
else
    handles.checkbox_ERP_op.Value =0;
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    msgboxText =  'Real ERP: ALLERPset is empty and cannot match simulation with it';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);



function edit_bin_Callback(hObject, eventdata, handles)

if ~isempty(handles.ALLERP)
    binArray = str2num(handles.edit_bin.String);
    if isempty(binArray)
        msgboxText =  'Real ERP: Please input one positive numeric for "Bin".';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    
    if numel(binArray)~=1
        binArray = binArray(1);
    end
    if binArray<=0
        msgboxText =  'Real ERP: Please input one positive numeric for "Bin".';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
    ALLERP =  handles.ALLERP;
    CURRENTERP= handles.CURRENTERP;
    if isempty(CURRENTERP)
        CURRENTERP =  length(ALLERP);
    end
    if numel(CURRENTERP)~=1
        CURRENTERP  = CURRENTERP(1);
    end
    if CURRENTERP> length(ALLERP) || CURRENTERP<=0
        CURRENTERP =  length(ALLERP);
    end
    handles.CURRENTERP=CURRENTERP;
    handles.edit_erpset.String = num2str(CURRENTERP);
    ERP = ALLERP(CURRENTERP);
    if binArray > ERP.nbin
        binArray =1;
    end
    handles.edit_bin.String = num2str(binArray);
else
    handles.checkbox_ERP_op.Value =0;
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    msgboxText =  'Real ERP: ALLERPset is empty and cannot match simulation with it';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);





% --- Executes during object creation, after setting all properties.
function edit_bin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_bin.
function pushbutton_bin_Callback(hObject, eventdata, handles)
if ~isempty(handles.ALLERP)
    ALLERP =  handles.ALLERP;
    CURRENTERP= handles.CURRENTERP;
    if isempty(CURRENTERP)
        CURRENTERP =  length(ALLERP);
    end
    if numel(CURRENTERP)~=1
        CURRENTERP  = CURRENTERP(1);
    end
    if CURRENTERP> length(ALLERP) || CURRENTERP<=0
        CURRENTERP =  length(ALLERP);
    end
    handles.CURRENTERP=CURRENTERP;
    handles.edit_erpset.String = num2str(CURRENTERP);
    ERP = ALLERP(CURRENTERP);
    binArray = str2num(handles.edit_bin.String);
    if isempty(binArray)
        binArray=1;
    end
    if numel(binArray)~=1
        binArray = binArray(1);
    end
    if binArray<=0
        binArray=1;
    end
    if max(binArray(:)) >ERP.nchan
        binArray =1;
    end
    
    for Numofchan = 1:ERP.nbin
        listb{Numofchan}= strcat(num2str(Numofchan),'.',ERP.bindescr{Numofchan});
    end
    titlename = 'Select One Bin:';
    binArray = browsechanbinGUI(listb, binArray, titlename);
    if ~isempty(binArray)
        if numel(binArray)~=1
            binArray = binArray(1);
        end
        handles.edit_bin.String = num2str(binArray);
    else
        msgboxText =  'Real ERP: User selected cancel.';
        handles.text_message.String = msgboxText;
        handles.text_message.ForegroundColor = 'k';
        handles.text_message.FontSize = 12;
        return;
    end
else
    handles.checkbox_ERP_op.Value =0;
    handles.checkbox_ERP_op.Enable = 'off';
    handles.edit_erpset.Enable = 'off';
    handles.pushbutton_erpset.Enable = 'off';
    handles.edit_channel.Enable = 'off';
    handles.pushbutton_channel.Enable = 'off';
    handles.edit_bin.Enable = 'off';
    handles.pushbutton_bin.Enable = 'off';
    msgboxText =  'Real ERP: ALLERPset is empty and cannot match simulation with it';
    handles.text_message.String = msgboxText;
    handles.text_message.ForegroundColor = 'k';
    handles.text_message.FontSize = 12;
    return;
end
plotsimulationwave(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_loaderpset.
% function pushbutton_loaderpset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loaderpset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_newnoise.
function checkbox_newnoise_Callback(hObject, eventdata, handles)

%%reset the phase for sin signal
SimulationPhase = rand(1);
erpworkingmemory('SimulationPhase',SimulationPhase);

%%reset seeds for white or pink noise
SimulationSeed = erpworkingmemory('SimulationSeed');
try
    SimulationSeed.Type = 'twister';
    SimulationSeed.Seed = SimulationSeed.Seed+1;
catch
    SimulationSeed.Type = 'twister';
    SimulationSeed.Seed = 0;
end
erpworkingmemory('SimulationSeed',SimulationSeed);
handles.SimulationSeed = SimulationSeed;
handles.SimulationPhase = SimulationPhase;

plotsimulationwave(hObject, eventdata, handles);
