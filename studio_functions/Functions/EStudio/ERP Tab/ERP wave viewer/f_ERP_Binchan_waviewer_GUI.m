% ERPset selector panel
%
% Author: Guanghui ZHANG & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & 2023

% ERPLAB Toolbox
%

%
% Initial setup
%
function varargout = f_ERP_Binchan_waviewer_GUI(varargin)
%
global viewer_ERPDAT
global observe_ERPDAT;

addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);
addlistener(viewer_ERPDAT,'ERPset_Chan_bin_label_change',@ERPset_Chan_bin_label_change);
addlistener(observe_ERPDAT,'ERP_chan_change',@ERP_chan_changed);
addlistener(observe_ERPDAT,'ERP_bin_change',@ERP_bin_changed);
addlistener(observe_ERPDAT,'Two_GUI_change',@Two_GUI_change);



ERPwaveview_binchan = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorBviewer_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
catch
    ColorBviewer_def = [0.7765    0.7294    0.8627];
end
ERPdatasets = []; % Local data structure
% global Chanbin_waveviewer_box;
if nargin == 0
    fig = figure(); % Parent figure
    Chanbin_waveviewer_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Channels and Bins', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12); % Create boxpanel
elseif nargin == 1
    Chanbin_waveviewer_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Channels and Bins', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12);
elseif nargin == 3 || nargin == 2
    Chanbin_waveviewer_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Channels and Bins', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
elseif nargin == 4
    Chanbin_waveviewer_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Channels and Bins', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
    
end

try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end

drawui_erpsetbinchan_viewer(FonsizeDefault);

