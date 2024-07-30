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
        %%Color limits
        try limitauto =def{6}; catch limitauto =1; end
        if isempty(limitauto) || numel(limitauto)~=1 || (limitauto~=0 && limitauto~=1)
            limitauto=1;
        end
        try colorlimit = def{7}; catch colorlimit = []; end
        if numel(colorlimit)~=2 || min(colorlimit(:))>1 || max(colorlimit(:))<0
            colorlimit = [];
        end
        try limimin = colorlimit(1); catch limimin=0;  end
        try limimax = colorlimit(2); catch limimax=1;  end
        gui_mvpc_confusion.color_limitstitle = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        gui_mvpc_confusion.color_limiauto = uicontrol('Style','checkbox','Parent', gui_mvpc_confusion.color_limitstitle,'Value',limitauto,...
            'String','Auto, limit: min ','Enable','off','callback',@color_limiauto,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_mvpc_confusion.color_limimin = uicontrol('Style','edit','Parent', gui_mvpc_confusion.color_limitstitle,...
            'String',num2str(limimin),'Enable','off','callback',@color_limimin,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        gui_mvpc_confusion.color_limimin.KeyPressFcn = @mvpc_graverage_presskey;
        uicontrol('Style','text','Parent',gui_mvpc_confusion.color_limitstitle,...
            'String',', max','Enable','on','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def);
        gui_mvpc_confusion.color_limimax = uicontrol('Style','edit','Parent', gui_mvpc_confusion.color_limitstitle,...
            'String',num2str(limimax),'Enable','off','callback',@color_limimax,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1]); % 2F
        set(gui_mvpc_confusion.color_limitstitle,'Sizes',[110 60 30 60]);
        gui_mvpc_confusion.paras{4} = gui_mvpc_confusion.color_limiauto.Value;
        gui_mvpc_confusion.paras{5} = [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
        
        
        gui_mvpc_confusion.location_title1 = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',gui_mvpc_confusion.location_title1);
        gui_mvpc_confusion.location_title = uiextras.HBox('Parent', gui_mvpc_confusion.DataSelBox,'BackgroundColor',ColorB_def);
        gui_mvpc_confusion.cancel  = uicontrol('Style','pushbutton','Parent',gui_mvpc_confusion.location_title,'Enable','off',...
            'String','Cancel','callback',@average_cancel,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        gui_mvpc_confusion.export_ops  = uicontrol('Style','pushbutton','Parent',gui_mvpc_confusion.location_title,'Enable','off',...
            'String','Export','callback',@average_export,'FontSize',FontSize_defualt,'BackgroundColor',[1 1 1],'Max',10); % 2F
        
        gui_mvpc_confusion.run = uicontrol('Style','pushbutton','Parent',gui_mvpc_confusion.location_title,'Enable','off',...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        set(gui_mvpc_confusion.DataSelBox,'Sizes',[30, 25,35,30,20,5,30]);
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
        gui_mvpc_confusion.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_confusion.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_confusion.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.export_ops.ForegroundColor = [1 1 1];
        if  gui_mvpc_confusion.color_limiauto.Value==1
            enableFlag = 'off';
            gui_mvpc_confusion.color_limimin.String = '0';
            gui_mvpc_confusion.color_limimax.String = '1';
        else
            enableFlag = 'on';
        end
        gui_mvpc_confusion.color_limimin.Enable = enableFlag;
        gui_mvpc_confusion.color_limimax.Enable = enableFlag;
    end

%%------------------------min of color limits------------------------------
    function color_limimin(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_confusion.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_confusion.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_confusion.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.export_ops.ForegroundColor = [1 1 1];
        color_limimin = str2num(gui_mvpc_confusion.color_limimin.String);
        if isempty(color_limimin) || numel(color_limimin)~=1
            gui_mvpc_confusion.color_limimin.String = '';
        end
    end

%%--------------------max of color limits----------------------------------
    function color_limimax(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        gui_mvpc_confusion.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_mvpc_confusion.run.ForegroundColor = [1 1 1];
        MVPC_confusion_box_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.cancel.ForegroundColor = [1 1 1];
        gui_mvpc_confusion.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.export_ops.ForegroundColor = [1 1 1];
        color_limimax = str2num( gui_mvpc_confusion.color_limimax.String);
        if isempty(color_limimax) || numel(color_limimax)~=1
            gui_mvpc_confusion.color_limimax.String = '';
        end
        
    end


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
        gui_mvpc_confusion.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.export_ops.ForegroundColor = [1 1 1];
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
        gui_mvpc_confusion.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.export_ops.ForegroundColor = [1 1 1];
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
        gui_mvpc_confusion.export_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_mvpc_confusion.export_ops.ForegroundColor = [1 1 1];
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
        
        try color_limiauto = gui_mvpc_confusion.paras{4}; catch color_limiauto=1; end
        if isempty(color_limiauto) || numel(color_limiauto)~=1 || (color_limiauto~=0 && color_limiauto~=1)
            color_limiauto=1;
        end
        gui_mvpc_confusion.color_limiauto.Value=color_limiauto;
        
        if gui_mvpc_confusion.color_limiauto.Value==1
            colorlimits = [0 1];
        else
            try colorlimits= gui_mvpc_confusion.paras{5}; catch colorlimits = []; end
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
        end
        try color_limimin =colorlimits(1); catch colorlimits=0; end
        try color_limimax =colorlimits(2); catch color_limimax=1; end
        gui_mvpc_confusion.color_limimin.String = num2str(color_limimin);
        gui_mvpc_confusion.color_limimax.String = num2str(color_limimax);
        if  gui_mvpc_confusion.color_limiauto.Value==1
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_confusion.color_limimin.Enable = enableFlag;
        gui_mvpc_confusion.color_limimax.Enable = enableFlag;
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        gui_mvpc_confusion.paras{4} = gui_mvpc_confusion.color_limiauto.Value;
        gui_mvpc_confusion.paras{5} = [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
        gui_mvpc_confusion.run.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.cancel.ForegroundColor = [0 0 0];
        gui_mvpc_confusion.export_ops.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.export_ops.ForegroundColor = [0 0 0];
    end
%%---------------------------Export confusion matrix-----------------------
    function average_export(~,~)
        if isempty(observe_DECODE.MVPC)
            observe_DECODE.Count_currentMVPC=1;
            return;
        end
        
        measure_latency = str2num(gui_mvpc_confusion.measure_latency.String);
        if isempty(measure_latency)
            gui_mvpc_confusion.measure_latency.String = '';
            msgboxText =  ['Plot Confusion Matrices>Export - The latency is EMPTY'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if any(measure_latency(:)<observe_DECODE.MVPC.times(1)) || any(measure_latency(:)>observe_DECODE.MVPC.times(end))
            gui_mvpc_confusion.measure_latency.String = '';
            msgboxText =  ['Plot Confusion Matrices>Export - The latency should be between ',32,num2tr(observe_DECODE.MVPC.times(1)),32,'and',32,num2tr(observe_DECODE.MVPC.times(2))];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if gui_mvpc_confusion.measure_method.Value==2
            if numel(measure_latency)~=2
                msgboxText =  ['Plot Confusion Matrices>Export - The latency should be two numbers for "Average Confusion Matrix between two latencies".'];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        
        MVPCArray= estudioworkingmemory('MVPCArray');
        if isempty(MVPCArray) || (~isempty(MVPCArray) && any(MVPCArray(:)>length(observe_DECODE.ALLMVPC)))
            MVPCArray = length(observe_DECODE.ALLMVPC);
            observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
            observe_DECODE.CURRENTMVPC = MVPCArray;
            estudioworkingmemory('MVPCArray',MVPCArray);
        end
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =[pwd,filesep];
        end
        
        defx =  estudioworkingmemory('pop_exportconfusions');
        def = {1,[],3,[pathName,filesep,'Confusion_matrix']};
        if isempty(defx)
            defx = def;
        end
        try defx{2} = measure_latency;catch end
        try PathNames=defx{4};catch PathNames=[pathName,filesep,'Confusion_matrix']; end
        [pathstr, erpfilename, ext] = fileparts(PathNames) ;
        if isempty(pathstr)
            pathstr = pathName;
        end
        if isempty(erpfilename)
            erpfilename = 'confusion_matrix';
        end
        pathName = [pathstr,filesep,erpfilename];
        try defx{4} = pathName;catch end
        estudioworkingmemory('pop_exportconfusions',defx);
        estudioworkingmemory('f_Decode_proces_messg','Plot Confusion Matrices>Export');
        observe_DECODE.Process_messg =1;
        
        
        def  = estudioworkingmemory('pop_exportconfusions');
        ALLMVPC= observe_DECODE.ALLMVPC;
        %
        % Open plot confusion GUI
        %
        app = feval('Save_Confusion_file_GUI',observe_DECODE.ALLMVPC,MVPCArray,def);
        waitfor(app,'Finishbutton',1);
        try
            answer = app.Output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return
        end
        if isempty(answer)
            observe_DECODE.Process_messg =2;
            return
        end
        
        plot_menu =   answer{1}; % 0;1
        tp = answer{2};
        decimalNum = answer{3};
        fileNames = answer{4};
        
        %def = {actualnset, optioni, mvpcset,stderror};
        def = {plot_menu, tp, decimalNum, fileNames};
        estudioworkingmemory('pop_exportconfusions', def);
        
        if plot_menu == 1
            %single timepoint confusion matrix
            meas = 'timepoint';
        elseif plot_menu==2
            %average across time window confusion matrix
            meas = 'average';
        end
        
        %
        % Somersault
        %
        MVPCCOM=pop_exportconfusions(ALLMVPC,MVPCArray, 'Times',tp,'Type',meas,...
            'fileNames',fileNames,'decimalNum',decimalNum,'History', 'gui','Tooltype','estudio');
        
        if isempty(MVPCCOM)
            observe_DECODE.Process_messg =2;
            return;
        end
        mvpch(MVPCCOM);
        observe_DECODE.Count_currentMVPC=5;
        gui_mvpc_confusion.run.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.cancel.ForegroundColor = [0 0 0];
        gui_mvpc_confusion.export_ops.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.export_ops.ForegroundColor = [0 0 0];
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        gui_mvpc_confusion.paras{4} = gui_mvpc_confusion.color_limiauto.Value;
        gui_mvpc_confusion.paras{5} = [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
        observe_DECODE.Process_messg =2;
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
        if gui_mvpc_confusion.color_limiauto.Value==1
            colorlimits = [0 1];  color_limiauto=1;
        else
            colorlimits= [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
            color_limiauto=0;
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
            gui_mvpc_confusion.color_limimin.String = '';
            gui_mvpc_confusion.color_limimax.String = '';
            msgboxText =  ['Plot Confusion Matrices>RUN - Color limits are invalid.'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        gui_mvpc_confusion.run.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.run.ForegroundColor = [0 0 0];
        MVPC_confusion_box_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_mvpc_confusion.cancel.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.cancel.ForegroundColor = [0 0 0];
        gui_mvpc_confusion.export_ops.BackgroundColor =  [1 1 1];
        gui_mvpc_confusion.export_ops.ForegroundColor = [0 0 0];
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        gui_mvpc_confusion.paras{4} = gui_mvpc_confusion.color_limiauto.Value;
        gui_mvpc_confusion.paras{5} = [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
        
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
                'Colormap', cmaps{plot_cmap}, 'History', 'script','Tooltype','estudio','ColorLimits',colorlimits);
        end
        fprintf([MVPCCOM]);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        mvpch(MVPCCOM);
        def = {plot_menu, plot_cmap,1, tp, 1,color_limiauto,colorlimits};
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
        gui_mvpc_confusion.color_limiauto.Enable = enableFlag;
        gui_mvpc_confusion.color_limimin.Enable = enableFlag;
        gui_mvpc_confusion.color_limimax.Enable = enableFlag;
        gui_mvpc_confusion.export_ops.Enable = enableFlag;
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
        if gui_mvpc_confusion.color_limiauto.Value==1
            colorlimits = [0 1];  color_limiauto=1;
        else
            colorlimits= [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
            color_limiauto=0;
        end
        if isempty(colorlimits) || numel(colorlimits)~=2 || min(colorlimits(:))>1 || max(colorlimits(:))<0
            colorlimits = [];
        end
        try color_limimin =colorlimits(1); catch colorlimits=0; end
        try color_limimax =colorlimits(2); catch color_limimax=1; end
        gui_mvpc_confusion.color_limimin.String = num2str(color_limimin);
        gui_mvpc_confusion.color_limimax.String = num2str(color_limimax);
        if  gui_mvpc_confusion.color_limiauto.Value==1
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_confusion.color_limimin.Enable = enableFlag;
        gui_mvpc_confusion.color_limimax.Enable = enableFlag;
        gui_mvpc_confusion.measure_latency.String = num2str(measure_latency);
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        gui_mvpc_confusion.paras{4} = gui_mvpc_confusion.color_limiauto.Value;
        gui_mvpc_confusion.paras{5} = [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
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

%%---------------------------Reset parameters------------------------------
    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_Best_paras_panel~=4
            return;
        end
        gui_mvpc_confusion.measure_method.Value=1;
        gui_mvpc_confusion.measure_latency.String = '';
        gui_mvpc_confusion.measure_color.Value=1;
        gui_mvpc_confusion.color_limiauto.Value=1;
        gui_mvpc_confusion.color_limimin.String = '0';
        gui_mvpc_confusion.color_limimax.String = '1';
        if  gui_mvpc_confusion.color_limiauto.Value==1
            enableFlag = 'off';
        else
            enableFlag = 'on';
        end
        gui_mvpc_confusion.color_limimin.Enable = enableFlag;
        gui_mvpc_confusion.color_limimax.Enable = enableFlag;
        gui_mvpc_confusion.paras{1} = gui_mvpc_confusion.measure_method.Value;
        gui_mvpc_confusion.paras{2} = str2num(gui_mvpc_confusion.measure_latency.String);
        gui_mvpc_confusion.paras{3} = gui_mvpc_confusion.measure_color.Value;
        gui_mvpc_confusion.paras{4} = gui_mvpc_confusion.color_limiauto.Value;
        gui_mvpc_confusion.paras{5} = [str2num(gui_mvpc_confusion.color_limimin.String),str2num(gui_mvpc_confusion.color_limimax.String)];
        
        if gui_mvpc_confusion.measure_method.Value == 1
            text_instruct = '(e.g., 300 to plot confusion matrix at 300ms or 100:50:350 to plot at 100,...,350 ms)' ;
        else
            text_instruct = '(e.g., 200 250 to plot average confusion matrix across 200 to 250 ms)';
        end
        gui_mvpc_confusion.latency_exp.String = text_instruct;
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =[pwd,filesep];
        end
        
        def = {1,[],3,[pathName,filesep,'Confusion_matrix']};
        estudioworkingmemory('pop_exportconfusions',def);
        observe_DECODE.Reset_Best_paras_panel=5;
    end

end