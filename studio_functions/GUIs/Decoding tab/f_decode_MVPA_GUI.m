% MVPA panel for EStudio
%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024 & 2025

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
        try MVPCA_panelparas=estudioworkingmemory('MVPCA_panelparas'); catch  MVPCA_panelparas = {[],[]}; end
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
            'String','All','callback',@selclass_all,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
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
            'String','Number of Classes/Bins','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
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
            'String','Cross-validation Folds','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%GH Oct 2025
        %%----------------------#Trials & #AVGs----------------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try classtrialType = Paras_mvpa{6}; catch classtrialType=1;  end
        if isempty(classtrialType) || numel(classtrialType)~=1 || any(classtrialType(:)>7) || any(classtrialType(:)<1)
            classtrialType=7;
        end
        Docode_do_mvpa.Paras{6} = classtrialType;
        Docode_do_mvpa.trialsAVGs_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.trialsAVGs_title,...
            'String','#Trials & #AVGs','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);

        %%Equal Trials, Max AVGs # 1 2 3
        Docode_do_mvpa.eq_trials_maxavg_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_maxavg = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.eq_trials_maxavg_title,'Value',1,...
            'String','Equal Trials, Max AVGs','callback',@eq_trials_max_avg,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_maxavg.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.eq_trials_maxavg.String =  '<html>Equal Trials,<br />Max AVGs</html>';
        % uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_maxavg_title);
        %%Equal trials, Equal AVGs # 4 5 6
        % Docode_do_mvpa.eqtrials_eqavgs_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eqtrials_eqavgs = uicontrol('Style', 'radiobutton','Parent',  Docode_do_mvpa.eq_trials_maxavg_title,'Value',0,...
            'String','Equal Trials, Equal AVGs','callback',@eqtrials_eqavgs,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);

        Docode_do_mvpa.eqtrials_eqavgs.KeyPressFcn=  @decode_mvpc_presskey;
        % uiextras.Empty('Parent', Docode_do_mvpa.eqtrials_eqavgs_title);
        % set(Docode_do_mvpa.eqtrials_eqavgs_title,'Sizes',[160 -1]);
        Docode_do_mvpa.eqtrials_eqavgs.String =  '<html>Equal Trials,<br />Equal AVGs</html>';

        set(Docode_do_mvpa.eq_trials_maxavg_title,'Sizes',[-1 -1]);

        %%Equal trials, Equal AVGs # 4 5 6
        % Docode_do_mvpa.eqtrials_eqavgs_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        % Docode_do_mvpa.eqtrials_eqavgs = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.eqtrials_eqavgs_title,'Value',0,...
        %     'String','Equal Trials, Equal AVGs','callback',@eqtrials_eqavgs,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        % Docode_do_mvpa.eqtrials_eqavgs.KeyPressFcn=  @decode_mvpc_presskey;
        % uiextras.Empty('Parent', Docode_do_mvpa.eqtrials_eqavgs_title);
        % set(Docode_do_mvpa.eqtrials_eqavgs_title,'Sizes',[160 -1]);

        %%across Classes
        Docode_do_mvpa.eq_trials_acrclass_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrclass_title);
        Docode_do_mvpa.eq_trials_acrclas_radio = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.eq_trials_acrclass_title,'Value',0,...
            'String','Across Classes','callback',@eq_trials_acrclas_radio,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_acrclas_radio.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrclass_title);
        set(Docode_do_mvpa.eq_trials_acrclass_title,'Sizes',[20 140 -1]);

        %%across bests
        Docode_do_mvpa.eq_trials_acrbest_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrbest_title);
        Docode_do_mvpa.eq_trials_acrbest_checkbox = uicontrol('Style', 'checkbox','Parent', Docode_do_mvpa.eq_trials_acrbest_title,'Value',0,...
            'String','Across BESTsets','callback',@eq_trials_acrbest_checkbox,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_acrbest_checkbox.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrbest_title);
        set(Docode_do_mvpa.eq_trials_acrbest_title,'Sizes',[40 140 -1]);

        %%Manual Floor
        Docode_do_mvpa.manfloor_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.manfloor_title);
        Docode_do_mvpa.manfloor_radio = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.manfloor_title,'Value',0,...
            'String','Manual Floor','callback',@manfloor_radio,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.manfloor_radio.KeyPressFcn=  @decode_mvpc_presskey;
        Docode_do_mvpa.manfloor_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.manfloor_title,...
            'String','','callback',@manfloor_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.manfloor_title,'Sizes',[20 140 -1]);

        try manfloor_edit = Paras_mvpa{7}; catch manfloor_edit = 1;end
        if isempty(manfloor_edit) || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
            manfloor_edit=1;
        end
        Docode_do_mvpa.manfloor_edit.String = num2str(manfloor_edit);
        Docode_do_mvpa.Paras{7} = str2num(Docode_do_mvpa.manfloor_edit.String);
        %%------------------Equal trials, Max AVGs-------------------------
        if classtrialType==1 ||  classtrialType==2 || classtrialType==3
            Docode_do_mvpa.eq_trials_maxavg.Value=1;
            if  classtrialType==2%%Across best
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=1;
                Docode_do_mvpa.manfloor_radio.Value=0;
            elseif  classtrialType==3%%Floor
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
                % Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=1;
                Docode_do_mvpa.manfloor_radio.Value=1;
            else%%Across classes
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
                Docode_do_mvpa.manfloor_radio.Value=0;
            end
        else
            Docode_do_mvpa.eq_trials_maxavg.Value=0;
        end
        %%------------------Equal trials, Equal AVGs-----------------------
        if classtrialType==4 ||  classtrialType==5 ||   classtrialType==6
            Docode_do_mvpa.eqtrials_eqavgs.Value=1;
            if  classtrialType==5
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=1;
                Docode_do_mvpa.manfloor_radio.Value=0;
            elseif  classtrialType==6
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
                % Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=1;
                Docode_do_mvpa.manfloor_radio.Value=1;
            else
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
                Docode_do_mvpa.manfloor_radio.Value=0;
            end
        else
            Docode_do_mvpa.eqtrials_eqavgs.Value=0;
        end


        %%Max Trials, Equal AVGs
        Docode_do_mvpa.max_trials_equalavg_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.max_trials_equalavg = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.max_trials_equalavg_title,'Value',0,...
            'String','Max Trials, Equal AVGs','callback',@Maxtrials_equalavg,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.max_trials_equalavg.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.max_trials_equalavg_title);
        set(Docode_do_mvpa.max_trials_equalavg_title,'Sizes',[160 -1]);
        if classtrialType==7
            Docode_do_mvpa.max_trials_equalavg.Value=1;
        end
        %%----------------------------------metrics-----------------------
        Docode_do_mvpa.metric_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.metric_title,...
            'String','Metric','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try metric_edit = Paras_mvpa{8}; catch metric_edit = 1;end
        %%ACC
        Docode_do_mvpa.decodemetrics_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.metric_ACC = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.decodemetrics_title,'Value',metric_edit,...
            'String','ACC','callback',@metric_ACC,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.metric_ACC.KeyPressFcn=  @decode_mvpc_presskey;
        %%AUC
        Docode_do_mvpa.metric_AUC = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.decodemetrics_title,'Value',~metric_edit,...
            'String','AUC','callback',@metric_AUC,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.metric_AUC.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.decodemetrics_title);
        set(Docode_do_mvpa.decodemetrics_title,'Sizes',[100 100 -1]);
        Docode_do_mvpa.Paras{8} = Docode_do_mvpa.metric_ACC.Value;


        %%----------------------------------Normalization-----------------------
        Docode_do_mvpa.nor_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.nor_title,...
            'String','Normalization','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try nor_edit = Paras_mvpa{9}; catch nor_edit = 1;end
        %%On
        Docode_do_mvpa.decodenor_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.nor_on = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.decodenor_title,'Value',~nor_edit,...
            'String','On','callback',@nor_on,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.nor_on.KeyPressFcn=  @decode_mvpc_presskey;
        %%Off
        Docode_do_mvpa.nor_off = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.decodenor_title,'Value',nor_edit,...
            'String','Off','callback',@nor_off,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.nor_off.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.decodenor_title);
        set(Docode_do_mvpa.decodenor_title,'Sizes',[100 100 -1]);
        Docode_do_mvpa.Paras{9} = Docode_do_mvpa.nor_off.Value;
        %%----------------------------------temporal generalization matrix-----------------------
        Docode_do_mvpa.tgm_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.tgm_title,...
            'String','Temporal generalization matrix','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try TGM_edit = Paras_mvpa{10}; catch TGM_edit = 1;end
        %%On
        Docode_do_mvpa.decodetgm_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.tgm_on = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.decodetgm_title,'Value',~TGM_edit,...
            'String','On','callback',@tgm_on,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.tgm_on.KeyPressFcn=  @decode_mvpc_presskey;
        %%Off
        Docode_do_mvpa.tgm_off = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.decodetgm_title,'Value',TGM_edit,...
            'String','Off','callback',@tgm_off,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.tgm_off.KeyPressFcn=  @decode_mvpc_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.decodetgm_title);
        set(Docode_do_mvpa.decodetgm_title,'Sizes',[100 100 -1]);
        Docode_do_mvpa.Paras{10} = Docode_do_mvpa.tgm_off.Value;


        %%Table is to display the bin descriptions
        Docode_do_mvpa.bindecps_title2 = uiextras.HBox('Parent',Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.table_bins=  uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.bindecps_title2,'Value',0,...
            'String','Show Summary of AVGs and Trials','callback',@sum_avg_trials,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', Docode_do_mvpa.bindecps_title2);
        set(Docode_do_mvpa.bindecps_title2,'Sizes',[200 -1]);
        estudioworkingmemory('MVPA_sum_avg_trial',0);
        % Docode_do_mvpa.table_bins = uitable(  ...
        %     'Parent'        , Docode_do_mvpa.bindecps_title2,...
        %     'Data'          , [], ...
        %     'ColumnName'    , {'BEST File','Class ID','Class/Label','N(trials)','B(ERPs)','N(per ERP)'}, ...
        %     'RowName'    , [], ...
        %     'ColumnEditable',[false,false,false,false,false,false]);%%'CellEditCallback', @updatePlot
        Docode_do_mvpa.table_bins.Enable = 'off';

        %%-----------------------Cancel and Run----------------------------
        Docode_do_mvpa.detar_run_title = uiextras.HBox('Parent', Docode_do_mvpa.vBox_decode,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.mvpa_cancel = uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Cancel','callback',@mvpa_cancel,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.mvpa_ops = uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Options','callback',@mvpa_ops,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.mvpa_run = uicontrol('Style','pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Run','callback',@mvpa_run,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);

        set(Docode_do_mvpa.vBox_decode,'Sizes',[20 15 25 20 25 25 25 25 25 25 35 25 16 16 25 15 15 15 15 15 15 25 30]);
        try  Docode_do_mvpa.paras_ops = MVPCA_panelparas{2}; catch  Docode_do_mvpa.paras_ops = [];end
        if isempty(Docode_do_mvpa.paras_ops )
            Docode_do_mvpa.paras_ops = {1,2,1,[],1,0, 0};
        end
        %%(1)Methods (1.SVM;2.LDA;  3.Crossnobis),
        %%(2)SVM coding (1: 1vs1 / 2: 1vsAll or empty - def: 1vsALL)
        %%(3)epochTimes (1:all, 2: pre, 3: post, 4:custom)
        %%(4)decodeTimes ([start,end]; def = []); % IN MS!
        %%(5)decode_every_Npoint(1 = every point)
        %%(6)parCompute (def = 0)
        %%(7) Regularization
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
            if Docode_do_mvpa.metric_AUC.Value==0
                Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            else
                Docode_do_mvpa.chance.String = '0.5';
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
            if Docode_do_mvpa.metric_AUC.Value==0
                Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            else
                Docode_do_mvpa.chance.String = '0.5';
            end
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

        ClassArray = str2num(Docode_do_mvpa.selclass_custom_defined.String);
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
            if Docode_do_mvpa.metric_AUC.Value==0
                Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            else
                Docode_do_mvpa.chance.String = '0.5';
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
            if Docode_do_mvpa.metric_AUC.Value==0
                Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            else
                Docode_do_mvpa.chance.String = '0.5';
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

        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
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

%%-----------------------Equal trials, Max AVGs----------------------------
    function eq_trials_max_avg(~,~)%%GH Oct 2025
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
        if Docode_do_mvpa.max_trials_equalavg.Value==1
            Docode_do_mvpa.metric_ACC.Value=0;
            Docode_do_mvpa.metric_AUC.Value=0;
        end
        Docode_do_mvpa.eq_trials_maxavg.Value=1;
        Docode_do_mvpa.max_trials_equalavg.Value=0;
        Docode_do_mvpa.eqtrials_eqavgs.Value=0;
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'on';
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
        Docode_do_mvpa.manfloor_radio.Enable = 'on';
        Docode_do_mvpa.metric_ACC.Enable = 'on';
        Docode_do_mvpa.manfloor_edit.Enable = 'on';
        if  Docode_do_mvpa.manfloor_radio.Value==0
            Docode_do_mvpa.manfloor_edit.Enable = 'off';
        end
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Equal Trials, Max AVGs:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            observe_DECODE.Count_currentbest=1;
        end
        if Docode_do_mvpa.eq_trials_acrclas_radio.Value== 0 && Docode_do_mvpa.manfloor_radio.Value==0
            Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
        end

        if  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
            Enable_flag = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
        else
            Enable_flag = 'on';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        end
        Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        if numel(BESTArray)==1
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Value =0;
        end
    end


%%-----------------------Equalize trials Equal AVGs:checkbox---------------
    function eqtrials_eqavgs(~,~)
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
        Docode_do_mvpa.metric_ACC.Enable = 'on';
        if Docode_do_mvpa.max_trials_equalavg.Value==1
            Docode_do_mvpa.metric_ACC.Value=0;
            Docode_do_mvpa.metric_AUC.Value=0;
        end
        Docode_do_mvpa.eq_trials_maxavg.Value=0;
        Docode_do_mvpa.eqtrials_eqavgs.Value=1;
        Docode_do_mvpa.max_trials_equalavg.Value=0;

        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'on';
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
        Docode_do_mvpa.manfloor_radio.Enable = 'on';
        Docode_do_mvpa.manfloor_edit.Enable = 'on';
        if Docode_do_mvpa.eq_trials_acrclas_radio.Value== 0 && Docode_do_mvpa.manfloor_radio.Value==0
            Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
        end
        if Docode_do_mvpa.eqtrials_eqavgs.Value==1
            if  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
                Enable_flag = 'off';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
            else
                Enable_flag = 'on';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            end
            Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        end
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            observe_DECODE.Count_currentbest=1;
        end
        if numel(BESTArray)==1
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Value =0;
        end
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
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
        Docode_do_mvpa.metric_ACC.Enable = 'on';
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
        Docode_do_mvpa.manfloor_radio.Value=0;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            observe_DECODE.Count_currentbest=1;
        end
        if numel(BESTArray)==1
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
        end
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
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
        Docode_do_mvpa.metric_ACC.Enable = 'on';
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
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
        Docode_do_mvpa.metric_ACC.Enable = 'on';
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
        Docode_do_mvpa.manfloor_radio.Value=1;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.Enable = 'on';
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
        %%check if the floor number is below the minimal trial numbers/cross
        %%number
        manfloor_editnumber = str2num(Docode_do_mvpa.manfloor_edit.String);
        if isempty(manfloor_editnumber) || numel(manfloor_editnumber)~=1 || any(manfloor_editnumber(:)<1)
            manfloor_editnumber=1;
        end
        nBlocks = str2num(Docode_do_mvpa.foldsnum.String);
        if isempty(nBlocks) || numel(nBlocks)~=1 || any(nBlocks(:)<1)
            nBlocks = 3;
        end

        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        BEST = observe_DECODE.BEST;
        ALLBEST = observe_DECODE.ALLBEST;
        decodeClasses = ceil(str2num(Docode_do_mvpa.selclass_custom_defined.String));
        if isempty(decodeClasses) || any(decodeClasses(:)>BEST.nbin) || any(decodeClasses(:)<1)
            decodeClasses=1:BEST.nbin;
        end
        try Methodops = Docode_do_mvpa.paras_ops{1}; catch Methodops=1; end
        if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2 && Methodops~=3)
            Methodops=1;
        end

        for s = 1:numel(BESTArray)
            if isempty(decodeClasses) || any(decodeClasses(:)>ALLBEST(BESTArray(s)).nbin) || any(decodeClasses(:)<1)
                decodeClasses=1:ALLBEST(BESTArray(s)).nbin;
            end
            subj_ntrials = ALLBEST(BESTArray(s)).n_trials_per_bin(decodeClasses); %all trials per subject
            minCnt = min(subj_ntrials(:));
            if Methodops~=3
                nPerBinBlock(s) = floor(minCnt/nBlocks);
            else
                nPerBinBlock(s) = minCnt;
            end
        end
        value_check = min(nPerBinBlock);
        if manfloor_editnumber > value_check
            msgboxTest = sprintf(['You selected an invalid floor %i. The value exceeds the max the number of trials within cross-validation blocks (SVM) ' ...
                'or the max number of trials in any class (Crossnobis)'],manfloor_editnumber);
            title = 'ERPLAB Studio: Cross-Validation error';
            errorfound(msgboxTest, title);
            Docode_do_mvpa.manfloor_edit.String = '1';
        end


    end

%%-------------------------------floor number------------------------------
    function manfloor_edit(~,~)
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

        manfloor_editnumber = str2num(Docode_do_mvpa.manfloor_edit.String);
        if isempty(manfloor_editnumber) || numel(manfloor_editnumber)~=1 || any(manfloor_editnumber(:)<1)
            manfloor_editnumber=1;
        end
        nBlocks = str2num(Docode_do_mvpa.foldsnum.String);
        if isempty(nBlocks) || numel(nBlocks)~=1 || any(nBlocks(:)<1)
            nBlocks = 3;
        end

        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
        end
        BEST = observe_DECODE.BEST;
        ALLBEST = observe_DECODE.ALLBEST;
        decodeClasses = ceil(str2num(Docode_do_mvpa.selclass_custom_defined.String));
        if isempty(decodeClasses) || any(decodeClasses(:)>BEST.nbin) || any(decodeClasses(:)<1)
            decodeClasses=1:BEST.nbin;
        end
        try Methodops = Docode_do_mvpa.paras_ops{1}; catch Methodops=1; end
        if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2 && Methodops~=3)
            Methodops=1;
        end

        for s = 1:numel(BESTArray)
            if isempty(decodeClasses) || any(decodeClasses(:)>ALLBEST(BESTArray(s)).nbin) || any(decodeClasses(:)<1)
                decodeClasses=1:ALLBEST(BESTArray(s)).nbin;
            end
            subj_ntrials = ALLBEST(BESTArray(s)).n_trials_per_bin(decodeClasses); %all trials per subject
            minCnt = min(subj_ntrials(:));
            if Methodops~=3
                nPerBinBlock(s) = floor(minCnt/nBlocks);
            else
                nPerBinBlock(s) = minCnt;
            end
        end
        value_check = min(nPerBinBlock);
        if manfloor_editnumber > value_check
            msgboxTest = sprintf(['You selected an invalid floor %i. The value exceeds the max the number of trials within cross-validation blocks (SVM) ' ...
                'or the max number of trials in any class (Crossnobis)'],manfloor_editnumber);
            title = 'ERPLAB Studio: Cross-Validation error';
            errorfound(msgboxTest, title);
            Docode_do_mvpa.manfloor_edit.String = '1';
        end
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Manual floor:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
    end




