%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

% ERPLAB Studio Toolbox
%

function varargout = f_mvpc_grandaverageGUI(varargin)
global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

gui_mvpc_grdavg = struct();
%-----------------------------Name the title----------------------------------------------
% global MVPC_grdavg_box_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    MVPC_grdavg_box_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Average Across MVPCsets (Grand Average)', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel  tool_link
elseif nargin == 1
    MVPC_grdavg_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Average Across MVPCsets (Grand Average)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    MVPC_grdavg_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Average Across MVPCsets (Grand Average)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @tool_link
end

%-----------------------------Draw the panel-------------------------------------
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_mvpc_gradavg(FonsizeDefault)
varargout{1} = MVPC_grdavg_box_gui;

    function drawui_mvpc_gradavg(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_mvpc_grdavg.DataSelBox = uiextras.VBox('Parent', MVPC_grdavg_box_gui,'BackgroundColor',ColorB_def);
        
        %%Parameters
        gui_mvpc_grdavg.weigavg_title = uiextras.HBox('Parent', gui_mvpc_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', gui_mvpc_grdavg.weigavg_title,...
            'String','MVPCsets','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        
        gui_mvpc_grdavg.mvpc_edit = uicontrol('Style','edit','Parent', gui_mvpc_grdavg.weigavg_title,...
            'String','','Enable','off','callback',@mvpc_edit,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_grdavg.mvpc_edit.KeyPressFcn = @mvpc_graverage_presskey;
        gui_mvpc_grdavg.paras{1} = str2num(gui_mvpc_grdavg.mvpc_edit.String);
        gui_mvpc_grdavg.mvpc_browse = uicontrol('Style','pushbutton','Parent', gui_mvpc_grdavg.weigavg_title,...
            'String','Browse','Enable','off','callback',@mvpc_browse,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_grdavg.mvpc_browse.KeyPressFcn = @mvpc_graverage_presskey;
        set(gui_mvpc_grdavg.weigavg_title,'Sizes',[70 -1 70]);
        try avg_def=  estudioworkingmemory('pop_mvpcaverager'); catch avg_def = [];  end;
        try sem_checkbox =avg_def{4};  catch   sem_checkbox=1;end
        if isempty(avg_def) || numel(avg_def)~=1 || (avg_def~=0 && avg_def~=1)
            avg_def=1;
        end
        gui_mvpc_grdavg.cbdatq_title = uiextras.HBox('Parent', gui_mvpc_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_mvpc_grdavg.sem_checkbox = uicontrol('Style','checkbox','Parent', gui_mvpc_grdavg.cbdatq_title,'Enable','off',...
            'String','','Value',avg_def,'callback',@sem_checkbox,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_mvpc_grdavg.sem_checkbox.String =  '<html>Compute point-by-point standard error of mean </html>';
        gui_mvpc_grdavg.sem_checkbox.KeyPressFcn = @mvpc_graverage_presskey;
        gui_mvpc_grdavg.paras{2} = gui_mvpc_grdavg.sem_checkbox.Value;
        try warning_checbox =avg_def{5};  catch   warning_checbox=0;end
        if isempty(warning_checbox) || numel(warning_checbox)~=1 || (warning_checbox~=0 && warning_checbox~=1)
            warning_checbox=0;
        end
        gui_mvpc_grdavg.warning_title = uiextras.HBox('Parent', gui_mvpc_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        gui_mvpc_grdavg.warning_checbox = uicontrol('Style','checkbox','Parent', gui_mvpc_grdavg.warning_title,'Enable','off',...
            'String','','Value',warning_checbox,'callback',@warning_checbox,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_mvpc_grdavg.warning_checbox.String =  '<html>Warning (to command line) if there are<br />any difference in decoding parameters</html>';
        gui_mvpc_grdavg.warning_checbox.KeyPressFcn = @mvpc_graverage_presskey;
        gui_mvpc_grdavg.paras{3} = gui_mvpc_grdavg.warning_checbox.Value;
        
        gui_mvpc_grdavg.location_title = uiextras.HBox('Parent', gui_mvpc_grdavg.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',gui_mvpc_grdavg.location_title);
        gui_mvpc_grdavg.cancel  = uicontrol('Style','pushbutton','Parent',gui_mvpc_grdavg.location_title,'Enable','off',...
            'String','Cancel','callback',@average_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        uiextras.Empty('Parent',gui_mvpc_grdavg.location_title);
        gui_mvpc_grdavg.run = uicontrol('Style','pushbutton','Parent',gui_mvpc_grdavg.location_title,'Enable','off',...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',gui_mvpc_grdavg.location_title);
        set(gui_mvpc_grdavg.location_title,'Sizes',[20 95 30 95 20]);
        set(gui_mvpc_grdavg.DataSelBox,'Sizes',[30,30,30,30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------checkbox for weighted average-----------------------------
    function mvpc_edit(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        MVPCArray  = str2num(gui_mvpc_grdavg.mvpc_edit.String);
        if isempty(MVPCArray) || any(MVPCArray(:)<1) || numel(MVPCArray)==1 || any(MVPCArray(:)> length(observe_DECODE.ALLMVPC))
            msgboxText =  ['Average Across MVPCsets (Grand Average)>MVPCsets: Selected MVPCsets should be between 1 and ',32,...
                num2str(length(observe_DECODE.ALLMVPC)),32,'and two mvpcsets should be included at least'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            MVPCArray = [1:length(observe_DECODE.ALLMVPC)];
        end
        MVPCArray = vect2colon(MVPCArray,'Sort', 'on');
        MVPCArray = erase(MVPCArray,{'[',']'});
        gui_mvpc_grdavg.mvpc_edit.String = MVPCArray;
        gui_mvpc_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.run.ForegroundColor = [1 1 1];
        MVPC_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.cancel.ForegroundColor = [1 1 1];
    end
%%------------------------Browse for mvpc sets-----------------------------
    function mvpc_browse(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.run.ForegroundColor = [1 1 1];
        MVPC_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.cancel.ForegroundColor = [1 1 1];
        for Numofbin = 1:length(observe_DECODE.ALLMVPC)
            try
                listb{Numofbin} = observe_DECODE.ALLMVPC.mvpcname;
            catch
                listb{Numofbin} = char(['MVPC',32,num2str(Numofbin)]);
            end
        end
        try
            indxlistb = 1:length(observe_DECODE.ALLMVPC);
        catch
            return;
        end
        titlename = 'Select MVPC(es):';
        if ~isempty(listb)
            MVPCselect = browsechanbinGUI(listb, indxlistb, titlename);
            if ~isempty(MVPCselect) || numel(MVPCselect)>1
                binset = vect2colon(MVPCselect,'Sort', 'on');
                binset = erase(binset,{'[',']'});
                gui_mvpc_grdavg.mvpc_edit.String=binset;
            else
                msgboxText =  ['Average Across MVPCsets (Grand Average)>MVPCsets:Must have two MVPCsets at least to select',];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
                return
            end
        else
            return;
        end
    end

%%------------------------compute SEM-------------------------------------
    function sem_checkbox(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.run.ForegroundColor = [1 1 1];
        MVPC_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.cancel.ForegroundColor = [1 1 1];
    end

    function warning_checbox(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_grdavg.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.run.ForegroundColor = [1 1 1];
        MVPC_grdavg_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_grdavg.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_grdavg.cancel.ForegroundColor = [1 1 1];
    end


%%--------------------------------cancel-----------------------------------
    function average_cancel(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        MVPCArray =  gui_mvpc_grdavg.paras{1};
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = 1:length(observe_DECODE.ALLMVPC);
        end
        binset = vect2colon(MVPCArray,'Sort', 'on');
        binset = erase(binset,{'[',']'});
        gui_mvpc_grdavg.mvpc_edit.String = binset;
        gui_mvpc_grdavg.paras{1} = str2num(gui_mvpc_grdavg.mvpc_edit.String);
        sem_checkbox = gui_mvpc_grdavg.paras{2};
        if isempty(sem_checkbox) || numel(sem_checkbox)~=1 || (sem_checkbox~=0 && sem_checkbox~=1)
            sem_checkbox=1;
        end
        gui_mvpc_grdavg.sem_checkbox.Value = sem_checkbox;
        gui_mvpc_grdavg.paras{2} = gui_mvpc_grdavg.sem_checkbox.Value;
        
        warning_checbox = gui_mvpc_grdavg.paras{3};
        if isempty(warning_checbox) || numel(warning_checbox)~=1 || (warning_checbox~=0 && warning_checbox~=1)
            warning_checbox=0;
        end
        gui_mvpc_grdavg.warning_checbox.Value = warning_checbox;
        gui_mvpc_grdavg.paras{3} = gui_mvpc_grdavg.warning_checbox.Value;
        gui_mvpc_grdavg.run.BackgroundColor =  [1 1 1];
        gui_mvpc_grdavg.run.ForegroundColor = [0 0 0];
        MVPC_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_grdavg.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_grdavg.cancel.ForegroundColor = [0 0 0];
    end

%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        MVPCArray = str2num(gui_mvpc_grdavg.mvpc_edit.String);
        gui_mvpc_grdavg.paras{2} = gui_mvpc_grdavg.sem_checkbox.Value;
        gui_mvpc_grdavg.paras{3} = gui_mvpc_grdavg.warning_checbox.Value;
        
        if isempty(MVPCArray) ||  numel(MVPCArray)<2
            msgboxText =  ['Average Across MVPCsets (Grand Average)  - Two MVPCsets,at least,were selected'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(MVPCArray(:)<1) || any(MVPCArray(:)>length(observe_DECODE.ALLMVPC))
            msgboxText =  ['Average Across MVPCsets (Grand Average)  - The index(es) should be between 1 and ',32,num2str(length(observe_DECODE.ALLMVPC))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        gui_mvpc_grdavg.run.BackgroundColor =  [1 1 1];
        gui_mvpc_grdavg.run.ForegroundColor = [0 0 0];
        MVPC_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_grdavg.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_grdavg.cancel.ForegroundColor = [0 0 0];
        
        gui_mvpc_grdavg.paras{1} = str2num(gui_mvpc_grdavg.mvpc_edit.String);
        gui_mvpc_grdavg.paras{2} = gui_mvpc_grdavg.sem_checkbox.Value;
        gui_mvpc_grdavg.paras{3} = gui_mvpc_grdavg.warning_checbox.Value;
        
        stderror = gui_mvpc_grdavg.sem_checkbox.Value;
        warnon = gui_mvpc_grdavg.warning_checbox.Value;
        if stderror==1
            stdsstr = 'on';
        else
            stdsstr = 'off';
        end
        if warnon==1
            warnon_str = 'on';
        else
            warnon_str = 'off';
        end
        
        estudioworkingmemory('pop_mvpcaverager',{[],0,'',stderror,warnon});
        
        
        ALLMVPC = observe_DECODE.ALLMVPC;
        
        MVPC = pop_mvpcaverager( ALLMVPC,'Mvpcsets',MVPCArray, 'SEM',  stdsstr,'Warning', warnon_str,'History','gui');
        
          pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =[pwd,filesep];
        end
        
        
        Answer = f_mvpc_save_multi_file(MVPC,1,'grandavg',1,pathName);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            MVPC = Answer{1};
            Save_file_label = Answer{2};
        end
        
        ALLMVPC = observe_DECODE.ALLMVPC;
        if Save_file_label==1
            [pathstr, file_name, ext] = fileparts(MVPC.filename);
            if isempty(file_name)
                file_name='grandavg';
            end
            MVPC.filename = [file_name,'.mvpc'];
            [MVPC, issave, MVPCCOM] = pop_savemymvpc(MVPC, 'mvpcname', MVPC.mvpcname, 'filename', MVPC.filename,...
                'filepath',MVPC.filepath,'Tooltype','estudio');
            if ~isempty(MVPCCOM)
                mvpch(MVPCCOM);
            end
        else
            MVPC.filename = '';
            MVPC.saved = 'no';
            MVPC.filepath = '';
        end
        if isempty(ALLMVPC)
            ALLMVPC = MVPC;
        else
            ALLMVPC(length(ALLMVPC)+1) = MVPC;
        end
        MVPCArray = length(ALLMVPC);
        observe_DECODE.ALLMVPC = ALLMVPC;
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
        observe_DECODE.CURRENTMVPC = MVPCArray;
        estudioworkingmemory('MVPCArray',MVPCArray);
        observe_DECODE.Count_currentMVPC=1;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=3
            return;
        end
        if isempty(observe_DECODE.MVPC) || length(observe_DECODE.ALLMVPC)<2
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        if ~isempty(observe_DECODE.MVPC) && ~isempty(observe_DECODE.ALLMVPC)
            MVPCArray= estudioworkingmemory('MVPCArray');
            if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
                MVPCArray = 1:length(observe_DECODE.ALLMVPC);
            end
            [serror, msgwrng] = f_checkmvpc(observe_DECODE.ALLMVPC,MVPCArray);
            if serror==1 || serror==2
                enableFlag = 'off';
            end
        end
        gui_mvpc_grdavg.mvpc_edit.Enable = enableFlag;
        gui_mvpc_grdavg.mvpc_browse.Enable = enableFlag;
        gui_mvpc_grdavg.sem_checkbox.Enable = enableFlag;
        gui_mvpc_grdavg.warning_checbox.Enable = enableFlag;
        gui_mvpc_grdavg.cancel.Enable = enableFlag;
        gui_mvpc_grdavg.run.Enable = enableFlag;
        if ~isempty(observe_DECODE.MVPC)
            MVPCArray= estudioworkingmemory('MVPCArray');
            if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
                MVPCArray = 1:length(observe_DECODE.ALLMVPC);
            end
            binset = vect2colon(MVPCArray,'Sort', 'on');
            binset = erase(binset,{'[',']'});
            gui_mvpc_grdavg.mvpc_edit.String = binset;
        end
        observe_DECODE.Count_currentMVPC=4;
    end

%%--------------press return to execute "Apply"----------------------------
    function mvpc_graverage_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_mesuretool');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            estudioworkingmemory('ERPTab_gravg',0);
            gui_mvpc_grdavg.run.BackgroundColor =  [1 1 1];
            gui_mvpc_grdavg.run.ForegroundColor = [0 0 0];
            MVPC_grdavg_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_mvpc_grdavg.cancel.BackgroundColor =  [1 1 1];
            gui_mvpc_grdavg.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_Best_paras_panel~=3
            return;
        end
        if ~isempty(observe_DECODE.ALLMVPC)
            MVPCArray = 1:length(observe_DECODE.ALLMVPC);
        else
            MVPCArray = [];
        end
        binset = vect2colon(MVPCArray,'Sort', 'on');
        binset = erase(binset,{'[',']'});
        gui_mvpc_grdavg.mvpc_edit.String = binset;
        gui_mvpc_grdavg.paras{1} = str2num(gui_mvpc_grdavg.mvpc_edit.String);
        gui_mvpc_grdavg.sem_checkbox.Value = 1;
        gui_mvpc_grdavg.paras{2} = gui_mvpc_grdavg.sem_checkbox.Value;
        gui_mvpc_grdavg.warning_checbox.Value = 0;
        gui_mvpc_grdavg.paras{3} = gui_mvpc_grdavg.warning_checbox.Value;
        observe_DECODE.Reset_Best_paras_panel=4;
    end

end