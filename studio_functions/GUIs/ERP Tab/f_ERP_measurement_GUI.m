%%% ERPLAB Studio: ERO meansurement panel


%Author: Guanghui ZHANG
%Center for Mind and Brain
% University of California, Davis
%Davis, CA
% 2022


function varargout = f_ERP_measurement_GUI(varargin)

global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@erpschange);
% addlistener(observe_ERPDAT,'ERP_change',@drawui_CB);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'ERP_chan_change',@ERP_chan_changed);
addlistener(observe_ERPDAT,'ERP_bin_change',@ERP_bin_changed);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERP_change);

%%Get the parameters for pop_geterpvalues used in the last time.
def_erpvalue   = erpworkingmemory('pop_geterpvalues');

try
    ALLERP = evalin('base','ALLERP');
    CurrentERPSet = evalin('base','CURRENTERP');
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
% end


EStudio_erp_m_t_p = S_IN;


%%---------------------------gui-------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    erp_measurement_box = uiextras.BoxPanel('Parent', fig, 'Title', 'ERP Measurement Tool', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    erp_measurement_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Measurement Tool', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    erp_measurement_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Measurement Tool', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

ERPMTops = struct();

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
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_m_t_gui(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        ERPMTops.mt = uiextras.VBox('Parent',erp_measurement_box,'Spacing',1,'BackgroundColor',ColorB_def);
        try
            SelectedIndex = EStudio_erp_m_t_p.Erpsets;
        catch
            SelectedIndex = observe_ERPDAT.CURRENTERP;
        end
        if strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
            checked_curr_index = 1;
        else
            checked_curr_index = 0;
        end
        checked_ERPset_Index = f_checkerpsets(observe_ERPDAT.ALLERP,SelectedIndex);
        if checked_curr_index || any(checked_ERPset_Index)
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        
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
        ERPMTops.out_file_title = uicontrol('Style','text','Parent',  ERPMTops.measurement_type,'String','File&Path:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.out_file_title,'HorizontalAlignment','left');
        
        
        %%-----------------------------Setting for second column---------------
        %%2A
        mesurement_type = {'Mean amplitude between two fixed latencies','Local peak amplitude (Negative)','Local peak amplitude (Positive)','Local peak latency (Negative)',...
            'Local peak latency (Positive)','Fractional peak latency (Negative)','Fractional peak latency (Positive)','Fractional area latency: Rectified area (negative values become positive)',...
            'Fractional area latency: Numrical integration (area for negatives substracted from area for positives)',...
            'Fractional area latency: Area for negative waveforms (positive values will be zeroed)','Fractional area latency: Area for positive waveforms (negative values will be zeroed)',...
            'Numerical integration/Area between two fixed latencies: Rectified area (Negative values become positive)',...
            'Numerical integration/Area between two fixed latencies: Numerical intergration (area for negative substracted from area for positive)',...
            'Numerical integration/Area between two fixed latencies: Area for negative waveforms (positive values will be zeroed)',...
            'Numerical integration/Area between two fixed latencies: Area for positive waveforms (negative values will be zeroed)',...
            'Numerical integration/Area between two (automatically detected)zero-crossing latencies: Rectified area (Negative values become positive)',...
            'Numerical integration/Area between two (automatically detected)zero-crossing latencies: Numerical intergration (area for negative substracted from area for positive)',...
            'Numerical integration/Area between two (automatically detected)zero-crossing latencies: Area for negative waveforms (positive values will be zeroed)',...
            'Numerical integration/Area between two (automatically detected)zero-crossing latencies: Area for positive waveforms (negative values will be zeroed)',...
            'Instantaneous amplitude'};
        ERPMTops.m_t_type = uicontrol('Style', 'popup','Parent',ERPMTops.measurement_type,'String',mesurement_type,'callback',@Mesurement_type,'Enable',Enable_label,'FontSize',FonsizeDefault);
        if isempty(EStudio_erp_m_t_p.Measure) || ~ischar(EStudio_erp_m_t_p.Measure)
            EStudio_erp_m_t_p.Measure = 'meanbl';
        end
        switch EStudio_erp_m_t_p.Measure%Find the label of the selected item, the defualt one is 1 (Mean amplitude between two fixed latencies)
            case 'meanbl'% Mean amplitude
                set(ERPMTops.m_t_type,'Value',1);
            case 'peakampbl'% Local peak amplitude (P vs. N)
                if strcmp(EStudio_erp_m_t_p.Peakpolarity,'positive')
                    set(ERPMTops.m_t_type,'Value',3);
                else
                    set(ERPMTops.m_t_type,'Value',2);
                end
            case  'peaklatbl'%Peak latency (P vs. N)
                if strcmp(EStudio_erp_m_t_p.Peakpolarity,'positive')
                    set(ERPMTops.m_t_type,'Value',5);
                elseif strcmp(EStudio_erp_m_t_p.Peakpolarity,'negative')
                    set(ERPMTops.m_t_type,'Value',4);
                end
            case  'fpeaklat'%Fractional Peak latency (P vs. N)
                if strcmp(EStudio_erp_m_t_p.Peakpolarity,'positive')
                    set(ERPMTops.m_t_type,'Value',7);
                elseif strcmp(EStudio_erp_m_t_p.Peakpolarity,'negative')
                    set(ERPMTops.m_t_type,'Value',6);
                end
                
            otherwise%if the measurement type comes from Advanced option
                MeasureName_other = {'fareatlat','fninteglat','fareaplat','fareanlat',...
                    'areat','ninteg','areap','arean',...
                    'areazt','nintegz','areazp','areazn',...
                    'instabl'};
                [C,IA] = ismember_bc2({EStudio_erp_m_t_p.Measure}, MeasureName_other);
                if any(IA) || isempty(IA)
                    set(ERPMTops.m_t_type,'Value',1);
                else
                    set(ERPMTops.m_t_type,'Value',IA+7);
                end
        end
        
        %%2B ERPset custom
        SelectedERP_Index =  estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP_Index) || max(SelectedERP_Index)> length(observe_ERPDAT.ALLERP)
            ERPMTops.m_t_erpset = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String', '','callback',@erpset_custom,'Enable',Enable_label,'FontSize',FonsizeDefault); %
        else
            ERPMTops.m_t_erpset = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String', num2str(vect2colon(SelectedERP_Index,'Sort','on')),'callback',@erpset_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);
        end
        
        %%2C
        if isempty(EStudio_erp_m_t_p.binArray)
            ERP_CURRENT = evalin('base','ERP');
            if isempty(ERP_CURRENT.nbin) || any(ERP_CURRENT.nbin)
                ERPMTops.m_t_bin = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String', [],'callback',@binSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault); %
            else
                ERPMTops.m_t_bin = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String', num2str(vect2colon(1:ERP_CURRENT.nbin,'Sort','on')),'callback',@binSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);
            end
        else
            ERPMTops.m_t_bin = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',num2str(vect2colon(EStudio_erp_m_t_p.binArray,'Sort','on')),'callback',@binSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);
        end
        %%2D
        if isempty(EStudio_erp_m_t_p.chanArray) || ~any(EStudio_erp_m_t_p.chanArray)
            try
                ERP_CURRENT = evalin('base','ERP');
                if isempty(ERP_CURRENT.chanArray) || any(ERP_CURRENT.chanArray)
                    ERPMTops.m_t_chan = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',[],'callback',@chanSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);%vect2colon(observe_ERPDAT.ERP_chan,'Sort', 'on')
                else
                    ERPMTops.m_t_chan = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',num2str(vect2colon(1:ERP_CURRENT.nchan,'Sort','on')),'callback',@chanSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);
                end
            catch
                ERPMTops.m_t_chan = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',[],'callback',@chanSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);
            end
        else
            ERPMTops.m_t_chan = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',num2str(vect2colon(EStudio_erp_m_t_p.chanArray,'Sort','on')),'callback',@chanSelect_custom,'Enable',Enable_label,'FontSize',FonsizeDefault);
        end
        %%2E
        if isempty(EStudio_erp_m_t_p.latency)
            ERPMTops.m_t_TW = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String','0.000','callback',@t_w_set,'Enable',Enable_label,'FontSize',FonsizeDefault);
        else
            ERPMTops.m_t_TW = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',num2str(EStudio_erp_m_t_p.latency),'callback',@t_w_set,'Enable',Enable_label,'FontSize',FonsizeDefault);
        end
        %%2F
        if isempty(EStudio_erp_m_t_p.Filename)
            ERPMTops.m_t_file = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String','','callback',@file_name_set,'Enable',Enable_label,'FontSize',FonsizeDefault);
        else
            ERPMTops.m_t_file = uicontrol('Style', 'edit','Parent',ERPMTops.measurement_type,'String',EStudio_erp_m_t_p.Filename,'callback',@file_name_set,'Enable',Enable_label,'FontSize',FonsizeDefault);
        end
        
        
        %%-----------Setting for third column--------------------------------
        %%3A
        ERPMTops.m_t_type_ops = uicontrol('Style', 'pushbutton','Parent',ERPMTops.measurement_type,'String','Option','callback',@Mesurement_type_option,'Enable',Enable_label,'FontSize',FonsizeDefault);
        %%3B
        ERPMTops.m_t_erpset_ops = uicontrol('Style','pushbutton','Parent',  ERPMTops.measurement_type,'String','Option','callback',@erpsetop,'Enable',Enable_label,'FontSize',FonsizeDefault);
        %%3C
        ERPMTops.m_t_bin_ops = uicontrol('Style','pushbutton','Parent',  ERPMTops.measurement_type,'String','Option','callback',@binSelect_label,'Enable',Enable_label,'FontSize',FonsizeDefault);
        
        %%3D
        ERPMTops.m_t_chan_ops = uicontrol('Style','pushbutton','Parent', ERPMTops.measurement_type,'String','Option','callback',@chanSelect_label,'Enable',Enable_label,'FontSize',FonsizeDefault);
        %%3E
        ERPMTops.m_t_TW_ops = uicontrol('Style', 'pushbutton','Parent',ERPMTops.measurement_type,'String','Option','callback',@baseline_set,'Enable',Enable_label,'FontSize',FonsizeDefault);
        %%3F
        ERPMTops.m_t_file_ops = uicontrol('Style', 'pushbutton','Parent',ERPMTops.measurement_type,'String','Option','callback',@out_file_option,'Enable',Enable_label,'FontSize',FonsizeDefault);
        set(ERPMTops.measurement_type, 'ColumnSizes',[65 135 65],'RowSizes',[25 25 25 25 25 25]);
        
        
        %%-------------------------Setting for Viewer----------------------
        ERPMTops.mt_viewer = uiextras.HBox('Parent',ERPMTops.mt,'Spacing',1,'BackgroundColor',ColorB_def);
        ERPMTops.m_t_viewer_title = uicontrol('Style', 'text','Parent', ERPMTops.mt_viewer,'String','Viewer:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(ERPMTops.m_t_viewer_title,'HorizontalAlignment','left');
        ERPMTops.m_t_viewer_on = uicontrol('Style', 'radiobutton','Parent', ERPMTops.mt_viewer,'String','On',...
            'callback',@m_t_viewer_on,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        ERPMTops.m_t_viewer_off = uicontrol('Style', 'radiobutton','Parent', ERPMTops.mt_viewer,'String','Off',...
            'callback',@m_t_viewer_off,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        if strcmp(EStudio_erp_m_t_p.Viewer,'on')
            ERPMTops.m_t_viewer_on.Value = 1;
            ERPMTops.m_t_viewer_off.Value =0;
        elseif strcmp(EStudio_erp_m_t_p.Viewer,'off')
            ERPMTops.m_t_viewer_on.Value = 0;
            ERPMTops.m_t_viewer_off.Value =1;
            
        end
        uiextras.Empty('Parent', ERPMTops.mt_viewer,'BackgroundColor',ColorB_def); % 1A
        set(ERPMTops.mt_viewer,'Sizes',[70 60 60 70]);
        
        %%---------------------------Select ERPsets and Run options-----------
        ERPMTops.out_file_run = uiextras.HBox('Parent',ERPMTops.mt,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', ERPMTops.out_file_run);
        uicontrol('Style', 'pushbutton','Parent',ERPMTops.out_file_run,'String','?','callback',@ERPmeasr_help,'Enable','on','FontSize',16);
        uiextras.Empty('Parent', ERPMTops.out_file_run);
        ERPMTops.m_t_value = uicontrol('Style', 'pushbutton','Parent',ERPMTops.out_file_run,'String','Save values','callback',@apply_erp_m_t,'Enable',Enable_label,'FontSize',FonsizeDefault);
        uiextras.Empty('Parent', ERPMTops.out_file_run);
        set(ERPMTops.out_file_run, 'Sizes',[15 105  20 105 15]);
        
        %%ERPMTops end
        set(ERPMTops.mt,'Sizes',[150 25 30]);
    end

%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%-----------------Help------------------------------
    function ERPmeasr_help(~,~)
        web('https://github.com/lucklab/erplab/wiki/ERP-Measurement-Tool','-browser');
    end

%%---------------------------Setting for the Measurement type-----------------------------%%
    function Mesurement_type(source_measure_type,~)
        Select_label = source_measure_type.Value;
        if isempty(Select_label)
            EStudio_erp_m_t_p.Measure = 'meanbl';
        elseif Select_label==1 % Mean amplitude
            EStudio_erp_m_t_p.Measure = 'meanbl';
        elseif Select_label==2 %Peak amplitude
            EStudio_erp_m_t_p.Measure ='peakampbl';
            EStudio_erp_m_t_p.Peakpolarity = 'negative';
        elseif Select_label==3 % Peak amplitude
            EStudio_erp_m_t_p.Measure ='peakampbl';
            EStudio_erp_m_t_p.Peakpolarity = 'positive';
        elseif Select_label==4 % Peak latency
            EStudio_erp_m_t_p.Measure = 'peaklatbl';
            EStudio_erp_m_t_p.Peakpolarity = 'negative';
        elseif Select_label==5 %Peak latency
            EStudio_erp_m_t_p.Measure = 'peaklatbl';
            EStudio_erp_m_t_p.Peakpolarity = 'positive';
            
        elseif Select_label==6 %Fractional Peak latency
            EStudio_erp_m_t_p.Measure ='fpeaklat';
            EStudio_erp_m_t_p.Peakpolarity = 'negative';
        elseif Select_label==7 %Fractional Peak latency
            EStudio_erp_m_t_p.Measure ='fpeaklat';
            EStudio_erp_m_t_p.Peakpolarity = 'positive';
        else
            if Select_label > 7
                MeasureName_other = {'fareatlat','fninteglat','fareanlat','fareaplat',...
                    'areat','ninteg','arean','areap',...
                    'areazt','nintegz','areazn','areazp',...
                    'instabl'};
                EStudio_erp_m_t_p.Measure = MeasureName_other{Select_label-7};
                if 15 < Select_label && Select_label<20
                    mnamex = 'Numerical integration/Area between two (automatically detected) zero-crossing latencies';
                    question = [ '%s\n\nThis tool is still in alpha phase.\n'...
                        'Use it under your responsibility.'];
                    title       = 'ERPLAB Studio: Overwriting Confirmation';
                    button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
                end
            else
                EStudio_erp_m_t_p.Measure =  'meanbl';
            end
        end
        
        S_ws = estudioworkingmemory('geterpvalues');
        S_ws.Measure = EStudio_erp_m_t_p.Measure;
        S_ws.Peakpolarity = EStudio_erp_m_t_p.Peakpolarity;
        estudioworkingmemory('geterpvalues',S_ws);
        
        if strcmp(EStudio_erp_m_t_p.Viewer,'on')
            
            moption = EStudio_erp_m_t_p.Measure;
            latency = EStudio_erp_m_t_p.latency;
            if isempty(moption)
                beep;
                msgboxText =  ['ERP Measurement Tool - User must specify a type of measurement'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                if length(latency)~=1
                    beep;
                    msgboxText =  ['ERP Measurement Tool - ',32,moption ' only needs 1 latency value.'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                    
                end
            else
                if length(latency)~=2
                    beep;
                    msgboxText =  ['ERP Measurement Tool - ',32,moption ' only needs 2 latency values'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                else
                    if latency(1)>=latency(2)
                        beep;
                        msgboxText =  ['ERP Measurement Tool - For latency range, lower time limit must be on the left.\n'...
                            'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    end
                end
            end
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
    end


%%------------Options for the measurement type-----------------------------
    function Mesurement_type_option(~,~)
        try
            S_ws =  estudioworkingmemory('geterpvalues');
            EStudio_erp_m_t_p.Measure = S_ws.Measure;
        catch
            beep;
            msgboxText =  ['ERP Measurement Tool - None of measure types was selected'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        try
            op         = S_ws.Measure;
        catch
            op=  'meanbl';
        end% option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
        try
            dig        = S_ws.Resolution;
        catch
            dig        =3;
        end%Resolution
        try
            Binlabel = S_ws.Binlabel;
        catch
            Binlabel = 'off';
        end
        if strcmpi(Binlabel,'off')
            binlabop   = 0; % 0: bin# as bin label for table, 1 bin label
        else
            binlabop   = 1;
        end
        try
            Peakpolarity = S_ws.Peakpolarity;
        catch
            Peakpolarity = 'negative';
        end
        if strcmpi(Peakpolarity,'negative')
            polpeak    = 0;
        else
            polpeak    = 1; % local peak positive polarity
        end
        try
            sampeak    = S_ws.Neighborhood; % number of samples (one-side) for local peak detection criteria
        catch
            sampeak = 3;
        end
        try
            Peakreplace = S_ws.Peakreplace;
        catch
            Peakreplace = 'absolute';
        end
        if strcmpi(Peakreplace,'absolute')
            locpeakrep = 1;
        else
            locpeakrep = 0; % 1 abs peak , 0 Nan
        end
        try
            frac =  S_ws.Afraction;
        catch
            frac       = 0.5;
        end
        try
            Fracreplace =  S_ws.Fracreplace;
        catch
            Fracreplace = 'NaN';
        end
        
        if strcmpi(Fracreplace,'NaN')
            fracmearep = 0; % def{19}; NaN
        else
            fracmearep = 1; % def{19}; NaN
        end
        try
            SendtoWorkspace = S_ws.SendtoWorkspace;
        catch
            SendtoWorkspace = 'off';
        end
        if strcmpi(SendtoWorkspace,'off')
            send2ws    = 0; % 1 send to ws, 0 dont do
        else
            send2ws    = 1;
        end
        try
            IncludeLat =  S_ws.IncludeLat ;
        catch
            IncludeLat = 'off';
        end
        if strcmpi(IncludeLat,'on')
            
            inclate    = 1;
        else
            inclate    = 0;
        end
        try
            intfactor = S_ws.InterpFactor;
        catch
            intfactor  = 10;
        end
        try
            peakonset =S_ws.PeakOnset;
        catch
            peakonset = 1;
        end
        
        %%Change the modified parameters after the subfucntion was called
        def = { op ,dig,binlabop,polpeak,sampeak,locpeakrep,frac,fracmearep,send2ws,inclate,intfactor,peakonset};
        ERP= observe_ERPDAT.ERP;
        Answer = geterpvaluesparasGUI2(def,ERP);
        
        if isempty(Answer)
            beep;
            disp('User selected cancel');
            return;
        end
        S_ws.Measure = Answer{1};
        S_ws.Resolution=Answer{2};
        binlabop = Answer{3};
        if binlabop
            S_ws.Binlabel = 'on';
        else
            S_ws.Binlabel = 'off';
        end
        
        polpeak= Answer{4};
        if polpeak==0
            S_ws.Peakpolarity     = 'negative';
        else
            S_ws.Peakpolarity     = 'positive';
        end
        
        S_ws.Neighborhood = Answer{5};
        
        locpeakrep = Answer{6};
        if locpeakrep==0
            S_ws.Peakreplace = 'NaN';
        else
            S_ws.Peakreplace = 'absolute';
        end
        
        S_ws.Afraction = Answer{7};
        
        fracmearep= Answer{8};
        if fracmearep==0 % Fractional area latency replacement
            S_ws.Fracreplace = 'NaN';
        else
            if ismember_bc2({S_ws.Measure}, {'fareatlat', 'fninteglat','fareaplat','fareanlat'})
                S_ws.Fracreplace = 'errormsg';
            else
                S_ws.Fracreplace = 'absolute';
            end
        end
        send2ws = Answer{9};
        if send2ws
            S_ws.SendtoWorkspace = 'on';
        else
            S_ws.SendtoWorkspace = 'off';
        end
        inclate = Answer{10};
        if inclate
            S_ws.IncludeLat = 'on' ;
        else
            S_ws.IncludeLat = 'off' ;
        end
        S_ws.InterpFactor=Answer{11};
        S_ws.PeakOnset = Answer{12};
        estudioworkingmemory('geterpvalues',S_ws);
        if strcmp(EStudio_erp_m_t_p.Viewer,'on')
            
            moption = EStudio_erp_m_t_p.Measure;
            latency = EStudio_erp_m_t_p.latency;
            if isempty(moption)
                beep;
                msgboxText =  ['ERP Measurement Tool - User must specify a type of measurement'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                if length(latency)~=1
                    beep;
                    msgboxText =  ['ERP Measurement Tool - ',32,moption ' only needs 1 latency value'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                end
            else
                if length(latency)~=2
                    beep;
                    msgboxText =  ['ERP Measurement Tool - ',32,moption ' needs 2 latency values'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                else
                    if latency(1)>=latency(2)
                        beep;
                        msgboxText =  ['ERP Measurement Tool - For latency range, lower time limit must be on the left.\n'...
                            'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    end
                end
            end
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
        
    end

%%----------------------------ERPset custom--------------------------------
    function erpset_custom(Source,~)
        ERPsetArray = str2num(Source.String);
        ERPsetArraydef =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPsetArray) || max(ERPsetArray)> length(observe_ERPDAT.ALLERP)
            if isempty(ERPsetArraydef) || max(ERPsetArraydef)> length(observe_ERPDAT.ALLERP)
                Source.String = '';
            else
                Source.String = num2str(vect2colon(ERPsetArraydef,'Sort','on'));
            end
            return;
        else
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,ERPsetArray);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            Current_ERP_selected=ERPsetArray(1);
            observe_ERPDAT.CURRENTERP = Current_ERP_selected;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_ERP_selected);
            
            estudioworkingmemory('selectederpstudio',ERPsetArray);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
        
    end

%%-------------Select bins by user custom----------------------------------
    function binSelect_custom(source,~)
        binNums =  str2num(source.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, binNums, [],1);
        
        if chk(1)
            binArray= observe_ERPDAT.ERP_bin;
            source.String = num2str(binArray);
            
            beep;
            msgboxText =  ['ERP Measurement Tool -',32,msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if ~isempty(binNums)
            binNums   = unique_bc2(binNums);
            binList = 1:observe_ERPDAT.ERP.nbin;
            indxlistb = binNums;
            [~,y_check_bin] =find(indxlistb>observe_ERPDAT.ERP.nbin);
            if any(y_check_bin)
                mnamex = ['Label of one of the imported bins was higher than the number of bins (',num2str(observe_ERPDAT.ERP.nbin),').'];
                question = [ '%s\n\n Please input or select bins of interst from "Bin:" on the "ERP Measurement Tool" panel again.\n'];
                title       = 'EStudio: ERP Measurement Tool';
                button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
                return;
            end
            
            indxlistb = indxlistb(indxlistb<=length(binList));
            EStudio_erp_m_t_p.binArray = indxlistb;
            S_ws= estudioworkingmemory('geterpvalues');
            if isempty(S_ws)
                return;
            end
            S_ws.binArray = EStudio_erp_m_t_p.binArray;
            estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
            %Remark the selected bin in bin and Channel selection
            if strcmp(EStudio_erp_m_t_p.Viewer,'on')
                SelectedERP_Index =  estudioworkingmemory('selectederpstudio');
                if isempty(SelectedERP_Index)
                    SelectedERP_Index =  observe_ERPDAT.CURRENTERP;
                    S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
                    estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                    estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
                    estudioworkingmemory('selectederpstudio',SelectedERP_Index);
                end
                
                S_binchan =  estudioworkingmemory('geterpbinchan');
                Select_index = S_binchan.Select_index;
                
                Bin_label_select = indxlistb;
                if isempty(Bin_label_select)
                    beep;
                    disp(['No bin was selected']);
                    return;
                end
                if S_binchan.checked_ERPset_Index(1) ==1% The number of bins varied across the selected erpsets
                    S_binchan.bins{Select_index} = Bin_label_select;
                    S_binchan.bin_n(Select_index) = numel(Bin_label_select);
                else
                    
                    for Numofselecterp = 1:numel(SelectedERP_Index)
                        S_binchan.bins{Numofselecterp} = Bin_label_select;
                        S_binchan.bin_n(Numofselecterp) = numel(Bin_label_select);
                    end
                    
                end
                estudioworkingmemory('geterpbinchan',S_binchan);
            end
            observe_ERPDAT.ERP_bin = indxlistb;
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
    end


%%----------------Option for erpset----------------------------------------
    function erpsetop(~,~)
        ERPsetArraydef = estudioworkingmemory('selectederpstudio');
        if isempty(ERPsetArraydef) || max(ERPsetArraydef)> length(observe_ERPDAT.ALLERP)
            ERPsetArraydef = observe_ERPDAT.CURRENTERP;
        end
        for Numoferpset = 1:length(observe_ERPDAT.ALLERP)
            listname{Numoferpset} = char(strcat(num2str(Numoferpset),'.',observe_ERPDAT.ALLERP(Numoferpset).erpname));
        end
        indxlistb  =ERPsetArraydef;
        
        titlename = 'Select ERPset(s):';
        ERPset_select = browsechanbinGUI(listname, indxlistb, titlename);
        
        if ~isempty(ERPset_select)
            ERPMTops.m_t_erpset.String = num2str(vect2colon(ERPset_select,'Sort','on'));
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,ERPset_select);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            Current_ERP_selected=ERPset_select(1);
            observe_ERPDAT.CURRENTERP = Current_ERP_selected;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_ERP_selected);
            estudioworkingmemory('selectederpstudio',ERPset_select);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        else
            return;
        end
        
    end



%%---------------Bins selection from "Option"------------------------------
    function binSelect_label(Source,~)
        ERP_CURRENT = evalin('base','ERP');
        for Numofbin = 1:length(ERP_CURRENT.bindescr)
            listb{Numofbin} = char(strcat(num2str(Numofbin),'.',ERP_CURRENT.bindescr{Numofbin}));
        end
        try
            indxlistb  =EStudio_erp_m_t_p.binArray;
        catch
            indxlistb = 1:ERP_CURRENT.nbin;
        end
        titlename = 'Select Bin(s):';
        %----------------judge the number of latency/latencies--------
        if ~isempty(listb)
            bin_label_select = browsechanbinGUI(listb, indxlistb, titlename);
            if ~isempty(bin_label_select)
                EStudio_erp_m_t_p.binArray = bin_label_select;
                ERPMTops.m_t_bin.String=num2str(vect2colon(EStudio_erp_m_t_p.binArray,'Sort', 'on'));
            else
                disp('User selected Cancel');
                return
            end
        else
            beep;
            msgboxText =  ['ERP Measurement Tool - No bin information was found'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end%Program end: Judge the number of latency/latencies
        S_ws= estudioworkingmemory('geterpvalues');
        if isempty(S_ws)
            return;
        end
        
        S_ws.binArray = EStudio_erp_m_t_p.binArray;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
        %Remark the selected bin in bin and Channel selection
        if strcmp(EStudio_erp_m_t_p.Viewer,'on')
            SelectedERP_Index =  estudioworkingmemory('selectederpstudio');
            if isempty(SelectedERP_Index)
                SelectedERP_Index =  observe_ERPDAT.CURRENTERP;
                S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
                estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
                estudioworkingmemory('selectederpstudio',SelectedERP_Index);
            end
            
            S_binchan =  estudioworkingmemory('geterpbinchan');
            Select_index = S_binchan.Select_index;
            
            Bin_label_select = bin_label_select;
            if isempty(Bin_label_select)
                beep;
                disp(['No bin was selected']);
                return;
            end
            EStudio_erp_m_t_p.binArray = bin_label_select;
            if S_binchan.checked_ERPset_Index(1) ==1% The number of bins varied across the selected erpsets
                S_binchan.bins{Select_index} = Bin_label_select;
                S_binchan.bin_n(Select_index) = numel(Bin_label_select);
            else
                for Numofselecterp = 1:numel(SelectedERP_Index)
                    S_binchan.bins{Numofselecterp} = Bin_label_select;
                    S_binchan.bin_n(Numofselecterp) = numel(Bin_label_select);
                end
            end
            estudioworkingmemory('geterpbinchan',S_binchan);
        end
        observe_ERPDAT.ERP_bin = bin_label_select;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    end


%%----------------Define the channels of interest----------------------
    function chanSelect_custom(Source,~)
        chanNums =  str2num(Source.String);
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, [], chanNums,2);
        
        if chk(2)
            chanArray= observe_ERPDAT.ERP_chan;
            Source.String = num2str(chanArray);
            beep;
            msgboxText =  ['ERP Measurement Tool -',32,msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if ~isempty(chanNums)
            chanNums   = unique_bc2(chanNums);
            chanList = 1:observe_ERPDAT.ERP.nchan;
            indxlist_chan = chanNums;
            
            [~,y_check_bin] =find(indxlist_chan>observe_ERPDAT.ERP.nchan);
            if any(y_check_bin)
                mnamex = ['Label of one of the imported channels was higher than the number of channels (',num2str(observe_ERPDAT.ERP.nchan),').'];
                question = [ '%s\n\n Please input or select bins of interst from "Channel:" on the "ERP Measurement Tool" panel again.\n'];
                title       = 'ERPLAB Studio: ERP Measurement Tool';
                button      = questdlg(sprintf(question, mnamex), title,'OK','OK');
                return;
            end
            
            indxlist_chan = indxlist_chan(indxlist_chan<=length(chanList));
            EStudio_erp_m_t_p.chanArray = indxlist_chan;
            S_ws= estudioworkingmemory('geterpvalues');
            if isempty(S_ws)
                return;
            end
            S_ws.chanArray = EStudio_erp_m_t_p.chanArray;
            estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
            %When the "Viewer" is active on the measurement Tool panel---------
            if  strcmp(EStudio_erp_m_t_p.Viewer,'on')
                SelectedERP_Index =  estudioworkingmemory('selectederpstudio');
                if isempty(SelectedERP_Index)
                    SelectedERP_Index =  observe_ERPDAT.CURRENTERP;
                    S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
                    estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                    estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
                    estudioworkingmemory('selectederpstudio',SelectedERP_Index);
                end
                
                S_binchan =  estudioworkingmemory('geterpbinchan');
                Select_index = S_binchan.Select_index;
                chan_label_select = indxlist_chan;
                
                if S_binchan.checked_ERPset_Index(2) ==2%% the number of channels varied across ERPsets
                    S_binchan.elecs_shown{S_binchan.Select_index} = chan_label_select;
                    S_binchan.elec_n(Select_index) = numel(chan_label_select);
                    S_binchan.first_elec(Select_index) = chan_label_select(1);
                else
                    
                    for Numofselecterp = 1:numel(SelectedERP_Index)
                        S_binchan.elecs_shown{Numofselecterp} = chan_label_select;
                        S_binchan.elec_n(Numofselecterp) = numel(chan_label_select);
                        S_binchan.first_elec(Numofselecterp) = chan_label_select(1);
                    end
                    
                end
                estudioworkingmemory('geterpbinchan',S_binchan);
            end
            observe_ERPDAT.ERP_chan = indxlist_chan;
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
        
    end


%%----------------Channels selection from option--------------------------------------
    function chanSelect_label(Source,~)
        ERP_CURRENT = evalin('base','ERP');
        
        if isempty(ERP_CURRENT.nchan) || ERP_CURRENT.nchan ==0
            beep;
            msgboxText =  ['ERP Measurement Tool -No channel information was found'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        for Numofchan = 1:ERP_CURRENT.nchan
            listb{Numofchan}= strcat(num2str(Numofchan),'.',ERP_CURRENT.chanlocs(Numofchan).labels);
        end
        try
            indxlistb= EStudio_erp_m_t_p.chanArray ;
        catch
            indxlistb = 1:ERP_CURRENT.nchan;
        end
        titlename = 'Select Channel(s):';
        
        if ~isempty(listb)
            chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
            if ~isempty(chan_label_select)
                EStudio_erp_m_t_p.chanArray = chan_label_select;
                %%%Save the changed parameters
                S_ws= estudioworkingmemory('geterpvalues');
                if isempty(S_ws)
                    return;
                end
                
                S_ws.chanArray = EStudio_erp_m_t_p.chanArray;
                estudioworkingmemory('geterpvalues',S_ws); clear S_ws;
                ERPMTops.m_t_chan.String=num2str(vect2colon(EStudio_erp_m_t_p.chanArray,'Sort', 'on'));
            else
                beep;
                disp('User selected Cancel');
                return
            end
        else
            beep;
            msgboxText =  ['ERP Measurement Tool -No channel information was found'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        %When the "Viewer" is active on the measurement Tool panel---------
        if  strcmp(EStudio_erp_m_t_p.Viewer,'on')
            SelectedERP_Index =  estudioworkingmemory('selectederpstudio');
            if isempty(SelectedERP_Index)
                SelectedERP_Index =  observe_ERPDAT.CURRENTERP;
                S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
                estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
                estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
                estudioworkingmemory('selectederpstudio',SelectedERP_Index);
            end
            
            S_binchan =  estudioworkingmemory('geterpbinchan');
            Select_index = S_binchan.Select_index;
            if isempty(chan_label_select)
                beep;
                disp(['No channel was selected']);
                return;
            end
            if S_binchan.checked_ERPset_Index(2) ==2%% the number of channels varied across ERPsets
                S_binchan.elecs_shown{S_binchan.Select_index} = chan_label_select;
                S_binchan.elec_n(Select_index) = numel(chan_label_select);
                S_binchan.first_elec(Select_index) = chan_label_select(1);
            else
                
                for Numofselecterp = 1:numel(SelectedERP_Index)
                    S_binchan.elecs_shown{Numofselecterp} = chan_label_select;
                    S_binchan.elec_n(Numofselecterp) = numel(chan_label_select);
                    S_binchan.first_elec(Numofselecterp) = chan_label_select(1);
                end
            end
            estudioworkingmemory('geterpbinchan',S_binchan);
        end
        chanArray =  str2num(ERPMTops.m_t_chan.String);
        if ~isempty(chanArray)
            observe_ERPDAT.ERP_chan = chanArray;
        end
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    end

%%-----------------Measurement time-window-------------------------------%%
    function t_w_set(source_tw,~)
        if isempty(str2num(source_tw.String))
            beep;
            msgboxText =  ['ERP Measurement Tool -No measurement window was set'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        else
            lat_erp = unique_bc2(str2num(source_tw.String));
            EStudio_erp_m_t_p.latency = lat_erp;
            moption = EStudio_erp_m_t_p.Measure;
            latency = EStudio_erp_m_t_p.latency;
            if isempty(moption)
                beep;
                msgboxText =  ['ERP Measurement Tool - User must specify a type of measurement'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                if length(latency)~=1
                    beep;
                    msgboxText =  ['ERP Measurement Tool -',32,moption ' only needs 1 latency value'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                end
            else
                if length(latency)~=2
                    beep;
                    msgboxText =  ['ERP Measurement Tool -',32,moption ' needs 2 latency values'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                else
                    if latency(1)>=latency(2)
                        beep;
                        msgboxText =  ['ERP Measurement Tool -For latency range, lower time limit must be on the left.\n'...
                            'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    end
                end
            end
            
            
            S_ws= estudioworkingmemory('geterpvalues');
            if isempty(S_ws)
                return;
            end
            S_ws.latency = lat_erp;
            estudioworkingmemory('geterpvalues',S_ws); clear S_ws;
            
        end
        if strcmp(EStudio_erp_m_t_p.Viewer,'on')
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
    end


%-------------------------Baseline period---------------------------------
    function baseline_set(~,~)
        try
            S_ws=estudioworkingmemory('geterpvalues');
            Answer = f_ERP_meas_basecorr(S_ws.Baseline);
        catch
            Answer = f_ERP_meas_basecorr('none');
        end
        
        if isempty(Answer)
            beep;
            disp('User selected cancel');
            return;
        end
        ERP_times = observe_ERPDAT.ERP.times;
        latency = str2num(Answer);
        if ~isempty(latency)
            if latency(1)>=latency(2)
                beep;
                msgboxText =  ['ERP Measurement Tool - The first latency should be smaller than the second one'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(1)< ERP_times(1)
                beep;
                msgboxText =  ['ERP Measurement Tool - The defined first latency should be larger than',32, num2str(ERP_times(1)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(2)> ERP_times(end)
                beep;
                msgboxText =  ['ERP Measurement Tool - The defined second latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            
            if latency(1)> ERP_times(end)
                beep;
                msgboxText =  ['ERP Measurement Tool - The defined first latency should be smaller than',32, num2str(ERP_times(end)),'ms'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        end
        
        S_ws= estudioworkingmemory('geterpvalues');
        S_ws.Baseline = Answer;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
        
        if strcmp(EStudio_erp_m_t_p.Viewer,'on')
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        end
    end

%%------------------File name setting for the output file.----------------
    function file_name_set(source_file_name,~)
        EStudio_erp_m_t_p.Filename = source_file_name.String;
        S_ws=estudioworkingmemory('geterpvalues');
        S_ws.Filename = source_file_name.String;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
    end

%%-------------------Path setting to save the measurement results----------
    function out_file_option(~,~)
        if strcmp(EStudio_erp_m_t_p.FileFormat,'wide')
            FileFormat = 0;
        else
            FileFormat = 1;
        end
        pathName_folder_default =  erpworkingmemory('ERP_save_folder');
        FileName =  EStudio_erp_m_t_p.Filename;
        [pathNamex, fname, ext] = fileparts(FileName);
        Answer = f_ERP_meas_format_path(FileFormat,fullfile(pathName_folder_default,fname));
        
        if isempty(Answer)
            disp('User selected Cancel');
            return;
            
        end
        if Answer{1}==1 % 1 means "long format"; 0 means "wide format"
            foutputstr = 'long';
        else
            foutputstr = 'wide';
        end
        
        S_ws=estudioworkingmemory('geterpvalues');
        S_ws.Filename = Answer{2};
        S_ws.FileFormat = foutputstr;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
        
        EStudio_erp_m_t_p.FileFormat = foutputstr;
        EStudio_erp_m_t_p.Filename = Answer{2};
        ERPMTops.m_t_file.String = EStudio_erp_m_t_p.Filename;
        
    end


%%---------------Viewer:ON------------------------------
    function m_t_viewer_on(~,~)
        Source_value = 1;
        set(ERPMTops.m_t_viewer_on,'Value',Source_value);
        set(ERPMTops.m_t_viewer_off,'Value',~Source_value);
        EStudio_erp_m_t_p.Viewer = 'on';
        S_ws= estudioworkingmemory('geterpvalues');
        S_ws.Viewer = EStudio_erp_m_t_p.Viewer;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    end

%%---------------Viewer:Off------------------------------
    function m_t_viewer_off(~,~)
        Source_value = 1;
        set(ERPMTops.m_t_viewer_off,'Value',Source_value);
        set(ERPMTops.m_t_viewer_on,'Value',~Source_value);
        EStudio_erp_m_t_p.Viewer = 'off';
        S_ws=estudioworkingmemory('geterpvalues');
        S_ws.Viewer = EStudio_erp_m_t_p.Viewer;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    end


%%--------------------Apply the set parameters to selected ERPset----------
    function apply_erp_m_t(~,~)
        pathName_folder =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_folder)
            pathName_folder =  cd;
        end
        
        EStudio_erp_m_t_p =estudioworkingmemory('geterpvalues');
        if isempty(EStudio_erp_m_t_p)
            EStudio_erp_m_t_p =EStudio_erp_m_t_p;
            return;
        end
        
        SelectedERP_Index =  estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP_Index)
            SelectedERP_Index =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            estudioworkingmemory('selectederpstudio',SelectedERP_Index);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        
        EStudio_erp_m_t_p.Erpsets =  SelectedERP_Index;
        
        MeasureName = {'meanbl','peakampbl', 'peaklatbl','fareatlat','fpeaklat','fninteglat','fareaplat','fareanlat',...
            'areat','ninteg','areap','arean','areazt','nintegz','areazp','areazn','instabl'};
        [C,IA] = ismember_bc2({EStudio_erp_m_t_p.Measure}, MeasureName);
        if ~any(IA) || isempty(IA)
            IA =1;
        end
        if isempty(EStudio_erp_m_t_p.Filename)
            beep;
            msgboxText =  ['ERP Measurement Tool - Please set a name for the output file'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if isempty(EStudio_erp_m_t_p.latency)
            beep;
            msgboxText =  ['ERP Measurement Tool - Please set a Measurement window'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        moption = EStudio_erp_m_t_p.Measure;
        latency = EStudio_erp_m_t_p.latency;
        if isempty(moption)
            beep;
            msgboxText =  ['ERP Measurement Tool - User must specify a type of measurement'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
            if length(latency)~=1
                beep;
                msgboxText =  ['ERP Measurement Tool - ',32, moption ' only needs 1 latency value'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        else
            if length(latency)~=2
                beep;
                msgboxText =  ['ERP Measurement Tool - ',32,moption ' needs 2 latency values.'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            else
                if latency(1)>=latency(2)
                    beep;
                    msgboxText =  ['ERP Measurement Tool - For latency range, lower time limit must be on the left.\n'...
                        'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return;
                end
            end
        end
        ALLERP = evalin('base','ALLERP');
        
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, EStudio_erp_m_t_p.binArray, [],1);
        
        if chk(1)
            beep;
            msgboxText =  ['ERP Measurement Tool - ',32,msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        [chk, msgboxText] = f_ERP_chckbinandchan(observe_ERPDAT.ERP, [], EStudio_erp_m_t_p.chanArray,2);
        
        if chk(2)
            beep;
            msgboxText =  ['ERP Measurement Tool - ',32,msgboxText];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        FileName =  EStudio_erp_m_t_p.Filename;
        [pathNamex, fname, ext] = fileparts(FileName);
        if isempty(fname)
            beep;
            msgboxText =  ['ERP Measurement Tool - Please give a name to the output file'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if isempty(pathNamex)
            EStudio_erp_m_t_p.Filename = fullfile(pathName_folder,fname);
        end
        
        
        erpworkingmemory('f_ERP_proces_messg',' ERP Measurement Tool (Save values)');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        try
            if ~isempty(EStudio_erp_m_t_p.latency)
                %
                [ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP, EStudio_erp_m_t_p.latency, EStudio_erp_m_t_p.binArray, EStudio_erp_m_t_p.chanArray,...
                    'Erpsets', EStudio_erp_m_t_p.Erpsets, 'Measure',MeasureName{IA}, 'Component', EStudio_erp_m_t_p.Component,...
                    'Resolution', EStudio_erp_m_t_p.Resolution, 'Baseline', EStudio_erp_m_t_p.Baseline, 'Binlabel', EStudio_erp_m_t_p.Binlabel,...
                    'Peakpolarity',EStudio_erp_m_t_p.Peakpolarity, 'Neighborhood', EStudio_erp_m_t_p.Neighborhood, 'Peakreplace', EStudio_erp_m_t_p.Peakreplace,...
                    'Filename', EStudio_erp_m_t_p.Filename, 'Warning',EStudio_erp_m_t_p.Warning,'SendtoWorkspace', EStudio_erp_m_t_p.SendtoWorkspace, 'Append', EStudio_erp_m_t_p.Append,...
                    'FileFormat', EStudio_erp_m_t_p.FileFormat,'Afraction', EStudio_erp_m_t_p.Afraction, 'Mlabel', EStudio_erp_m_t_p.Mlabel,...
                    'Fracreplace', EStudio_erp_m_t_p.Fracreplace,'IncludeLat', EStudio_erp_m_t_p.IncludeLat, 'InterpFactor', EStudio_erp_m_t_p.InterpFactor,...
                    'PeakOnset',EStudio_erp_m_t_p.PeakOnset,'History', 'gui');
                %%%------------Save history to current session--------------
                ALLERPCOM = evalin('base','ALLERPCOM');
                [~, ALLERPCOM] = erphistory(observe_ERPDAT.ERP, ALLERPCOM, erpcom);
                assignin('base','ALLERPCOM',ALLERPCOM);
                
                %%---------------save the applied parameters using erpworkingmemory function--------------------
                EStudio_erp_m_t_p_save = EStudio_erp_m_t_p;
                if strcmp(EStudio_erp_m_t_p_save.Binlabel,'off')
                    EStudio_erp_m_t_p_save.Binlabel = 0;
                else
                    EStudio_erp_m_t_p_save.Binlabel = 1;
                end
                
                if strcmp(EStudio_erp_m_t_p_save.Peakpolarity,'negative')
                    EStudio_erp_m_t_p_save.Peakpolarity = 0;
                else
                    EStudio_erp_m_t_p_save.Peakpolarity = 1;
                end
                
                if strcmp(EStudio_erp_m_t_p_save.Peakreplace,'NaN')
                    EStudio_erp_m_t_p_save.Peakreplace = 0;
                else
                    EStudio_erp_m_t_p_save.Peakreplace = 1;
                end
                
                if strcmp(EStudio_erp_m_t_p_save.Fracreplace,'NaN') % Fractional area latency replacement
                    EStudio_erp_m_t_p_save.Fracreplace = 0;
                else
                    EStudio_erp_m_t_p_save.Fracreplace = 1;
                end
                
                if strcmp(EStudio_erp_m_t_p_save.SendtoWorkspace,'off')
                    EStudio_erp_m_t_p_save.SendtoWorkspace=0;
                else
                    EStudio_erp_m_t_p_save.SendtoWorkspace=1;
                end
                
                if strcmp(EStudio_erp_m_t_p_save.FileFormat,'wide')
                    EStudio_erp_m_t_p_save.FileFormat = 0;
                else
                    EStudio_erp_m_t_p_save.FileFormat = 1;
                end
                
                if strcmp(EStudio_erp_m_t_p_save.IncludeLat,'no')
                    EStudio_erp_m_t_p_save.IncludeLat = 0;
                else
                    EStudio_erp_m_t_p_save.IncludeLat = 1;
                end
                
                erpworkingmemory('pop_geterpvalues', {CurrentERPSet, EStudio_erp_m_t_p_save.Erpsets, EStudio_erp_m_t_p_save.Filename, EStudio_erp_m_t_p_save.latency,...
                    EStudio_erp_m_t_p_save.binArray, EStudio_erp_m_t_p_save.chanArray, EStudio_erp_m_t_p_save.Measure, EStudio_erp_m_t_p_save.Component, EStudio_erp_m_t_p_save.Resolution, EStudio_erp_m_t_p_save.Baseline,...
                    EStudio_erp_m_t_p_save.Binlabel, EStudio_erp_m_t_p_save.Peakpolarity,EStudio_erp_m_t_p_save.Neighborhood, EStudio_erp_m_t_p_save.Peakreplace,...
                    EStudio_erp_m_t_p_save.Afraction, EStudio_erp_m_t_p_save.Fracreplace,EStudio_erp_m_t_p_save.SendtoWorkspace, EStudio_erp_m_t_p_save.FileFormat, EStudio_erp_m_t_p_save.Mlabel,...
                    EStudio_erp_m_t_p_save.IncludeLat, EStudio_erp_m_t_p_save.InterpFactor, EStudio_erp_m_t_p_save.PeakOnset});
                
            end
            observe_ERPDAT.Process_messg =2;
        catch
            beep;
            msgboxText =  ['ERP Measurement Tool - Cannot export the values'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end



%----------displayed channel label will be midified after vaied channels was selected--------
    function ERP_chan_changed(~,~)
        ERPMTops.m_t_chan.String = num2str(vect2colon(observe_ERPDAT.ERP_chan,'Sort', 'on'));
        S_ws= estudioworkingmemory('geterpvalues');
        S_ws.chanArray = observe_ERPDAT.ERP_chan;
        EStudio_erp_m_t_p.chanArray = observe_ERPDAT.ERP_chan;
        estudioworkingmemory('geterpvalues',S_ws); clear S_ws;
    end

%----------displayed bin label will be midified after different channels was selected--------
    function ERP_bin_changed(~,~)
        ERPMTops.m_t_bin.String = num2str(vect2colon(observe_ERPDAT.ERP_bin,'Sort', 'on'));
        S_ws= estudioworkingmemory('geterpvalues');
        S_ws.binArray = observe_ERPDAT.ERP_bin;
        EStudio_erp_m_t_p.binArray = observe_ERPDAT.ERP_bin;
        estudioworkingmemory('geterpvalues',S_ws);clear S_ws;
    end


%%--------Settting if the current panel is active or not based on the selected ERPsets------------
    function  Count_currentERP_change(~,~)
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                beep;
                msgboxText =  ['ERP Measurement Tool - No ERPset was selected'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        S_binchan = estudioworkingmemory('geterpbinchan');
        ERPMTops.m_t_erpset.String= num2str(vect2colon(Selectederp_Index,'Sort','on'));%%Dec 20 2022
        if strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
            checked_curr_index = 1;
        else
            checked_curr_index = 0;
        end
        
        checked_ERPset_Index = S_binchan.checked_ERPset_Index;
        if checked_curr_index || any(checked_ERPset_Index(:))
            ERPMTops.m_t_value.Enable = 'off';
        else
            ERPMTops.m_t_value.Enable = 'on';
        end
        Enable_label = 'on';
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
        ERPMTops.m_t_viewer_on.Enable = Enable_label;
        ERPMTops.m_t_viewer_off.Enable = Enable_label;
        ERPMTops.m_t_erpset.Enable = Enable_label;
        ERPMTops.m_t_erpset_ops.Enable = Enable_label;
        if checked_ERPset_Index(1)==1
            ERPMTops.m_t_bin.Enable = 'off';
            ERPMTops.m_t_bin_ops.Enable = 'off';
        else
            ERPMTops.m_t_bin.Enable = 'on';
            ERPMTops.m_t_bin_ops.Enable = 'on';
        end
        if checked_ERPset_Index(2)==2
            ERPMTops.m_t_chan.Enable = 'off';
            ERPMTops.m_t_chan_ops.Enable = 'off';
        else
            ERPMTops.m_t_chan.Enable = 'on';
            ERPMTops.m_t_chan_ops.Enable = 'on';
        end
    end

end%Progem end: ERP Measurement tool