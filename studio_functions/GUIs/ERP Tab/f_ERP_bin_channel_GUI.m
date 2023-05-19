%%This function is used to get the 'Bin and Channel Selection' Panel and record the change of th selected channels and selected bins

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_bin_channel_GUI(varargin)

global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@allErpChanged);
addlistener(observe_ERPDAT,'ERP_chan_change',@ERP_chan_changed);
addlistener(observe_ERPDAT,'ERP_bin_change',@ERP_bin_changed);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);

%---------------------------Initialize parameters------------------------------------
try
    SelectedIndex = observe_ERPDAT.CURRENTERP;
catch
    disp('f_ERP_bin_channel_GUI error: No CURRENTERP is on Matlab Workspace');
    return;
end
% end
if SelectedIndex ==0
    
    disp('f_ERP_bin_channel_GUI error: No ERPset is imported');
    return;
end
if SelectedIndex>length(observe_ERPDAT.ALLERP)
    SelectedIndex =1;
end

S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedIndex);
estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);

EStduio_gui_erp_bin_chan = struct();

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


observe_ERPDAT.ERP_chan = S_erpbinchan.geterpbinchan.elecs_shown{1};
observe_ERPDAT.ERP_bin = S_erpbinchan.geterpbinchan.bins{1};
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
        EStduio_gui_erp_bin_chan.DataSelBox = uiextras.VBox('Parent', EStudio_box_bin_chan,'BackgroundColor',ColorB_def);
        EStduio_gui_erp_bin_chan.DataSelGrid = uiextras.Grid('Parent', EStduio_gui_erp_bin_chan.DataSelBox,'BackgroundColor',ColorB_def);
        
        
        % Second column:
        uicontrol('Style','text','Parent', EStduio_gui_erp_bin_chan.DataSelGrid,'String','Channels','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1B
        Chanlist = observe_ERPDAT.ERP.chanlocs;
        Chanlist_name{1} = 'All';
        for Numofchan = 1:length(Chanlist)
            Chanlist_name{Numofchan+1} = char(strcat(num2str(Numofchan),'.',32,Chanlist(Numofchan).labels));
        end
        EStduio_gui_erp_bin_chan.ElecRange = uicontrol('Parent', EStduio_gui_erp_bin_chan.DataSelGrid,'Style','listbox','min',1,'max',length(Chanlist_name),...
            'String', Chanlist_name,'Callback',@onElecRange,'FontSize',FonsizeDefault,'Enable','on'); % 2B
        
        if  S_erpbinchan.geterpbinchan.checked_curr_index ==1 || S_erpbinchan.geterpbinchan.checked_ERPset_Index(2) ==2
            EStduio_gui_erp_bin_chan.ElecRange.Enable = 'off';
        end
        
        if  numel(S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index}) == numel(Chanlist)
            EStduio_gui_erp_bin_chan.ElecRange.Value  =1;
        else
            EStduio_gui_erp_bin_chan.ElecRange.Value = S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index}+1;
        end
        
        
        % Third column:
        uicontrol('Style','text','Parent', EStduio_gui_erp_bin_chan.DataSelGrid,'String','Bins','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 1C
        
        BinNum = observe_ERPDAT.ERP.nbin;
        BinName = observe_ERPDAT.ERP.bindescr;
        brange = cell(BinNum+1,1);
        brange(1) = {'ALL'};
        for i = 1:BinNum
            brange(i+1) = {strcat(num2str(i),'.',32,BinName{i})};
        end
        EStduio_gui_erp_bin_chan.BinRange =  uicontrol('Parent', EStduio_gui_erp_bin_chan.DataSelGrid,'Style','listbox','Min',1,'Max',BinNum+1,...
            'String', brange,'callback',@onBinChanged,'FontSize',FonsizeDefault); % 2C
        if BinNum== numel(S_erpbinchan.geterpbinchan.bins{1})
            EStduio_gui_erp_bin_chan.BinRange.Value  =1;
        else
            EStduio_gui_erp_bin_chan.BinRange.Value = S_erpbinchan.geterpbinchan.bins{1}+1;
        end
        if  S_erpbinchan.geterpbinchan.checked_curr_index ==1 || S_erpbinchan.geterpbinchan.checked_ERPset_Index(1) ==1
            EStduio_gui_erp_bin_chan.BinRange.Enable = 'off';
        end
        
        set(EStduio_gui_erp_bin_chan.DataSelGrid, 'ColumnSizes',[ -1.2 -2],'RowSizes',[20 -3]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%----------------------------Get the changed channels----------------------*
    function onElecRange ( src, ~)
        erpworkingmemory('f_ERP_proces_messg','Bin and Channel Selection-select channel(s)');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP_Index= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP_Index)
            SelectedERP_Index = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP_Index)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
            S_erpbinchan.geterpbinchan = S_erpplot.geterpbinchan;
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        S_erpbinchan.geterpbinchan= estudioworkingmemory('geterpbinchan');
        if isempty(S_erpbinchan.geterpbinchan)
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
            S_erpbinchan.geterpbinchan = S_erpplot.geterpbinchan;
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        new_chans = src.Value;
        if isempty(new_chans)
            beep;
            disp(['No channel was selected']);
            return;
        end
        [~,y_chan_index_select] = find(new_chans==1);
        if isempty(y_chan_index_select) && numel(new_chans) < numel(src.String)-1 %% 'All' is not slected
            
            if S_erpbinchan.geterpbinchan.checked_ERPset_Index(2) ==2%% the number of channels varied across ERPsets
                S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index} = new_chans-1;
                S_erpbinchan.geterpbinchan.elec_n(S_erpbinchan.geterpbinchan.Select_index) = numel(new_chans);
                S_erpbinchan.geterpbinchan.first_elec(S_erpbinchan.geterpbinchan.Select_index) = new_chans(1)-1;
            else
                for Numofselecterp = 1:numel(SelectedERP_Index)
                    S_erpbinchan.geterpbinchan.elecs_shown{Numofselecterp} = new_chans-1;
                    S_erpbinchan.geterpbinchan.elec_n(Numofselecterp) = numel(new_chans);
                    S_erpbinchan.geterpbinchan.first_elec(Numofselecterp) = new_chans(1)-1;
                end
            end
            EStduio_gui_erp_bin_chan.ElecRange.Value = new_chans;
        else%% 'All' is selected and included or all channels are slected except 'ALL'
            carray = src.String;
            carray(1) = [];
            if S_erpbinchan.geterpbinchan.checked_ERPset_Index(2) ==2
                S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index} = [1:numel(carray)];
                S_erpbinchan.geterpbinchan.elec_n(S_erpbinchan.geterpbinchan.Select_index) = numel(carray);
                S_erpbinchan.geterpbinchan.first_elec(S_erpbinchan.geterpbinchan.Select_index) = 1;
            else
                
                for Numofselecterp = 1:numel(SelectedERP_Index)
                    S_erpbinchan.geterpbinchan.elecs_shown{Numofselecterp} = [1:numel(carray)];
                    S_erpbinchan.geterpbinchan.elec_n(Numofselecterp) = numel(carray);
                    S_erpbinchan.geterpbinchan.first_elec(Numofselecterp) = 1;
                end
                
            end
            
            EStduio_gui_erp_bin_chan.ElecRange.Value = 1;
        end
        estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
        observe_ERPDAT.ERP_chan = S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index};
        observe_ERPDAT.Process_messg =2;
        %%Plot waves
        try
            try
                S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
                S_ws_viewer = S_ws_geterpvalues.Viewer;
            catch
                S_ws_viewer = 'off';
            end
            
            if strcmp(S_ws_viewer,'on')
                f_redrawERP_mt_viewer();
            else
                f_redrawERP();
            end
            
        catch
            f_redrawERP();
        end
        %         observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end




