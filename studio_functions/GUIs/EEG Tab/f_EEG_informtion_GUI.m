
%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 20234



function varargout = f_EEG_informtion_GUI(varargin)
global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    EEG_info = uiextras.BoxPanel('Parent', fig, 'Title', 'EEGset Information', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_info = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEGset Information', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EEG_info = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEGset Information', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

varargout{1} = EEG_info;
gui_EEG_info = struct;
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_EEG_info(FonsizeDefault);


    function drawui_EEG_info(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        gui_EEG_info.DataSelBox = uiextras.VBox('Parent', EEG_info, 'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%----------------------------Setting sampling rate---------------------
        gui_EEG_info.samplingrate = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.samplingrate = uicontrol('Style','text','Parent', gui_EEG_info.samplingrate,'String','Sampling:','FontSize',FonsizeDefault);
        
        EEG_time_resolution = strcat('Sampling:',32,num2str(0),32,'ms (time resolution);',32,num2str(''),32,'0Hz (rate)');
        set(gui_EEG_info.samplingrate,'HorizontalAlignment','left','BackgroundColor',ColorB_def,'String',EEG_time_resolution);
        
        %%----------------------------Number of Channels---------------------
        gui_EEG_info.chan_num = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.numofchan = uicontrol('Style','text','Parent', gui_EEG_info.chan_num,'String','Number of channels: ','FontSize',FonsizeDefault);
        set(gui_EEG_info.numofchan,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        %%----------------------------Setting epoch---------------------
        gui_EEG_info.epoch = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.epoch_name = uicontrol('Style','text','Parent', gui_EEG_info.epoch,'String','Time: ','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_EEG_info.epoch_name,'HorizontalAlignment','left');
        
        
        %%----------------------------Number of bins---------------------
        gui_EEG_info.bin_num = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.numofbin = uicontrol('Style','text','Parent', gui_EEG_info.bin_num,'String','Number of bins:','FontSize',FonsizeDefault);
        set(gui_EEG_info.numofbin,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        %%----------------------------Number of epoch---------------------
        gui_EEG_info.epoch_num_title = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.numofepoch = uicontrol('Style','text','Parent', gui_EEG_info.epoch_num_title,'String','Number of epochs:','FontSize',FonsizeDefault);
        set(gui_EEG_info.numofepoch,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        %%----------------------------Total accepted---------------------
        N_trials = 0;
        N_trial_total = 0;
        N_trial_rejected = 0;
        if N_trial_total ==0
            Total_rejected_trials = strcat('0');
        else
            Total_rejected_trials = strcat('0%');
        end
        gui_EEG_info.total_rejected = uiextras.HBox('Parent',gui_EEG_info.DataSelBox);
        gui_EEG_info.total_rejected_percentage = uicontrol('Style','text','Parent', gui_EEG_info.total_rejected,'String',['Total rejected trials:',32,Total_rejected_trials],'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_EEG_info.total_rejected_percentage,'HorizontalAlignment','left');
        
        %%------------totla rejected----------
        gui_EEG_info.total_rejected_show = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.total_rejected_option  = uicontrol('Style','pushbutton','Parent', gui_EEG_info.total_rejected_show,'String','Artifact & aSME Summary',...
            'callback',@total_reject_ops,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_EEG_info.total_rejected_option.Enable = 'off';
        uiextras.Empty('Parent', gui_EEG_info.total_rejected_show);
        set(gui_EEG_info.total_rejected_show,'Sizes',[150 250]);
        
        
        %%---------------------Table---------------------------------------
        gui_EEG_info.bin_latency_title = uiextras.HBox('Parent', gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_EEG_info.bin_latency_title,...
            'String','Trial information:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_EEG_info.table_title = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = [];
            dsnames{ii,2} = [];
            dsnames{ii,3} = [];
            dsnames{ii,4} = [];
            dsnames{ii,5} = [];
        end
        gui_EEG_info.table_event = uitable(  ...
            'Parent'        , gui_EEG_info.table_title,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {40,50,60,60,50}, ...
            'ColumnName'    , {'Bin','Total','Accepted','Rejected','invalid'}, ...
            'RowName'       , [],...
            'ColumnEditable',[false, false, false, false, false]);
        set(gui_EEG_info.DataSelBox,'Sizes',[20 20 20 20 20 30 30 20 100])
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Subfunction----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg~=4
            return;
        end
        
        EEG = observe_EEGDAT.EEG;
        if ~isempty(EEG)
            EEG_time_resolution = strcat(32,num2str(roundn(1000/EEG.srate,-2)),32,'ms(resolution);',32,num2str(EEG.srate),32,'Hz');
        else
            EEG_time_resolution = strcat(32,num2str(0),32,'ms(time resolution);',32,num2str(0),32,'Hz (rate)');
        end
        gui_EEG_info.samplingrate.String = ['Sampling:',EEG_time_resolution];
        %%channel
        try
            gui_EEG_info.numofchan.String=['Number of channels:',32,num2str(EEG.nbchan)];
        catch
            gui_EEG_info.numofchan.String=['Number of channels: 0'];
        end
        
        %%------------------------time------------------------
        try
            if EEG.trials==1
                gui_EEG_info.epoch_name.String=['Time:',32,num2str(EEG.xmin),32,'to',32,num2str(EEG.xmax),'s'];
            else
                gui_EEG_info.epoch_name.String=['Epoch:',32,num2str(EEG.times(1)),32,'to',32,num2str(EEG.times(end)),'ms'];
            end
        catch
            gui_EEG_info.epoch_name.String='Time:';
        end
        
        try
            gui_EEG_info.numofbin.String=['Number of bins:',32,num2str(numel(EEG.EVENTLIST.trialsperbin))];
            gui_EEG_info.numofbin.Enable = 'on';
        catch
            gui_EEG_info.numofbin.String='Number of bins:';
            gui_EEG_info.numofbin.Enable = 'off';
        end
        %%Numof rejection
        for ii = 1:100
            dsnamesdef{ii,1} = [];
            dsnamesdef{ii,2} = [];
            dsnamesdef{ii,3} = [];
            dsnamesdef{ii,4} = [];
            dsnamesdef{ii,5} = [];
        end
        if ~isempty(EEG) && EEG.trials>1
            gui_EEG_info.total_rejected_option.Enable = 'on';
            gui_EEG_info.numofepoch.String = ['Number of epochs:',32,num2str(EEG.trials)];
            gui_EEG_info.numofepoch.Enable = 'on';
            [ERP, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname] = averager(EEG, 1, 1, 1, 1, [], [],1);
            ERP.ntrials.accepted = countbinOK;
            ERP.ntrials.rejected = countbiORI-countbinINV-countbinOK;
            ERP.ntrials.invalid = countbinINV;
            N_trials = ERP.ntrials;
            N_trial_total = sum(N_trials.accepted(:))+sum(N_trials.rejected(:))+sum(N_trials.invalid(:));
            N_trial_rejected = sum(N_trials.rejected(:));
            if N_trial_total ==0
                Total_rejected_trials = ['Total rejected trials:',32,'0 (0%)'];
            else
                Total_rejected_trials = strcat([num2str(N_trial_rejected),32,'(',num2str(roundn(N_trial_rejected/N_trial_total,-3)*100),'%)']);
            end
            gui_EEG_info.total_rejected_percentage.String = ['Total rejected trials:',32,Total_rejected_trials];
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
                dsnames = dsnamesdef;
            end
        else
            gui_EEG_info.total_rejected_percentage.String = ['Total rejected trials:',32,'0 (0%)'];
            gui_EEG_info.numofepoch.Enable = 'off';
            Enable_label = 'off';
            dsnames = dsnamesdef;
            gui_EEG_info.numofepoch.String = ['Number of epochs:'];
        end
        gui_EEG_info.table_event.Data = dsnames;
        gui_EEG_info.total_rejected_percentage.Enable = Enable_label;
        gui_EEG_info.total_rejected_option.Enable = Enable_label;
        observe_EEGDAT.count_current_eeg=5;
    end

%%----------------Rejection option----------------------------------------
    function total_reject_ops(~,~)
        if isempty(observe_EEGDAT.ALLEEG) || isempty(observe_EEGDAT.EEG)
            return;
        end
        %%--------Selected EEGsets-----------
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        ALLERP = [];
        try
            for NumofEEG = 1:numel(EEGArray)
                ERP    = buildERPstruct([]);
                EEG  = observe_EEGDAT.ALLEEG(EEGArray(NumofEEG));
                [ERP, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname] = averager(EEG, 1, 1, 1, 1, [], [],1);
                ERP.erpname = EEG.setname;
                ERP.ntrials.accepted = countbinOK;
                ERP.ntrials.rejected = countbiORI-countbinINV-countbinOK;
                ERP.ntrials.invalid = countbinINV;
                %                 [ERP, acce, rej, histoflags, EEGcom] = pop_summary_AR_erp_detection(ERP);
                if NumofEEG ==1
                    ALLERP = ERP;
                else
                    ALLERP(length(ALLERP)+1)   = ERP;
                end
            end
        catch
            return;
        end
        if ~isempty(ALLERP)
            feval('dq_trial_rejection',ALLERP,[],1);
        end
    end

end