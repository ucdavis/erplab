%%This function is to create simulated ERPset with single channel and bin

%Format:
% [ERP, erpcom] =  pop_ERP_simulation(ALLERP,BasFuncName,'EpochStart',EpochStart,'EpochStop',EpochStop,'Srate',Srate,'BasPeakAmp',...
%         BasPeakAmp,'MeanLatencyOnset',MeanLatOnset,'SDOffset',SDOffset,'ExGauTau',ExGauTau,'SinoiseAmp',SinoiseAmp,'SinoiseFre',SinoiseFre,...
%         'WhiteAmp',WhiteAmp,'PinkAmp',PinkAmp,'Saveas', 'off','History', 'gui');

% Inputs:
%
%ALLERP           - structure array of ERP structures (ERPsets)
%                 To read the ERPset from a list in a text file,
%                 replace ALLERP by the whole filename. If there is no
%                 ALLERP, please use [] instead.
%BasFuncName      -Name for basic function. We, here, provide three
%                  options, "Exgaussian", "Impulse", and "Boxcar".

%The available parameters are as follows:
%EpochStart       - epoch start in millisecond e.g., -200
%EpochStop        - epoch stop in millisecond e.g., 800
%Srate            - sampling rate. e.g., 1000Hz
%BasPeakAmp       - peak amplitude for basic function e.g., 1
%MeanLatencyOnset - gaussian mean for Ex-Guassian function, Latency for impulse
%                   function, and onset for boxcar
%SDOffset         - SD for Ex-Guassian function and off set for boxcar
%ExGauTau         -Exponential tau for ex-Gaussian function in ms
%SinoiseAmp       -Peak amplitude for sinusoidal function
%SinoiseFre       -Frequency for sinusoidal function
%WhiteAmp         -peak amplitude for white noise e.g., 1
%PinkAmp          -peak amplitude for pink noise e.g., 1
%NewnoiseFlag     -1. create a new seed for the random number generator
%                  0. Use the same seed as before

% Author: Guanghui Zhang & Steve J. Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Mar. 2023



function [ERP, erpcom] = pop_ERP_simulation(ALLERP,BasFuncName, varargin)
erpcom = [];
ERP = [];

if nargin < 1
    help pop_ERP_simulation
    return;
end