%---------------------------get the changed bin----------------------------
    function onBinChanged( src, ~ )
        erpworkingmemory('f_ERP_proces_messg','Bin and Channel Selection-select bin(s)');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP_Index= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP_Index)
            SelectedERP_Index = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP_Index)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
            S_erpbinchan.geterpbinchan = S_erpplot.geterpbinchan;
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        
        S_erpbinchan.geterpbinchan= estudioworkingmemory('geterpbinchan');
        if isempty(S_erpbinchan.geterpbinchan)
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP_Index);
            S_erpbinchan.geterpbinchan = S_erpplot.geterpbinchan;
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        
        Bin_label_select = src.Value;
        if isempty(Bin_label_select)
            beep;
            disp(['No bin was selected']);
            return;
        end
        
        [~,y_bin_index_select] = find(Bin_label_select==1);
        if isempty(y_bin_index_select) && numel(Bin_label_select) < numel(src.String)-1
            if S_erpbinchan.geterpbinchan.checked_ERPset_Index(1) ==1% The number of bins varied across the selected erpsets
                S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index} = Bin_label_select-1;
                S_erpbinchan.geterpbinchan.bin_n(S_erpbinchan.geterpbinchan.Select_index) = numel(Bin_label_select);
            else
                for Numofselecterp = 1:numel(SelectedERP_Index)
                    S_erpbinchan.geterpbinchan.bins{Numofselecterp} = Bin_label_select-1;
                    S_erpbinchan.geterpbinchan.bin_n(Numofselecterp) = numel(Bin_label_select);
                end
            end
            EStduio_gui_erp_bin_chan.BinRange.Value = Bin_label_select;
            
        else% 'All' is selected  and inlcuded
            carray = src.String;
            carray(1) = [];
            if S_erpbinchan.geterpbinchan.checked_ERPset_Index(1) ==1% The number of bins varied across the selected erpsets
                S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index} = [1:numel(carray)];
                S_erpbinchan.geterpbinchan.bin_n(S_erpbinchan.geterpbinchan.Select_index) = numel(carray);
            else
                for Numofselecterp = 1:numel(SelectedERP_Index)
                    S_erpbinchan.geterpbinchan.bins{Numofselecterp} = [1:numel(carray)];
                    S_erpbinchan.geterpbinchan.bin_n(Numofselecterp) = numel(carray);
                end
            end
            EStduio_gui_erp_bin_chan.BinRange.Value = 1;
        end
        estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
        observe_ERPDAT.ERP_bin = S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index};
        observe_ERPDAT.Process_messg =2;
        %%Plot waves
        try
            try
                S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
                S_ws_viewer = S_ws_geterpvalues.Viewer;
            catch
                S_ws_viewer = 'off';
            end
            
            if strcmp(S_ws_viewer,'on')
                f_redrawERP_mt_viewer();
            else
                f_redrawERP();
            end
            
        catch
            f_redrawERP();
        end
        %         observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%----------displayed channel label will be midified after channels was selected--------
    function ERP_chan_changed(~,~)
        if observe_ERPDAT.Process_messg==0
           return; 
        end
        chanString = EStduio_gui_erp_bin_chan.ElecRange.String;
        chanArray = observe_ERPDAT.ERP_chan;
        if max(chanArray)> length(chanString)-1
            EStduio_gui_erp_bin_chan.ElecRange.Value =1;
            observe_ERPDAT.ERP_chan = [1:length(chanString)-1];
        else
            if max(chanArray)>length(chanString)-1
                EStduio_gui_erp_bin_chan.ElecRange.Value =1;
                observe_ERPDAT.ERP_chan = [1:length(chanString)-1];
            else
                if numel(chanArray) == length(chanString)-1
                    EStduio_gui_erp_bin_chan.ElecRange.Value =1;
                else
                    EStduio_gui_erp_bin_chan.ElecRange.Value = chanArray+1;
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
        binString = EStduio_gui_erp_bin_chan.BinRange.String;
        
        if max(binArray)> length(binString)-1
            EStduio_gui_erp_bin_chan.BinRange.Value =1;
            observe_ERPDAT.ERP_bin = [1:length(binString)-1];
        else
            if max(binArray)>length(binString)-1
                EStduio_gui_erp_bin_chan.BinRange.Value =1;
                observe_ERPDAT.ERP_bin = [1:length(binString)-1];
            else
                if numel(binArray) == length(binString)-1
                    EStduio_gui_erp_bin_chan.BinRange.Value =1;
                else
                    EStduio_gui_erp_bin_chan.BinRange.Value = binArray+1;
                end
            end
        end
    end


