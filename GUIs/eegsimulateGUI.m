function varargout = eegsimulateGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @eegsimulateGUI_OpeningFcn, ...
        'gui_OutputFcn',  @eegsimulateGUI_OutputFcn, ...
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


% --- Executes just before eegsimulateGUI is made visible.
function eegsimulateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

try
        def = varargin{1};
catch
%     if isempty(nprechebychev || npostchebychev || chebychevwin || chebyfreq || chebyphase)
        def = {'none', 'none', [],[],[], [], [], [], [], [], [],[], [], [], [], [], [], 'simulatedeeg', 1000, 1000, 10, 100, [], []};
%     else
%         def = {'none', 'none', [],[],[], [], [], [], [], [], [],[], nprechebychev, npostchebychev, chebychevwin,...
%             chebyfreq, chebyphase, 'simulatedeeg', 1000, 1000, 10, 100, []};
%     end
end

trendtype       = def{1};      %type of trend that you want to do (sin, cos, linear, dcoffset, squarefit, perfsquare)
evoketype       = def{2};      %type of evoked activity to insert (squarefit, perfsquare, erplike)
chanArray1      = def{3};      %channel(s) to be trended
chanArray2      = def{4};      %channel(s) to be trended
sinamp          = def{5};      %amplitude of sin and cos wave created
sinfreq         = def{6};      %frequency multiplier of sin and cos wave
rwpvalueArray   = def{7};
dcoffset        = def{8};      %amount of vertical shift
linslope        = def{9};      %slope for linear trend, small = gradual, large = steap
onsetArray      = def{10};     %time for square plot to start at in sec
amplitudeArray  = def{11};     %amplitude of square plot
squaredur       = def{12};     %duration in ms
nprechebychev   = def{13};     %ms of zeroes before chebychev window
npostchebychev  = def{14};     %ms of zeroes after chebychev window
chebychevwin    = def{15};     %length chebychev window in ms
chebyfreq       = def{16};
chebyphase      = def{17};     %*
eegtype         = def{18};
simduration     = def{19};
simsrate        = def{20};
simnchan        = def{21};
simeegamp       = def{22};
type2insert     = def{23};
onseterrorval   = def{24};

try
        eeginfo   = varargin{2};
        setname   = eeginfo{1};
        fs        = eeginfo{2};
        nbchan    = eeginfo{3};
        pnts      = eeginfo{4};
        chanlocs  = eeginfo{5};
        isepoched = eeginfo{6};
catch
        setname     = [];
        fs          = 1000;
        nbchan      = [];
        pnts        = [];
        chanlocs    = [];
        isepoched   = 1;
end

nchan4label = [];
snrfontsize = 16;
handles.trendtype       = trendtype;                    %type of trend that you want to do (sin, cos, linear, vertical, squarefit, perfsquare)
handles.evoketype       = evoketype;
handles.sinamp          = sinamp;                          %amplitude of sin and cos wave created
handles.sinfreq         = sinfreq;                         %frequency multiplier of sin and cos wave
handles.rwpvalueArray   = rwpvalueArray;
handles.chanArray1      = chanArray1;                         %channel(s) to be trended
handles.chanArray2      = chanArray2;                         %channel(s) to be trended
handles.dcoffset        = dcoffset;                    %amount of vertical shift
handles.linslope        = linslope;                     %slope for linear trend, small = gradual, large = steap
handles.onsetArray      = onsetArray;      %time for square plot to start at in sec
handles.amplitudeArray  = amplitudeArray; 
handles.squaredur       = squaredur;                     %duration in ms
handles.nprechebychev   = nprechebychev;                %ms of zeroes before chebychev window
handles.npostchebychev  = npostchebychev;               %ms of zeroes after chebychev window
handles.chebychevwin    = chebychevwin;                 %length chebychev window in ms
handles.chebyfreq       = chebyfreq;
handles.chebyphase      = chebyphase;
handles.eegtype         = eegtype;
handles.simduration     = simduration;
handles.simsrate        = simsrate;
handles.simnchan        = simnchan;
handles.simeegamp       = simeegamp;
handles.fs              = fs;
handles.type2insert     = type2insert;
handles.snrfontsize     = snrfontsize; % font size for SNR 
handles.nbchan          = nbchan;
handles.pnts            = pnts;
handles.chanlocs        = chanlocs;
handles.onseterrorval   = onseterrorval; 

if strcmp(eegtype,'simulatedeeg') || isempty(setname) || isepoched
        set(handles.radiobutton_simeeg, 'Value', 1)
        set(handles.edit_numsimch, 'String', num2str(simnchan))
        set(handles.edit_dursimeeg, 'String', num2str(simduration))
        set(handles.edit_simeegsrate, 'String', num2str(simsrate))
        set(handles.edit_EEGamp, 'String', num2str(simeegamp))
        
        if ~strcmpi(evoketype, 'none')
                if ~isempty(simeegamp) && ~isempty(amplitudeArray)
                        snr = mean(amplitudeArray)/simeegamp;
                        snrstr = sprintf('SNR = %.2f', snr);
                        set(handles.text_SNR, 'String', snrstr)
                        set(handles.text_SNR, 'FontSize', snrfontsize)
                end
        end
        if isepoched
                set(handles.radiobutton_usecurrenteeg, 'Enable', 'off');
        end
        if ~isempty(simnchan)
                chanArray1  = chanArray1(chanArray1<=simnchan);
                chanArray2  = chanArray2(chanArray2<=simnchan);
                nchan4label = simnchan;
        end
else
        set(handles.radiobutton_usecurrenteeg, 'Value', 1);
        set(handles.radiobutton_usecurrenteeg, 'String', sprintf('Use current dataset : %s', setname));
        set(handles.edit_dursimeeg, 'Enable', 'off');
        set(handles.edit_numsimch, 'Enable', 'off');
        set(handles.edit_simeegsrate, 'Enable', 'off');
        set(handles.edit_EEGamp, 'Enable', 'off');
        if ~isempty(nbchan)
                chanArray1  = chanArray1(chanArray1<=nbchan);
                chanArray2  = chanArray2(chanArray2<=nbchan);
                nchan4label = length(chanlocs);
        end
end

%
% Prepare List of current Channels
%
if isempty(chanlocs)
        for e = 1:nchan4label
                chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
listch = {''};
for ch =1:nchan4label
        listch{ch} = [num2str(ch) ' = ' chanlocs(ch).labels ];
end

handles.listch     = listch;
handles.indxlistch = chanArray1; % channel array

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


