
%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022




function varargout = f_erp_informtion_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);


if nargin < 1
    beep;
    help f_erp_informtion_GUI;
    return;
end


try
    ERP = evalin('base','ERP');
catch
    beep;
    disp('f_erp_informtion_GUI: No ERP was found in workspace');
    return;
    
end

if isempty(ERP)
    msgboxText =  'No ERPset was found!';
    title_msg  = 'EStudio: f_erp_informtion_GUI() error:';
    errorfound(msgboxText, title_msg);
    return
end
if ~isfield(ERP, 'bindata')
    msgboxText =  'f_erp_informtion_GUI cannot handle an empty ERP dataset';
    title = 'EStudio: f_erp_informtion_GUI() error:';
    errorfound(msgboxText, title);
    return
end
if isempty(ERP.bindata)
    msgboxText =  'f_erp_informtion_GUI cannot handle an empty ERP dataset';
    title = 'EStudio: f_erp_informtion_GUI() error:';
    errorfound(msgboxText, title);
    return
end


try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    Erp_information = uiextras.BoxPanel('Parent', fig, 'Title', 'ERP Information', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Information', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Erp_information = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Information', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        if ERP.srate> 0
            ERP_time_resolution = strcat(32,num2str(roundn(1000/ERP.srate,-2)),32,'ms (resolution);',32,num2str(ERP.srate),32,'Hz','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        else
            ERP_time_resolution = strcat(32,num2str(0),32,'ms (time resolution);',32,num2str(ERP.srate),32,'Hz (rate)','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        end
        set(gui_erp_information.samplingrate_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        
        gui_erp_information.samplingrate_resolution = uicontrol('Style','text','Parent', gui_erp_information.samplingrate,'String',ERP_time_resolution,'FontSize',FonsizeDefault);
        set(gui_erp_information.samplingrate_resolution,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.samplingrate ,'Sizes',[70 430]);
        
        %%----------------------------Setting epoch---------------------
        gui_erp_information.epoch = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.epoch_title = uicontrol('Style','text','Parent', gui_erp_information.epoch,'String','Epoch:','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_information.epoch_title,'HorizontalAlignment','left');
        gui_erp_information.epoch_name = uicontrol('Style','text','Parent', gui_erp_information.epoch,'String',[32,num2str(roundn(ERP.times(1),-2)),32,'to',32,num2str(roundn(ERP.times(end),-2)),32,'ms (',num2str(numel(ERP.times)),32,'pts)'],'FontSize',FonsizeDefault);
        set(gui_erp_information.epoch_name,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.epoch ,'Sizes',[50 450]);
        
        %%----------------------------Number of Channels---------------------
        gui_erp_information.chan_num = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.numofchan_title = uicontrol('Style','text','Parent', gui_erp_information.chan_num,'String','Number of channels:','FontSize',FonsizeDefault);
        set(gui_erp_information.numofchan_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        gui_erp_information.numofchan  = uicontrol('Style','text','Parent', gui_erp_information.chan_num,'String',[32,num2str(ERP.nchan)],'FontSize',FonsizeDefault);
        set(gui_erp_information.numofchan,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.chan_num ,'Sizes',[125 375]);
        %         set(gui_erp_information.filename_gui,'Sizes',[100 -1]);
        
        
        %%----------------------------Number of bins---------------------
        gui_erp_information.bin_num = uiextras.HBox('Parent',gui_erp_information.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_information.bin_num_title = uicontrol('Style','text','Parent', gui_erp_information.bin_num,'String','Number of bins:','FontSize',FonsizeDefault);
        set(gui_erp_information.bin_num_title,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        gui_erp_information.numofbin  = uicontrol('Style','text','Parent', gui_erp_information.bin_num,'String',[num2str(ERP.nbin)],'FontSize',FonsizeDefault);
        %         set(gui_erp_information.filename_gui,'Sizes',[100 -1]);
        set(gui_erp_information.numofbin,'HorizontalAlignment','left','BackgroundColor',ColorB_def);
        set(gui_erp_information.bin_num ,'Sizes',[110 390]);
        
        
        %%----------------------------Total accepted---------------------
        N_trials = ERP.ntrials;
        N_trial_total = sum(N_trials.accepted(:))+sum(N_trials.rejected(:))+sum(N_trials.invalid(:));
        N_trial_rejected = sum(N_trials.rejected(:));
        
        if N_trial_total ==0
            Total_rejected_trials = strcat('0');
        else
            Total_rejected_trials = strcat(num2str(roundn(N_trial_rejected/N_trial_total,-3)*100),'%');
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
            'callback',@total_reject_ops,'FontSize',FonsizeDefault);
        
        if strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
            gui_erp_information.total_rejected_option.Enable = 'off';
        end
        uiextras.Empty('Parent', gui_erp_information.total_rejected_show);
        set(gui_erp_information.total_rejected_show,'Sizes',[150 250]);
        
        set(gui_erp_information.DataSelBox,'Sizes',[20 20 20 20 20 30])
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Subfunction----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
%         try
%             ERPloadIndex = estudioworkingmemory('ERPloadIndex');
%         catch
%             ERPloadIndex =0;
%         end
%         if ERPloadIndex==1
%             ALLERPIN = evalin('base','ALLERP');
%             CURRENTERPIN = evalin('base','CURRENTERP');
%             observe_ERPDAT.ALLERP = ALLERPIN;
%             observe_ERPDAT.CURRENTERP =CURRENTERPIN;
%             try
%                 observe_ERPDAT.ERP = ALLERPIN(CURRENTERPIN);
%             catch
%                 observe_ERPDAT.ERP = ALLERPIN(end);
%                 observe_ERPDAT.CURRENTERP =length(ALLERPIN);
%             end
%         end
        
        
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        S_binchan =  estudioworkingmemory('geterpbinchan');
        SelectedERP_current_index = S_binchan.Select_index;
        
        if ~isempty(SelectedERP)&& SelectedERP_current_index> numel(SelectedERP)
            SelectedERP(1) = observe_ERPDAT.CURRENTERP;
            SelectedERP_current_index = 1;
        end
        
        if strcmp(observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index)).erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        
        ERP_current_index = observe_ERPDAT.ALLERP(SelectedERP(SelectedERP_current_index));
        if numel(SelectedERP)==1
            if ERP_current_index.srate> 0
                ERP_time_resolution = strcat(32,num2str(roundn(1000/ERP_current_index.srate,-2)),32,'ms(resolution);',32,num2str(ERP_current_index.srate),32,'Hz');
            else
                ERP_time_resolution = strcat(32,num2str(0),32,'ms(time resolution);',32,num2str(ERP_current_index.srate),32,'Hz (rate)');
            end
            gui_erp_information.samplingrate_resolution.String = ERP_time_resolution;
            try
                gui_erp_information.epoch_name.String=char(strcat(num2str(roundn(ERP_current_index.times(1),-2)),32,'to',32,num2str(roundn(ERP_current_index.times(end),-2)),32,...
                    'ms(',num2str(numel(ERP_current_index.times)),32,'pts)'));
            catch
                gui_erp_information.epoch_name.String=char(strcat('0 to 0ms(0 pts)'));
            end
            
            gui_erp_information.numofchan.String=num2str(ERP_current_index.nchan);
            gui_erp_information.numofbin.String=num2str(ERP_current_index.nbin);
            N_trials = ERP_current_index.ntrials;
            N_trial_total = sum(N_trials.accepted(:))+sum(N_trials.rejected(:))+sum(N_trials.invalid(:));
            N_trial_rejected = sum(N_trials.rejected(:));
            if N_trial_total ==0
                Total_rejected_trials = strcat('0');
            else
                Total_rejected_trials = strcat(num2str(roundn(N_trial_rejected/N_trial_total,-3)*100),'%');
            end
            gui_erp_information.total_rejected_percentage.Enable = Enable_label;
            gui_erp_information.total_rejected_percentage.String = Total_rejected_trials;
            gui_erp_information.total_rejected_option.Enable = Enable_label;
        end
        
        if numel(SelectedERP)>1
            Check_Selected_erpset = [0 0 0 0 0 0 0];
            if numel(SelectedERP)>1
                
                Check_Selected_erpset = S_binchan.checked_ERPset_Index;
                
            end
            %%bin
            if Check_Selected_erpset(1) ==1
                gui_erp_information.numofbin.String = 'Varied across ERPsets';
            else
                try
                    BinNum = observe_ERPDAT.ERP.nbin;
                catch
                    BinNum = 0;
                end
                gui_erp_information.numofbin.String = num2str(BinNum);
            end
            
            %%chan
            if Check_Selected_erpset(2) ==2
                gui_erp_information.numofchan.String = 'Varied across ERPsets';
            else
                try
                    chanNum = observe_ERPDAT.ERP.nchan;
                catch
                    chanNum = 0;
                end
                gui_erp_information.numofchan.String = num2str(chanNum);
            end
            %%Total rejected artifacts
            gui_erp_information.total_rejected_percentage.String = 'Varied across ERPsets';
            
            %%sampling rate
            if Check_Selected_erpset(7) ==7
                gui_erp_information.samplingrate_resolution.String = 'Varied across ERPsets';
            else
                try
                    if observe_ERPDAT.ERP.srate
                        ERP_time_resolution = strcat(32,num2str(roundn(1000/ERP_current_index.srate,-2)),32,'ms(resolution);',32,num2str(ERP_current_index.srate),32,'Hz');
                    end
                catch
                    ERP_time_resolution = strcat(32,num2str(0),32,'ms(time resolution);',32,num2str(ERP_current_index.srate),32,'Hz (rate)');
                end
                gui_erp_information.samplingrate_resolution.String = ERP_time_resolution;
            end
            
            if any(Check_Selected_erpset(4:6))
                gui_erp_information.epoch_name.String=char(strcat('Varied across ERPsets'));
            else
                try
                    gui_erp_information.epoch_name.String=char(strcat(num2str(roundn(ERP_current_index.times(1),-2)),32,'to',32,num2str(roundn(ERP_current_index.times(end),-2)),32,...
                        'ms(',num2str(numel(ERP_current_index.times)),32,'pts)'));
                catch
                    gui_erp_information.epoch_name.String=char(strcat('0 to 0ms(0 pts)'));
                end
            end
            
            
        end
        
        
    end



%%----------------Rejection option----------------------------------------
    function total_reject_ops(~,~)
        
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
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