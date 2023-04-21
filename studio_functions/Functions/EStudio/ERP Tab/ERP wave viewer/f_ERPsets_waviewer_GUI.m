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
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);
% addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
% addlistener(viewer_ERPDAT,'Process_messg_change',@Process_messg_change);
addlistener(observe_ERPDAT,'Two_GUI_change',@Two_GUI_change);
ERPwaveview_erpsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------

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

drawui_erpsetbinchan_viewer(ERPdatasets,ERPwaviewer)

varargout{1} = ERPsets_waveviewer_box;

% Draw the ui
    function drawui_erpsetbinchan_viewer(ERPdatasets,ERPwaviewer)
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
        ERPtooltype = erpgettoolversion('tooltype');
        if ~strcmpi(ERPtooltype,'EStudio') && ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaviewer.erp_binchan_op = 0;
        end
        
        try
            Enable_auto =  ERPwaviewer.erp_binchan_op;
        catch
            Enable_auto =  1;
        end
        
        if Enable_auto ==1
            Enable_label = 'off';
        elseif Enable_auto ==0
            Enable_label = 'on';
        end
        %%---------------------Options for selecting ERPsets-----------------------------------------------------
        ERPwaveview_erpsetops.opts_title = uiextras.HBox('Parent', ERPwaveview_erpsetops.vBox, 'Spacing', 5,'BackgroundColor',ColorBviewer_def);
        ERPwaveview_erpsetops.auto = uicontrol('Style', 'radiobutton','Parent', ERPwaveview_erpsetops.opts_title,...
            'String',' ','callback',@erpselect_auto,'Value',Enable_auto,'Enable','on','FontSize',12,'BackgroundColor',ColorBviewer_def);
        
        ERPwaveview_erpsetops.custom = uicontrol('Style', 'radiobutton','Parent', ERPwaveview_erpsetops.opts_title,...
            'String','Custom','callback',@erpselect_custom,'Value',~Enable_auto,'Enable','on','FontSize',12,'BackgroundColor',ColorBviewer_def);
        
        if strcmpi(ERPtooltype,'EStudio')
            ERPwaveview_erpsetops.auto.String = 'Same as EStudio';
        elseif  strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_erpsetops.auto.String = 'Same as ERPLAB';
            set(ERPwaveview_erpsetops.opts_title,'Sizes',[130 90]);
        else
            ERPwaveview_erpsetops.auto.String = '';
            ERPwaveview_erpsetops.auto.Enable = 'off';
            ERPwaveview_erpsetops.custom.String = '';
            ERPwaveview_erpsetops.custom.Enable = 'off';
        end
        
        
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
            ds_length,'String', dsnames,'Value', SelectedIndex,'Callback',@selectdata,'FontSize',12,'Enable',Enable_label);
        %%Help and apply
        ERPwaveview_erpsetops.help_apply_title = uiextras.HBox('Parent', ERPwaveview_erpsetops.vBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title );
        uicontrol('Style','pushbutton','Parent', ERPwaveview_erpsetops.help_apply_title  ,'String','Cancel',...
            'callback',@erpset_help,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title  );
        ERPwaveview_erpsetops.erpset_apply = uicontrol('Style','pushbutton','Parent',ERPwaveview_erpsetops.help_apply_title  ,'String','Apply',...
            'callback',@ERPset_apply,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',ERPwaveview_erpsetops.help_apply_title );
        set(ERPwaveview_erpsetops.help_apply_title ,'Sizes',[40 70 20 70 20]);
        set(ERPwaveview_erpsetops.vBox, 'Sizes', [20 190 25]);
        ERPwaveview_erpsetops.ERPLABFlag = 0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------select the ERPset of interest--------------------------
    function selectdata(source,EventData)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            ERPsetindex =  ERPwaviewerIN.SelectERPIdx;
            if max(ERPsetindex) > length(source.String)
                ERPsetindex = length(source.String);
            end
            source.Value = ERPsetindex;
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_ERPsetpanel',1);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [0.5569    0.9373    0.8902];
    end


%%---------------Setting for auto option-----------------------------------
    function erpselect_auto(source,~)
        
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            ERPsetop =  ERPwaviewerIN.erp_binchan_op;
            ERPwaveview_erpsetops.auto.Value = ERPsetop;
            ERPwaveview_erpsetops.custom.Value =~ERPsetop;
            ERPwaveview_erpsetops.auto.Value = ERPsetop;
            ERPwaveview_erpsetops.custom.Value =~ERPsetop;
            viewer_ERPDAT.Process_messg =4;
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            return;
        end
        ERPtooltype = erpgettoolversion('tooltype');
        estudioworkingmemory('MyViewer_ERPsetpanel',1);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [0.5569    0.9373    0.8902];
        
        BackERPLABcolor1 = [1 0.9 0.3];    % yellow
        question1 = ['Are you sure to use the same ERPsets as',32, ERPtooltype,'?\n If so, the current ERPsets will be overwritten.'];
        title1 = 'ERP Wave Viewer>ERPsets';
        oldcolor1 = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor1)
        button1 = questdlg(sprintf(question1), title1,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor1);
        
        MessageViewer= char(strcat('ERPsets>" Same as',32,ERPtooltype,32,'"'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        if strcmpi(ERPtooltype,'EStudio') || strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_erpsetops.auto.Value = 1;
            ERPwaveview_erpsetops.custom.Value =0;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'off';
        else
            ERPwaveview_erpsetops.auto.Value = 0;
            ERPwaveview_erpsetops.custom.Value =1;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
            ERPwaveview_erpsetops.auto.Enable = 'off';
            ERPwaveview_erpsetops.custom.Enable = 'off';
        end
        
        if strcmpi(button1,'Yes')
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
                
                
                MessageViewer= char(strcat('ERPsets>" Same as',32,ERPtooltype,32,'"'));
                erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
                viewer_ERPDAT.Process_messg =2;
            else
                ERPwaveview_erpsetops.auto.Value = 0;
                ERPwaveview_erpsetops.custom.Value =1;
                ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
                ERPwaveview_erpsetops.auto.Enable = 'off';
            end
        else
            ERPwaveview_erpsetops.auto.Value = 0;
            ERPwaveview_erpsetops.custom.Value =1;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
            estudioworkingmemory('MyViewer_ERPsetpanel',0);
            ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
            return;
        end
    end

%%---------------Setting for custom option---------------------------------
    function erpselect_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            ERPsetop =  ERPwaviewerIN.erp_binchan_op;
            ERPwaveview_erpsetops.auto.Value = ~ERPsetop;
            ERPwaveview_erpsetops.custom.Value =ERPsetop;
            ERPwaveview_erpsetops.auto.Value = ERPsetop;
            ERPwaveview_erpsetops.custom.Value =~ERPsetop;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        
        estudioworkingmemory('MyViewer_ERPsetpanel',1);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [0.5569    0.9373    0.8902];
        ERPtooltype = erpgettoolversion('tooltype');
        if  ~strcmpi(ERPtooltype,'EStudio') && ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_erpsetops.auto.Value = 0;
            ERPwaveview_erpsetops.custom.Value =1;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
            ERPwaveview_erpsetops.auto.Enable = 'off';
        else
            ERPwaveview_erpsetops.auto.Value = 0;
            ERPwaveview_erpsetops.custom.Value =1;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
        end
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
        changeFlag =  estudioworkingmemory('MyViewer_ERPsetpanel');
        if changeFlag~=1
            return;
        end
        
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n ERPsets > Cancel-f_ERPsets_waviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        ERPwaveview_erpsetops.ERPLABFlag=0;
        
        ERP_OP = ERPwaviewer_apply.erp_binchan_op;
        if ERP_OP ==1
            ERPwaveview_erpsetops.auto.Value = 1;
            ERPwaveview_erpsetops.custom.Value =0;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'off';
        else
            ERPwaveview_erpsetops.auto.Value = 0;
            ERPwaveview_erpsetops.custom.Value =1;
            ERPwaveview_erpsetops.butttons_datasets.Enable = 'on';
        end
        
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
    end

%%------------------------------Apply--------------------------------------
    function ERPset_apply(~,~)
        %%check if the changes were saved for the other panels.
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=1
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            viewer_ERPDAT.Process_messg =4;
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            return;
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
        if numel(unique(SrateNum_mp))>1
            MessageViewer= char(strcat('Warning:Sampling rate varies across the selected ERPsets, we therefore set "ERPsets" to be "Pages".'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =4;
            %%
            MessageViewer= char(strcat('ERPsets > Apply'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        end
        
        ERPwaviewer_apply.CURRENTERP = CurrentERP;
        ERPwaviewer_apply.ERP = ERPwaviewer_apply.ALLERP(CurrentERP);
        ERPwaviewer_apply.SelectERPIdx = ERPsetArray;
        ERPwaviewer_apply.erp_binchan_op = ERPwaveview_erpsetops.auto.Value;
        
        if ERPwaveview_erpsetops.auto.Value ==1
            Geterpbinchan = estudioworkingmemory('geterpbinchan');
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
            %%% we may need to get the grid layout automatically
        end
        
        estudioworkingmemory('MyViewer_ERPsetpanel',0);
        ERPwaveview_erpsetops.erpset_apply.BackgroundColor = [1 1 1];
        
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
        viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
        
        f_redrawERP_viewer_test();%%Plot the waves
        MessageViewer= char(strcat('ERPsets > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =2;
    end


%%------------Update this panel based on the imported parameters-----------
    function count_loadproper_change(~,~)
        if viewer_ERPDAT.count_loadproper ==0
            return;
        end
        try
            ERPwaviewer_up = evalin('base','ALLERPwaviewer');
            SelectedIndex = ERPwaviewer_up.SelectERPIdx;
            ALLERPup = ERPwaviewer_up.ALLERP;
            if isempty(ALLERPup)
                beep;
                disp('f_ERPsets_waviewer_GUI()>count_loadproper_change() error: ALLERP is empty.');
                return;
            end
            if max(SelectedIndex(:))> length(ALLERPup)
                SelectedIndex =length(ALLERPup);
                ERPwaviewer_up.SelectERPIdx = SelectedIndex;
            end
        catch
            beep;
            disp('f_ERPsets_waviewer_GUI()>count_loadproper_change() error: Restart ERPwave Viewer');
            return;
        end
        
        ERPtooltype = erpgettoolversion('tooltype');
        if isempty(ERPtooltype)
            ERPtooltype = 'MyViewer';
            erpgettoolversion('tooltype','MyViewer');
        end
        if ~strcmpi(ERPtooltype,'EStudio') && ~strcmpi(ERPtooltype,'ERPLAB')
            ERPwaviewer_up.erp_binchan_op = 0;
        end
        try
            Enable_auto =  ERPwaviewer_up.erp_binchan_op;
        catch
            Enable_auto =  1;
            ERPwaviewer_up.erp_binchan_op = 1;
        end
        if Enable_auto ==1
            Enable_label = 'off';
        elseif Enable_auto ==0
            Enable_label = 'on';
        end
        ERPwaveview_erpsetops.auto.Value = Enable_auto;
        ERPwaveview_erpsetops.custom.Value=~Enable_auto;
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
        if strcmpi(ERPtooltype,'EStudio')
            ERPwaveview_erpsetops.auto.String = 'Same as EStudio';
        elseif  strcmpi(ERPtooltype,'ERPLAB')
            ERPwaveview_erpsetops.auto.String = 'Same as ERPLAB';
        else
            ERPwaveview_erpsetops.auto.String = '';
            ERPwaveview_erpsetops.auto.Enable = 'off';
            ERPwaveview_erpsetops.custom.String = '';
            ERPwaveview_erpsetops.custom.Enable = 'off';
        end
        assignin('base','ALLERPwaviewer',ERPwaviewer_up);
    end



%%change this panel based on the chaneges of main EStudio
    function Two_GUI_change(~,~)
        
        try
            ERPAutoValue = ERPwaveview_erpsetops.auto.Value;
        catch
            return;
        end
        
        if isempty(observe_ERPDAT.ALLERP)
            try
                cprintf('red',['\n ERP Wave viewer will be closed because ALLERP is empty.\n\n']);
                close(gui_erp_waviewer.Window);
            catch
            end
            assignin('base','ALLERPwaviewer',[]);
            return;
        end
        
        if ERPAutoValue ==1
            MessageViewer= char(strcat('Update "ERP wave Viewer"'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =1;
            
            ALLERPStudio = observe_ERPDAT.ALLERP;
            if isempty(ALLERPStudio) || (length(ALLERPStudio)==1&& strcmpi(ALLERPStudio(1).erpname,'No ERPset loaded')) || strcmpi(ALLERPStudio(length(ALLERPStudio)).erpname,'No ERPset loaded')
                return;
            end
            ERPArrayStudio= estudioworkingmemory('selectederpstudio');
            CURRENTERPStudio = observe_ERPDAT.CURRENTERP;
            if max(ERPArrayStudio(:))> length(ALLERPStudio) || min(ERPArrayStudio(:))<=0
                ERPArrayStudio = length(ALLERPStudio);
                CURRENTERPStudio = length(ALLERPStudio);
            end
            [x_index,y_index] = find(ERPArrayStudio==CURRENTERPStudio);
            if isempty(y_index)
                y_index = numel(ERPArrayStudio);
            end
            
            try
                ERPwaviewer_up = evalin('base','ALLERPwaviewer');
            catch
                beep;
                disp('f_ERPsets_waviewer_GUI() error: Restart ERPwave Viewer');
                return;
            end
            ERPwaviewer_up.ALLERP = ALLERPStudio;
            ERPwaviewer_up.ERP = ALLERPStudio(CURRENTERPStudio);
            ERPwaviewer_up.CURRENTERP = CURRENTERPStudio;
            ERPwaviewer_up.SelectERPIdx = ERPArrayStudio;
            ERPwaviewer_up.PageIndex = y_index;
            ERPdatasets = getERPDatasets(ALLERPStudio); % Get datasets from ALLERP
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
            
            %             ERPwaveview_erpsetops.butttons_datasets.Enable = Enable_label;
            ds_length = length(ERPdatasets);
            if ds_length<=2
                ERPwaveview_erpsetops.butttons_datasets.Max = ds_length+1;
            else
                ERPwaveview_erpsetops.butttons_datasets.Max = ds_length;
            end
            ERPwaveview_erpsetops.butttons_datasets.String = dsnames;
            ERPwaveview_erpsetops.butttons_datasets.Value = ERPArrayStudio;
            ERPtooltype = erpgettoolversion('tooltype');
            if strcmpi(ERPtooltype,'ERPLAB')
                observe_ERPDAT.ERP_bin= [1:observe_ERPDAT.ERP.nbin];
                observe_ERPDAT.ERP_chan = [1:observe_ERPDAT.ERP.nchan];
                ERPwaveview_erpsetops.butttons_datasets.Value =observe_ERPDAT.CURRENTERP;
                ERPwaviewer_up.SelectERPIdx = observe_ERPDAT.CURRENTERP;
                ERPwaviewer_up.PageIndex = 1;
            end
            
            estudioworkingmemory('PlotOrg_ERPLAB',1);%%This is used to Grid, Overlay, and Pages if "same as ERPLAB"
            
            assignin('base','ALLERPwaviewer',ERPwaviewer_up);
            viewer_ERPDAT.Count_currentERP = viewer_ERPDAT.Count_currentERP+1;
            f_redrawERP_viewer_test();%%Plot the waves
            
            MessageViewer= char(strcat('Update "ERP wave Viewer"'));
            erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
            viewer_ERPDAT.Process_messg =2;
        end
        
        
    end

end