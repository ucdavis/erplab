%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2025

% ERPLAB Studio Toolbox
%

function varargout = f_mvpc_plotempgenrmatrixGUI(varargin)
global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

gui_mvpc_temporalgenermatrix = struct();
%-----------------------------Name the title----------------------------------------------
% global MVPC_confusion_box_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    MVPC_confusion_box_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Plot/Export Temporal Generalization Matrix', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel  tool_link
elseif nargin == 1
    MVPC_confusion_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot/Export Temporal Generalization Matrix',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    MVPC_confusion_box_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Plot/Export Temporal Generalization Matrix',...
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
        gui_mvpc_temporalgenermatrix.DataSelBox = uiextras.VBox('Parent', MVPC_confusion_box_gui,'BackgroundColor',ColorB_def);


        %%Latecies
        gui_mvpc_temporalgenermatrix.latency_title = uiextras.HBox('Parent', gui_mvpc_temporalgenermatrix.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_mvpc_temporalgenermatrix.latency_title,...
            'String','Latency to plot:','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_temporalgenermatrix.measure_latency = uicontrol('Style','edit','Parent', gui_mvpc_temporalgenermatrix.latency_title,...
            'String','','Enable','off','callback',@measure_latency,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_temporalgenermatrix.measure_latency.KeyPressFcn = @mvpc_graverage_presskey;
        set(gui_mvpc_temporalgenermatrix.latency_title,'Sizes',[90 -1]);

        %%latency example
        gui_mvpc_temporalgenermatrix.latency_title2 = uiextras.HBox('Parent', gui_mvpc_temporalgenermatrix.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_mvpc_temporalgenermatrix.latency_title2,...
            'String','','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_temporalgenermatrix.latency_exp = uicontrol('Style','text','Parent', gui_mvpc_temporalgenermatrix.latency_title2,...
            'String','','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        set(gui_mvpc_temporalgenermatrix.latency_title2,'Sizes',[30 -1]);

        text_instruct = '(e.g., -200 800 to plot average confusion matrix across -200 to 800 ms)';
        gui_mvpc_temporalgenermatrix.latency_exp.String = text_instruct;
        %%colors
        gui_mvpc_temporalgenermatrix.color_title = uiextras.HBox('Parent', gui_mvpc_temporalgenermatrix.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_mvpc_temporalgenermatrix.color_title,...
            'String','Color to plot:','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_temporalgenermatrix.measure_color = uicontrol('Style','popupmenu','Parent', gui_mvpc_temporalgenermatrix.color_title,...
            'String',{'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' },'Enable','off','callback',@measure_color,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_temporalgenermatrix.measure_color.KeyPressFcn = @mvpc_graverage_presskey;

        set(gui_mvpc_temporalgenermatrix.color_title,'Sizes',[80 -1]);
        %%default parameters
        def = estudioworkingmemory('pop_plotempgenerMatrix');
        try measure_latency =def{3} ; catch  measure_latency = [];end
        if ~isempty(measure_latency)
            if numel(measure_latency)~=2
                measure_latency = [];
            end
        end
        gui_mvpc_temporalgenermatrix.measure_latency.String = num2str(measure_latency);

        try measure_color = def{1};  catch  measure_color=1; end
        if isempty(measure_color) || numel(measure_color)~=1 || any(measure_color(:)<1) || any(measure_color(:)>8)
            measure_color=1;
        end
        gui_mvpc_temporalgenermatrix.measure_color.Value = measure_color;
        gui_mvpc_temporalgenermatrix.paras{1} = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        gui_mvpc_temporalgenermatrix.paras{2} = gui_mvpc_temporalgenermatrix.measure_color.Value;
        %%Color limits
        try limitauto =def{10}; catch limitauto =1; end
        if isempty(limitauto) || numel(limitauto)~=1 || (limitauto~=0 && limitauto~=1)
            limitauto=1;
        end
        try colorlimit = def{11}; catch colorlimit = []; end
        if numel(colorlimit)~=2 || min(colorlimit(:))>1 || max(colorlimit(:))<0
            colorlimit = [];
        end
        try limimin = colorlimit(1); catch limimin=0;  end
        try limimax = colorlimit(2); catch limimax=1;  end
        gui_mvpc_temporalgenermatrix.color_limitstitle = uiextras.HBox('Parent', gui_mvpc_temporalgenermatrix.DataSelBox,'BackgroundColor',ColorB_def);
        gui_mvpc_temporalgenermatrix.color_limiauto = uicontrol('Style','checkbox','Parent', gui_mvpc_temporalgenermatrix.color_limitstitle,'Value',limitauto,...
            'String','Auto, limit: min ','Enable','off','callback',@color_limiauto,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_mvpc_temporalgenermatrix.color_limimin = uicontrol('Style','edit','Parent', gui_mvpc_temporalgenermatrix.color_limitstitle,...
            'String',num2str(limimin),'Enable','off','callback',@color_limimin,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_temporalgenermatrix.color_limimin.KeyPressFcn = @mvpc_graverage_presskey;
        uicontrol('Style','text','Parent',gui_mvpc_temporalgenermatrix.color_limitstitle,...
            'String',', max','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_temporalgenermatrix.color_limimax = uicontrol('Style','edit','Parent', gui_mvpc_temporalgenermatrix.color_limitstitle,...
            'String',num2str(limimax),'Enable','off','callback',@color_limimax,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        set(gui_mvpc_temporalgenermatrix.color_limitstitle,'Sizes',[110 60 30 60]);
        gui_mvpc_temporalgenermatrix.paras{3} = gui_mvpc_temporalgenermatrix.color_limiauto.Value;
        gui_mvpc_temporalgenermatrix.paras{4} = [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];


        gui_mvpc_temporalgenermatrix.location_title1 = uiextras.HBox('Parent', gui_mvpc_temporalgenermatrix.DataSelBox,'BackgroundColor',ColorB_def);
        % uiextras.Empty('Parent',gui_mvpc_temporalgenermatrix.location_title1);
        gui_mvpc_temporalgenermatrix.location_title = uiextras.HBox('Parent', gui_mvpc_temporalgenermatrix.DataSelBox,'BackgroundColor',ColorB_def);
        % uiextras.Empty('Parent',gui_mvpc_temporalgenermatrix.location_title);
        gui_mvpc_temporalgenermatrix.cancel  = uicontrol('Style','pushbutton','Parent',gui_mvpc_temporalgenermatrix.location_title,'Enable','off',...
            'String','Cancel','callback',@average_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        gui_mvpc_temporalgenermatrix.export_ops  = uicontrol('Style','pushbutton','Parent',gui_mvpc_temporalgenermatrix.location_title,'Enable','off',...
            'String','Export','callback',@average_export,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        % uiextras.Empty('Parent',gui_mvpc_temporalgenermatrix.location_title);
        gui_mvpc_temporalgenermatrix.run = uicontrol('Style','pushbutton','Parent',gui_mvpc_temporalgenermatrix.location_title,'Enable','off',...
            'String','Plot','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        % uiextras.Empty('Parent',gui_mvpc_temporalgenermatrix.location_title);
        % set(gui_mvpc_temporalgenermatrix.location_title,'Sizes',[20 95 30 95 20]);
        set(gui_mvpc_temporalgenermatrix.DataSelBox,'Sizes',[25,35,30,20,5,30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------------color limits------------------------------
    function color_limiauto(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [1 1 1];
        if  gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            enableFlag = 'off';
            gui_mvpc_temporalgenermatrix.color_limimin.String = '0';
            gui_mvpc_temporalgenermatrix.color_limimax.String = '1';
        else
            enableFlag = 'on';
        end
        gui_mvpc_temporalgenermatrix.color_limimin.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimax.Enable = enableFlag;
    end

%%------------------------min of color limits------------------------------
    function color_limimin(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [1 1 1];
        color_limimin = str2num(gui_mvpc_temporalgenermatrix.color_limimin.String);
        if isempty(color_limimin) || numel(color_limimin)~=1
            gui_mvpc_temporalgenermatrix.color_limimin.String = '';
        end
    end

%%--------------------max of color limits----------------------------------
    function color_limimax(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [1 1 1];
        color_limimax = str2num( gui_mvpc_temporalgenermatrix.color_limimax.String);
        if isempty(color_limimax) || numel(color_limimax)~=1
            gui_mvpc_temporalgenermatrix.color_limimax.String = '';
        end
    end


%%----------------------------latencies------------------------------------
    function measure_latency(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [1 1 1];
        measure_latency = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        if isempty(measure_latency)
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
        end
        if any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end))
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix  - The latency should be between ',32,num2tr(observe_DECODE.MVPC.times(1)),32,'and',32,num2tr(observe_DECODE.MVPC.times(2))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end

        if numel(measure_latency)>=2
            gui_mvpc_temporalgenermatrix.measure_latency.String = num2str(measure_latency(1:2));
        else
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
        end
    end

%%---------------------------colors----------------------------------------
    function measure_color(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [1 1 1];
    end


%%--------------------------------cancel-----------------------------------
    function average_cancel(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end


        try measure_latency =gui_mvpc_temporalgenermatrix.paras{1} ; catch  measure_latency = [];end
        if ~isempty(measure_latency) && (any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end)))
            measure_latency = [];
        end
        if ~isempty(measure_latency)
            if numel(measure_latency)~=2
                measure_latency = [];
            end
        end
        gui_mvpc_temporalgenermatrix.measure_latency.String = num2str(measure_latency);

        try measure_color = gui_mvpc_temporalgenermatrix.paras{2};  catch  measure_color=1; end
        if isempty(measure_color) || numel(measure_color)~=1 || any(measure_color(:)<1) || any(measure_color(:)>8)
            measure_color=1;
        end
        gui_mvpc_temporalgenermatrix.measure_color.Value = measure_color;

        try color_limiauto = gui_mvpc_temporalgenermatrix.paras{3}; catch color_limiauto=1; end
        if isempty(color_limiauto) || numel(color_limiauto)~=1 || (color_limiauto~=0 && color_limiauto~=1)
            color_limiauto=1;
        end
        gui_mvpc_temporalgenermatrix.color_limiauto.Value=color_limiauto;

        if gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            colorlimits = [0 1];
        else
            try colorlimits= gui_mvpc_temporalgenermatrix.paras{4}; catch colorlimits = []; end
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
        end
        try color_limimin =colorlimits(1); catch colorlimits=0; end
        try color_limimax =colorlimits(2); catch color_limimax=1; end
        gui_mvpc_temporalgenermatrix.color_limimin.String = num2str(color_limimin);
        gui_mvpc_temporalgenermatrix.color_limimax.String = num2str(color_limimax);
        if  gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_temporalgenermatrix.color_limimin.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimax.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.paras{1} = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        gui_mvpc_temporalgenermatrix.paras{2} = gui_mvpc_temporalgenermatrix.measure_color.Value;
        gui_mvpc_temporalgenermatrix.paras{3} = gui_mvpc_temporalgenermatrix.color_limiauto.Value;
        gui_mvpc_temporalgenermatrix.paras{4} = [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [0 0 0];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [0 0 0];
    end
%---------------------------Export confusion matrix-----------------------
    function average_export(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end

        measure_latency = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        if isempty(measure_latency)
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix> Export - The latency is EMPTY'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end))
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix>Export - The latency should be between ',32,num2tr(observe_DECODE.MVPC.times(1)),32,'and',32,num2tr(observe_DECODE.MVPC.times(2))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end

        if numel(measure_latency)~=2
            msgboxText =  ['Plot Temporal Generalization Matrix>Export - The latency should be two numbers for "Average Confusion Matrix between two latencies".'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end


        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end

        estudioworkingmemory('f_Decode_proces_messg','Plot Temporal Generalization Matrix>Export');
        observe_DECODE.Process_messg =1;


        plot_cmap = gui_mvpc_temporalgenermatrix.measure_color.Value;

        if gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            colorlimits = [0 1];  color_limiauto=1;
        else
            colorlimits= [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
            color_limiauto=0;
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
            gui_mvpc_temporalgenermatrix.color_limimin.String = '';
            gui_mvpc_temporalgenermatrix.color_limimax.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix>RUN - Color limits are invalid.'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end


        def  = estudioworkingmemory('pop_plotempgenerMatrix');
        if isempty(def)
            def = {1, 1, [], 1,0,[pwd,filesep],3,0,1,1,[0 1]};
            %def{1} = colormap
            %def{2} = format (1: fig, 2: png);
            %def{3} = times in [];
            %def{4} = save(1/def) or no save
        end

        def{1} = plot_cmap; def{3} = measure_latency;def{10} = color_limiauto;def{11} = colorlimits;


        enableFlag = 'off';
        gui_mvpc_temporalgenermatrix.measure_latency.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.measure_color.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.cancel.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.run.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limiauto.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimin.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimax.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.export_ops.Enable = enableFlag;


        ALLMVPC= observe_DECODE.ALLMVPC;
        %
        % Open plot confusion GUI
        %
        app = feval('plotTempGMGUI',observe_DECODE.ALLMVPC,MVPCArray(1),def);
        waitfor(app,'FinishButton',1);
        try
            answer = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            observe_DECODE.Count_currentMVPC=5;
            disp('User selected Cancel');
            return
        end
        if isempty(answer)
            observe_DECODE.Process_messg =2;
            return
        end

        plot_cmap     = answer{1};%plot_colormap
        tp =   answer{2}; % 0;1
        pname = answer{3};
        frmt = answer{4};
        savec = answer{5};
        %warnon    = answer {4};
        cmaps = {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
        frmts = {'fig','png','pdf','svg'};

        savefile =  answer{6};
        filepathname = answer{7};
        Decimal = answer{8};
        istime    = answer{9};
        tunit     = answer{10};


        %def = {actualnset, optioni, mvpcset,stderror};
        def = {plot_cmap,frmt, tp, savec,savefile,filepathname,Decimal,istime,tunit,color_limiauto,colorlimits};
        estudioworkingmemory('pop_plotempgenerMatrix', def);


        if savec == 1
            savestr = 'on';
        else
            savestr = 'off';
        end
        %
        % Somersault
        %
        if istime==1
            time = 'on';
        else
            time = 'off';
        end
        if  tunit==1
            tunitstr = 'milliseconds';
        else
            tunitstr = 'seconds';

        end

        if savefile
            Filesavestr = 'on';
        else
            Filesavestr = 'off';
        end


        % ColorLimits = [];
        MVPCCOM =pop_plotempgenerMatrix(ALLMVPC, 'MVPCindex',MVPCArray,'Times',tp, 'ColorLimits',colorlimits,...
            'Figpath',pname, 'Colormap', cmaps{plot_cmap}, 'Format',frmts{frmt}, 'FigSaveas',savestr,...
            'FileSaveas',Filesavestr,'Filepath',filepathname,'Decimal',Decimal, 'time', time, 'timeunit', tunitstr,'History', 'gui');


        if isempty(MVPCCOM)
            observe_DECODE.Process_messg =2;
            return;
        end
        mvpch(MVPCCOM);
        observe_DECODE.Count_currentMVPC=5;
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [0 0 0];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [0 0 0];
        gui_mvpc_temporalgenermatrix.paras{1} = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        gui_mvpc_temporalgenermatrix.paras{2} = gui_mvpc_temporalgenermatrix.measure_color.Value;
        gui_mvpc_temporalgenermatrix.paras{3} = gui_mvpc_temporalgenermatrix.color_limiauto.Value;
        gui_mvpc_temporalgenermatrix.paras{4} = [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
        observe_DECODE.Process_messg =2;

    end


%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        measure_latency = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        if isempty(measure_latency)
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix>RUN - The latency is EMPTY and the default will be used'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            % return;
            measure_latency = [observe_DECODE.MVPC.times(1),observe_DECODE.MVPC.times(end)];
            gui_mvpc_temporalgenermatrix.measure_latency.String = num2str(measure_latency);
        end
        if any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end))
            gui_mvpc_temporalgenermatrix.measure_latency.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix>RUN - The latency should be between ',32,num2tr(observe_DECODE.MVPC.times(1)),32,'and',32,num2tr(observe_DECODE.MVPC.times(2))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if numel(measure_latency)~=2
            msgboxText =  ['Plot Temporal Generalization Matrix>RUN - The latency should be two numbers for "Average Confusion Matrix between two latencies".'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            colorlimits = [0 1];  color_limiauto=1;
        else
            colorlimits= [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
            color_limiauto=0;
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
            gui_mvpc_temporalgenermatrix.color_limimin.String = '';
            gui_mvpc_temporalgenermatrix.color_limimax.String = '';
            msgboxText =  ['Plot Temporal Generalization Matrix>RUN - Color limits are invalid.'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [0 0 0];
        gui_mvpc_temporalgenermatrix.export_ops.BackgroundColor =  [1 1 1];
        gui_mvpc_temporalgenermatrix.export_ops.ForegroundColor = [0 0 0];
        gui_mvpc_temporalgenermatrix.paras{1} = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        gui_mvpc_temporalgenermatrix.paras{2} = gui_mvpc_temporalgenermatrix.measure_color.Value;
        gui_mvpc_temporalgenermatrix.paras{3} = gui_mvpc_temporalgenermatrix.color_limiauto.Value;
        gui_mvpc_temporalgenermatrix.paras{4} = [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
        ALLMVPC = observe_DECODE.ALLMVPC;
        plot_cmap = gui_mvpc_temporalgenermatrix.measure_color.Value;
        cmaps = {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
        % tp = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['Plot Temporal Generalization Matrix',32,32,32,32,datestr(datetime('now')),'\n']);
        for Numofmvpc = 1:numel(MVPCArray)
            % MVPCCOM= pop_plotempgenerMatrix(ALLMVPC, 'Times',tp,'Type',meas, 'MVPCindex',MVPCArray(Numofmvpc),...
            %     'Colormap', cmaps{plot_cmap}, 'History', 'script','Tooltype','estudio','ColorLimits',colorlimits);
            MVPCCOM =pop_plotempgenerMatrix(ALLMVPC, 'MVPCindex',MVPCArray(Numofmvpc),'Times',measure_latency, 'ColorLimits',colorlimits,...
                'Figpath','', 'Colormap', cmaps{plot_cmap},  'FigSaveas','off','History', 'script','Tooltype','estudio');
        end
        fprintf([MVPCCOM]);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        mvpch(MVPCCOM);

        def  = erpworkingmemory('pop_plotempgenerMatrix');
        if isempty(def)
            def = {1, 1, [], 1,0,'',3,0,1,1,[0 1]};
            %def{1} = colormap
            %def{2} = format (1: fig, 2: png);
            %def{3} = times in [];
            %def{4} = save(1/def) or no save
        end
        def{1} = plot_cmap; def{3} = measure_latency;def{10} = color_limiauto;def{11} = colorlimits;
        estudioworkingmemory('pop_plotempgenerMatrix', def);
        observe_DECODE.Count_currentMVPC=5;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=5
            return;
        end
        if isempty(observe_DECODE.MVPC)
            enableFlag = 'off';
        else
            if ~isempty(observe_DECODE.MVPC.TGM)
                enableFlag = 'on';
            else
                enableFlag = 'off';
            end
        end
        gui_mvpc_temporalgenermatrix.measure_latency.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.measure_color.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.cancel.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.run.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limiauto.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimin.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimax.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.export_ops.Enable = enableFlag;
        try measure_latency =str2num(gui_mvpc_temporalgenermatrix.measure_latency.String) ; catch  measure_latency = [];end
        if ~isempty(observe_DECODE.MVPC)
            if ~isempty(measure_latency) && (any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end)))
                measure_latency = [observe_DECODE.MVPC.times(1),observe_DECODE.MVPC.times(end)];
            elseif isempty(measure_latency)
                measure_latency = [observe_DECODE.MVPC.times(1),observe_DECODE.MVPC.times(end)];
            end
        end
        if ~isempty(measure_latency)
            if numel(measure_latency)~=2
                measure_latency = [];
            end
        end
        if gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            colorlimits = [0 1];  color_limiauto=1;
        else
            colorlimits= [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
            color_limiauto=0;
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
        end
        try color_limimin =colorlimits(1); catch colorlimits=0; end
        try color_limimax =colorlimits(2); catch color_limimax=1; end
        gui_mvpc_temporalgenermatrix.color_limimin.String = num2str(color_limimin);
        gui_mvpc_temporalgenermatrix.color_limimax.String = num2str(color_limimax);
        if  gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_temporalgenermatrix.color_limimin.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimax.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.measure_latency.String = num2str(measure_latency);
        gui_mvpc_temporalgenermatrix.paras{1} = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        gui_mvpc_temporalgenermatrix.paras{2} = gui_mvpc_temporalgenermatrix.measure_color.Value;
        gui_mvpc_temporalgenermatrix.paras{3} = gui_mvpc_temporalgenermatrix.color_limiauto.Value;
        gui_mvpc_temporalgenermatrix.paras{4} = [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];
        observe_DECODE.Count_currentMVPC=6;
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
            gui_mvpc_temporalgenermatrix.run.BackgroundColor =  [1 1 1];
            gui_mvpc_temporalgenermatrix.run.ForegroundColor = [0 0 0];
            MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_mvpc_temporalgenermatrix.cancel.BackgroundColor =  [1 1 1];
            gui_mvpc_temporalgenermatrix.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%---------------------------Reset parameters------------------------------
    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_Best_paras_panel~=5
            return;
        end
        gui_mvpc_temporalgenermatrix.measure_latency.String = '';
        gui_mvpc_temporalgenermatrix.measure_color.Value=1;
        gui_mvpc_temporalgenermatrix.color_limiauto.Value=1;
        gui_mvpc_temporalgenermatrix.color_limimin.String = '0';
        gui_mvpc_temporalgenermatrix.color_limimax.String = '1';
        if  gui_mvpc_temporalgenermatrix.color_limiauto.Value==1
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_temporalgenermatrix.color_limimin.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.color_limimax.Enable = enableFlag;
        gui_mvpc_temporalgenermatrix.paras{1} = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        gui_mvpc_temporalgenermatrix.paras{2} = gui_mvpc_temporalgenermatrix.measure_color.Value;
        gui_mvpc_temporalgenermatrix.paras{3} = gui_mvpc_temporalgenermatrix.color_limiauto.Value;
        gui_mvpc_temporalgenermatrix.paras{4} = [str2num(gui_mvpc_temporalgenermatrix.color_limimin.String),str2num(gui_mvpc_temporalgenermatrix.color_limimax.String)];

        tp = str2num(gui_mvpc_temporalgenermatrix.measure_latency.String);
        text_instruct = '(e.g., -200 800 to plot average confusion matrix across -200 to 800 ms)';
        gui_mvpc_temporalgenermatrix.latency_exp.String = text_instruct;

        def = {1, 1, tp, 1,0,'',3,0,1,1,[0 1]};
        estudioworkingmemory('pop_plotempgenerMatrix',def);
        observe_DECODE.Reset_Best_paras_panel=6;
    end
end