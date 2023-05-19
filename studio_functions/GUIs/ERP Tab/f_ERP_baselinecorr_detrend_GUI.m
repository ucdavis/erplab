%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_baselinecorr_detrend_GUI(varargin)

% global gui_erp_blc_dt;
global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@erpschange);
% addlistener(observe_ERPDAT,'ERP_change',@drawui_CB);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);

%%---------------------------gui-------------------------------------------
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_basecorr_detrend_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Baseline Correction & Linear Detrend', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_basecorr_detrend_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Baseline Correction & Linear Detrend', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_basecorr_detrend_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Baseline Correction & Linear Detrend', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

gui_erp_blc_dt = struct();
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
   FonsizeDefault = f_get_default_fontsize();
end
erp_blc_dt_gui(FonsizeDefault);
varargout{1} = ERP_basecorr_detrend_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_blc_dt_gui(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        
        if strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        gui_erp_blc_dt.blc_dt = uiextras.VBox('Parent',ERP_basecorr_detrend_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        %%Measurement type
        gui_erp_blc_dt.blc_dt_type_title = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_blc_dt.blc_dt_type_title,...
            'String','Type:','FontWeight','bold','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.blc_dt_option = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.blc = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_option,...
            'String','Baseline Correction','callback',@baseline_correction_erp,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.dt = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_option,...
            'String','Linear detrend','callback',@detrend_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        %%Baseline period: Pre, post whole custom
        gui_erp_blc_dt.blc_dt_baseline_period_title = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_blc_dt.blc_dt_baseline_period_title,...
            'String','Baseline Period:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.blc_dt_bp_option = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.pre = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option,...
            'String','Pre','callback',@pre_erp,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.post = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option,...
            'String','Post','callback',@post_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.whole = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option,...
            'String','Whole','callback',@whole_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.blc_dt_bp_option_cust = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.custom = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_dt_bp_option_cust,...
            'String','Custom (ms) [start stop]','callback',@custom_erp,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.custom_edit = uicontrol('Style', 'edit','Parent', gui_erp_blc_dt.blc_dt_bp_option_cust,...
            'String','','callback',@custom_edit,'Enable',Enable_label,'FontSize',FonsizeDefault);
        
        if observe_ERPDAT.ERP.times(1)>=0
            CUstom_String = '';
        else
            CUstom_String = num2str([observe_ERPDAT.ERP.times(1),0]);
        end
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
        set(gui_erp_blc_dt.blc_dt_bp_option_cust, 'Sizes',[160  135]);
        
        
        %%Bin and channels selection
        gui_erp_blc_dt.blc_dt_bin_chan_title = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_blc_dt.blc_dt_bin_chan_title,...
            'String','Bin and Chan Selection:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.blc_bin_chan_option = uiextras.HBox('Parent',  gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.all_bin_chan = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_bin_chan_option,...
            'String','All(Recommended)','callback',@All_bin_chan,'Value',1,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        gui_erp_blc_dt.Selected_bin_chan = uicontrol('Style', 'radiobutton','Parent', gui_erp_blc_dt.blc_bin_chan_option,...
            'String','Selected bin & chan','callback',@Selected_bin_chan,'Value',0,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_blc_dt.blc_bin_chan_option, 'Sizes',[125  175]);
        
        %%Cancel and advanced
        gui_erp_blc_dt.other_option = uiextras.HBox('Parent',gui_erp_blc_dt.blc_dt,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_blc_dt.other_option,'BackgroundColor',ColorB_def);
        gui_erp_blc_dt.reset = uicontrol('Parent',gui_erp_blc_dt.other_option,'Style','pushbutton',...
            'String','Reset','callback',@Reset_blc_dt,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_blc_dt.other_option);
        gui_erp_blc_dt.apply = uicontrol('Style','pushbutton','Parent',gui_erp_blc_dt.other_option,...
            'String','Apply','callback',@apply_blc_dt,'Enable',Enable_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_blc_dt.other_option);
        set(gui_erp_blc_dt.other_option, 'Sizes',[15 105  30 105 15]);
        
        set(gui_erp_blc_dt.blc_dt,'Sizes',[18 25 15 25 25 15 25 30]);
        
    end
%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%--------------------------------setting for amplitude------------------
    function  baseline_correction_erp(source,~)
        gui_erp_blc_dt.blc.Value =1;
        gui_erp_blc_dt.dt.Value = 0;
    end

%%--------------------------Setting for phase-----------------------------
    function detrend_erp(source,~)
        gui_erp_blc_dt.dt.Value = 1;
        gui_erp_blc_dt.blc.Value =0;
    end

%%----------------Setting for "pre"-----------------------------------------
    function pre_erp(~,~)
        gui_erp_blc_dt.pre.Value=1;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        if observe_ERPDAT.ERP.times(1)>=0
            CUstom_String = '';
        else
            CUstom_String = num2str([observe_ERPDAT.ERP.times(1),0]);
        end
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
        
    end


%%----------------Setting for "post"-----------------------------------------
    function post_erp(~,~)
        gui_erp_blc_dt.pre.Value=0;
        gui_erp_blc_dt.post.Value=1;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        
        if observe_ERPDAT.ERP.times(end)<=0
            CUstom_String = '';
        else
            CUstom_String = num2str([0 observe_ERPDAT.ERP.times(end)]);
        end
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
        
    end

%%----------------Setting for "whole"-----------------------------------------
    function whole_erp(~,~)
        gui_erp_blc_dt.pre.Value=0;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=1;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        CUstom_String = num2str([observe_ERPDAT.ERP.times(1) observe_ERPDAT.ERP.times(end)]);
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
    end

%%----------------Setting for "custom"-----------------------------------------
    function custom_erp(~,~)
        gui_erp_blc_dt.pre.Value=0;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=1;
        gui_erp_blc_dt.custom_edit.Enable = 'on';
    end

%%----------------input baseline period defined by user----------------------
    function custom_edit(Source,~)
        lat_osci = str2num(Source.String);
        if isempty(lat_osci)
            beep;
            msgboxText =  ['Baseline Correction & Linear Detrend - Invalid input for "baseline range"'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if numel(lat_osci) ==1
            beep;
            msgboxText =  ['Baseline Correction & Linear Detrend - Wrong baseline range. Please, enter two values'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if lat_osci(1)>= lat_osci(2)
            beep;
            msgboxText =  ['Baseline Correction & Linear Detrend - The first value must be smaller than the second one'];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        if lat_osci(2) > observe_ERPDAT.ERP.times(end)
            beep;
            msgboxText =  ['Baseline Correction & Linear Detrend - Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.times(end))];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if lat_osci(1) < observe_ERPDAT.ERP.times(1)
            beep;
            msgboxText =  ['Baseline Correction & Linear Detrend - First value must be larger than',32,num2str(observe_ERPDAT.ERP.times(1))];
            fprintf(2,['\n Warning: ',msgboxText,'.\n']);
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
    end

%%---------------------Setting for all chan and bin------------------------
    function All_bin_chan(~,~)
        gui_erp_blc_dt.all_bin_chan.Value = 1;
        gui_erp_blc_dt.Selected_bin_chan.Value = 0;
    end

%%----------------Setting for selected bin and chan------------------------
    function Selected_bin_chan(~,~)
        gui_erp_blc_dt.all_bin_chan.Value = 0;
        gui_erp_blc_dt.Selected_bin_chan.Value = 1;
    end
%%--------------------------Setting for plot-------------------------------
    function apply_blc_dt(~,~)
        
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        
        
        try
            if gui_erp_blc_dt.pre.Value==1
                BaselineMethod = 'pre';
            elseif  gui_erp_blc_dt.post.Value==1
                BaselineMethod = 'post';
            elseif  gui_erp_blc_dt.whole.Value==1
                BaselineMethod = 'all';
            elseif  gui_erp_blc_dt.custom.Value ==1
                BaselineMethod = str2num(gui_erp_blc_dt.custom_edit.String);
            end
        catch
            BaselineMethod = 'pre';
        end
        
        %%Check the baseline period defined by the custom.
        if gui_erp_blc_dt.custom.Value ==1
            if isempty(BaselineMethod)
                beep;
                msgboxText =  ['Baseline Correction & Linear Detrend - Invalid input for baseline range; Please reset two values'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if numel(BaselineMethod) ==1
                beep;
                msgboxText =  ['Baseline Correction & Linear Detrend - Wrong baseline range. Please, enter two values'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if BaselineMethod(1)>= BaselineMethod(2)
                beep;
                msgboxText =  ['Baseline Correction & Linear Detrend - The first value must be smaller than the second one'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if roundn(BaselineMethod(2),-3) > roundn(observe_ERPDAT.ERP.times(end),-3)
                beep;
                msgboxText =  ['Baseline Correction & Linear Detrend - Second value must be smaller than',32,num2str(observe_ERPDAT.ERP.times(end))];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            if roundn(BaselineMethod(1),-3) < roundn(observe_ERPDAT.ERP.times(1),-3)
                beep;
                msgboxText =  ['Baseline Correction & Linear Detrend - First value must be larger than',32,num2str(observe_ERPDAT.ERP.times(1))];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
        end
        
        %%Run the function based on the defined parameters
        Check_Selected_erpset = [0 0 0 0 0 0 0];
        S_ws_binchan=  estudioworkingmemory('geterpbinchan');
        if numel(Selected_erpset)>1
            try
                Check_Selected_erpset = S_ws_binchan.checked_ERPset_Index;
            catch
                Check_Selected_erpset = f_checkerpsets(observe_ERPDAT.ALLERP,Selected_erpset);
            end
        end
        
        %%--------------Loop start for removeing baseline for the selected ERPsets------------
        if gui_erp_blc_dt.dt.Value ==1
            Suffix_str = char(strcat('detrend'));
        else
            Suffix_str = char(strcat('baselinecorr'));
        end
        if numel(Selected_erpset)>1
            if gui_erp_blc_dt.dt.Value ==1
                Suffix_str = char(strcat('detrend'));
            else
                Suffix_str = char(strcat('baselinecorr'));
            end
            
            Answer = f_ERP_save_multi_file(observe_ERPDAT.ALLERP,Selected_erpset,Suffix_str);
            if isempty(Answer)
                beep;
                disp('User selected Cancel');
                return;
            end
            
            if ~isempty(Answer{1})
                ALLERP_advance = Answer{1};
                Save_file_label = Answer{2};
            end
            
        elseif numel(Selected_erpset)==1
            Save_file_label = 0;
            ALLERP_advance = observe_ERPDAT.ALLERP;
        end
        
        %%%%-------------------Loop fpor baseline correction---------------
        erpworkingmemory('f_ERP_proces_messg','Baseline correction & Linear detrend');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        
        try
            BinArray = [];
            ChanArray = [];
            for Numoferp = 1:numel(Selected_erpset)
                
                if Selected_erpset(Numoferp)> length(observe_ERPDAT.ALLERP)
                    error('EStudio says: No corresponding ERP exists in ALLEERP');
                    break;
                end
                
                ERP = observe_ERPDAT.ALLERP(Selected_erpset(Numoferp));
                if (Check_Selected_erpset(1)==1 || Check_Selected_erpset(2)==2) && gui_erp_blc_dt.Selected_bin_chan.Value ==1
                    if Check_Selected_erpset(1) ==1
                        msgboxText =  ['Number of bins across the selected ERPsets is different!'];
                    elseif Check_Selected_erpset(2)==2
                        msgboxText =  ['Number of channels across the selected ERPsets is different!'];
                    elseif Check_Selected_erpset(1)==1 && Check_Selected_erpset(2)==2
                        msgboxText =  ['Number of channels and bins vary across the selected ERPsets'];
                    end
                    question = [  '%s\n\n "All" will be active instead of "Selected bin and chan".'];
                    title       = 'EStudio: Baseline correction & linear detrend';
                    button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
                    BinArray = [];
                    ChanArray = [];
                end
                
                if (Check_Selected_erpset(1)==0 && Check_Selected_erpset(2)==0) && gui_erp_blc_dt.Selected_bin_chan.Value ==1
                    try
                        BinArray = S_ws_binchan.bins{1};
                        ChanArray = S_ws_binchan.elecs_shown{1};
                        [chk, msgboxText] = f_ERP_chckbinandchan(ERP, BinArray, [],1);
                        if chk(1)==1
                            BinArray =  [1:ERP.nbin];
                        end
                        [chk, msgboxText] = f_ERP_chckbinandchan(ERP,[], ChanArray,2);
                        if chk(2)==1
                            ChanArray =  [1:ERP.nchan];
                        end
                        
                    catch
                        BinArray = [1:ERP.nbin];
                        ChanArray = [1:ERP.nchan];
                    end
                end
                
                if gui_erp_blc_dt.all_bin_chan.Value == 1
                    BinArray = [1:ERP.nbin];
                    ChanArray = [1:ERP.nchan];
                end
                
                
                if gui_erp_blc_dt.dt.Value ==1
                    [ERP ERPCOM] = pop_erplindetrend( ERP, BaselineMethod , 'Saveas', 'off','History','gui');
                else
                    [ERP ERPCOM]= pop_blcerp( ERP , 'Baseline', BaselineMethod, 'Saveas', 'off','History','gui');
                end
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                if Numoferp ==1
                    [~, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
                end
                
                %%Only the slected bin and chan were selected to remove baseline and detrending and others are remiained.
                if ~isempty(BinArray)
                    ERP_before_bl = ALLERP_advance(Selected_erpset(Numoferp));
                    ERP_before_bl.bindata(ChanArray,:,BinArray) = ERP.bindata(ChanArray,:,BinArray);
                    ERP_before_bl.history = ERP.history;
                    ERP = ERP_before_bl;
                end
                
                
                if numel(Selected_erpset) ==1
                    Answer = f_ERP_save_single_file(strcat(ERP.erpname,'-',Suffix_str),ERP.filename,Selected_erpset(Numoferp));
                    if isempty(Answer)
                        beep;
                        disp('User selectd cancal');
                        return;
                    end
                    
                    if ~isempty(Answer)
                        ERPName = Answer{1};
                        if ~isempty(ERPName)
                            ERP.erpname = ERPName;
                        end
                        fileName_full = Answer{2};
                        if isempty(fileName_full)
                            ERP.filename = ERP.erpname;
                        elseif ~isempty(fileName_full)
                            
                            [pathstr, file_name, ext] = fileparts(fileName_full);
                            ext = '.erp';
                            if strcmp(pathstr,'')
                                pathstr = cd;
                            end
                            ERP.filename = [file_name,ext];
                            ERP.filepath = pathstr;
                            %%----------save the current sdata as--------------------
                            [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                        end
                    end
                end
                
                if Save_file_label
                    [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
                
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
                
            end%%Loop end for the selected ERset
            
            erpworkingmemory('f_ERP_BLS_Detrend',{BaselineMethod,0,1});
            %%
            %             [~, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(Selected_erpset)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(Selected_erpset)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            observe_ERPDAT.Process_messg =2;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            
            observe_ERPDAT.Process_messg =3;
            erpworkingmemory('f_ERP_BLS_Detrend',{BaselineMethod,0,1});
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            return;
        end
         observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%%-----------------Setting for save option---------------------------------
    function Reset_blc_dt(~,~)
        gui_erp_blc_dt.blc.Value =1;
        gui_erp_blc_dt.dt.Value = 0;
        gui_erp_blc_dt.pre.Value=1;
        gui_erp_blc_dt.post.Value=0;
        gui_erp_blc_dt.whole.Value=0;
        gui_erp_blc_dt.custom.Value=0;
        gui_erp_blc_dt.custom_edit.Enable = 'off';
        if observe_ERPDAT.ERP.times(1)>=0
            CUstom_String = '';
        else
            CUstom_String = num2str([observe_ERPDAT.ERP.times(1),0]);
        end
        gui_erp_blc_dt.custom_edit.String = CUstom_String;
        gui_erp_blc_dt.all_bin_chan.Value = 1;
        gui_erp_blc_dt.Selected_bin_chan.Value = 0;
    end


%%-------------------Setting for the whole panel of fitering based on ALLERP and CURRENTERP--------------
    function Count_currentERPChanged(~,~)
        if  strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded') || ~strcmp(observe_ERPDAT.ERP.datatype,'ERP')
            Enable_Label = 'off';
        else
            Enable_Label = 'on';
        end
        
        gui_erp_blc_dt.blc.Enable = Enable_Label;
        gui_erp_blc_dt.dt.Enable = Enable_Label;
        gui_erp_blc_dt.apply.Enable = Enable_Label;
        gui_erp_blc_dt.reset.Enable = Enable_Label;
        gui_erp_blc_dt.pre.Enable= Enable_Label;
        gui_erp_blc_dt.post.Enable= Enable_Label;
        gui_erp_blc_dt.whole.Enable= Enable_Label;
        gui_erp_blc_dt.custom.Enable= Enable_Label;
        gui_erp_blc_dt.custom_edit.Enable = Enable_Label;
        gui_erp_blc_dt.apply.Enable = Enable_Label;
        gui_erp_blc_dt.reset.Enable = Enable_Label;
        gui_erp_blc_dt.all_bin_chan.Enable = Enable_Label;
        gui_erp_blc_dt.Selected_bin_chan.Enable = Enable_Label;
        
        if gui_erp_blc_dt.custom.Value==1
            gui_erp_blc_dt.custom_edit.Enable = 'on';
        else
            gui_erp_blc_dt.custom_edit.Enable = 'off';
        end
        
        Selected_erpset =  estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =  observe_ERPDAT.CURRENTERP;
            S_erpbinchan = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpbinchan.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpbinchan.geterpplot);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        S_binchan =  estudioworkingmemory('geterpbinchan');
        
        Check_Selected_erpset = [0 0 0 0 0 0 0];
        if numel(Selected_erpset)>1
            Check_Selected_erpset = S_binchan.checked_ERPset_Index;
        end
        if Check_Selected_erpset(1) ==1 || Check_Selected_erpset(2) == 2
            gui_erp_blc_dt.all_bin_chan.Enable = 'on';
            gui_erp_blc_dt.Selected_bin_chan.Enable = 'off';
            gui_erp_blc_dt.all_bin_chan.Value = 1;
            gui_erp_blc_dt.Selected_bin_chan.Value = 0;
        end
    end

end
%Progem end: ERP Measurement tool