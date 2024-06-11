
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
    EEG_info = uiextras.BoxPanel('Parent', fig, 'Title', 'EEG & Bin Information', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_info = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG & Bin Information', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EEG_info = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG & Bin Information', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        
        %%EEG setname and file name
        gui_EEG_info.setfilename_title = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', gui_EEG_info.setfilename_title,'String','Current EEG setname & file name',...
            'FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
        
        
        gui_EEG_info.setfilename_title2 = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
            dsnames{ii,2} = '';
        end
        gui_EEG_info.table_setfilenames = uitable(  ...
            'Parent'        , gui_EEG_info.setfilename_title2,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {500}, ...
            'ColumnName'    , {''}, ...
            'RowName'       , {'Set name','File name'},...
            'ColumnEditable',[false]);
        
        %%----------------------------Setting sampling rate---------------------
        gui_EEG_info.samplingrate = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.samplingrate = uicontrol('Style','text','Parent', gui_EEG_info.samplingrate,'String','Sampling:','FontSize',FonsizeDefault);
        
        EEG_time_resolution = strcat('Sampling:');
        set(gui_EEG_info.samplingrate,'HorizontalAlignment','left','BackgroundColor',ColorB_def,'String',EEG_time_resolution);
        
        %%----------------------------Number of Channels---------------------
        gui_EEG_info.chan_num = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.numofchan = uicontrol('Style','text','Parent', gui_EEG_info.chan_num,'String','Number of channels: ','FontSize',FonsizeDefault);
        set(gui_EEG_info.numofchan,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        %%----------------------------Setting epoch---------------------
        gui_EEG_info.epoch = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.epoch_name = uicontrol('Style','text','Parent', gui_EEG_info.epoch,'String','Time range: ','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_EEG_info.epoch_name,'HorizontalAlignment','left');
        
        %%----------------------------Setting chanlocation---------------------
        gui_EEG_info.chanlocs_title = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.chanlocs = uicontrol('Style','text','Parent', gui_EEG_info.chanlocs_title,'String','Channel locations: ','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_EEG_info.chanlocs,'HorizontalAlignment','left');
        
        %%----------------------------Setting ICA weights---------------------
        gui_EEG_info.icweights_title = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'BackgroundColor',ColorB_def);
        gui_EEG_info.icweights = uicontrol('Style','text','Parent', gui_EEG_info.icweights_title ,'String','ICA weights: ','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_EEG_info.icweights,'HorizontalAlignment','left');
        
        
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
        
        
        %%---------------------Table---------------------------------------
        gui_EEG_info.table_title = uiextras.HBox('Parent',gui_EEG_info.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
            dsnames{ii,2} = '';
            dsnames{ii,3} = '';
        end
        gui_EEG_info.table_event = uitable(  ...
            'Parent'        , gui_EEG_info.table_title,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {50,100,100}, ...
            'ColumnName'    , {'Bin','Description','#Occurrences'}, ...
            'RowName'       , [],...
            'ColumnEditable',[false, false, false]);
        
        set(gui_EEG_info.DataSelBox,'Sizes',[20 70 20 20 20 20 20 20 20 30 100]);% 20 100
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Subfunction----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg~=7
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        EEG = observe_EEGDAT.EEG;
        if ~isempty(EEG)
            EEG_time_resolution = strcat(num2str(EEG.srate),32,'Hz',32,'(',num2str(roundn(1000/EEG.srate,-2)),32,'ms /sample)');
        else
            EEG_time_resolution = strcat('');
        end
        gui_EEG_info.samplingrate.String = ['Sampling: ',EEG_time_resolution];
        %%channel
        try
            gui_EEG_info.numofchan.String=['Number of channels: ',32,num2str(EEG.nbchan)];
        catch
            gui_EEG_info.numofchan.String=['Number of channels: 0'];
        end
        
        %%------------------------time------------------------
        try
            if EEG.trials==1
                gui_EEG_info.epoch_name.String=['Time range: ',32,num2str(EEG.xmin),32,'to',32,num2str(EEG.xmax),'s'];
            else
                gui_EEG_info.epoch_name.String=['Epoch: ',32,num2str(EEG.times(1)),32,'to',32,num2str(EEG.times(end)),32,'ms',32,'(',num2str(EEG.pnts),32,'pnts)'];
            end
        catch
            gui_EEG_info.epoch_name.String='Time range: ';
        end
        %%channel locations?
        try
            count = 0;
            if ~isempty(EEG.chanlocs)
                for Numofchan = 1:EEG.nbchan
                    if ~isempty(EEG.chanlocs(Numofchan).X)
                        count =1;
                    end
                end
            end
            if count==1
                gui_EEG_info.chanlocs.String = 'Channel locations: set';
            else
                gui_EEG_info.chanlocs.String = 'Channel locations: not set';
            end
        catch
            gui_EEG_info.chanlocs.String = 'Channel locations: not set';
        end
        
        try
            if ~isempty(EEG)
                if ~isempty(EEG.icachansind) && ~isempty(EEG.icaweights) && ~isempty(EEG.icasphere) && ~isempty(EEG.icawinv)
                    gui_EEG_info.icweights.String = 'ICA Weights: present';
                else
                    gui_EEG_info.icweights.String = 'ICA Weights: absent';
                end
            end
        catch
            gui_EEG_info.icweights.String = 'ICA Weights: ';
        end
        
        try
            gui_EEG_info.numofbin.String=['Number of bins: ',32,num2str(numel(EEG.EVENTLIST.trialsperbin))];
            gui_EEG_info.numofbin.Enable = 'on';
        catch
            gui_EEG_info.numofbin.String='Number of bins: ';
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
        if ~isempty(EEG) && EEG.trials>1 && isfield(EEG,'EVENTLIST') && ~isempty(EEG.EVENTLIST)
            gui_EEG_info.numofepoch.String = ['Number of epochs:',32,num2str(EEG.trials)];
            gui_EEG_info.numofepoch.Enable = 'on';
            [ERP, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname] = averager(EEG, 1, 1, 1, 1, [], [],0);
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
        else
            gui_EEG_info.total_rejected_percentage.String = ['Total rejected trials:',32,'0 (0%)'];
            gui_EEG_info.numofepoch.Enable = 'off';
            Enable_label = 'off';
            dsnames = dsnamesdef;
            gui_EEG_info.numofepoch.String = ['Number of epochs:'];
        end
        %         gui_EEG_info.table_event.Data = dsnames;
        if EEGUpdate==1
            Enable_label = 'off';
        end
        gui_EEG_info.total_rejected_percentage.Enable = Enable_label;
        
        try
            filesetname{1,1} = EEG.setname;
            filesetname{2,1} = EEG.filename;
        catch
            filesetname{1,1} = '';
            filesetname{2,1} = '';
        end
        gui_EEG_info.table_setfilenames.Data= filesetname;
        
        for ii = 1:100
            dsnamesdef{ii,1} = '';
            dsnamesdef{ii,2} = '';
            dsnamesdef{ii,3} = '';
        end
        if ~isempty(observe_EEGDAT.EEG)  &&  isfield(observe_EEGDAT.EEG,'EVENTLIST') && ~isempty(observe_EEGDAT.EEG.EVENTLIST) && (~isempty(observe_EEGDAT.EEG.EVENTLIST.trialsperbin))
            EEG = observe_EEGDAT.EEG;
            for jjj = 1:length(EEG.EVENTLIST.eventinfo)
                eventbini(jjj,1) = EEG.EVENTLIST.eventinfo(jjj).bini;
            end
            if any(eventbini(:)>0)
                for ii = 1:length(observe_EEGDAT.EEG.EVENTLIST.trialsperbin)
                    try
                        dsnames{ii,1} = num2str(ii);
                        dsnames{ii,2} = EEG.EVENTLIST.bdf(ii).description;
                        dsnames{ii,3} = num2str(EEG.EVENTLIST.trialsperbin(ii));
                    catch
                        dsnames{ii,1} = '';
                        dsnames{ii,2} = '';
                        dsnames{ii,3} ='';
                    end
                end
            else
                dsnames = dsnamesdef;
            end
        else
            dsnames = dsnamesdef;
        end
        gui_EEG_info.table_event.Data = dsnames;
        
        observe_EEGDAT.count_current_eeg=8;
    end
end