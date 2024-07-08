% BESTset selector panel
%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

% ERPLAB Studio Toolbox
%


function varargout = f_decode_bestsetsGUI(varargin)
global observe_DECODE;
global EStudio_gui_erp_totl;
addlistener(observe_DECODE,'Count_currentbest_change',@Count_currentbest_change);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

Bestsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_bestset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'BESTsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_bestset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'BESTsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_bestset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'BESTsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

varargout{1} = box_bestset_gui;

% Draw the ui
    function drawui_bestset(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        vBox = uiextras.VBox('Parent', box_bestset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5,'BackgroundColor',ColorB_def);
        
        %%-----------------------ERPset display---------------------------------------
        BESTlistName =  getBESTsets();
        Edit_label = 'off';
        
        Bestsetops.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
            2,'String', BESTlistName,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        try Bestsetops.butttons_datasets.Value=1; catch end;
        set(vBox, 'Sizes', 150);
        
        %%---------------------Options for BESTsets-----------------------------------------------------
        Bestsetops.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        Bestsetops.dupeselected = uicontrol('Parent', Bestsetops.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Bestsetops.renameselected = uicontrol('Parent', Bestsetops.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Bestsetops.suffix = uicontrol('Parent', Bestsetops.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        
        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        Bestsetops.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Bestsetops.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', ...
            'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Bestsetops.refresh_erpset = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Refresh',...
            'Callback', @refresh_erpset,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        
        Bestsetops.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save',...
            'Callback', @save_best,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Bestsetops.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save a Copy', ...
            'Callback', @save_bestas,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Bestsetops.curr_folder = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder',...
            'Callback', @curr_folder,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(buttons4,'Sizes',[70 90 95])
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------duplicate the selected BESTsets-----------------------------
    function duplicateSelected(source,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Duplicate');
        observe_DECODE.Process_messg =1;
        
        BESTArray= Bestsetops.butttons_datasets.Value;
        if isempty(BESTArray)
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        
        ALLBEST = observe_DECODE.ALLBEST;
        [ALLBEST, bestcom] = pop_duplicatbest(ALLBEST,'BESTArray', BESTArray,'History','gui');
        
        if isempty(ALLBEST) || isempty(bestcom)
            estudioworkingmemory('f_Decode_proces_messg','BESTsets>Duplicate:user selected cancel');
            observe_DECODE.Process_messg =2;
            return;
        end
        eegh(bestcom);
        observe_DECODE.ALLBEST = ALLBEST;
        
        BESTlistName =  getBESTsets();
        %%Reset the display in ERPset panel
        Bestsetops.butttons_datasets.String = BESTlistName;
        Bestsetops.butttons_datasets.Min = 1;
        Bestsetops.butttons_datasets.Max = length(BESTlistName)+1;
        
        try
            BESTArray =  [length(observe_DECODE.ALLBEST)-numel(BESTArray)+1:length(observe_DECODE.ALLBEST)];
            Bestsetops.butttons_datasets.Value = BESTArray;
            observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST)-numel(BESTArray)+1;
        catch
            BESTArray = length(observe_DECODE.ALLBEST);
            Bestsetops.butttons_datasets.Value =  BESTArray;
            observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST);
        end
        observe_DECODE.BEST = observe_DECODE.ALLBEST(observe_DECODE.CURRENTBEST);
        assignin('base','BEST',observe_DECODE.BEST);
        assignin('base','ALLBEST',ALLBEST);
        assignin('base','CURRENTBEST',observe_DECODE.CURRENTBEST);
        estudioworkingmemory('BESTArray',BESTArray);
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentbest = 1;
    end


%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Rename');
        observe_DECODE.Process_messg =1;
        
        BESTArray= Bestsetops.butttons_datasets.Value;
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        app = feval('Decode_Tab_rename_gui',observe_DECODE.ALLBEST(BESTArray),BESTArray);
        waitfor(app,'Finishbutton',1);
        try
            bestnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(bestnames)
            return;
        end
        
        ALLBEST_out = [];
        ALLBEST = observe_DECODE.ALLBEST(BESTArray);
        [ALLBEST, BESTCOM] = pop_renambest( ALLBEST, 'bestnames',bestnames,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(BESTCOM)
            return;
        end
        for Numofbest = 1:numel(BESTArray)
            BEST = ALLBEST(Numofbest);
            if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
            end
            if isempty(ALLBEST_out)
                ALLBEST_out = BEST;
            else
                ALLBEST_out(length(ALLBEST_out)+1)=BEST;
            end
        end
        
        
        observe_DECODE.ALLBEST(BESTArray) = ALLBEST_out;
        observe_DECODE.BEST = observe_DECODE.ALLBEST(observe_DECODE.CURRENTBEST);
        BESTlistName =  getBESTsets();
        Bestsetops.butttons_datasets.String = BESTlistName;
        Bestsetops.butttons_datasets.Min = 1;
        Bestsetops.butttons_datasets.Max = length(BESTlistName)+1;
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentbest=2;
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Add Suffix');
        observe_DECODE.Process_messg =1;
        
        BESTArray= Bestsetops.butttons_datasets.Value;
        if isempty(BESTArray)
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        
        suffixstr = f_EEG_suffix_gui('Suffix',2);
        if isempty(suffixstr)
            return;
        end
        
        
        ALLBEST_out = [];
        ALLBEST = observe_DECODE.ALLBEST(BESTArray);
        [ALLBEST, BESTCOM] = pop_suffixbest( ALLBEST, 'suffixstr',suffixstr,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(BESTCOM)
            return;
        end
        for Numofbest = 1:numel(BESTArray)
            BEST = ALLBEST(Numofbest);
            if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
            end
            if isempty(ALLBEST_out)
                ALLBEST_out = BEST;
            else
                ALLBEST_out(length(ALLBEST_out)+1)=BEST;
            end
        end
        
        observe_DECODE.ALLBEST(BESTArray) = ALLBEST_out;
        observe_DECODE.BEST = observe_DECODE.ALLBEST(observe_DECODE.CURRENTBEST);
        BESTlistName =  getBESTsets();
        Bestsetops.butttons_datasets.String = BESTlistName;
        Bestsetops.butttons_datasets.Min = 1;
        Bestsetops.butttons_datasets.Max = length(BESTlistName)+1;
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentbest = 2;
    end

%%-------------------------------fresh ------------------------------------
    function refresh_erpset(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Refresh');
        observe_DECODE.Process_messg =1;
        try
            ALLBEST = evalin('base', 'ALLBEST');
        catch
            ALLBEST = [];
        end
        try
            BEST = evalin('base', 'BEST');
        catch
            BEST = [];
        end
        try
            CURRENTBEST = evalin('base', 'CURRENTBEST');
        catch
            CURRENTBEST = 1;
        end
        
        if isempty(ALLBEST) && ~isempty(ALLBEST)
            ALLBEST = BEST;
            CURRENTBEST =1;
        end
        if ~isempty(ALLBEST) && isempty(BEST)
            if isempty(CURRENTBEST) || numel(CURRENTBEST)~=1 || any(CURRENTBEST(:)>length(ALLBEST))
                CURRENTBEST = length(ALLBEST);
            end
            try
                BEST =  observe_DECODE.ALLBEST(CURRENTBEST);
            catch
                BEST = [];
            end
        end
        observe_DECODE.ALLBEST= ALLBEST;
        try observe_DECODE.ALLBEST(CURRENTBEST) = BEST;catch  end
        
        observe_DECODE.BEST= BEST;
        observe_DECODE.CURRENTBEST= CURRENTBEST;
        
        assignin('base','CURRENTBEST',CURRENTBEST);
        assignin('base','BEST',BEST);
        assignin('base','ALLBEST',ALLBEST);
        estudioworkingmemory('BESTArray',CURRENTBEST);
        BESTlistName =  getBESTsets();
        Bestsetops.butttons_datasets.String = BESTlistName;
        Bestsetops.butttons_datasets.Min = 1;
        Bestsetops.butttons_datasets.Max = length(BESTlistName)+1;
        if any(CURRENTBEST(:)<1)
            Bestsetops.butttons_datasets.Value=1;
        else
            Bestsetops.butttons_datasets.Value = CURRENTBEST;
        end
        observe_DECODE.Count_currentbest=2;
        observe_DECODE.Process_messg =2;
    end

%%---------------------Load ERP--------------------------------------------
    function load(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Load');
        observe_DECODE.Process_messg =1;
        
        [filename, filepath] = uigetfile({'*.best'}, ...
            'Load BESTsets', ...
            'MultiSelect', 'on');
        if isequal(filename,0)
            return;
        end
        
        [BEST,ALLBEST] = pop_loadbest( 'filename', filename, 'filepath', filepath,'History','gui' );
        
        observe_DECODE.ALLBEST = ALLBEST;
        
        BESTlistName =  getBESTsets();
        if isempty(observe_DECODE.ALLBEST)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
        observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST);
        Bestsetops.butttons_datasets.Value = observe_DECODE.CURRENTBEST;
        Bestsetops.butttons_datasets.String = BESTlistName;
        Bestsetops.dupeselected.Enable=Edit_label;
        Bestsetops.renameselected.Enable=Edit_label;
        Bestsetops.suffix.Enable= Edit_label;
        Bestsetops.refresh_erpset.Enable= 'on';
        Bestsetops.clearselected.Enable=Edit_label;
        Bestsetops.savebutton.Enable= Edit_label;
        Bestsetops.saveasbutton.Enable=Edit_label;
        Bestsetops.curr_folder.Enable='on';
        Bestsetops.butttons_datasets.Enable = Edit_label;
        Bestsetops.append.Enable = Edit_label;
        BESTArray = observe_DECODE.CURRENTBEST;
        estudioworkingmemory('BESTArray',BESTArray);
        Bestsetops.butttons_datasets.Min=1;
        Bestsetops.butttons_datasets.Max=length(BESTlistName)+1;
        assignin('base','BEST',observe_DECODE.BEST);
        assignin('base','ALLBEST',observe_DECODE.ALLBEST);
        assignin('base','CURRENTBEST',observe_DECODE.CURRENTBEST);
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentbest = 2;
        
        if EStudio_gui_erp_totl.ERP_autoplot==1
            
        end
    end

%%----------------------Clear the selected BESTsets-------------------------
    function cleardata(source,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Clear');
        observe_DECODE.Process_messg =1;
        BESTArray = Bestsetops.butttons_datasets.Value;
        ALLBEST = observe_DECODE.ALLBEST;
        [ALLBEST,LASTCOM] = pop_deletebestset(ALLBEST,'BESTsets', BESTArray, 'Saveas', 'off','History', 'gui' );
        if isempty(LASTCOM)
            return;
        end
        
        if isempty(ALLBEST)
            observe_DECODE.ALLBEST = [];
            observe_DECODE.BEST = [];
            observe_DECODE.CURRENTBEST  = 0;
            assignin('base','BEST',observe_DECODE.BEST)
        else
            observe_DECODE.ALLBEST = ALLBEST;
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST  = length(observe_DECODE.ALLBEST);
        end
        BESTlistName =  getBESTsets();
        if isempty(observe_DECODE.ALLBEST)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        Bestsetops.butttons_datasets.String = BESTlistName;
        if observe_DECODE.CURRENTBEST>0
            Bestsetops.butttons_datasets.Value = observe_DECODE.CURRENTBEST;
        else
            Bestsetops.butttons_datasets.Value=1;
        end
        Bestsetops.dupeselected.Enable=Edit_label;
        Bestsetops.renameselected.Enable=Edit_label;
        Bestsetops.suffix.Enable= Edit_label;
        Bestsetops.refresh_erpset.Enable= 'on';
        Bestsetops.clearselected.Enable=Edit_label;
        Bestsetops.savebutton.Enable= Edit_label;
        Bestsetops.saveasbutton.Enable=Edit_label;
        Bestsetops.curr_folder.Enable='on';
        Bestsetops.butttons_datasets.Min =1;
        Bestsetops.butttons_datasets.Max =length(BESTlistName)+1;
        Bestsetops.butttons_datasets.Enable = Edit_label;
        Bestsetops.append.Enable = Edit_label;
        BESTArray = observe_DECODE.CURRENTBEST;
        estudioworkingmemory('BESTArray',BESTArray);
        observe_DECODE.Process_messg =2;
        observe_DECODE.Count_currentbest = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            
        end
    end


%-------------------------- Save selected BESTsets-------------------------------------------
    function save_best(source,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Save');
        observe_DECODE.Process_messg =1;
        
        pathNamedef =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathNamedef)
            pathNamedef =  cd;
        end
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        
        
        for Numoferp = 1:length(BESTArray)
            BEST = observe_DECODE.ALLBEST(BESTArray(Numoferp));
            pathName = BEST.filepath;
            if isempty(pathName)
                pathName = pathNamedef;
            end
            FileName = BEST.filename;
            if isempty(FileName)
                FileName = BEST.bestname;
            end
            [pathx, filename, ext] = fileparts(FileName);
            filename = [filename '.best'];
            checkfileindex = checkfilexists([pathName,filesep,filename]);
            if checkfileindex==1
                [BEST, issave, BESTCOM] = pop_savemybest(BEST, 'bestname', BEST.bestname, 'filename',...
                    filename, 'filepath',pathName,'History','gui');
                if Numoferp==1
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    fprintf(['*BESTsets>Save*',32,32,32,32,datestr(datetime('now')),'\n']);
                    fprintf( [BESTCOM]);
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                end
                
                if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                    olderpcom = cellstr(BEST.EEGhistory);
                    newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                    BEST.EEGhistory = char(newerpcom);
                elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                    BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
                end
                
            end
            observe_DECODE.ALLBEST(BESTArray(Numoferp)) = BEST;
        end
        observe_DECODE.BEST = observe_DECODE.ALLBEST(observe_DECODE.CURRENTBEST);
        assignin('base','ALLBESTCOM',ALLBESTCOM);
        try assignin('base','ERPCOM',ERPCOM);catch; end
        observe_DECODE.Count_currentbest = 1;
        observe_DECODE.Process_messg =2;
    end

%------------------------- Save as-----------------------------------------
    function save_bestas(~,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_Decode_proces_messg','BESTsets>Save a Copy');
        observe_DECODE.Process_messg =1;
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray(:)>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        
        Answer = f_BEST_save_as_GUI(observe_DECODE.ALLBEST,BESTArray,'_copy',1,pathName);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLBEST_out = Answer{1};
        end
        ALLBEST = observe_DECODE.ALLBEST;
        for Numoferp = 1:length(BESTArray)
            BEST = ALLBEST_out(BESTArray(Numoferp));
            if ~isempty(BEST.filename)
                filename = BEST.filename;
            else
                filename = [BEST.bestname,'.best'];
            end
            [pathstr, erpfilename, ext] = fileparts(filename);
            ext = '.best';
            erpFilename = char(strcat(erpfilename,ext));
            
            [BEST, issave, BESTCOM] = pop_savemybest(BEST, 'bestname', BEST.bestname,...
                'filename', erpFilename, 'filepath',BEST.filepath,'History','gui');
            
            if Numoferp==1
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*BESTsets>Save a Copy*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf( [BESTCOM]);
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end
            
            if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
            end
            ALLBEST(length(ALLBEST)+1) = BEST;
        end
        observe_DECODE.ALLBEST = ALLBEST;
        BESTlistName =  getBESTsets();
        %%Reset the display in ERPset panel
        Bestsetops.butttons_datasets.String = BESTlistName;
        Bestsetops.butttons_datasets.Min = 1;
        Bestsetops.butttons_datasets.Max = length(BESTlistName)+1;
        
        try
            BESTArray =  [length(observe_DECODE.ALLBEST)-numel(BESTArray)+1:length(observe_DECODE.ALLBEST)];
            Bestsetops.butttons_datasets.Value = BESTArray;
            observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST)-numel(BESTArray)+1;
        catch
            BESTArray = length(observe_DECODE.ALLBEST);
            Bestsetops.butttons_datasets.Value =  BESTArray;
            observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST);
        end
        observe_DECODE.BEST = observe_DECODE.ALLBEST(observe_DECODE.CURRENTBEST);
        estudioworkingmemory('BESTArray',BESTArray);
        
        Bestsetops.butttons_datasets.Value = BESTArray;
        observe_DECODE.Count_currentbest = 2;
        observe_DECODE.Process_messg =2;
    end


%---------------- Enable/Disable dot structure-----------------------------
    function curr_folder(~,~)
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
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
        if ~isempty(observe_DECODE.BEST)
            BEST = observe_DECODE.BEST;
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*BESTsets>Current Folder*',32,32,32,32,datestr(datetime('now')),'\n']);
            if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                observe_DECODE.BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                observe_DECODE.BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        
        estudioworkingmemory('EEG_save_folder',sel_path1);
        %         observe_DECODE.Count_currentbest = 20;
    end


%-----------------select the ERPset of interest--------------------------
    function selectdata(source,~)
        if isempty(observe_DECODE.BEST)
            observe_DECODE.Count_currentbest=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_decodetab_panelchanges();
        if ~isempty(messgStr)
            observe_DECODE.Count_currentbest=eegpanelIndex+1;%%call the functions from the other panel
        end
        BESTArray = source.Value;
        estudioworkingmemory('BESTArray',BESTArray);
        
        Current_ERP_selected=BESTArray(1);
        observe_DECODE.CURRENTBEST = Current_ERP_selected;
        observe_DECODE.BEST = observe_DECODE.ALLBEST(Current_ERP_selected);
        observe_DECODE.Count_currentbest = 2;
        if EStudio_gui_erp_totl.ERP_autoplot==1
            
        end
    end

%%%--------------Up this panel--------------------------------------
    function Count_currentbest_change(~,~)
        if observe_DECODE.Count_currentbest~=1
            return;
        end
        if ~isempty(observe_DECODE.ALLBEST) && ~isempty(observe_DECODE.BEST)
            BESTArray= estudioworkingmemory('BESTArray');
            if isempty(BESTArray) || (~isempty(BESTArray) && any(BESTArray(:)>length(observe_DECODE.ALLBEST)))
                BESTArray = length(observe_DECODE.ALLBEST);
                observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
                observe_DECODE.CURRENTBEST = BESTArray;
                estudioworkingmemory('BESTArray',BESTArray);
            end
            BESTlistName =  getBESTsets();
            Bestsetops.butttons_datasets.String = BESTlistName;
            Bestsetops.butttons_datasets.Value = BESTArray;
            
            Bestsetops.butttons_datasets.Min=1;
            Bestsetops.butttons_datasets.Max=length(BESTlistName)+1;
            estudioworkingmemory('BESTArray',BESTArray);
            Bestsetops.butttons_datasets.Value = BESTArray;
            Bestsetops.butttons_datasets.Enable = 'on';
            Edit_label = 'on';
        else
            BESTlistName =  getBESTsets();
            BESTArray =1;
            Bestsetops.butttons_datasets.String = BESTlistName;
            Bestsetops.butttons_datasets.Value = BESTArray;
            Bestsetops.butttons_datasets.Min=1;
            Bestsetops.butttons_datasets.Max=length(BESTlistName)+1;
            estudioworkingmemory('BESTArray',BESTArray);
            Edit_label = 'off';
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if ViewerFlag==1
            Edit_label = 'off';
            Bestsetops.loadbutton.Enable='off';
        else
            Bestsetops.loadbutton.Enable='on';
        end
        Bestsetops.dupeselected.Enable=Edit_label;
        Bestsetops.renameselected.Enable=Edit_label;
        Bestsetops.suffix.Enable= Edit_label;
        Bestsetops.refresh_erpset.Enable= 'on';
        Bestsetops.clearselected.Enable=Edit_label;
        Bestsetops.savebutton.Enable= Edit_label;
        Bestsetops.saveasbutton.Enable=Edit_label;
        Bestsetops.curr_folder.Enable='on';
        Bestsetops.butttons_datasets.Enable = Edit_label;
        Bestsetops.append.Enable = Edit_label;
        assignin('base','BEST',observe_DECODE.BEST);
        assignin('base','ALLBEST',observe_DECODE.ALLBEST);
        assignin('base','CURRENTBEST',observe_DECODE.CURRENTBEST);
        observe_DECODE.Count_currentbest = 2;
    end

%%------------------get the names of BESTsets-------------------------------
    function BESTlistName =  getBESTsets(ALLBEST)
        if nargin<1
            ALLBEST= observe_DECODE.ALLBEST;
        end
        BESTlistName = {};
        if ~isempty(ALLBEST)
            for ii = 1:length(ALLBEST)
                BESTlistName{ii,1} =    char(strcat(num2str(ii),'.',32, ALLBEST(ii).bestname));
            end
        else
            BESTlistName{1} = 'No BESTset is available' ;
        end
    end

    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_erp_paras_panel~=1
            return;
        end
        
        if ~isempty(observe_DECODE.ALLBEST)
            observe_DECODE.BEST =  observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',observe_DECODE.CURRENTBEST);
            Bestsetops.butttons_datasets.Value = observe_DECODE.CURRENTBEST;
        end
        observe_DECODE.Reset_erp_paras_panel=2;
    end

end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%% 2024
checkfileindex=0;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr,filesep, file_name,'.best'];
if exist(filenamex, 'file')~=0
    msgboxText =  ['This BEST set already exists.\n'...;
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