if nargin==1 || nargin==2 %with GUI to get other parameters
    if nargin==1
        BasFuncName = 'Exgaussian';
    end
    
    def   = erpworkingmemory('pop_ERP_simulation');
    if isempty(def)
        def  = {1,1,100,50,1000,-200,799,1,1000,0,1,0,1,0,1,10,0};
    end
    
    if isempty(BasFuncName) || ~ischar(BasFuncName)
        BasFunLabel = 1;
    else
        if strcmpi(BasFuncName,'Impulse')
            BasFunLabel = 2;
        elseif strcmpi(BasFuncName,'Boxcar')
            BasFunLabel = 3;
        else
            BasFunLabel = 1;
        end
    end
    def{1} = BasFunLabel;
    def = f_ERP_simulation_GUI(def,ALLERP);
    
    if isempty(def)
        disp('User selected Cancel')
        return
    end
    erpworkingmemory('pop_ERP_simulation',def);
    BasFunLabel = def{1};
    
    if BasFunLabel==2
        BasFuncName = 'Impulse';
    elseif  BasFunLabel==3
        BasFuncName = 'Boxcar';
    else
        BasFuncName = 'Exgaussian';
    end
    
    try
        BasPeakAmp = def{2};
    catch
        BasPeakAmp =1;
    end
    if isempty(BasPeakAmp)
        BasPeakAmp =1;
    end
    
    %%Mean/onset
    try
        MeanLatOnset =  def{3};
    catch
        MeanLatOnset =100;
    end
    if isempty(MeanLatOnset)
        MeanLatOnset =100;
    end
    
    %%SD/offset
    try
        SDOffset=  def{4};
    catch
        SDOffset =50;
    end
    if isempty(SDOffset)
        SDOffset =50;
    end
    
    %%ExGauTau
    try
        ExGauTau = def{5};
    catch
        ExGauTau =1;
    end
    if isempty(ExGauTau)
        ExGauTau =1;
    end
    
    %%epoch start
    try
        EpochStart =  def{6};
    catch
        EpochStart =  -200;
    end
    if isempty(EpochStart)
        EpochStart =  -200;
    end
    
    %%epoch stop
    try
        EpochStop =  def{7};
    catch
        EpochStop =  800;
    end
    if isempty(EpochStop)
        EpochStop =  800;
    end
    
    %%sampling rate
    try
        Srate =  def{9};
    catch
        Srate =  1000;
    end
    if isempty(Srate)
        Srate =  1000;
    end
    
    %%Amplitude for sin noise
    try
        SinoiseFlag = def{14};
    catch
        SinoiseFlag =0;
    end
    
    if SinoiseFlag==0
        SinoiseAmp = 0;
    else
        try
            SinoiseAmp =def{15};
        catch
            SinoiseAmp=1;
        end
    end
    
    try
        SinoiseFre = def{16};
    catch
        SinoiseFre =10;
    end
    
    %%white noise
    try
        whitenoiseFlag = def{10};
    catch
        whitenoiseFlag =0;
    end
    
    if whitenoiseFlag==0
        WhiteAmp =0;
    else
        try
            WhiteAmp =  def{11};
        catch
            WhiteAmp=1;
        end
    end
    
    %%pink noise
    try
        pinknoiseFlag = def{12};
    catch
        pinknoiseFlag =0;
    end
    if pinknoiseFlag==0
        PinkAmp =0;
    else
        try
            PinkAmp = def{13};
        catch
            PinkAmp=1;
        end
    end
    
    NewnoiseFlag = 0;
    try
        NewnoiseFlag = def{17};
    catch
    end
    
    [ERP, erpcom] =  pop_ERP_simulation(ALLERP,BasFuncName,'EpochStart',EpochStart,'EpochStop',EpochStop,'Srate',Srate,'BasPeakAmp',...
        BasPeakAmp,'MeanLatencyOnset',MeanLatOnset,'SDOffset',SDOffset,'ExGauTau',ExGauTau,'SinoiseAmp',SinoiseAmp,'SinoiseFre',SinoiseFre,...
        'WhiteAmp',WhiteAmp,'PinkAmp',PinkAmp,'NewnoiseFlag',NewnoiseFlag,'Saveas', 'on','History', 'gui');
    pause(0.1);
    return;
end



%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
p.addRequired('BasFuncName',@ischar);


% option(s)
p.addParamValue('EpochStart',[],@isnumeric);
p.addParamValue('EpochStop',[],@isnumeric);
p.addParamValue('Srate',[],@isnumeric);
p.addParamValue('BasPeakAmp', [],@isnumeric);
p.addParamValue('MeanLatencyOnset', [],@isnumeric);
p.addParamValue('SDOffset', [],@isnumeric);
p.addParamValue('ExGauTau', [],@isnumeric);

p.addParamValue('SinoiseAmp', [],@isnumeric);%%sinusoidal noise in Amplitude
p.addParamValue('SinoiseFre', [],@isnumeric);%%sinusoidal noise in Hz
p.addParamValue('WhiteAmp', [],@isnumeric);%%sinusoidal noise in Hz
p.addParamValue('PinkAmp', [],@isnumeric);%%sinusoidal noise in Hz
p.addParamValue('NewnoiseFlag', [],@isnumeric);

p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar);

% Parsing
p.parse(ALLERP,BasFuncName,varargin{:});

if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end

ImpluseFlag = '';
BoxCarFlag = '';
GaussianFlag = '';
qBasFuncName  = p.Results.BasFuncName;
if strcmpi(qBasFuncName,'Impulse')
    qBasFunLabel = 2;
    ImpluseFlag = 'on';