switch trendtype
        case 'sin'
                set(handles.radiobutton_sinwave, 'Value', 1)
                set(handles.edit_tdcoffset, 'Enable', 'off');
                set(handles.edit_linslope, 'Enable', 'off');
                set(handles.edit_channels2trend, 'String', vect2colon(chanArray1, 'Delimiter', 'off'));                 
                set(handles.edit_ampsin, 'String', num2str(sinamp));
                set(handles.edit_freqsin, 'String', num2str(sinfreq));                
                set(handles.edit_rwpvalues, 'Enable', 'off') 
        case 'rwalk'
                set(handles.radiobutton_randomwalk, 'Value', 1)
                set(handles.edit_ampsin, 'Enable', 'off');
                set(handles.edit_freqsin, 'Enable', 'off');
                set(handles.edit_tdcoffset, 'Enable', 'off');
                set(handles.edit_linslope, 'Enable', 'off');
                set(handles.edit_channels2trend, 'String', vect2colon(chanArray1, 'Delimiter', 'off')); 
                set(handles.edit_rwpvalues, 'String', vect2colon(rwpvalueArray, 'Delimiter', 'off')); 
        case 'linear'
                set(handles.radiobutton_linear, 'Value', 1)
                set(handles.edit_ampsin, 'Enable', 'off');
                set(handles.edit_freqsin, 'Enable', 'off');
                set(handles.edit_tdcoffset, 'Enable', 'off');
                set(handles.edit_channels2trend, 'String', vect2colon(chanArray1, 'Delimiter', 'off'));                 
                set(handles.edit_linslope, 'String', num2str(linslope));                
                set(handles.edit_rwpvalues, 'Enable', 'off') 
        case 'dcoffset'
                set(handles.radiobutton_tdcoffset, 'Value', 1)
                set(handles.edit_ampsin, 'Enable', 'off');
                set(handles.edit_freqsin, 'Enable', 'off');
                set(handles.edit_linslope, 'Enable', 'off');
                set(handles.edit_channels2trend, 'String', vect2colon(chanArray1, 'Delimiter', 'off'));
                set(handles.edit_tdcoffset, 'String', num2str(dcoffset));                
                set(handles.edit_rwpvalues, 'Enable', 'off')
        otherwise
                set(handles.radiobutton_nonetrend, 'Value', 1)
                set(handles.edit_ampsin, 'Enable', 'off');
                set(handles.edit_freqsin, 'Enable', 'off');
                set(handles.edit_tdcoffset, 'Enable', 'off');
                set(handles.edit_linslope, 'Enable', 'off');    
                set(handles.edit_channels2trend, 'String', '');  
                set(handles.edit_channels2trend, 'Enable', 'off');
                set(handles.edit_rwpvalues, 'Enable', 'off') 
end
switch evoketype
        case 'squarefit'
                set(handles.radiobutton_square, 'Value', 1)
                set(handles.edit_chebychev1, 'Enable', 'off');
                set(handles.edit_chebychev2, 'Enable', 'off');
                set(handles.edit_chebywin, 'Enable', 'off');
                %set(handles.edit_amparray, 'Enable', 'off');
                set(handles.edit_chebyfreq, 'Enable', 'off');
                set(handles.edit_chebyphase, 'Enable', 'off');
                %set(handles.edit_onsetarray, 'Enable', 'off');
                set(handles.edit_channels2evoke, 'String', vect2colon(chanArray2, 'Delimiter', 'off'));
                set(handles.edit_type2insert, 'Enable', 'on');
                set(handles.edit_amparray, 'String', vect2colon(amplitudeArray, 'Delimiter', 'off'));
                set(handles.edit_onsetarray, 'String', vect2colon(onsetArray, 'Delimiter', 'off'));
                set(handles.edit_type2insert, 'String', vect2colon(type2insert, 'Delimiter', 'off'));
                set(handles.edit_onseterrorval, 'Enable', 'off');
                set(handles.edit_onseterrorval, 'String', vect2colon(onseterrorval, 'Delimiter', 'off'));
                   
                set(handles.axes1, 'Visible', 'on')
        case 'perfsquare'
                set(handles.checkbox_perfsquare, 'Value', 1)
                set(handles.edit_chebychev1, 'Enable', 'off');
                set(handles.edit_chebychev2, 'Enable', 'off');
                set(handles.edit_chebywin, 'Enable', 'off');
                %set(handles.edit_amparray, 'Enable', 'off');
                set(handles.edit_chebyfreq, 'Enable', 'off');
                set(handles.edit_chebyphase, 'Enable', 'off');
                %set(handles.edit_onsetarray, 'Enable', 'off');
                set(handles.edit_channels2evoke, 'String', vect2colon(chanArray2, 'Delimiter', 'off'));
                set(handles.edit_type2insert, 'Enable', 'on');
                set(handles.edit_amparray, 'String', vect2colon(amplitudeArray, 'Delimiter', 'off'));
                set(handles.edit_onsetarray, 'String', vect2colon(onsetArray, 'Delimiter', 'off'));
                set(handles.edit_type2insert, 'String', vect2colon(type2insert, 'Delimiter', 'off'));
                set(handles.edit_onseterrorval, 'Enable', 'off');
                set(handles.edit_onseterrorval, 'String', vect2colon(onseterrorval, 'Delimiter', 'off'));
                   
                set(handles.axes1, 'Visible', 'on')
        case 'erplike'
                set(handles.radiobutton_erplike, 'Value', 1)
                %set(handles.edit_sqonset, 'Enable', 'off');
                set(handles.edit_sqduration, 'Enable', 'off');
                %set(handles.edit_sqamp, 'Enable', 'off');
                set(handles.edit_channels2evoke, 'String', vect2colon(chanArray2, 'Delimiter', 'off'));
                set(handles.axes1, 'Visible', 'on')
                set(handles.edit_chebychev1,'String', num2str(nprechebychev))
                set(handles.edit_chebychev2,'String', num2str(npostchebychev))
                set(handles.edit_chebywin,'String', num2str(chebychevwin))
                set(handles.edit_chebyfreq,'String', num2str(chebyfreq))
                set(handles.edit_chebyphase, 'String', chebyphase);
                set(handles.edit_type2insert, 'Enable', 'on');
                set(handles.edit_onseterrorval, 'Enable', 'on');                   
                set(handles.edit_amparray, 'String', vect2colon(amplitudeArray, 'Delimiter', 'off'));
                set(handles.edit_onsetarray, 'String', vect2colon(onsetArray, 'Delimiter', 'off'));
                set(handles.edit_type2insert, 'String', vect2colon(type2insert, 'Delimiter', 'off'));
                
                updateviewer_Callback(hObject, eventdata, handles)
        otherwise
                set(handles.radiobutton_noneERP, 'Value', 1)
                %set(handles.edit_sqonset, 'Enable', 'off');
                set(handles.edit_sqduration, 'Enable', 'off');
                %set(handles.edit_sqamp, 'Enable', 'off');
                set(handles.edit_chebychev1, 'Enable', 'off');
                set(handles.edit_chebychev2, 'Enable', 'off');
                set(handles.edit_chebywin, 'Enable', 'off');
                %set(handles.edit_amparray, 'Enable', 'off');
                set(handles.edit_chebyfreq, 'Enable', 'off');
                set(handles.edit_chebyphase, 'Enable', 'off');
                %set(handles.edit_onsetarray, 'Enable', 'off');
                set(handles.edit_channels2evoke, 'Enable', 'off');
                set(handles.edit_amparray, 'Enable', 'off');
                set(handles.edit_onsetarray, 'Enable', 'off');
                set(handles.checkbox_perfsquare, 'Enable', 'off');
                set(handles.edit_type2insert, 'Enable', 'off');
                set(handles.edit_onseterrorval, 'Enable', 'off');                   
                set(handles.axes1, 'Visible', 'off')
