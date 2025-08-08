% ERPset selector panel
%
% Author: Guanghui Zhang, David Garrett, & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022-2025

% ERPLAB Toolbox
%


function varargout = f_ERP_erpsetsGUI(varargin)
global observe_ERPDAT;
global EStudio_gui_erp_totl;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

ERPsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_erpset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_erpset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end


try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_erpset(FonsizeDefault);

varargout{1} = box_erpset_gui;

% Draw the ui
    function drawui_erpset(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        vBox = uiextras.VBox('Parent', box_erpset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5,'BackgroundColor',ColorB_def);
        
        %%-----------------------ERPset display---------------------------------------
        ERPlistName =  getERPsets();
        Edit_label = 'off';
        
        ERPsetops.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
            2,'String', ERPlistName,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        try ERPsetops.butttons_datasets.Value=1; catch end;
        set(vBox, 'Sizes', 150);

        %%---------------------Options for ERPsets-----------------------------------------------------
        ERPsetops.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.dupeselected = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.renameselected = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.suffix = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.refresh_erpset = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Refresh',...
            'Callback', @refresh_erpset,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);


        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load ERP', ...
            'Callback', @load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.importexport = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Import ERP',...
            'Callback', @imp_erp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.export = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Export',...
            'Callback', @exp_erp,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);

        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save ERP',...
            'Callback', @save_erp,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save a Copy', ...
            'Callback', @save_erpas,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.curr_folder = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder',...
            'Callback', @curr_folder,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);

        buttons5 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.clearselected = uicontrol('Parent', buttons5, 'Style', 'pushbutton', 'String', 'Clear Selected', ...
            'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.clearall = uicontrol('Parent', buttons5, 'Style', 'pushbutton', 'String', 'Clear All', ...
            'Callback', @clearall,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        %set(buttons4,'Sizes',[70 90 95])
        set(vBox, 'Sizes', [170 25 25 25 25]);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------duplicate the selected ERPsets-----------------------------
    function duplicateSelected(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Duplicate');
        observe_ERPDAT.Process_messg =1;
        
        ERPArray= ERPsetops.butttons_datasets.Value;
        if isempty(ERPArray)
            ERPArray = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        ChanArray= estudioworkingmemory('ERP_ChanArray');
        BinArray= estudioworkingmemory('ERP_BinArray');
        
        def = f_ERP_duplicate(observe_ERPDAT.ERP,BinArray,ChanArray);
        if isempty(def)
            return;
        end
        BinArray = def{1};
        ChanArray =def{2};
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        ChanAllold = [1:observe_ERPDAT.ERP.nchan];
        binAllold = [1:observe_ERPDAT.ERP.nbin];
        ALLERP_out = [];
        ALLERP = observe_ERPDAT.ALLERP;
        for Numoferp = 1:numel(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            [ERP, ERPCOM] = pop_duplicaterp( ERP, 'ChanArray',sort(ChanArray), 'BinArray',sort(BinArray),...
                'Saveas', 'off', 'History', 'gui');
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            if isempty(ALLERP_out)
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1)=ERP;
            end
        end
        
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray),'_duplicate');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLERP_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numoferp =  1:length(ALLERP_out)
            ERP = ALLERP_out(Numoferp);
            if Save_file_label==1
                [pathstr, file_name, ext] = fileparts(ERP.filename);
                ERP.filename = [file_name,'.erp'];
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                if Numoferp ==length(ALLERP_out)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            else
                ERP.filename = '';
                ERP.saved = 'no';
                ERP.filepath = '';
            end
            ALLERP(length(ALLERP)+1) = ERP;
        end
        observe_ERPDAT.ALLERP = ALLERP;
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('ERPfilter',1);
        
        ERPlistName =  getERPsets();
        %%Reset the display in ERPset panel
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
        
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            ERPsetops.butttons_datasets.Value = Selected_ERP_afd;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            ERPsetops.butttons_datasets.Value =  Selected_ERP_afd;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        assignin('base','ERP',observe_ERPDAT.ERP);
        assignin('base','ALLERP',ALLERP);
        assignin('base','CURRENTERP',observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        observe_ERPDAT.Process_messg =2;
        
        ChanAllNew = [1:observe_ERPDAT.ERP.nchan];
        chandiff = setdiff(ChanAllold,ChanAllNew);
        ChanArray =  estudioworkingmemory('ERP_ChanArray');
        if ~isempty(chandiff) && ~isempty(ChanArray)
            chancom = intersect(ChanArray,chandiff);
            if ~isempty(chancom)
                ChanArray = reshape(ChanArray,1,numel(ChanArray));
                for Numofchan = 1:numel(chancom)
                    [~,ypos] = find(ChanArray==chancom(Numofchan));
                    ChanArray(ypos) = [];
                end
                estudioworkingmemory('ERP_ChanArray',ChanArray);
            end
        end
        
        binAllNew = [1:observe_ERPDAT.ERP.nbin];
        bindiff = setdiff(binAllNew,binAllold);
        binArray =  estudioworkingmemory('ERP_BinArray');
        if ~isempty(bindiff) && ~isempty(binArray)
            bincom = intersect(binArray,bindiff);
            if ~isempty(bincom)
                binArray = reshape(binArray,1,numel(binArray));
                for Numofbin = 1:numel(bincom)
                    [~,ypos] = find(binArray==chancom(Numofbin));
                    binArray(ypos) = [];
                end
                
                estudioworkingmemory('ERP_BinArray',binArray);
            end
        end
        
        
        observe_ERPDAT.Count_currentERP = 1;
    end


%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Rename');
        observe_ERPDAT.Process_messg =1;
        
        ERPArray= ERPsetops.butttons_datasets.Value;
        if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
            ERPArray = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        app = feval('ERP_Tab_rename_gui',observe_ERPDAT.ALLERP(ERPArray),ERPArray);
        waitfor(app,'Finishbutton',1);
        try
            erpnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(erpnames)
            return;
        end
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        
        ALLERP_out = [];
        ALLERP = observe_ERPDAT.ALLERP(ERPArray);
        [ALLERP, ERPCOM] = pop_renamerp( ALLERP, 'erpnames',erpnames,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(ERPCOM)
            return;
        end
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(Numoferp);
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            if isempty(ALLERP_out)
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1)=ERP;
            end
        end
        
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('ERPfilter',1);
        observe_ERPDAT.ALLERP(ERPArray) = ALLERP_out;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        ERPlistName =  getERPsets();
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Add Suffix');
        observe_ERPDAT.Process_messg =1;
        
        ERPArray= ERPsetops.butttons_datasets.Value;
        if isempty(ERPArray)
            ERPArray = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        suffixstr = f_ERP_suffix_gui('Suffix');
        if isempty(suffixstr)
            return;
        end
        
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        
        ALLERP_out = [];
        ALLERP = observe_ERPDAT.ALLERP(ERPArray);
        [ALLERP, ERPCOM] = pop_suffixerp( ALLERP, 'suffixstr',suffixstr,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(ERPCOM)
            return;
        end
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(Numoferp);
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            if isempty(ALLERP_out)
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1)=ERP;
            end
        end
        
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('ERPfilter',1);
        observe_ERPDAT.ALLERP(ERPArray) = ALLERP_out;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        ERPlistName =  getERPsets();
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end

%%-------------------------------fresh ------------------------------------
    function refresh_erpset(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Refresh');
        observe_ERPDAT.Process_messg =1;
        try
            ALLERP = evalin('base', 'ALLERP');
        catch
            ALLERP = [];
        end
        try
            ERP = evalin('base', 'ERP');
        catch
            ERP = [];
        end
        try
            CURRENTERP = evalin('base', 'CURRENTERP');
        catch
            CURRENTERP = 1;
        end
        
        if isempty(ALLERP) && ~isempty(ALLERP)
            ALLERP = ERP;
            CURRENTERP =1;
        end
        if ~isempty(ALLERP) && isempty(ERP)
            if isempty(CURRENTERP) || numel(CURRENTERP)~=1 || any(CURRENTERP(:)>length(ALLERP))
                CURRENTERP = length(ALLERP);
            end
            try
                ERP =  observe_ERPDAT.ALLERP(CURRENTERP);
            catch
                ERP = [];
            end
        end
        observe_ERPDAT.ALLERP= ALLERP;
        try observe_ERPDAT.ALLERP(CURRENTERP) = ERP;catch  end
        
        observe_ERPDAT.ERP= ERP;
        observe_ERPDAT.CURRENTERP= CURRENTERP;
        
        assignin('base','CURRENTERP',CURRENTERP);
        assignin('base','ERP',ERP);
        assignin('base','ALLERP',ALLERP);
        estudioworkingmemory('selectederpstudio',CURRENTERP);
        ERPlistName =  getERPsets();
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
        ERPsetops.butttons_datasets.Value = CURRENTERP;
        observe_ERPDAT.Count_currentERP=1;
        observe_ERPDAT.Process_messg =2;
    end

%----------------------- Import--------------------------------------------
    function imp_erp( ~, ~ )
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Import');
        observe_ERPDAT.Process_messg =1;
        %-----------Setting for import-------------------------------------
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
        [ind,tf] = listdlg('ListString',{'ERPSS Text','Universal Text','Neuroscan (*.arg)'},'SelectionMode','single',...
            'PromptString','Please select a type to import from...','Name','Import','OKString','Select');
        
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        if isempty(ind)
            return;
        end
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = [];  end
        
        if tf%Import start
            %%-------------------------------------------------------------------------------
            %%-----------------------Import ERPSS text---------------------------------------
            %%-------------------------------------------------------------------------------
            if ind == 1
                %                     pop_importerpss_studio();
                answer = importERPSS_GUI; %(gui was modified)
                
                if isempty(answer)
                    return
                end
                
                fname      = answer{1}; % filename (+ whole path)
                dformat    = answer{2}; % data format
                dtranspose = answer{3}; % transpose data  (Fixed)
                if dformat==0
                    dformatstr = 'explicit'; % points at columns
                else
                    dformatstr = 'implicit'; % points at rows
                end
                if dtranspose==0
                    orienpoint = 'column';   % points at columns
                else
                    orienpoint = 'row';      % points at rows
                end
                
                [ERP, ALLERP, ERPCOM] = pop_importerpss('Filename', fname, 'Format', dformatstr, 'Pointat', orienpoint, 'History', 'script');
                [ERP, ALLERPCOM]= erphistory(ERP, ALLERPCOM, ERPCOM,2);
                
                try
                    Selected_erpset = [length(ALLERP)-length(fname)+1:length(ALLERP)];
                catch
                    disp('Fail to import the ERPsets, please try again or restart EStudio!');
                    return
                end
                ALLERP = f_erp_remv_Calibrate(ALLERP, Selected_erpset);
                Answer = f_ERP_save_multi_file(ALLERP,Selected_erpset,'_erpss');
                if isempty(Answer)
                    return;
                end
                Save_file_label = 0;
                if ~isempty(Answer{1})
                    ALLERP_advance = Answer{1};
                    Save_file_label = Answer{2};
                end
                if Save_file_label==1
                    for Numoferp = 1:length(Selected_erpset)
                        ERP = ALLERP_advance(Selected_erpset(Numoferp));
                        [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                        ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                        if Numoferp==length(Selected_erpset)
                            [ERP,ALLERPCOM]= erphistory(ERP, ALLERPCOM, ERPCOM,2);
                        else
                            [ERP,ALLERPCOM]= erphistory(ERP, ALLERPCOM, ERPCOM,1);
                        end
                    end
                end
                observe_ERPDAT.ALLERP=ALLERP_advance; clear ALLERP_advance;clear ALLERP
            else
                %%------------------------------------------------------------------------
                %%----------------------- Import Universal text-----------------------
                %%------------------------------------------------------------------------
                if ind == 2
                    
                    def  = estudioworkingmemory('pop_importerp');
                    if isempty(def)
                        def = {'','','',0,1,0,0,1000,[-200 800]};
                    end
                    %
                    % Call GUI
                    %
                    getlista = importerpGUI(def);
                    
                    if isempty(getlista)
                        return
                    end
                    
                    filename    = getlista{1};
                    filepath    = getlista{2};
                    ftype       = getlista{3};
                    includetime = getlista{4};
                    timeunit    = getlista{5};
                    elabel      = getlista{6};
                    transpose   = getlista{7};
                    fs          = getlista{8};
                    xlim        = getlista{9};
                    
                    estudioworkingmemory('pop_importerp', {filename, filepath, ftype,includetime,timeunit,elabel,transpose,fs,xlim});
                    
                    filetype = {'text'};
                    if includetime==0
                        inctimestr = 'off';
                    else
                        inctimestr = 'on';
                    end
                    if elabel==0
                        elabelstr = 'off';
                    else
                        elabelstr = 'on';
                    end
                    if transpose==0
                        orienpoint = 'column'; % points at columns
                    else
                        orienpoint = 'row';    % points at rows
                    end
                    
                    %
                    % Somersault
                    %
                    [ERP, ERPCOM] = pop_importerp('Filename', filename, 'Filepath', filepath, 'Filetype', filetype, 'Time', inctimestr,...
                        'Timeunit', timeunit, 'Elabel', elabelstr, 'Pointat', orienpoint, 'Srate', fs, 'Xlim', xlim, 'Saveas', 'off',...
                        'History', 'gui');
                    if  length(observe_ERPDAT.ALLERP)==1 && strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
                        Selected_erpset_indx = 1;
                    else
                        Selected_erpset_indx = length(observe_ERPDAT.ALLERP)+1;
                    end
                    try
                        filename = ERP.erpname;
                    catch
                        filename = strcat('Sub',num2str(Selected_erpset_indx),'-universal');
                    end
                    if isempty(filename)
                        filename = strcat('Sub',num2str(Selected_erpset_indx),'-universal');
                    end
                    ERP.erpname = filename;
                    %%------------------------------------------------------------------------
                    %%------------------------Import Neuroscan (.avg)----------------
                    %%------------------------------------------------------------------------
                elseif ind == 3  %%
                    [filename, filepath] = uigetfile({'*.avg';'Neuroscan average file (*.avg)'},'Select a file (Neuroscan)', 'MultiSelect', 'on');
                    if ~iscell(filename) && ~ischar(filename) && filename==0
                        return
                    end
                    
                    [ERP, ERPCOM]= pop_importavg(filename, filepath, 'Saveas','off','History', 'gui');
                    [pathstr, file_name, ext] = fileparts(filename{1,1});
                    ERP.erpname = file_name;
                    if  length(observe_ERPDAT.ALLERP)==1 && strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
                        Selected_erpset_indx = 1;
                    else
                        Selected_erpset_indx = length(observe_ERPDAT.ALLERP)+1;
                    end
                end
                [ERP,ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                
                Answer = f_ERP_save_single_file(ERP.erpname,ERP.filename,Selected_erpset_indx);
                if isempty(Answer)
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
                        ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                        [ERP,ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                    end
                end
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) =ERP;
            end
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        
        ERPlistName =  getERPsets();
        
        if isempty(observe_ERPDAT.ALLERP)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        
        ERPsetops.butttons_datasets.Value = length(observe_ERPDAT.ALLERP);
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.refresh_erpset.Enable= 'on';
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.clearall.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.curr_folder.Enable='on';
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        
        ERPArray = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',ERPArray);
        ERPsetops.butttons_datasets.Min=1;
        ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end

%-----------------------Export-----------------------------------
    function exp_erp( ~, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Export');
        observe_ERPDAT.Process_messg =1;
        %         pathName =  estudioworkingmemory('EEG_save_folder');
        %         if isempty(pathName)
        pathName =  cd;
        %         end
        ERPArray= ERPsetops.butttons_datasets.Value;
        if isempty(ERPArray)
            ERPArray = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        checked_ERPset_Index_bin_chan = f_checkerpsets(observe_ERPDAT.ALLERP,ERPArray);
        ChanArray= estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        
        BinArray = estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
        [ind,tf] = listdlg('ListString',{'ERPSS Text','Universal Text'},'SelectionMode','single','PromptString','Please select a type to export to...','Name','Export ERP to','OKString','Ok');
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        if isempty(ind)
            return;
        end
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        for Numoferp = 1:length(ERPArray)
            
            ERP_export_erp = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            if checked_ERPset_Index_bin_chan(1) ==1 || checked_ERPset_Index_bin_chan(2) ==2
                BinArray = [1:ERP_export_erp.nbin];
                ChanArray = [1:ERP_export_erp.nchan];
            end
            if ind==1
                ERP_export_erp.filename =fullfile(pathName,ERP_export_erp.filename);
                Answer_erpss = f_erp2ascGUI(ERP_export_erp,BinArray,ChanArray);
                if isempty(Answer_erpss)
                    return;
                end
                ERP = Answer_erpss{1};
                FileName = Answer_erpss{2};
                [ERP, ERPCOM] = pop_erp2asc(ERP,FileName,'History', 'gui');
                if Numoferp ==length(ERPArray)
                    [observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
                assignin('base','ALLERPCOM',ALLERPCOM);
                assignin('base','ERPCOM',ERPCOM);
                observe_ERPDAT.Count_currentERP = 20;
                observe_ERPDAT.Process_messg =2;
            elseif ind ==2
                ERP_export_erp.filename =fullfile(pathName,ERP_export_erp.filename);
                ERP = ERP_export_erp;
                def  = estudioworkingmemory('f_export2textGUI');
                if isempty(def)
                    def = {1,1000, 1, 1, 4, ''};
                end
                
                %
                % Call GUI
                %
                def_x = def;
                def_x{6} = ERP.filename;
                answer_export = f_export2textGUI(ERP,def_x,BinArray,ChanArray);
                if isempty(answer_export)
                    return;
                end
                estudioworkingmemory('f_export2textGUI',answer_export);
                istime    = answer_export{1};
                tunit     = answer_export{2};
                islabeled = answer_export{3};
                transpa   = answer_export{4};
                prec      = answer_export{5};
                filename  = answer_export{6};
                ERP = answer_export{7};
                binArray  = [1:ERP.nbin];
                if istime
                    time = 'on';
                else
                    time = 'off';
                end
                if islabeled
                    elabel = 'on';
                else
                    elabel = 'off';
                end
                if transpa
                    tra = 'on';
                else
                    tra = 'off';
                end
                [ERP, ERPCOM] = pop_export2text(ERP, filename, binArray, 'time', time, 'timeunit', tunit, 'electrodes', elabel,...
                    'transpose', tra, 'precision', prec, 'History', 'gui');
                if Numoferp ==length(ERPArray)
                    [observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
                assignin('base','ALLERPCOM',ALLERPCOM);
                assignin('base','ERPCOM',ERPCOM);
                observe_ERPDAT.Count_currentERP = 1;
                observe_ERPDAT.Process_messg =2;
            end
        end
    end

%%---------------------Load ERP--------------------------------------------
    function load(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Load');
        observe_ERPDAT.Process_messg =1;
        ALLERPCOM = evalin('base','ALLERPCOM');
        
        [filename, filepath] = uigetfile({'*.erp','ERP (*.erp)';...
            '*.mat','ERP (*.mat)'}, ...
            'Load ERP', ...
            'MultiSelect', 'on');
        if isequal(filename,0)
            return;
        end
        
        if ischar(filename)
            [ERP, ~, ERPCOM] = pop_loaderp('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'off', 'multiload', 'off',...
                'History', 'gui');
            ERP.filename = filename;
            ERP.filepath = filepath;
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            if isempty(observe_ERPDAT.ALLERP)
                observe_ERPDAT.ALLERP = ERP;
            else
                observe_ERPDAT.ALLERP(length( observe_ERPDAT.ALLERP)+1)  =ERP;
            end
        elseif iscell(filename)
            for numoferp = 1:length(filename)
                [ERP, ~, ERPCOM] = pop_loaderp('filename', filename{numoferp}, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'off', 'multiload', 'off',...
                    'History', 'gui'); %If eeglab is not open, don't update
                ERP.filename = filename{numoferp};
                ERP.filepath = filepath;
                if numoferp ==length(filename)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
                if isempty(observe_ERPDAT.ALLERP)
                    observe_ERPDAT.ALLERP = ERP;
                else
                    observe_ERPDAT.ALLERP(length( observe_ERPDAT.ALLERP)+1)  =ERP;
                end
            end
        end
        assignin('base','ALLERP',observe_ERPDAT.ALLERP);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        
        ERPlistName =  getERPsets();
        if isempty(observe_ERPDAT.ALLERP)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        if ~isempty(observe_ERPDAT.ALLERP)
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        else
            observe_ERPDAT.ERP=[];
            observe_ERPDAT.CURRENTERP = 1;
        end
        observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.refresh_erpset.Enable= 'on';
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.clearall.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.curr_folder.Enable='on';
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        ERPsetops.butttons_datasets.Min=1;
        ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            f_redrawERP();
        end
    end

%%----------------------Clear the selected ERPsets-------------------------
    function cleardata(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Clear');
        observe_ERPDAT.Process_messg =1;
        SelectedERP = ERPsetops.butttons_datasets.Value;
        ALLERP = observe_ERPDAT.ALLERP;
        [ALLERP,LASTCOM] = pop_deleterpset(ALLERP,'Erpsets', SelectedERP, 'Saveas', 'off','History', 'gui' );
        if isempty(LASTCOM)
            return;
        end
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM = []; end
        ERP1 =  observe_ERPDAT.ERP;
        [ERP1, ALLERPCOM] = erphistory(ERP1, ALLERPCOM, LASTCOM,2);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',LASTCOM);
        if isempty(ALLERP)
            observe_ERPDAT.ALLERP = [];
            observe_ERPDAT.ERP = [];
            observe_ERPDAT.CURRENTERP  = 0;
            assignin('base','ERP',observe_ERPDAT.ERP)
        else
            observe_ERPDAT.ALLERP = ALLERP;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP  = length(observe_ERPDAT.ALLERP);
        end
        ERPlistName =  getERPsets();
        if isempty(observe_ERPDAT.ALLERP)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        ERPsetops.butttons_datasets.String = ERPlistName;
        if observe_ERPDAT.CURRENTERP>0
            ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        else
            ERPsetops.butttons_datasets.Value=1;
        end
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.refresh_erpset.Enable= 'on';
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.clearall.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.curr_folder.Enable='on';
        ERPsetops.butttons_datasets.Min =1;
        ERPsetops.butttons_datasets.Max =length(ERPlistName)+1;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            f_redrawERP();
        end
    end

%%----------------------Clear ALL ERPsets-------------------------
function clearall(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Clear');
        observe_ERPDAT.Process_messg =1;   
        ALLERP = observe_ERPDAT.ALLERP;
        SelectedERP = 1:length(ALLERP);
        [ALLERP,LASTCOM] = pop_deleterpset(ALLERP,'Erpsets', SelectedERP, 'Saveas', 'off','History', 'gui' );
        if isempty(LASTCOM)
            return;
        end
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch ALLERPCOM = []; end
        ERP1 =  observe_ERPDAT.ERP;
        [ERP1, ALLERPCOM] = erphistory(ERP1, ALLERPCOM, LASTCOM,2);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',LASTCOM);
        if isempty(ALLERP)
            observe_ERPDAT.ALLERP = [];
            observe_ERPDAT.ERP = [];
            observe_ERPDAT.CURRENTERP  = 0;
            assignin('base','ERP',observe_ERPDAT.ERP)
        else
            observe_ERPDAT.ALLERP = ALLERP;
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP  = length(observe_ERPDAT.ALLERP);
        end
        ERPlistName =  getERPsets();
        if isempty(observe_ERPDAT.ALLERP)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        ERPsetops.butttons_datasets.String = ERPlistName;
        if observe_ERPDAT.CURRENTERP>0
            ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        else
            ERPsetops.butttons_datasets.Value=1;
        end
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.refresh_erpset.Enable= 'on';
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.clearall.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.curr_folder.Enable='on';
        ERPsetops.butttons_datasets.Min =1;
        ERPsetops.butttons_datasets.Max =length(ERPlistName)+1;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            f_redrawERP();
        end
    end

%-------------------------- Save selected ERPsets-------------------------------------------
    function save_erp(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Save');
        observe_ERPDAT.Process_messg =1;
        
        %         pathNamedef =  estudioworkingmemory('EEG_save_folder');
        %         if isempty(pathNamedef)
        pathNamedef =  cd;
        %         end
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
            ERPArray = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        
        for Numoferp = 1:length(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            pathName = ERP.filepath;
            if isempty(pathName)
                pathName = pathNamedef;
            end
            FileName = ERP.filename;
            if isempty(FileName)
                FileName = ERP.erpname;
            end
            [pathx, filename, ext] = fileparts(FileName);
            filename = [filename '.erp'];
            checkfileindex = checkfilexists([pathName,filesep,filename]);
            if checkfileindex==1
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', filename, 'filepath',pathName);
                ERPCOM = f_erp_save_history(ERP.erpname,filename,pathName);
                if Numoferp==1
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    fprintf(['*ERPsets>Save*',32,32,32,32,datestr(datetime('now')),'\n']);
                    fprintf( [ERPCOM]);
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                end
                
                if Numoferp == numel(ERPArray)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            end
            observe_ERPDAT.ALLERP(ERPArray(Numoferp)) = ERP;
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        assignin('base','ALLERPCOM',ALLERPCOM);
        try assignin('base','ERPCOM',ERPCOM);catch; end
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
    end

%------------------------- Save as-----------------------------------------
    function save_erpas(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_ERP_proces_messg','ERPsets>Save a Copy');
        observe_ERPDAT.Process_messg =1;
        
        %         pathName =  estudioworkingmemory('EEG_save_folder');
        %         if isempty(pathName)
        pathName =  [cd,filesep];
        %         end
        
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) || any(ERPArray(:)>length(observe_ERPDAT.ALLERP))
            ERPArray = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        Answer = f_ERP_save_as_GUI(observe_ERPDAT.ALLERP,ERPArray,'_copy',1,pathName);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLERP_out = Answer{1};
        end
        ALLERP = observe_ERPDAT.ALLERP;
        for Numoferp = 1:length(ERPArray)
            ERP = ALLERP_out(ERPArray(Numoferp));
            if ~isempty(ERP.filename)
                filename = ERP.filename;
            else
                filename = [ERP.erpname,'.erp'];
            end
            [pathstr, erpfilename, ext] = fileparts(filename);
            ext = '.erp';
            erpFilename = char(strcat(erpfilename,ext));
            [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', erpFilename,...
                'filepath',ERP.filepath);
            
            ERPCOM = f_erp_save_history(ERP.erpname,erpFilename,ERP.filepath);
            if Numoferp==1
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*ERPsets>Save a Copy*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf( [ERPCOM]);
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end
            if Numoferp == numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            ALLERP(length(ALLERP)+1) = ERP;
        end
        
        observe_ERPDAT.ALLERP = ALLERP;
        
        ERPlistName =  getERPsets();
        %%Reset the display in ERPset panel
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
        
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            ERPsetops.butttons_datasets.Value = Selected_ERP_afd;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            ERPsetops.butttons_datasets.Value =  Selected_ERP_afd;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        ERPsetops.butttons_datasets.Value = Selected_ERP_afd;
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
    end


%---------------- Enable/Disable dot structure-----------------------------
    function curr_folder(~,~)
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        %         pathName =  estudioworkingmemory('EEG_save_folder');
        %         if isempty(pathName)
        pathName =[pwd,filesep];
        %         end
        title = 'Select one forlder for saving files in following procedures';
        sel_path1 = uigetdir(pathName,title);
        if isequal(sel_path1,0)
            sel_path1 = cd;
        end
        
        cd(sel_path1);
        erpcom  = sprintf('cd("%s',sel_path1);
        erpcom = [erpcom,'");'];
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        if ~isempty(observe_ERPDAT.ERP)
            ERP = observe_ERPDAT.ERP;
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*ERPsets>Current Folder*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf( [erpcom]);
            fprintf( ['\n',repmat('-',1,100) '\n']);
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, erpcom,2);
        else
            if isempty(ALLERPCOM)
                ALLERPCOM{1} = erpcom;
            else
                ALLERPCOM{length(ALLERPCOM)+1} = erpcom;
            end
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        estudioworkingmemory('EEG_save_folder',sel_path1);
        observe_ERPDAT.Count_currentERP = 20;
    end


%-----------------select the ERPset of interest--------------------------
    function selectdata(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        ERPArray = source.Value;
        estudioworkingmemory('selectederpstudio',ERPArray);
        
        Current_ERP_selected=ERPArray(1);
        observe_ERPDAT.CURRENTERP = Current_ERP_selected;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_ERP_selected);
        observe_ERPDAT.Count_currentERP = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            f_redrawERP();
        end
    end

%%%--------------Up this panel--------------------------------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=1
            return;
        end
        if ~isempty(observe_ERPDAT.ALLERP) && ~isempty(observe_ERPDAT.ERP)
            ERPArray= estudioworkingmemory('selectederpstudio');
            if isempty(ERPArray)
                ERPArray = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                observe_ERPDAT.CURRENTERP = ERPArray;
                estudioworkingmemory('selectederpstudio',ERPArray);
            end
            ERPlistName =  getERPsets();
            ERPsetops.butttons_datasets.String = ERPlistName;
            ERPsetops.butttons_datasets.Value = ERPArray;
            
            ERPsetops.butttons_datasets.Min=1;
            ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
            estudioworkingmemory('selectederpstudio',ERPArray);
            ERPsetops.butttons_datasets.Value = ERPArray;
            ERPsetops.butttons_datasets.Enable = 'on';
            Edit_label = 'on';
        else
            ERPlistName =  getERPsets();
            ERPArray =1;
            ERPsetops.butttons_datasets.String = ERPlistName;
            ERPsetops.butttons_datasets.Value = ERPArray;
            ERPsetops.butttons_datasets.Min=1;
            ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
            estudioworkingmemory('selectederpstudio',ERPArray);
            Edit_label = 'off';
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if ViewerFlag==1
            Edit_label = 'off';
            ERPsetops.importexport.Enable=Edit_label;
            ERPsetops.loadbutton.Enable=Edit_label;
        else
            ERPsetops.importexport.Enable='on';
            ERPsetops.loadbutton.Enable='on';
        end
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.refresh_erpset.Enable= 'on';
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.curr_folder.Enable='on';
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        
        assignin('base','ERP',observe_ERPDAT.ERP);
        assignin('base','ALLERP',observe_ERPDAT.ALLERP);
        assignin('base','CURRENTERP',observe_ERPDAT.CURRENTERP);
        
        observe_ERPDAT.Count_currentERP = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            f_redrawERP();
        end
    end

%%------------------get the names of erpsets-------------------------------
    function ERPlistName =  getERPsets(ALLERP)
        if nargin<1
            ALLERP= observe_ERPDAT.ALLERP;
        end
        ERPlistName = {};
        if ~isempty(ALLERP)
            count1 =0;
            count = 0;
            FFTArray = [];
            FFTstr = '';
            for ii = 1:length(ALLERP)
                if strcmpi(ALLERP(ii).datatype,'TFFT')
                    count1 = count1+1;
                    FFTArray(count1) = ii;
                    if count1==1
                        FFTstr =  ALLERP(ii).erpname;
                    else
                        FFTstr =  [FFTstr,',',32,ALLERP(ii).erpname];
                    end
                else
                    count = count+1;
                    ERPlistName{count,1} =    char(strcat(num2str(ii),'.',32, ALLERP(ii).erpname));
                end
            end
            if ~isempty(FFTArray)
                observe_ERPDAT.ALLERP(FFTArray) = [];
                observe_ERPDAT.Count_currentERP = 1;
                msgboxText =  ['ERPLAB Studio doesnot work with ERPsets that have been transformed into the frequency domain, the details are as below:',32,FFTstr];
                title = 'ERPsets panel';
                estudio_warning(msgboxText,title);
                return
            end
        else
            ERPlistName{1} = 'No erpset is available' ;
        end
    end

    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=1
            return;
        end
        if ~isempty(observe_ERPDAT.ALLERP)
            observe_ERPDAT.ERP =  observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',observe_ERPDAT.CURRENTERP);
            ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        end
        observe_ERPDAT.Reset_erp_paras_panel=2;
    end

end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%% 2024
checkfileindex=1;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr,filesep, file_name,'.erp'];
if exist(filenamex, 'file')~=0
    msgboxText =  ['This ERP set already exists.\n'...;
        'Would you like to overwrite it?'];
    title  = 'Estudio: WARNING!';
    button = askquest(sprintf(msgboxText), title);
    if strcmpi(button,'no')
        checkfileindex=0;
    else
        checkfileindex=1;
    end
end
end