elseif strcmpi(qBasFuncName,'Boxcar')
    qBasFunLabel = 3;
    BoxCarFlag = 'on';
else
    qBasFunLabel = 1;
    GaussianFlag = 'on';
end

%%peak amplitude for basic function
qBasPeakAmp = p.Results.BasPeakAmp;
if isempty(qBasPeakAmp)
    qBasPeakAmp = 0;
else
    if numel(qBasPeakAmp)~=1
        qBasPeakAmp =qBasPeakAmp(1);
    end
end

%%Mean/latency/onset for basic function
qMeanLatOnset = p.Results.MeanLatencyOnset;
if isempty(qMeanLatOnset)
    qMeanLatOnset =100;
else
    if numel(qMeanLatOnset)~=1
        qMeanLatOnset = qMeanLatOnset(1);
    end
end


%%SD or offset for basic function
qSDOffset = p.Results.SDOffset;
if isempty(qSDOffset)
    qSDOffset=50;
else
    if numel(qSDOffset)~=1
        qSDOffset = qSDOffset(1);
    end
end

%%Tau for exGuassian
ExGauTau = p.Results.ExGauTau;
if isempty(ExGauTau)
    ExGauTau =0;
else
    if numel(ExGauTau)~=1
        ExGauTau = ExGauTau(1);
    end
end
ExGauTau  =ExGauTau/1000;

%%Epoch start
EpochStart = p.Results.EpochStart;
if isempty(EpochStart)
    EpochStart = -200;
else
    if numel(EpochStart)~=1
        EpochStart = EpochStart(1);
    end
end

%%Epoch Stop
EpochStop = p.Results.EpochStop;
if isempty(EpochStop)
    EpochStop = 799;
else
    if numel(EpochStop)~=1
        EpochStop = EpochStop(1);
    end
end


if EpochStop<=EpochStart
    msgboxText =  'Start time of epoch must be smaller than stop time of epoch!';
    title = 'ERPLAB: pop_ERP_simulation() error';
    errorfound(msgboxText, title);
    return;
end

if qMeanLatOnset< EpochStart
    msgboxText =  [' "MeanLatencyOnset" should be larger than',32,num2str(EpochStop),'ms'];
    title = 'ERPLAB: pop_ERP_simulation() error';
    errorfound(msgboxText, title);
    return;
end


if qMeanLatOnset >  EpochStop
    msgboxText =  [' "MeanLatencyOnset" should be smaller than',32,num2str(EpochStop),'ms'];
    title = 'ERPLAB: pop_ERP_simulation() error';
    errorfound(msgboxText, title);
    return;
end
if strcmpi(BasFuncName,'Exgaussian')
    if qSDOffset<=0
        msgboxText =  [' "SDOffset" for EX-Gaussian function should be a positive number.'];
        title = 'ERPLAB: pop_ERP_simulation() error';
        errorfound(msgboxText, title);
    end
end

if strcmpi(BasFuncName,'Boxcar')
    if qSDOffset >  EpochStop
        msgboxText =  [' "SDOffset" for Boxcar function should be smaller than',32,num2str(EpochStop),'ms'];
        title = 'ERPLAB: pop_ERP_simulation() error';
        errorfound(msgboxText, title);
        return;
    end
    
    if qMeanLatOnset>qSDOffset
        msgboxText =  [' "MeanLatencyOnset" for Boxcar function should be smaller than',32, num2str(qSDOffset),'ms'];
        title = 'ERPLAB: pop_ERP_simulation() error';
        errorfound(msgboxText, title);
        return;
    end
end



%%Sampling rate
Srate = p.Results.Srate;
if isempty(Srate)
    Srate = 1000;
else
    if numel(Srate)~=1
        Srate = Srate(1);
    end
end

if 1000/Srate>= (EpochStop-EpochStart)
    msgboxText =  ['Please sampling period must be much smaller than ',32,num2str(EpochStop-EpochStart)];
    title = 'ERPLAB: pop_ERP_simulation() error';
    errorfound(msgboxText, title);
    return;