end

%mimic the actual function, so will disable edit_ampsin
% set(handles.edit_channels2trend, 'Enable', 'on');

% UIWAIT makes eegsimulateGUI wait for user response (see UIRESUME)
uiwait(handles.gui_chassis);


%--------------------------------------------------------------------------------------
function varargout = eegsimulateGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.gui_chassis);
pause(0.1);

%--------------------------------------------------------------------------------------
function pushbutton_cancel_Callback(hObject, eventdata, handles)

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

%--------------------------------------------------------------------------------------
function radiobutton_nonetrend_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_sinwave, 'value', 0);
        set(handles.radiobutton_randomwalk, 'value', 0);
        set(handles.radiobutton_tdcoffset, 'value', 0);
        set(handles.radiobutton_linear, 'value', 0);
        set(handles.edit_channels2trend, 'String', '');
        set(handles.edit_ampsin, 'enable', 'off');
        set(handles.edit_ampsin, 'String', 0);
        set(handles.edit_freqsin, 'enable', 'off');
        set(handles.edit_freqsin, 'String', 0);
        set(handles.edit_tdcoffset, 'enable', 'off');
        set(handles.edit_tdcoffset, 'String', 0);
        set(handles.edit_linslope, 'enable', 'off');
        set(handles.edit_linslope, 'String', 0);
        set(handles.edit_channels2trend, 'enable', 'off');
        set(handles.edit_rwpvalues, 'Enable', 'off') 
        %set(handles.edit_sqonset, 'enable', 'on');
        %set(handles.edit_sqduration, 'enable', 'on');
        %set(handles.edit_sqamp, 'enable', 'on');
        %set(handles.edit_chebychev1, 'enable', 'off');
        %set(handles.edit_chebychev2, 'enable', 'off');
        %set(handles.edit_chebychev1, 'String', 0);
        %set(handles.edit_chebychev2, 'String', 0);
        %set(handles.edit_chebywin, 'enable', 'off');
        %set(handles.edit_chebywin, 'String', 0);
        %set(handles.edit_onsetarray, 'enable', 'off');
        %set(handles.edit_onsetarray, 'String', 0);
        %set(handles.edit_chebyfreq, 'enable', 'off');
        %set(handles.edit_chebyfreq, 'String', 0);
        %set(handles.edit_amparray, 'enable', 'off');
        %set(handles.edit_amparray, 'String', 0);
else
        %force user to click something else
        set(hObject, 'value', 1)
end


