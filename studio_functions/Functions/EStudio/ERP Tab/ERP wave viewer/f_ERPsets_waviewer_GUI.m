% ERP Viewer for EStudio Toolbox
%
% Author: Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 && Nov. 2023

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
addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);


ERPwaveview_erpsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------
% gui_erp_waviewer.Window.WindowButtonMotionFcn = {@erpselect_refresh};
try
    [version reldate,ColorBviewer_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
catch
    ColorBviewer_def = [0.7765    0.7294    0.8627];
end

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

drawui_erpsetbinchan_viewer(FonsizeDefault)

% Draw the ui
    function drawui_erpsetbinchan_viewer(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        catch
            ColorBviewer_def =  [0.7765    0.7294    0.8627];
        end
        ALLERP = gui_erp_waviewer.ERPwaviewer.ALLERP;
        ERPdatasets = getERPDatasets(ALLERP); % Get datasets from ALLERP
        
        try
            SelectedIndex = gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
        catch
            SelectedIndex =length(ALLERP);
        end
        if any(SelectedIndex(:)> length(ALLERP))
            SelectedIndex =length(ALLERP);
        end
        
        ERPwaveview_erpsetops.vBox = uiextras.VBox('Parent', ERPsets_waveviewer_box, 'Spacing', 5,'BackgroundColor',ColorBviewer_def); % VBox for everything
        %%-----------------------Display tthe selected ERPsets---------------------------------------
        panelshbox = uiextras.HBox('Parent', ERPwaveview_erpsetops.vBox, 'Spacing', 5,'BackgroundColor',ColorBviewer_def);
        dsnames = {};
        for Numofsub = 1:size(ERPdatasets,1)
            dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
        end
        ds_length = length(ERPdatasets);
        ERPwaveview_erpsetops.butttons_datasets = uicontrol('Parent', panelshbox, 'Style', 'listbox', 'min', 1,'max',...
            ds_length,'String', dsnames,'Value', SelectedIndex,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable','on','BackgroundColor',[1 1 1]);
        ERPwaveview_erpsetops.butttons_datasets.KeyPressFcn = @ERPset_keypress;
        %%Help and apply
        ERPwaveview_erpsetops.help_apply_title = uiextras.HBox('Parent', ERPwaveview_erpsetops.vBox,'BackgroundColor',ColorBviewer_def);
        
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title );
        ERPwaveview_erpsetops.erpset_cancel = uicontrol('Style','pushbutton','Parent', ERPwaveview_erpsetops.help_apply_title  ,'String','Cancel',...
            'callback',@erpset_cancel,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title  );
        ERPwaveview_erpsetops.erpset_apply = uicontrol('Style','pushbutton','Parent',ERPwaveview_erpsetops.help_apply_title  ,'String','Apply',...
            'callback',@ERPset_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title );
        set(ERPwaveview_erpsetops.help_apply_title ,'Sizes',[40 70 20 70 20]);
        set(ERPwaveview_erpsetops.vBox, 'Sizes', [290 25]);
        ERPwaveview_erpsetops.ERPLABFlag = 0;
        gui_erp_waviewer.ERPwaviewer.SelectERPIdx = ERPwaveview_erpsetops.butttons_datasets.Value;
        
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------select the ERPset of interest--------------------------
    function selectdata(Source,EventData)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        %%check if  the sampling rate or time range is the same across
        %%selected ERPsets-------2023 Dec.
        ERPSetArray = Source.Value;
        if numel(ERPSetArray)>1
            ERPSetArraydef= gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
            for ii = 1:numel(ERPSetArray)
                sratearray(ii) = viewer_ERPDAT.ALLERP(ERPSetArray(ii)).srate;
                samplearray(ii) = viewer_ERPDAT.ALLERP(ERPSetArray(ii)).pnts;
                erpstartarray(ii) = viewer_ERPDAT.ALLERP(ERPSetArray(ii)).xmin;
                erpendarray(ii) = viewer_ERPDAT.ALLERP(ERPSetArray(ii)).xmax;
            end
            
            sratearray = unique(sratearray);
            if numel(sratearray)>1
                Source.Value=ERPSetArraydef;
                msgboxText = ['You cannot select these ERPsets at the same time because they differ in timing parameters (sampling rate, prestimulus period, and/or epoch length).\n'...
                    'You can equate the temporal parameters using the Resample ERPsets panel in ERPLAB Studio.'];
                title = 'ERPLAB Studio: Advanced Wave Viewer>ERPsets';
                errorfound(sprintf(msgboxText), title);
                viewer_ERPDAT.Count_currentERP = 2;
                return;
            end
            samplearray = unique(samplearray);
            if numel(samplearray)>1
                Source.Value=ERPSetArraydef;
                msgboxText = ['You cannot select these ERPsets at the same time because they differ in timing parameters (sampling rate, prestimulus period, and/or epoch length).\n'...
                    'You can equate the temporal parameters using the Resample ERPsets panel in ERPLAB Studio.'];
                title = 'ERPLAB Studio: Advanced Wave Viewer>ERPsets';
                errorfound(sprintf(msgboxText), title);
                return;
            end
            erpstartarray = unique(erpstartarray);
            if numel(erpstartarray)>1
                Source.Value=ERPSetArraydef;
                msgboxText = ['You cannot select these ERPsets at the same time because they differ in timing parameters (sampling rate, prestimulus period, and/or epoch length).\n'...
                    'You can equate the temporal parameters using the Resample ERPsets panel in ERPLAB Studio.'];
                title = 'ERPLAB Studio: Advanced Wave Viewer>ERPsets';
                errorfound(sprintf(msgboxText), title);
                return;
            end
            erpendarray = unique(erpendarray);
            if numel(erpendarray)>1
                Source.Value=ERPSetArraydef;
                msgboxText = ['You cannot select these ERPsets at the same time because they differ in timing parameters (sampling rate, prestimulus period, and/or epoch length).\n'...
                    'You can equate the temporal parameters using the Resample ERPsets panel in ERPLAB Studio.'];
                title = 'ERPLAB Studio: Advanced Wave Viewer>ERPsets';
                errorfound(sprintf(msgboxText), title);
                return;
            end
        end
        
        estudioworkingmemory('MyViewer_ERPsetpanel',1);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [0.4940 0.1840 0.5560];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [1 1 1];
        ERPsets_waveviewer_box.TitleColor= [0.4940 0.1840 0.5560];
        ERPwaveview_erpsetops.erpset_cancel.BackgroundColor = [0.4940 0.1840 0.5560];
        ERPwaveview_erpsetops.erpset_cancel.ForegroundColor = [1 1 1];
    end


%%-------------------------------Help--------------------------------------
    function erpset_cancel(~,~)
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
        
        ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
        ALLERPin = gui_erp_waviewer.ERPwaviewer.ALLERP;
        ERPdatasets = getERPDatasets(ALLERPin); % Get datasets from ALLERP
        dsnames = {};
        for Numofsub = 1:size(ERPdatasets,1)
            dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
        end
        
        ds_length = size(ERPdatasets,1);
        ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
        ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
        ERPArray =  gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
        if isempty(ERPArray)|| min(ERPArray(:))<=0 || any(ERPArray(:) > length(ALLERPin))
            ERPArray =  length(ALLERPin);
            gui_erp_waviewer.ERPwaviewer.SelectERPIdx = ERPArray;
            gui_erp_waviewer.ERPwaviewer.CURRENTERP = ERPArray;
            gui_erp_waviewer.ERPwaviewer.ERP = gui_erp_waviewer.ERPwaviewer.ALLERP(ERPArray);
            gui_erp_waviewer.ERPwaviewer.PageIndex=1;
            ERPwaveview_erpsetops.butttons_datasets.Value = ERPArray;
            viewer_ERPDAT.Count_currentERP = 2;
        end
        ERPwaveview_erpsetops.butttons_datasets.Value = ERPArray;
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
        ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        ERPwaveview_erpsetops.erpset_cancel.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_cancel.ForegroundColor = [0 0 0];
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
        
        ERPsetArray =  ERPwaveview_erpsetops.butttons_datasets.Value;
        CurrentERP = ERPsetArray(1);
        ALLERPIN = gui_erp_waviewer.ERPwaviewer.ALLERP;
        for Numofselectederp = 1:numel(ERPsetArray)
            SrateNum_mp(Numofselectederp,1)   =  ALLERPIN(ERPsetArray(Numofselectederp)).srate;
        end
        
        %         ERPtooltype = erpgettoolversion('tooltype');
        %         if strcmpi(ERPtooltype,'EStudio')
        %             ERPTab_plotset_pars = estudioworkingmemory('ERPTab_plotset_pars');
        %             try chan_bin =ERPTab_plotset_pars{7};catch chan_bin=1; end;
        %             if isempty(chan_bin) || numel(chan_bin)~=1  || (chan_bin~=1 && chan_bin~=2)
        %                 chan_bin=1;
        %             end
        %             if chan_bin ==1
        %                 gui_erp_waviewer.ERPwaviewer.plot_org.Grid =2;
        %                 gui_erp_waviewer.ERPwaviewer.plot_org.Overlay=1;
        %                 gui_erp_waviewer.ERPwaviewer.plot_org.Pages=3;
        %             elseif chan_bin==2
        %                 gui_erp_waviewer.ERPwaviewer.plot_org.Grid =1;
        %                 gui_erp_waviewer.ERPwaviewer.plot_org.Overlay=2;
        %                 gui_erp_waviewer.ERPwaviewer.plot_org.Pages=3;
        %             end
        %         end
        gui_erp_waviewer.ERPwaviewer.CURRENTERP = CurrentERP;
        gui_erp_waviewer.ERPwaviewer.ERP = gui_erp_waviewer.ERPwaviewer.ALLERP(CurrentERP);
        gui_erp_waviewer.ERPwaviewer.SelectERPIdx = ERPwaveview_erpsetops.butttons_datasets.Value;
        
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
        ERPwaveview_erpsetops.erpset_cancel.BackgroundColor = [1 1 1];
        ERPwaveview_erpsetops.erpset_cancel.ForegroundColor = [0 0 0];
        ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
        
        viewer_ERPDAT.Count_currentERP = 2;
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
            SelectedIndex = gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
            ALLERPup = gui_erp_waviewer.ERPwaviewer.ALLERP;
            if isempty(ALLERPup)
                beep;
                disp('f_ERPsets_waviewer_GUI()>loadproper_change() error: ALLERP is empty.');
                return;
            end
            if max(SelectedIndex(:))> length(ALLERPup)
                SelectedIndex =length(ALLERPup);
                gui_erp_waviewer.ERPwaviewer.SelectERPIdx = SelectedIndex;
            end
        catch
            beep;
            disp('f_ERPsets_waviewer_GUI()>loadproper_change() error: Restart ERPwave Viewer');
            return;
        end
        
        Enable_label = 'on';
        ERPdatasets = getERPDatasets(ALLERPup); % Get datasets from ALLERP
        dsnames = {};
        for Numofsub = 1:size(ERPdatasets,1)
            dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
        end
        
        ERPwaveview_erpsetops.butttons_datasets.Enable = Enable_label;
        ds_length = length(ERPdatasets);
        ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
        ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
        ERPwaveview_erpsetops.butttons_datasets.Value = SelectedIndex;
        
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


%%Reset this panel with the default parameters
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==1
            ERPtooltype = erpgettoolversion('tooltype');
            if strcmpi(ERPtooltype,'EStudio') || strcmpi(ERPtooltype,'ERPLAB')
                if strcmpi(ERPtooltype,'ERPLAB')
                    try
                        ERPArray = evalin('base','CURRENTERP');
                        CURRENTERPStudio = ERPArray;
                    catch
                        viewer_ERPDAT.Process_messg =3;
                        fprintf(2,'\n ERPsets error: Cannot get CURRENTERP from Workspace.\n');
                        return;
                    end
                    estudioworkingmemory('PlotOrg_ERPLAB',1);
                else
                    ERPArray=  gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
                    CURRENTERPStudio = gui_erp_waviewer.ERPwaviewer.CURRENTERP;
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
                    return;
                end
                
                if isempty(ERPArray) || any(ERPArray(:)> length(ALLERPin))
                    ERPArray =  length(ALLERPin);
                end
                if isempty(CURRENTERPStudio) || any(CURRENTERPStudio> length(ALLERPin))
                    CURRENTERPStudio =  length(ALLERPin);
                end
                
                [x_index,y_index] = find(ERPArray==CURRENTERPStudio);
                if isempty(y_index)
                    y_index = numel(ERPArray);
                end
                ERPwaveview_erpsetops.ALLERP = ALLERPin;
                ERPwaveview_erpsetops.ERP = ALLERPin(CURRENTERPStudio);
                ERPwaveview_erpsetops.CURRENTERP = CURRENTERPStudio;
                ERPwaveview_erpsetops.SelectERPIdx = ERPArray;
                ERPwaveview_erpsetops.PageIndex = y_index;
                ERPwaveview_erpsetops.ERPLABFlag = 1;
                
                ERPdatasets = getERPDatasets(ALLERPin); % Get datasets from ALLERP
                dsnames = {};
                for Numofsub = 1:size(ERPdatasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(cell2mat(ERPdatasets(Numofsub,2))),'.',32,ERPdatasets{Numofsub,1}));
                end
                ds_length = size(ERPdatasets,1);
                
                ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
                ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
                ERPwaveview_erpsetops.butttons_datasets.Value = ERPArray;
            else
                ERPwaveview_erpsetops.auto.Value = 0;
                ERPwaveview_erpsetops.custom.Value =1;
                ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
                ERPwaveview_erpsetops.auto.Enable = 'off';
            end
            
            gui_erp_waviewer.ERPwaviewer.ALLERP =  ERPwaveview_erpsetops.ALLERP;
            gui_erp_waviewer.ERPwaviewer.ERP =        ERPwaveview_erpsetops.ERP;
            gui_erp_waviewer.ERPwaviewer.CURRENTERP=      ERPwaveview_erpsetops.CURRENTERP;
            gui_erp_waviewer.ERPwaviewer.SelectERPIdx=    ERPwaveview_erpsetops.SelectERPIdx;
            gui_erp_waviewer.ERPwaviewer.PageIndex=   ERPwaveview_erpsetops.PageIndex;
            ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
            ERPwaveview_erpsetops.erpset_apply.ForegroundColor = [0 0 0];
            ERPsets_waveviewer_box.TitleColor= [0.5 0.5 0.9];
            viewer_ERPDAT.Reset_Waviewer_panel=2;
        end
    end


%%---------------------current ERPset change-------------------------------
    function v_currentERP_change(~,~)
        if viewer_ERPDAT.Count_currentERP~=1
            return;
        end
        
        ERPsetArray = gui_erp_waviewer.ERPwaviewer.SelectERPIdx;
        if isempty(ERPsetArray) || any(ERPsetArray(:) > length(ERPwaveview_erpsetops.butttons_datasets.String))
            ERPsetArray = length(ERPwaveview_erpsetops.butttons_datasets.String);
            ERPwaveview_erpsetops.butttons_datasets.Value = ERPsetArray;
            gui_erp_waviewer.ERPwaviewer.CURRENTERP = ERPsetArray;
            gui_erp_waviewer.ERPwaviewer.ERP = gui_erp_waviewer.ERPwaviewer.ALLERP(ERPsetArray);
            gui_erp_waviewer.ERPwaviewer.PageIndex=1;
            ERPwaveview_erpsetops.butttons_datasets.Value = ERPsetArray;
        end
        gui_erp_waviewer.ERPwaviewer.SelectERPIdx =ERPsetArray;
        viewer_ERPDAT.Count_currentERP=2;
        f_redrawERP_viewer_test();
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