end


Times = [];

if EpochStart>=0
    count =0;
    tIndex(1,1) =0;
    for ii = 1:10000
        count = count+1000/Srate;
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
        count = count-1000/Srate;
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
        count = count-1000/Srate;
        if count>=EpochStart
            tIndex1(1,ii+1) = count;
        else
            break;
        end
    end
    tIndex2=[];
    count1 =0;
    for ii = 1:10000
        count1 = count1+1000/Srate;
        if count1<=EpochStop
            tIndex2(1,ii) = count1;
        else
            break;
        end
    end
    Times = [sort(tIndex1),tIndex2];
end

[x1,y1]  = find(roundn(Times,-3)==roundn(EpochStart,-3));


[x2,y2]  = find(roundn(Times,-3)==roundn(EpochStop,-3));
if isempty(y1) || isempty(y2)
    msgboxText = 'Warning: The exact time periods you have specified cannot be exactly created with the specified sampling rate. We will round to the nearest possible time values when the ERPset is created.';
    title = 'ERPLAB: pop_ERP_simulation() error';
    errorfound(msgboxText, title);
    %     return;
end

%%Amplitude for basic function
qBasPeakAmp = p.Results.BasPeakAmp;

if isempty(qBasPeakAmp)
    qBasPeakAmp =0;
else
    if numel(qBasPeakAmp)~=1
        qBasPeakAmp = qBasPeakAmp(1);
    end
end


%%mean/latency/onset for basic function
qMeanLatencyOnset = p.Results.MeanLatencyOnset;
if isempty(qMeanLatencyOnset)
    qMeanLatencyOnset=100;
else
    if numel(qMeanLatencyOnset)~=1
        qMeanLatencyOnset =qMeanLatencyOnset(1);
    end
end


%%SD/offset for basic function
qSD_Offset = p.Results.SDOffset;
if isempty(qSD_Offset)
    qSD_Offset =50;
else
    if numel(qSD_Offset)~=1
        qSD_Offset =qSD_Offset(1);
    end
end

%%Tau for ex-Gaussian function
qExGauTau = p.Results.ExGauTau;
if isempty(qExGauTau)
    qExGauTau =1;
else
    if numel(qExGauTau)~=1
        qExGauTau = qExGauTau(1);
    end
end

%%Amplitude for sin noise
qSinoiseAmp = p.Results.SinoiseAmp;
if isempty(qSinoiseAmp)
    qSinoiseAmp =0;
else
    if numel(qSinoiseAmp)~=1
        qSinoiseAmp = qSinoiseAmp(1);
    end
end

qSinoiseFre  = p.Results.SinoiseFre;
if isempty(p.Results.SinoiseFre)
    qSinoiseFre =10;
else
    if numel(qSinoiseFre)~=1
        qSinoiseFre = qSinoiseFre(1);
    end
end


%%Amplitude for white noise
qWhiteAmp = p.Results.WhiteAmp;
if isempty(qWhiteAmp)
    qWhiteAmp =0;
else
    if numel(qWhiteAmp)~=1
        qWhiteAmp = qWhiteAmp(1);
    end
end


%%Amplitude for pink noise
qPinkAmp = p.Results.PinkAmp;
if isempty(qPinkAmp)
    qPinkAmp =0;
else
    if numel(qPinkAmp)~=1
        qPinkAmp =qPinkAmp(1);
    end
end


qNewnoiseFlag = p.Results.NewnoiseFlag;
if isempty(qNewnoiseFlag)
    qNewnoiseFlag =0;
end
if numel(qNewnoiseFlag)~=1
    qNewnoiseFlag = qNewnoiseFlag(1);
end
%%------------------------------the data for basic function----------------
Desiredsignal = zeros(1,numel(Times));
Desirednosizesin = zeros(1,numel(Times));
Desirednosizewhite = zeros(1,numel(Times));
Desirednosizepink = zeros(1,numel(Times));

