% ERP Viewer for EStudio Toolbox
%
% Author: Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

% ERPLAB Toolbox
%

%
% Initial setup
%
function varargout = f_ERPsets_waviewer_GUI(varargin)
%
global viewer_ERPDAT
global observe_ERPDAT;
global gui_erp_waviewer;
addlistener(viewer_ERPDAT,'loadproper_change',@loadproper_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);
addlistener(viewer_ERPDAT,'ERPset_Chan_bin_label_change',@ERPset_Chan_bin_label_change);
addlistener(observe_ERPDAT,'Two_GUI_change',@Two_GUI_change);
ERPwaveview_erpsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------
% gui_erp_waviewer.Window.WindowButtonMotionFcn = {@erpselect_refresh};
try
    [version reldate,ColorBviewer_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
catch
    ColorBviewer_def = [0.7765    0.7294    0.8627];
end
ERPdatasets = []; % Local data structure
% global ERPsets_waveviewer_box;
if nargin == 0
    fig = figure(); % Parent figure
    ERPsets_waveviewer_box = uiextras.BoxPanel('Parent', fig, 'Title', 'ERPsets', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12); % Create boxpanel
elseif nargin == 1
    ERPsets_waveviewer_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12);
elseif nargin == 3 || nargin == 2
    ERPsets_waveviewer_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
elseif nargin == 4
    ERPsets_waveviewer_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
    
end
% ERPsets_waveviewer_box.Position(4) = 400;
try
    ALLERPwaviewer = evalin('base','ALLERPwaviewer');
    ERPwaviewer = ALLERPwaviewer;
catch
    return;
end

ALLERP = ERPwaviewer.ALLERP;
ERPdatasets = getERPDatasets(ALLERP); % Get datasets from ALLERP
ERPdatasets = sortdata(ERPdatasets);
ERPdatasets = sortdata(ERPdatasets);

%%Get local path
sel_path = cd;
estudioworkingmemory('ERP_save_folder',sel_path);


varargout{1} = ERPsets_waveviewer_box;
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end

drawui_erpsetbinchan_viewer(ERPdatasets,ERPwaviewer,FonsizeDefault)