varargout{1} = Chanbin_waveviewer_box;
% Draw the ui
    function drawui_erpsetbinchan_viewer(FonsizeDefault)
        MERPWaveViewer_chanbin= estudioworkingmemory('MERPWaveViewer_chanbin');%%call the memery for this panel
        
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        catch
            ColorBviewer_def =  [0.7765    0.7294    0.8627];
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
            SelectedIndex = ERPwaviewer.SelectERPIdx;
            ALLERP = ERPwaviewer.ALLERP;
            if max(SelectedIndex(:))> length(ALLERP)
                SelectedIndex =length(ALLERP);
            end
        catch
            beep;
            disp('f_ERP_Binchan_waviewer_GUI error: Restart ERPwave Viewer');
            return;
        end
        ERPwaveview_binchan.vBox = uiextras.VBox('Parent', Chanbin_waveviewer_box, 'Spacing', 5,'BackgroundColor',ColorBviewer_def); % VBox for everything
        ERPtooltype = erpgettoolversion('tooltype');
        
        if ~strcmpi(ERPtooltype,'EStudio') %&& ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaviewer.erp_binchan_op = 0;
            MERPWaveViewer_chanbin{1}=0;
        end
        try
            Enable_auto =  MERPWaveViewer_chanbin{1};
        catch
            Enable_auto =  1;
            MERPWaveViewer_chanbin{1}=1;
        end
        if numel(Enable_auto)~=1 || (Enable_auto~=0 && Enable_auto~=1)
            Enable_auto =  1;
            MERPWaveViewer_chanbin{1}=1;
        end
        if Enable_auto ==1
            Enable_label = 'off';
        elseif Enable_auto ==0
            Enable_label = 'on';
        end
        %%---------------------Options for selecting channel and bins-----------------------------------------------------
        ERPwaveview_binchan.opts_title = uiextras.HBox('Parent', ERPwaveview_binchan.vBox, 'Spacing', 5,'BackgroundColor',ColorBviewer_def);
        ERPwaveview_binchan.auto = uicontrol('Style', 'radiobutton','Parent', ERPwaveview_binchan.opts_title,...
            'String','Same as EStudio','callback',@Chanbin_auto,'Value',Enable_auto,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def);
        ERPwaveview_binchan.auto.KeyPressFcn = @setbinchan_presskey;
        
        ERPwaveview_binchan.custom = uicontrol('Style', 'radiobutton','Parent', ERPwaveview_binchan.opts_title,...
            'String','Custom','callback',@Chanbin_custom,'Value',~Enable_auto,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',ColorBviewer_def);
        ERPwaveview_binchan.custom.KeyPressFcn = @setbinchan_presskey;
        
        %
        %%---------------------Display channel and bin labels-----------------------------------------------------
        
        ERPwaveview_binchan.DataSelGrid = uiextras.HBox('Parent', ERPwaveview_binchan.vBox,'BackgroundColor',ColorBviewer_def);
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,SelectedIndex);
        
        Chanlist_name = cell(length(chanStr)+1,1);
        Chanlist_name(1) = {'All'};
        for Numofchan11 = 1:length(chanStr)
            Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
        end
        % Channel information
        Chanlist = chanStr;
        Chan_seldef = ERPwaviewer.chan;
        if ~isempty(Chan_seldef)
            if max(Chan_seldef)> numel(Chanlist)
                Chan_seldef=   1:length(Chanlist);
            end
        else
            Chan_seldef=   1:length(Chanlist);
        end
        try
            Chan_sel = MERPWaveViewer_chanbin{2};
        catch
            MERPWaveViewer_chanbin{2} = Chan_seldef;
            Chan_sel = Chan_seldef;
        end
        Chan_sel = unique(Chan_sel);
        if isempty(Chan_sel) || max(Chan_sel(:))> length(Chanlist) || min(Chan_sel(:))> length(Chanlist) || min(Chan_sel(:))<=0
            MERPWaveViewer_chanbin{2} = Chan_seldef;
            Chan_sel = Chan_seldef;
        end
        ERPwaviewer.chan = Chan_sel;
        ERPwaveview_binchan.ElecRange = uicontrol('Parent', ERPwaveview_binchan.DataSelGrid,'Style','listbox','min',1,'max',length(Chanlist_name),...
            'String', Chanlist_name,'Callback',@ViewerElecRange,'FontSize',FonsizeDefault,'Enable',Enable_label); % 2B
        
        ERPwaveview_binchan.ElecRange.KeyPressFcn = @setbinchan_presskey;
        if  numel(Chan_sel) == numel(Chanlist)
            ERPwaveview_binchan.ElecRange.Value  =1;
        else
            ERPwaveview_binchan.ElecRange.Value = Chan_sel+1;
        end
        %%Bin information
        brange = cell(length(binStr)+1,1);
        BinNum = length(binStr);
        Bin_seldef = ERPwaviewer.bin;
        if ~isempty(Bin_seldef)
            if max(Bin_seldef)> BinNum
                Bin_seldef=   1:BinNum;
            end
        else
            Bin_seldef=   1:BinNum;
        end
        try
            Bin_sel = MERPWaveViewer_chanbin{3};
        catch
            MERPWaveViewer_chanbin{3} = Bin_seldef;
            Bin_sel = Bin_seldef;
        end
        if isempty(Bin_sel) || max(Bin_sel(:))> length(binStr) || min(Bin_sel(:))> length(binStr) || min(Bin_sel(:))<=0
            MERPWaveViewer_chanbin{3} = Bin_seldef;
            Bin_sel = Bin_seldef;
        end
        ERPwaviewer.bin=Bin_sel;
        brange(1) = {'All'};
        for Numofbin11 = 1:length(binStr)
            brange(Numofbin11+1) = {char(strcat(num2str(Numofbin11),'.',32,char(binStr(Numofbin11))))};
        end
        ERPwaveview_binchan.BinRange =  uicontrol('Parent', ERPwaveview_binchan.DataSelGrid,'Style','listbox','Min',1,'Max',BinNum+1,...
            'String', brange,'callback',@ViewerBinRange,'FontSize',FonsizeDefault,'Enable',Enable_label); % 2C
        ERPwaveview_binchan.BinRange.KeyPressFcn = @setbinchan_presskey;
        if BinNum== numel(Bin_sel)
            ERPwaveview_binchan.BinRange.Value  =1;
        else
            ERPwaveview_binchan.BinRange.Value = Bin_sel+1;
        end
        set(ERPwaveview_binchan.DataSelGrid, 'Sizes',[ -1.2 -2]);
        
        if strcmpi(ERPtooltype,'EStudio')
            ERPwaveview_binchan.auto.String = 'Same as EStudio';
        else
            ERPwaveview_binchan.auto.String = '';
            ERPwaveview_binchan.auto.Enable = 'off';
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.custom.String = '';
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Enable = 'off';
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
        
        
        %%Help and apply
        ERPwaveview_binchan.help_apply_title = uiextras.HBox('Parent', ERPwaveview_binchan.vBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',ERPwaveview_binchan.help_apply_title );
        uicontrol('Style','pushbutton','Parent', ERPwaveview_binchan.help_apply_title  ,'String','Cancel',...
            'callback',@setbinchan_help,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'FontWeight','bold','HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_binchan.help_apply_title  );
        ERPwaveview_binchan.apply =  uicontrol('Style','pushbutton','Parent',ERPwaveview_binchan.help_apply_title  ,'String','Apply',...
            'callback',@setbinchan_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
%         ERPwaveview_binchan.custom.KeyPressFcn = @setbinchan_presskey;
        uiextras.Empty('Parent',ERPwaveview_binchan.help_apply_title );
        set(ERPwaveview_binchan.help_apply_title ,'Sizes',[40 70 20 70 20]);
        set(ERPwaveview_binchan.vBox, 'Sizes', [20 190 25]);
        assignin('base','ALLERPwaviewer',ERPwaviewer);
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------Channel changes------------------------------------
    function ViewerElecRange(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        ChanArray = Source.Value;
        [x_flag,y_flag] = find(ChanArray==1);
        if ~isempty(y_flag)
            Source.Value = 1;
        else
            if length(Source.String)-1 == numel(ChanArray)
                Source.Value = 1;
            end
        end
        estudioworkingmemory('MyViewer_chanbin',1);
        ERPwaveview_binchan.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        ERPwaveview_binchan.apply.ForegroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.4940 0.1840 0.5560];
    end


%%----------------------------Bin change-----------------------------------
    function ViewerBinRange(BinSource,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        BinArray = BinSource.Value;
        [x_flag,y_flag] = find(BinArray==1);
        if ~isempty(y_flag)
            BinSource.Value = 1;
        else
            if length(BinSource.String)-1 == numel(BinArray)
                BinSource.Value = 1;
            end
        end
        
        estudioworkingmemory('MyViewer_chanbin',1);
        ERPwaveview_binchan.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        ERPwaveview_binchan.apply.ForegroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.4940 0.1840 0.5560];
    end

%%---------------Setting for auto option-----------------------------------
    function Chanbin_auto(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_chanbin',1);
        ERPwaveview_binchan.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        ERPwaveview_binchan.apply.ForegroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.4940 0.1840 0.5560];
        ERPtooltype = erpgettoolversion('tooltype');
        if strcmpi(ERPtooltype,'EStudio')
            ERPwaveview_binchan.auto.Value = 1;
            ERPwaveview_binchan.custom.Value =0;
            ERPwaveview_binchan.ElecRange.Enable = 'off';
            ERPwaveview_binchan.BinRange.Enable = 'off';
            Selected_erpset= estudioworkingmemory('selectederpstudio');
            Geterpbinchan = estudioworkingmemory('geterpbinchan');
            CurrentERPIndex = Geterpbinchan.Select_index;
            try
                ERPwaviewerIN = evalin('base','ALLERPwaviewer');
                ALLERPIN = ERPwaviewerIN.ALLERP;
                if max(Selected_erpset(:))> length(ALLERPIN)
                    Selected_erpset =1;
                    CurrentERPIndex =1;
                end
            catch
                beep;
                disp('f_ERP_Binchan_waviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            
            BinArray = Geterpbinchan.bins{Geterpbinchan.Select_index};
            chanArray = Geterpbinchan.elecs_shown{Geterpbinchan.Select_index};
            chan_bin = Geterpbinchan.bins_chans(CurrentERPIndex);
            if chan_bin ==1
                ERPwaviewerIN.plot_org.Grid =2;
                ERPwaviewerIN.plot_org.Overlay=1;
                ERPwaviewerIN.plot_org.Pages=3;
            elseif chan_bin==0
                ERPwaviewerIN.plot_org.Grid =1;
                ERPwaviewerIN.plot_org.Overlay=2;
                ERPwaviewerIN.plot_org.Pages=3;
            end
            
            % Channel information
            chanStr = [1:(numel(ERPwaveview_binchan.ElecRange.String)-1)];
            Chanlist = chanStr;
            Chan_sel = chanArray;
            if ~isempty(Chan_sel)
                if max(Chan_sel)> numel(Chanlist)
                    Chan_sel=   1:length(Chanlist);
                end
            else
                Chan_sel=   1:length(Chanlist);
            end
            try
                if length(Chan_sel) ==  numel(chanStr)
                    ERPwaveview_binchan.ElecRange.Value  =1;
                else
                    ERPwaveview_binchan.ElecRange.Value  =Chan_sel+1;
                end
            catch
                ERPwaveview_binchan.ElecRange.Value  =1;
            end
            
            %%Bin information
            binStr =  ERPwaveview_binchan.BinRange.String;
            BinNum = length(binStr)-1;
            Bin_sel = BinArray;
            if ~isempty(Bin_sel)
                if max(Bin_sel)> BinNum
                    Bin_sel=   1:BinNum;
                end
            else
                Bin_sel=   1:BinNum;
            end
            
            if BinNum== numel(Bin_sel)
                ERPwaveview_binchan.BinRange.Value  =1;
            else
                ERPwaveview_binchan.BinRange.Value = Bin_sel+1;
            end
            
        elseif strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_binchan.auto.Value = 1;
            ERPwaveview_binchan.custom.Value =0;
            ERPwaveview_binchan.ElecRange.Enable = 'off';
            ERPwaveview_binchan.BinRange.Enable = 'off';
            Selected_erpset = evalin('base','CURRENTERP');
            ALLERP = evalin('base','ALLERP');
            if ~isempty(Selected_erpset) && ~isempty(ALLERP) && (Selected_erpset<= length(ALLERP)) && min(Selected_erpset)>0
                [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,SelectedIndex);
                Chanlist_name = cell(length(chanStr)+1,1);
                Chanlist_name(1) = {'All'};
                for Numofchan11 = 1:length(chanStr)
                    Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
                end
                ERPwaveview_binchan.ElecRange.String = Chanlist_name;
                ERPwaveview_binchan.ElecRange.Value =1;
                
                brange = cell(length(binStr)+1,1);
                brange(1) = {'All'};
                for Numofbin11 = 1:length(binStr)
                    brange(Numofbin11+1) = {char(strcat(num2str(Numofbin11),'.',32,char(binStr(Numofbin11))))};
                end
                ERPwaveview_binchan.BinRange.String = brange;
                ERPwaveview_binchan.BinRange.Value = 1;
            end
        else
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
    end
%%---------------Setting for custom option---------------------------------
    function Chanbin_custom(source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_chanbin',1);
        ERPwaveview_binchan.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        ERPwaveview_binchan.apply.ForegroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.4940 0.1840 0.5560];
        
        ERPtooltype = erpgettoolversion('tooltype');
        if  ~strcmpi(ERPtooltype,'EStudio') && ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
            ERPwaveview_binchan.auto.Enable = 'off';
        else
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
    end


%%-------------------------------Help--------------------------------------
    function setbinchan_help(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        
        changeFlag =  estudioworkingmemory('MyViewer_chanbin');
        if changeFlag~=1
            return;
        end
        MessageViewer= char(strcat('Channels and Bins > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\nChannels and Bins > Cancel-f_ERP_Binchan_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        if ERPwaviewer_apply.binchan_op==1
            ERPwaveview_binchan.auto.Value = 1;
            ERPwaveview_binchan.custom.Value =0;
            ERPwaveview_binchan.ElecRange.Enable = 'off';
            ERPwaveview_binchan.BinRange.Enable = 'off';
        else
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
        
        binArray =  ERPwaviewer_apply.bin;
        chanArray = ERPwaviewer_apply.chan;
        if numel(binArray) == length(ERPwaveview_binchan.BinRange.String)-1
            ERPwaveview_binchan.BinRange.Value =1;
        else
            ERPwaveview_binchan.BinRange.Value =binArray+1;
        end
        if numel(chanArray)==length(ERPwaveview_binchan.ElecRange.String)-1
            ERPwaveview_binchan.ElecRange.Value =1;
        else
            ERPwaveview_binchan.ElecRange.Value =chanArray+1;
        end
        
        ERPtooltype = erpgettoolversion('tooltype');
        if ~strcmpi(ERPtooltype,'EStudio') %&& ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
        
        estudioworkingmemory('MyViewer_chanbin',0);
        ERPwaveview_binchan.apply.BackgroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        ERPwaveview_binchan.apply.ForegroundColor = [0 0 0];
         MessageViewer= char(strcat('Channels and Bins > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end

%%------------------------------Apply--------------------------------------
    function setbinchan_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        MessageViewer= char(strcat('Channels and Bins > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\nChannels and Bins > Apply-f_ERP_Binchan_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        ERPwaviewer_apply.binchan_op = ERPwaveview_binchan.auto.Value;
        ChanArrayValue = ERPwaveview_binchan.ElecRange.Value;
        if numel(ChanArrayValue)== 1&& ChanArrayValue ==1
            ChanArray = [1:length(ERPwaveview_binchan.ElecRange.String)-1];
        else
            ChanArray =  ChanArrayValue-1;
        end
        ERPwaviewer_apply.chan = ChanArray;
        BinArrayValue = ERPwaveview_binchan.BinRange.Value;
        if BinArrayValue ==1
            BinArray = [1:length(ERPwaveview_binchan.BinRange.String)-1];
        else
            BinArray =  BinArrayValue-1;
        end
        ERPwaviewer_apply.bin = BinArray;
        
        %%recover the label for bin and channel panel, and reset
        %%backgroundcolor of "Apply"
        estudioworkingmemory('MyViewer_chanbin',0);
        ERPwaveview_binchan.apply.BackgroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        ERPwaveview_binchan.apply.ForegroundColor = [0 0 0];
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        
        %%save the parameters to memory file
        MERPWaveViewer_chanbin{1} = ERPwaviewer_apply.binchan_op;
        MERPWaveViewer_chanbin{2} =ERPwaviewer_apply.chan;
        MERPWaveViewer_chanbin{3} =ERPwaviewer_apply.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        %%change  the other panels based on the changed bins and channels
        viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
        %%plot waves
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
    end

%%---------change channels and bins based on the selected ERPsets----------
    function v_currentERP_change(~,~)
        try
            ERPwaviewer_S  = evalin('base','ALLERPwaviewer');
        catch
            return;
        end
        ALLERP_S = ERPwaviewer_S.ALLERP;
        Selected_ERPsetlabel = ERPwaviewer_S.SelectERPIdx;
        
        if max(Selected_ERPsetlabel(:))> length(ALLERP_S)
            Selected_ERPsetlabel =length(ALLERP_S);
        end
        try
            ERPwaviewer_S.ERP = ALLERP_S(Selected_ERPsetlabel(1));
            ERPwaviewer_S.CURRENTERP =Selected_ERPsetlabel(1);
        catch
            ERPwaviewer_S.ERP = ALLERP_S(Selected_ERPsetlabel(1));
            ERPwaviewer_S.CURRENTERP =Selected_ERPsetlabel(1);
        end
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP_S,Selected_ERPsetlabel);
        % Channel information
        Chanlist_name = cell(length(chanStr)+1,1);
        Chanlist_name(1) = {'All'};
        for Numofchan11 = 1:length(chanStr)
            Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
        end
        % Channel information
        Chanlist = chanStr;
        Chan_selindex = ERPwaveview_binchan.ElecRange.Value;
        if numel(Chan_selindex) ==1 && Chan_selindex==1
            Chan_sel = [1:numel(ERPwaveview_binchan.ElecRange.String)-1];
        else
            Chan_sel =Chan_selindex-1;
        end
        if ~isempty(Chan_sel)
            if max(Chan_sel)> numel(Chanlist)
                Chan_sel=   1:length(Chanlist);
            end
        else
            Chan_sel= 1:length(Chanlist);
        end
        ERPwaveview_binchan.ElecRange.String = Chanlist_name;
        try
            if length(Chan_sel) ==  numel(chanStr)
                ERPwaveview_binchan.ElecRange.Value  =1;
            else
                ERPwaveview_binchan.ElecRange.Value  =Chan_sel+1;
            end
        catch
            ERPwaveview_binchan.ElecRange.Value  =1;
        end
        ERPwaveview_binchan.ElecRange.Min = 1;
        ERPwaveview_binchan.ElecRange.Max = length(ERPwaveview_binchan.ElecRange.String)+1;
        
        %%Bin information
        brange = cell(length(binStr)+1,1);
        BinNum = length(binStr);
        Bin_selIndex = ERPwaveview_binchan.BinRange.Value;
        if numel(Bin_selIndex) ==1  && Bin_selIndex==1
            Bin_sel = [1:numel(ERPwaveview_binchan.BinRange.String)-1];
        else
            Bin_sel = Bin_selIndex-1;
        end
        if ~isempty(Bin_sel)
            if max(Bin_sel)> BinNum
                Bin_sel=   1:BinNum;
            end
        else
            Bin_sel= 1:BinNum;
        end
        brange(1) = {'All'};
        for Numofbin11 = 1:length(binStr)
            brange(Numofbin11+1) = {char(strcat(num2str(Numofbin11),'.',32,char(binStr(Numofbin11))))};
        end
        ERPwaveview_binchan.BinRange.String = brange;
        if BinNum== numel(Bin_sel)
            ERPwaveview_binchan.BinRange.Value  =1;
        else
            ERPwaveview_binchan.BinRange.Value = Bin_sel+1;
        end
        
        ChanArrayValue = ERPwaveview_binchan.ElecRange.Value;
        if numel(ChanArrayValue)== 1&& ChanArrayValue ==1
            ChanArray = [1:length(ERPwaveview_binchan.ElecRange.String)-1];
        else
            ChanArray =  ChanArrayValue-1;
        end
        ERPwaviewer_S.chan = ChanArray;
        
        BinArrayValue =ERPwaveview_binchan.BinRange.Value ;
        if BinArrayValue ==1
            BinArray = [1:length(ERPwaveview_binchan.BinRange.String)-1];
        else
            BinArray =  BinArrayValue-1;
        end
        ERPwaviewer_S.bin = BinArray;
        assignin('base','ALLERPwaviewer',ERPwaviewer_S);
        
        %%save the parameters to memory file
        MERPWaveViewer_chanbin{1} = ERPwaviewer_S.binchan_op;
        MERPWaveViewer_chanbin{2} =ERPwaviewer_S.chan;
        MERPWaveViewer_chanbin{3} =ERPwaviewer_S.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
    end



%%------------update this panel based on the imported parameters-----------
    function loadproper_change(~,~)
        if viewer_ERPDAT.loadproper_count ~=2
            return;
        end
        
        try
            ERPwaviewer_S  = evalin('base','ALLERPwaviewer');
        catch
            return;
        end
        ALLERP_S = ERPwaviewer_S.ALLERP;
        Selected_ERPsetlabel = ERPwaviewer_S.SelectERPIdx;
        
        if max(Selected_ERPsetlabel(:))> length(ALLERP_S)
            Selected_ERPsetlabel =length(ALLERP_S);
        end
        try
            ERPwaviewer_S.ERP = ALLERP_S(Selected_ERPsetlabel(1));
            ERPwaviewer_S.CURRENTERP =Selected_ERPsetlabel(1);
        catch
            ERPwaviewer_S.ERP = ALLERP_S(Selected_ERPsetlabel(1));
            ERPwaviewer_S.CURRENTERP =Selected_ERPsetlabel(1);
        end
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP_S,Selected_ERPsetlabel);
        % Channel information
        Chanlist_name = cell(length(chanStr)+1,1);
        Chanlist_name(1) = {'All'};
        for Numofchan11 = 1:length(chanStr)
            Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
        end
        % Channel information
        Chanlist = chanStr;
        Chan_sel =ERPwaviewer_S.chan;
        if ~isempty(Chan_sel)
            if max(Chan_sel)> numel(Chanlist)
                Chan_sel=   1:length(Chanlist);
            end
        else
            Chan_sel= 1:length(Chanlist);
        end
        ERPwaviewer_S.chan = Chan_sel;
        ERPwaveview_binchan.ElecRange.String = Chanlist_name;
        try
            if length(Chan_sel) ==  numel(chanStr)
                ERPwaveview_binchan.ElecRange.Value  =1;
            else
                ERPwaveview_binchan.ElecRange.Value  =Chan_sel+1;
            end
        catch
            ERPwaveview_binchan.ElecRange.Value  =1;
        end
        ERPwaveview_binchan.ElecRange.Min = 1;
        ERPwaveview_binchan.ElecRange.Max = length(ERPwaveview_binchan.ElecRange.String)+1;
        
        %%Bin information
        brange = cell(length(binStr)+1,1);
        BinNum = length(binStr);
        Bin_sel = ERPwaviewer_S.bin;
        if ~isempty(Bin_sel)
            if max(Bin_sel)> BinNum
                Bin_sel=   1:BinNum;
            end
        else
            Bin_sel= 1:BinNum;
        end
        brange(1) = {'All'};
        for Numofbin11 = 1:length(binStr)
            brange(Numofbin11+1) = {char(strcat(num2str(Numofbin11),'.',32,char(binStr(Numofbin11))))};
        end
        ERPwaveview_binchan.BinRange.String = brange;
        if BinNum== numel(Bin_sel)
            ERPwaveview_binchan.BinRange.Value  =1;
        else
            ERPwaveview_binchan.BinRange.Value = Bin_sel+1;
        end
        ERPwaviewer_S.bin = Bin_sel;
        
        ERPtooltype = erpgettoolversion('tooltype');
        if ~strcmpi(ERPtooltype,'EStudio') && ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaviewer_S.erp_binchan_op = 0;
        end
        
        %%Auto or Custom
        binchanOp =  ERPwaviewer_S.binchan_op;
        if binchanOp ==1
            ERPwaveview_binchan.auto.Value = 1;
            ERPwaveview_binchan.custom.Value =0;
            ERPwaveview_binchan.ElecRange.Enable = 'off';
            ERPwaveview_binchan.BinRange.Enable = 'off';
        else
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
        %%settings dependent on runing EStudio or ERPLAB or other way (e.g.,script).
        if strcmpi(ERPtooltype,'EStudio')
            ERPwaveview_binchan.auto.String = 'Same as EStudio';
        elseif  strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_binchan.auto.String = '';
            ERPwaveview_binchan.BinRange.Enable = 'on';
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.auto.Enable = 'off';
            ERPwaveview_binchan.custom.Enable = 'off';
        else
            ERPwaveview_binchan.auto.String = '';
            ERPwaveview_binchan.auto.Enable = 'off';
            ERPwaveview_binchan.custom.Value =1;
            ERPwaveview_binchan.custom.String = '';
            ERPwaveview_binchan.auto.Value = 0;
            ERPwaveview_binchan.custom.Enable = 'off';
            ERPwaveview_binchan.ElecRange.Enable = 'on';
            ERPwaveview_binchan.BinRange.Enable = 'on';
        end
        
        assignin('base','ALLERPwaviewer',ERPwaviewer_S);
        %%save the parameters to memory file
        MERPWaveViewer_chanbin{1} = ERPwaviewer_S.binchan_op;
        MERPWaveViewer_chanbin{2} =ERPwaviewer_S.chan;
        MERPWaveViewer_chanbin{3} =ERPwaviewer_S.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        viewer_ERPDAT.loadproper_count=3;
    end

%%modify the channels based on the changes of main EStudio
    function ERP_chan_changed(~,~)
        ALLERPStudio = observe_ERPDAT.ALLERP;
        if isempty(ALLERPStudio) || (length(ALLERPStudio)==1&& strcmpi(ALLERPStudio(1).erpname,'No ERPset loaded')) || strcmpi(ALLERPStudio(length(ALLERPStudio)).erpname,'No ERPset loaded')
            return;
        end
        try
            ChanBinAutoValue =  ERPwaveview_binchan.auto.Value;
        catch
            return;
        end
        
        ChanArrayStudio = observe_ERPDAT.ERP_chan;
        chanNumdef = length(ERPwaveview_binchan.ElecRange.String)-1;
        
        if ~isempty(ChanArrayStudio) && ChanBinAutoValue==1
            if min(ChanArrayStudio(:))<=0 || max(ChanArrayStudio(:))>chanNumdef
                return;
            end
            
            MessageViewer= char(strcat('Channels and Bins > Channel'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            %             viewer_ERPDAT.Process_messg =1;
            
            try
                ALLERPwaviewer_apply = evalin('base','ALLERPwaviewer');
            catch
                viewer_ERPDAT.Process_messg =3;
                fprintf(2,'\nChannels and Bins -f_ERP_Binchan_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
                return;
            end
            try
                if numel(ChanArrayStudio)==chanNumdef
                    ERPwaveview_binchan.ElecRange.Value =1;
                else
                    ERPwaveview_binchan.ElecRange.Value =ChanArrayStudio+1;
                end
            catch
                ERPwaveview_binchan.ElecRange.Value  =1;
            end
            ALLERPwaviewer_apply.chan = ChanArrayStudio;
            assignin('base','ALLERPwaviewer',ALLERPwaviewer_apply);
            %%change  the other panels based on the changed bins and channels
            viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
            
            %%save the parameters to memory file
            MERPWaveViewer_chanbin{1} = ALLERPwaviewer_apply.binchan_op;
            MERPWaveViewer_chanbin{2} =ALLERPwaviewer_apply.chan;
            MERPWaveViewer_chanbin{3} =ALLERPwaviewer_apply.bin;
            estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
            %%plot waves
            f_redrawERP_viewer_test();
        end
    end

%%modify the bins based on the changes of main EStudio
    function ERP_bin_changed(~,~)
        ALLERPStudio = observe_ERPDAT.ALLERP;
        if isempty(ALLERPStudio) || (length(ALLERPStudio)==1&& strcmpi(ALLERPStudio(1).erpname,'No ERPset loaded')) || strcmpi(ALLERPStudio(length(ALLERPStudio)).erpname,'No ERPset loaded')
            return;
        end
        
        try
            ChanBinAutoValue =  ERPwaveview_binchan.auto.Value;
        catch
            return;
        end
        BinArrayStudio =  observe_ERPDAT.ERP_bin;
        binNumdef = length(ERPwaveview_binchan.BinRange.String)-1;
        if ~isempty(BinArrayStudio) && ChanBinAutoValue==1
            if min(BinArrayStudio(:))<=0 || max(BinArrayStudio(:))> binNumdef
                return;
            end
            MessageViewer= char(strcat('Channels and Bins > Bin'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            %             viewer_ERPDAT.Process_messg =1;
            
            try
                ALLERPwaviewer_apply = evalin('base','ALLERPwaviewer');
            catch
                viewer_ERPDAT.Process_messg =3;
                fprintf(2,'\nChannels and Bins -f_ERP_Binchan_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
                return;
            end
            try
                if numel(BinArrayStudio)==binNumdef
                    ERPwaveview_binchan.BinRange.Value =1;
                else
                    ERPwaveview_binchan.BinRange.Value =BinArrayStudio+1;
                end
            catch
                ERPwaveview_binchan.BinRange.Value  =1;
            end
            ALLERPwaviewer_apply.bin = BinArrayStudio;
            assignin('base','ALLERPwaviewer',ALLERPwaviewer_apply);
            
            %%save the parameters to memory file
            MERPWaveViewer_chanbin{1} = ALLERPwaviewer_apply.binchan_op;
            MERPWaveViewer_chanbin{2} =ALLERPwaviewer_apply.chan;
            MERPWaveViewer_chanbin{3} =ALLERPwaviewer_apply.bin;
            estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
            
            %%change  the other panels based on the changed bins and channels
            viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
            %%plot waves
            f_redrawERP_viewer_test();
        end
    end


%%change channels and bins based on the main EStudio
    function Two_GUI_change(~,~)
        if observe_ERPDAT.Two_GUI~=2
            return;
        end
        
        ERPtooltype = erpgettoolversion('tooltype');
        if isempty(observe_ERPDAT.ALLERP)
            try
                % %                 cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                close(gui_erp_waviewer.Window);
            catch
            end
            assignin('base','ALLERPwaviewer',[]);
            return;
        end
        
        
        ALLERPStudio = observe_ERPDAT.ALLERP;
        if strcmpi(ERPtooltype,'EStudio')
            if  (length(ALLERPStudio)==1&& strcmpi(ALLERPStudio(1).erpname,'No ERPset loaded')) || strcmpi(ALLERPStudio(length(ALLERPStudio)).erpname,'No ERPset loaded')
                try
                    %                     cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                    close(gui_erp_waviewer.Window);
                catch
                end
                assignin('base','ALLERPwaviewer',[]);
                return;
            end
        end
        
        try
            ALLERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\nChannels and Bins -f_ERP_Binchan_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        try
            ChanBinAutoValue =  ERPwaveview_binchan.auto.Value;
        catch
            return;
        end
        MessageViewer= char(strcat('Channels and Bins'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        
        if strcmpi(ERPtooltype,'EStudio') && ChanBinAutoValue==1
            ALLERPwaviewer_apply.bin=observe_ERPDAT.ERP_bin;
            ALLERPwaviewer_apply.chan=observe_ERPDAT.ERP_chan;
        end
        
        BinArrayStudio =  ALLERPwaviewer_apply.bin;
        binNumdef = length(ERPwaveview_binchan.BinRange.String)-1;
        if ~isempty(BinArrayStudio) && ChanBinAutoValue==1
            if min(BinArrayStudio(:))<=0 || max(BinArrayStudio(:))> binNumdef
                return;
            end
            try
                if numel(BinArrayStudio)==binNumdef
                    ERPwaveview_binchan.BinRange.Value =1;
                else
                    ERPwaveview_binchan.BinRange.Value =BinArrayStudio+1;
                end
            catch
                ERPwaveview_binchan.BinRange.Value  =1;
            end
            ALLERPwaviewer_apply.bin = BinArrayStudio;
        end
        
        ChanArrayStudio = ALLERPwaviewer_apply.chan;
        chanNumdef = length(ERPwaveview_binchan.ElecRange.String)-1;
        if ~isempty(ChanArrayStudio) && ChanBinAutoValue==1
            if min(ChanArrayStudio(:))<=0 || max(ChanArrayStudio(:))>chanNumdef
                return;
            end
            try
                if numel(ChanArrayStudio)==chanNumdef
                    ERPwaveview_binchan.ElecRange.Value =1;
                else
                    ERPwaveview_binchan.ElecRange.Value =ChanArrayStudio+1;
                end
                ERPwaveview_binchan.ElecRange.Max = length( ERPwaveview_binchan.ElecRange.String)+2;
            catch
                ERPwaveview_binchan.ElecRange.Value  =1;
            end
            ALLERPwaviewer_apply.chan = ChanArrayStudio;
        end
        ERPwaveview_binchan.ElecRange.Max = length(ERPwaveview_binchan.ElecRange.String)+2;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer_apply);
        
        %%save the parameters to memory file
        MERPWaveViewer_chanbin{1} = ALLERPwaviewer_apply.binchan_op;
        MERPWaveViewer_chanbin{2} =ALLERPwaviewer_apply.chan;
        MERPWaveViewer_chanbin{3} =ALLERPwaviewer_apply.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        
        
        %%change  the other panels based on the changed bins and channels
        viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
        %%plot waves
        f_redrawERP_viewer_test();
        observe_ERPDAT.Two_GUI = 0;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_chanbin');
        if changeFlag~=1
            return;
        end
        setbinchan_apply();
    end

%%Reset this panel with the default parameters
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==2
            ERPtooltype = erpgettoolversion('tooltype');
            try
                ERPwaviewerIN = evalin('base','ALLERPwaviewer');
                ALLERPIN = ERPwaviewerIN.ALLERP;
            catch
                beep;
                disp('f_ERP_Binchan_waviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            
            if strcmpi(ERPtooltype,'EStudio')
                ERPwaveview_binchan.auto.Value = 1;
                ERPwaveview_binchan.custom.Value =0;
                ERPwaveview_binchan.ElecRange.Enable = 'off';
                ERPwaveview_binchan.BinRange.Enable = 'off';
                Selected_erpset= estudioworkingmemory('selectederpstudio');
                Geterpbinchan = estudioworkingmemory('geterpbinchan');
                CurrentERPIndex = Geterpbinchan.Select_index;
                
                if max(Selected_erpset(:))> length(ALLERPIN)
                    Selected_erpset =1;
                    CurrentERPIndex =1;
                end
                BinArray = Geterpbinchan.bins{Geterpbinchan.Select_index};
                chanArray = Geterpbinchan.elecs_shown{Geterpbinchan.Select_index};
                chan_bin = Geterpbinchan.bins_chans(CurrentERPIndex);
                if chan_bin ==1
                    ERPwaviewerIN.plot_org.Grid =2;
                    ERPwaviewerIN.plot_org.Overlay=1;
                    ERPwaviewerIN.plot_org.Pages=3;
                elseif chan_bin==0
                    ERPwaviewerIN.plot_org.Grid =1;
                    ERPwaviewerIN.plot_org.Overlay=2;
                    ERPwaviewerIN.plot_org.Pages=3;
                end
                
                % Channel information
                chanStr = [1:(numel(ERPwaveview_binchan.ElecRange.String)-1)];
                Chanlist = chanStr;
                Chan_sel = chanArray;
                if ~isempty(Chan_sel)
                    if max(Chan_sel)> numel(Chanlist)
                        Chan_sel=   1:length(Chanlist);
                    end
                else
                    Chan_sel=   1:length(Chanlist);
                end
                try
                    if length(Chan_sel) ==  numel(chanStr)
                        ERPwaveview_binchan.ElecRange.Value  =1;
                    else
                        ERPwaveview_binchan.ElecRange.Value  =Chan_sel+1;
                    end
                catch
                    ERPwaveview_binchan.ElecRange.Value  =1;
                end
                
                %%Bin information
                binStr =  ERPwaveview_binchan.BinRange.String;
                BinNum = length(binStr)-1;
                Bin_sel = BinArray;
                if ~isempty(Bin_sel)
                    if max(Bin_sel)> BinNum
                        Bin_sel=   1:BinNum;
                    end
                else
                    Bin_sel=   1:BinNum;
                end
                
                if BinNum== numel(Bin_sel)
                    ERPwaveview_binchan.BinRange.Value  =1;
                else
                    ERPwaveview_binchan.BinRange.Value = Bin_sel+1;
                end
                
                ERPwaviewerIN.bin = Bin_sel;
                ERPwaviewerIN.chan = Chan_sel;
                ERPwaviewerIN.binchan_op = 1;
            elseif strcmpi(ERPtooltype,'ERPLAB')
                ERPwaveview_binchan.auto.Value = 0;
                ERPwaveview_binchan.custom.Value =1;
                ERPwaveview_binchan.auto.Enable = 'off';
                ERPwaveview_binchan.custom.Enable = 'off';
                ERPwaveview_binchan.ElecRange.Enable = 'on';
                ERPwaveview_binchan.BinRange.Enable = 'on';
                Selected_erpset = evalin('base','CURRENTERP');
                ALLERP = evalin('base','ALLERP');
                if ~isempty(Selected_erpset) && ~isempty(ALLERP) && (Selected_erpset<= length(ALLERP)) && min(Selected_erpset)>0
                    [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP,Selected_erpset);
                    Chanlist_name = cell(length(chanStr)+1,1);
                    Chanlist_name(1) = {'All'};
                    for Numofchan11 = 1:length(chanStr)
                        Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
                    end
                    ERPwaveview_binchan.ElecRange.String = Chanlist_name;
                    ERPwaveview_binchan.ElecRange.Value =1;
                    
                    brange = cell(length(binStr)+1,1);
                    brange(1) = {'All'};
                    for Numofbin11 = 1:length(binStr)
                        brange(Numofbin11+1) = {char(strcat(num2str(Numofbin11),'.',32,char(binStr(Numofbin11))))};
                    end
                    ERPwaveview_binchan.BinRange.String = brange;
                    ERPwaveview_binchan.BinRange.Value = 1;
                end
                ERPwaviewerIN.bin = [1:length(ERPwaveview_binchan.BinRange.String)-1];
                ERPwaviewerIN.chan = [1:length(ERPwaveview_binchan.ElecRange.String)-1];
                ERPwaviewerIN.binchan_op = 0;
            end
            assignin('base','ALLERPwaviewer',ERPwaviewerIN);
            
            %%save the parameters to memory file
            MERPWaveViewer_chanbin{1} = ERPwaviewerIN.binchan_op;
            MERPWaveViewer_chanbin{2} =ERPwaviewerIN.chan;
            MERPWaveViewer_chanbin{3} =ERPwaviewerIN.bin;
            estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
            
            ERPwaveview_binchan.apply.BackgroundColor = [1 1 1];
            Chanbin_waveviewer_box.TitleColor= [0.5 0.5 0.9];
            ERPwaveview_binchan.apply.ForegroundColor = [0 0 0];
            viewer_ERPDAT.Reset_Waviewer_panel=3;
        end
    end%%reset end

%%Update the change of label indeces
    function ERPset_Chan_bin_label_change(~,~)
        if viewer_ERPDAT.ERPset_Chan_bin_label~=1
            return;
        end
        try
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_Binchan_waviewer_GUI error: Restart ERPwave Viewer');
            return;
        end
        
        if ERPwaveview_binchan.auto.Value ==0
            BinArray = ERPwaviewerIN.bin;
            ChanArray =  ERPwaviewerIN.chan;
            ChaNum= length(ERPwaveview_binchan.ElecRange.String)-1;
            if max(ChanArray(:)) <=ChaNum
                if ChaNum== numel(ChanArray)
                    ERPwaveview_binchan.ElecRange.Value=1;
                else
                    ERPwaveview_binchan.ElecRange.Value= ChanArray+1;
                end
            end
            BiNum = length(ERPwaveview_binchan.BinRange.String)-1;
            if max(BinArray(:)) <=BiNum
                if numel(BinArray)==BiNum
                    ERPwaveview_binchan.BinRange.Value=1;
                else
                    ERPwaveview_binchan.BinRange.Value=BinArray+1;
                end
            end
            
            %%save the parameters to memory file
            MERPWaveViewer_chanbin{1} = ERPwaviewerIN.binchan_op;
            MERPWaveViewer_chanbin{2} =ERPwaviewerIN.chan;
            MERPWaveViewer_chanbin{3} =ERPwaviewerIN.bin;
            estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin); 
        end
    end


%%Execute the panel when press "Return" or "Enter"
    function setbinchan_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            setbinchan_apply();
        else
            return;
        end
    end

end