%--------------------------------------------------------------------------------------
function radiobutton_sinwave_Callback(hObject, eventdata, handles)
if get(hObject, 'value')        
        set(handles.radiobutton_nonetrend, 'value', 0);
        set(handles.radiobutton_randomwalk, 'value', 0);
        set(handles.radiobutton_tdcoffset, 'value', 0);
        set(handles.radiobutton_linear, 'value', 0);
        %set(handles.radiobutton_square, 'value', 0);
        %set(handles.checkbox_perfsquare, 'value', 0);
        %set(handles.radiobutton_erplike, 'value', 0);
        set(handles.edit_tdcoffset, 'enable', 'off');
        set(handles.edit_tdcoffset, 'String', 0);
        set(handles.edit_linslope, 'enable', 'off');
        set(handles.edit_linslope, 'String', 0);
        %set(handles.edit_sqonset, 'enable', 'off');
        %set(handles.edit_sqonset, 'String', 0);
        %set(handles.edit_sqduration, 'enable', 'off');
        %set(handles.edit_sqduration, 'String', 0);
        %set(handles.edit_sqamp, 'enable', 'off');
        %set(handles.edit_sqamp, 'String', 0);
        set(handles.edit_ampsin, 'enable', 'on');
        set(handles.edit_freqsin, 'enable', 'on');
        set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_rwpvalues, 'Enable', 'off') 
        %set(handles.edit_chebychev1, 'enable', 'off');
        %set(handles.edit_chebychev2, 'enable', 'off');
        %set(handles.edit_chebychev1, 'String', 0);
        %set(handles.edit_chebychev2, 'String', 0);
        %set(handles.edit_chebywin, 'enable', 'off');
        %set(handles.edit_chebywin, 'String', 0);
        %set(handles.edit_onsetarray, 'enable', 'off');
        %set(handles.edit_onsetarray, 'String', 0);
        %set(handles.edit_chebyfreq, 'enable', 'off');
        %set(handles.edit_chebyfreq, 'String', 0);
        %set(handles.edit_amparray, 'enable', 'off');
        %set(handles.edit_amparray, 'String', 0);
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_randomwalk_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_nonetrend, 'value', 0);
        set(handles.radiobutton_sinwave, 'value', 0);
        set(handles.radiobutton_tdcoffset, 'value', 0);
        set(handles.radiobutton_linear, 'value', 0);
        %set(handles.radiobutton_square, 'value', 0);
        %set(handles.checkbox_perfsquare, 'value', 0);
        %set(handles.radiobutton_erplike, 'value', 0);
        
        set(handles.edit_ampsin, 'Enable', 'off');
        set(handles.edit_freqsin, 'Enable', 'off');
        set(handles.edit_tdcoffset, 'Enable', 'off');
        set(handles.edit_linslope, 'Enable', 'off');
        
        
        set(handles.edit_tdcoffset, 'enable', 'off');
        set(handles.edit_tdcoffset, 'String', 0);
        set(handles.edit_linslope, 'enable', 'off');
        set(handles.edit_linslope, 'String', 0);
        set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_rwpvalues, 'Enable', 'on') 
        %set(handles.edit_sqonset, 'enable', 'off');
        %set(handles.edit_sqonset, 'String', 0);
        %set(handles.edit_sqduration, 'enable', 'off');
        %set(handles.edit_sqduration, 'String', 0);
        %set(handles.edit_sqamp, 'enable', 'off');
        %set(handles.edit_sqamp, 'String', 0);
        % %         set(handles.edit_ampsin, 'enable', 'on');
        % %         set(handles.edit_freqsin, 'enable', 'on');
        % %         set(handles.edit_channels2trend, 'enable', 'on');
        %set(handles.edit_chebychev1, 'enable', 'off');
        %set(handles.edit_chebychev2, 'enable', 'off');
        %set(handles.edit_chebychev1, 'String', 0);
        %set(handles.edit_chebychev2, 'String', 0);
        %set(handles.edit_chebywin, 'enable', 'off');
        %set(handles.edit_chebywin, 'String', 0);
        %set(handles.edit_onsetarray, 'enable', 'off');
        %set(handles.edit_onsetarray, 'String', 0);
        %set(handles.edit_chebyfreq, 'enable', 'off');
        %set(handles.edit_chebyfreq, 'String', 0);
        %set(handles.edit_amparray, 'enable', 'off');
        %set(handles.edit_amparray, 'String', 0);
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_tdcoffset_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_nonetrend, 'value', 0);
        set(handles.radiobutton_sinwave, 'value', 0);
        set(handles.radiobutton_randomwalk, 'value', 0);
        set(handles.radiobutton_linear, 'value', 0);
        %set(handles.radiobutton_square, 'value', 0);
        %set(handles.checkbox_perfsquare, 'value', 0);
        %set(handles.radiobutton_erplike, 'value', 0);
        set(handles.edit_ampsin, 'enable', 'off');
        set(handles.edit_ampsin, 'String', 0);
        set(handles.edit_freqsin, 'enable', 'off');
        set(handles.edit_freqsin, 'String', 0);
        set(handles.edit_linslope, 'enable', 'off');
        set(handles.edit_linslope, 'String', 0);
        %set(handles.edit_sqonset, 'enable', 'off');
        %set(handles.edit_sqonset, 'String', 0);
        %set(handles.edit_sqduration, 'enable', 'off');
        %set(handles.edit_sqduration, 'String', 0);
        %set(handles.edit_sqamp, 'enable', 'off');
        %set(handles.edit_sqamp, 'String', 0);
        set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_tdcoffset, 'enable', 'on');
        set(handles.edit_rwpvalues, 'Enable', 'off'); 
        %set(handles.edit_chebychev1, 'enable', 'off');
        %set(handles.edit_chebychev2, 'enable', 'off');
        %set(handles.edit_chebychev1, 'String', 0);
        %set(handles.edit_chebychev2, 'String', 0);
        %set(handles.edit_chebywin, 'enable', 'off');
        %set(handles.edit_chebywin, 'String', 0);
        %set(handles.edit_onsetarray, 'enable', 'off');
        %set(handles.edit_onsetarray, 'String', 0);
        %set(handles.edit_chebyfreq, 'enable', 'off');
        %set(handles.edit_chebyfreq, 'String', 0);
        %set(handles.edit_amparray, 'enable', 'off');
        %set(handles.edit_amparray, 'String', 0);
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_linear_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_nonetrend, 'value', 0);
        set(handles.radiobutton_sinwave, 'value', 0);
        set(handles.radiobutton_randomwalk, 'value', 0);
        set(handles.radiobutton_tdcoffset, 'value', 0);
        %set(handles.radiobutton_square, 'value', 0);
        %set(handles.checkbox_perfsquare, 'value', 0);
        %set(handles.radiobutton_erplike, 'value', 0);
        set(handles.edit_ampsin, 'enable', 'off');
        set(handles.edit_ampsin, 'String', 0);
        set(handles.edit_freqsin, 'enable', 'off');
        set(handles.edit_freqsin, 'String', 0);
        set(handles.edit_tdcoffset, 'enable', 'off');
        set(handles.edit_tdcoffset, 'String', 0);
        %set(handles.edit_sqonset, 'enable', 'off');
        %set(handles.edit_sqonset, 'String', 0);
        %set(handles.edit_sqduration, 'enable', 'off');
        %set(handles.edit_sqduration, 'String', 0);
        %set(handles.edit_sqamp, 'enable', 'off');
        %set(handles.edit_sqamp, 'String', 0);
        set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_linslope, 'enable', 'on');
        set(handles.edit_rwpvalues, 'Enable', 'off') 
        %set(handles.edit_chebychev1, 'enable', 'off');
        %set(handles.edit_chebychev2, 'enable', 'off');
        %set(handles.edit_chebychev1, 'String', 0);
        %set(handles.edit_chebychev2, 'String', 0);
        %set(handles.edit_chebywin, 'enable', 'off');
        %set(handles.edit_chebywin, 'String', 0);
        %set(handles.edit_onsetarray, 'enable', 'off');
        %set(handles.edit_onsetarray, 'String', 0);
        %set(handles.edit_chebyfreq, 'enable', 'off');
        %set(handles.edit_chebyfreq, 'String', 0);
        %set(handles.edit_amparray, 'enable', 'off');
        %set(handles.edit_amparray, 'String', 0);
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_noneERP_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_square, 'value', 0);
        set(handles.checkbox_perfsquare, 'value', 0);
        set(handles.checkbox_perfsquare, 'Enable', 'off');
        set(handles.radiobutton_erplike, 'value', 0);
        set(handles.edit_onseterrorval, 'Enable', 'off');
        set(handles.edit_onseterrorval, 'Value', 0);
                   
        %set(handles.radiobutton_sinwave, 'value', 0);
        %set(handles.radiobutton_randomwalk, 'value', 0);
        %set(handles.radiobutton_tdcoffset, 'value', 0);
        %set(handles.radiobutton_linear, 'value', 0);
        %set(handles.radiobutton_square, 'value', 0);
        %set(handles.checkbox_perfsquare, 'value', 0);
        %set(handles.radiobutton_erplike, 'value', 0);
        %set(handles.edit_tdcoffset, 'enable', 'off');
        %set(handles.edit_tdcoffset, 'String', 0);
        %set(handles.edit_linslope, 'enable', 'off');
        %set(handles.edit_linslope, 'String', 0);
        set(handles.edit_channels2evoke, 'enable', 'off');        
        %set(handles.edit_sqonset, 'enable', 'off');
        %set(handles.edit_sqonset, 'String', 0);
        set(handles.edit_sqduration, 'enable', 'off');
%         set(handles.edit_sqduration, 'String', '');
        %set(handles.edit_sqamp, 'enable', 'off');
        %set(handles.edit_sqamp, 'String', 0);
        %set(handles.edit_ampsin, 'enable', 'on');
        %set(handles.edit_freqsin, 'enable', 'on');
        %set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_chebychev1, 'enable', 'off');
        set(handles.edit_chebychev2, 'enable', 'off');
