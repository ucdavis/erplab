% MVPCset selector panel
%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

% ERPLAB Studio Toolbox
%


function varargout = f_decode_mvpcsetsGUI(varargin)
global observe_DECODE;
global EStudio_gui_erp_totl;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

Mvpcsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_mvpcset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'MVPCsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_mvpcset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'MVPCsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_mvpcset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'MVPCsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end


try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_bestset(FonsizeDefault);

varargout{1} = box_mvpcset_gui;

% Draw the ui
    function drawui_bestset(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        vBox = uiextras.VBox('Parent', box_mvpcset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5,'BackgroundColor',ColorB_def);
        
        %%-----------------------ERPset display---------------------------------------
        BESTlistName =  getMVPCsets();
        Edit_label = 'off';
        
        Mvpcsetops.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
            2,'String', BESTlistName,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        try Mvpcsetops.butttons_datasets.Value=1; catch end;
        set(vBox, 'Sizes', 150);
        
        %%---------------------Options for MVPCsets-----------------------------------------------------
        Mvpcsetops.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        Mvpcsetops.dupeselected = uicontrol('Parent', Mvpcsetops.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Mvpcsetops.renameselected = uicontrol('Parent', Mvpcsetops.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Mvpcsetops.suffix = uicontrol('Parent', Mvpcsetops.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        
        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        Mvpcsetops.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Mvpcsetops.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', ...
            'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Mvpcsetops.refresh_mvpcset = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Refresh',...
            'Callback', @refresh_mvpcset,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        
        Mvpcsetops.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save',...
            'Callback', @save_mvpc,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Mvpcsetops.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save a Copy', ...
            'Callback', @save_mvpcas,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Mvpcsetops.curr_folder = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder',...
            'Callback', @curr_folder,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(buttons4,'Sizes',[70 90 95])
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------duplicate the selected MVPCsets-----------------------------
    function duplicateSelected(source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Duplicate');
        observe_DECODE.Process_messg =1;
        
        MVPCArray= Mvpcsetops.butttons_datasets.Value;
        if isempty(MVPCArray)
            MVPCArray = length(observe_DECODE.ALLMVPC);
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        ALLMVPC = observe_DECODE.ALLMVPC;
        [ALLMVPC, mvpcom] = pop_duplicatmvpc( ALLMVPC, 'MVPCArray',MVPCArray,...
            'History', 'gui');
        if isempty(ALLMVPC) || isempty(mvpcom)
            estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Duplicate:user selected cancel');
            observe_DECODE.Process_messg =2;
            return;
        end
        eegh(mvpcom);
        observe_DECODE.ALLMVPC = ALLMVPC;
        
        BESTlistName =  getMVPCsets();
        Mvpcsetops.butttons_datasets.String = BESTlistName;
        Mvpcsetops.butttons_datasets.Min = 1;
        Mvpcsetops.butttons_datasets.Max = length(BESTlistName)+1;
        try
            MVPCArray =  [length(observe_DECODE.ALLMVPC)-numel(MVPCArray)+1:length(observe_DECODE.ALLMVPC)];
            Mvpcsetops.butttons_datasets.Value = MVPCArray;
            observe_DECODE.CURRENTMVPC = length(observe_DECODE.ALLMVPC)-numel(MVPCArray)+1;
        catch
            MVPCArray = length(observe_DECODE.ALLMVPC);
            Mvpcsetops.butttons_datasets.Value =  MVPCArray;
            observe_DECODE.CURRENTMVPC = length(observe_DECODE.ALLMVPC);
        end
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(observe_DECODE.CURRENTMVPC);
        assignin('base','MVPC',observe_DECODE.MVPC);
        assignin('base','ALLMVPC',ALLMVPC);
        assignin('base','CURRENTMVPC',observe_DECODE.CURRENTMVPC);
        estudioworkingmemory('MVPCArray',MVPCArray);
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentMVPC = 1;
    end


%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Rename');
        observe_DECODE.Process_messg =1;
        
        MVPCArray= Mvpcsetops.butttons_datasets.Value;
        if isempty(MVPCArray) || any(MVPCArray>length(observe_DECODE.ALLMVPC))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        app = feval('Decode_Tab_mvpcrename_gui',observe_DECODE.ALLMVPC(MVPCArray),MVPCArray);
        waitfor(app,'Finishbutton',1);
        try
            mvpcnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(mvpcnames)
            return;
        end
        ALLMVPC = observe_DECODE.ALLMVPC(MVPCArray);
        [ALLMVPC, BESTCOM] = pop_renamemvpc( ALLMVPC, 'mvpcnames',mvpcnames,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(BESTCOM)
            return;
        end
        observe_DECODE.ALLMVPC(MVPCArray) = ALLMVPC;
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(observe_DECODE.CURRENTMVPC);
        BESTlistName =  getMVPCsets();
        Mvpcsetops.butttons_datasets.String = BESTlistName;
        Mvpcsetops.butttons_datasets.Min = 1;
        Mvpcsetops.butttons_datasets.Max = length(BESTlistName)+1;
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentMVPC=1;
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Add Suffix');
        observe_DECODE.Process_messg =1;
        
        MVPCArray= Mvpcsetops.butttons_datasets.Value;
        if isempty(MVPCArray)
            MVPCArray = length(observe_DECODE.ALLMVPC);
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        suffixstr = f_EEG_suffix_gui('Suffix',2);
        if isempty(suffixstr)
            return;
        end
        
        ALLMVPC = observe_DECODE.ALLMVPC(MVPCArray);
        [ALLMVPC, BESTCOM] = pop_suffixmvpc( ALLMVPC, 'suffixstr',suffixstr,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(BESTCOM)
            return;
        end
        
        observe_DECODE.ALLMVPC(MVPCArray) = ALLMVPC;
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(observe_DECODE.CURRENTMVPC);
        BESTlistName =  getMVPCsets();
        Mvpcsetops.butttons_datasets.String = BESTlistName;
        Mvpcsetops.butttons_datasets.Min = 1;
        Mvpcsetops.butttons_datasets.Max = length(BESTlistName)+1;
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentMVPC = 1;
    end

%%-------------------------------fresh ------------------------------------
    function refresh_mvpcset(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Refresh');
        observe_DECODE.Process_messg =1;
        try
            ALLMVPC = evalin('base', 'ALLMVPC');
        catch
            ALLMVPC = [];
        end
        try
            MVPC = evalin('base', 'MVPC');
        catch
            MVPC = [];
        end
        try
            CURRENTMVPC = evalin('base', 'CURRENTMVPC');
        catch
            CURRENTMVPC = 1;
        end
        
        if isempty(ALLMVPC) && ~isempty(ALLMVPC)
            ALLMVPC = MVPC;
            CURRENTMVPC =1;
        end
        if ~isempty(ALLMVPC) && isempty(MVPC)
            if isempty(CURRENTMVPC) || numel(CURRENTMVPC)~=1 || any(CURRENTMVPC(:)>length(ALLMVPC))
                CURRENTMVPC = length(ALLMVPC);
            end
            try
                MVPC =  observe_DECODE.ALLMVPC(CURRENTMVPC);
            catch
                MVPC = [];
            end
        end
        observe_DECODE.ALLMVPC= ALLMVPC;
        try observe_DECODE.ALLMVPC(CURRENTMVPC) = MVPC;catch  end
        
        observe_DECODE.MVPC= MVPC;
        observe_DECODE.CURRENTMVPC= CURRENTMVPC;
        
        assignin('base','CURRENTMVPC',CURRENTMVPC);
        assignin('base','MVPC',MVPC);
        assignin('base','ALLMVPC',ALLMVPC);
        estudioworkingmemory('MVPCArray',CURRENTMVPC);
        MVPClistName =  getMVPCsets();
        Mvpcsetops.butttons_datasets.String = MVPClistName;
        Mvpcsetops.butttons_datasets.Min = 1;
        Mvpcsetops.butttons_datasets.Max = length(MVPClistName)+1;
        if any(CURRENTMVPC(:)<1)
            Mvpcsetops.butttons_datasets.Value =1;
        else
            Mvpcsetops.butttons_datasets.Value = CURRENTMVPC;
        end
        observe_DECODE.Count_currentMVPC=1;
        observe_DECODE.Process_messg =2;
    end

%%---------------------Load MVPC-------------------------------------------
    function load(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Load');
        observe_DECODE.Process_messg =1;
        
        [filename, filepath] = uigetfile({'*.mvpc'}, ...
            'Load MVPCsets', ...
            'MultiSelect', 'on');
        if isequal(filename,0)
            return;
        end
        
        [MVPC,ALLMVPC] = pop_loadmvpc( 'filename', filename, 'filepath', filepath,...
            'UpdateMainGui', 'off','History','gui' );
        observe_DECODE.ALLMVPC = ALLMVPC;
        
        MVPClistName =  getMVPCsets();
        if isempty(observe_DECODE.ALLMVPC)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
        observe_DECODE.CURRENTMVPC = length(observe_DECODE.ALLMVPC);
        Mvpcsetops.butttons_datasets.Value = observe_DECODE.CURRENTMVPC;
        Mvpcsetops.butttons_datasets.String = MVPClistName;
        Mvpcsetops.dupeselected.Enable=Edit_label;
        Mvpcsetops.renameselected.Enable=Edit_label;
        Mvpcsetops.suffix.Enable= Edit_label;
        Mvpcsetops.refresh_mvpcset.Enable= 'on';
        Mvpcsetops.clearselected.Enable=Edit_label;
        Mvpcsetops.savebutton.Enable= Edit_label;
        Mvpcsetops.saveasbutton.Enable=Edit_label;
        Mvpcsetops.curr_folder.Enable='on';
        Mvpcsetops.butttons_datasets.Enable = Edit_label;
        Mvpcsetops.append.Enable = Edit_label;
        MVPCArray = observe_DECODE.CURRENTMVPC;
        estudioworkingmemory('MVPCArray',MVPCArray);
        Mvpcsetops.butttons_datasets.Min=1;
        Mvpcsetops.butttons_datasets.Max=length(MVPClistName)+1;
        assignin('base','MVPC',observe_DECODE.MVPC);
        assignin('base','ALLMVPC',observe_DECODE.ALLMVPC);
        assignin('base','CURRENTMVPC',observe_DECODE.CURRENTMVPC);
        
        [serror, msgwrng] = f_checkmvpc( observe_DECODE.ALLMVPC,MVPCArray);
        if serror==1 && ~isempty(msgwrng)
            msgboxText =  ['MVPCsets> Load:We only plot accuracy results for the first selected MVPCset becuase',32,msgwrng];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        elseif serror==2 && ~isempty(msgwrng)
        end
        
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentMVPC = 1;
        
    end

%%----------------------Clear the selected MVPCsets-------------------------
    function cleardata(source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Clear');
        observe_DECODE.Process_messg =1;
        MVPCArray = Mvpcsetops.butttons_datasets.Value;
        ALLMVPC = observe_DECODE.ALLMVPC;
        [ALLMVPC,LASTCOM] = pop_deletemvpcset(ALLMVPC,'MVPCsets', MVPCArray, 'Saveas', 'off','History', 'gui' );
        if isempty(LASTCOM)
            return;
        end
        eegh(LASTCOM);
        
        if isempty(ALLMVPC)
            observe_DECODE.ALLMVPC = [];
            observe_DECODE.MVPC = [];
            observe_DECODE.CURRENTMVPC  = 0;
            assignin('base','MVPC',observe_DECODE.MVPC)
        else
            observe_DECODE.ALLMVPC = ALLMVPC;
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC  = length(observe_DECODE.ALLMVPC);
        end
        MVPClistName =  getMVPCsets();
        if isempty(observe_DECODE.ALLMVPC)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        Mvpcsetops.butttons_datasets.String = MVPClistName;
        if observe_DECODE.CURRENTMVPC>0
            Mvpcsetops.butttons_datasets.Value = observe_DECODE.CURRENTMVPC;
        else
            Mvpcsetops.butttons_datasets.Value=1;
        end
        Mvpcsetops.dupeselected.Enable=Edit_label;
        Mvpcsetops.renameselected.Enable=Edit_label;
        Mvpcsetops.suffix.Enable= Edit_label;
        Mvpcsetops.refresh_mvpcset.Enable= 'on';
        Mvpcsetops.clearselected.Enable=Edit_label;
        Mvpcsetops.savebutton.Enable= Edit_label;
        Mvpcsetops.saveasbutton.Enable=Edit_label;
        Mvpcsetops.curr_folder.Enable='on';
        Mvpcsetops.butttons_datasets.Min =1;
        Mvpcsetops.butttons_datasets.Max =length(MVPClistName)+1;
        Mvpcsetops.butttons_datasets.Enable = Edit_label;
        Mvpcsetops.append.Enable = Edit_label;
        MVPCArray = observe_DECODE.CURRENTMVPC;
        estudioworkingmemory('MVPCArray',MVPCArray);
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentMVPC = 1;
        
    end


%-------------------------- Save selected MVPCsets-------------------------------------------
    function save_mvpc(source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Save');
        observe_DECODE.Process_messg =1;
        
        pathNamedef =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathNamedef)
            pathNamedef =  cd;
        end
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || any(MVPCArray>length(observe_DECODE.ALLMVPC))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        for Numoferp = 1:length(MVPCArray)
            MVPC = observe_DECODE.ALLMVPC(MVPCArray(Numoferp));
            pathName = MVPC.filepath;
            if isempty(pathName)
                pathName = pathNamedef;
            end
            FileName = MVPC.filename;
            if isempty(FileName)
                FileName = MVPC.mvpcname;
            end
            [pathx, filename, ext] = fileparts(FileName);
            filename = [filename '.mvpc'];
            checkfileindex = checkfilexists([pathName,filesep,filename]);
            if checkfileindex==1
                [MVPC, issave, MVPCCOM] = pop_savemymvpc(MVPC, 'mvpcname', MVPC.mvpcname, 'filename',...
                    filename, 'filepath',pathName,'History','gui');
                if Numoferp==1
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    fprintf(['*MVPCsets>Save*',32,32,32,32,datestr(datetime('now')),'\n']);
                    fprintf( [MVPCCOM]);
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    eegh(MVPCCOM);
                end
            end
        end
        
        observe_DECODE.Count_currentMVPC = 1;
        observe_DECODE.Process_messg =2;
    end

%------------------------- Save as-----------------------------------------
    function save_mvpcas(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','MVPCsets>Save a Copy');
        observe_DECODE.Process_messg =1;
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || any(MVPCArray(:)>length(observe_DECODE.ALLMVPC))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        Answer = f_MVPC_save_as_GUI(observe_DECODE.ALLMVPC,MVPCArray,'_copy',1,pathName);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLMVPC_out = Answer{1};
        end
        ALLMVPC = observe_DECODE.ALLMVPC;
        for Numoferp = 1:length(MVPCArray)
            MVPC = ALLMVPC_out(MVPCArray(Numoferp));
            if ~isempty(MVPC.filename)
                filename = MVPC.filename;
            else
                filename = [MVPC.mvpcname,'.mvpc'];
            end
            [pathstr, erpfilename, ext] = fileparts(filename);
            ext = '.mvpc';
            erpFilename = char(strcat(erpfilename,ext));
            
            [MVPC, issave, MVPCCOM] = pop_savemymvpc(MVPC, 'mvpcname', MVPC.mvpcname,...
                'filename', erpFilename, 'filepath',MVPC.filepath,'History','gui');
            
            if Numoferp==1
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*MVPCsets>Save a Copy*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf( [MVPCCOM]);
                fprintf( ['\n',repmat('-',1,100) '\n']);
                eegh(MVPCCOM);
            end
            ALLMVPC(length(ALLMVPC)+1) = MVPC;
        end
        observe_DECODE.ALLMVPC = ALLMVPC;
        MVPClistName =  getMVPCsets();
        Mvpcsetops.butttons_datasets.String = MVPClistName;
        Mvpcsetops.butttons_datasets.Min = 1;
        Mvpcsetops.butttons_datasets.Max = length(MVPClistName)+1;
        
        try
            MVPCArray =  [length(observe_DECODE.ALLMVPC)-numel(MVPCArray)+1:length(observe_DECODE.ALLMVPC)];
            Mvpcsetops.butttons_datasets.Value = MVPCArray;
            observe_DECODE.CURRENTMVPC = length(observe_DECODE.ALLMVPC)-numel(MVPCArray)+1;
        catch
            MVPCArray = length(observe_DECODE.ALLMVPC);
            Mvpcsetops.butttons_datasets.Value =  MVPCArray;
            observe_DECODE.CURRENTMVPC = length(observe_DECODE.ALLMVPC);
        end
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(observe_DECODE.CURRENTMVPC);
        estudioworkingmemory('MVPCArray',MVPCArray);
        
        Mvpcsetops.butttons_datasets.Value = MVPCArray;
        observe_DECODE.Count_currentMVPC = 1;
        observe_DECODE.Process_messg =2;
    end


%---------------- Enable/Disable dot structure-----------------------------
    function curr_folder(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =[pwd,filesep];
        end
        title = 'Select one forlder for saving files in following procedures';
        sel_path1 = uigetdir(pathName,title);
        if isequal(sel_path1,0)
            sel_path1 = cd;
        end
        
        cd(sel_path1);
        erpcom  = sprintf('cd("%s',sel_path1);
        erpcom = [erpcom,'");'];
        fprintf( [erpcom,'\n']);
        eegh(erpcom);
        estudioworkingmemory('EEG_save_folder',sel_path1);
    end


%-----------------select the ERPset of interest--------------------------
    function selectdata(source,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentMVPC=eegpanelIndex+1;%%call the functions from the other panel
        end
        MVPCArray = source.Value;
        estudioworkingmemory('MVPCArray',MVPCArray);
        
        Current_ERP_selected=MVPCArray(1);
        observe_DECODE.CURRENTMVPC = Current_ERP_selected;
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(Current_ERP_selected);
        observe_DECODE.Count_currentMVPC = 2;
        [serror, msgwrng] = f_checkmvpc( observe_DECODE.ALLMVPC,MVPCArray);
        if serror==1 && ~isempty(msgwrng)
            msgboxText =  ['MVPCsets> We only plot accuracy results for the first selected MVPCset becuase',32,msgwrng];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        elseif serror==2 && ~isempty(msgwrng)
        end
        observe_DECODE.Count_currentMVPC = 1;
    end

%%%--------------Up this panel--------------------------------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=1
            return;
        end
        if ~isempty(observe_DECODE.ALLMVPC) && ~isempty(observe_DECODE.MVPC)
            MVPCArray= estudioworkingmemory('MVPCArray');
            if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
                MVPCArray = length(observe_DECODE.ALLMVPC);
                observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
                observe_DECODE.CURRENTMVPC = MVPCArray;
                estudioworkingmemory('MVPCArray',MVPCArray);
            end
            MVPClistName =  getMVPCsets();
            Mvpcsetops.butttons_datasets.String = MVPClistName;
            Mvpcsetops.butttons_datasets.Value = MVPCArray;
            
            Mvpcsetops.butttons_datasets.Min=1;
            Mvpcsetops.butttons_datasets.Max=length(MVPClistName)+1;
            estudioworkingmemory('MVPCArray',MVPCArray);
            Mvpcsetops.butttons_datasets.Value = MVPCArray;
            Mvpcsetops.butttons_datasets.Enable = 'on';
            Edit_label = 'on';
        else
            MVPClistName =  getMVPCsets();
            MVPCArray =1;
            Mvpcsetops.butttons_datasets.String = MVPClistName;
            Mvpcsetops.butttons_datasets.Value = MVPCArray;
            Mvpcsetops.butttons_datasets.Min=1;
            Mvpcsetops.butttons_datasets.Max=length(MVPClistName)+1;
            estudioworkingmemory('MVPCArray',MVPCArray);
            Edit_label = 'off';
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if ViewerFlag==1
            Edit_label = 'off';
            Mvpcsetops.loadbutton.Enable='off';
        else
            Mvpcsetops.loadbutton.Enable='on';
        end
        Mvpcsetops.dupeselected.Enable=Edit_label;
        Mvpcsetops.renameselected.Enable=Edit_label;
        Mvpcsetops.suffix.Enable= Edit_label;
        Mvpcsetops.refresh_mvpcset.Enable= 'on';
        Mvpcsetops.clearselected.Enable=Edit_label;
        Mvpcsetops.savebutton.Enable= Edit_label;
        Mvpcsetops.saveasbutton.Enable=Edit_label;
        Mvpcsetops.curr_folder.Enable='on';
        Mvpcsetops.butttons_datasets.Enable = Edit_label;
        Mvpcsetops.append.Enable = Edit_label;
        
        assignin('base','MVPC',observe_DECODE.MVPC);
        assignin('base','ALLMVPC',observe_DECODE.ALLMVPC);
        assignin('base','CURRENTMVPC',observe_DECODE.CURRENTMVPC);
        observe_DECODE.Count_currentMVPC = 2;
        if EStudio_gui_erp_totl.Decode_autoplot==1
            f_redrawmvpc_Wave_Viewer();
        end
    end

%%------------------get the names of MVPCsets-------------------------------
    function MVPClistName =  getMVPCsets(ALLMVPC)
        if nargin<1
            ALLMVPC= observe_DECODE.ALLMVPC;
        end
        MVPClistName = {};
        if ~isempty(ALLMVPC)
            for ii = 1:length(ALLMVPC)
                MVPClistName{ii,1} =    char(strcat(num2str(ii),'.',32, ALLMVPC(ii).mvpcname));
            end
        else
            MVPClistName{1} = 'No MVPCset is available' ;
        end
    end


    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_Best_paras_panel~=1
            return;
        end
        if ~isempty(observe_DECODE.ALLMVPC)
            observe_DECODE.MVPC =  observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = length(observe_DECODE.ALLMVPC);
            estudioworkingmemory('MVPCArray',observe_DECODE.CURRENTMVPC);
            Mvpcsetops.butttons_datasets.Value = observe_DECODE.CURRENTMVPC;
        end
        observe_DECODE.Reset_Best_paras_panel=2;
    end

end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%% 2024
checkfileindex=0;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr,filesep, file_name,'.mvpc'];
if exist(filenamex, 'file')~=0
    msgboxText =  ['This mvpc set already exists.\n'...;
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