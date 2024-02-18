
%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022  && Nov. 2023



function varargout = f_erp_informtion_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    Erp_information = uiextras.BoxPanel('Parent', fig, 'Title', 'ERP & Bin Information', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP & Bin Information', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP & Bin Information', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

varargout{1} = Erp_information;
gui_erp_information = struct;
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_erp_information(FonsizeDefault);


    function drawui_erp_information(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        gui_erp_information.DataSelBox = uiextras.VBox('Parent', Erp_information, 'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%----------------------------Setting sampling rate---------------------
        gui_erp_information.samplingrate = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.samplingrate_title = uicontrol('Style','text','Parent', gui_erp_information.samplingrate,'String','Sampling:','FontSize',FonsizeDefault);
        
        ERP_time_resolution = strcat(32,num2str(0),32,'ms (time resolution);',32,num2str(''),32,'Hz (rate)','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_information.samplingrate_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        gui_erp_information.samplingrate_resolution = uicontrol('Style','text','Parent', gui_erp_information.samplingrate,'String',ERP_time_resolution,'FontSize',FonsizeDefault);
        set(gui_erp_information.samplingrate_resolution,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.samplingrate ,'Sizes',[70 430]);
        
        %%----------------------------Setting epoch---------------------
        gui_erp_information.epoch = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.epoch_title = uicontrol('Style','text','Parent', gui_erp_information.epoch,'String','Epoch:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_information.epoch_title,'HorizontalAlignment','left');
        gui_erp_information.epoch_name = uicontrol('Style','text','Parent', gui_erp_information.epoch,'String',[32,'',32,'to',32,'',32,'ms (','0',32,'pts)'],'FontSize',FonsizeDefault);
        set(gui_erp_information.epoch_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.epoch ,'Sizes',[50 450]);
        %%----------------------------Number of Channels---------------------
        gui_erp_information.chan_num = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.numofchan_title = uicontrol('Style','text','Parent', gui_erp_information.chan_num,'String','Number of channels:','FontSize',FonsizeDefault);
        set(gui_erp_information.numofchan_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        gui_erp_information.numofchan  = uicontrol('Style','text','Parent', gui_erp_information.chan_num,'String','','FontSize',FonsizeDefault);
        set(gui_erp_information.numofchan,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.chan_num ,'Sizes',[125 375]);
        %         set(gui_erp_information.filename_gui,'Sizes',[100 -1]);
        %%----------------------------Number of bins---------------------
        gui_erp_information.bin_num = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.bin_num_title = uicontrol('Style','text','Parent', gui_erp_information.bin_num,'String','Number of bins:','FontSize',FonsizeDefault);
        set(gui_erp_information.bin_num_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        gui_erp_information.numofbin  = uicontrol('Style','text','Parent', gui_erp_information.bin_num,'String','','FontSize',FonsizeDefault);
        %         set(gui_erp_information.filename_gui,'Sizes',[100 -1]);
        set(gui_erp_information.numofbin,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.bin_num ,'Sizes',[110 390]);
        %%----------------------------Total accepted---------------------
        N_trials = 0;
        N_trial_total = 0;
        N_trial_rejected = 0;
        if N_trial_total ==0
            Total_rejected_trials = strcat('0%');
        else
            Total_rejected_trials = strcat('0%');
        end
        gui_erp_information.total_rejected = uiextras.HBox('Parent',gui_erp_information.DataSelBox);
        gui_erp_information.total_rejected_title = uicontrol('Style','text','Parent', gui_erp_information.total_rejected,'String','Total rejected trials:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_information.total_rejected_title,'HorizontalAlignment','left');
        
        gui_erp_information.total_rejected_percentage  = uicontrol('Style','text','Parent', gui_erp_information.total_rejected,'String',Total_rejected_trials,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_information.total_rejected_percentage,'HorizontalAlignment','left');
        set(gui_erp_information.total_rejected,'Sizes',[125 375]);
        
        %%------------totla rejected----------
        gui_erp_information.total_rejected_show = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.total_rejected_option  = uicontrol('Style','pushbutton','Parent', gui_erp_information.total_rejected_show,'String','Artifact rejection details',...
            'callback',@total_reject_ops,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_information.total_rejected_option.Enable = 'off';
        uiextras.Empty('Parent', gui_erp_information.total_rejected_show);
        set(gui_erp_information.total_rejected_show,'Sizes',[150 250]);
        
        
        %%---------------------Table---------------------------------------
        gui_erp_information.bin_latency_title = uiextras.HBox('Parent', gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_information.bin_latency_title,...
            'String','Trial information:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_information.table_title = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = [];
            dsnames{ii,2} = [];
            dsnames{ii,3} = [];
            dsnames{ii,4} = [];
            dsnames{ii,5} = [];
        end
        gui_erp_information.table_event = uitable(  ...
            'Parent'        , gui_erp_information.table_title,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {50,50,60,60,50}, ...
            'ColumnName'    , {'Bin','Total','Accepted','Rejected','invalid'}, ...
            'RowName'       , [],...
            'ColumnEditable',[false, false, false, false, false]);
        set(gui_erp_information.DataSelBox,'Sizes',[20 20 20 20 20 30 20 100])
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Subfunction----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=5
            return;
        end
        
        ERP = observe_ERPDAT.ERP;
        if ~isempty(ERP)
            ERP_time_resolution = strcat(32,num2str(roundn(1000/ERP.srate,-2)),32,'ms(resolution);',32,num2str(ERP.srate),32,'Hz');
        else
            ERP_time_resolution = strcat(32,num2str(0),32,'ms(time resolution);',32,num2str(0),32,'Hz (rate)');
        end
        gui_erp_information.samplingrate_resolution.String = ERP_time_resolution;
        try
            gui_erp_information.epoch_name.String=char(strcat(num2str(roundn(ERP.times(1),-2)),32,'to',32,num2str(roundn(ERP.times(end),-2)),32,...
                'ms(',num2str(numel(ERP.times)),32,'pts)'));
        catch
            gui_erp_information.epoch_name.String=char(strcat('0 to 0 ms(0 pts)'));
        end
        try
            gui_erp_information.numofchan.String=num2str(ERP.nchan);
        catch
            gui_erp_information.numofchan.String=num2str(0);
        end
        try
            gui_erp_information.numofbin.String=num2str(ERP.nbin);
        catch
            gui_erp_information.numofbin.String=num2str(0);
        end
        if ~isempty(ERP)
            N_trials = ERP.ntrials;
            N_trial_total = sum(N_trials.accepted(:))+sum(N_trials.rejected(:))+sum(N_trials.invalid(:));
            N_trial_rejected = sum(N_trials.rejected(:));
            if N_trial_total ==0
                Total_rejected_trials = strcat('0 (0)');
            else
                Total_rejected_trials = strcat([num2str(N_trial_rejected),32,'(',num2str(roundn(N_trial_rejected/N_trial_total,-3)*100),'%)']);
            end
            gui_erp_information.total_rejected_percentage.String = Total_rejected_trials;
            Enable_label = 'on';
            try
                for ii = 1:numel(ERP.ntrials.accepted)
                    dsnames{ii,1} = ii;
                    dsnames{ii,2} = ERP.ntrials.accepted(ii)+ ERP.ntrials.rejected(ii)+ERP.ntrials.invalid(ii);
                    dsnames{ii,3} = ERP.ntrials.accepted(ii);
                    dsnames{ii,4} = ERP.ntrials.rejected(ii);
                    dsnames{ii,5} = ERP.ntrials.invalid(ii);
                end
            catch
                for ii = 1:100
                    dsnames{ii,1} = [];
                    dsnames{ii,2} = [];
                    dsnames{ii,3} = [];
                    dsnames{ii,4} = [];
                    dsnames{ii,5} = [];
                end
            end
            gui_erp_information.table_event.Data = dsnames;
        else
            gui_erp_information.total_rejected_percentage.String = '0';
            Enable_label = 'off';
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;erpworkingmemory('ViewerFlag',0);
        end
        if ViewerFlag==1
            Enable_label = 'off';
        end
        gui_erp_information.total_rejected_percentage.Enable = Enable_label;
        gui_erp_information.total_rejected_option.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=6;
    end

%%----------------Rejection option----------------------------------------
    function total_reject_ops(~,~)
        if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
            return;
        end
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP) || any(SelectedERP>length(observe_ERPDAT.ALLERP))
            SelectedERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = SelectedERP;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        try
            for Numoferp = 1:numel(SelectedERP)
                ERP  = observe_ERPDAT.ALLERP(SelectedERP(Numoferp));
                [ERP, acce, rej, histoflags, erpcom] = pop_summary_AR_erp_detection(ERP);
            end
        catch
            return;
        end
    end

end