%         set(handles.edit_chebychev1, 'String', '');
%         set(handles.edit_chebychev2, 'String', '');
        set(handles.edit_chebywin, 'enable', 'off');
%         set(handles.edit_chebywin, 'String', '');
        set(handles.edit_onsetarray, 'enable', 'off');
%         set(handles.edit_onsetarray, 'String', '');
        set(handles.edit_chebyfreq, 'enable', 'off');
%         set(handles.edit_chebyfreq, 'String', '');
        set(handles.edit_chebyphase, 'enable', 'off');
        set(handles.edit_amparray, 'enable', 'off');
%         set(handles.edit_amparray, 'String', '');
%         set(handles.edit_type2insert, 'String', '');
        set(handles.edit_type2insert, 'Enable', 'off');
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_square_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        %set(handles.radiobutton_sinwave, 'value', 0);
        %set(handles.radiobutton_randomwalk, 'value', 0);
        %set(handles.radiobutton_tdcoffset, 'value', 0);
        %set(handles.radiobutton_linear, 'value', 0);
        set(handles.radiobutton_noneERP, 'value', 0);        
        set(handles.checkbox_perfsquare, 'value', 0);
        set(handles.checkbox_perfsquare, 'Enable', 'on');
        set(handles.radiobutton_erplike, 'value', 0);
        set(handles.edit_onseterrorval, 'Enable', 'off');
        set(handles.edit_onseterrorval, 'Value', 0);
        %set(handles.edit_ampsin, 'enable', 'off');
        %set(handles.edit_ampsin, 'String', 0);
        %set(handles.edit_freqsin, 'enable', 'off');
        %set(handles.edit_freqsin, 'String', 0);
        %set(handles.edit_tdcoffset, 'enable', 'off');
        %set(handles.edit_tdcoffset, 'String', 0);
        %set(handles.edit_linslope, 'enable', 'off');
        %set(handles.edit_linslope, 'String', 0);
        %set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_channels2evoke, 'enable', 'on');
        %set(handles.edit_sqonset, 'enable', 'on');
        set(handles.edit_sqduration, 'enable', 'on');
        %set(handles.edit_sqamp, 'enable', 'on');
        set(handles.edit_chebychev1, 'enable', 'off');
        set(handles.edit_chebychev2, 'enable', 'off');
%         set(handles.edit_chebychev1, 'String', '');
%         set(handles.edit_chebychev2, 'String', '');
        set(handles.edit_chebywin, 'enable', 'off');
%         set(handles.edit_chebywin, 'String', '');
        set(handles.edit_onsetarray, 'enable', 'on');
        %set(handles.edit_onsetarray, 'String', '');
        set(handles.edit_chebyfreq, 'enable', 'off');
        set(handles.edit_chebyphase, 'enable', 'off');
%         set(handles.edit_chebyfreq, 'String', '');
        set(handles.edit_amparray, 'enable', 'on');
        %set(handles.edit_amparray, 'String', '');
        set(handles.edit_type2insert, 'Enable', 'on');
        
        updateviewer_Callback(hObject, eventdata, handles)
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function checkbox_perfsquare_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function radiobutton_erplike_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        %set(handles.radiobutton_sinwave, 'value', 0);
        %set(handles.radiobutton_randomwalk, 'value', 0);
        %set(handles.radiobutton_tdcoffset, 'value', 0);
        %set(handles.radiobutton_linear, 'value', 0);
        set(handles.radiobutton_noneERP, 'value', 0);
        set(handles.radiobutton_square, 'value', 0);
        set(handles.checkbox_perfsquare, 'value', 0);
        set(handles.checkbox_perfsquare, 'Enable', 'off');
        set(handles.edit_onseterrorval, 'Enable', 'on');
        %set(handles.edit_ampsin, 'enable', 'off');
        %set(handles.edit_ampsin, 'String', 0);
        %set(handles.edit_freqsin, 'enable', 'off');
        %set(handles.edit_freqsin, 'String', 0);
        %set(handles.edit_tdcoffset, 'enable', 'off');
        %set(handles.edit_tdcoffset, 'String', 0);
        %set(handles.edit_linslope, 'enable', 'off');
        %set(handles.edit_linslope, 'String', 0);
        %set(handles.edit_channels2trend, 'enable', 'on');
        set(handles.edit_channels2evoke, 'enable', 'on');
        %set(handles.edit_sqonset, 'enable', 'off');
        %set(handles.edit_sqonset, 'String', 0);
        set(handles.edit_sqduration, 'enable', 'off');
        %set(handles.edit_sqamp, 'enable', 'off');
        %set(handles.edit_sqamp, 'String', 0);
        set(handles.edit_chebychev1, 'enable', 'on');
        set(handles.edit_chebychev2, 'enable', 'on');
        set(handles.edit_chebywin, 'enable', 'on');
        set(handles.edit_onsetarray, 'enable', 'on');
        set(handles.edit_chebyfreq, 'enable', 'on');
        set(handles.edit_chebyphase, 'enable', 'on');        
        set(handles.edit_amparray, 'enable', 'on');
        set(handles.edit_type2insert, 'Enable', 'on');
        
        updateviewer_Callback(hObject, eventdata, handles)
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_usecurrenteeg_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_simeeg, 'value', 0);
        set(handles.edit_dursimeeg, 'enable', 'off');
        set(handles.edit_simeegsrate, 'enable', 'off');
        set(handles.edit_numsimch, 'enable', 'off');
        set(handles.edit_EEGamp, 'Enable', 'off');
        
        %
        % Prepare List of current Channels
        %
        chanlocs = handles.chanlocs;
        if isempty(chanlocs)
                nbchan = handles.nbchan;
                for e = 1:nbchan
                        chanlocs(e).labels = ['Ch' num2str(e)];
                end
        end
        listch = {''};
        for ch =1:length(chanlocs)
                listch{ch} = [num2str(ch) ' = ' chanlocs(ch).labels ];
        end
        
        handles.listch     = listch;
        handles.indxlistch = 1; % channel array
        
        %Update handles structure
        guidata(hObject, handles);
else
        %force user to click something else
        set(hObject, 'value', 1)
end

%--------------------------------------------------------------------------------------
function radiobutton_simeeg_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
        set(handles.radiobutton_usecurrenteeg, 'value', 0);
        set(handles.edit_dursimeeg, 'enable', 'on');
        set(handles.edit_simeegsrate, 'enable', 'on');
        set(handles.edit_numsimch, 'enable', 'on');
        set(handles.edit_EEGamp, 'Enable', 'on');
        
        %
        % Prepare List of current Channels
        %
        nchan4label = str2num(get(handles.edit_numsimch, 'String'));
        if ~isempty(nchan4label)
                for e = 1:nchan4label
                        chanlocs(e).labels = ['Ch' num2str(e)];
                end
                listch = {''};
                for ch =1:nchan4label
                        listch{ch} = [num2str(ch) ' = ' chanlocs(ch).labels ];
                end
                
                handles.listch     = listch;
                handles.indxlistch = 1; % channel array
                
                %Update handles structure
                guidata(hObject, handles);                
        end