%%-----------------------------Max Trials, Equal AVGs----------------------
    function Maxtrials_equalavg(~,~)
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
        Docode_do_mvpa.eq_trials_maxavg.Value=0;
        Docode_do_mvpa.max_trials_equalavg.Value=1;
        Docode_do_mvpa.eqtrials_eqavgs.Value=0;
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        Docode_do_mvpa.manfloor_radio.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
        Docode_do_mvpa.metric_ACC.Value = 0;
        Docode_do_mvpa.metric_ACC.Enable = 'off';
        Docode_do_mvpa.metric_AUC.Value = 1;

        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Equal Trials, Max AVGs:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
    end
%%--------------------------------ACC -------------------------------------
    function metric_ACC(~,~)
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
        Docode_do_mvpa.metric_ACC.Value =1;
        Docode_do_mvpa.metric_AUC.Value =0;
        ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArraydef)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
            Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
        end

    end


%%--------------------------------AUC -------------------------------------
    function metric_AUC(~,~)
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
        Docode_do_mvpa.metric_ACC.Value =0;
        Docode_do_mvpa.metric_AUC.Value =1;
        Docode_do_mvpa.chance.String = '0.5';

    end
%%-------------------------normalization:on--------------------------------
    function nor_on(~,~)
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
        Docode_do_mvpa.nor_on.Value=1;
        Docode_do_mvpa.nor_off.Value=0;
    end
