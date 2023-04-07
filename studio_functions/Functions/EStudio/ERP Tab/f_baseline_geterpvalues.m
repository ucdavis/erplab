%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function S_out = f_baseline_geterpvalues(varargin)

%%Get the parameters for pop_geterpvalues used in the last time.
def_erpvalue   = erpworkingmemory('pop_geterpvalues');

try
    ALLERP = evalin('base','ALLERP');
    CurrentERPSet = evalin('base','CURRENTERP');
    Current_ERP = evalin('base','ERP');
catch
    return;
end

if isstruct(ALLERP)
    if ~iserpstruct(ALLERP(1))
        ALLERP = [];
        nbinx  = 1;
        nchanx = 1;
    else
        nbinx  = ALLERP(1).nbin;
        nchanx = ALLERP(1).nchan;
    end
else
    ALLERP = [];
    nbinx = 1;
    nchanx = 1;
end

if isempty(def_erpvalue)
    if isempty(ALLERP)
        inp1   = 1; %from hard drive
        CurrentERPSet = [];
    else
        inp1   = 0; %from erpset menu
        CurrentERPSet = 1:length(ALLERP);
    end
    
    def_erpvalue = {inp1,CurrentERPSet,'',0,1:nbinx,1:nchanx,'meanbl',...
        1,3,'pre',1,1,5,0,0.5,0,0,0,'',0,1,1};
    
else
    if ~isempty(ALLERP)
        if isnumeric(def_erpvalue{2}) % JavierLC 11-17-11
            [uu, mm] = unique_bc2(def_erpvalue{2}, 'first');
            erpset_list_sorted   = [def_erpvalue{2}(sort(mm))];
            %def_erpvalue{2}   = def_erpvalue{2}(def_erpvalue{2}<=length(ALLERP));
            % non-empty check, axs jul17
            erpset_list = erpset_list_sorted(erpset_list_sorted<=length(ALLERP));
            if isempty(erpset_list)
                % if nothing in list, just go with current
                def_erpvalue{2} = CurrentERPSet;
            else
                % use JLC's sorting, iff not empty
                def_erpvalue{2} = erpset_list;
            end
            
        end
    end
end


if def_erpvalue{11} == 0
    def_erpvalue{11} = 'off';
else
    def_erpvalue{11} = 'on';
end

if def_erpvalue{12} == 0
    def_erpvalue{12} = 'negative';
else
    def_erpvalue{12} = 'positive';
end

if def_erpvalue{14}==0
    def_erpvalue{14} = 'NaN';
else
    def_erpvalue{14} = 'absolute';
end

if def_erpvalue{16}==0 % Fractional area latency replacement
    def_erpvalue{16} = 'NaN';
else
    if ismember_bc2({def_erpvalue{7}}, {'fareatlat', 'fninteglat','fareaplat','fareanlat'})
        def_erpvalue{16} = 'errormsg';
    else
        def_erpvalue{16} = 'absolute';
    end
end

if def_erpvalue{17} == 0
    def_erpvalue{17} = 'off';
else
    def_erpvalue{17} = 'on';
end

if def_erpvalue{18} == 0
    def_erpvalue{18} = 'wide';
else
    def_erpvalue{18} = 'long';
end


if def_erpvalue{20} == 0
    def_erpvalue{20} = 'no';
else
    def_erpvalue{20} = 'yes';
end

%
S_IN = estudioworkingmemory('geterpvalues');
if isempty(S_IN)
    erpvalues_variables = {'geterpvalues','latency',def_erpvalue{4},...
        'binArray',def_erpvalue{5},...
        'chanArray', def_erpvalue{6},...
        'Erpsets', def_erpvalue{2},...
        'Measure',def_erpvalue{7},...
        'Component',def_erpvalue{8},...
        'Resolution', def_erpvalue{9},...
        'Baseline', def_erpvalue{10},...
        'Binlabel', def_erpvalue{11},...
        'Peakpolarity',def_erpvalue{12},...
        'Neighborhood', def_erpvalue{13},...
        'Peakreplace', def_erpvalue{14},...
        'Filename', def_erpvalue{3},...
        'Warning','on',...
        'SendtoWorkspace', def_erpvalue{17},...
        'Append', '',...
        'FileFormat', def_erpvalue{18},...
        'Afraction',def_erpvalue{15},...
        'Mlabel', def_erpvalue{19},...
        'Fracreplace', def_erpvalue{16},...
        'IncludeLat', def_erpvalue{20},...
        'InterpFactor', def_erpvalue{21},...
        'Viewer', 'off',...
        'PeakOnset',def_erpvalue{22},...
        'History', 'gui'};
    S_OUT = createrplabstudioparameters(S_IN,erpvalues_variables);
    estudioworkingmemory('geterpvalues',S_OUT.geterpvalues);
    S_IN = S_OUT.geterpvalues;
end