else
        %force user to click something else
        set(hObject, 'value', 1)
end

% Hint: get(hObject,'Value') returns toggle state of radiobutton_simeeg

%--------------------------------------------------------------------------------------
function edit_ampsin_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_ampsin_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_freqsin_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_freqsin_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_channels2trend_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_channels2trend_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_tdcoffset_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_tdcoffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_linslope_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_linslope_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
% function edit_sqonset_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
% function edit_sqonset_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
% end

%--------------------------------------------------------------------------------------
function edit_sqduration_Callback(hObject, eventdata, handles)

updateviewer_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------------------
function edit_sqduration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
% function edit_sqamp_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
% function edit_sqamp_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
% end

%--------------------------------------------------------------------------------------
function edit_chebychev1_Callback(hObject, eventdata, handles)

updateviewer_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------------------
function edit_chebychev1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_chebychev2_Callback(hObject, eventdata, handles)

updateviewer_Callback(hObject, eventdata, handles)


%--------------------------------------------------------------------------------------
function edit_chebychev2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_chebywin_Callback(hObject, eventdata, handles)

updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_chebywin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_amparray_Callback(hObject, eventdata, handles)
simeegamp     = str2num(get(handles.edit_EEGamp, 'String'));
amparray      = str2num(get(handles.edit_amparray, 'String'));
simop = get(handles.radiobutton_simeeg, 'Value');

if isempty(amparray)
        return
end
if simop && ~isempty(simeegamp)
        snrfontsize = handles.snrfontsize;
        snr = mean(amparray)/simeegamp;
        snrstr = sprintf('SNR = %.2f', snr);
        set(handles.text_SNR, 'String', snrstr)
        set(handles.text_SNR, 'FontSize', snrfontsize)
end

updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_amparray_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_chebyfreq_Callback(hObject, eventdata, handles)

updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function pushbutton_decreasefreq_Callback(hObject, eventdata, handles)
f = str2num(get(handles.edit_chebyfreq, 'String'));
if isempty(f)
        return
end
f = f - 0.05;
if f<=0
        f = 0;
end
set(handles.edit_chebyfreq, 'String', num2str(f))
updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function pushbutton_increasefreq_Callback(hObject, eventdata, handles)
f = str2num(get(handles.edit_chebyfreq, 'String'));
if isempty(f)
        return
end
f = f + 0.05;
set(handles.edit_chebyfreq, 'String', num2str(f))
updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_chebyfreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_chebyphase_Callback(hObject, eventdata, handles)

updateviewer_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------------------
function edit_chebyphase_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function pushbutton_decreasephase_Callback(hObject, eventdata, handles)
ph = str2num(get(handles.edit_chebyphase, 'String'));
if isempty(ph)
        return
end
ph = ph - 0.1;

set(handles.edit_chebyphase, 'String', num2str(ph))
updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function pushbutton_increasephase_Callback(hObject, eventdata, handles)
ph = str2num(get(handles.edit_chebyphase, 'String'));
if isempty(ph)
        return
end
ph = ph + 0.1;

set(handles.edit_chebyphase, 'String', num2str(ph))
updateviewer_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_onsetarray_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_onsetarray_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_numsimch_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_numsimch_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_dursimeeg_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_dursimeeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dursimeeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_simeegsrate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_simeegsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_simeegsrate as text
%        str2double(get(hObject,'String')) returns contents of edit_simeegsrate as a double


%--------------------------------------------------------------------------------------
function edit_simeegsrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_simeegsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
end

% % % %--------------------------------------------------------------------------------------
% % % function pushbutton_browsechan_Callback(hObject, eventdata, handles)
% % % listch     = handles.listch;
% % % indxlistch = handles.indxlistch;
% % % indxlistch = indxlistch(indxlistch<=length(listch));
% % % titlename  = 'Select Channel(s)';
% % %
% % % if get(hObject, 'Value')
% % %         if ~isempty(listch)
% % %                 ch = browsechanbinGUI(listch, indxlistch, titlename);
% % %                 if ~isempty(ch)
% % %                         set(handles.edit_channels2trend, 'String', vect2colon(ch, 'Delimiter', 'off'));
% % %                         handles.indxlistch = ch;
% % %                         % Update handles structure
% % %                         guidata(hObject, handles);
% % %                 else
% % %                         disp('User selected Cancel')
% % %                         return
% % %                 end
% % %         else
% % %                 msgboxText =  'No channel information was found';
% % %                 title = 'ERPLAB: basicfilter GUI input';
% % %                 errorfound(msgboxText, title);
% % %                 return
% % %         end
% % % end

%--------------------------------------------------------------------------------------
function edit_channels2evoke_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_channels2evoke_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_rwpvalues_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_rwpvalues_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_type2insert_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------------------
function edit_type2insert_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------------------
function edit_EEGamp_Callback(hObject, eventdata, handles)
simeegamp     = str2num(get(handles.edit_EEGamp, 'String'));
amparray      = str2num(get(handles.edit_amparray, 'String'));

if isempty(simeegamp) || isempty(amparray)
        return
end
snrfontsize = handles.snrfontsize;
snr = mean(amparray)/simeegamp;
snrstr = sprintf('SNR = %.2f', snr);
set(handles.text_SNR, 'String', snrstr)
set(handles.text_SNR, 'FontSize', snrfontsize)
drawnow

%--------------------------------------------------------------------------------------
function edit_EEGamp_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------


function edit_onseterrorval_Callback(hObject, eventdata, handles)


% Hints: get(hObject,'String') returns contents of edit_onseterrorval as text
%        str2double(get(hObject,'String')) returns contents of edit_onseterrorval as a double


%--------------------------------------------------------------------------------------
function edit_onseterrorval_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--------------------------------------------------------------------------------------
function pushbutton_run_Callback(hObject, eventdata, handles)       
        
