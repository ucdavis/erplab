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
global viewer_ERPDAT
global gui_erp_waviewer;
addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);


ERPwaveview_binchan = struct();

try
    [version reldate,ColorBviewer_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
catch
    ColorBviewer_def = [0.7765    0.7294    0.8627];
end
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
        
        ERPwaveview_binchan.vBox = uiextras.VBox('Parent', Chanbin_waveviewer_box, 'Spacing', 5,'BackgroundColor',ColorBviewer_def); % VBox for everything
        ERPtooltype = erpgettoolversion('tooltype');
        MERPWaveViewer_chanbin{1}=0;
        
        %%---------------------Display channel and bin labels-----------------------------------------------------
        ERPwaveview_binchan.DataSelGrid = uiextras.HBox('Parent', ERPwaveview_binchan.vBox,'BackgroundColor',ColorBviewer_def);
        [chanStr,binStr,diff_mark] = f_geterpschanbin(gui_erp_waviewer.ERPwaviewer.ALLERP,gui_erp_waviewer.ERPwaviewer.SelectERPIdx);
        
        Chanlist_name = cell(length(chanStr)+1,1);
        Chanlist_name(1) = {'All'};
        for Numofchan11 = 1:length(chanStr)
            Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
        end
        % Channel information
        Chanlist = chanStr;
        Chan_seldef = gui_erp_waviewer.ERPwaviewer.chan;
        if ~isempty(Chan_seldef)
            if any(Chan_seldef> numel(Chanlist))
                Chan_seldef=   1:length(Chanlist);
            end
        else
            Chan_seldef=   1:length(Chanlist);
        end
        if strcmpi(ERPtooltype,'EStudio')
            Chan_sel = Chan_seldef;
            MERPWaveViewer_chanbin{2} = Chan_seldef;
        else
            Chan_sel = 1:length(Chanlist);
            MERPWaveViewer_chanbin{2} = Chan_sel;
        end
        Chan_sel = unique(Chan_sel);
        if isempty(Chan_sel) || any(Chan_sel(:)> length(Chanlist)) || any(Chan_sel(:)<=0)
            MERPWaveViewer_chanbin{2} = Chan_seldef;
            Chan_sel = Chan_seldef;
        end
        gui_erp_waviewer.ERPwaviewer.chan = Chan_sel;
        ERPwaveview_binchan.ElecRange = uicontrol('Parent', ERPwaveview_binchan.DataSelGrid,'Style','listbox','min',1,'max',length(Chanlist_name),...
            'String', Chanlist_name,'Callback',@ViewerElecRange,'FontSize',FonsizeDefault,'Enable','on','BackgroundColor',[1 1 1]); % 2B
        
        ERPwaveview_binchan.ElecRange.KeyPressFcn = @setbinchan_presskey;
        if  numel(Chan_sel) == numel(Chanlist)
            ERPwaveview_binchan.ElecRange.Value  =1;
        else
            ERPwaveview_binchan.ElecRange.Value = Chan_sel+1;
        end
        %%Bin information
        brange = cell(length(binStr)+1,1);
        BinNum = length(binStr);
        Bin_seldef = gui_erp_waviewer.ERPwaviewer.bin;
        if ~isempty(Bin_seldef)
            if any(Bin_seldef> BinNum)
                Bin_seldef=   1:BinNum;
            end
        else
            Bin_seldef=   1:BinNum;
        end
        if strcmpi(ERPtooltype,'EStudio')
            MERPWaveViewer_chanbin{3} = Bin_seldef;
            Bin_sel = Bin_seldef;
        else
            Bin_sel = 1:BinNum;
            MERPWaveViewer_chanbin{3} = Bin_sel;
        end
        if isempty(Bin_sel) || any(Bin_sel(:)> length(binStr)) || any(Bin_sel(:)<=0)
            Bin_sel = 1:BinNum;
            MERPWaveViewer_chanbin{3} = Bin_sel;
        end
        gui_erp_waviewer.ERPwaviewer.bin=Bin_sel;
        brange(1) = {'All'};
        for Numofbin11 = 1:length(binStr)
            brange(Numofbin11+1) = {char(strcat(num2str(Numofbin11),'.',32,char(binStr(Numofbin11))))};
        end
        ERPwaveview_binchan.BinRange =  uicontrol('Parent', ERPwaveview_binchan.DataSelGrid,'Style','listbox','Min',1,'Max',BinNum+1,...
            'String', brange,'callback',@ViewerBinRange,'FontSize',FonsizeDefault,'Enable','on','BackgroundColor',[1 1 1]); % 2C
        ERPwaveview_binchan.BinRange.KeyPressFcn = @setbinchan_presskey;
        if BinNum== numel(Bin_sel)
            ERPwaveview_binchan.BinRange.Value  =1;
        else
            ERPwaveview_binchan.BinRange.Value = Bin_sel+1;
        end
        set(ERPwaveview_binchan.DataSelGrid, 'Sizes',[ -1.2 -2]);
        
        %%Help and apply
        ERPwaveview_binchan.help_apply_title = uiextras.HBox('Parent', ERPwaveview_binchan.vBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',ERPwaveview_binchan.help_apply_title );
        ERPwaveview_binchan.cancel = uicontrol('Style','pushbutton','Parent', ERPwaveview_binchan.help_apply_title  ,'String','Cancel',...
            'callback',@setbinchan_cancel,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'FontWeight','bold','HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_binchan.help_apply_title  );
        ERPwaveview_binchan.apply =  uicontrol('Style','pushbutton','Parent',ERPwaveview_binchan.help_apply_title  ,'String','Apply',...
            'callback',@setbinchan_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        %         ERPwaveview_binchan.custom.KeyPressFcn = @setbinchan_presskey;
        uiextras.Empty('Parent',ERPwaveview_binchan.help_apply_title );
        set(ERPwaveview_binchan.help_apply_title ,'Sizes',[40 70 20 70 20]);
        set(ERPwaveview_binchan.vBox, 'Sizes', [210 25]);
        
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin); %%save chan array and bin array
        estudioworkingmemory('MyViewer_chanbin',0);
        
        gui_erp_waviewer.ERPwaviewer.bin = Bin_sel;
        gui_erp_waviewer.ERPwaviewer.chan = Chan_sel;
        
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
        ERPwaveview_binchan.cancel.BackgroundColor =  [0.4940 0.1840 0.5560];
        ERPwaveview_binchan.cancel.ForegroundColor = [1 1 1];
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
        ERPwaveview_binchan.cancel.BackgroundColor =  [0.4940 0.1840 0.5560];
        ERPwaveview_binchan.cancel.ForegroundColor = [1 1 1];
    end

%%-------------------------------Help--------------------------------------
    function setbinchan_cancel(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        changeFlag =  estudioworkingmemory('MyViewer_chanbin');
        if changeFlag~=1
            return;
        end
        MessageViewer= char(strcat('Channels and Bins > Cancel'));
        estudioworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        binArray =   gui_erp_waviewer.ERPwaviewer.bin;
        if isempty(binArray) || any(binArray<=0) || any(binArray>length(ERPwaveview_binchan.BinRange.String)-1)
            binArray = [1:length(ERPwaveview_binchan.BinRange.String)-1];
            gui_erp_waviewer.ERPwaviewer.bin=binArray;
        end
        
        chanArray =  gui_erp_waviewer.ERPwaviewer.chan;
        if isempty(chanArray) || any(chanArray<=0) || any(chanArray>  length(ERPwaveview_binchan.ElecRange.String)-1)
            chanArray =   [1:length(ERPwaveview_binchan.BinRange.String)-1];
            gui_erp_waviewer.ERPwaviewer.chan= chanArray;
        end
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
        
        ERPwaveview_binchan.ElecRange.Enable = 'on';
        ERPwaveview_binchan.BinRange.Enable = 'on';
        
        estudioworkingmemory('MyViewer_chanbin',0);
        ERPwaveview_binchan.apply.BackgroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        ERPwaveview_binchan.apply.ForegroundColor = [0 0 0];
        ERPwaveview_binchan.cancel.BackgroundColor =  [1 1 1];
        ERPwaveview_binchan.cancel.ForegroundColor = [0 0 0];
        MessageViewer= char(strcat('Channels and Bins > Cancel'));
        estudioworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end

%%------------------------------Apply--------------------------------------
    function setbinchan_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=2
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        MessageViewer= char(strcat('Channels and Bins > Apply'));
        estudioworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        gui_erp_waviewer.ERPwaviewer.binchan_op = 0;
        ChanArrayValue = ERPwaveview_binchan.ElecRange.Value;
        if numel(ChanArrayValue)== 1 && ChanArrayValue ==1
            ChanArray = [1:length(ERPwaveview_binchan.ElecRange.String)-1];
        else
            ChanArray =  ChanArrayValue-1;
        end
        gui_erp_waviewer.ERPwaviewer.chan = ChanArray;
        BinArrayValue = ERPwaveview_binchan.BinRange.Value;
        if BinArrayValue ==1
            BinArray = [1:length(ERPwaveview_binchan.BinRange.String)-1];
        else
            BinArray =  BinArrayValue-1;
        end
        gui_erp_waviewer.ERPwaviewer.bin = BinArray;
        
        estudioworkingmemory('MyViewer_chanbin',0);
        ERPwaveview_binchan.apply.BackgroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        ERPwaveview_binchan.apply.ForegroundColor = [0 0 0];
        ERPwaveview_binchan.cancel.BackgroundColor =  [1 1 1];
        ERPwaveview_binchan.cancel.ForegroundColor = [0 0 0];
        
        MERPWaveViewer_chanbin{1} = 0;
        MERPWaveViewer_chanbin{2} =gui_erp_waviewer.ERPwaviewer.chan;
        MERPWaveViewer_chanbin{3} =gui_erp_waviewer.ERPwaviewer.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        %%change  the other panels based on the changed bins and channels
        viewer_ERPDAT.Count_currentERP = 1;
        viewer_ERPDAT.Process_messg =2;
    end

%%---------change channels and bins based on the selected ERPsets----------
    function v_currentERP_change(~,~)
        if viewer_ERPDAT.Count_currentERP~=2
            return;
        end
        
        ALLERP_S = gui_erp_waviewer.ERPwaviewer.ALLERP;
        ERPsetArray = gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
        
        if any(ERPsetArray(:)> length(ALLERP_S))
            ERPsetArray =length(ALLERP_S);
            gui_erp_waviewer.ERPwaviewer.SelectERPIdx =ERPsetArray;
        end
        try
            gui_erp_waviewer.ERPwaviewer.ERP = ALLERP_S(ERPsetArray(1));
            gui_erp_waviewer.ERPwaviewer.CURRENTERP =ERPsetArray(1);
        catch
            gui_erp_waviewer.ERPwaviewer.ERP = ALLERP_S(ERPsetArray(1));
            gui_erp_waviewer.ERPwaviewer.CURRENTERP =ERPsetArray(1);
            gui_erp_waviewer.ERPwaviewer.PageIndex=1;
        end
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP_S,ERPsetArray);
        % Channel information
        Chanlist_name = cell(length(chanStr)+1,1);
        Chanlist_name(1) = {'All'};
        for Numofchan11 = 1:length(chanStr)
            Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
        end
        % Channel information
        Chanlist = chanStr;
        Chan_selindex = gui_erp_waviewer.ERPwaviewer.chan;
        if isempty(Chan_selindex) || any(Chan_selindex>length(Chanlist)) || any(Chan_selindex(:)<=0)
           Chan_selindex =[1:length(Chanlist)]; 
           gui_erp_waviewer.ERPwaviewer.chan= Chan_selindex;
        end
     
         Chan_sel =Chan_selindex;
         
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
        
        %%----------------------Bin information----------------------------
        brange = cell(length(binStr)+1,1);
        BinNum = length(binStr);
        Bin_selIndex = gui_erp_waviewer.ERPwaviewer.bin;
        if isempty(Bin_selIndex) || any(Bin_selIndex>BinNum) || any(Bin_selIndex<=0)
            Bin_selIndex = [1:BinNum];
            gui_erp_waviewer.ERPwaviewer.bin=Bin_selIndex;
        end
        Bin_sel = Bin_selIndex;
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
        gui_erp_waviewer.ERPwaviewer.chan = ChanArray;
        
        BinArrayValue =ERPwaveview_binchan.BinRange.Value ;
        if BinArrayValue ==1
            BinArray = [1:length(ERPwaveview_binchan.BinRange.String)-1];
        else
            BinArray =  BinArrayValue-1;
        end
        gui_erp_waviewer.ERPwaviewer.bin = BinArray;
        
        ERPwaveview_binchan.ElecRange.Enable = 'on';
        ERPwaveview_binchan.BinRange.Enable = 'on';
        %%save the parameters to memory file
        MERPWaveViewer_chanbin{1} = 0;
        MERPWaveViewer_chanbin{2} =gui_erp_waviewer.ERPwaviewer.chan;
        MERPWaveViewer_chanbin{3} =gui_erp_waviewer.ERPwaviewer.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        viewer_ERPDAT.Count_currentERP=3;
    end



%%------------update this panel based on the imported parameters-----------
    function loadproper_change(~,~)
        if viewer_ERPDAT.loadproper_count ~=2
            return;
        end
        
        ALLERP_S = gui_erp_waviewer.ERPwaviewer.ALLERP;
        ERPsetArray = gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERP_S)
            ERPsetArray =length(ALLERP_S);
        end
        try
            gui_erp_waviewer.ERPwaviewer.ERP = ALLERP_S(ERPsetArray(1));
            gui_erp_waviewer.ERPwaviewer.CURRENTERP =ERPsetArray(1);
        catch
            gui_erp_waviewer.ERPwaviewer.ERP = ALLERP_S(ERPsetArray(1));
            gui_erp_waviewer.ERPwaviewer.CURRENTERP =ERPsetArray(1);
        end
        
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERP_S,ERPsetArray);
        % Channel information
        Chanlist_name = cell(length(chanStr)+1,1);
        Chanlist_name(1) = {'All'};
        for Numofchan11 = 1:length(chanStr)
            Chanlist_name(Numofchan11+1) = {char(strcat(num2str(Numofchan11),'.',32,char(chanStr(Numofchan11))))};
        end
        % Channel information
        Chanlist = chanStr;
        Chan_sel =gui_erp_waviewer.ERPwaviewer.chan;
        if ~isempty(Chan_sel)
            if max(Chan_sel)> numel(Chanlist)
                Chan_sel=   1:length(Chanlist);
            end
        else
            Chan_sel= 1:length(Chanlist);
        end
        gui_erp_waviewer.ERPwaviewer.chan = Chan_sel;
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
        Bin_sel = gui_erp_waviewer.ERPwaviewer.bin;
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
        gui_erp_waviewer.ERPwaviewer.bin = Bin_sel;
        
        ERPtooltype = erpgettoolversion('tooltype');
        if ~strcmpi(ERPtooltype,'EStudio') && ~strcmpi(ERPtooltype,'ERPLAB')
            gui_erp_waviewer.ERPwaviewer.erp_binchan_op = 0;
        end
        
        %%Auto or Custom
        ERPwaveview_binchan.ElecRange.Enable = 'on';
        ERPwaveview_binchan.BinRange.Enable = 'on';
        
        %%settings dependent on runing EStudio or ERPLAB or other way (e.g.,script).
        ERPwaveview_binchan.ElecRange.Enable = 'on';
        ERPwaveview_binchan.BinRange.Enable = 'on';
        
        %%save the parameters to memory file
        gui_erp_waviewer.ERPwaviewer.binchan_op=0;
        MERPWaveViewer_chanbin{1} = 0;
        MERPWaveViewer_chanbin{2} =gui_erp_waviewer.ERPwaviewer.chan;
        MERPWaveViewer_chanbin{3} =gui_erp_waviewer.ERPwaviewer.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        viewer_ERPDAT.loadproper_count=3;
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
        if viewer_ERPDAT.Reset_Waviewer_panel~=2
            return;
        end
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
        gui_erp_waviewer.ERPwaviewer.bin = [1:length(ERPwaveview_binchan.BinRange.String)-1];
        gui_erp_waviewer.ERPwaviewer.chan = [1:length(ERPwaveview_binchan.ElecRange.String)-1];
        gui_erp_waviewer.ERPwaviewer.binchan_op = 0;
        
        %%save the parameters to memory file
        MERPWaveViewer_chanbin{1} = 0;
        MERPWaveViewer_chanbin{2} =gui_erp_waviewer.ERPwaviewer.chan;
        MERPWaveViewer_chanbin{3} =gui_erp_waviewer.ERPwaviewer.bin;
        estudioworkingmemory('MERPWaveViewer_chanbin',MERPWaveViewer_chanbin);
        
        ERPwaveview_binchan.apply.BackgroundColor = [1 1 1];
        Chanbin_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        ERPwaveview_binchan.apply.ForegroundColor = [0 0 0];
        viewer_ERPDAT.Reset_Waviewer_panel=3;
    end%%reset end



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