if qBasFunLabel==1
    Gua_PDF = zeros(1,numel(Times));
    qSDOffset = qSDOffset/100;
    if ExGauTau~=0
        Mu =  qMeanLatOnset/100-Times(1)/100;
        if Mu<0
            Mu =  qMeanLatOnset/100;
        end
        if ExGauTau<0
            Mu = abs((Times(end)/100-Times(1)/100)-Mu);
        end
        LegthSig = (Times(end)-Times(1))/100;
        Sig = 0:LegthSig/numel(Times):LegthSig-LegthSig/numel(Times);
        Gua_PDF = f_exgauss_pdf(Sig, Mu, qSDOffset, abs(ExGauTau));
        if ExGauTau<0
            Gua_PDF = fliplr(Gua_PDF);
        end
    elseif ExGauTau==0 %%Gaussian signal
        Times_new = Times/1000;
        Gua_PDF = f_gaussian(Times_new,abs(qBasPeakAmp),qMeanLatOnset/1000,qSDOffset/10);
    end
    Max = max(abs( Gua_PDF(:)));
    Gua_PDF = qBasPeakAmp*Gua_PDF./Max;
    if qBasPeakAmp~=0
        Desiredsignal = Gua_PDF;
    end
elseif qBasFunLabel==2
    
    if qMeanLatOnset<Times(1)
        qMeanLatOnset=Times(1);
    end
    if qMeanLatOnset>Times(end)
        qMeanLatOnset=Times(end);
    end
    [xxx, latsamp, latdiffms] = closest(Times, qMeanLatOnset);
    Desiredsignal(latsamp) = qBasPeakAmp;
elseif qBasFunLabel==3
    if qMeanLatOnset> qSDOffset
        msgboxText =  'Please "offset" should be larger than "onset" of boxcar function!';
        title = 'ERPLAB: pop_ERP_simulation() error';
        errorfound(msgboxText, title);
        return;
    end
    [xxx, latsamp, latdiffms] = closest(Times, [qMeanLatOnset,qSDOffset]);
    Desiredsignal(latsamp(1):latsamp(2)) = qBasPeakAmp;
end

%%----------------------Noise----------------------------------------------
SimulationSeed = erpworkingmemory('SimulationSeed');
try
    SimulationSeed_Type = SimulationSeed.Type;
    SimulationSeed_seed=SimulationSeed.Seed;
catch
    SimulationSeed_Type = 'twister';
    SimulationSeed_seed = 1;
end
%phase for sin noise
SimulationPhase = erpworkingmemory('SimulationPhase');
if isempty(SimulationPhase) ||  ~isnumeric(SimulationPhase)
    SimulationPhase = 0;
end
if numel(SimulationPhase)~=1
    SimulationPhase = SimulationPhase(1);
end
if SimulationPhase<0 || SimulationPhase>1
    SimulationPhase = 0;
end

if qNewnoiseFlag==1
    %%reset the phase
    SimulationPhase = rand(1);
    
    %%reset the seed
    SimulationSeed_Type = 'twister';
    SimulationSeed_seed = SimulationSeed_seed+1;
end

%%sin Noise
X =  Times/1000;
Desirednosizesin = qSinoiseAmp*sin(2*qSinoiseFre*pi*X+2*pi*SimulationPhase);

%%white noise
try
    rng(SimulationSeed_seed,SimulationSeed_Type);
catch
    rng(0,'twister');
end
Desirednosizewhite =  randn(1,numel(Times));%%white noise
Desirednosizewhite = qWhiteAmp*Desirednosizewhite;

%%pink noise
try
    rng(SimulationSeed_seed,SimulationSeed_Type);
catch
    rng(0,'twister');
end

Desirednosizepink = f_pinknoise(numel(Times));
Desirednosizepink = reshape(Desirednosizepink,1,numel(Desirednosizepink));
Desirednosizepink = qPinkAmp*Desirednosizepink;