sinamp        = str2num(get(handles.edit_ampsin,'String'));
sinfreq       = str2num(get(handles.edit_freqsin, 'String'));
chanArray1    = str2num(get(handles.edit_channels2trend, 'String'));
chanArray2    = str2num(get(handles.edit_channels2evoke, 'String'));
rwpvalueArray = str2num(get(handles.edit_rwpvalues, 'String'));
val_dcoffset  = str2num(get(handles.edit_tdcoffset, 'String'));
val_linear    = str2num(get(handles.edit_linslope, 'String'));
onsetarray    = str2num(get(handles.edit_onsetarray, 'String'));
amparray      = str2num(get(handles.edit_amparray, 'String'));
%squareonset  = str2num(get(handles.edit_sqonset, 'String'));
squaredur     = str2num(get(handles.edit_sqduration, 'String'));
%squareamp    = str2num(get(handles.edit_sqamp, 'String'));
chebychev1    = str2num(get(handles.edit_chebychev1, 'String'));
chebychev2    = str2num(get(handles.edit_chebychev2,'String'));
chebywin      = str2num(get(handles.edit_chebywin, 'String'));
%chebyamp     = str2num(get(handles.edit_amparray, 'String'));
chebyfreq     = str2num(get(handles.edit_chebyfreq, 'String'));
chebyphase    = str2num(get(handles.edit_chebyphase, 'String'));
%chebyonset   = str2num(get(handles.edit_onsetarray, 'String'));
eegduration   = str2num(get(handles.edit_dursimeeg, 'String'));
srate         = str2num(get(handles.edit_simeegsrate, 'String'));
numsimch      = str2num(get(handles.edit_numsimch, 'String'));
tsinu         = get(handles.radiobutton_sinwave, 'Value');
trwalk        = get(handles.radiobutton_randomwalk, 'Value');
tdcoffset     = get(handles.radiobutton_tdcoffset, 'Value');
tlinear       = get(handles.radiobutton_linear, 'Value');
square        = get(handles.radiobutton_square, 'Value');
perfsquare    = get(handles.checkbox_perfsquare, 'Value');
erplike       = get(handles.radiobutton_erplike, 'Value');
normaleeg     = get(handles.radiobutton_usecurrenteeg, 'Value');
simulatedeeg  = get(handles.radiobutton_simeeg, 'Value');
simeegamp     = str2num(get(handles.edit_EEGamp, 'String'));
type2insert   = str2num(get(handles.edit_type2insert, 'String'));
onseterrorval = str2num(get(handles.edit_onseterrorval, 'String'));

nbchan        = handles.nbchan;

% trend
if tsinu && ~trwalk && ~tdcoffset && ~tlinear
        trendtype = 'sin';
elseif ~tsinu && trwalk && ~tdcoffset && ~tlinear
        trendtype = 'rwalk';
elseif ~tsinu && ~trwalk && tdcoffset && ~tlinear
        trendtype = 'dcoffset';
elseif ~tsinu && ~trwalk && ~tdcoffset && tlinear
        trendtype = 'linear';
else
        trendtype = 'none';
end
if isempty(chanArray1) && ~strcmpi(trendtype,'none')
        msgboxText =  'Please enter at least one channel to trend';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
% evoked
if square && ~perfsquare && ~erplike
        evoketype = 'squarefit';
elseif square && perfsquare && ~erplike
        evoketype = 'perfsquare';
elseif ~square && ~perfsquare && erplike
        evoketype = 'erplike';
elseif ~square && ~perfsquare && ~erplike
        evoketype = 'none';
else
        return
end
if isempty(onsetarray) && ~strcmpi(evoketype,'none')
        msgboxText =  'Please enter at least one onset latency to add evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
% simulate eeg
if normaleeg && ~simulatedeeg % use current dataset
        
        eegtype = 'normaleeg';        
        eegdurx = handles.pnts/handles.fs;
        
        if ~strcmpi(evoketype,'none') && max(onsetarray)>eegdurx 
                msgboxText =  'Some onset value is greater than the current dataset duration';
                title = 'ERPLAB: pop_EEGsimulate() error';
                errorfound(msgboxText, title);
                return
        end      
        if ~isempty(chanArray1) && ~isempty(chanArray2)
                if max(chanArray1)>nbchan
                        msgboxText =  'Some channel index for trending is higher than the amount of channels of the current dataset.';
                        title = 'ERPLAB: pop_EEGsimulate() error';
                        errorfound(msgboxText, title);
                        return
                end
                if max(chanArray2)>nbchan
                        msgboxText =  'Some channel index for adding evoked activity is higher than the amount of channels of the current dataset.';
                        title = 'ERPLAB: pop_EEGsimulate() error';
                        errorfound(msgboxText, title);
                        return
                end
        end
elseif ~normaleeg && simulatedeeg  % simulate EEG
        
        eegtype = 'simulatedeeg';              
        eegdurx = eegduration; % in secs
        if ~strcmpi(evoketype,'none') && max(onsetarray)>eegdurx 
                msgboxText =  'Some onset value is greater than the duration of the EEG to be simulated.';
                title = 'ERPLAB: pop_EEGsimulate() error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(numsimch)
                msgboxText =  'Please enter number of channels to simulate.';
                title = 'ERPLAB: pop_EEGsimulate() error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(eegduration)
                msgboxText =  'Please enter duration value to simulate EEG data.';
                title = 'ERPLAB: pop_EEGsimulate() error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(srate)
                msgboxText =  'Please enter sample rate to simulate EEG data.';
                title = 'ERPLAB: pop_EEGsimulate() error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(simeegamp)
                msgboxText =  'Please enter a peak-to-peak amplitude value to simulate EEG data.';
                title = 'ERPLAB: pop_EEGsimulate() error';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(chanArray1) && ~isempty(chanArray2)
                if max(chanArray1)>numsimch
                        msgboxText =  'Some channel index for trending is higher than the amount of channels of simulate';
                        title = 'ERPLAB: pop_EEGsimulate() error';
                        errorfound(msgboxText, title);
                        return
                end
                if max(chanArray2)>numsimch
                        msgboxText =  'Some channel index for adding evoked activity is higher than the amount of channels to simulate.';
                        title = 'ERPLAB: pop_EEGsimulate() error';
                        errorfound(msgboxText, title);
                        return
                end
        end
else
        % show error popup window about here
        return
end

% if square && ~perfsquare && ~erplike
%         evoketype = 'squarefit';
% elseif ~square && perfsquare && ~erplike
%         evoketype = 'perfsquare';
% elseif ~square && ~perfsquare && erplike
%         evoketype = 'erplike';
% else
%         evoketype = 'none';
% end
if isempty(chanArray2) && ~strcmpi(evoketype,'none')
        msgboxText =  'Please enter at least one channel to add evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(amparray) && ~strcmpi(evoketype,'none')
        msgboxText =  'Please enter at least one amplitude value to add evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(type2insert) && ~strcmpi(evoketype,'none')
        msgboxText =  'Please enter an event code for marking inserted evoked-activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(squaredur) && strcmpi(evoketype,'squarefit')
        msgboxText =  'Please enter a duration value to add a squared evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