% Draw the ui
    function drawui_erpsetbinchan_viewer(ERPdatasets,ERPwaviewer,FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        catch
            ColorBviewer_def =  [0.7765    0.7294    0.8627];
        end
        try
            SelectedIndex = ERPwaviewer.SelectERPIdx;
            ALLERP = ERPwaviewer.ALLERP;
            if max(SelectedIndex(:))> length(ALLERP)
                SelectedIndex =length(ALLERP);
            end
        catch
            beep;
            disp('f_ERPsets_waviewer_GUI error: Restart ERPwave Viewer');
            return;
        end
        
        [r, ~] = size(ERPdatasets); % Get size of array of ERPdatasets. r is # of ERPdatasets
        % Sort the ERPdatasets!!!
        ERPdatasets = sortdata(ERPdatasets);
        ERPwaveview_erpsetops.vBox = uiextras.VBox('Parent', ERPsets_waveviewer_box, 'Spacing', 5,'BackgroundColor',ColorBviewer_def); % VBox for everything
        
        %%-----------------------Display tthe selected ERPsets---------------------------------------
        panelshbox = uiextras.HBox('Parent', ERPwaveview_erpsetops.vBox, 'Spacing', 5,'BackgroundColor',ColorBviewer_def);
        dsnames = {};
        if size(ERPdatasets,1)==1
            if strcmp(ERPdatasets{1},'No ERPset loaded')
                dsnames = {''};
            else
                dsnames{1} =    strcat(num2str(cell2mat(ERPdatasets(1,2))),'.',32,ERPdatasets{1,1});
            end
        else
            for Numofsub = 1:size(ERPdatasets,1)
                dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
            end
        end
        ds_length = length(ERPdatasets);
        ERPwaveview_erpsetops.butttons_datasets = uicontrol('Parent', panelshbox, 'Style', 'listbox', 'min', 1,'max',...
            ds_length,'String', dsnames,'Value', SelectedIndex,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable','on');
        ERPwaveview_erpsetops.butttons_datasets.KeyPressFcn = @ERPset_keypress;
        %%Help and apply
        ERPwaveview_erpsetops.help_apply_title = uiextras.HBox('Parent', ERPwaveview_erpsetops.vBox,'BackgroundColor',ColorBviewer_def);
        ERPwaveview_erpsetops.auto = uicontrol('Style', 'pushbutton','Parent', ERPwaveview_erpsetops.help_apply_title,...
            'String',' Refresh','callback',@erpselect_refresh,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title );
        uicontrol('Style','pushbutton','Parent', ERPwaveview_erpsetops.help_apply_title  ,'String','Cancel',...
            'callback',@erpset_help,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title  );
        ERPwaveview_erpsetops.erpset_apply = uicontrol('Style','pushbutton','Parent',ERPwaveview_erpsetops.help_apply_title  ,'String','Apply',...
            'callback',@ERPset_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        %         uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title );
        set(ERPwaveview_erpsetops.help_apply_title ,'Sizes',[70 14 70 14 70]);
        set(ERPwaveview_erpsetops.vBox, 'Sizes', [190 25]);
        ERPwaveview_erpsetops.ERPLABFlag = 0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------select the ERPset of interest--------------------------
    function selectdata(~,EventData)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_ERPsetpanel',1);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [0.4940 0.1840 0.5560];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [1 1 1];
        ERPsets_waveviewer_box.TitleColor= [0.4940 0.1840 0.5560];
    end


%%---------------Setting for auto option-----------------------------------
    function erpselect_refresh(~,~)
        %         Value = Source.Value;
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        ERPtooltype = erpgettoolversion('tooltype');
        
        %%load the parameters from workspace
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n ERPsets > Refresh-f_ERPsets_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        MessageViewer= char(strcat('ERPsets>" Refresh'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        
        if strcmpi(ERPtooltype,'EStudio') || strcmpi(ERPtooltype,'ERPLAB')
            if strcmpi(ERPtooltype,'ERPLAB')
                try
                    Selected_erpset = ERPwaveview_erpsetops.butttons_datasets.Value;
                    try
                        CURRENTERPStudio = Selected_erpset(ERPwaviewer_apply.PageIndex);
                    catch
                        CURRENTERPStudio = Selected_erpset(1);
                        ERPwaviewer_apply.PageIndex=1;
                    end
                catch
                    messgStr =  strcat('Cannot get CURRENTERP from Workspace');
                    erpworkingmemory('ERPViewer_proces_messg',messgStr);
                    viewer_ERPDAT.Process_messg =3;
                    return;
                end
                %                 estudioworkingmemory('PlotOrg_ERPLAB',1);
            end
            try
                ALLERPin = evalin('base','ALLERP');
            catch
                messgStr =  strcat('Cannot get ALLERP from Workspace');
                erpworkingmemory('ERPViewer_proces_messg',messgStr);
                viewer_ERPDAT.Process_messg =3;
                return;
            end
            if isempty(ALLERPin)
                viewer_ERPDAT.Process_messg =3;
                try
                    cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                    close(gui_erp_waviewer.Window);
                catch
                end
                assignin('base','ALLERPwaviewer',[]);
                return;
            end
            
            if strcmpi(ERPtooltype,'EStudio')
                Selected_erpset= estudioworkingmemory('selectederpstudio');
                CURRENTERPStudio = observe_ERPDAT.CURRENTERP;
                if length(ALLERPin)==1 && strcmpi(ALLERPin(1).erpname,'No ERPset loaded')
                    try
                        cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                        close(gui_erp_waviewer.Window);
                    catch
                    end
                    assignin('base','ALLERPwaviewer',[]);
                    return;
                end
            end
            
            if isempty(Selected_erpset) || Selected_erpset> length(ALLERPin)
                Selected_erpset =  length(ALLERPin);
            end
            if isempty(CURRENTERPStudio) || CURRENTERPStudio> length(ALLERPin)
                CURRENTERPStudio =  Selected_erpset(1);
                ERPwaviewer_apply.PageIndex=1;
            end
            
            
            ERPwaveview_erpsetops.ALLERP = ALLERPin;
            ERPwaveview_erpsetops.ERP = ALLERPin(CURRENTERPStudio);
            ERPwaveview_erpsetops.CURRENTERP = CURRENTERPStudio;
            ERPwaveview_erpsetops.SelectERPIdx = Selected_erpset;
            ERPwaveview_erpsetops.PageIndex = ERPwaviewer_apply.PageIndex;
            ERPwaveview_erpsetops.ERPLABFlag = 1;
            ERPdatasets = getERPDatasets(ALLERPin); % Get datasets from ALLERP
            ERPdatasets = sortdata(ERPdatasets);
            dsnames = {};
            if size(ERPdatasets,1)==1
                if strcmp(ERPdatasets{1},'No ERPset loaded')
                    dsnames = {''};
                else
                    dsnames{1} = strcat(num2str(cell2mat(ERPdatasets(1,2))),'.',32,ERPdatasets{1,1});
                end
            else
                for Numofsub = 1:size(ERPdatasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
                end
            end
            
            ds_length = size(ERPdatasets,1);
            if ds_length<=2
                ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
            else
                ERPwaveview_erpsetops.butttons_datasets.Max = ds_length;
            end
            ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
            ERPwaveview_erpsetops.butttons_datasets.Value = Selected_erpset;
        else
            return;
        end
        
        ERPwaviewer_apply.ALLERP = ALLERPin;
        ERPwaviewer_apply.ERP = ALLERPin(CURRENTERPStudio);
        ERPwaviewer_apply.SelectERPIdx =Selected_erpset;
        ERPwaviewer_apply.CURRENTERP = CURRENTERPStudio;
        %         ERPwaviewer_apply.PageIndex = 1;
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
        ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        erpworkingmemory('ERPLAB_ERPWaviewer',0);
        ERPset_apply();
    end

% called datasets = sortdata(datasets), sorts datasets in order based on
% parents
    function varargout = sortdata(data)
        cinds = [];
        ndata = {}; % Sorted data
        it = 1; % Iterator for row
        for i = data' % Iterate thru all datasets
            if cell2mat(i(3)) == 0 % Find base datasets (child of 0 means it's not reliant on another dataset)
                [~, ic] = size(cinds);
                cinds(1, ic+1) = cell2mat(i(2)); % Append dataset number to list of current indexes
                ndata(it,:) = i'; % Put it in
                it = it + 1;
            end
        end
        
        cond = true;
        while cond
            ninds = []; % Reset new indexes
            for i = data' % Iterate thru all data
                for j = cinds % Iterate thru all parents
                    if cell2mat(i(3)) == j % Check to see if every datapoint is a child of the current layer
                        [~, nic] = size(ninds);
                        ninds(1, nic+1) = cell2mat(i(2)); % Append dataset number to the next round of parents
                        [ndr, ~] = size(ndata);
                        for v = 1:ndr
                            if cell2mat(ndata(v, 2)) == j
                                ndata(v+2:end+1,:) = ndata(v+1:end,:);
                                ndata(v+1,:) = i';
                            end
                        end
                    end
                end
            end
            [~, nic] = size(ninds);
            if nic == 0 % If we've gone thru all of them, there should be no new indexes
                cond = false;
            end
            clear cinds
            cinds = ninds; % Start again with ninds
        end
        varargout{1} = ndata;
    end


%----------------------Get the information of the updated ERPsets----------
    function ERPdatasets = getERPDatasets(ALLERP)
        ERPdatasets = {};
        if isempty(ALLERP)
            beep;
            disp('f_ERPsets_waveviewer_GUI>getERPDatasets error: ALLERP is empty.');
            return;
        end
        for Numoferpset = 1:length(ALLERP)
            ERPdatasets{Numoferpset,1} = ALLERP(Numoferpset).erpname;
            ERPdatasets{Numoferpset,2} = Numoferpset;
            ERPdatasets{Numoferpset,3} = 0;
            ERPdatasets{Numoferpset,4} = ALLERP(Numoferpset).filename;
            ERPdatasets{Numoferpset,5} = ALLERP(Numoferpset).filepath;
        end
    end


%%-------------------------------Help--------------------------------------
    function erpset_help(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        changeFlag =  estudioworkingmemory('MyViewer_ERPsetpanel');
        if changeFlag~=1
            return;
        end
        MessageViewer= char(strcat('ERPsets > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n ERPsets > Cancel-f_ERPsets_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
        ALLERPin = ERPwaviewer_apply.ALLERP;
        ERPdatasets = getERPDatasets(ALLERPin); % Get datasets from ALLERP
        ERPdatasets = sortdata(ERPdatasets);
        dsnames = {};
        if size(ERPdatasets,1)==1
            if strcmp(ERPdatasets{1},'No ERPset loaded')
                dsnames = {''};
            else
                dsnames{1} = strcat(num2str(cell2mat(ERPdatasets(1,2))),'.',32,ERPdatasets{1,1});
            end
        else
            for Numofsub = 1:size(ERPdatasets,1)
                dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
            end
        end
        
        ds_length = size(ERPdatasets,1);
        if ds_length<=2
            ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
        else
            ERPwaveview_erpsetops.butttons_datasets.Max = ds_length;
        end
        ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
        Selected_erpset =  ERPwaviewer_apply.SelectERPIdx;
        if min(Selected_erpset(:))<=0 || max(Selected_erpset(:)) > length(ALLERPin)
            Selected_erpset =  length(ALLERPin);
            ERPwaviewer_apply.SelectERPIdx = Selected_erpset;
            assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
            f_redrawERP_viewer_test();%%Plot the waves
        end
        ERPwaveview_erpsetops.butttons_datasets.Value = Selected_erpset;
        
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
        ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        MessageViewer= char(strcat('ERPsets > Cancel'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end

%%------------------------------Apply--------------------------------------
    function ERPset_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        MessageViewer= char(strcat('ERPsets > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n ERPsets > Apply-f_ERPsets_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        if ERPwaveview_erpsetops.ERPLABFlag==1
            ERPwaviewer_apply.ALLERP =  ERPwaveview_erpsetops.ALLERP;
            ERPwaviewer_apply.ERP =        ERPwaveview_erpsetops.ERP;
            ERPwaviewer_apply.CURRENTERP=      ERPwaveview_erpsetops.CURRENTERP;
            ERPwaviewer_apply.SelectERPIdx=    ERPwaveview_erpsetops.SelectERPIdx;
            ERPwaviewer_apply.PageIndex=   ERPwaveview_erpsetops.PageIndex;
            ERPwaveview_erpsetops.ERPLABFlag=0;
        end
        ERPsetArray =  ERPwaveview_erpsetops.butttons_datasets.Value;
        CurrentERP = ERPsetArray(1);
        ALLERPIN = ERPwaviewer_apply.ALLERP;
        for Numofselectederp = 1:numel(ERPsetArray)
            SrateNum_mp(Numofselectederp,1)   =  ALLERPIN(ERPsetArray(Numofselectederp)).srate;
        end
        
        ERPwaviewer_apply.CURRENTERP = CurrentERP;
        ERPwaviewer_apply.ERP = ERPwaviewer_apply.ALLERP(CurrentERP);
        ERPwaviewer_apply.SelectERPIdx = ERPsetArray;
        ERPtooltype = erpgettoolversion('tooltype');
        if strcmpi(ERPtooltype,'EStudio')
            Geterpbinchan = estudioworkingmemory('geterpbinchan');
            if ~isempty(Geterpbinchan)
                CurrentERPIndex = Geterpbinchan.Select_index;
                chan_bin = Geterpbinchan.bins_chans(CurrentERPIndex);
                if chan_bin ==1
                    ERPwaviewer_apply.plot_org.Grid =2;
                    ERPwaviewer_apply.plot_org.Overlay=1;
                    ERPwaviewer_apply.plot_org.Pages=3;
                elseif chan_bin==0
                    ERPwaviewer_apply.plot_org.Grid =1;
                    ERPwaviewer_apply.plot_org.Overlay=2;
                    ERPwaviewer_apply.plot_org.Pages=3;
                end
            end
            %%% we may need to get the grid layout automatically
        end
        
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
        ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
        f_redrawERP_viewer_test();%%Plot the waves
        MessageViewer= char(strcat('ERPsets > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end


%%------------Update this panel based on the imported parameters-----------
    function loadproper_change(~,~)
        if viewer_ERPDAT.loadproper_count ~=1
            return;
        end
        try
            ERPwaviewer_up = evalin('base','ALLERPwaviewer');
            SelectedIndex = ERPwaviewer_up.SelectERPIdx;
            ALLERPup = ERPwaviewer_up.ALLERP;
            if isempty(ALLERPup)
                beep;
                disp('f_ERPsets_waviewer_GUI()>loadproper_change() error: ALLERP is empty.');
                return;
            end
            if max(SelectedIndex(:))> length(ALLERPup)
                SelectedIndex =length(ALLERPup);
                ERPwaviewer_up.SelectERPIdx = SelectedIndex;
            end
        catch
            beep;
            disp('f_ERPsets_waviewer_GUI()>loadproper_change() error: Restart ERPwave Viewer');
            return;
        end
        
        Enable_label = 'on';
        ERPdatasets = getERPDatasets(ALLERPup); % Get datasets from ALLERP
        ERPdatasets = sortdata(ERPdatasets);
        dsnames = {};
        if size(ERPdatasets,1)==1
            if strcmp(ERPdatasets{1},'No ERPset loaded')
                dsnames = {''};
            else
                dsnames{1} = strcat(num2str(cell2mat(ERPdatasets(1,2))),'.',32,ERPdatasets{1,1});
            end
        else
            for Numofsub = 1:size(ERPdatasets,1)
                dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
            end
        end
        
        ERPwaveview_erpsetops.butttons_datasets.Enable = Enable_label;
        ds_length = length(ERPdatasets);
        ERPwaveview_erpsetops.butttons_datasets.Max = ds_length;
        ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
        ERPwaveview_erpsetops.butttons_datasets.Value = SelectedIndex;
        assignin('base','ALLERPwaviewer',ERPwaviewer_up);
        viewer_ERPDAT.loadproper_count=2;
    end




%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_ERPsetpanel');
        if changeFlag~=1
            return;
        end
        ERPset_apply();
    end


%%Reset this panel with the default parameters
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==1
            ERPtooltype = erpgettoolversion('tooltype');
            if strcmpi(ERPtooltype,'EStudio') || strcmpi(ERPtooltype,'ERPLAB')
                if strcmpi(ERPtooltype,'ERPLAB')
                    try
                        Selected_erpset = evalin('base','CURRENTERP');
                        CURRENTERPStudio = Selected_erpset;
                    catch
                        viewer_ERPDAT.Process_messg =3;
                        fprintf(2,'\n ERPsets error: Cannot get CURRENTERP from Workspace.\n');
                        return;
                    end
                    estudioworkingmemory('PlotOrg_ERPLAB',1);
                end
                try
                    ALLERPin = evalin('base','ALLERP');
                catch
                    viewer_ERPDAT.Process_messg =3;
                    fprintf(2,'\n ERPsets error: Cannot get ALLERP from Workspace.\n');
                    return;
                end
                if isempty(ALLERPin)
                    viewer_ERPDAT.Process_messg =3;
                    try
                        cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                        close(gui_erp_waviewer.Window);
                    catch
                    end
                    assignin('base','ALLERPwaviewer',[]);
                    return;
                end
                
                if strcmpi(ERPtooltype,'EStudio')
                    Selected_erpset= estudioworkingmemory('selectederpstudio');
                    CURRENTERPStudio = observe_ERPDAT.CURRENTERP;
                    if length(ALLERPin)==1 && strcmpi(ALLERPin(1).erpname,'No ERPset loaded')
                        try
                            cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                            close(gui_erp_waviewer.Window);
                        catch
                        end
                        assignin('base','ALLERPwaviewer',[]);
                        return;
                    end
                end
                
                if isempty(Selected_erpset) || Selected_erpset> length(ALLERPin)
                    Selected_erpset =  length(ALLERPin);
                end
                if isempty(CURRENTERPStudio) || CURRENTERPStudio> length(ALLERPin)
                    CURRENTERPStudio =  length(ALLERPin);
                end
                
                [x_index,y_index] = find(Selected_erpset==CURRENTERPStudio);
                if isempty(y_index)
                    y_index = numel(Selected_erpset);
                end
                
                ERPwaveview_erpsetops.ALLERP = ALLERPin;
                ERPwaveview_erpsetops.ERP = ALLERPin(CURRENTERPStudio);
                ERPwaveview_erpsetops.CURRENTERP = CURRENTERPStudio;
                ERPwaveview_erpsetops.SelectERPIdx = Selected_erpset;
                ERPwaveview_erpsetops.PageIndex = y_index;
                ERPwaveview_erpsetops.ERPLABFlag = 1;
                
                ERPdatasets = getERPDatasets(ALLERPin); % Get datasets from ALLERP
                ERPdatasets = sortdata(ERPdatasets);
                dsnames = {};
                if size(ERPdatasets,1)==1
                    if strcmp(ERPdatasets{1},'No ERPset loaded')
                        dsnames = {''};
                    else
                        dsnames{1} = strcat(num2str(cell2mat(ERPdatasets(1,2))),'.',32,ERPdatasets{1,1});
                    end
                else
                    for Numofsub = 1:size(ERPdatasets,1)
                        dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
                    end
                end
                
                ds_length = size(ERPdatasets,1);
                if ds_length<=2
                    ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
                else
                    ERPwaveview_erpsetops.butttons_datasets.Max = ds_length;
                end
                ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
                ERPwaveview_erpsetops.butttons_datasets.Value = Selected_erpset;
            else
                ERPwaveview_erpsetops.auto.Value = 0;
                ERPwaveview_erpsetops.custom.Value =1;
                ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
                ERPwaveview_erpsetops.auto.Enable = 'off';
            end
            try
                ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
            catch
                ERPwaviewer_apply = [];
            end
            ERPwaviewer_apply.ALLERP =  ERPwaveview_erpsetops.ALLERP;
            ERPwaviewer_apply.ERP =        ERPwaveview_erpsetops.ERP;
            ERPwaviewer_apply.CURRENTERP=      ERPwaveview_erpsetops.CURRENTERP;
            ERPwaviewer_apply.SelectERPIdx=    ERPwaveview_erpsetops.SelectERPIdx;
            ERPwaviewer_apply.PageIndex=   ERPwaveview_erpsetops.PageIndex;
            ERPwaviewer_apply.erp_binchan_op = ERPwaveview_erpsetops.auto.Value;
            ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
            ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
            ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
            
            assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
            viewer_ERPDAT.Reset_Waviewer_panel=2;
        end
    end


%%change the ERPset indeces when they are changed in Plot organization panel
    function ERPset_Chan_bin_label_change(~,~)
        if viewer_ERPDAT.ERPset_Chan_bin_label~=1  %% 1 means ERPset indeces were changed
            if viewer_ERPDAT.ERPset_Chan_bin_label==2%%Update Viewer based on the change in ERPLAB
                erpselect_refresh();
            end
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n ERPsets > f_ERPsets_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        ERPsetArray = ERPwaviewer_apply.SelectERPIdx;
        if max(ERPsetArray(:)) <= length(ERPwaveview_erpsetops.butttons_datasets.String)
            ERPwaveview_erpsetops.butttons_datasets.Value = ERPsetArray;
        end
    end

%%execute this panel when press "return" or "Enter"
    function ERPset_keypress(hObject, eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            ERPset_apply();
        else
            return;
        end
    end
end