S_out = S_IN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Judge if the baseline method is character?
%%------------------------GUI start----------------------------------------------
f_localpeak = figure( 'Name', 'ERP Measurement Tool', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off');
f_localpeak.Position(3:4) = [250 120];


% f_localpeak_ll = uiextras.BoxPanel('Parent', f_localpeak, 'Title', ' ', 'Padding', 5);

BaselineMethod =  S_out.Baseline;
if ~ischar(BaselineMethod)
    BaselineMethod = 'custom';
    BaselineInterval = S_out.Baseline;
else
    BaselineInterval = 0.000;
end


gui_baseline = erp_m_t_Baseline_period_gui();

    function  gui_baseline = erp_m_t_Baseline_period_gui()
        FontSize_defualt = erpworkingmemory('fontsizeGUI');
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        b1 = uiextras.VBox( 'Parent', f_localpeak);
        %%---------------------------------Title------------------------------------
        b11 = uiextras.HBox( 'Parent', b1 );
        b111 = uicontrol('Style','text','Parent', b11,'String','Baseline period (in ms)','fontsize',16);%,'FontWeight', 'bold');
        
        %%------------------------------Baseline methods---------------------------
        b13 = uiextras.HBox( 'Parent', b1 );
        b131 = uicontrol('Style','text','Parent', b13,'String','Method selection','FontSize',FontSize_defualt);%,'FontWeight', 'bold');
        set(b131, 'horizontalAlignment', 'left');
        Baseline_methods = {'None','Pre','Post','Whole','Custom'};
        lpa_baseline_method = uicontrol('Style', 'popup','Parent',b13,'String',Baseline_methods,'callback',@Baseline_selection,'FontSize',FontSize_defualt);
        set(b13, 'Sizes', [150 100]);
        if ~isempty(S_out.Baseline)
            switch BaselineMethod
                case 'none'
                    set(lpa_baseline_method,'value',1);
                case 'pre'
                    set(lpa_baseline_method,'value',2);
                case 'post'
                    set(lpa_baseline_method,'value',3);
                case 'whole'
                    set(lpa_baseline_method,'value',4);
                otherwise
                    set(lpa_baseline_method,'value',5);
            end
        end
        
        %%-----------------Custum define time window for baseline period-----------------
        b14 = uiextras.HBox( 'Parent', b1 );
        b141 = uicontrol('Style','text','Parent', b14,'String','Use two latencies','FontSize',FontSize_defualt);%,'FontWeight', 'bold');
        set(b141, 'horizontalAlignment', 'left');
        gui_baseline.lpa_baseline_custom = uicontrol('Style', 'edit','Parent',b14,'String',num2str(BaselineInterval),'callback',@Baseline_custom,'FontSize',FontSize_defualt);
        if ~strcmp(BaselineMethod,'custom')
            set(gui_baseline.lpa_baseline_custom,'ForegroundColor', [.5 0.5 0.5], 'Enable', 'off','BackgroundColor',[0.800 0.800 0.800]);
            set(b141,'ForegroundColor', [.5 0.5 0.5]);
        end
        set(b14, 'Sizes', [150 100]);
        %%------------------------Cancel and Run----------------------------------
        b16 = uiextras.HBox( 'Parent', b1);
        uicontrol( 'Parent', b16, 'String', 'Cancel','callback',@Local_peak_cancel,'FontSize',FontSize_defualt);
        uicontrol( 'Parent', b16, 'String', 'Run','callback',@Local_peak_run,'FontSize',FontSize_defualt);
        
    end
%%*************************************************************************
%%******************   subfunctions   *************************************
%%*************************************************************************

%%-----------------------Baseline method selection-------------------------
%%'None','Pre','Post','Whole','Custum'
    function Baseline_selection(Source_Baseline_selection,~)
        Values_local_replace = Source_Baseline_selection.Value;
        if ~isempty(Values_local_replace)
            
            if Values_local_replace ==1
                S_out.Baseline = 'none';
                gui_baseline.lpa_baseline_custom.Enable = 'Off';
                BaselineMethod = 'none';
            elseif Values_local_replace==2
                S_out.Baseline = 'pre';
                gui_baseline.lpa_baseline_custom.Enable = 'Off';
                BaselineMethod = 'pre';
            elseif Values_local_replace==3
                S_out.Baseline = 'post';
                gui_baseline.lpa_baseline_custom.Enable = 'Off';
                BaselineMethod = 'post';
            elseif Values_local_replace==4
                S_out.Baseline = 'whole';
                gui_baseline.lpa_baseline_custom.Enable = 'Off';
                BaselineMethod = 'whole';
            else
                BaselineMethod = 'custom';
                gui_baseline.lpa_baseline_custom.Enable = 'On';
            end
            erp_m_t_Baseline_period_gui();
        end
    end

%%--------------Custum define the baseline period--------------------------
    function Baseline_custom(source_custom,~)
        S_out.Baseline = str2num(source_custom.String);
        
        if isempty(S_out.Baseline) || length(S_out.Baseline)==1
            msgboxText =  {'Invalid Baseline range!';'Please enter two numeric values'};
            title = 'EStudio: Local peak amplitude setting';
            errorfound(msgboxText, title);
            return;
        end
        %%Judge the upper/lower intervals
        ERP = evalin('base','ERP');
        EpochStart = ERP.times(1);
        EpochEnd = ERP.times(end);
        if length(S_out.Baseline)==2
            if EpochStart > S_out.Baseline(1) || EpochEnd < S_out.Baseline(2)
                msgboxText =  {'For the defined two numeric values V1 and V2, where V1>=',num2str(EpochStart),',',32,'V2<=',num2str(EpochEnd)};
                title = 'EStudio: ERP measurement tool- baseline period';
                errorfound(msgboxText, title);
                return;
            end
        end
        BaselineInterval = S_out.Baseline;
        BaselineMethod = 'custom';
        
    end

%%-----------------------Cancel section-----------------------------------
    function Local_peak_cancel(Source_localp_cancel,~)
        Values_localp_cancel = Source_localp_cancel.Value;
        if ~isempty(Values_localp_cancel)
            beep;
            disp('User selected Cancel');
            close(f_localpeak);
            return;
        end
    end
%%-----------------------Run selection-------------------------------------
    function Local_peak_run(Source_localp_run,~)
        Values_localp_run = Source_localp_run.Value;
        if ~isempty(Values_localp_run)
            S_ws = estudioworkingmemory('geterpvalues');
            
            S_ws.Baseline = S_out.Baseline;
            estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
            
            close(f_localpeak);
            return;
        end
    end
%%%Program end
end