% erp-like
if isempty(chebychev1) && strcmpi(evoketype,'erplike')
        msgboxText =  'Please enter an onset delay value to add a ERP-like evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(chebychev2) && strcmpi(evoketype,'erplike')
        msgboxText =  'Please enter a post offset time value to add a ERP-like evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(chebywin) && strcmpi(evoketype,'erplike')
        msgboxText =  'Please enter a waveform width value to add a ERP-like evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(chebyfreq) && strcmpi(evoketype,'erplike')
        msgboxText =  'Please enter a frequency value to add a ERP-like evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(chebyphase) && strcmpi(evoketype,'erplike')
        msgboxText =  'Please enter a phase value to add a ERP-like evoked activity';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
% sin
if isempty(sinamp) && strcmpi(trendtype,'sin')
        msgboxText =   'Please enter an amplitude value for sinusoidal trend.';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
if isempty(sinfreq) && strcmpi(trendtype,'sin')
        msgboxText =  'Please enter a frequency value for sinusoidal trend.';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
%dc offset
if isempty(val_dcoffset) && strcmpi(trendtype,'dcoffset')
        msgboxText =  'Please enter a value for dc offset.';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
% linear
if isempty(val_linear) && strcmpi(trendtype,'linear')
        msgboxText =  'Please enter a value for linear trend.';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end
% rwalk
if isempty(rwpvalueArray) && strcmpi(trendtype,'rwalk')
        msgboxText =  'Please enter at least one p-value.';
        title = 'ERPLAB: pop_EEGsimulate() error';
        errorfound(msgboxText, title);
        return
end

%handles.output={amp latency baseline}
handles.output={trendtype evoketype chanArray1 chanArray2 sinamp sinfreq rwpvalueArray val_dcoffset val_linear onsetarray amparray squaredur chebychev1 chebychev2...
        chebywin chebyfreq chebyphase eegtype eegduration srate numsimch simeegamp type2insert onseterrorval};
guidata(hObject, handles);
uiresume(handles.gui_chassis);

%--------------------------------------------------------------------------------------
function updateviewer_Callback(hObject, eventdata, handles)
% I rewrote the code here. JLC

fs    = handles.fs;
amplitudeArray = get(handles.edit_amparray, 'String');
amplitudeArray = str2num(amplitudeArray);

if isempty(amplitudeArray) || isempty(fs) || fs<=1
        return
end
preplotwin = 50; %ms
preplot = round((fs/1000)*preplotwin); 

if get(handles.radiobutton_square, 'Value') % square
        sqdura = str2num(get(handles.edit_sqduration, 'String'));
        if isempty(sqdura)
                return
        end
        set(handles.axes1, 'Visible', 'on')
        amplitudeArray = amplitudeArray(1);         % plot only 1st amplitude
        npre    = round((fs/1000)*200);             % num datapoints pre window of 0s
        npost   = round((fs/1000)*200);             % num datapoints post window of 0s
        sqdurapnts  = round((fs/1000)*sqdura);          % num datapoints post window of 0s
        winsine = [zeros(1, npre)  repmat(amplitudeArray,1,sqdurapnts)  zeros(1, npost)];
        secsignalpoints = length(winsine); 
        secsignaltime   = secsignalpoints/fs;        
        a2 = linspace(-preplotwin/1000, secsignaltime, length(winsine)+preplot);
        
elseif get(handles.radiobutton_erplike, 'Value') % erplike
        npre        = str2num(get(handles.edit_chebychev1, 'String'));                                %num datapoints pre window of 0s
        npost       = str2num(get(handles.edit_chebychev2, 'String'));                               %num datapoints post window of 0s
        chebylength = str2num(get(handles.edit_chebywin, 'String'));                           %in # of datapoints
        chebyfreq   = str2num(get(handles.edit_chebyfreq, 'String'));
        chebyphase  = str2num(get(handles.edit_chebyphase, 'String'));
        if isempty(npre) || isempty(npost) || isempty(chebylength) || isempty(chebyfreq) || isempty(chebyphase)
                return
        end
        set(handles.axes1, 'Visible', 'on')
        amplitudeArray = amplitudeArray(1); % plot only 1st amplitude
        npre  = round((fs/1000)*npre);                                %num datapoints pre window of 0s
        npost = round((fs/1000)*npost);                               %num datapoints post window of 0s
        chebylength = round(fs/1000*chebylength);                           %in # of datapoints
        w  = chebwin(chebylength)';
        w  = [zeros(1, npre)  w  zeros(1, npost)];
        
        secsignalpoints = length(w);                             %signal duration in points
        secsignaltime   = secsignalpoints/fs;
        %a = 0:1/(fs):secsignaltime-1/(fs);                       %time vector
        a1 = linspace(0, secsignaltime, length(w));
        a2 = linspace(-preplotwin/1000, secsignaltime, length(w)+preplot);
        
        sinadd     = sin(2*pi*chebyfreq*a1 + chebyphase);
        winsine    = sinadd.*w;
        factoramp  = amplitudeArray/(max(winsine)-min(winsine));
        winsine    = winsine*factoramp;
else
        return
end

a2 = a2*1000; %convert to ms
winsine = [zeros(1, preplot) winsine];
plot(a2, winsine, 'k');
hold on
xmin = -preplotwin; %min(a);
xmax = max(a2);
ymin = min(winsine);
ymax = max(winsine);
maxmax = 1.2*max(abs([ymin ymax]));
line([0 0],[-maxmax maxmax], 'LineWidth',1,'Color',[.8 .8 .8])
axis([xmin xmax -maxmax maxmax])
hold off
drawnow


% npre  = round((fs/1000)*str2num(npre));                                %num datapoints pre window of 0s
% npost = round((fs/1000)*str2num(npost));                               %num datapoints post window of 0s
% chebylength = round(fs/1000*str2num(chebylength));                           %in # of datapoints
% 
% chebyfreq   = str2num(chebyfreq);
% chebyamp    = str2num(chebyamp);
% chebyamp    = chebyamp(1); % plot only 1st amplitude
% w           =  chebwin(chebylength)';
% w           = [zeros(1, npre)  w  zeros(1, npost)];
% 
% secsignalpoints = length(w); % signal duration in secs
% secsignaltime   = secsignalpoints/fs;
% x = 0:1/(fs):secsignaltime-1/(fs); % time vector
% 
% %length npre chebywin and npost
% y = sin(2*pi*chebyfreq*x);
% for i=1:length(x);
%         g(i) = chebyamp*w(i)*y(i);
% end
% x = x*1000; %convert to ms
% plot(x, g, 'k');
% 
% xmin = min(x);
% xmax = max(x);
% ymin = 1.1*min(g);
% ymax = 1.1*max(g);
% 
% axis([xmin xmax ymin ymax ])
% drawnow

%--------------------------------------------------------------------------------------
%Function to close the GUI
%also need to also change the closerqst
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