Sig = Desirednosizesin+Desiredsignal+Desirednosizepink+Desirednosizewhite;
ERPautx    = buildERPstruct([]);
ERPautx.bindata = zeros(1,numel(Times),1);
ERPautx.bindata(1,1:numel(Sig),1)=Sig;
ERPautx.bindescr{1} = 'Artificial ERP wave';
ERPautx.chanlocs(1).labels = 'Artificial ERP wave';

ERPautx.xmin = Times(1)/1000;
ERPautx.xmax = Times(end)/1000;
ERPautx.times = Times;
ERPautx.nchan = 1;
ERPautx.nbin = 1;
ERPautx.pnts = numel(Times);
ERPautx.erpname ='Cretedartificialwave';
ERPautx.srate = Srate;
ERPautx.saved  = 'no';
%%fixed by GH
ERPautx.ntrials.accepted = 1;
ERPautx.ntrials.rejected =0;
ERPautx.ntrials.invalid=0;
ERPautx.ntrials.arflags = zeros(1,8);
%
% History
%
%
% Completion statement
%
msg2end

% History command
%
fn = fieldnames(p.Results);

skipfields = {'ALLERP','BasFuncName'};

EpochStartstr = num2str(EpochStart);
EpochStopStr = num2str(EpochStop);
Sratestr = num2str(Srate);
% PLOTORGstr = vect2colon(qPLOTORG);
erpcom     = sprintf( 'ERP = pop_ERP_simulation( %s, %s','ALLERP',[char(39),BasFuncName,char(39)]);

if strcmpi(BoxCarFlag,'on')
    skipfields = {'ALLERP','BasFuncName','ExGauTau'};
end
if strcmpi(ImpluseFlag,'on')
    skipfields = {'ALLERP','BasFuncName','ExGauTau','SDOffset'};
end

def = erpworkingmemory('pop_ERP_simulation');
try
    SinoiseFlag = def{14};
catch
    SinoiseFlag =0;
end

try
    whitenoiseFlag = def{10};
catch
    whitenoiseFlag =0;
end

try
    pinknoiseFlag = def{12};
catch
    pinknoiseFlag =0;
end
if SinoiseFlag==0
    skipfields{length(skipfields)+1} ='SinoiseAmp';
    skipfields{length(skipfields)+1} ='SinoiseFre';
end
if whitenoiseFlag==0
    skipfields{length(skipfields)+1} = 'WhiteAmp';
end

if pinknoiseFlag==0
    skipfields{length(skipfields)+1} = 'PinkAmp';
end

if pinknoiseFlag==0
    skipfields{length(skipfields)+1} = 'NewnoiseFlag';
end

for q=1:length(fn)
    fn2com = fn{q}; % inputname
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com); %  input value
        if ~isempty(fn2res)
            if isnumeric(fn2res)
                erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
            else
                %                 if ~ismember_bc2(fn2com,{'xscale','yscale'})
                %                     erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                %                 else
                %                     xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                %                     erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, xyscalestr);
                %                 end
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);


if strcmpi(p.Results.Saveas,'on')
    issaveas = 1;
else
    issaveas = 0;
end
%
% Save ERPset from GUI
%
if issaveas
    [ERP, issave, erpcom_save] = pop_savemyerp(ERPautx,'gui','erplab', 'History', 'off');
    if issave>0
        %                 erpcom = sprintf( '%s = pop_filterp( %s, %s, %s, %s, %s, ''%s'', %s);', inputname(1), inputname(1),...
        %                         chanArraystr, num2str(locutoff), num2str(hicutoff),...
        %                         num2str(filterorder), lower(fdesign), num2str(remove_dc));
        %                 erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
        if issave==2
            erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your ERPset was saved on your hard drive.***';
            %mcolor = [0 0 1];
        else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
            %mcolor = [1 0.52 0.2];
        end
    else
        ERP = ERPautx;
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
        %mcolor = [1 0.22 0.2];
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
else
    ERP = ERPautx;
end


% get history from script. ERP
% shist = 1;
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        ERP = erphistory(ERP, [], erpcom, 1);
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
end


end