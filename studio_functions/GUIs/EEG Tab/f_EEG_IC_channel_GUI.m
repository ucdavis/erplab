%%This function is used to get the ' Channel  and IC Selection' Panel and
%%record the change of th selected channels and selected ICs

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023


function varargout = f_EEG_IC_channel_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);
%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_EEG_IC_chan = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_eeg_box_ic_chan;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_eeg_box_ic_chan = uiextras.BoxPanel('Parent', fig, 'Title', ' Channel  and IC Selection', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_eeg_box_ic_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', ' Channel  and IC Selection', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_eeg_box_ic_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', ' Channel  and IC Selection', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_ic_chan_eeg(FonsizeDefault)
varargout{1} = EStudio_eeg_box_ic_chan;

    function drawui_ic_chan_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_eegtab_EEG_IC_chan.DataSelBox = uiextras.VBox('Parent', EStudio_eeg_box_ic_chan,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_IC_chan.DataSelGrid = uiextras.Grid('Parent', EStduio_eegtab_EEG_IC_chan.DataSelBox,'BackgroundColor',ColorB_def);
        % Second column:
        uicontrol('Style','text','Parent', EStduio_eegtab_EEG_IC_chan.DataSelGrid,'String','Channels','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1B
        try
            ALLEEGIN = evalin('base','ALLEEG');
            CURRENTSETIN = evalin('base','CURRENTSET');
        catch
            CURRENTSETIN = [];
            ALLEEGIN = [];
        end
        if isempty(ALLEEGIN) || isempty(CURRENTSETIN)
            Chanlist_name = 'No EEG is available';
            ICNamestrs = 'No IC is available';
            Enable = 'off';
            ChaNum = 1;
            EnableIC = 'off';
            ICNum = 1;
        else
            if CURRENTSETIN==0 ||  length(ALLEEGIN)<CURRENTSETIN
                CURRENTSETIN = length(ALLEEGIN);
                assignin('base','CURRENTSET',CURRENTSETIN);
            end
            ChaNum = length(ALLEEGIN(CURRENTSETIN).chanlocs);
            Chanlist = ALLEEGIN(CURRENTSETIN).chanlocs;
            Chanlist_name{1} = 'All';
            for Numofchan = 1:length(Chanlist)
                Chanlist_name{Numofchan+1,1} = char(strcat(num2str(Numofchan),'.',32,Chanlist(Numofchan).labels));
            end
            Enable = 'on';
            %             observe_EEGDAT.EEG_chan = 1:ChaNum;
            if ~isempty(ALLEEGIN(CURRENTSETIN).icachansind)
                ICNamestrs{1} = 'All';
                for ii = 1:numel(ALLEEGIN(CURRENTSETIN).icachansind)
                    ICNamestrs{ii+1,1} = char(strcat(num2str(ii),'.',32,'IC',32,num2str(ii)));
                end
                EnableIC = 'on';
                ICNum = numel(ALLEEGIN(CURRENTSETIN).icachansind);
            else
                ICNamestrs = 'No IC is available';
                EnableIC = 'off';
                ICNum = 1;
            end
        end
        EStduio_eegtab_EEG_IC_chan.ElecRange = uicontrol('Parent', EStduio_eegtab_EEG_IC_chan.DataSelGrid,'Style','listbox','min',1,'max',length(Chanlist_name)+1,...
            'String', Chanlist_name,'Callback',@onElecRange,'FontSize',FonsizeDefault,'Enable',Enable); % 2B
        EStduio_eegtab_EEG_IC_chan.ElecRange.KeyPressFcn=  @eeg_ichan_presskey;
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray) || length(ChanArray)> ChaNum
            ChanArray = [1:ChaNum];
            estudioworkingmemory('EEG_ChanArray',ChanArray);
        end
        if  length(ChanArray) == ChaNum
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value  =1;
        else
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value = ChanArray+1;
        end
        
        % Third column:
        uicontrol('Style','text','Parent', EStduio_eegtab_EEG_IC_chan.DataSelGrid,'String','ICs','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1C
        
        EStduio_eegtab_EEG_IC_chan.ICRange =  uicontrol('Parent', EStduio_eegtab_EEG_IC_chan.DataSelGrid,'Style','listbox','Min',1,'Max',length(ICNamestrs)+1,...
            'String', ICNamestrs,'callback',@onIChanged,'FontSize',FonsizeDefault,'Enable',EnableIC); % 2C
        EStduio_eegtab_EEG_IC_chan.ICRange.KeyPressFcn=  @eeg_ichan_presskey;
        ICArray =  estudioworkingmemory('EEG_ICArray');
        if isempty(ICArray) || length(ICArray)>ICNum
            ICArray = 1: ICNum;
            estudioworkingmemory('EEG_ICArray',ICArray);
        end
        if length(ICArray) == ICNum
            EStduio_eegtab_EEG_IC_chan.ICRange.Value  =1;
        else
            EStduio_eegtab_EEG_IC_chan.ICRange.Value = ICArray+1;
        end
        set(EStduio_eegtab_EEG_IC_chan.DataSelGrid, 'ColumnSizes',[ -1.2 -2],'RowSizes',[20 -3]);
        
        %%Cancel and Apply
        EStduio_eegtab_EEG_IC_chan.reset_apply = uiextras.HBox('Parent',EStduio_eegtab_EEG_IC_chan.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', EStduio_eegtab_EEG_IC_chan.reset_apply); % 1A
        EStduio_eegtab_EEG_IC_chan.plot_reset = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_IC_chan.reset_apply,...
            'String','Cancel','callback',@plot_eeg_cancel,'FontSize',FonsizeDefault,'Enable',Enable,'BackgroundColor',[1 1 1]);
        
        uiextras.Empty('Parent', EStduio_eegtab_EEG_IC_chan.reset_apply); % 1A
        EStduio_eegtab_EEG_IC_chan.plot_apply = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_IC_chan.reset_apply,...
            'String','Apply','callback',@plot_eeg_apply,'FontSize',FonsizeDefault,'Enable',Enable,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_IC_chan.plot_apply.KeyPressFcn=  @eeg_ichan_presskey;
        uiextras.Empty('Parent', EStduio_eegtab_EEG_IC_chan.reset_apply); % 1A
        set(EStduio_eegtab_EEG_IC_chan.reset_apply, 'Sizes',[10,-1,30,-1,10]);
        
        set(EStduio_eegtab_EEG_IC_chan.DataSelBox,'Sizes',[250 30]);
        
        estudioworkingmemory('EEGTab_chanic',0);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%----------------------------Get the changed channels----------------------*
    function onElecRange ( src, ~)
        if isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.count_current_eeg=2;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_chanic',1);
        EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [1 1 1];
        EStudio_eeg_box_ic_chan.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [1 1 1];
        new_chans = src.Value;
        if isempty(new_chans)
            beep;
            disp(['No channel was selected']);
            return;
        end
        [~,y_chan_index_select] = find(new_chans==1);
        if isempty(y_chan_index_select) && numel(new_chans) < numel(src.String)-1 %% 'All' is not slected
        else%% 'All' is selected and included or all channels are slected except 'ALL'
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value = 1;
        end
    end


%---------------------------get the changed bin----------------------------
    function onIChanged( src, ~ )
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_chanic',1);
        EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [1 1 1];
        EStudio_eeg_box_ic_chan.TitleColor= [  0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [1 1 1];
        
        IC_label_select = src.Value;
        if isempty(IC_label_select)
            beep;
            disp(['No IC was selected']);
            return;
        end
        [~,y_bin_index_select] = find(IC_label_select==1);
        if isempty(y_bin_index_select) && numel(IC_label_select) < numel(src.String)-1
        else% 'All' is selected  and inlcuded
            EStduio_eegtab_EEG_IC_chan.ICRange.Value = 1;
        end
        
    end

%%---------------------Cancel what have changed----------------------------
    function plot_eeg_cancel(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        ChangeFlag =  estudioworkingmemory('EEGTab_chanic');
        if ChangeFlag~=1
            return;
        end
        estudioworkingmemory('EEGTab_chanic',0);
        EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [0 0 0];
        EStudio_eeg_box_ic_chan.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [0 0 0];
        
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        ChaNum = length(EStduio_eegtab_EEG_IC_chan.ElecRange.String)-1;
        if isempty(ChanArray) ||  any(ChanArray(:)> ChaNum) || any(ChanArray(:)<=0)
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value = 1;
            ChanArray = [1:ChaNum];
        else
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value = ChanArray+1;
        end
        estudioworkingmemory('EEG_ChanArray',ChanArray);
        
        if ~isempty(observe_EEGDAT.EEG.icachansind)
            ICArray=  estudioworkingmemory('EEG_ICArray');
            ICNum = length(EStduio_eegtab_EEG_IC_chan.ICRange.String);
            if isempty(ICArray) ||  min(ICArray(:))>ICNum || max(ICArray(:))>ICNum || min(ICArray(:))<=0 || (numel(ICArray)==ICNum)
                EStduio_eegtab_EEG_IC_chan.ICRange.Value=1;
                ICArray = [1:ICNum];
            else
                EStduio_eegtab_EEG_IC_chan.ICRange.Value = ICArray+1;
            end
        else
            ICArray = [];
        end
        estudioworkingmemory('EEG_ICArray',ICArray);
    end

%%------------------Apply the changed parameters---------------------------
    function plot_eeg_apply(~,~)
        if isempty(observe_EEGDAT.EEG) %%if the current EEG is empty
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=1
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_chanic');
        if ChangeFlag~=1
            return;
        end
        MessageViewer= char(strcat('Channel and IC Selection > Apply'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_panel_message=1;
        
        
        new_chans= EStduio_eegtab_EEG_IC_chan.ElecRange.Value;
        [~,y_chan_index_select] = find(new_chans==1);
        ChanNum = length(EStduio_eegtab_EEG_IC_chan.ElecRange.String)-1;
        if isempty(y_chan_index_select) && numel(new_chans) <ChanNum %% 'All' is not slected
            ChanArray = new_chans-1;
        else%% 'All' is selected and included or all channels are slected except 'ALL'
            ChanArray = [1:ChanNum];
        end
        estudioworkingmemory('EEG_ChanArray',ChanArray);
        
        if ~isempty(observe_EEGDAT.EEG.icachansind)
            IC_label_select = EStduio_eegtab_EEG_IC_chan.ICRange.Value;
            ICNum = length(EStduio_eegtab_EEG_IC_chan.ICRange.String)-1;
            [~,y_bin_index_select] = find(IC_label_select==1);
            if isempty(y_bin_index_select) && numel(IC_label_select) < ICNum
                ICArray = IC_label_select-1;
            else% 'All' is selected  and inlcuded
                ICArray = [1:ICNum];
            end
        else
            ICArray = [];
        end
        estudioworkingmemory('EEG_ICArray',ICArray);
        
        estudioworkingmemory('EEGTab_chanic',0);
        EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [0 0 0];
        EStudio_eeg_box_ic_chan.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [0 0 0];
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_panel_message=2;
    end



%----------displayed channel label will be midified after channels was selected--------
    function EEG_chan_change(~,~)
        if observe_EEGDAT.eeg_panel_message==0
            return;
        end
        chanString = EStduio_eegtab_EEG_IC_chan.ElecRange.String;
        chanArray = estudioworkingmemory('EEG_ChanArray');
        if max(chanArray(:))> length(chanString)-1
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value =1;
            observe_EEGDAT.EEG_chan = [1:length(chanString)-1];
        else
            if max(chanArray(:))>length(chanString)-1
                EStduio_eegtab_EEG_IC_chan.ElecRange.Value =1;
                observe_EEGDAT.EEG_chan = [1:length(chanString)-1];
            else
                if numel(chanArray) == length(chanString)-1
                    EStduio_eegtab_EEG_IC_chan.ElecRange.Value =1;
                else
                    EStduio_eegtab_EEG_IC_chan.ElecRange.Value = chanArray+1;
                end
            end
        end
    end



%----------displayed bin label will be midified after different channels was selected--------
    function EEG_IC_change(~,~)
        if observe_EEGDAT.eeg_panel_message==0 ||  isempty(observe_EEGDAT.EEG_IC)
            return;
        end
        binArray =   estudioworkingmemory('EEG_ICArray');
        binString = EStduio_eegtab_EEG_IC_chan.ICRange.String;
        if isemoty(binArray)
            EStduio_eegtab_EEG_IC_chan.ICRange.Value =1;
            return;
        end
        if max(binArray)> length(binString)-1
            EStduio_eegtab_EEG_IC_chan.ICRange.Value =1;
            %             observe_EEGDAT.ERP_bin = [1:length(binString)-1];
        else
            if max(binArray)>length(binString)-1
                EStduio_eegtab_EEG_IC_chan.ICRange.Value =1;
                %                 observe_EEGDAT.ERP_bin = [1:length(binString)-1];
            else
                if numel(binArray) == length(binString)-1
                    EStduio_eegtab_EEG_IC_chan.ICRange.Value =1;
                else
                    EStduio_eegtab_EEG_IC_chan.ICRange.Value = binArray+1;
                end
            end
        end
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=2
            return;
        end
        
        ALLEEGIN = observe_EEGDAT.ALLEEG;
        CURRENTEEGIN= observe_EEGDAT.CURRENTSET;
        if (~isempty(ALLEEGIN) && CURRENTEEGIN~=0 && ~isempty(observe_EEGDAT.EEG)) || (isfield(observe_EEGDAT.EEG,'chanlocs') && ~isempty(observe_EEGDAT.EEG.chanlocs))
            %The channels and bins will be modified if the ERPset is changed
            ChannelValue =  EStduio_eegtab_EEG_IC_chan.ElecRange.Value-1;
            try
                Chanlist = observe_EEGDAT.EEG.chanlocs;
            catch
                Chanlist = [];
            end
            Chanlist_name{1} = 'All';
            if ~isempty(Chanlist)
                for Numofchan = 1:length(Chanlist)
                    Chanlist_name{Numofchan+1,1} = strcat(num2str(Numofchan),'.',32,char(Chanlist(Numofchan).labels));
                end
            else
                for Numofchan = 1:size( observe_EEGDAT.EEG.data,1)
                    Chanlist_name{Numofchan+1,1} = strcat(num2str(Numofchan),'. chan', num2str(Numofchan));
                end
            end
            EStduio_eegtab_EEG_IC_chan.ElecRange.String=Chanlist_name;
            EStduio_eegtab_EEG_IC_chan.ElecRange.Min = 1;
            EStduio_eegtab_EEG_IC_chan.ElecRange.Max = length(Chanlist_name)+1;
            if isempty(ChannelValue)|| any(ChannelValue(:)<=0) || any(ChannelValue(:) >length(Chanlist_name)-1) || numel(ChannelValue) == length(Chanlist_name)-1
                EStduio_eegtab_EEG_IC_chan.ElecRange.Value = 1;
                ChanArray = [1:length(Chanlist_name)-1];
            else
                EStduio_eegtab_EEG_IC_chan.ElecRange.Value =ChannelValue+1;
                ChanArray = ChannelValue;
            end
            EStduio_eegtab_EEG_IC_chan.ElecRange.Enable = 'on';
            EStduio_eegtab_EEG_IC_chan.plot_reset.Enable = 'on';
            EStduio_eegtab_EEG_IC_chan.plot_apply.Enable = 'on';
        else
            Chanlist_name = 'No EEG is available or  chanlocs is empty';
            EStduio_eegtab_EEG_IC_chan.ElecRange.String = Chanlist_name;
            EStduio_eegtab_EEG_IC_chan.ElecRange.Value=1;
            EStduio_eegtab_EEG_IC_chan.ElecRange.Enable = 'off';
            ChanArray = [];
            EStduio_eegtab_EEG_IC_chan.plot_reset.Enable = 'off';
            EStduio_eegtab_EEG_IC_chan.plot_apply.Enable = 'off';
        end
        
        %%Setting for display ICs
        if ~isempty(ALLEEGIN) && CURRENTEEGIN~=0 && ( ~isempty(observe_EEGDAT.EEG) && ~isempty(observe_EEGDAT.EEG.icachansind))
            ICNamestrs{1} = 'All';
            for ii = 1:numel(observe_EEGDAT.EEG.icachansind)
                ICNamestrs{ii+1,1} = char(strcat(num2str(ii),'.',32,'IC',32,num2str(ii)));
            end
            EStduio_eegtab_EEG_IC_chan.ICRange.String = ICNamestrs;
            ICValue = EStduio_eegtab_EEG_IC_chan.ICRange.Value-1;
            
            if isempty(ICValue) || any(ICValue(:)<=0)|| numel(ICValue) == numel(observe_EEGDAT.EEG.icachansind) || any(ICValue(:)>numel(observe_EEGDAT.EEG.icachansind))
                EStduio_eegtab_EEG_IC_chan.ICRange.Value =1;
                ICValue = [ 1:numel(observe_EEGDAT.EEG.icachansind)];
            else
                EStduio_eegtab_EEG_IC_chan.ICRange.Value =ICValue+1;
            end
            EStduio_eegtab_EEG_IC_chan.ICRange.Enable = 'on';
            EStduio_eegtab_EEG_IC_chan.ICRange.Min = 1;
            EStduio_eegtab_EEG_IC_chan.ICRange.Max = numel(observe_EEGDAT.EEG.icachansind)+1;
        else
            %%ICs
            ICNamestrs = 'No IC is available';
            EStduio_eegtab_EEG_IC_chan.ICRange.String = ICNamestrs;
            EStduio_eegtab_EEG_IC_chan.ICRange.Value = 1;
            EStduio_eegtab_EEG_IC_chan.ICRange.Enable = 'off';
            ICValue = [];
        end
        estudioworkingmemory('EEG_ICArray',ICValue);
        estudioworkingmemory('EEG_ChanArray',ChanArray);
        observe_EEGDAT.count_current_eeg=3;
    end


%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_two_panels_change(~,~)
        if observe_EEGDAT.eeg_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_chanic');
        if ChangeFlag~=1
            return;
        end
        plot_eeg_apply();
        estudioworkingmemory('EEGTab_chanic',0);
        EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [0 0 0];
        EStudio_eeg_box_ic_chan.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_ichan_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_chanic');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            plot_eeg_apply();
            estudioworkingmemory('EEGTab_chanic',0);
            EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [1 1 1];
            EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [0 0 0];
            EStudio_eeg_box_ic_chan.TitleColor= [0.0500    0.2500    0.5000];
            EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [1 1 1];
            EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=2
            return;
        end
        %%------------------------------channel----------------------------
        Chanlist_name =  EStduio_eegtab_EEG_IC_chan.ElecRange.String;
        if length(Chanlist_name)==1
            ChanArray = [];
        else
            ChanArray = [1:length(Chanlist_name)-1];
        end
        EStduio_eegtab_EEG_IC_chan.ElecRange.Value=1;
        
        %%-------------------------------ICs-------------------------------
        ICNamestrs = EStduio_eegtab_EEG_IC_chan.ICRange.String;
        if length(ICNamestrs)==1
            ICValue=[];
        else
            ICValue = [1:length(ICNamestrs)-1];
        end
        EStduio_eegtab_EEG_IC_chan.ICRange.Value=1;
        
        estudioworkingmemory('EEG_ICArray',ICValue);
        estudioworkingmemory('EEG_ChanArray',ChanArray);
        estudioworkingmemory('EEGTab_chanic',0);
        EStduio_eegtab_EEG_IC_chan.plot_apply.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_apply.ForegroundColor = [0 0 0];
        %         EStudio_eeg_box_ic_chan.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_IC_chan.plot_reset.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_IC_chan.plot_reset.ForegroundColor = [0 0 0];
        observe_EEGDAT.Reset_eeg_paras_panel=3;
    end

end