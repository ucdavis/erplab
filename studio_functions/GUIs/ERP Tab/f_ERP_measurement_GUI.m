%%% ERPLAB Studio: ERO meansurement panel


%Author: Guanghui ZHANG
%Center for Mind and Brain
% University of California, Davis
%Davis, CA
% 2022 & Nov. 2023


function varargout = f_ERP_measurement_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERP_change);
addlistener(observe_ERPDAT,'erp_between_panels_change',@erp_between_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);


ERPMTops = struct();
%---------------------------gui-------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    erp_measurement_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Measurement Tool',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    erp_measurement_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Measurement Tool',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    erp_measurement_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Measurement Tool',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @ERPmeasr_help
end

try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_m_t_gui(FonsizeDefault);

varargout{1} = erp_measurement_box;
%%********************Draw the GUI for Measurement Tool*****************
    function erp_m_t_gui(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        ERPMTops.mt = uiextras.VBox('Parent',erp_measurement_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        Enable_label = 'off';
        %%-----------------------Measurement type setting-------------------
        ERPMTops.measurement_type = uiextras.Grid('Parent',ERPMTops.mt,'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%1A
        ERPMTops.measurement_type_title = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','Type:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.measurement_type_title,'HorizontalAlignment','left');
        %%1B
        ERPMTops.erpset_select_title  = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','ERPset:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.erpset_select_title,'HorizontalAlignment','left');
        %%1C
        ERPMTops.bin_select_title  = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','Bin:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.bin_select_title,'HorizontalAlignment','left');
        %%1D
        ERPMTops.channel_select_title = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','Channel:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.channel_select_title,'HorizontalAlignment','left');
        %%1E
        ERPMTops.tw_set_title = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','Window:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.tw_set_title,'HorizontalAlignment','left');
        %%1F
        ERPMTops.out_file_title = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','Output:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.out_file_title,'HorizontalAlignment','left');
        
        %%-----------------------------Setting for second column---------------
        %%2A
        mesurement_type = {'Mean Amp',...
            'Positive Peak Amp',...
            'Negative Peak Amp',...
            'Positive Peak Lat',...
            'Negative Peak Lat',...
            'Pos Frac Peak Lat',...
            'Neg Frac Peak Lat',...
            'Frac Area Lat (Rectified)',...
            'Frac Area Lat (Integral)',...
            'Frac Area Lat (Neg Area)',...
            'Frac Area Lat (Pos Area)',...
            'Rectified Area',...
            'Integral',...
            'Positive Area',...
            'Negative Area',...
            'Instantaneous Amp'};
        ERPMTops.m_t_type = uicontrol('Style', 'popup','Parent',ERPMTops.measurement_type,'String',mesurement_type,...
            'callback',@Mesurement_type,'Enable',Enable_label,'FontSize',FonsizeDefault);
        %%Get the parameters for pop_geterpvalues used in the last time.
        def_erpvalue   = estudioworkingmemory('pop_geterpvalues');
        if isempty(def_erpvalue)
            def_erpvalue = {0,1,'',0,[],[],'meanbl',...
                1,3,'pre',1,1,5,0,0.5,0,0,0,'',0,1,1};
        else
        end
        if def_erpvalue{11} == 0%%binlabop
            def_erpvalue{11} = 'off';
        else
            def_erpvalue{11} = 'on';
        end
        
        if def_erpvalue{12} == 0%%polpeak
            def_erpvalue{12} = 'negative';
        else
            def_erpvalue{12} = 'positive';
        end
        
        if def_erpvalue{14}==-1%%locpeakrep
            def_erpvalue{14} =  'errormsg';
        elseif def_erpvalue{14}==0
            def_erpvalue{14} = 'NaN';
        else
            def_erpvalue{14} = 'absolute';  
        end
        
        if def_erpvalue{16}==0 % Fractional area latency replacement
            def_erpvalue{16} = 'NaN';
        else
            if ismember_bc2({def_erpvalue{7}}, {'fareatlat', 'fninteglat','fareanlat','fareaplat'})
                def_erpvalue{16} = 'errormsg';
            else
                def_erpvalue{16} = 'absolute';
            end
        end
        
        if def_erpvalue{17} == 0%%send to workspace
            def_erpvalue{17} = 'off';
        else
            def_erpvalue{17} = 'on';
        end
        
        if def_erpvalue{18} == 0%% file format
            def_erpvalue{18} = 'wide';
        else
            def_erpvalue{18} = 'long';
        end
        
        if def_erpvalue{20} == 0%%include used latency values for measurements like mean, peak, area...
            def_erpvalue{20} = 'no';
        else
            def_erpvalue{20} = 'yes';
        end
        ERPMTops.def_erpvalue = def_erpvalue;
        
        try
            Measure = ERPMTops.def_erpvalue{7};
        catch
            Measure = 'meanbl';
        end
        try Peakpolarity = ERPMTops.def_erpvalue{12}; catch  Peakpolarity=1;end
        if isempty(Peakpolarity) ||numel(Peakpolarity)~=1 || (Peakpolarity~=0 && Peakpolarity~=1)
            Peakpolarity=1;
        end
        if  Peakpolarity==1
            Polarity= 'positive';
        else
            Polarity = 'negative';
        end
        switch Measure%Find the label of the selected item, the defualt one is 1 (Mean amplitude between two fixed latencies)
            case 'meanbl'% Mean amplitude
                set(ERPMTops.m_t_type,'Value',1);
            case 'peakampbl'% Peak amplitude (P vs. N)
                if strcmp(Polarity,'positive')
                    set(ERPMTops.m_t_type,'Value',2);
                else
                    set(ERPMTops.m_t_type,'Value',3);
                end
            case  'peaklatbl'%Peak latency (P vs. N)
                if strcmp(Polarity,'positive')
                    set(ERPMTops.m_t_type,'Value',4);
                elseif strcmp(Polarity,'negative')
                    set(ERPMTops.m_t_type,'Value',5);
                end
            case  'fpeaklat'%Fractional Peak latency (P vs. N)
                if strcmp(Polarity,'positive')
                    set(ERPMTops.m_t_type,'Value',6);
                elseif strcmp(Polarity,'negative')
                    set(ERPMTops.m_t_type,'Value',7);
                end
                
            otherwise%if the measurement type comes from Advanced option
                MeasureName_other = {'fareatlat','fninteglat','fareanlat','fareaplat',...
                    'areat','ninteg','areap','arean','instabl'};
                [C,IA] = ismember_bc2({Measure}, MeasureName_other);
                if isempty(IA)
                    set(ERPMTops.m_t_type,'Value',1);
                else
                    set(ERPMTops.m_t_type,'Value',IA+7);
                end
        end
        ERPMTops.Paras{1} = ERPMTops.m_t_type.Value;
        
        %%2B ERPset custom
        ERPMTops.m_t_erpset = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String', '',...
            'callback',@erpset_custom,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        ERPMTops.Paras{2} = str2num(ERPMTops.m_t_erpset.String);
        ERPMTops.m_t_erpset.KeyPressFcn = @erp_mt_presskey;
        
        %%2C
        ERPMTops.m_t_bin = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,...
            'String', '','callback',@binSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %
        ERPMTops.Paras{3} = str2num(ERPMTops.m_t_bin.String);
        ERPMTops.m_t_bin.KeyPressFcn = @erp_mt_presskey;
        %%2D
        ERPMTops.m_t_chan = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,...
            'String','','callback',@chanSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);%vect2colon(observe_ERPDAT.ERP_chan,'Sort', 'on')
        ERPMTops.Paras{4} = str2num(ERPMTops.m_t_chan.String);
        ERPMTops.m_t_chan.KeyPressFcn = @erp_mt_presskey;
        %%2E
        ERPMTops.m_t_TW = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,...
            'String','','callback',@t_w_set,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPMTops.Paras{5} = str2num(ERPMTops.m_t_TW.String);
        ERPMTops.m_t_TW.KeyPressFcn = @erp_mt_presskey;
        %%2F
        ERPMTops.m_t_file = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,...
            'String','','callback',@file_name_set,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPMTops.Paras{6} = ERPMTops.m_t_file.String;
        ERPMTops.m_t_file.KeyPressFcn = @erp_mt_presskey;
        
        %%-----------Setting for third column--------------------------------
        %%3A
        ERPMTops.m_t_type_ops = uicontrol('Style', 'pushbutton','Parent',ERPMTops.measurement_type,...
            'String','Options','callback',@Mesurement_type_option,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %%3B
        ERPMTops.m_t_erpset_ops = uicontrol('Style','pushbutton','Parent',  ERPMTops.measurement_type,...
            'String','Browse','callback',@erpsetop,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %%3C
        ERPMTops.m_t_bin_ops = uicontrol('Style','pushbutton','Parent',  ERPMTops.measurement_type,...
            'String','Browse','callback',@binSelect_label,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %%3D
        ERPMTops.m_t_chan_ops = uicontrol('Style','pushbutton','Parent', ERPMTops.measurement_type,...
            'String','Browse','callback',@chanSelect_label,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %%3E
        ERPMTops.m_t_TW_ops = uicontrol('Style', 'pushbutton','Parent',ERPMTops.measurement_type,...
            'String','Baseline','callback',@m_t_TW_ops,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %%3F
        ERPMTops.m_t_file_ops = uicontrol('Style', 'pushbutton','Parent',ERPMTops.measurement_type,...
            'String','Options','callback',@out_file_option,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(ERPMTops.measurement_type, 'ColumnSizes',[65 135 65],'RowSizes',[25 25 25 25 25 25]);
        
        %%---------------------------Select ERPsets and Run options-----------
        ERPMTops.out_file_run = uiextras.HBox('Parent',ERPMTops.mt,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPMTops.cancel = uicontrol('Style', 'pushbutton','Parent',ERPMTops.out_file_run,'String','Cancel',...
            'callback',@ERPmeasr_cancel,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPMTops.m_t_value = uicontrol('Style', 'pushbutton','Parent',ERPMTops.out_file_run,'String','Save measures',...
            'callback',@erp_m_t_savalue,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPMTops.apply = uicontrol('Style', 'pushbutton','Parent',ERPMTops.out_file_run,'String','Preview',...
            'callback',@erp_m_t_view,'Enable',Enable_label,'FontSize',FonsizeDefault,'Value',0,'BackgroundColor',[1 1 1]);
        set(ERPMTops.out_file_run,'Sizes',[70 -1 70]);
        
        %%ERPMTops end
        set(ERPMTops.mt,'Sizes',[155 30]);
        estudioworkingmemory('ERPTab_mesuretool',0);
    end

%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%---------------------------Setting for the Measurement type-----------------------------%%
    function Mesurement_type(source_measure_type,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_mesuretool',1);
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        
        Measure= source_measure_type.Value;
        switch Measure%Find the label of the selected item, the defualt one is 1 (Mean amplitude between two fixed latencies)
            case 1
                moption = 'meanbl';% Mean amplitude
            case 2
                moption = 'peakampbl';
                ERPMTops.def_erpvalue{12} = 'positive';
            case 3 % Peak amplitude (P vs. N)
                moption = 'peakampbl';
                ERPMTops.def_erpvalue{12} = 'negative';
            case  4
                moption= 'peaklatbl';
                ERPMTops.def_erpvalue{12} = 'positive';
            case 5
                moption= 'peaklatbl';
                ERPMTops.def_erpvalue{12} = 'negative';
            case  6
                moption= 'fpeaklat';
                ERPMTops.def_erpvalue{12} = 'positive';
            case 7
                moption= 'fpeaklat';
                ERPMTops.def_erpvalue{12} = 'negative';
            otherwise%if the measurement type comes from Advanced option
                MeasureName_other = {'fareatlat','fninteglat','fareanlat','fareaplat',...
                    'areat','ninteg','areap','arean','instabl'};
                try
                    moption=  MeasureName_other{Measure-7};
                catch
                    moption=  'meanbl';
                    source_measure_type.Value=1;
                end
        end
        ERPMTops.def_erpvalue{7} = moption;
    end


%%------------Options for the measurement type-----------------------------
    function Mesurement_type_option(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        
        try
            op         = ERPMTops.def_erpvalue{7};
        catch
            op=  'meanbl';
        end% option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
        try
            dig        = ERPMTops.def_erpvalue{9};
        catch
            dig        =3;
        end%Resolution
        try
            Binlabel = ERPMTops.def_erpvalue{11};
        catch
            Binlabel = 'off';
        end
        if strcmpi(Binlabel,'off')
            binlabop   = 0; % 0: bin# as bin label for table, 1 bin label
        else
            binlabop   = 1;
        end
        try
            Peakpolarity = ERPMTops.def_erpvalue{12};
        catch
            Peakpolarity = 'negative';
        end
        if strcmpi(Peakpolarity,'negative')
            polpeak    = 0;
        else
            polpeak    = 1; % Peak positive polarity
        end
        %%resolution
        try
            sampeak    = ERPMTops.def_erpvalue{13}; % number of samples (one-side) for Peak detection criteria
        catch
            sampeak = 3;
        end
        try
            Peakreplace = ERPMTops.def_erpvalue{14};
        catch
            Peakreplace = 'absolute';
        end
        if strcmpi(Peakreplace,'absolute')
            locpeakrep = 1;
        elseif strcmpi(Peakreplace,'Nan')
            locpeakrep = 0; % 1 abs peak , 0 Nan
        elseif strcmpi(Peakreplace,'errormsg')
            locpeakrep = -1;
        end
        try
            frac =  ERPMTops.def_erpvalue{15};
        catch
            frac       = 0.5;
        end
        try
            Fracreplace =  ERPMTops.def_erpvalue{16};
        catch
            Fracreplace = 'NaN';
        end
        
        if ismember_bc2({op}, {'fareatlat', 'fninteglat','fareanlat','fareaplat'})
            if strcmpi(Fracreplace,'NaN')%% latency : closet 0, NAN 1, error 2
                fracmearep = 0; %  NaN
            else
                fracmearep = 2;
            end
        else
            if strcmpi(Fracreplace,'absolute')
                fracmearep = 1;
            elseif  strcmpi(Fracreplace,'errormsg')
                fracmearep = -1;
            else
                fracmearep = 0;
            end
        end
        
        try
            SendtoWorkspace = ERPMTops.def_erpvalue{17};
        catch
            SendtoWorkspace = 'off';
        end
        if strcmpi(SendtoWorkspace,'off')
            send2ws    = 0; % 1 send to ws, 0 dont do
        else
            send2ws    = 1;
        end
        try
            IncludeLat =  ERPMTops.def_erpvalue{20} ;
        catch
            IncludeLat = 'off';
        end
        if strcmpi(IncludeLat,'on')
            inclate    = 1;
        else
            inclate    = 0;
        end
        try
            intfactor = ERPMTops.def_erpvalue{21};
        catch
            intfactor  = 10;
        end
        try
            peakonset =ERPMTops.def_erpvalue{22};
        catch
            peakonset = 1;
        end
        
        %%Change the modified parameters after the subfucntion was called
        def = { op ,dig,binlabop,polpeak,sampeak,locpeakrep,frac,...
            fracmearep,send2ws,inclate,intfactor,peakonset};
        ERP= observe_ERPDAT.ERP;
        Answer = geterpvaluesparasGUI2(def,ERP);
        
        if isempty(Answer)
            return;
        end
        Measure = Answer{1};
        
        switch Measure%Find the label of the selected item, the defualt one is 1 (Mean amplitude between two fixed latencies)
            case 'meanbl'% Mean amplitude
                set(ERPMTops.m_t_type,'Value',1);
            case 'peakampbl'% Peak amplitude (P vs. N)
                if strcmp(Peakpolarity,'positive')
                    set(ERPMTops.m_t_type,'Value',2);
                else
                    set(ERPMTops.m_t_type,'Value',3);
                end
            case  'peaklatbl'%Peak latency (P vs. N)
                if strcmp(Peakpolarity,'positive')
                    set(ERPMTops.m_t_type,'Value',4);
                elseif strcmp(Peakpolarity,'negative')
                    set(ERPMTops.m_t_type,'Value',5);
                end
            case  'fpeaklat'%Fractional Peak latency (P vs. N)
                if strcmp(Peakpolarity,'positive')
                    set(ERPMTops.m_t_type,'Value',6);
                elseif strcmp(Peakpolarity,'negative')
                    set(ERPMTops.m_t_type,'Value',7);
                end
            otherwise%if the measurement type comes from Advanced option
                MeasureName_other = {'fareatlat','fninteglat','fareanlat','fareaplat',...
                    'areat','ninteg','areap','arean','instabl'};
                [C,IA] = ismember_bc2({Measure}, MeasureName_other);
                if  isempty(IA)
                    set(ERPMTops.m_t_type,'Value',1);
                    Measure = 'meanbl';
                else
                    set(ERPMTops.m_t_type,'Value',IA+7);
                end
        end
        ERPMTops.def_erpvalue{7} = Measure;
        
        ERPMTops.def_erpvalue{9} =Answer{2};
        
        polpeak= Answer{4};%%polarity
        if polpeak==0
            ERPMTops.def_erpvalue{12}     = 'negative';
        else
            ERPMTops.def_erpvalue{12}    = 'positive';
        end
        
        ERPMTops.def_erpvalue{13} = Answer{5};%%Neighborhood
        
        locpeakrep = Answer{6};%%Peak replacement
        
        if locpeakrep==0
            ERPMTops.def_erpvalue{14} = 'NaN';
        elseif locpeakrep==1
            ERPMTops.def_erpvalue{14} = 'absolute';
        elseif locpeakrep==-1
            ERPMTops.def_erpvalue{14}   = 'errormsg';
        end
        
        ERPMTops.def_erpvalue{15} = Answer{7};%%Afraction
        
        fracmearep= Answer{8};%%Fracreplace
        if fracmearep==0 % Fractional area latency replacement
            ERPMTops.def_erpvalue{16} = 'NaN';
        else
            if ismember_bc2({ERPMTops.def_erpvalue{7}}, {'fareatlat', 'fninteglat','fareanlat','fareaplat'})
                ERPMTops.def_erpvalue{16} = 'errormsg';
            else
                if fracmearep==1
                    ERPMTops.def_erpvalue{16} = 'absolute';
                elseif fracmearep==-1
                    ERPMTops.def_erpvalue{16} = 'errormsg';
                end
            end
        end
        
        ERPMTops.def_erpvalue{21} =Answer{11};
        ERPMTops.def_erpvalue{22} = Answer{12};
    end

%%----------------------------ERPset custom--------------------------------
    function erpset_custom(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        ERPsetArray = str2num(Source.String);
        ERPsetArraydef =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPsetArray) || any(ERPsetArray> length(observe_ERPDAT.ALLERP))
            if isempty(ERPsetArraydef) || any(ERPsetArraydef> length(observe_ERPDAT.ALLERP))
                Source.String = '';
            else
                ERPset =  vect2colon(ERPsetArraydef,'Sort','on');
                ERPset = erase(ERPset,{'[',']'});
                Source.String = ERPset;
            end
        end
    end

%%-------------Select bins by user custom----------------------------------
    function binSelect_custom(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        binNums =  str2num(source.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binNums, [],1);
        if chk(1)
            source.String = '';
            msgboxText =  ['Measurement Tool -',32,msgboxText];
            estudioworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
    end


%%----------------Option for erpset----------------------------------------
    function erpsetop(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        
        ERPsetArraydef = estudioworkingmemory('selectederpstudio');
        if isempty(ERPsetArraydef) || any(ERPsetArraydef> length(observe_ERPDAT.ALLERP))
            ERPsetArraydef = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = ERPsetArraydef;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
        end
        ERPArray = str2num(ERPMTops.m_t_erpset.String);
        if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
            ERPArray = ERPsetArraydef;
        end
        for Numoferpset = 1:length(observe_ERPDAT.ALLERP)
            listname{Numoferpset} = char(strcat(num2str(Numoferpset),'.',observe_ERPDAT.ALLERP(Numoferpset).erpname));
        end
        indxlistb  =ERPArray;
        titlename = 'Select ERPset(s):';
        ERPset_select = browsechanbinGUI(listname, indxlistb, titlename);
        if ~isempty(ERPset_select)
            ERPset = vect2colon(ERPset_select,'Sort','on');
            ERPset = erase(ERPset,{'[',']'});
            ERPMTops.m_t_erpset.String = ERPset;
        else
            return;
        end
    end


%%---------------Bins selection from "Option"------------------------------
    function binSelect_label(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        
        ERP_CURRENT = observe_ERPDAT.ERP;
        for Numofbin = 1:length(ERP_CURRENT.bindescr)
            listb{Numofbin} = char(strcat(num2str(Numofbin),'.',ERP_CURRENT.bindescr{Numofbin}));
        end
        indxlistb  = str2num(ERPMTops.m_t_bin.String);
        if isempty(indxlistb) || any(indxlistb>observe_ERPDAT.ERP.nbin)
            indxlistb = 1:observe_ERPDAT.ERP.nbin;
        end
        titlename = 'Select Bin(s):';
        %----------------judge the number of latency/latencies--------
        bin_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(bin_label_select)
            binset = vect2colon(bin_label_select,'Sort', 'on');
            binset = erase(binset,{'[',']'});
            ERPMTops.m_t_bin.String=binset;
        else
            return
        end
    end


%%----------------Define the channels of interest----------------------
    function chanSelect_custom(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        chanNums =  str2num(Source.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, [], chanNums,2);
        if chk(2)
            Source.String = '';
            msgboxText =  ['Measurement Tool -',32,msgboxText];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end


%%----------------Channels selection from option--------------------------------------
    function chanSelect_label(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        
        for Numofchan = 1:observe_ERPDAT.ERP.nchan
            try
                listb{Numofchan}= strcat(num2str(Numofchan),'.',observe_ERPDAT.ERP.chanlocs(Numofchan).labels);
            catch
                listb{Numofchan}= strcat(num2str(Numofchan),'.','chan',num2str(Numofchan));
            end
        end
        chanArray =  str2num(ERPMTops.m_t_chan.String);
        if isempty(chanArray) || any(chanArray>observe_ERPDAT.ERP.nchan) || any(chanArray<1)
            chanArray = [1:observe_ERPDAT.ERP.nchan];
        end
        if isempty(listb)
            msgboxText =  ['Measurement Tool-No channel information was found'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        titlename = 'Select Channel(s):';
        chan_label_select = browsechanbinGUI(listb, chanArray, titlename);
        if ~isempty(chan_label_select)
            chanset = vect2colon(chan_label_select,'Sort', 'on');
            chanset = erase(chanset,{'[',']'});
            ERPMTops.m_t_chan.String=chanset;
        else
            return
        end
    end

%%-----------------Measurement time-window-------------------------------%%
    function t_w_set(source_tw,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        if isempty(str2num(source_tw.String))
            source_tw.String = '';
            msgboxText =  ['Measurement Tool - No measurement window was set'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        Measure= ERPMTops.m_t_type.Value;
        switch Measure%Find the label of the selected item, the defualt one is 1 (Mean amplitude between two fixed latencies)
            case 1
                moption = 'meanbl';% Mean amplitude
            case 2
                moption = 'peakampbl';
            case 3 % Peak amplitude (P vs. N)
                moption = 'peakampbl';
            case  4
                moption= 'peaklatbl';
            case 5
                moption= 'peaklatbl';
            case  6
                moption= 'fpeaklat';
            case 7
                moption= 'fpeaklat';
            otherwise%if the measurement type comes from Advanced option
                MeasureName_other = {'fareatlat','fninteglat','fareanlat','fareaplat',...
                    'areat','ninteg','areap','arean','instabl'};
                try
                    moption=  MeasureName_other{Measure-7};
                catch
                    moption=  'fareatlat';
                end
        end
        latency = unique_bc2(str2num(source_tw.String));
        if ismember_bc2({moption}, {'instabl'})
            if length(latency)~=1
                msgboxText =  ['Measurement Tool -',32,moption ' only needs 1 latency value'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        else
            if length(latency)~=2
                msgboxText =  ['Measurement Tool -',32,moption ' needs 2 latency values'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                source_tw.String = '';
                return;
            else
                if latency(1)>=latency(2)
                    msgboxText =  ['Measurement Tool -For latency range, lower time limit must be on the left.',32,...
                        'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    source_tw.String = '';
                    return;
                end
            end
        end
    end


%-------------------------Baseline period---------------------------------
    function m_t_TW_ops(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        try
            Baseline =   ERPMTops.def_erpvalue{10};
            Answer = f_ERP_meas_basecorr(Baseline);
        catch
            Answer = f_ERP_meas_basecorr('none');
        end
        
        if isempty(Answer)
            return;
        end
        ERP_times = observe_ERPDAT.ERP.times;
        latency = str2num(Answer);
        if ~isempty(latency)
            if latency(1)>=latency(2)
                msgboxText =  ['Measurement Tool - The first latency should be smaller than the second one'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if latency(1)< ERP_times(1)
                msgboxText =  ['Measurement Tool - The defined first latency should be larger than',32, num2str(ERP_times(1)),'ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if latency(2)> ERP_times(end)
                msgboxText =  ['Measurement Tool - The defined second latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if latency(1)> ERP_times(end)
                msgboxText =  ['Measurement Tool - The defined first latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
    end

%%------------------File name setting for the output file.----------------
    function file_name_set(source_file_name,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        ERPMTops.apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.apply.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
    end

%%-------------------Path setting to save the measurement results----------
    function out_file_option(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPMTops.m_t_value.ForegroundColor = [1 1 1];
        erp_measurement_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        ERPMTops.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_mesuretool',1);
        
        if strcmp(ERPMTops.def_erpvalue{18},'wide')
            FileFormat = 1;
        else
            FileFormat = 0;
        end
        pathName_folder_default =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName_folder_default)
            pathName_folder_default = cd;
        end
        FileName =  ERPMTops.m_t_file.String;
        [pathNamex, fname, ext] = fileparts(FileName);
        if isempty(fname)
            fname = 'save_erpvalues';
        end
        if isempty(pathNamex)
            pathNamex = pathName_folder_default;
        end
        
        try
            Binlabel = ERPMTops.def_erpvalue{11};
        catch
            Binlabel = 'off';
        end
        if strcmpi(Binlabel,'off')
            binlabop   = 0; % 0: bin# as bin label for table, 1 bin label
        else
            binlabop   = 1;
        end
        
        try
            SendtoWorkspace = ERPMTops.def_erpvalue{17};
        catch
            SendtoWorkspace = 'off';
        end
        if strcmpi(SendtoWorkspace,'off')
            send2ws    = 0; % 1 send to ws, 0 dont do
        else
            send2ws    = 1;
        end
        
        try
            IncludeLat =  ERPMTops.def_erpvalue{20} ;
        catch
            IncludeLat = 'off';
        end
        if strcmpi(IncludeLat,'on')
            inclate    = 1;
        else
            inclate    = 0;
        end
        
        Answer = f_ERP_meas_format_path(FileFormat,fullfile(pathNamex,fname),inclate,send2ws,binlabop);
        if isempty(Answer)
            return;
        end
        if Answer{1}==0 % 0 means "long format"; 1 means "wide format"
            foutputstr = 'long';
        else
            foutputstr = 'wide';
        end
        ERPMTops.def_erpvalue{18} = foutputstr;
        ERPMTops.m_t_file.String = Answer{2};
        
        binlabop = Answer{5};%%Binlabel
        if binlabop
            ERPMTops.def_erpvalue{11} = 'on';
        else
            ERPMTops.def_erpvalue{11} = 'off';
        end
        
        send2ws = Answer{4};
        if send2ws
            ERPMTops.def_erpvalue{17} = 'on';
        else
            ERPMTops.def_erpvalue{17} = 'off';
        end
        inclate = Answer{3};
        if inclate
            ERPMTops.def_erpvalue{20} = 'on' ;
        else
            ERPMTops.def_erpvalue{20} = 'off' ;
        end
    end


%%--------------------Apply the set parameters to selected ERPset----------
    function erp_m_t_savalue(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
        ERPMTops.m_t_value.ForegroundColor = [0 0 0];
        erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [1 1 1];
        ERPMTops.cancel.ForegroundColor = [0 0 0];
        ERPMTops.apply.BackgroundColor =  [1 1 1];
        ERPMTops.apply.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_mesuretool',0);
        
        pathName_folder =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName_folder)
            pathName_folder =  cd;
        end
        ERPArraydef = estudioworkingmemory('selectederpstudio');
        if isempty(ERPArraydef) || any(ERPArraydef> length(observe_ERPDAT.ALLERP))
            ERPArraydef =  observe_ERPDAT.CURRENTERP;
        end
        ERPsetArray =  str2num(ERPMTops.m_t_erpset.String);
        if isempty(ERPsetArray) || any(ERPsetArray(:)>length(observe_ERPDAT.ALLERP))
            ERPsetArray =  ERPArraydef;
        end
        
        MeasureName = {'meanbl','peakampbl', 'peaklatbl','fpeaklat','fareatlat','fninteglat','fareanlat','fareaplat',...
            'areat','ninteg','areap','arean','instabl'};
        [C,IA] = ismember_bc2({ERPMTops.def_erpvalue{7}}, MeasureName);
        if ~any(IA) || isempty(IA)
            IA =1;
        end
        if isempty(ERPMTops.m_t_file.String)
            msgboxText =  ['Measurement Tool - Please set a name for the output file'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        latency = str2num(ERPMTops.m_t_TW.String);
        if isempty(latency)
            msgboxText =  ['Measurement Tool - Please define the measurement window'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        moption = ERPMTops.def_erpvalue{7};
        
        if isempty(moption)
            msgboxText =  ['Measurement Tool - User must specify a type of measurement'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
            if length(latency)~=1
                msgboxText =  ['Measurement Tool - ',32, moption,32, ' only needs 1 latency value'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            if length(latency)~=2
                msgboxText =  ['Measurement Tool - ',32,moption,32, ' needs 2 latency values.'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            else
                if latency(1)>=latency(2)
                    msgboxText =  ['Measurement Tool - For latency range, lower time limit must be on the left.',32,...
                        'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
        end
        
        binArray = str2num(ERPMTops.m_t_bin.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binArray, [],1);
        if chk(1)
            msgboxText =  ['Measurement Tool - ',32,msgboxText];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        chanArray = str2num(ERPMTops.m_t_chan.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, [],chanArray,2);
        if chk(2)
            msgboxText =  ['Measurement Tool - ',32,msgboxText];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        FileName =  ERPMTops.m_t_file.String;
        [pathNamex, fname, ext] = fileparts(FileName);
        if isempty(fname)
            msgboxText =  ['Measurement Tool - Please give a name to the output file'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if isempty(pathNamex)
            ERPMTops.m_t_file.String = fullfile(pathName_folder,fname);
        end
        FileName=ERPMTops.m_t_file.String;
        estudioworkingmemory('f_ERP_proces_messg',' Measurement Tool (Save values)');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        %%check if the file already exists?
        if exist(FileName, 'file')~=0
            msgboxText =  ['This file already exists.\n'...;
                'Would you like to overwrite it?'];
            title  = 'Estudio: WARNING!';
            button = askquest(sprintf(msgboxText), title);
            if ~strcmpi(button,'Yes')
                return
            end
        end
        
        ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
        ERPMTops.m_t_value.ForegroundColor = [0 0 0];
        erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [1 1 1];
        ERPMTops.cancel.ForegroundColor = [0 0 0];
        ERPMTops.apply.BackgroundColor =  [1 1 1];
        ERPMTops.apply.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_mesuretool',0);
        
        ERPMTops.Paras{1} = ERPMTops.m_t_type.Value;
        ERPMTops.Paras{2} = str2num(ERPMTops.m_t_erpset.String);
        ERPMTops.Paras{3} = str2num(ERPMTops.m_t_bin.String);
        ERPMTops.Paras{4} = str2num(ERPMTops.m_t_chan.String);
        ERPMTops.Paras{5} = str2num(ERPMTops.m_t_TW.String);
        ERPMTops.Paras{6} = ERPMTops.m_t_file.String;
      
   
        ALLERP =observe_ERPDAT.ALLERP;
        if ~isempty(latency)
            [~, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP, latency, binArray, chanArray,...
                'Erpsets', ERPsetArray, 'Measure',MeasureName{IA}, 'Component', ERPMTops.def_erpvalue{8},...
                'Resolution', ERPMTops.def_erpvalue{9}, 'Baseline', ERPMTops.def_erpvalue{10}, 'Binlabel', ERPMTops.def_erpvalue{11},...
                'Peakpolarity',ERPMTops.def_erpvalue{12}, 'Neighborhood', ERPMTops.def_erpvalue{13}, 'Peakreplace',ERPMTops.def_erpvalue{14},...
                'Filename', FileName, 'Warning','on','SendtoWorkspace', ERPMTops.def_erpvalue{17}, 'Append', 'off',...
                'FileFormat',ERPMTops.def_erpvalue{18},'Afraction', ERPMTops.def_erpvalue{15}, 'Mlabel', ERPMTops.def_erpvalue{19},...
                'Fracreplace', ERPMTops.def_erpvalue{16},'IncludeLat',ERPMTops.def_erpvalue{20}, 'InterpFactor',ERPMTops.def_erpvalue{21},...
                'PeakOnset',ERPMTops.def_erpvalue{22},'History', 'gui');
            %%%------------Save history to current session--------------
            try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
            for Numoferp = 1:length(ERPsetArray)
                if Numoferp ==length(ERPsetArray)
                    [observe_ERPDAT.ALLERP(ERPsetArray(Numoferp)), ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(ERPsetArray(Numoferp)), ALLERPCOM, erpcom,2);
                else
                    [observe_ERPDAT.ALLERP(ERPsetArray(Numoferp)), ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(ERPsetArray(Numoferp)), ALLERPCOM, erpcom,1);
                end
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',erpcom);
            %%---------------save the applied parameters using estudioworkingmemory function--------------------
            Measure = MeasureName{IA};
            if strcmp(ERPMTops.def_erpvalue{11},'off')
                Binlabel = 0;
            else
                Binlabel = 1;
            end
            if strcmp(ERPMTops.def_erpvalue{12},'negative')
                Peakpolarity = 0;
            else
                Peakpolarity = 1;
            end
            
            if strcmpi(ERPMTops.def_erpvalue{14},'absolute')
                Peakreplace = 1;
            elseif strcmpi(ERPMTops.def_erpvalue{14},'NaN')
                Peakreplace = 0; % 1 abs peak , 0 Nan
            elseif strcmpi(ERPMTops.def_erpvalue{14},'errormsg')
                Peakreplace = -1;
            end
            
            %%Fractional area latency replacement
            if ismember_bc2({Measure}, {'fareatlat', 'fninteglat','fareanlat','fareaplat'}) % Fractional area latency replacement
                if strcmpi(ERPMTops.def_erpvalue{16},'NaN')%% latency : closet 0, NAN 1, error 2
                    Fracreplace = 0; %  NaN
                else
                    Fracreplace = 2;
                end
            else
                if strcmpi(ERPMTops.def_erpvalue{16},'absolute')
                    Fracreplace = 1;
                elseif  strcmpi(ERPMTops.def_erpvalue{16},'errormsg')
                    Fracreplace = -1;
                else
                    Fracreplace = 0;
                end
            end
            
            
            if strcmp(ERPMTops.def_erpvalue{17},'off')
                SendtoWorkspace=0;
            else
                SendtoWorkspace=1;
            end
            
            if strcmp(ERPMTops.def_erpvalue{18},'wide')
                FileFormat = 0;
            else
                FileFormat = 1;
            end
            
            if strcmp(ERPMTops.def_erpvalue{20},'no')
                IncludeLat = 0;
            else
                IncludeLat = 1;
            end
            
            estudioworkingmemory('pop_geterpvalues', {0, ERPsetArray, FileName, latency,...
                binArray, chanArray, Measure, ERPMTops.def_erpvalue{8}, ERPMTops.def_erpvalue{9}, ERPMTops.def_erpvalue{10},...
                Binlabel, Peakpolarity,ERPMTops.def_erpvalue{13},Peakreplace,...
                ERPMTops.def_erpvalue{15}, Fracreplace,SendtoWorkspace, FileFormat, ERPMTops.def_erpvalue{19},...
                IncludeLat, ERPMTops.def_erpvalue{21}, ERPMTops.def_erpvalue{22}});
        end
        observe_ERPDAT.Count_currentERP = 20;
        observe_ERPDAT.Process_messg =2;
    end

%%---------------------Apply measurement-----------------------------------
    function erp_m_t_view(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
        ERPMTops.m_t_value.ForegroundColor = [0 0 0];
        erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [1 1 1];
        ERPMTops.cancel.ForegroundColor = [0 0 0];
        ERPMTops.apply.BackgroundColor =  [1 1 1];
        ERPMTops.apply.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_mesuretool',0);
        
        ERPsetArray =  str2num(ERPMTops.m_t_erpset.String);
        if isempty(ERPsetArray) || any(ERPsetArray>length(observe_ERPDAT.ALLERP))
            ERPsetArray =  ERPArraydef;
        end
        
        MeasureName = {'meanbl','peakampbl', 'peaklatbl','fpeaklat','fareatlat','fninteglat','fareanlat','fareaplat',...
            'areat','ninteg','areap','arean','instabl'};
        [C,IA] = ismember_bc2({ERPMTops.def_erpvalue{7}}, MeasureName);
        if ~any(IA) || isempty(IA)
            IA =1;
        end
        
        latency = str2num(ERPMTops.m_t_TW.String);
        if isempty(latency)
            msgboxText =  ['Measurement Tool > Preview - Please define the measurement window'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        moption = ERPMTops.def_erpvalue{7};
        
        if isempty(moption)
            msgboxText =  ['Measurement Tool -  Preview - User must specify a type of measurement'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
            if length(latency)~=1
                msgboxText =  ['Measurement Tool > Preview - ',32, moption,32, ' only needs 1 latency value'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            if length(latency)~=2
                msgboxText =  ['Measurement Tool > Preview - ',32,moption,32, ' needs 2 latency values.'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            else
                if latency(1)>=latency(2)
                    msgboxText =  ['Measurement Tool > Preview - For latency range, lower time limit must be on the left.',32,...
                        'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
        end
        binArray = str2num(ERPMTops.m_t_bin.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binArray, [],1);
        if chk(1)
            msgboxText =  ['Measurement Tool > Preview - ',32,msgboxText];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        chanArray = str2num(ERPMTops.m_t_chan.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, [],chanArray,2);
        if chk(2)
            msgboxText =  ['Measurement Tool > Preview - ',32,msgboxText];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        FileName =  ERPMTops.m_t_file.String;
        [pathNamex, fname, ext] = fileparts(FileName);
        
        FileName=ERPMTops.m_t_file.String;
        estudioworkingmemory('f_ERP_proces_messg',' Measurement Tool > Preview');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
        ERPMTops.m_t_value.ForegroundColor = [0 0 0];
        erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [1 1 1];
        ERPMTops.cancel.ForegroundColor = [0 0 0];
        ERPMTops.apply.BackgroundColor =  [1 1 1];
        ERPMTops.apply.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_mesuretool',0);
        ERPMTops.Paras{1} = ERPMTops.m_t_type.Value;
        ERPMTops.Paras{2} = str2num(ERPMTops.m_t_erpset.String);
        ERPMTops.Paras{3} = str2num(ERPMTops.m_t_bin.String);
        ERPMTops.Paras{4} = str2num(ERPMTops.m_t_chan.String);
        ERPMTops.Paras{5} = str2num(ERPMTops.m_t_TW.String);
        ERPMTops.Paras{6} = ERPMTops.m_t_file.String;
        estudioworkingmemory('ERPTab_mtviewer',1);
        
        if ~isempty(latency)
            %%---------------save the applied parameters using estudioworkingmemory function--------------------
            Measure = MeasureName{IA};
            if strcmp(ERPMTops.def_erpvalue{11},'off')
                Binlabel = 0;
            else
                Binlabel = 1;
            end
            if strcmp(ERPMTops.def_erpvalue{12},'negative')
                Peakpolarity = 0;
            else
                Peakpolarity = 1;
            end
            
            if strcmpi(ERPMTops.def_erpvalue{14},'absolute')
                Peakreplace = 1;
            elseif strcmpi(ERPMTops.def_erpvalue{14},'NaN')
                Peakreplace = 0; % 1 abs peak , 0 Nan
            elseif strcmpi(ERPMTops.def_erpvalue{14},'errormsg')
                Peakreplace = -1;
            end
            
            %%Fractional area latency replacement
            if ismember_bc2({Measure}, {'fareatlat', 'fninteglat','fareanlat','fareaplat'}) % Fractional area latency replacement
                if strcmpi(ERPMTops.def_erpvalue{16},'NaN')%% latency : closet 0, NAN 1, error 2
                    Fracreplace = 0; %  NaN
                else
                    Fracreplace = 2;
                end
            else
                if strcmpi(ERPMTops.def_erpvalue{16},'absolute')
                    Fracreplace = 1;
                elseif  strcmpi(ERPMTops.def_erpvalue{16},'errormsg')
                    Fracreplace = -1;
                else
                    Fracreplace = 0;
                end
            end
            
            if strcmp(ERPMTops.def_erpvalue{17},'off')
                SendtoWorkspace=0;
            else
                SendtoWorkspace=1;
            end
            if strcmp(ERPMTops.def_erpvalue{18},'wide')
                FileFormat = 0;
            else
                FileFormat = 1;
            end
            if strcmp(ERPMTops.def_erpvalue{20},'no')
                IncludeLat = 0;
            else
                IncludeLat = 1;
            end
            
            estudioworkingmemory('pop_geterpvalues', {0, ERPsetArray, FileName, latency,...
                binArray, chanArray, Measure, ERPMTops.def_erpvalue{8}, ERPMTops.def_erpvalue{9}, ERPMTops.def_erpvalue{10},...
                Binlabel, Peakpolarity,ERPMTops.def_erpvalue{13},Peakreplace,...
                ERPMTops.def_erpvalue{15}, Fracreplace,SendtoWorkspace, FileFormat, ERPMTops.def_erpvalue{19},...
                IncludeLat, ERPMTops.def_erpvalue{21}, ERPMTops.def_erpvalue{22}});
            estudioworkingmemory('ViewerFlag', 1);
            observe_ERPDAT.Count_currentERP=1;
            estudioworkingmemory('f_ERP_proces_messg','Measurement Tool > Preview: The main ERPLAB Studio window will be frozen until you close the Viewer window for the Measurement Tool');
            observe_ERPDAT.Process_messg =4; %%Marking for the procedure has been started.
            
            f_erp_viewerGUI(observe_ERPDAT.ALLERP(ERPsetArray),1,binArray,chanArray);
            try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = [];  end
            ERPCOM = ['f_erp_viewerGUI(ALLERP(',vect2colon(ERPsetArray),'),1,',...
                vect2colon(binArray),',',vect2colon(chanArray),');'];
            ALLERPCOM{end+1} = char(ERPCOM);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
        end
        estudioworkingmemory('ViewerFlag', 0);
        observe_ERPDAT.Count_currentERP=1;
        observe_ERPDAT.Process_messg =2;
    end

%%--------Settting if the current panel is active or not based on the selected ERPsets------------
    function  Count_currentERP_change(~,~)
        if observe_ERPDAT.Count_currentERP~=14
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT') || ViewerFlag==1
            Enable_label = 'off';
            
        else
            Enable_label = 'on';
        end
        ERPMTops.m_t_type.Enable = Enable_label;
        ERPMTops.m_t_type_ops.Enable = Enable_label;
        ERPMTops.m_t_bin.Enable = Enable_label;
        ERPMTops.m_t_bin_ops.Enable = Enable_label;
        ERPMTops.m_t_chan.Enable = Enable_label;
        ERPMTops.m_t_chan_ops.Enable = Enable_label;
        ERPMTops.m_t_TW.Enable = Enable_label;
        ERPMTops.m_t_TW_ops.Enable = Enable_label;
        ERPMTops.m_t_file.Enable = Enable_label;
        ERPMTops.m_t_file_ops.Enable = Enable_label;
        ERPMTops.m_t_viewer.Enable = Enable_label;
        ERPMTops.m_t_advanced.Enable = Enable_label;
        ERPMTops.m_t_erpset.Enable = Enable_label;
        ERPMTops.m_t_erpset_ops.Enable = Enable_label;
        ERPMTops.cancel.Enable = Enable_label;
        ERPMTops.apply.Enable = Enable_label;
        ERPMTops.m_t_value.Enable = Enable_label;
        if strcmpi(Enable_label,'off')
            observe_ERPDAT.Count_currentERP=15;
            return;
        end
        
        if  ~isempty(observe_ERPDAT.ERP) && ~isempty(observe_ERPDAT.ALLERP)
            ERPArray= estudioworkingmemory('selectederpstudio');
            if isempty(ERPArray) || any(ERPArray> length(observe_ERPDAT.ALLERP))
                ERPArray =  length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                observe_ERPDAT.CURRENTERP = ERPArray;
                estudioworkingmemory('selectederpstudio',ERPArray);
            end
            ERPArray = vect2colon(ERPArray,'Sort','on');
            ERPArray = erase(ERPArray,{'[',']'});
            %             ERPMTops.m_t_erpset.String= ERPArray;%%Dec 20 2022
            BinArray = estudioworkingmemory('ERP_BinArray');
            ChanArray =  estudioworkingmemory('ERP_ChanArray');
            [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, BinArray, [],1);
            if chk(1)==1
                BinArray =  [1:observe_ERPDAT.ERP.nbin];
            end
            BinArray = vect2colon(BinArray,'Sort', 'on');
            BinArray = erase(BinArray,{'[',']'});
            
            [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP,[], ChanArray,2);
            if chk(2)==1
                ChanArray =  [1:observe_ERPDAT.ERP.nchan];
            end
            ChanArray = vect2colon(ChanArray,'Sort', 'on');
            ChanArray = erase(ChanArray,{'[',']'});
            %             ERPMTops.m_t_chan.String = ChanArray;
        end
        observe_ERPDAT.Count_currentERP=15;
    end

%%-----------------------cancel--------------------------------------------
    function ERPmeasr_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=10
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
        ERPMTops.m_t_value.ForegroundColor = [0 0 0];
        erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [1 1 1];
        ERPMTops.cancel.ForegroundColor = [0 0 0];
        ERPMTops.apply.BackgroundColor =  [1 1 1];
        ERPMTops.apply.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_mesuretool',0);
        
        m_t_type = ERPMTops.Paras{1} ;
        if isempty(m_t_type) || numel(m_t_type)~=1 || any(m_t_type>20)
            m_t_type =1;  ERPMTops.Paras{1} =1;
        end
        ERPMTops.m_t_type.Value=m_t_type;
        %%erpsets
        m_t_erpset = ERPMTops.Paras{2};
        if isempty(m_t_erpset) || any(m_t_erpset> length(observe_ERPDAT.ALLERP))
            m_t_erpset =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = m_t_erpset;
            estudioworkingmemory('selectederpstudio',m_t_erpset);
            ERPMTops.Paras{2} = m_t_erpset;
        end
        m_t_erpset = vect2colon(m_t_erpset,'Sort', 'on');
        m_t_erpset = erase(m_t_erpset,{'[',']'});
        ERPMTops.m_t_erpset.String= m_t_erpset;
        %%binarray
        BinArray= ERPMTops.Paras{3};
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, BinArray, [],1);
        if chk(1)==1
            BinArray =  [1:observe_ERPDAT.ERP.nbin];
            ERPMTops.Paras{3} = BinArray;
        end
        BinArray = vect2colon(BinArray,'Sort', 'on');
        BinArray = erase(BinArray,{'[',']'});
        ERPMTops.m_t_bin.String = BinArray;
        %%chanarray
        ChanArray=ERPMTops.Paras{4};
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP,[], ChanArray,2);
        if chk(2)==1
            ChanArray =  [1:observe_ERPDAT.ERP.nchan];
            ERPMTops.Paras{4}= ChanArray;
        end
        ChanArray = vect2colon(ChanArray,'Sort', 'on');
        ChanArray = erase(ChanArray,{'[',']'});
        ERPMTops.m_t_chan.String = ChanArray;
        %%latency
        latency = ERPMTops.Paras{5};
        if isempty(latency) || any(latency<observe_ERPDAT.ERP.times(1)) || any(latency>observe_ERPDAT.ERP.times(end))
            latency = [];
            ERPMTops.Paras{5}=[];
        end
        ERPMTops.m_t_TW.String = num2str(latency);
        %%path name
        try pathanme = ERPMTops.Paras{6}; catch pathanme=  ''; ERPMTops.Paras{6}='';end
        ERPMTops.m_t_file.String = pathanme;
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_mt_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_mesuretool');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            erp_m_t_view();
            ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
            ERPMTops.m_t_value.ForegroundColor = [0 0 0];
            erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            ERPMTops.cancel.BackgroundColor =  [1 1 1];
            ERPMTops.cancel.ForegroundColor = [0 0 0];
            ERPMTops.apply.BackgroundColor =  [1 1 1];
            ERPMTops.apply.ForegroundColor = [0 0 0];
            estudioworkingmemory('ERPTab_mesuretool',0);
        else
            return;
        end
    end

    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=10
            return;
        end
        ERPMTops.m_t_value.BackgroundColor =  [1 1 1];
        ERPMTops.m_t_value.ForegroundColor = [0 0 0];
        erp_measurement_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        ERPMTops.cancel.BackgroundColor =  [1 1 1];
        ERPMTops.cancel.ForegroundColor = [0 0 0];
        ERPMTops.apply.BackgroundColor =  [1 1 1];
        ERPMTops.apply.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_mesuretool',0);
        ERPMTops.m_t_type.Value=1;
        ERPArray= estudioworkingmemory('selectederpstudio');
        if ~isempty(observe_ERPDAT.ALLERP)
            if isempty(ERPArray) || any(ERPArray> length(observe_ERPDAT.ALLERP))
                ERPArray =  length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                observe_ERPDAT.CURRENTERP = ERPArray;
                estudioworkingmemory('selectederpstudio',ERPArray);
            end
        end
        ERPArray = vect2colon(ERPArray,'Sort', 'on');
        ERPArray = erase(ERPArray,{'[',']'});
        ERPMTops.m_t_erpset.String= ERPArray;%%Dec 20 2022
        try
            BinArray =  [1:observe_ERPDAT.ERP.nbin];
        catch
            BinArray = [];
        end
        BinArray = vect2colon(BinArray,'Sort', 'on');
        BinArray = erase(BinArray,{'[',']'});
        ERPMTops.m_t_bin.String = BinArray;
        try
            ChanArray =  [1:observe_ERPDAT.ERP.nchan];
        catch
            ChanArray = [];
        end
        ChanArray = vect2colon(ChanArray,'Sort', 'on');
        ChanArray = erase(ChanArray,{'[',']'});
        ERPMTops.m_t_chan.String = ChanArray;
        ERPMTops.m_t_TW.String = '';
        ERPMTops.m_t_file.String = '';
        ERPMTops.def_erpvalue{18} = 'wide';%%file format
        ERPMTops.def_erpvalue{11} = 'off';%%Binlabel
        ERPMTops.def_erpvalue{17} = 'off';%%send2ws
        ERPMTops.def_erpvalue{20} = 'off' ;%%inclate
        observe_ERPDAT.Reset_erp_paras_panel=11;
    end

end%Progem end