%%This function is used to get the 'Bin and Channel Selection' Panel and record the change of th selected channels and selected bins

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & Oct 2023


function varargout = f_ERP_bin_channel_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'ERP_chan_change',@ERP_chan_changed);
addlistener(observe_ERPDAT,'ERP_bin_change',@ERP_bin_changed);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);


ERPTab_bin_chan = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_bin_chan;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_bin_chan = uiextras.BoxPanel('Parent', fig, 'Title', 'Bin and Channel Selection', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_bin_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Bin and Channel Selection', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_bin_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Bin and Channel Selection', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

%-----------------------------Draw the panel-------------------------------------

try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end

drawui_bin_chan(FonsizeDefault)
varargout{1} = EStudio_box_bin_chan;

    function drawui_bin_chan(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        ERPTab_bin_chan.DataSelBox = uiextras.VBox('Parent', EStudio_box_bin_chan,'BackgroundColor',ColorB_def);
        ERPTab_bin_chan.DataSelGrid = uiextras.Grid('Parent', ERPTab_bin_chan.DataSelBox,'BackgroundColor',ColorB_def);
        
        % Second column:
        uicontrol('Style','text','Parent', ERPTab_bin_chan.DataSelGrid,'String','Channels','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1B
        Chanlist_name = ['No erpset is available'];
        ERPTab_bin_chan.ElecRange = uicontrol('Parent', ERPTab_bin_chan.DataSelGrid,'Style','listbox','min',1,'max',length(Chanlist_name),...
            'String', Chanlist_name,'Callback',@onElecRange,'FontSize',FonsizeDefault,'Enable','off'); % 2B
        ERPTab_bin_chan.ElecRange.Value  =1;
        ERPTab_bin_chan.ElecRange.KeyPressFcn=  @erp_binchan_presskey;
        % Third column:
        uicontrol('Style','text','Parent', ERPTab_bin_chan.DataSelGrid,'String','Bins','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1C
        
        brange = ['No erpset is available'];
        ERPTab_bin_chan.BinRange =  uicontrol('Parent', ERPTab_bin_chan.DataSelGrid,'Style','listbox','Min',1,'Max',2,...
            'String', brange,'callback',@onBinChanged,'FontSize',FonsizeDefault,'Enable','off','Value',1); % 2C
        ERPTab_bin_chan.BinRange.KeyPressFcn=  @erp_binchan_presskey;
        
        set(ERPTab_bin_chan.DataSelGrid, 'ColumnSizes',[ -1.2 -2],'RowSizes',[20 -3]);
        
        
        %%Cancel and Apply
        ERPTab_bin_chan.reset_apply = uiextras.HBox('Parent',ERPTab_bin_chan.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', ERPTab_bin_chan.reset_apply); % 1A
        ERPTab_bin_chan.plot_reset = uicontrol('Style', 'pushbutton','Parent',ERPTab_bin_chan.reset_apply,...
            'String','Cancel','callback',@plot_erp_cancel,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        
        uiextras.Empty('Parent', ERPTab_bin_chan.reset_apply); % 1A
        ERPTab_bin_chan.plot_apply = uicontrol('Style', 'pushbutton','Parent',ERPTab_bin_chan.reset_apply,...
            'String','Apply','callback',@binchan_apply,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        ERPTab_bin_chan.plot_apply.KeyPressFcn=  @erp_binchan_presskey;
        uiextras.Empty('Parent', ERPTab_bin_chan.reset_apply); % 1A
        set(ERPTab_bin_chan.reset_apply, 'Sizes',[10,-1,30,-1,10]);
        set(ERPTab_bin_chan.DataSelBox,'Sizes',[250 30]);
        
        estudioworkingmemory('ERPTab_chanbin',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%----------------------------Get the changed channels----------------------*
    function onElecRange (src, ~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_chanbin',1);
        ERPTab_bin_chan.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_bin_chan.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_bin_chan.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_bin_chan.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_bin_chan.plot_reset.ForegroundColor = [1 1 1];
        
        new_chans = src.Value;
        if isempty(new_chans)
            beep;
            disp(['No channel was selected']);
            return;
        end
        [~,y_chan_index_select] = find(new_chans==1);
        if isempty(y_chan_index_select) && numel(new_chans) < length(ERPTab_bin_chan.ElecRange.String)-1 %% 'All' is not slected
        else%% 'All' is selected and included or all channels are slected except 'ALL'
            ERPTab_bin_chan.ElecRange.Value = 1;
        end
    end



%---------------------------get the changed bin----------------------------
    function onBinChanged(Sources, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_chanbin',1);
        ERPTab_bin_chan.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_bin_chan.plot_apply.ForegroundColor = [1 1 1];
        EStudio_box_bin_chan.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_bin_chan.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        ERPTab_bin_chan.plot_reset.ForegroundColor = [1 1 1];
        
        bin_select = ERPTab_bin_chan.BinRange.Value;
        if isempty(bin_select)
            beep;
            disp(['No bin was selected']);
            return;
        end
        [~,y_bin_index_select] = find(bin_select==1);
        if isempty(y_bin_index_select) && numel(bin_select) < length(ERPTab_bin_chan.BinRange.String)-1
        else% 'All' is selected  and inlcuded
            ERPTab_bin_chan.BinRange.Value = 1;
        end
        
    end


%----------displayed channel label will be midified after channels was selected--------
    function ERP_chan_changed(~,~)
        if observe_ERPDAT.Process_messg==0
            return;
        end
        chanString = ERPTab_bin_chan.ElecRange.String;
        chanArray = observe_ERPDAT.ERP_chan;
        if max(chanArray)> length(chanString)-1
            ERPTab_bin_chan.ElecRange.Value =1;
            observe_ERPDAT.ERP_chan = [1:length(chanString)-1];
        else
            if max(chanArray)>length(chanString)-1
                ERPTab_bin_chan.ElecRange.Value =1;
                observe_ERPDAT.ERP_chan = [1:length(chanString)-1];
            else
                if numel(chanArray) == length(chanString)-1
                    ERPTab_bin_chan.ElecRange.Value =1;
                else
                    ERPTab_bin_chan.ElecRange.Value = chanArray+1;
                end
            end
        end
    end



%----------displayed bin label will be midified after different channels was selected--------
    function ERP_bin_changed(~,~)
        if observe_ERPDAT.Process_messg==0
            return;
        end
        binArray =  observe_ERPDAT.ERP_bin;
        binString = ERPTab_bin_chan.BinRange.String;
        
        if max(binArray)> length(binString)-1
            ERPTab_bin_chan.BinRange.Value =1;
            observe_ERPDAT.ERP_bin = [1:length(binString)-1];
        else
            if max(binArray)>length(binString)-1
                ERPTab_bin_chan.BinRange.Value =1;
                observe_ERPDAT.ERP_bin = [1:length(binString)-1];
            else
                if numel(binArray) == length(binString)-1
                    ERPTab_bin_chan.BinRange.Value =1;
                else
                    ERPTab_bin_chan.BinRange.Value = binArray+1;
                end
            end
        end
    end

%%-------------cancel the previously changed parameters--------------------
    function plot_erp_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_ERP_proces_messg','Bin and Channel Selection > Cancel');
        observe_ERPDAT.Process_messg =1;
        
        estudioworkingmemory('ERPTab_chanbin',0);
        ERPTab_bin_chan.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_bin_chan.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_bin_chan.TitleColor= [ 0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_bin_chan.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_bin_chan.plot_reset.ForegroundColor = [0 0 0];
        
        %
        %%setting for channels
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        ChaNum = length(ERPTab_bin_chan.ElecRange.String)-1;
        if isempty(ChanArray) ||  any(ChanArray(:)> ChaNum) || any(ChanArray(:)<=0) || numel(ChanArray) == ChaNum
            ERPTab_bin_chan.ElecRange.Value = 1;
            ChanArray = [1:ChaNum];
        else
            ERPTab_bin_chan.ElecRange.Value = ChanArray+1;
        end
        estudioworkingmemory('EEG_ChanArray',ChanArray);
        
        %
        %%setting for bins
        BinArray=  estudioworkingmemory('ERP_BinArray');
        BinNum = length( ERPTab_bin_chan.BinRange.String)-1;
        if isempty(BinArray) ||  any(BinArray(:)>BinNum) ||  any(BinArray(:)<=0) || (numel(BinArray)==BinNum)
            ERPTab_bin_chan.BinRange.Value=1;
            BinArray = [1:BinNum];
        else
            ERPTab_bin_chan.BinRange.Value = BinArray+1;
        end
        estudioworkingmemory('ERP_BinArray',BinArray);
        erpworkingmemory('f_ERP_proces_messg','Bin and Channel Selection > Cancel');
        observe_ERPDAT.Process_messg =2;
    end

%%---------------------------Apply-----------------------------------------
    function binchan_apply(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('ERPTab_chanbin',0);
        ERPTab_bin_chan.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_bin_chan.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_bin_chan.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_bin_chan.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_bin_chan.plot_reset.ForegroundColor = [0 0 0];
        
        erpworkingmemory('f_ERP_proces_messg','Bin and Channel Selection > Apply');
        observe_ERPDAT.Process_messg =1;
        %
        %%selected channels
        new_chans= ERPTab_bin_chan.ElecRange.Value;
        [~,y_chan_index_select] = find(new_chans==1);
        ChanNum = length(ERPTab_bin_chan.ElecRange.String)-1;
        if isempty(y_chan_index_select) && numel(new_chans) <ChanNum %% 'All' is not slected
            ChanArray = new_chans-1;
        else%% 'All' is selected and included or all channels are slected except 'ALL'
            ChanArray = [1:ChanNum];
        end
        if any(ChanArray(:)<=0)
            ChanArray = [1:ChanNum];
        end
        estudioworkingmemory('ERP_ChanArray',ChanArray);
        %
        %%selectd bins
        BinArray=  ERPTab_bin_chan.BinRange.Value;
        BinNum = length( ERPTab_bin_chan.BinRange.String)-1;
        if isempty(BinArray) && numel(BinArray) < BinNum
            BinArray = BinArray-1;
        else
            BinArray = [1:BinNum];
        end
        if any(BinArray(:)<=0)
            BinArray = [1:BinNum];
        end
        estudioworkingmemory('ERP_BinArray',BinArray);
        
        %%plot waves
        %%insert here
        %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%
        observe_ERPDAT.Count_currentERP=1;
        erpworkingmemory('f_ERP_proces_messg','Bin and Channel Selection > Apply');
        observe_ERPDAT.Process_messg =2;
    end


%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=2
            return;
        end
        disp('need to insert plot function in chan and bin panel ("apply")');%%delete this one this was finished.
        
        if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
            Chanlist_name = 'No erpset is available';
            ERPTab_bin_chan.ElecRange.String = Chanlist_name;
            ERPTab_bin_chan.ElecRange.Value=1;
            Binlist_name = 'No erpset is available ';
            ERPTab_bin_chan.BinRange.String = Binlist_name;
            ERPTab_bin_chan.BinRange.Value=1;
            ChanArray = [];
            BinArray = [];
            Enableflag = 'off';
        else
            Enableflag = 'on';
            %
            %%setting for channels
            ChannelValue =  ERPTab_bin_chan.ElecRange.Value-1;
            Chanlist = observe_ERPDAT.ERP.chanlocs;
            Chanlist_name{1} = 'All';
            for Numofchan = 1:length(Chanlist)
                Chanlist_name{Numofchan+1,1} = strcat(num2str(Numofchan),'.',32,char(Chanlist(Numofchan).labels));
            end
            ERPTab_bin_chan.ElecRange.String=Chanlist_name;
            ERPTab_bin_chan.ElecRange.Min = 1;
            ERPTab_bin_chan.ElecRange.Max = length(Chanlist_name)+1;
            if isempty(ChannelValue) || any(ChannelValue(:)<=0) || any(ChannelValue(:) >length(Chanlist_name)-1) || numel(ChannelValue) == length(Chanlist_name)-1
                ERPTab_bin_chan.ElecRange.Value = 1;
                ChanArray = [1:length(Chanlist_name)-1];
            else
                ERPTab_bin_chan.ElecRange.Value =ChannelValue+1;
                ChanArray = ChannelValue;
            end
            %
            %%setting for bins
            bindescr =  observe_ERPDAT.ERP.bindescr;
            binlist_name{1} = 'All';
            for ii = 1:observe_ERPDAT.ERP.nbin
                try
                    binlist_name{1+ii} = strcat(num2str(ii),'.',32,char(bindescr{ii}));
                catch
                    binlist_name{1+ii} = strcat(num2str(ii),'.',32,'bin',num2str(ii));
                end
            end
            ERPTab_bin_chan.BinRange.String = binlist_name;
            ERPTab_bin_chan.BinRange.Min = 1;
            ERPTab_bin_chan.BinRange.Max = length(binlist_name) + 1;
            BinArray=  ERPTab_bin_chan.BinRange.Value-1;
            BinNum = observe_ERPDAT.ERP.nbin;
            if isempty(BinArray) || any(BinArray(:)<=0) || any(BinArray(:)>BinNum) || numel(BinArray) < BinNum
                BinArray = [1:BinNum];
                ERPTab_bin_chan.BinRange.Value=1;
            else
                ERPTab_bin_chan.BinRange.Value =BinArray+1;
            end
        end
        
        estudioworkingmemory('ERP_ChanArray',ChanArray);
        estudioworkingmemory('ERP_BinArray',BinArray);
        ERPTab_bin_chan.ElecRange.Enable = Enableflag;
        ERPTab_bin_chan.BinRange.Enable = Enableflag;
        ERPTab_bin_chan.plot_reset.Enable = Enableflag;
        ERPTab_bin_chan.plot_apply.Enable = Enableflag;
        observe_ERPDAT.Count_currentERP=3;
    end



    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        
        ChangeFlag =  estudioworkingmemory('ERPTab_chanbin');
        if ChangeFlag~=1
            return;
        end
        binchan_apply();
        estudioworkingmemory('ERPTab_chanbin',0);
        ERPTab_bin_chan.plot_apply.BackgroundColor =  [ 1 1 1];
        ERPTab_bin_chan.plot_apply.ForegroundColor = [0 0 0];
        EStudio_box_bin_chan.TitleColor= [ 0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        ERPTab_bin_chan.plot_reset.BackgroundColor =  [1 1 1];
        ERPTab_bin_chan.plot_reset.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function erp_binchan_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_chanbin');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            binchan_apply();
            estudioworkingmemory('ERPTab_chanbin',0);
            ERPTab_bin_chan.plot_apply.BackgroundColor =  [ 1 1 1];
            ERPTab_bin_chan.plot_apply.ForegroundColor = [0 0 0];
            EStudio_box_bin_chan.TitleColor= [ 0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
            ERPTab_bin_chan.plot_reset.BackgroundColor =  [1 1 1];
            ERPTab_bin_chan.plot_reset.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

end