%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        try
            ERPloadIndex = estudioworkingmemory('ERPloadIndex');
        catch
            ERPloadIndex =0;
        end
        if ERPloadIndex==1
            ALLERPIN = evalin('base','ALLERP');
            CURRENTERPIN = evalin('base','CURRENTERP');
            observe_ERPDAT.ALLERP = ALLERPIN;
            observe_ERPDAT.CURRENTERP =CURRENTERPIN;
            try
                observe_ERPDAT.ERP = ALLERPIN(CURRENTERPIN);
            catch
                observe_ERPDAT.ERP = ALLERPIN(end);
                observe_ERPDAT.CURRENTERP =length(ALLERPIN);
            end
        end
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = observe_ERPDAT.CURRENTERP;
            if isempty(Selectederp_Index)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            S_erpbinchan.geterpbinchan = S_erpplot.geterpbinchan;
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        
        S_erpbinchan.geterpbinchan= estudioworkingmemory('geterpbinchan');
        if isempty(S_erpbinchan.geterpbinchan)
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selectederp_Index);
            S_erpbinchan.geterpbinchan = S_erpplot.geterpbinchan;
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        if max(Selectederp_Index(:)) > length(observe_ERPDAT.ALLERP)
            beep;
            disp(['Max. index of selected ERPsets is greater than the length of ALLERP!!!']);
            return;
        end
        
        %The channels and bins will be modified if the ERPset is changed
        Chanlist = observe_ERPDAT.ERP.chanlocs;
        Chanlist_name{1} = 'All';
        for Numofchan = 1:length(Chanlist)
            Chanlist_name{Numofchan+1} = strcat(num2str(Numofchan),'.',32,char(Chanlist(Numofchan).labels));
        end
        EStduio_gui_erp_bin_chan.ElecRange.String=Chanlist_name;
        
        try
            checked_ERPset_Index_bin_chan = S_erpbinchan.geterpbinchan.checked_ERPset_Index;
        catch
            checked_ERPset_Index_bin_chan = f_checkerpsets(observe_ERPDAT.ALLERP,Selectederp_Index);
        end
        if  strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded') || checked_ERPset_Index_bin_chan(2) ==2
            EStduio_gui_erp_bin_chan.ElecRange.Enable = 'off';
        else
            EStduio_gui_erp_bin_chan.ElecRange.Enable = 'on';
        end
        
        EStduio_gui_erp_bin_chan.ElecRange.Min = 1;
        EStduio_gui_erp_bin_chan.ElecRange.Max = length(Chanlist_name)+1;
        
        chanArray_pv =  EStduio_gui_erp_bin_chan.ElecRange.Value;
        if numel(chanArray_pv)==1 && chanArray_pv ==1
            EStduio_gui_erp_bin_chan.ElecRange.Value  =1;
            S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index} = 1:(length(Chanlist_name)-1);
        else
            if max(chanArray_pv-1)<= (length(Chanlist_name)-1)
                S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index}= chanArray_pv-1;
            else
                S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index} = 1:(length(Chanlist_name)-1);
            end
        end
        
        if  numel(S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index}) == numel(Chanlist)
            EStduio_gui_erp_bin_chan.ElecRange.Value  =1;
            observe_ERPDAT.ERP_chan = [1:numel(Chanlist)];
        else
            EStduio_gui_erp_bin_chan.ElecRange.Value = S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index}+1;
            observe_ERPDAT.ERP_chan= S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index};
        end
        
        ChanShow = S_erpbinchan.geterpbinchan.elecs_shown{S_erpbinchan.geterpbinchan.Select_index};
        S_erpbinchan.geterpbinchan.elec_n(S_erpbinchan.geterpbinchan.Select_index) = numel(ChanShow);
        S_erpbinchan.geterpbinchan.first_elec(S_erpbinchan.geterpbinchan.Select_index) = ChanShow(1);
        
        estudioworkingmemory('ChanShow',ChanShow);
        
        %%Setting for display bins
        BinNum = observe_ERPDAT.ERP.nbin;
        BinName = observe_ERPDAT.ERP.bindescr;
        brange = cell(BinNum+1,1);
        brange(1) = {'ALL'};
        for i = 1:BinNum
            brange(i+1) = {strcat(num2str(i),'.',32,BinName{i})};
        end
        EStduio_gui_erp_bin_chan.BinRange.String=brange;
        binArray_pv =  EStduio_gui_erp_bin_chan.BinRange.Value;
        if numel(binArray_pv)==1 && binArray_pv ==1
            EStduio_gui_erp_bin_chan.BinRange.Value  =1;
            S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index} = 1:BinNum;
        else
            if max(binArray_pv-1)<= BinNum
                S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index}= binArray_pv-1;
            else
                S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index} = 1:BinNum;
            end
        end
        
        if numel(S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index}) == BinNum
            EStduio_gui_erp_bin_chan.BinRange.Value =1;
        else
            EStduio_gui_erp_bin_chan.BinRange.Value =S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index};
        end
        if  strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded') || checked_ERPset_Index_bin_chan(1) ==1
            EStduio_gui_erp_bin_chan.BinRange.Enable = 'off';
        else
            EStduio_gui_erp_bin_chan.BinRange.Enable = 'on';
        end
        EStduio_gui_erp_bin_chan.BinRange.Min = 1;
        EStduio_gui_erp_bin_chan.BinRange.Max = length(brange)+1;
        
        if  numel(S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index}) == BinNum
            EStduio_gui_erp_bin_chan.BinRange.Value  =1;
            observe_ERPDAT.ERP_bin = [1:BinNum];
        else
            EStduio_gui_erp_bin_chan.BinRange.Value = S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index}+1;
            observe_ERPDAT.ERP_bin = S_erpbinchan.geterpbinchan.bins{S_erpbinchan.geterpbinchan.Select_index};
        end
        estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
        
    end

end