%%-------------------------normalization:off-------------------------------
    function nor_off(~,~)
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
        Docode_do_mvpa.nor_on.Value=0;
        Docode_do_mvpa.nor_off.Value=1;
    end

%%--------------------------------TGM:on-----------------------------------
    function tgm_on(~,~)
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
        Docode_do_mvpa.tgm_on.Value=1;
        Docode_do_mvpa.tgm_off.Value=0;
    end

%%--------------------------------TGM:off-----------------------------------
    function tgm_off(~,~)
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
        Docode_do_mvpa.tgm_on.Value=0;
        Docode_do_mvpa.tgm_off.Value=1;
    end


%%----------------------Show Summary of AVGs and Trials--------------------
    function sum_avg_trials(~,~)
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
        %%block number
        foldsnum=   str2num(Docode_do_mvpa.foldsnum.String);%%Docode_do_mvpa.Paras{3}
        if isempty(foldsnum) || numel(foldsnum)~=1 || any(foldsnum(:)<1)
            foldsnum = 3;Docode_do_mvpa.foldsnum.String = '3';
        end

        %%subfolding strategy
        if Docode_do_mvpa.max_trials_equalavg.Value==1%%Maxtrials, equal AVGs
            equalize_trials=7;
        elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
            equalize_trials=4;%%class
        elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
            equalize_trials=5;%%best
        elseif  Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
            equalize_trials=6;%%Floor
            floorValue = ceil(str2num(Docode_do_mvpa.manfloor_edit.String));
            if isempty(floorValue) || numel(floorValue)~=1 || any(floorValue(:)<1) || any(observe_DECODE.BEST.n_trials_per_bin(:)<floorValue)
                floorValue=1;Docode_do_mvpa.manfloor_edit.String='1';
            end
        elseif  Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
            equalize_trials=1; %%Equal trials, Max AVGs
        elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
            equalize_trials=2; %%Equal trials, Max AVGs
        elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
            equalize_trials=3; %%Equal trials, Max AVGs
            floorValue = ceil(str2num(Docode_do_mvpa.manfloor_edit.String));
            if isempty(floorValue) || numel(floorValue)~=1 || any(floorValue(:)<1) || any(observe_DECODE.BEST.n_trials_per_bin(:)<floorValue)
                floorValue=1;Docode_do_mvpa.manfloor_edit.String='1';
            end
        end


        ALLBEST = observe_DECODE.ALLBEST(BESTArray);


        %%floor number
        if equalize_trials==3 || equalize_trials==6
            floorValue = ceil(str2num(Docode_do_mvpa.manfloor_edit.String));
            if isempty(floorValue) || numel(floorValue)~=1 || any(floorValue(:)<1) || any(observe_DECODE.BEST.n_trials_per_bin(:)<floorValue)
                floorValue=1;Docode_do_mvpa.manfloor_edit.String='1';
            end
        else
            floorValue = [];
        end
        %%decoding classes
        decodeClasses = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if isempty(decodeClasses) || any(decodeClasses(:)>observe_DECODE.BEST.nbin) || any(decodeClasses(:)<1)
            decodeClasses = [1:observe_DECODE.BEST.nbin];
        end

        %%decoding algorithm
        try selected_method = Docode_do_mvpa.paras_ops{1};catch  selected_method=1; end
        if isempty(selected_method) || numel(selected_method)~=1 || (selected_method~=1 && selected_method~=2 && selected_method~=3)
            selected_method = 1; Docode_do_mvpa.paras_ops{1}=1;
        end
        estudioworkingmemory('MVPA_sum_avg_trial',1);
        defs = {foldsnum,equalize_trials,floorValue,decodeClasses,selected_method};

        estudioworkingmemory('MVPA_sum_avg_trial',1);
        observe_DECODE.Count_currentbest =1;
        Docode_do_mvpa.selclass_all.Enable = 'off';
        Docode_do_mvpa.selclass_custom.Enable = 'off';
        Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
        Docode_do_mvpa.eq_trials_maxavg.Enable = 'off';
        Docode_do_mvpa.eqtrials_eqavgs.Enable = 'off';
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        Docode_do_mvpa.max_trials_equalavg.Enable = 'off';
        Docode_do_mvpa.manfloor_radio.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
        Docode_do_mvpa.table_bins.Enable = 'off';
        Docode_do_mvpa.mvpa_cancel.Enable = 'off';
        Docode_do_mvpa.mvpa_ops.Enable = 'off';
        Docode_do_mvpa.mvpa_run.Enable = 'off';
        Docode_do_mvpa.nor_on.Enable = 'off';
        Docode_do_mvpa.nor_off.Enable = 'off';
        Docode_do_mvpa.tgm_on.Enable = 'off';
        Docode_do_mvpa.tgm_off.Enable = 'off';
        Docode_do_mvpa.metric_ACC.Enable = 'off';
        Docode_do_mvpa.metric_AUC.Enable = 'off';
        Docode_do_mvpa.foldsnum.Enable = 'off';
        Docode_do_mvpa.channels_edit.Enable = 'off';
        Docode_do_mvpa.channels_browse.Enable = 'off';
        Docode_do_mvpa.iter_edit.Enable = 'off';
        app = feval('DecodingSumAVGsTrialsGUI', ALLBEST, defs,1); %cludgy way
        waitfor(app,'FinishButton',1);
        try
            decoding_res = app.output;
            app.delete;
            pause(0.5);
            estudioworkingmemory('MVPA_sum_avg_trial',0);
            observe_DECODE.Count_currentbest =1;
        catch
            disp('User selected Cancel');
            estudioworkingmemory('MVPA_sum_avg_trial',0);
            observe_DECODE.Count_currentbest =1;
            return
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
        try iter_edit =  Docode_do_mvpa.Paras{5}; catch  iter_edit =100; end
        if isempty(iter_edit) || numel(iter_edit)~=1 || any(iter_edit(:)<1)
            iter_edit=100;
        end
        Docode_do_mvpa.iter_edit.String = num2str(iter_edit);

        %%---------------------Trials, AVGs--------------------------------
        Docode_do_mvpa.eq_trials_maxavg.Value=0;
        Docode_do_mvpa.eqtrials_eqavgs.Value=0;
        Docode_do_mvpa.max_trials_equalavg.Value=0;
        try  equalizeTrials  =  Docode_do_mvpa.Paras{6};  catch  equalizeTrials=1; end
        if isempty(equalizeTrials) || numel(equalizeTrials)~=1 || any(equalizeTrials(:)<1)|| any(equalizeTrials(:)>5)
            equalizeTrials=1;
        end

        if equalizeTrials<7
            if equalizeTrials<4
                Docode_do_mvpa.eq_trials_maxavg.Value=1;
                Docode_do_mvpa.eqtrials_eqavgs.Value=0;
            else
                Docode_do_mvpa.eqtrials_eqavgs.Value=1;
                Docode_do_mvpa.eq_trials_maxavg.Value=0;
            end
            Docode_do_mvpa.manfloor_edit.String = '';
            Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'on';
            Docode_do_mvpa.manfloor_radio.Enable = 'on';
            if equalizeTrials==1 || equalizeTrials== 4
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
                Docode_do_mvpa.manfloor_radio.Value=0;
                Docode_do_mvpa.manfloor_edit.Enable = 'off';
            elseif equalizeTrials==2 || equalizeTrials==5
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=1;
                Docode_do_mvpa.manfloor_radio.Value=0;
                Docode_do_mvpa.manfloor_edit.Enable = 'off';
            elseif equalizeTrials==3 || equalizeTrials==6
                Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
                Docode_do_mvpa.manfloor_radio.Value=1;
                Docode_do_mvpa.manfloor_edit.Enable = 'on';
                try manfloor_edit = Docode_do_mvpa.Paras{7};catch manfloor_edit=1;  end
                if  isempty(manfloor_edit)  || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
                    manfloor_edit=1;
                end
                Docode_do_mvpa.manfloor_edit.String = num2str(manfloor_edit);
            end
        else
            Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            Docode_do_mvpa.manfloor_radio.Enable = 'off';
            Docode_do_mvpa.manfloor_edit.Enable = 'off';
            % Docode_do_mvpa.max_trials_equalavg.Enable = 'on';
        end
        try Outcome_metric=Docode_do_mvpa.Paras{8}; catch Outcome_metric=1; end
        if isempty(Outcome_metric) || numel(Outcome_metric)~=1 || (Outcome_metric~=0 && Outcome_metric~=1)
            Outcome_metric=1;
        end
        if equalizeTrials==7
            Docode_do_mvpa.max_trials_equalavg.Value=1;
            Outcome_metric=0;
            Docode_do_mvpa.metric_ACC.Enable = 'off';
            Docode_do_mvpa.max_trials_equalavg.Enable = 'off';
        else
            Docode_do_mvpa.max_trials_equalavg.Value=0;
            Docode_do_mvpa.metric_ACC.Enable = 'on';
            Docode_do_mvpa.max_trials_equalavg.Enable = 'on';
        end
        Docode_do_mvpa.metric_ACC.Value = Outcome_metric;
        Docode_do_mvpa.metric_AUC.Value = ~Outcome_metric;

        try nor_value = Docode_do_mvpa.Paras{9}; catch nor_value=0; end
        if isempty(nor_value) ||  numel(nor_value)~=1 || (nor_value~=0 && nor_value~=1)
            nor_value=1;
        end
        Docode_do_mvpa.nor_on.Value = ~nor_value;
        Docode_do_mvpa.nor_off.Value = nor_value;

        try tgm_value = Docode_do_mvpa.Paras{10}; catch tgm_value=0; end
        if isempty(tgm_value) ||  numel(tgm_value)~=1 || (tgm_value~=0 && tgm_value~=1)
            tgm_value=1;
        end
        Docode_do_mvpa.tgm_on.Value = ~tgm_value;
        Docode_do_mvpa.tgm_off.Value = tgm_value;


        % Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=eq_trials_acrbest_checkbox;
        Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
        Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
        Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
        Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
        Docode_do_mvpa.Paras{6} = equalizeTrials;
        Docode_do_mvpa.Paras{7} = str2num(Docode_do_mvpa.manfloor_edit.String);
        Docode_do_mvpa.Paras{8} =Docode_do_mvpa.metric_ACC.Value;
        Docode_do_mvpa.Paras{9} =     Docode_do_mvpa.nor_off.Value;
        Docode_do_mvpa.Paras{10} =     Docode_do_mvpa.tgm_off.Value;
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end

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
        Count_currentbest_change();
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
        if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2 && Methodops~=3)
            Methodops=1;
        end
        if Methodops==3
            Docode_do_mvpa.foldsnum.Enable = 'off';
            Enable_flag = 'off';
        else
            Docode_do_mvpa.foldsnum.Enable = 'on';
            Enable_flag = 'on';
        end

        % if Methodops<3
        %     Docode_do_mvpa.table_bins.ColumnName= {'BEST File','Class ID','Class/Label','N(trials)','B(ERPs)','N(per ERP)'};
        % else
        %     Docode_do_mvpa.table_bins.ColumnName= {'BEST File','Class ID','Class/Label','N(trials)'};
        % end
        Docode_do_mvpa.eq_trials_maxavg.Enable = Enable_flag;
        Docode_do_mvpa.max_trials_equalavg.Enable = Enable_flag;
        Docode_do_mvpa.metric_ACC.Enable = Enable_flag;
        Docode_do_mvpa.metric_AUC.Enable = Enable_flag;
        Docode_do_mvpa.eqtrials_eqavgs.Enable = Enable_flag;
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
        Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
        Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
        Docode_do_mvpa.nor_on.Enable = Enable_flag;
        Docode_do_mvpa.nor_off.Enable = Enable_flag;
        Docode_do_mvpa.tgm_on.Enable = Enable_flag;
        Docode_do_mvpa.tgm_off.Enable = Enable_flag;
        BESTArray= estudioworkingmemory('BESTArray');
        if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            BESTArray = length(observe_DECODE.ALLBEST);
            estudioworkingmemory('BESTArray',BESTArray);
            observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            observe_DECODE.Count_currentbest=1;
        end

        if Methodops<3
            try  equalizeTrials  =  Docode_do_mvpa.Paras{6};  catch  equalizeTrials=1; end
            if isempty(equalizeTrials) || numel(equalizeTrials)~=1 || any(equalizeTrials(:)<1)|| any(equalizeTrials(:)>7)
                equalizeTrials=1;
            end

            if  equalizeTrials <7
                if equalizeTrials <4
                    Docode_do_mvpa.eqtrials_eqavgs.Value=0;
                    Docode_do_mvpa.eq_trials_maxavg.Value=1;
                else
                    Docode_do_mvpa.eqtrials_eqavgs.Value=1;
                    Docode_do_mvpa.eq_trials_maxavg.Value=0;
                end
                Docode_do_mvpa.manfloor_edit.String = '';
                if equalizeTrials==1 ||  equalizeTrials==4
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                    if numel(BESTArray)==1
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                    else
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
                    end
                elseif equalizeTrials==2 || equalizeTrials==5
                    if numel(BESTArray)==1
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
                    else
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
                    end
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
                elseif equalizeTrials==3 || equalizeTrials==6
                    Docode_do_mvpa.manfloor_edit.Enable = 'on';
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                end
            else
                Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                Docode_do_mvpa.manfloor_radio.Enable = 'off';
                Docode_do_mvpa.manfloor_edit.Enable = 'off';
                % Docode_do_mvpa.nor_on.Enable = 'off';
                % Docode_do_mvpa.nor_off.Enable = 'off';
                % Docode_do_mvpa.tgm_on.Enable = 'off';
                % Docode_do_mvpa.tgm_off.Enable = 'off';
            end

            if equalizeTrials==7
                Docode_do_mvpa.metric_ACC.Enable = 'off';
            else
                Docode_do_mvpa.metric_ACC.Enable = 'on';
            end
        else

        end
        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Cross-validation Blocks:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        % end
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

        try selected_method = Docode_do_mvpa.paras_ops{1};catch  selected_method=1; end
        if isempty(selected_method) || numel(selected_method)~=1 || (selected_method~=1 && selected_method~=2 && selected_method~=3)
            selected_method = 1; Docode_do_mvpa.paras_ops{1}=1;
        end
        if selected_method == 2 %LDA
            smethod = 'LDA';
        elseif selected_method == 3
            smethod = 'Crossnobis';
        else%%SVM
            smethod = 'SVM';
        end
        try classcoding = Docode_do_mvpa.paras_ops{2}; catch  classcoding=2; end
        if isempty(classcoding) || numel(classcoding)~=1
            classcoding=2; Docode_do_mvpa.paras_ops{2}=2;
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
        %%Regulatization for SVM or LDA GH Oct 2025
        try  regularization_Value = Docode_do_mvpa.paras_ops{7}; catch regularization_Value = 0; end
        if selected_method==3%%
            regularization_Value = [];
        else %%SVM ;LDA
            if selected_method==2
                if isempty(regularization_Value) || numel(regularization_Value)~=1 || any(regularization_Value<0) || any(regularization_Value>1)
                    regularization_Value=0;
                end
            else
                if isempty(regularization_Value) || numel(regularization_Value)~=1 || any(regularization_Value<=0)
                    regularization_Value=1;
                end
            end
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

        %%GH Dec. 2025 7 options
        floorValue = [];
        if Docode_do_mvpa.max_trials_equalavg.Value==1%%Maxtrials, equal AVGs
            equalizeTrials=7;
            seqtr = 'MaxTrialsEqualAVGs';
        elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
            equalizeTrials=4;%%class
            seqtr = 'EqtrlEqagclasses';%%Equal trials, Equal AVGs
        elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
            equalizeTrials=5;%%best
            seqtr = 'EqtrlEqagbest';%%Equal trials, Equal AVGs
        elseif  Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
            equalizeTrials=6;%%Floor
            floorValue = ceil(str2num(Docode_do_mvpa.manfloor_edit.String));
            if isempty(floorValue) || numel(floorValue)~=1 || any(floorValue(:)<1) || any(BEST.n_trials_per_bin(:)<floorValue)
                floorValue=1;Docode_do_mvpa.manfloor_edit.String='1';
            end
            seqtr = 'EqtrlEqagfloor';%%Equal trials, Equal AVGs
        elseif  Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
            equalizeTrials=1; %%Equal trials, Max AVGs
            seqtr = 'EqtrlMaxagclasses';%%Equal trials, Max AVGs
        elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
            equalizeTrials=2; %%Equal trials, Max AVGs
            seqtr = 'EqtrlMaxagbest';%%Equal trials, Max AVGs
        elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
            equalizeTrials=3; %%Equal trials, Max AVGs
            floorValue = ceil(str2num(Docode_do_mvpa.manfloor_edit.String));
            if isempty(floorValue) || numel(floorValue)~=1 || any(floorValue(:)<1) || any(BEST.n_trials_per_bin(:)<floorValue)
                floorValue=1;Docode_do_mvpa.manfloor_edit.String='1';
            end
            seqtr = 'EqtrlMaxagfloor';%%Equal trials, Max AVGs
        end

        if Docode_do_mvpa.metric_ACC.Value==0 && Docode_do_mvpa.metric_AUC.Value==0
            msgboxText = 'Multivariate Pattern Classification>Run:Please choose one decoding metric to use [accuracy (ACC) or area under the curve (AUC)].';
            titlNamerro = 'Warning for Pattern Classification Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end

        Outcome_metric = Docode_do_mvpa.metric_ACC.Value;
        if Outcome_metric==1
            MetricStr = 'ACC';
        else
            MetricStr = 'AUC';
        end
        if equalizeTrials==7
            MetricStr = 'AUC';
        end
        Normalization_par=Docode_do_mvpa.nor_off.Value;
        if selected_method==3
            Normalization_par=1;
        end
        if Normalization_par==1
            Normalization_str = 'off';
        else
            Normalization_str = 'on';
        end

        decodeClasses = ceil(str2num(Docode_do_mvpa.selclass_custom_defined.String));
        if isempty(decodeClasses) || any(decodeClasses(:)>BEST.nbin) || any(decodeClasses(:)<1)
            decodeClasses=1:BEST.nbin;
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

        % [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        % if ~isempty(errormess)
        %     msgboxText =  ['Multivariate Pattern Classification>Run:',32,errormess];
        %     titlNamerro = 'Warning for Pattern Classification Tab';
        %     estudio_warning(msgboxText,titlNamerro);
        %     return;
        % end
        estudioworkingmemory('f_Decode_proces_messg','Multivariate Pattern Classification');
        observe_DECODE.Process_messg =1; %%Marking for the procedure has been started.

        def = {[], [], relevantChans, nIter, nCrossBlocks, epoch_times, ...
            decodeTimes, decode_every_Npoint, 2, floorValue, ...
            selected_method, classcoding, ParCompute,decodeClasses,regularization_Value,Outcome_metric,Normalization_par};
        estudioworkingmemory('pop_decoding',def);
        ALLMVPC_out = [];
        ALLBEST = observe_DECODE.ALLBEST;
        for  Numofbest = 1:numel(BESTArray)
            BEST = observe_DECODE.ALLBEST(BESTArray(Numofbest));
            DataTimes = BEST.times;
            equalT = 'classes';
            classcoding=2;
            method=1;
            MVPC = buildMVPCstruct(BEST,relevantChans, nIter, nCrossBlocks, DataTimes,equalT,classcoding,method);
            MVPC.mvpcname = BEST.bestname;
            MVPC.filename = BEST.filename;
            MVPC.filepath =BEST.filepath;
            if isempty(ALLMVPC_out)
                ALLMVPC_out = MVPC;
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
        if equalizeTrials==6 && numel(BESTArray)>1
            for Numofbest = 1:numel(BESTArray)
                n_trials_per_bin=  ALLBEST(BESTArray(Numofbest)).n_trials_per_bin(decodeClasses);
                n_trials_per_binmin(Numofbest) = min(n_trials_per_bin(:));
            end
        elseif equalizeTrials==3 && numel(BESTArray)>1


        end
        if Docode_do_mvpa.tgm_off.Value==1
            TGM_Str = 'off';
        else
            TGM_Str = 'on';
        end
        [MVPC_out,BESTCOM,ALLMVPC_new] = pop_decoding(ALLBEST,'BESTindex', BESTArray, 'Classes', decodeClasses, ...
            'Channels', relevantChans, 'nIter',nIter,'nCrossblocks',nCrossBlocks,  ...
            'DecodeTimes', decodeTimes, 'Decode_Every_Npoint',decode_every_Npoint,  ...
            'TrialsAVGs', seqtr, 'FloorValue',floorValue,'Method', smethod, ...
            'classcoding',strcoding, 'Saveas','off', 'ParCompute',spar, ...
            'Regularization',regularization_Value,'OutcomeMetric',MetricStr,'Normalization',Normalization_str,...
            'TGM',TGM_Str,'History','script','Tooltype','estudio');%'BetaWeights', sbeta,


        for Numofbest = 1:numel(BESTArray)
            BEST = observe_DECODE.ALLBEST(BESTArray(Numofbest));
            % fprintf( ['\n\n',repmat('-',1,100) '\n']);
            % fprintf(['*Multivariate Pattern Classification>Run*',32,32,32,32,datestr(datetime('now')),'\n']);
            % %             fprintf(['Your current BESTset(No.',num2str(BESTArray(Numofbest)),'):',32,BEST.bestname,'\n\n']);
            % if equalizeTrials==6 && numel(BESTArray)>1
            %     ALLBEST(BESTArray(Numofbest)).n_trials_per_bin  =min(n_trials_per_binmin(:))*ones(1,ALLBEST(BESTArray(Numofbest)).nbin);
            % end
            %
            if isempty(BESTCOM)
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return;
            end
            fprintf([BESTCOM]);

            if ~isempty(BESTCOM) && ~isempty(BEST.EEGhistory)
                olderpcom = cellstr(BEST.EEGhistory);
                newerpcom = [olderpcom; {[BESTCOM ,'% ', 'GUI: ', datestr(now)]}];
                BEST.EEGhistory = char(newerpcom);
            elseif ~isempty(BESTCOM) && isempty(BEST.EEGhistory)
                BEST.EEGhistory = [char(BESTCOM) , '% ', 'GUI: ', datestr(now)];
            end

            observe_DECODE.ALLBEST(BESTArray(Numofbest)) = BEST;

            if Numofbest==1;
                mvpch(BESTCOM);
            end
            ALLMVPC_new(Numofbest).mvpcname = ALLMVPC_out(Numofbest).mvpcname;
            ALLMVPC_new(Numofbest).filename = ALLMVPC_out(Numofbest).filename;
            ALLMVPC_new(Numofbest).filepath =ALLMVPC_out(Numofbest).filepath;

            if Save_file_label==1
                [pathstr, file_name, ext] = fileparts(ALLMVPC_new(Numofbest).filename);
                ALLMVPC_new(Numofbest).filename = [file_name,'.mvpc'];
                [MVPC, issave, MVPCCOM] = pop_savemymvpc(ALLMVPC_new(Numofbest), 'mvpcname', ALLMVPC_new(Numofbest).mvpcname, 'filename', ALLMVPC_new(Numofbest).filename,...
                    'filepath',ALLMVPC_new(Numofbest).filepath,'Tooltype','estudio','gui' ,'script');
                if ~isempty(MVPCCOM) && Numofbest==1
                    mvpch(MVPCCOM);
                end
            else
                MVPC = ALLMVPC_new(Numofbest);
                MVPC.filename = '';
                MVPC.saved = 'no';
                MVPC.filepath = '';
            end
            if isempty(ALLMVPC)
                ALLMVPC = MVPC;
            else
                ALLMVPC(length(ALLMVPC)+1) = MVPC;
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
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
        Docode_do_mvpa.Paras{6} = equalizeTrials;
        Docode_do_mvpa.Paras{7} = str2num(Docode_do_mvpa.manfloor_edit.String);
        Docode_do_mvpa.Paras{8} = Outcome_metric;
        Docode_do_mvpa.Paras{9} =     Docode_do_mvpa.nor_off.Value;
        Docode_do_mvpa.Paras{10} =     Docode_do_mvpa.tgm_off.Value;
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
        Docode_do_mvpa.eqtrials_eqavgs.Enable = Edit_label;
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Edit_label;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Edit_label;
        Docode_do_mvpa.manfloor_radio.Enable = Edit_label;
        Docode_do_mvpa.manfloor_edit.Enable = Edit_label;
        Docode_do_mvpa.eq_trials_maxavg.Enable = Edit_label;
        Docode_do_mvpa.max_trials_equalavg.Enable = Edit_label;
        Docode_do_mvpa.metric_ACC.Enable = Edit_label;
        Docode_do_mvpa.metric_AUC.Enable = Edit_label;
        Docode_do_mvpa.nor_on.Enable = Edit_label;
        Docode_do_mvpa.nor_off.Enable = Edit_label;
        Docode_do_mvpa.table_bins.Enable = Edit_label;
        Docode_do_mvpa.mvpa_cancel.Enable = Edit_label;
        Docode_do_mvpa.mvpa_ops.Enable = Edit_label;
        Docode_do_mvpa.mvpa_run.Enable = Edit_label;
        Docode_do_mvpa.tgm_on.Enable = Edit_label;
        Docode_do_mvpa.tgm_off.Enable = Edit_label;
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
            if Docode_do_mvpa.eqtrials_eqavgs.Value==1 ||  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
                Enable_flag = 'on';
            else
                Enable_flag = 'off';
            end
            Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
            Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
            Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
            if Docode_do_mvpa.eqtrials_eqavgs.Value==1 ||  Docode_do_mvpa.eq_trials_acrclas_radio.Value==1
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
            % BESTArray= estudioworkingmemory('BESTArray');
            % if isempty(BESTArray) || any(BESTArray>length(observe_DECODE.ALLBEST))
            %     BESTArray = length(observe_DECODE.ALLBEST);
            %     estudioworkingmemory('BESTArray',BESTArray);
            %     observe_DECODE.BEST = observe_DECODE.ALLBEST(end);
            %     observe_DECODE.CURRENTBEST =length(observe_DECODE.ALLBEST);
            %     observe_DECODE.Count_currentbest=1;
            % end

            checking = checkmultiBEST(observe_DECODE.ALLBEST(BESTArray));
            if ~checking && numel(BESTArray)>1
                msgboxText = {'Welcome to the Estudio decoding GUI',
                    'Estudio detected that the currently selected BESTsets as specified in the BESTset panel',
                    'do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.',
                    ' ',
                    'Please select BESTsets that match in terms of bins and channels!',
                    'You can:',
                    '1: Select the indicies of the BESTsets that match in terms of bins and channels in the "From BESTsets Panel" Options'};
                % Docode_do_mvpa.table_bins.Data = msgboxText;
                % Docode_do_mvpa.table_bins.ColumnName= {' '};
                % Docode_do_mvpa.table_bins.ColumnWidth ={600};
                Docode_do_mvpa.selclass_all.Enable = 'off';
                Docode_do_mvpa.selclass_custom.Enable = 'off';
                Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
                Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
                Docode_do_mvpa.no_class.String = '';
                Docode_do_mvpa.channels_edit.Enable = 'off';
                Docode_do_mvpa.channels_browse.Enable = 'off';
                Docode_do_mvpa.iter_edit.Enable = 'off';
                Docode_do_mvpa.eq_trials_maxavg.Enable = 'off';
                Docode_do_mvpa.eqtrials_eqavgs.Enable = 'off';
                Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                Docode_do_mvpa.manfloor_radio.Enable = 'off';
                Docode_do_mvpa.manfloor_edit.Enable = 'off';
                Docode_do_mvpa.max_trials_equalavg.Enable = 'off';
                Docode_do_mvpa.foldsnum.Enable = 'off';
                Docode_do_mvpa.mvpa_cancel.Enable = 'off';
                Docode_do_mvpa.mvpa_ops.Enable = 'off';
                Docode_do_mvpa.mvpa_run.Enable = 'off';
                Docode_do_mvpa.foldsnum.Enable = 'off';
                Docode_do_mvpa.metric_ACC.Enable = 'off';
                Docode_do_mvpa.metric_AUC.Enable = 'off';
                Docode_do_mvpa.nor_on.Enable = 'off';
                Docode_do_mvpa.nor_off.Enable = 'off';
                Docode_do_mvpa.tgm_on.Enable = 'off';
                Docode_do_mvpa.tgm_off.Enable = 'off';


            else
                %%if select crossvalidated mahalanobis
                try Methodops = Docode_do_mvpa.paras_ops{1}; catch Methodops=1; end
                if isempty(Methodops) || numel(Methodops)~=1 || (Methodops~=1 && Methodops~=2 && Methodops~=3)
                    Methodops=1;
                end
                % if Methodops<3
                %     %     Docode_do_mvpa.table_bins.ColumnName= {'BEST File','Class ID','Class/Label','N(trials)','B(ERPs)','N(per ERP)'};
                %     % else
                %     %     Docode_do_mvpa.table_bins.ColumnName= {'BEST File','Class ID','Class/Label','N(trials)'};
                % end
                if Docode_do_mvpa.max_trials_equalavg.Value==1%%Maxtrials, equal AVGs
                    classtrialType=7;
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
                    classtrialType=4;%%classes
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
                    classtrialType=5;%%best
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                elseif  Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
                    classtrialType=6;%%Floor
                    Docode_do_mvpa.manfloor_edit.Enable = 'on';
                elseif   Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
                    classtrialType=1; %%Equal trials, Max AVGs across classes
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
                    classtrialType=2;%%Equal trials, Max AVGs across bestes
                    Docode_do_mvpa.manfloor_edit.Enable = 'off';
                elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 &&  Docode_do_mvpa.manfloor_radio.Value==1
                    classtrialType=3;%%Equal trials, Max AVGs    Floor
                    Docode_do_mvpa.manfloor_edit.Enable = 'on';
                end

                if Methodops==3%%GH Oct 2025 disable the trials & AVGs panels
                    Enable_flag = 'off';
                else
                    Enable_flag = 'on';
                end
                Docode_do_mvpa.eq_trials_maxavg.Enable = Enable_flag;
                Docode_do_mvpa.max_trials_equalavg.Enable = Enable_flag;
                Docode_do_mvpa.metric_ACC.Enable = Enable_flag;
                Docode_do_mvpa.metric_AUC.Enable = Enable_flag;
                Docode_do_mvpa.nor_on.Enable = Enable_flag;
                Docode_do_mvpa.nor_off.Enable = Enable_flag;
                Docode_do_mvpa.eqtrials_eqavgs.Enable = Enable_flag;
                Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
                Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
                Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
                Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
                Docode_do_mvpa.nor_on.Enable = Enable_flag;
                Docode_do_mvpa.nor_off.Enable = Enable_flag;
                Docode_do_mvpa.tgm_on.Enable = Enable_flag;
                Docode_do_mvpa.tgm_off.Enable = Enable_flag;
                Docode_do_mvpa.foldsnum.Enable = Enable_flag;
                if  Methodops~=3
                    if classtrialType==3 || classtrialType==6;%%Floor
                        Docode_do_mvpa.manfloor_edit.Enable = 'on';
                    else
                        Docode_do_mvpa.manfloor_edit.Enable = 'off';
                    end
                end
                if  classtrialType==7
                    Enable_flag = 'off';
                    Docode_do_mvpa.eq_trials_acrclas_radio.Enable = Enable_flag;
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = Enable_flag;
                    Docode_do_mvpa.manfloor_radio.Enable = Enable_flag;
                    Docode_do_mvpa.manfloor_edit.Enable = Enable_flag;
                end

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

                if classtrialType==7
                    Docode_do_mvpa.metric_ACC.Enable = 'off';
                    Docode_do_mvpa.metric_ACC.Value=0;
                    Docode_do_mvpa.metric_AUC.Value=1;
                else
                    if Methodops~=7 && Methodops~=3
                        Docode_do_mvpa.metric_ACC.Enable = 'on';
                    end
                end

                ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
                if ~isempty(ClassArraydef)
                    Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
                    if Docode_do_mvpa.metric_AUC.Value==0
                        Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
                    else
                        Docode_do_mvpa.chance.String = '0.5';
                    end
                end

                % FloorNum=manfloor_edit;
                % try trialsbymethod= Docode_do_mvpa.paras_ops{1}; catch trialsbymethod=1; end
                % if isempty(trialsbymethod) || numel(trialsbymethod)~=1 || (trialsbymethod~=1 && trialsbymethod~=2 && trialsbymethod~=3)
                %     trialsbymethod=1;
                % end
                % % Data = updatetabledata(observe_DECODE.ALLBEST(BESTArray),decodebins,trialsbymethod,nBlock,classtrialType,FloorNum);
                % % Docode_do_mvpa.table_bins.Data = Data;
                % % Docode_do_mvpa.table_bins.ColumnWidth ={50,50,70,50,60};
                if  classtrialType==1 || classtrialType==4%%class
                    if numel(BESTArray)==1
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                    else
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
                    end
                elseif  classtrialType==2 ||  classtrialType==5;
                    if numel(BESTArray)==1
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Value =0;
                    else
                        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
                    end
                else
                    Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';

                end
            end
            %%save parameters
            Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
            Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
            Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
            Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
            Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
            Docode_do_mvpa.Paras{6} = classtrialType;
            Docode_do_mvpa.Paras{7} = str2num(Docode_do_mvpa.manfloor_edit.String);
            Docode_do_mvpa.Paras{8} = Docode_do_mvpa.metric_ACC.Value;
            Docode_do_mvpa.Paras{9} =     Docode_do_mvpa.nor_off.Value;
            Docode_do_mvpa.Paras{10} =     Docode_do_mvpa.tgm_off.Value;
            if Methodops<3 || (~checking && numel(BESTArray)>1)
                Docode_do_mvpa.foldsnum.Enable = 'on';
            else
                Docode_do_mvpa.foldsnum.Enable = 'off';
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
        if observe_DECODE.Reset_Best_paras_panel~=7
            return;
        end

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

        Docode_do_mvpa.eq_trials_maxavg.Value=0;
        Docode_do_mvpa.eqtrials_eqavgs.Value=0;
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Value=0;
        Docode_do_mvpa.manfloor_radio.Value=0;
        Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        Docode_do_mvpa.manfloor_radio.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.String = '';
        Docode_do_mvpa.max_trials_equalavg.Value=1;%%Maxtrials, equal AVGs
        Docode_do_mvpa.tgm_off.Value =1;
        Docode_do_mvpa.tgm_on.Value =0;
        Docode_do_mvpa.nor_off.Value = 1;
        Docode_do_mvpa.nor_on.Value = 0;
        if Docode_do_mvpa.max_trials_equalavg.Value==1%%Maxtrials, equal AVGs
            classtrialType=7;
            Docode_do_mvpa.metric_ACC.Value=0;
            Docode_do_mvpa.metric_AUC.Value=1;
            Docode_do_mvpa.metric_ACC.Enable = 'off';
        elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
            classtrialType=4;%%class
        elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
            classtrialType=5;%%best
        elseif  Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
            classtrialType=6;%%Floor
        elseif  Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
            classtrialType=1; %%Equal trials, Max AVGs
        elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
            classtrialType=2; %%Equal trials, Max AVGs
        elseif Docode_do_mvpa.eq_trials_maxavg.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
            classtrialType=3; %%Equal trials, Max AVGs
        end

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
            % Docode_do_mvpa.table_bins.Data = msgboxText;
            % Docode_do_mvpa.table_bins.ColumnName= {' '};
            % Docode_do_mvpa.table_bins.ColumnWidth ={600};
            Docode_do_mvpa.selclass_all.Enable = 'off';
            Docode_do_mvpa.selclass_custom.Enable = 'off';
            Docode_do_mvpa.selclass_custom_browse.Enable = 'off';
            Docode_do_mvpa.selclass_custom_defined.Enable = 'off';
            %                 Docode_do_mvpa.no_class.String = '';
            Docode_do_mvpa.channels_edit.Enable = 'off';
            Docode_do_mvpa.channels_browse.Enable = 'off';
            Docode_do_mvpa.iter_edit.Enable = 'off';
            Docode_do_mvpa.eqtrials_eqavgs.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrclas_radio.Enable = 'off';
            Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
            Docode_do_mvpa.manfloor_radio.Enable = 'off';
            Docode_do_mvpa.manfloor_edit.Enable = 'off';
            Docode_do_mvpa.foldsnum.Enable = 'off';
            Docode_do_mvpa.mvpa_cancel.Enable = 'off';
            Docode_do_mvpa.mvpa_ops.Enable = 'off';
            Docode_do_mvpa.mvpa_run.Enable = 'off';
            Docode_do_mvpa.foldsnum.Enable = 'off';
            Docode_do_mvpa.tgm_off.Enable = 'off';
            Docode_do_mvpa.tgm_on.Enable = 'off';
            Docode_do_mvpa.nor_off.Enable = 'off';
            Docode_do_mvpa.nor_on.Enable = 'off';
        end
        ClassArraydef = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        if ~isempty(ClassArraydef)
            Docode_do_mvpa.no_class.String = num2str(numel(ClassArraydef));
            if Docode_do_mvpa.metric_AUC.Value==0
                Docode_do_mvpa.chance.String = num2str(roundn(1/numel(ClassArraydef),-2));
            else
                Docode_do_mvpa.chance.String = '0.5';
            end
        end
        %%Update the table
        % if checking && ~isempty(observe_DECODE.BEST) && ~isempty(observe_DECODE.ALLBEST)
        %     [Docode_do_mvpa,errormess] = f_updatables(Docode_do_mvpa);
        %     if ~isempty(errormess)
        %         msgboxText =  ['Multivariate Pattern Classification:',32,errormess];
        %         titlNamerro = 'Warning for Pattern Classification Tab';
        %         estudio_warning(msgboxText,titlNamerro);
        %     end
        % end
        Docode_do_mvpa.selclass_all.Value = 1;
        Docode_do_mvpa.selclass_all.Value = 0;

        Docode_do_mvpa.Paras{1} = Docode_do_mvpa.selclass_all.Value;
        Docode_do_mvpa.Paras{2} = str2num(Docode_do_mvpa.selclass_custom_defined.String);
        Docode_do_mvpa.Paras{3} = str2num(Docode_do_mvpa.foldsnum.String);
        Docode_do_mvpa.Paras{4} = str2num(Docode_do_mvpa.channels_edit.String);
        Docode_do_mvpa.Paras{5} = str2num(Docode_do_mvpa.iter_edit.String);
        Docode_do_mvpa.Paras{6} = classtrialType;
        Docode_do_mvpa.Paras{7} = str2num(Docode_do_mvpa.manfloor_edit.String);
        Docode_do_mvpa.Paras{8} =Docode_do_mvpa.metric_ACC.Value;
        Docode_do_mvpa.Paras{9} =     Docode_do_mvpa.nor_off.Value;
        Docode_do_mvpa.Paras{10} = Docode_do_mvpa.tgm_off.Value;
        Docode_do_mvpa.paras_ops = {1,2,1,[],1,0,0};
        % observe_DECODE.Reset_Best_paras_panel=2;
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
if isempty(trialsbymethod) || numel(trialsbymethod)~=1 || (trialsbymethod~=1 && trialsbymethod~=2 && trialsbymethod~=3)
    trialsbymethod=1;
end

%%No. of blocks
nBlock = str2num(Docode_do_mvpa.foldsnum.String);
if isempty(nBlock) || numel(nBlock)~=1 || any(nBlock(:)<=0)
    nBlock=3;
    Docode_do_mvpa.foldsnum.String = '3';
end

if Docode_do_mvpa.max_trials_equalavg.Value==1 %%Max trials, equal avgs
    classtrialType=5;
elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==0
    classtrialType=2;
elseif Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.eq_trials_acrclas_radio.Value==1 && Docode_do_mvpa.eq_trials_acrbest_checkbox.Value==1
    classtrialType=3;
elseif  Docode_do_mvpa.eqtrials_eqavgs.Value==1 && Docode_do_mvpa.manfloor_radio.Value==1
    classtrialType=4;
else%%Equal trials, Max AVGs
    classtrialType=1;
end

%%
manfloor_edit = str2num(Docode_do_mvpa.manfloor_edit.String);
if  isempty(manfloor_edit)  || numel(manfloor_edit)~=1 || any(manfloor_edit(:)<1)
    Docode_do_mvpa.manfloor_edit.String = '1';manfloor_edit=1;
end
FloorNum=manfloor_edit;

[Data,errormess] = updatetabledata(observe_DECODE.ALLBEST(BESTArray),decodebins,trialsbymethod,nBlock,classtrialType,FloorNum);
if ~isempty(Data) && isempty(errormess)

    if trialsbymethod<3
        % Docode_do_mvpa.table_bins.ColumnWidth ={50,50,70,50,50,60};
        % Docode_do_mvpa.table_bins.Data = Data;
    else
        try Data(:,6) = []; catch  end;
        try Data(:,5) = []; catch  end;
        % Docode_do_mvpa.table_bins.Data = Data;
        % Docode_do_mvpa.table_bins.ColumnWidth ={100,100,70,50};
    end
end
end



function [tmpdata,errormess]= updatetabledata(ALLBEST,decodebins,trialsbymethod,nBlock,classtrialType,FloorNum)
tmpdata = [];
[nPerBinCheckall,errormess] = f_BinCheck(ALLBEST,decodebins,trialsbymethod,nBlock,classtrialType,FloorNum);
if ~isempty(errormess)
    return;
end

%%trialsbymethod-1.SVM 2. LDA
if trialsbymethod <3 %svm or lda
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
                nPerBin{rowInd} = num2str(nPerBinCheckall(rowIndbin));
                if classtrialType==1%%GH Oct 2025
                    nblockcells{rowInd} =  num2str(floor(ALLBEST(f).n_trials_per_bin(b)/nPerBinCheckall(rowIndbin)));
                else
                    nblockcells{rowInd} = num2str(nBlock);
                end
            else
                nPerBin{rowInd} = 'NOT USED';
                nblockcells{rowInd} = 'NOT USED';%%GH Oct 2025
            end
        end
    end
    tmpdata = cell(length(bestfils),5);
    tmpdata(:,1) = bestfils';
    tmpdata(:,2) =classid';
    tmpdata(:,3) =claslabel';
    tmpdata(:,4) =trialnum';
    tmpdata(:,5) = nblockcells';
    tmpdata(:,6) = nPerBin';
elseif trialsbymethod == 3 %crossnobis
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
    try    tmpdata(:,6) = []; catch  end;
    try  tmpdata(:,5) = [];catch  end
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
%%---------------------------------SVM & LDA method------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trialsbymethod == 1  ||  trialsbymethod == 2
    %%classtrialType--1 is inactive equalize trials
    if classtrialType==7
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%--------------------euqal trials, equal AVGs-----------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if classtrialType==4
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
    if classtrialType==5
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

    %%----------------4 Common floor--------------------------------------
    if classtrialType==6
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%--------------------euqal trials, Max AVGs-----------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if classtrialType==1%%equal trials, Max avgs %%GH Oct 2025
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheckall(count,1) = floor(min(ALLBEST(Numofbest).n_trials_per_bin(decodebins))/nBlock);
                nPerBinCheck(count,1) = floor(min(ALLBEST(Numofbest).n_trials_per_bin(decodebins))/nBlock);
            end
        end
        if any(nPerBinCheckall(:)<1)
            nPerBinCheck = [];
            errormess = ['The block number should be smaller than',32,num2str(min(nPerBinCheckall(:)))];
            return;
        end
        return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------------Corssvalidated Mahalanobis-----------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if trialsbymethod == 3
    %%classtrialType--1 is inactive equalize trials
    classtrialType=5;%%GH Oct 2025
    if classtrialType==5
        count = 0;
        for Numofbest = 1:length(ALLBEST)
            for Numofbin = 1:numel(decodebins)
                count = count+1;
                nPerBinCheck(count,1) = ALLBEST(Numofbest).n_trials_per_bin(decodebins(Numofbin));
            end
        end
        return;
    end
end
end