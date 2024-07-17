% D
%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

% ERPLAB Studio Toolbox
%


function varargout = f_decode_MVPA_GUI(varargin)
global observe_DECODE;

addlistener(observe_DECODE,'Count_currentbest_change',@Count_currentbest_change);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
Docode_do_mvpa = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_bestset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Multivariate Pattern Classification', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_bestset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Multivariate Pattern Classification', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_bestset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Multivariate Pattern Classification', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end


try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_do_mvpa(FonsizeDefault);

varargout{1} = box_bestset_gui;

% Draw the ui
    function drawui_do_mvpa(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        Docode_do_mvpa.vBox_decode = uiextras.VBox('Parent', box_bestset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        
        %%-----------------------Select classes To decode across-----------
        Edit_label = 'off';
        
        
        MVPCA_panelparas=estudioworkingmemory('MVPCA_panelparas');
        try Paras_mvpa = MVPCA_panelparas{1}; catch Paras_mvpa = [];end
        Docode_do_mvpa.select_classes_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.select_classes_title,...
            'String','Select Classes To Decode Across:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        %%class all vs custom
        try selclass_all = Paras_mvpa{1}; catch selclass_all = 1;end
        if isempty(selclass_all) || numel(selclass_all)~=1 || (selclass_all~=0 && selclass_all~=1)
            selclass_all=1;
        end
        Docode_do_mvpa.select_classes = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_all = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.select_classes ,'Value',selclass_all,...
            'String','ALL','callback',@selclass_all,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_all.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.selclass_custom = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.select_classes ,'Value',~selclass_all,...
            'String','Custom','callback',@selclass_custom,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_custom.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
        
        %%defined class
        Docode_do_mvpa.select_classes_custom = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.select_classes_custom,...
            'String','Class ID','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_custom_defined = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.select_classes_custom ,'Value',0,...
            'String',' ','callback',@selclass_custom_defined,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.selclass_custom_defined.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.selclass_custom_browse = uicontrol('Style', 'pushbutton','Parent', Docode_do_mvpa.select_classes_custom ,'Value',0,...
            'String','Browse','callback',@selclass_custom_browse,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.selclass_custom_browse.KeyPressFcn=  @decode_mvpc_presskey;
        set(Docode_do_mvpa.select_classes_custom,'Sizes',[60 -1 60]);
        try selclass_custom_defined = Paras_mvpa{2}; catch selclass_custom_defined = 1;end
        Docode_do_mvpa.selclass_custom_defined.String = num2str(selclass_custom_defined);
        Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        
        %%--------------------decoding parameters--------------------------
        Docode_do_mvpa.decode_paras_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.decode_paras_title ,...
            'String','Decoding Parameters:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.no_class_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  Docode_do_mvpa.no_class_title  ,...
            'String','Number of Classes/bins','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.no_class = uicontrol('Style', 'edit','Parent',  Docode_do_mvpa.no_class_title  ,'Value',0,...
            'String',' ','Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.no_class_title ,'Sizes',[140 -1]);
        %%chance
        Docode_do_mvpa.chance_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  Docode_do_mvpa.chance_title  ,...
            'String','Chance','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.chance = uicontrol('Style', 'edit','Parent',  Docode_do_mvpa.chance_title ,...
            'String',' ','Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.chance_title ,'Sizes',[140 -1]);
        %%Number of cross folds
        Docode_do_mvpa.folds_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  Docode_do_mvpa.folds_title  ,...
            'String','Cross-validation Blocks','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.foldsnum = uicontrol('Style', 'edit','Parent',  Docode_do_mvpa.folds_title,...
            'String',' ','callback',@foldsnum,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.folds_title ,'Sizes',[140 -1]);
        try foldsnum = Paras_mvpa{3}; catch foldsnum = 3;end
        if isempty(foldsnum) || numel(foldsnum)~=1 || any(foldsnum(:)<2)
            foldsnum=3;
        end
        Docode_do_mvpa.foldsnum.String = num2str(foldsnum);
        Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
        %%channels
        Docode_do_mvpa.channels_custom = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.channels_custom ,...
            'String','Channels','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.channels_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.channels_custom,...
            'String',' ','callback',@channels_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.channels_edit.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.channels_browse = uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.channels_custom ,...
            'String','Browse','callback',@channels_browse,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.channels_browse.KeyPressFcn=  @decode_mvpc_presskey;
        set(Docode_do_mvpa.channels_custom,'Sizes',[60 -1 60]);
        try channels_edit = Paras_mvpa{4}; catch channels_edit = [];end
        channels_edit = vect2colon(channels_edit,'Sort', 'on');
        channels_edit = erase(channels_edit,{'[',']'});
        Docode_do_mvpa.channels_edit.String = channels_edit;
        Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
        
        %%Iterations
        Docode_do_mvpa.iter_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.iter_title ,...
            'String','Iterations','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.iter_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.iter_title,...
            'String',' ','callback',@iter_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.iter_edit.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.iter_title );
        set(Docode_do_mvpa.iter_title,'Sizes',[60 -1 60]);
        try iter_edit = Paras_mvpa{5}; catch iter_edit = 100;end
        if isempty(iter_edit) || numel(iter_edit)~=1 || any(iter_edit(:)<1)
            iter_edit=100;
        end
        Docode_do_mvpa.iter_edit.String = num2str(iter_edit);
        Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
        
        %%Equalize trials
        Docode_do_mvpa.eq_trials_checkbox_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_checkbox = uicontrol('Style', 'checkbox','Parent', Docode_do_mvpa.eq_trials_checkbox_title,'Value',1,...
            'String','Equalize Trials','callback',@eq_trials_checkbox,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_checkbox.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_checkbox_title);
        set(Docode_do_mvpa.eq_trials_checkbox_title,'Sizes',[140 -1]);
        try eq_trials_checkbox = Paras_mvpa{6}; catch eq_trials_checkbox = 1;end
        if isempty(eq_trials_checkbox) || numel(eq_trials_checkbox)~=1 || (eq_trials_checkbox~=0 && eq_trials_checkbox~=1)
            eq_trials_checkbox=1;
        end
        Docode_do_mvpa.eq_trials_checkbox.Value=eq_trials_checkbox;
        Docode_do_mvpa.Paras{6} = Docode_do_mvpa.eq_trials_checkbox.Value;
        
        %%across Classes
        Docode_do_mvpa.eq_trials_acrclass_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrclass_title);
        Docode_do_mvpa.eq_trials_acrclas_radio = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.eq_trials_acrclass_title,'Value',1,...
            'String','Across Classes','callback',@eq_trials_acrclas_radio,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_acrclas_radio.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrclass_title);
        set(Docode_do_mvpa.eq_trials_acrclass_title,'Sizes',[20 140 -1]);
        try eq_trials_acrclas_radio = Paras_mvpa{7}; catch eq_trials_acrclas_radio = 1;end
        if isempty(eq_trials_acrclas_radio) ||  numel(eq_trials_acrclas_radio)~=1 || (eq_trials_acrclas_radio~=0 && eq_trials_acrclas_radio~=1)
            eq_trials_acrclas_radio=1;
        end
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=eq_trials_acrclas_radio;
        Docode_do_mvpa.Paras{7} = Docode_do_mvpa.eq_trials_acrclas_radio.Value;
        
        
        %%across bests
        Docode_do_mvpa.eq_trials_acrbest_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrbest_title);
        Docode_do_mvpa.eq_trials_acrbest_checkbox = uicontrol('Style', 'checkbox','Parent', Docode_do_mvpa.eq_trials_acrbest_title,'Value',1,...
            'String','Across BESTsets','callback',@eq_trials_acrbest_checkbox,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_acrclas_radio.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrbest_title);
        set(Docode_do_mvpa.eq_trials_acrbest_title,'Sizes',[40 140 -1]);
        try eq_trials_acrbest_checkbox = Paras_mvpa{8}; catch eq_trials_acrbest_checkbox = 1;end
        if isempty(eq_trials_acrbest_checkbox) || numel(eq_trials_acrbest_checkbox)~=1 || (eq_trials_acrbest_checkbox~=0 && eq_trials_acrbest_checkbox~=1)
            eq_trials_acrbest_checkbox=1;
        end
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=eq_trials_acrbest_checkbox;
        Docode_do_mvpa.Paras{8} = Docode_do_mvpa.eq_trials_acrbest_checkbox.Value;
        
        
        %%Manual Floor
        Docode_do_mvpa.manfloor_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.manfloor_title);
        Docode_do_mvpa.manfloor_radio = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.manfloor_title,'Value',~eq_trials_acrclas_radio,...
            'String','Manual Floor','callback',@manfloor_radio,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.manfloor_radio.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.manfloor_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.manfloor_title,...
            'String','','callback',@manfloor_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.manfloor_title,'Sizes',[20 140 -1]);
        try manfloor_edit = Paras_mvpa{9}; catch manfloor_edit = 1;end
        if isempty(manfloor_edit) || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
            manfloor_edit=1;
        end
        Docode_do_mvpa.manfloor_edit.String = num2str(manfloor_edit);
        Docode_do_mvpa.Paras{9} = str2num(Docode_do_mvpa.manfloor_edit.String);
        
        
        %%Table is to display the bin descriptions
        Docode_do_mvpa.bindecps_title2 = uiextras.HBox('Parent',Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.table_bins = uitable(  ...
            'Parent'        , Docode_do_mvpa.bindecps_title2,...
            'Data'          , [], ...
            'ColumnName'    , {'BEST File','Class ID','Class/Label','N(trials)','N(per ERP)'}, ...
            'RowName'    , [], ...
            'ColumnEditable',[false,false,false,false,false]);%%'CellEditCallback', @updatePlot
        Docode_do_mvpa.table_bins.Enable = 'off';
        
        %%-----------------------Cancel and Run----------------------------
        Docode_do_mvpa.detar_run_title = uiextras.HBox('Parent', Docode_do_mvpa.vBox_decode,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.mvpa_cancel = uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Cancel','callback',@mvpa_cancel,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.mvpa_ops = uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Options','callback',@mvpa_ops,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.mvpa_run = uicontrol('Style','pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Run','callback',@mvpa_run,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        
        set(Docode_do_mvpa.vBox_decode,'Sizes',[20 25 25 20 25 25 25 25 25 25 16 16 25 100 30]);
        try  Docode_do_mvpa.paras_ops = MVPCA_panelparas{2}; catch  Docode_do_mvpa.paras_ops = [];end
        if isempty(Docode_do_mvpa.paras_ops )
            Docode_do_mvpa.paras_ops = {1,1,1,[],1,0};
        end
        %%(1)Methods (1.SVM; 2.Crossnobis),
        %%(2)SVM coding (1: 1vs1 / 2: 1vsAll or empty - def: 1vsALL)
        %%(3)epochTimes (1:all, 2: pre, 3: post, 4:custom)
        %%(4)decodeTimes ([start,end]; def = []); % IN MS!
        %%(5)decode_every_Npoint(1 = every point)
        %%(6)parCompute (def = 0)
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%----------------------------------select all classes---------------------
    function selclass_all(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        Docode_do_mvpa.selclass_all.Value=1;
        Docode_do_mvpa.selclass_custom.Value=0;
        Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
        Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
        ClassArray = [1:observe_DECODE.BEST.nbin];
        ClassArray = vect2colon(ClassArray,'Sort', 'on');
        ClassArray = erase(ClassArray,{'[',']'});
        Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
        ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArraydef)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
            Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
            if ~isempty(errormess)
                msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
    end

%%------------------------radio custom classes-----------------------------
    function selclass_custom(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        
        Docode_do_mvpa.selclass_all.Value=0;
        Docode_do_mvpa.selclass_custom.Value=1;
        Docode_do_mvpa.selclass_custom_browse.Enable = 'on';
        Docode_do_mvpa.selclass_custom_defined.Enable = 'on';
        ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArraydef)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
            Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
        end
    end

%%--------------------------defined classes--------------------------------
    function selclass_custom_defined(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        
        ClassArray = Docode_do_mvpa.selclass_custom_defined.String;
        if isempty(ClassArray) || numel(ClassArray)<2
            msgboxText =  ['Multivariate Pattern Classification>Class ID:Must have two classes at least to decode',];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            ClassArray = [1:observe_DECODE.BEST.nbin];
        end
        if any(ClassArray(:)>observe_DECODE.BEST.nbin) || any(ClassArray(:)<1)
            msgboxText =  ['Multivariate Pattern Classification>Class ID: Index of selected classes must be between 1 and',32,num2str(observe_DECODE.BEST.nbin)];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            ClassArray = [1:observe_DECODE.BEST.nbin];
        end
        ClassArray = vect2colon(ClassArray,'Sort', 'on');
        ClassArray = erase(ClassArray,{'[',']'});
        Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
        ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArraydef)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
            Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
            if ~isempty(errormess)
                msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
    end
%%-------------------------Browse classes----------------------------------
    function selclass_custom_browse(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        BEST = observe_DECODE.BEST;
        for Numofbin = 1:length(BEST.bindesc)
            try
                listb{Numofbin} = char(strcat(num2str(Numofbin),'.',BEST.bindescr{Numofbin}));
            catch
                listb{Numofbin} = char(['Bin',32,num2str(Numofbin)]);
            end
        end
        try
            indxlistb = 1:BEST.nbin;
        catch
            return;
        end
        titlename = 'Select class(es):';
        %----------------judge the number of latency/latencies--------
        if ~isempty(listb)
            bin_label_select = browsechanbinGUI(listb, indxlistb, titlename);
            if ~isempty(bin_label_select) || numel(bin_label_select)>1
                binset = vect2colon(bin_label_select,'Sort', 'on');
                binset = erase(binset,{'[',']'});
                Docode_do_mvpa.selclass_custom_defined.String=binset;
            else
                msgboxText =  ['Multivariate Pattern Classification>Class ID:Must have two classes at least to decode',];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
                return
            end
        else
            msgboxText =  ['Multivariate Pattern Classification>Class ID>Browse-No bin information was found',];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArraydef)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
            Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
            if ~isempty(errormess)
                msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
    end
%%------------------------Numbr of class folds-----------------------------
    function foldsnum(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        Cossfolds = str2num(Docode_do_mvpa.foldsnum.String);
        if isempty(Cossfolds) || numel(Cossfolds)~=1 || any(Cossfolds(:)<1)
            Docode_do_mvpa.foldsnum.String = '3';
            Cossfolds=3;
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:It should be a single positive value',];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        else
            Cossfolds = ceil(Cossfolds);
            Docode_do_mvpa.foldsnum.String = num2str(Cossfolds);
        end
        
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%------------------------Edit:channels------------------------------------
    function channels_edit(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        ChanArray = str2num(Docode_do_mvpa.channels_edit.String);
        BEST = observe_DECODE.BEST;
        if isempty(ChanArray) || any(ChanArray(:)>BEST.nbchan) || any(ChanArray(:)<1)
            msgboxText =  ['Multivariate Pattern Classification>Channels:Index of channel must be between 1 and ',32,num2str(BEST.nbchan)];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            ChanArray = 1:BEST.nbchan;
        end
        ChanArray = vect2colon(ChanArray,'Sort', 'on');
        ChanArray = erase(ChanArray,{'[',']'});
        Docode_do_mvpa.channels_edit.String=ChanArray;
    end

%%-------------------------Browse:channels---------------------------------
    function channels_browse(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        BEST = observe_DECODE.BEST;
        for Numofbin = 1:BEST.nbchan
            try
                listb{Numofbin} = char(strcat(num2str(Numofbin),'.',BEST.chanlocs(Numofbin).labels));
            catch
                listb{Numofbin} = char(['Chan',32,num2str(Numofbin)]);
            end
        end
        try
            indxlistb = 1:BEST.nbchan;
        catch
            return;
        end
        titlename = 'Select chans:';
        %----------------judge the number of latency/latencies--------
        
        bin_label_select = browsechanbinGUI(listb, indxlistb, titlename);
        if ~isempty(bin_label_select)
            chanarray = vect2colon(bin_label_select,'Sort', 'on');
            chanarray = erase(chanarray,{'[',']'});
            Docode_do_mvpa.channels_edit.String=chanarray;
        else
            msgboxText =  ['Multivariate Pattern Classification>Channels:Must have one channel at least to decode',];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
    end

%%-------------------------------iterations--------------------------------
    function iter_edit(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        
        iter_edit = str2num(Docode_do_mvpa.iter_edit.String);
        if isempty(iter_edit) || numel(iter_edit)~=1 || any(iter_edit(iter_edit(:)<=0))
            msgboxText =  ['Multivariate Pattern Classification>Iterations:Iteration should be a single positive number'];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            iter_edit = 100;
        end
        Docode_do_mvpa.iter_edit.String = num2str(ceil(iter_edit));
    end

%%-----------------------Equalize trials:checkbox--------------------------
    function eq_trials_checkbox(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        if Docode_do_mvpa.eq_trials_checkbox.Value==1
            Enable_flag = 'on';
        else
            Enable_flag = 'off';
        end
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
        Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
        Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        if Docode_do_mvpa.eq_trials_checkbox.Value==1
            if  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
                Enable_flag = 'off';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
            else
                Enable_flag = 'on';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            end
            Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        end
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%-------------------------------across classes----------------------------
    function eq_trials_acrclas_radio(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
        Docode_do_mvpa.manfloor_radio.Value=0;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%-------------------------across bestsets---------------------------------
    function eq_trials_acrbest_checkbox(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end

%%------------------------Manual Floor-------------------------------------
    function manfloor_radio(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
        Docode_do_mvpa.manfloor_radio.Value=1;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.Enable = 'on';
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
    end


%%---------------------------------cancel----------------------------------
    function mvpa_cancel(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 1 1 1];
        Docode_do_mvpa.run.ForegroundColor = [0 0 0];
        box_bestset_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [1 1 1];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [0 0 0];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [1 1 1];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [0 0 0];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [1 1 1];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [0 0 0];
        
        Docode_do_mvpa.selclass_all.Value=  Docode_do_mvpa.Paras{1};
        Docode_do_mvpa.selclass_custom.Value = ~Docode_do_mvpa.Paras{1};
        Docode_do_mvpa.selclass_custom_defined.String = num2str(Docode_do_mvpa.Paras{2});
        ClassArraydef = [1:observe_DECODE.BEST.nbin];
        ClassArraydef = vect2colon(ClassArraydef,'Sort', 'on');
        ClassArraydef = erase(ClassArraydef,{'[',']'});
        if Docode_do_mvpa.selclass_all.Value==1
            Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
            Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
            Docode_do_mvpa.selclass_custom_defined.String = ClassArraydef;
        else
            ClassArray = str2num(Docode_do_mvpa.selclass_custom_defined.String);
            if isempty(ClassArray) || any(ClassArray(:)>observe_DECODE.BEST.nbin) || any(ClassArray(:)<1)
                Docode_do_mvpa.selclass_custom_defined.String = ClassArraydef;
            end
        end
        ClassArray = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArray)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArray));
            Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArray),-2));
        end
        
        foldsnum=  Docode_do_mvpa.Paras{3};
        if isempty(foldsnum) || numel(foldsnum)~=1 || any(foldsnum(:)<1)
            foldsnum = 3;
        end
        Docode_do_mvpa.foldsnum.String = num2str(foldsnum);
        
        %%channel
        channels_edit = Docode_do_mvpa.Paras{4};
        nbchan = observe_DECODE.BEST.nbchan;
        if isempty(channels_edit) || any(channels_edit(:)<0)  || any(channels_edit(:)>nbchan)
            channels_edit = 1:nbchan;
        end
        channels_edit = vect2colon(channels_edit,'Sort', 'on');
        channels_edit = erase(channels_edit,{'[',']'});
        Docode_do_mvpa.channels_edit.String = channels_edit;
        
        %%interations
        iter_edit =  Docode_do_mvpa.Paras{5};
        if isempty(iter_edit) || numel(iter_edit)~=1 || any(iter_edit(:)<1)
            iter_edit=100;
        end
        Docode_do_mvpa.iter_edit.String = num2str(iter_edit);
        
        eq_trials_checkbox = Docode_do_mvpa.Paras{6};
        if isempty(eq_trials_checkbox) || numel(eq_trials_checkbox)~=1 || (eq_trials_checkbox~=0 && eq_trials_checkbox~=1)
            eq_trials_checkbox=1;
        end
        
        Docode_do_mvpa.eq_trials_checkbox.Value = eq_trials_checkbox;
        eq_trials_acrclas_radio = Docode_do_mvpa.Paras{7};
        if isempty(eq_trials_acrclas_radio) || numel(eq_trials_acrclas_radio)~=1 || (eq_trials_acrclas_radio~=0 && eq_trials_acrclas_radio~=1)
            eq_trials_acrclas_radio=1;
        end
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=eq_trials_acrclas_radio;
        Docode_do_mvpa.manfloor_radio.Value= ~eq_trials_acrclas_radio;
        
        %%Equaliza trials
        if Docode_do_mvpa.eq_trials_checkbox.Value==1
            Enable_flag = 'on';
        else
            Enable_flag = 'off';
        end
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
        Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
        Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        if Docode_do_mvpa.eq_trials_checkbox.Value==1
            if  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
                Enable_flag = 'off';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
            else
                Enable_flag = 'on';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            end
            Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        end
        eq_trials_acrbest_checkbox = Docode_do_mvpa.Paras{8};
        if isempty(eq_trials_acrbest_checkbox) ||  numel(eq_trials_acrbest_checkbox)~=1 || (eq_trials_acrbest_checkbox~=0 && eq_trials_acrbest_checkbox~=1)
            eq_trials_acrbest_checkbox=1;
        end
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=eq_trials_acrbest_checkbox;
        
        manfloor_edit = Docode_do_mvpa.Paras{9};
        if  isempty(manfloor_edit)  || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
            manfloor_edit=1;
        end
        Docode_do_mvpa.manfloor_edit.String = num2str(manfloor_edit);
        
        Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
        Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
        Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
        Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
        Docode_do_mvpa.Paras{6} = Docode_do_mvpa.eq_trials_checkbox.Value;
        Docode_do_mvpa.Paras{7} = Docode_do_mvpa.eq_trials_acrclas_radio.Value;
        Docode_do_mvpa.Paras{8} = Docode_do_mvpa.eq_trials_acrbest_checkbox.Value;
        Docode_do_mvpa.Paras{9} = str2num(Docode_do_mvpa.manfloor_edit.String);
        
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
        %%if select crossvalidated mahalanobis
        try Methodops = Docode_do_mvpa.paras_ops{1}; catch Methodops=1; end
        if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2)
            Methodops=1;
        end
        if Methodops~=1
            Docode_do_mvpa.foldsnum.Enable = 'off';
        else
            Docode_do_mvpa.foldsnum.Enable = 'on';
        end
    end

%%-----------------------Optionss for MVPA----------------------------------
    function mvpa_ops(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        Docode_do_mvpa.run.ForegroundColor = [1 1 1];
        box_bestset_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [1 1 1];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [0.5137    0.7569    0.9176];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [1 1 1];
        
        app = feval('estudio_decode_mvpa_ops', observe_DECODE.BEST,Docode_do_mvpa.paras_ops); %cludgy way
        waitfor(app,'Finishbutton',1);
        try
            decoding_res = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            return
        end
        if isempty(decoding_res)
            return;
        end
        
        Docode_do_mvpa.paras_ops = decoding_res;
        try Methodops = Docode_do_mvpa.paras_ops{1}; catch Methodops=1; end
        if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2)
            Methodops=1;
        end
        if Methodops~=1
            Docode_do_mvpa.foldsnum.Enable = 'off';
        else
            Docode_do_mvpa.foldsnum.Enable = 'on';
        end
        
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
    end

%%-------------------------------Run---------------------------------------
    function mvpa_run(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            return;
        end
        Docode_do_mvpa.run.BackgroundColor =  [ 1 1 1];
        Docode_do_mvpa.run.ForegroundColor = [0 0 0];
        box_bestset_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [1 1 1];
        Docode_do_mvpa.mvpa_cancel.ForegroundColor = [0 0 0];
        Docode_do_mvpa.mvpa_ops.BackgroundColor =  [1 1 1];
        Docode_do_mvpa.mvpa_ops.ForegroundColor = [0 0 0];
        Docode_do_mvpa.mvpa_run.BackgroundColor =  [1 1 1];
        Docode_do_mvpa.mvpa_run.ForegroundColor = [0 0 0];
        
        selected_method = Docode_do_mvpa.paras_ops{1};
        if isempty(selected_method) || numel(selected_method)~=1 || (selected_method~=1 && selected_method~=2)
            selected_method = 1; Docode_do_mvpa.paras_ops{1}=1;
        end
        if selected_method == 1 %svm
            smethod = 'SVM';
        elseif selected_method == 2
            smethod = 'Crossnobis';
        end
        classcoding = Docode_do_mvpa.paras_ops{2};
        if isempty(classcoding) || numel(classcoding)~=1
            classcoding=1; Docode_do_mvpa.paras_ops{2}=1;
        end
        if classcoding == 1
            strcoding = 'OneVsOne';
        elseif classcoding == 2
            strcoding = 'OneVsAll';
        else
            strcoding = 'none';
        end
        sbeta = 'off';
        
        %%epochtimes (1:all, 2: pre, 3: post, 4:custom)
        epochTimes= Docode_do_mvpa.paras_ops{3};
        if epochTimes==2
            decodeTimes =  [observe_DECODE.BEST.times(1),0];
            epoch_times=2;
        elseif  epochTimes==3
            decodeTimes =  [0,observe_DECODE.BEST.times(end)];epoch_times=3;
        elseif epochTimes==4
            decodeTimes =  Docode_do_mvpa.paras_ops{4}*1000; epoch_times=4;
        else
            decodeTimes =  [observe_DECODE.BEST.times(1),observe_DECODE.BEST.times(end)];
            epoch_times=1;
        end
        if isempty(decodeTimes) || numel(decodeTimes)~=2 || any(decodeTimes(:)<observe_DECODE.BEST.times(1)) || any(decodeTimes(:)>observe_DECODE.BEST.times(end))
            decodeTimes =  [observe_DECODE.BEST.times(1),observe_DECODE.BEST.times(end)];
        end
        Docode_do_mvpa.paras_ops{4} = decodeTimes/1000;
        Docode_do_mvpa.paras_ops{3} = epoch_times;
        
        decode_every_Npoint = Docode_do_mvpa.paras_ops{5};
        if isempty(decode_every_Npoint) || numel(decode_every_Npoint)~=1
            decode_every_Npoint=1;Docode_do_mvpa.paras_ops{5}=1;
        end
        
        ParCompute = Docode_do_mvpa.paras_ops{6};
        if isempty(ParCompute) || numel(ParCompute)~=1 || (ParCompute~=0 && ParCompute~=1)
            ParCompute=0;Docode_do_mvpa.paras_ops{6}=0;
        end
        if ParCompute
            spar = 'on';
        else
            spar = 'off';
        end
        
        BEST = observe_DECODE.BEST;
        relevantChans = str2num(Docode_do_mvpa.channels_edit.String);
        if isempty(relevantChans) || numel(relevantChans)>BEST.nbchan || any(relevantChans(:)<1)
            relevantChans = 1:BEST.nbchan;
            chanArray = vect2colon(chanArray,'Sort', 'on');
            chanArray = erase(chanArray,{'[',']'});
            Docode_do_mvpa.channels_edit.String=chanArray;
        end
        
        %%number of iterations
        nIter = ceil(str2num(Docode_do_mvpa.iter_edit.String));
        if isempty(nIter) || numel(nIter)~=1 || any(nIter(:)<1)
            nIter =100; Docode_do_mvpa.iter_edit.String = '100';
        end
        %%Number of crossfolds
        nCrossBlocks = ceil(str2num(Docode_do_mvpa.foldsnum.String));
        if isempty(nCrossBlocks) || numel(nCrossBlocks)~=1 || any(nCrossBlocks(:)<2)
            nCrossBlocks=3; Docode_do_mvpa.foldsnum.String = '3';
        end
        
        if  Docode_do_mvpa.eq_trials_checkbox.Value==0
            floorValue=0;
        else
            if Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
                if Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
                    equalizeTrials=1;
                else
                    equalizeTrials=2;
                end
            else
                equalizeTrials=3;
            end
        end
        
        if equalizeTrials == 1
            seqtr = 'classes';
            floorValue = [];
        elseif equalizeTrials == 2
            seqtr = 'best';
            floorValue = [];
        elseif equalizeTrials == 3
            seqtr = 'floor';
            floorValue = ceil(str2num(Docode_do_mvpa.manfloor_edit.String));
            if isempty(floorValue) || numel(floorValue)~=1 || any(floorValue(:)<1) || any(BEST.n_trials_per_bin(:)<floorValue)
                floorValue=1;Docode_do_mvpa.manfloor_edit.String=1;
            end
        else
            seqtr ='none';
            floorValue = [];
        end
        decodeClasses = ceil(str2num(Docode_do_mvpa.selclass_custom_defined.String));
        if isempty(decodeClasses) || any(decodeClasses(:)>BEST.nbin) || any(decodeClasses(:)<1)
            decodeClasses(:)=1:BEST.nbin;
            ClassArray = vect2colon(decodeClasses,'Sort', 'on');
            ClassArray = erase(ClassArray,{'[',']'});
            Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
        end
        
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            observe_DECODE.Count_currentbest=1;
        end
        checking = checkmultiBEST(observe_DECODE.ALLBEST(BESTArray));
        if ~checking && numel(BESTArray)>1
            msgboxText = 'Multivariate Pattern Classification>Run:The selected BESTsets do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.';
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        if ~isempty(errormess)
            msgboxText =  ['Multivariate Pattern Classification>Run:',32,errormess];
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        estudioworkingmemory('f_Decode_proces_messg','Multivariate Pattern Classification');
        observe_DECODE.Process_messg =1; %%Marking for the procedure has been started.
        
        def = {[], [], relevantChans, nIter, nCrossBlocks, epoch_times, ...
            decodeTimes, decode_every_Npoint, 2, floorValue, ...
            selected_method, classcoding, ParCompute,decodeClasses};
        estudioworkingmemory('pop_decoding',def);
        ALLMVPC_out = [];
        ALLBEST = observe_DECODE.ALLBEST;
        for Numofbest = 1:numel(BESTArray)
            BEST = observe_DECODE.ALLBEST(BESTArray(Numofbest));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Multivariate Pattern Classification>Run*',32,32,32,32,datestr(datetime('now')),'\n']);
            %             fprintf(['Your current BESTset(No.',num2str(BESTArray(Numofbest)),'):',32,BEST.bestname,'\n\n']);
            [MVPC,BESTCOM] = pop_decoding(ALLBEST,'BESTindex', BESTArray(Numofbest), 'Classes', decodeClasses, ...
                'Channels', relevantChans, ...
                'nIter',nIter,'nCrossblocks',nCrossBlocks,  ...
                'DecodeTimes', decodeTimes, 'Decode_Every_Npoint',decode_every_Npoint,  ...
                'EqualizeTrials', seqtr, 'FloorValue',floorValue,'Method', smethod, ...
                'classcoding',strcoding, 'Saveas','off', 'ParCompute',spar, 'BetaWeights', sbeta, 'History','script','Tooltype','estudio');
            if isempty(BESTCOM)
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return;
            end
            fprintf( [BESTCOM]);
            
            if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
            end
            
            observe_DECODE.ALLBEST(BESTArray(Numofbest)) = BEST;
            fprintf( ['\n',repmat('-',1,100) '\n']);
            if isempty(ALLMVPC_out)
                ALLMVPC_out = MVPC;
                eegh(BESTCOM);
            else
                ALLMVPC_out(length(ALLMVPC_out)+1) = MVPC;
            end
        end
        
        Answer = f_mvpc_save_multi_file(ALLMVPC_out,[1:length(ALLMVPC_out)],'');
        if isempty(Answer)
            observe_DECODE.Process_messg =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLMVPC_out = Answer{1};
            Save_file_label = Answer{2};
        end
        ALLMVPC = observe_DECODE.ALLMVPC;
        for Numofmvpc =  1:length(ALLMVPC_out)
            MVPC = ALLMVPC_out(Numofmvpc);
            if Save_file_label==1
                [pathstr, file_name, ext] = fileparts(MVPC.filename);
                MVPC.filename = [file_name,'.mvpc'];
                [MVPC, issave, MVPCCOM] = pop_savemymvpc(MVPC, 'mvpcname', MVPC.mvpcname, 'filename', MVPC.filename,...
                    'filepath',MVPC.filepath,'Tooltype','estudio');
                if ~isempty(MVPCCOM) && Numofmvpc==1
                    eegh(MVPCCOM);
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
        end
        MVPCArray = length(ALLMVPC);
        observe_DECODE.ALLMVPC = ALLMVPC;
        observe_DECODE.MVPC = observe_DECODE.ALLMVPC(end);
        observe_DECODE.CURRENTMVPC = MVPCArray;
        estudioworkingmemory('MVPCArray',MVPCArray);
        observe_DECODE.Count_currentMVPC=1;
        observe_DECODE.Process_messg =2;
        %%save parameters
        Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
        Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
        Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
        Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
        Docode_do_mvpa.Paras{6} = Docode_do_mvpa.eq_trials_checkbox.Value;
        Docode_do_mvpa.Paras{7} = Docode_do_mvpa.eq_trials_acrclas_radio.Value;
        Docode_do_mvpa.Paras{8} = Docode_do_mvpa.eq_trials_acrbest_checkbox.Value;
        Docode_do_mvpa.Paras{9} = str2num(Docode_do_mvpa.manfloor_edit.String);
        
        estudioworkingmemory('MVPCA_panelparas',{Docode_do_mvpa.Paras,Docode_do_mvpa.paras_ops});
    end


%%%--------------Up this panel---------------------------------------------
    function Count_currentbest_change(~,~)
        if observe_DECODE.Count_currentbest~=2
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
            Edit_label = 'on';
        else
            Edit_label = 'off';
        end
        Docode_do_mvpa.selclass_all.Enable = Edit_label;
        Docode_do_mvpa.selclass_custom.Enable = Edit_label;
        Docode_do_mvpa.selclass_custom_browse.Enable = Edit_label;
        Docode_do_mvpa.selclass_custom_defined.Enable = Edit_label;
        Docode_do_mvpa.no_class.String = '';
        Docode_do_mvpa.foldsnum.Enable = Edit_label;
        Docode_do_mvpa.channels_edit.Enable = Edit_label;
        Docode_do_mvpa.channels_browse.Enable = Edit_label;
        Docode_do_mvpa.iter_edit.Enable = Edit_label;
        Docode_do_mvpa.eq_trials_checkbox.Enable = Edit_label;
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Edit_label;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Edit_label;
        Docode_do_mvpa.manfloor_radio.Enable = Edit_label;
        Docode_do_mvpa.manfloor_edit.Enable = Edit_label;
        Docode_do_mvpa.table_bins.Enable = Edit_label;
        Docode_do_mvpa.mvpa_cancel.Enable = Edit_label;
        Docode_do_mvpa.mvpa_ops.Enable = Edit_label;
        Docode_do_mvpa.mvpa_run.Enable = Edit_label;
        if ~isempty(observe_DECODE.BEST)
            ClassArray = [1:observe_DECODE.BEST.nbin];
            ClassArray = vect2colon(ClassArray,'Sort', 'on');
            ClassArray = erase(ClassArray,{'[',']'});
            if Docode_do_mvpa.selclass_all.Value==1
                Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
                Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
                Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
            else
                ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
                if isempty(ClassArraydef) || any(ClassArraydef(:)>observe_DECODE.BEST.nbin) || any(ClassArraydef(:)<1)
                    Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
                end
            end
            ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
            if ~isempty(ClassArraydef)
                Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
                Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            end
            
            %%channels
            chanArray =  str2num(Docode_do_mvpa.channels_edit.String);
            if isempty(chanArray) || any(chanArray(:)>observe_DECODE.BEST.nbchan) || any(chanArray(:)<1)
                chanArray = 1:observe_DECODE.BEST.nbchan;
                chanArray = vect2colon(chanArray,'Sort', 'on');
                chanArray = erase(chanArray,{'[',']'});
                Docode_do_mvpa.channels_edit.String=chanArray;
            end
            %%Iterations
            iter_edit = str2num(Docode_do_mvpa.iter_edit.String);
            if isempty(iter_edit) || any(iter_edit(:)<=0) || numel(iter_edit)~=1
                Docode_do_mvpa.iter_edit.String = '100';
            end
            
            %%Equaliza trials
            if Docode_do_mvpa.eq_trials_checkbox.Value==1
                Enable_flag = 'on';
            else
                Enable_flag = 'off';
            end
            Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
            Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
            Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
            if Docode_do_mvpa.eq_trials_checkbox.Value==1
                if  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
                    Enable_flag = 'off';
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
                else
                    Enable_flag = 'on';
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                end
                Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
            end
            manfloor_edit = str2num(Docode_do_mvpa.manfloor_edit.String);
            if  isempty(manfloor_edit)  || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
                Docode_do_mvpa.manfloor_edit.String = '1';manfloor_edit=1;
            end
            %%Tables
            BESTArray= estudioworkingmemory('BESTArray');
            if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
                BESTArray = length(observe_DECODE.ALLBEST);
                estudioworkingmemory('BESTArray',BESTArray);
                observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
                observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
                observe_DECODE.Count_currentbest=1;
            end
            
            checking = checkmultiBEST(observe_DECODE.ALLBEST(BESTArray));
            if ~checking && numel(BESTArray)>1
                msgboxText = {'Welcome to the Estudio decoding GUI',
                    'Estudio detected that the currently selected BESTsets as specified in the BESTset panel',
                    'do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.',
                    ' ',
                    'Please select BESTsets that match in terms of bins and channels!',
                    'You can:',
                    '1: Select the indicies of the BESTsets that match in terms of bins and channels in the "From BESTsets Panel" Options'};
                Docode_do_mvpa.table_bins.Data = msgboxText;
                Docode_do_mvpa.table_bins.ColumnName= {' '};
                Docode_do_mvpa.table_bins.ColumnWidth ={600};
                Docode_do_mvpa.selclass_all.Enable = 'off';
                Docode_do_mvpa.selclass_custom.Enable = 'off';
                Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
                Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
                Docode_do_mvpa.no_class.String = '';
                Docode_do_mvpa.channels_edit.Enable = 'off';
                Docode_do_mvpa.channels_browse.Enable = 'off';
                Docode_do_mvpa.iter_edit.Enable = 'off';
                Docode_do_mvpa.eq_trials_checkbox.Enable = 'off';
                Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                Docode_do_mvpa.manfloor_radio.Enable = 'off';
                Docode_do_mvpa.manfloor_edit.Enable = 'off';
                Docode_do_mvpa.foldsnum.Enable = 'off';
                Docode_do_mvpa.mvpa_cancel.Enable = 'off';
                Docode_do_mvpa.mvpa_ops.Enable = 'off';
                Docode_do_mvpa.mvpa_run.Enable = 'off';
                Docode_do_mvpa.foldsnum.Enable = 'off';
            else
                Docode_do_mvpa.table_bins.ColumnName= {'BEST File','Class ID','Class/Label','N(trials)','N(per ERP)'};
                %%No. of blocks
                nBlock = str2num(Docode_do_mvpa.foldsnum.String);
                if isempty(nBlock) || numel(nBlock)~=1 || any(nBlock(:)<=0)
                    nBlock=3;
                    Docode_do_mvpa.foldsnum.String = '3';
                end
                
                decodebins = str2num(Docode_do_mvpa.selclass_custom_defined.String);
                if isempty(decodebins) || any(decodebins(:)>observe_DECODE.BEST.nbin)
                    decodebins=1:observe_DECODE.BEST.nbin;
                    ClassArray = vect2colon(decodebins,'Sort', 'on');
                    ClassArray = erase(ClassArray,{'[',']'});
                    Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
                end
                
                if Docode_do_mvpa.eq_trials_checkbox.Value==0
                    classtrialType=1;
                elseif Docode_do_mvpa.eq_trials_checkbox.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
                    classtrialType=2;
                elseif Docode_do_mvpa.eq_trials_checkbox.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
                    classtrialType=3;
                    
                elseif  Docode_do_mvpa.eq_trials_checkbox.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
                    classtrialType=4;
                end
                FloorNum=manfloor_edit;
                def = estudioworkingmemory('pop_decoding');
                try trialsbymethod = def{11}; catch trialsbymethod=1; end
                if isempty(trialsbymethod) || numel(trialsbymethod)~=1 || (trialsbymethod~=1 && trialsbymethod~=2)
                    trialsbymethod=1;
                end
                Data = updatetabledata(observe_DECODE.ALLBEST(BESTArray),decodebins,trialsbymethod,nBlock,classtrialType,FloorNum);
                Docode_do_mvpa.table_bins.Data = Data;
                Docode_do_mvpa.table_bins.ColumnWidth ={50,50,70,50,60};
            end
            %%save parameters
            Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
            Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
            Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
            Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
            Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
            Docode_do_mvpa.Paras{6} = Docode_do_mvpa.eq_trials_checkbox.Value;
            Docode_do_mvpa.Paras{7} = Docode_do_mvpa.eq_trials_acrclas_radio.Value;
            Docode_do_mvpa.Paras{8} = Docode_do_mvpa.eq_trials_acrbest_checkbox.Value;
            Docode_do_mvpa.Paras{9} = str2num(Docode_do_mvpa.manfloor_edit.String);
            %%if select crossvalidated mahalanobis
            try Methodops = Docode_do_mvpa.paras_ops{1}; catch Methodops=1; end
            if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2)
                Methodops=1;
            end
            if Methodops~=1 || (~checking && numel(BESTArray)>1)
                Docode_do_mvpa.foldsnum.Enable = 'off';
            else
                Docode_do_mvpa.foldsnum.Enable = 'on';
            end
        end
    end

%%---------------press return to execute "Run"-----------------------------
    function decode_mvpc_presskey(~,eventdata)
        keypress = eventdata.Key;
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            mvpa_run();
            Docode_do_mvpa.run.BackgroundColor =  [ 1 1 1];
            Docode_do_mvpa.run.ForegroundColor = [0 0 0];
            box_bestset_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            Docode_do_mvpa.mvpa_cancel.BackgroundColor =  [1 1 1];
            Docode_do_mvpa.mvpa_cancel.ForegroundColor = [0 0 0];
            Docode_do_mvpa.mvpa_ops.BackgroundColor =  [1 1 1];
            Docode_do_mvpa.mvpa_ops.ForegroundColor = [0 0 0];
            Docode_do_mvpa.mvpa_run.BackgroundColor =  [1 1 1];
            Docode_do_mvpa.mvpa_run.ForegroundColor = [0 0 0];
        end
    end

%%----------------------------------------Reset----------------------------
    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_Best_paras_panel~=1
            return;
        end
        Docode_do_mvpa.selclass_all.Value = 1;
        Docode_do_mvpa.selclass_custom.Value = 0;
        if isempty(observe_DECODE.BEST)
            classArray = [];
        else
            classArray = [1:observe_DECODE.BEST.nbin];
        end
        classArraydef = vect2colon(classArray,'Sort', 'on');
        classArraydef = erase(classArraydef,{'[',']'});
        Docode_do_mvpa.selclass_custom_defined.String = classArraydef;
        Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
        Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
        %%Number of classes/bins
        if ~isempty(classArray)
            Docode_do_mvpa.no_class.String = num2str(numel(classArray));
        else
            Docode_do_mvpa.no_class.String = '';
        end
        Docode_do_mvpa.foldsnum.String = '3';
        %%channels
        if isempty(observe_DECODE.BEST)
            chanArray = [];
        else
            chanArray = [1:observe_DECODE.BEST.nbchan];
        end
        chanArray = vect2colon(chanArray,'Sort', 'on');
        chanArray = erase(chanArray,{'[',']'});
        Docode_do_mvpa.channels_edit.String = chanArray;
        %%iterations
        Docode_do_mvpa.iter_edit.String = '100';
        
        Docode_do_mvpa.eq_trials_checkbox.Value=1;
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
        Docode_do_mvpa.manfloor_radio.Value=0;
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.String = '';
        
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            observe_DECODE.Count_currentbest=1;
        end
        
        checking =0;
        if numel(BESTArray)>1 && ~isempty(observe_DECODE.ALLBEST)
            checking = checkmultiBEST(observe_DECODE.ALLBEST(BESTArray));
        end
        if (~checking && numel(BESTArray)>1) || isempty(observe_DECODE.BEST)
            msgboxText = {'Welcome to the Estudio decoding GUI',
                'Estudio detected that the currently selected BESTsets as specified in the BESTset panel',
                'do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.',
                ' ',
                'Please select BESTsets that match in terms of bins and channels!',
                'You can:',
                '1: Select the indicies of the BESTsets that match in terms of bins and channels in the "From BESTsets Panel" Options'};
            Docode_do_mvpa.table_bins.Data = msgboxText;
            Docode_do_mvpa.table_bins.ColumnName= {' '};
            Docode_do_mvpa.table_bins.ColumnWidth ={600};
            Docode_do_mvpa.selclass_all.Enable = 'off';
            Docode_do_mvpa.selclass_custom.Enable = 'off';
            Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
            Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
            %                 Docode_do_mvpa.no_class.String = '';
            Docode_do_mvpa.channels_edit.Enable = 'off';
            Docode_do_mvpa.channels_browse.Enable = 'off';
            Docode_do_mvpa.iter_edit.Enable = 'off';
            Docode_do_mvpa.eq_trials_checkbox.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            Docode_do_mvpa.manfloor_radio.Enable = 'off';
            Docode_do_mvpa.manfloor_edit.Enable = 'off';
            Docode_do_mvpa.foldsnum.Enable = 'off';
            Docode_do_mvpa.mvpa_cancel.Enable = 'off';
            Docode_do_mvpa.mvpa_ops.Enable = 'off';
            Docode_do_mvpa.mvpa_run.Enable = 'off';
            Docode_do_mvpa.foldsnum.Enable = 'off';
        end
        %%Update the table
        if checking && ~isempty(observe_DECODE.BEST) && ~isempty(observe_DECODE.ALLBEST)
            [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
            if ~isempty(errormess)
                msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
                titlNamerro = 'Warning for Pattern Classification Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
        Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
        Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
        Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
        Docode_do_mvpa.Paras{6} = Docode_do_mvpa.eq_trials_checkbox.Value;
        Docode_do_mvpa.Paras{7} = Docode_do_mvpa.eq_trials_acrclas_radio.Value;
        Docode_do_mvpa.Paras{8} = Docode_do_mvpa.eq_trials_acrbest_checkbox.Value;
        Docode_do_mvpa.Paras{9} = str2num(Docode_do_mvpa.manfloor_edit.String);
        Docode_do_mvpa.paras_ops = {1,1,1,[],1,0};
        observe_DECODE.Reset_Best_paras_panel=2;
    end

end


function [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
global observe_DECODE;
errormess = '';

BESTArray= estudioworkingmemory('BESTArray');
if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
    BESTArray = length(observe_DECODE.ALLBEST);
    estudioworkingmemory('BESTArray',BESTArray);
    observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
    observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
    observe_DECODE.Count_currentbest=1;
end

decodebins = str2num(Docode_do_mvpa.selclass_custom_defined.String);
if isempty(decodebins) || any(decodebins(:)>observe_DECODE.BEST.nbin)
    decodebins=1:observe_DECODE.BEST.nbin;
    ClassArray = vect2colon(decodebins,'Sort', 'on');
    ClassArray = erase(ClassArray,{'[',']'});
    Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
end

try trialsbymethod = Docode_do_mvpa.paras_ops{1}; catch trialsbymethod=1; end
if isempty(trialsbymethod) || numel(trialsbymethod)~=1 || (trialsbymethod~=1 && trialsbymethod~=2)
    trialsbymethod=1;
end

%%No. of blocks
nBlock = str2num(Docode_do_mvpa.foldsnum.String);
if isempty(nBlock) || numel(nBlock)~=1 || any(nBlock(:)<=0)
    nBlock=3;
    Docode_do_mvpa.foldsnum.String = '3';
end

if Docode_do_mvpa.eq_trials_checkbox.Value==0
    classtrialType=1;
elseif Docode_do_mvpa.eq_trials_checkbox.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
    classtrialType=2;
elseif Docode_do_mvpa.eq_trials_checkbox.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
    classtrialType=3;
elseif  Docode_do_mvpa.eq_trials_checkbox.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
    classtrialType=4;
end

%%
manfloor_edit = str2num(Docode_do_mvpa.manfloor_edit.String);
if  isempty(manfloor_edit)  || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
    Docode_do_mvpa.manfloor_edit.String = '1';manfloor_edit=1;
end
FloorNum=manfloor_edit;

[Data,errormess] = updatetabledata(observe_DECODE.ALLBEST(BESTArray),decodebins,trialsbymethod,nBlock,classtrialType,FloorNum);
if ~isempty(Data) && isempty(errormess)
    Docode_do_mvpa.table_bins.Data = Data;
    Docode_do_mvpa.table_bins.ColumnWidth ={50,50,70,50,60};
end
end



function [tmpdata,errormess]= updatetabledata(ALLBEST,decodebins,trialsbymethod,nBlock,classtrialType,FloorNum)
tmpdata = [];
[nPerBinCheckall,errormess] = f_BinCheck(ALLBEST,decodebins,trialsbymethod,nBlock,classtrialType,FloorNum);
if ~isempty(errormess)
    return;
end

%%trialsbymethod-1.SVM
if trialsbymethod == 1 %svm
    rowInd = 0;
    rowIndbin = 0;
    for f = 1:numel(ALLBEST)
        nbin= ALLBEST(f).nbin;
        for b = 1:nbin
            rowInd = rowInd +1;
            bestfils{rowInd} = ALLBEST(f).bestname;
            classid{rowInd} = num2str(b);
            try claslabel{rowInd} = ALLBEST(f).bindesc{b};catch claslabel{rowInd} = 'undefined'; end
            try trialnum{rowInd} = num2str(ALLBEST(f).n_trials_per_bin(b));catch trialnum{rowInd} =[]; end
            % N_trial_per_bin_per_bock analysis
            if ismember(b,decodebins)
                rowIndbin = rowIndbin+1;
                %                 nPerBinBlock = floor(ALLBEST(f).n_trials_per_bin/nBlock); %subject's n_trial_per_bin
                nPerBin{rowInd} = num2str(nPerBinCheckall(rowIndbin));
            else
                nPerBin{rowInd} = 'NOT USED';
            end
        end
    end
    tmpdata = cell(length(bestfils),5);
    tmpdata(:,1) = bestfils';
    tmpdata(:,2) =classid';
    tmpdata(:,3) =claslabel';
    tmpdata(:,4) =trialnum';
    tmpdata(:,5) = nPerBin';
elseif trialsbymethod == 2 %crossnobis
    %crossnobis only cares about N(trials)
    rowInd = 0;
    for f = 1:numel(ALLBEST)
        nbin= ALLBEST(f).nbin;
        rowIndbin = 0;
        for b = 1:nbin
            rowInd = rowInd +1;
            bestfils{rowInd} = ALLBEST(f).bestname;
            classid{rowInd} = b;
            try claslabel{rowInd} = ALLBEST(f).bindesc{b};catch claslabel{rowInd} = 'undefined'; end
            if ismember(b,decodebins)
                rowIndbin = rowIndbin+1;
                %                 nPerBinBlock = ALLBEST(f).n_trials_per_bin; %subject's n_trial_per_bin
                nPerBin{rowInd} = num2str(nPerBinCheckall(rowIndbin));
            else
                nPerBin{rowInd} = 'NOT USED';
            end
        end
    end
    tmpdata = cell(length(bestfils),5);
    tmpdata(:,1) = bestfils';
    tmpdata(:,2) =classid';
    tmpdata(:,3) =claslabel';
    tmpdata(:,4) = nPerBin';
    tmpdata(:,5) = [];
end

end


function [nPerBinCheck,errormess] = f_BinCheck(ALLBEST,decodebins,trialsbymethod,nBlock,classtrialType,FloorNum)
errormess = '';
nPerBinCheck = [];
if isempty(FloorNum) || numel(FloorNum)~=1 || any(FloorNum(:)<1)
    errormess = 'The common floor should be a single positive value';
    return;
end
if isempty(nBlock) || numel(nBlock)~=1 || any(nBlock(:)<1)
    errormess = 'Cross-validation Blocks should be a single positive value';
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%---------------------------------SVM method------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trialsbymethod == 1
    %%classtrialType--1 is inactive equalize trials
    if classtrialType==1
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                if ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin))>=nBlock
                    nPerBinCheck(count,1) = floor(ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin))/nBlock);
                else
                    nPerBinCheck = [];
                    errormess = ['Cross-validation Blocks should be smaller than',32,num2str(ALLBEST(Numofbest).n_trials_per_bin(decodebins(count)))];
                    return;
                end
            end
        end
    end
    
    if classtrialType==2
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            decodebinsbest =  ALLBEST(Numofbest).n_trials_per_bin(decodebins);
            if any(decodebinsbest(:) < nBlock)
                nPerBinCheck = [];
                errormess = ['Cross-validation Blocks should be smaller than',32,num2str(min(decodebinsbest(:)))];
                return;
            else
                decodebinsacrossbest = floor(decodebinsbest/nBlock);
                for Numofbin = 1:numel(decodebins)
                    count = count+1;
                    nPerBinCheck(count,1) = min(decodebinsacrossbest(:));
                end
            end
        end
    end
    
    %%----------------3 is across calsses across BESTsets
    if classtrialType==3
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheckall(count,1) = ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin));
            end
        end
        
        if any(nPerBinCheckall(:)<nBlock)
            nPerBinCheck = [];
            errormess = ['Cross-validation Blocks should be smaller than',32,num2str(min(nPerBinCheckall(:)))];
            return;
        else
            binsacrossbests = floor(nPerBinCheckall/nBlock);
            nPerBinCheck = ones(length(ALLBEST)*numel(decodebins),1)*min(binsacrossbests(:));
            return;
        end
    end
    
    %%----------------4 Common floor
    if classtrialType==4
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheckall(count,1) = ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin));
                nPerBinCheck(count,1) = FloorNum;
            end
        end
        if any(nPerBinCheckall(:)<FloorNum)
            nPerBinCheck = [];
            errormess = ['The common floor should be smaller than',32,num2str(min(nPerBinCheckall(:)))];
            return;
        end
        return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------Corssvalidated Mahalanobis-----------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trialsbymethod == 2
    %%classtrialType--1 is inactive equalize trials
    if classtrialType==1
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheck(count,1) = ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin));
            end
        end
        return;
    end
    
    %%----------------2 is across calsses
    if classtrialType==2
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            trialnums = ALLBEST(Numofbest).n_trials_per_bin(decodebins);
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheck(count,1) = min(trialnums(:));
            end
        end
    end
    
    %%----------------3 is across calsses across BESTsets
    if classtrialType==3
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheckall(count,1) = ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin));
            end
        end
        nPerBinCheck = ones(length(ALLBEST)*numel(decodebins),1)*min(nPerBinCheckall(:));
        return;
    end
    
    %%----------------4 Common floor-----
    if classtrialType==4
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheckall(count,1) = ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin));
                nPerBinCheck(count,1) = FloorNum;
            end
        end
        if any(nPerBinCheckall(:)<FloorNum)
            nPerBinCheck = [];
            errormess = ['The common floor should be smaller than',32,num2str(min(nPerBinCheckall(:)))];
            return;
        end
        return;
    end
end
end