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
% addlistener(observe_EEGDAT,'ALLERP_change',@allErpChanged);
addlistener(observe_EEGDAT,'EEG_chan_change',@EEG_chan_change);
addlistener(observe_EEGDAT,'EEG_IC_change',@EEG_IC_change);
% addlistener(observe_EEGDAT,'CURRENTEEG_change',@cerpchange);
addlistener(observe_EEGDAT,'Count_currentEEG_change',@Count_currentEEG_change);

%---------------------------Initialize parameters------------------------------------

EStduio_gui_EEG_IC_chan = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_bin_chan;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_bin_chan = uiextras.BoxPanel('Parent', fig, 'Title', ' Channel  and IC Selection', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_bin_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', ' Channel  and IC Selection', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_bin_chan = uiextras.BoxPanel('Parent', varargin{1}, 'Title', ' Channel  and IC Selection', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        EStduio_gui_EEG_IC_chan.DataSelBox = uiextras.VBox('Parent', EStudio_box_bin_chan,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_IC_chan.DataSelGrid = uiextras.Grid('Parent', EStduio_gui_EEG_IC_chan.DataSelBox,'BackgroundColor',ColorB_def);
        % Second column:
        uicontrol('Style','text','Parent', EStduio_gui_EEG_IC_chan.DataSelGrid,'String','Channels','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1B
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
            observe_EEGDAT.EEG_IC = [];
            observe_EEGDAT.EEG_chan = [];
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
            observe_EEGDAT.EEG_chan = 1:ChaNum;
            if ~isempty(ALLEEGIN(CURRENTSETIN).icachansind)
                ICNamestrs{1} = 'All';
                for ii = 1:numel(ALLEEGIN(CURRENTSETIN).icachansind)
                    ICNamestrs{ii+1,1} = char(strcat(num2str(ii),'.',32,'IC',32,num2str(ii)));
                end
                EnableIC = 'on';
                ICNum = numel(ALLEEGIN(CURRENTSETIN).icachansind);
                observe_EEGDAT.EEG_IC = 1:ICNum;
            else
                ICNamestrs = 'No IC is available';
                EnableIC = 'off';
                ICNum = 1;
                observe_EEGDAT.EEG_IC = [];
            end
            
        end
        EStduio_gui_EEG_IC_chan.ElecRange = uicontrol('Parent', EStduio_gui_EEG_IC_chan.DataSelGrid,'Style','listbox','min',1,'max',length(Chanlist_name)+1,...
            'String', Chanlist_name,'Callback',@onElecRange,'FontSize',FonsizeDefault,'Enable',Enable); % 2B
        ChanArray =  estudioworkingmemory('EEG_ChanArray');
        if isempty(ChanArray) || length(ChanArray)> ChaNum
            ChanArray = [1:ChaNum];
            estudioworkingmemory('EEG_ChanArray',ChanArray);
        end
        if  length(ChanArray) == ChaNum
            EStduio_gui_EEG_IC_chan.ElecRange.Value  =1;
        else
            EStduio_gui_EEG_IC_chan.ElecRange.Value = ChanArray+1;
        end
        
        % Third column:
        uicontrol('Style','text','Parent', EStduio_gui_EEG_IC_chan.DataSelGrid,'String','ICs','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1C
        
        EStduio_gui_EEG_IC_chan.ICRange =  uicontrol('Parent', EStduio_gui_EEG_IC_chan.DataSelGrid,'Style','listbox','Min',1,'Max',length(ICNamestrs)+1,...
            'String', ICNamestrs,'callback',@onIChanged,'FontSize',FonsizeDefault,'Enable',EnableIC); % 2C
        ICArray =  estudioworkingmemory('EEG_ICArray');
        if isempty(ICArray) || length(ICArray)>ICNum
            ICArray = 1: ICNum;
            estudioworkingmemory('EEG_ICArray',ICArray);
        end
        if length(ICArray) == ICNum
            EStduio_gui_EEG_IC_chan.ICRange.Value  =1;
        else
            EStduio_gui_EEG_IC_chan.ICRange.Value = ICArray+1;
        end
        set(EStduio_gui_EEG_IC_chan.DataSelGrid, 'ColumnSizes',[ -1.2 -2],'RowSizes',[20 -3]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%----------------------------Get the changed channels----------------------*
    function onElecRange ( src, ~)
        erpworkingmemory('f_ERP_proces_messg',' Channel  and IC Selection-select channel(s)');
        observe_EEGDAT.Process_messg_EEG =1;
        
        new_chans = src.Value;
        if isempty(new_chans)
            beep;
            disp(['No channel was selected']);
            return;
        end
        [~,y_chan_index_select] = find(new_chans==1);
        if isempty(y_chan_index_select) && numel(new_chans) < numel(src.String)-1 %% 'All' is not slected
            ChanArray = new_chans;
        else%% 'All' is selected and included or all channels are slected except 'ALL'
            EStduio_gui_EEG_IC_chan.ElecRange.Value = 1;
            ChanArray = [1:length(src.String)-1];
        end
        estudioworkingmemory('EEG_ChanArray',ChanArray);
        observe_EEGDAT.ERP_chan = ChanArray;
        observe_EEGDAT.Process_messg_EEG =2;
        %%Plot waves
        %         try
        %             if strcmp(S_ws_viewer,'on')
        %                 f_redrawERP_mt_viewer();
        %             else
        %                 f_redrawERP();
        %             end
        %
        %         catch
        %             f_redrawERP();
        %         end
        %         %         observe_EEGDAT.Count_CURRENTEEG = observe_EEGDAT.Count_CURRENTEEG+1;
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end




%---------------------------get the changed bin----------------------------
    function onIChanged( src, ~ )
        erpworkingmemory('f_ERP_proces_messg',' Channel  and IC Selection-select bin(s)');
        observe_EEGDAT.Process_messg_EEG =1;
        
        IC_label_select = src.Value;
        if isempty(IC_label_select)
            beep;
            disp(['No IC was selected']);
            return;
        end
        
        [~,y_bin_index_select] = find(IC_label_select==1);
        if isempty(y_bin_index_select) && numel(IC_label_select) < numel(src.String)-1
            ICArray = IC_label_select;
        else% 'All' is selected  and inlcuded
            EStduio_gui_EEG_IC_chan.ICRange.Value = 1;
            ICArray = [1:length(src.String)-1];
        end
        estudioworkingmemory('EEG_ICArray',ICArray);
        observe_EEGDAT.EEG_IC = ICArray;
        observe_EEGDAT.Process_messg_EEG =2;
        %%Plot waves
        %         try
        %             if strcmp(S_ws_viewer,'on')
        %                 f_redrawERP_mt_viewer();
        %             else
        %                 f_redrawERP();
        %             end
        %
        %         catch
        %             f_redrawERP();
        %         end
        %         observe_EEGDAT.Count_CURRENTEEG = observe_EEGDAT.Count_CURRENTEEG+1;
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end


%----------displayed channel label will be midified after channels was selected--------
    function EEG_chan_change(~,~)
        if observe_EEGDAT.Process_messg_EEG==0
            return;
        end
        chanString = EStduio_gui_EEG_IC_chan.ElecRange.String;
        chanArray = observe_EEGDAT.ERP_chan;
        if max(chanArray)> length(chanString)-1
            EStduio_gui_EEG_IC_chan.ElecRange.Value =1;
            observe_EEGDAT.ERP_chan = [1:length(chanString)-1];
        else
            if max(chanArray)>length(chanString)-1
                EStduio_gui_EEG_IC_chan.ElecRange.Value =1;
                observe_EEGDAT.EEG_chan = [1:length(chanString)-1];
            else
                if numel(chanArray) == length(chanString)-1
                    EStduio_gui_EEG_IC_chan.ElecRange.Value =1;
                else
                    EStduio_gui_EEG_IC_chan.ElecRange.Value = chanArray+1;
                end
            end
        end
    end



%----------displayed bin label will be midified after different channels was selected--------
    function EEG_IC_change(~,~)
        if observe_EEGDAT.Process_messg_EEG==0 ||  isempty(observe_EEGDAT.EEG_IC)
            return;
        end
        binArray =  observe_EEGDAT.EEG_IC;
        binString = EStduio_gui_EEG_IC_chan.ICRange.String;
        
        if max(binArray)> length(binString)-1
            EStduio_gui_EEG_IC_chan.ICRange.Value =1;
            observe_EEGDAT.ERP_bin = [1:length(binString)-1];
        else
            if max(binArray)>length(binString)-1
                EStduio_gui_EEG_IC_chan.ICRange.Value =1;
                observe_EEGDAT.ERP_bin = [1:length(binString)-1];
            else
                if numel(binArray) == length(binString)-1
                    EStduio_gui_EEG_IC_chan.ICRange.Value =1;
                else
                    EStduio_gui_EEG_IC_chan.ICRange.Value = binArray+1;
                end
            end
        end
    end


%%--------Settting will be modified if the selected was changed------------
    function Count_currentEEG_change(~,~)
        try
            ERPloadIndex = estudioworkingmemory('ERPloadIndex');
        catch
            ERPloadIndex =0;
        end
        if ERPloadIndex==1
            ALLEEGIN = evalin('base','ALLEEG');
            CURRENTEEGIN = evalin('base','CURRENTSET');
            observe_EEGDAT.ALLEEG = ALLEEGIN;
            observe_EEGDAT.CURRENTSET =CURRENTEEGIN;
            if isempty(ALLEEGIN)
                observe_EEGDAT.EEG = [];
            else
                try
                    observe_EEGDAT.EEG = ALLEEGIN(CURRENTEEGIN);
                catch
                    observe_EEGDAT.EEG = ALLEEGIN(end);
                    observe_EEGDAT.CURRENTSET =length(ALLEEGIN);
                    assignin('base','CURRENTSET',length(ALLEEGIN));
                end
            end
        end
        if ~isempty(ALLEEGIN) && CURRENTEEGIN~=0 && ~isempty(observe_EEGDAT.EEG)
            %The channels and bins will be modified if the ERPset is changed
            ChannelValue =  EStduio_gui_EEG_IC_chan.ElecRange.Value-1;
            Chanlist = observe_EEGDAT.EEG.chanlocs;
            Chanlist_name{1} = 'All';
            for Numofchan = 1:length(Chanlist)
                Chanlist_name{Numofchan+1,1} = strcat(num2str(Numofchan),'.',32,char(Chanlist(Numofchan).labels));
            end
            EStduio_gui_EEG_IC_chan.ElecRange.String=Chanlist_name;
            EStduio_gui_EEG_IC_chan.ElecRange.Min = 1;
            EStduio_gui_EEG_IC_chan.ElecRange.Max = length(Chanlist_name)+1;
            if min(ChannelValue(:)) >length(Chanlist_name) || max(ChannelValue(:))> length(Chanlist_name) || numel(ChannelValue) == length(Chanlist_name)
                EStduio_gui_EEG_IC_chan.ElecRange.Value = 1;
                observe_EEGDAT.EEG_chan = [1:length(Chanlist_name)];
            else
                EStduio_gui_EEG_IC_chan.ElecRange.Value =ChannelValue+1;
                observe_EEGDAT.EEG_chan = ChannelValue;
            end
            EStduio_gui_EEG_IC_chan.ElecRange.Enabel = 'on';
        else
            Chanlist_name = 'No EEG is available';
            observe_EEGDAT.EEG_chan = [];
            EStduio_gui_EEG_IC_chan.ElecRange.String = Chanlist_name;
            EStduio_gui_EEG_IC_chan.ElecRange.Value=1;
            EStduio_gui_EEG_IC_chan.ElecRange.Enabel = 'off';
        end
        
        
        %%Setting for display ICs
        if ~isempty(ALLEEGIN) && CURRENTEEGIN~=0 && ( ~isempty(observe_EEGDAT.EEG) && ~isempty(observe_EEGDAT.EEG.icachansind))
            ICNamestrs{1} = 'All';
            for ii = 1:numel(observe_EEGDAT.EEG.icachansind)
                ICNamestrs{ii+1,1} = char(strcat(num2str(ii),'.',32,'IC',32,num2str(ii)));
            end
            EStduio_gui_EEG_IC_chan.ICRange.String = ICNamestrs;
            ICValue = EStduio_gui_EEG_IC_chan.ICRange.Value;
            
            if numel(ICValue) == numel(observe_EEGDAT.EEG.icachansind) || min(ICValue(:))>numel(observe_EEGDAT.EEG.icachansind) ||  max(ICValue(:))>numel(observe_EEGDAT.EEG.icachansind)
                EStduio_gui_EEG_IC_chan.ICRange.Value =1;
                ICValue = [ 1:numel(observe_EEGDAT.EEG.icachansind)];
            else
                EStduio_gui_EEG_IC_chan.ICRange.Value =ICValue;
            end
            observe_EEGDAT.EEG_IC = ICValue;
            EStduio_gui_EEG_IC_chan.ICRange.Enable = 'on';
            EStduio_gui_EEG_IC_chan.ICRange.Min = 1;
            EStduio_gui_EEG_IC_chan.ICRange.Max = numel(observe_EEGDAT.EEG.icachansind)+1;
        else
            ICNamestrs = 'No IC is available';
            EStduio_gui_EEG_IC_chan.ICRange.String = ICNamestrs;
            EStduio_gui_EEG_IC_chan.ICRange.Value = 1;
            EStduio_gui_EEG_IC_chan.ICRange.Enable = 'off';
            observe_EEGDAT.EEG_IC = [];
            ICValue = [];
        end
        estudioworkingmemory('EEG_ICArray',ICValue);
        
    end

end