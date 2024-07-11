%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

% ERPLAB Studio Toolbox
%

function varargout = f_mvpc_plotconfusionGUI(varargin)
global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

gui_mvpc_confusion = struct();
%-----------------------------Name the title----------------------------------------------
% global MVPC_confusion_box_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    MVPC_confusion_box_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot Confusion Matrices', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel  tool_link
elseif nargin == 1
    MVPC_confusion_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Confusion Matrices',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    MVPC_confusion_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot Confusion Matrices',...
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
varargout{1} = MVPC_confusion_box_gui;

    function drawui_mvpc_gradavg(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_mvpc_confusion.DataSelBox = uiextras.VBox('Parent', MVPC_confusion_box_gui,'BackgroundColor',ColorB_def);
        
        %%Parameters
        gui_mvpc_confusion.weigavg_title = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', gui_mvpc_confusion.weigavg_title,...
            'String','Value to plot:','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        
        gui_mvpc_confusion.measure_method = uicontrol('Style','popupmenu','Parent', gui_mvpc_confusion.weigavg_title,...
            'String',{'Timepoint Confusion Matrix','Average Confusion Matrix between two latencies'},'Enable','off','callback',@measure_method,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_confusion.measure_method.KeyPressFcn = @mvpc_graverage_presskey;
        set(gui_mvpc_confusion.weigavg_title,'Sizes',[90 -1]);
        
        %%Latecies
        gui_mvpc_confusion.latency_title = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_mvpc_confusion.latency_title,...
            'String','Latency to plot:','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_confusion.measure_latency = uicontrol('Style','edit','Parent', gui_mvpc_confusion.latency_title,...
            'String','','Enable','off','callback',@measure_latency,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_confusion.measure_latency.KeyPressFcn = @mvpc_graverage_presskey;
        set(gui_mvpc_confusion.latency_title,'Sizes',[90 -1]);
        
        %%latency example
        gui_mvpc_confusion.latency_title2 = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_mvpc_confusion.latency_title2,...
            'String','','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_confusion.latency_exp = uicontrol('Style','text','Parent', gui_mvpc_confusion.latency_title2,...
            'String','','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        set(gui_mvpc_confusion.latency_title2,'Sizes',[30 -1]);
        if gui_mvpc_confusion.measure_method.Value == 1
            text_instruct = '(e.g., 300 to plot confusion matrix at 300ms or 100:50:350 to plot at 100,...,350 ms)' ;
        else
            text_instruct = '(e.g., 200 250 to plot average confusion matrix across 200 to 250 ms)';
        end
        gui_mvpc_confusion.latency_exp.String = text_instruct;
        %%colors
        gui_mvpc_confusion.color_title = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_mvpc_confusion.color_title,...
            'String','Color to plot:','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_confusion.measure_color = uicontrol('Style','popupmenu','Parent', gui_mvpc_confusion.color_title,...
            'String',{'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' },'Enable','off','callback',@measure_color,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_confusion.measure_color.KeyPressFcn = @mvpc_graverage_presskey;
        
        set(gui_mvpc_confusion.color_title,'Sizes',[80 -1]);
        %%default parameters
        def = estudioworkingmemory('pop_plotconfusions');
        try measure_method =def{1};catch measure_method=1; end
        if isempty(measure_method) || numel(measure_method)~=1 || (measure_method~=1 && measure_method~=2)
            measure_method=1;
        end
        gui_mvpc_confusion.measure_method.Value = measure_method;
        
        try measure_latency =def{4} ; catch  measure_latency = [];end
        if ~isempty(measure_latency) && gui_mvpc_confusion.measure_method.Value ==2
            if numel(measure_latency)~=2
                measure_latency = [];
            end
        end
        gui_mvpc_confusion.measure_latency.String = num2str(measure_latency);
        
        try measure_color = def{2};  catch  measure_color=1; end
        if isempty(measure_color) || numel(measure_color)~=1 || any(measure_color(:)<1) || any(measure_color(:)>8)
            measure_color=1;
        end
        gui_mvpc_confusion.measure_color.Value = measure_color;
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        
        gui_mvpc_confusion.location_title = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',gui_mvpc_confusion.location_title);
        gui_mvpc_confusion.cancel  = uicontrol('Style','pushbutton','Parent',gui_mvpc_confusion.location_title,'Enable','off',...
            'String','Cancel','callback',@average_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        uiextras.Empty('Parent',gui_mvpc_confusion.location_title);
        gui_mvpc_confusion.run = uicontrol('Style','pushbutton','Parent',gui_mvpc_confusion.location_title,'Enable','off',...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',gui_mvpc_confusion.location_title);
        set(gui_mvpc_confusion.location_title,'Sizes',[20 95 30 95 20]);
        set(gui_mvpc_confusion.DataSelBox,'Sizes',[30, 25,35,30,30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------checkbox for weighted average-----------------------------
    function measure_method(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_confusion.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_confusion.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.cancel.ForegroundColor = [1 1 1];
        if gui_mvpc_confusion.measure_method.Value == 1
            text_instruct = '(e.g., 300 to plot confusion matrix at 300ms or 100:50:350 to plot at 100,...,350 ms)' ;
        else
            text_instruct = '(e.g., 200 250 to plot average confusion matrix across 200 to 250 ms)';
        end
        gui_mvpc_confusion.latency_exp.String = text_instruct;
    end

%%----------------------------latencies------------------------------------
    function measure_latency(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_confusion.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_confusion.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.cancel.ForegroundColor = [1 1 1];
        measure_latency = str2num(gui_mvpc_confusion.measure_latency.String);
        if isempty(measure_latency)
            gui_mvpc_confusion.measure_latency.String = '';
        end
        if any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end))
            gui_mvpc_confusion.measure_latency.String = '';
            msgboxText =  ['Plot Confusion Matrices  - The latency should be between ',32,num2tr(observe_DECODE.MVPC.times(1)),32,'and',32,num2tr(observe_DECODE.MVPC.times(2))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if gui_mvpc_confusion.measure_method.Value==2
            if numel(measure_latency)>=2
                gui_mvpc_confusion.measure_latency.String = num2str(measure_latency(1:2));
            else
                gui_mvpc_confusion.measure_latency.String = '';
            end
        end
    end

%%---------------------------colors----------------------------------------
    function measure_color(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_confusion.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_confusion.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.cancel.ForegroundColor = [1 1 1];
    end


%%--------------------------------cancel-----------------------------------
    function average_cancel(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        try measure_method =gui_mvpc_confusion.paras{1};catch measure_method=1; end
        if isempty(measure_method) || numel(measure_method)~=1 || (measure_method~=1 && measure_method~=2)
            measure_method=1;
        end
        gui_mvpc_confusion.measure_method.Value = measure_method;
        
        try measure_latency =gui_mvpc_confusion.paras{2} ; catch  measure_latency = [];end
        if ~isempty(measure_latency) && (any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end)))
            measure_latency = [];
        end
        if ~isempty(measure_latency) && gui_mvpc_confusion.measure_method.Value ==2
            if numel(measure_latency)~=2
                measure_latency = [];
            end
        end
        gui_mvpc_confusion.measure_latency.String = num2str(measure_latency);
        
        try measure_color = gui_mvpc_confusion.paras{3};  catch  measure_color=1; end
        if isempty(measure_color) || numel(measure_color)~=1 || any(measure_color(:)<1) || any(measure_color(:)>8)
            measure_color=1;
        end
        gui_mvpc_confusion.measure_color.Value = measure_color;
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        gui_mvpc_confusion.run.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.cancel.ForegroundColor = [0 0 0];
    end

%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        
        measure_latency = str2num(gui_mvpc_confusion.measure_latency.String);
        if isempty(measure_latency)
            gui_mvpc_confusion.measure_latency.String = '';
            gui_mvpc_confusion.measure_latency.String = '';
            msgboxText =  ['Plot Confusion Matrices>RUN - The latency is EMPTY'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end))
            gui_mvpc_confusion.measure_latency.String = '';
            msgboxText =  ['Plot Confusion Matrices>RUN - The latency should be between ',32,num2tr(observe_DECODE.MVPC.times(1)),32,'and',32,num2tr(observe_DECODE.MVPC.times(2))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if gui_mvpc_confusion.measure_method.Value==2
            if numel(measure_latency)~=2
                msgboxText =  ['Plot Confusion Matrices>RUN - The latency should be two numbers for "Average Confusion Matrix between two latencies".'];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        
        gui_mvpc_confusion.run.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.cancel.ForegroundColor = [0 0 0];
        
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        
        ALLMVPC = observe_DECODE.ALLMVPC;
        plot_menu = gui_mvpc_confusion.measure_method.Value;
        if plot_menu == 1
            meas = 'timepoint';
        elseif plot_menu==2
            meas = 'average';
        end
        plot_cmap = gui_mvpc_confusion.measure_color.Value;
        cmaps = {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
        tp = str2num(gui_mvpc_confusion.measure_latency.String);
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['Plot Confusion Matrices',32,32,32,32,datestr(datetime('now')),'\n']);
        for Numofmvpc = 1:numel(MVPCArray)
            MVPCCOM= pop_plotconfusions(ALLMVPC, 'Times',tp,'Type',meas, 'MVPCindex',MVPCArray(Numofmvpc),...
                'Colormap', cmaps{plot_cmap}, 'History', 'script','Tooltype','estudio');
        end
        fprintf([MVPCCOM]);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        eegh(MVPCCOM);
        def = {plot_menu, plot_cmap,1, tp, 1};
        estudioworkingmemory('pop_plotconfusions', def);
        observe_DECODE.Count_currentMVPC=5;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=4
            return;
        end
        if isempty(observe_DECODE.MVPC)
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_confusion.measure_method.Enable = enableFlag;
        gui_mvpc_confusion.measure_latency.Enable = enableFlag;
        gui_mvpc_confusion.measure_color.Enable = enableFlag;
        gui_mvpc_confusion.cancel.Enable = enableFlag;
        gui_mvpc_confusion.run.Enable = enableFlag;
        try measure_latency =str2num(gui_mvpc_confusion.measure_latency.String) ; catch  measure_latency = [];end
        if ~isempty(observe_DECODE.MVPC)
            if ~isempty(measure_latency) && (any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end)))
                measure_latency = [];
            end
        end
        if ~isempty(measure_latency) && gui_mvpc_confusion.measure_method.Value ==2
            if numel(measure_latency)~=2
                measure_latency = [];
            end
        end
        gui_mvpc_confusion.measure_latency.String = num2str(measure_latency);
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        observe_DECODE.Count_currentMVPC=5;
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
            estudioworkingmemory('ERPTab_confusion',0);
            gui_mvpc_confusion.run.BackgroundColor =  [1 1 1];
            gui_mvpc_confusion.run.ForegroundColor = [0 0 0];
            MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_mvpc_confusion.cancel.BackgroundColor =  [1 1 1];
            gui_mvpc_confusion.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_erp_paras_panel~=4
            return;
        end
        gui_mvpc_confusion.measure_method.Value=1;
        gui_mvpc_confusion.measure_latency.String = '';
        gui_mvpc_confusion.measure_color.Value=1;
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        if gui_mvpc_confusion.measure_method.Value == 1
            text_instruct = '(e.g., 300 to plot confusion matrix at 300ms or 100:50:350 to plot at 100,...,350 ms)' ;
        else
            text_instruct = '(e.g., 200 250 to plot average confusion matrix across 200 to 250 ms)';
        end
        gui_mvpc_confusion.latency_exp.String = text_instruct;
        observe_DECODE.Reset_Best_paras_panel=5;
    end

end