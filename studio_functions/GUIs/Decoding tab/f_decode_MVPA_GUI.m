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
        
        Docode_do_mvpa.select_classes_title = uiextras.HBox('Parent',  Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.select_classes_title,...
            'String','Select Classes To Decode Across:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        %%class all vs custom
        Docode_do_mvpa.select_classes = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_all = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.select_classes ,'Value',1,...
            'String','ALL','callback',@selclass_all,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_all.KeyPressFcn=  @eeg_binepoch_presskey;
        Docode_do_mvpa.selclass_custom = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.select_classes ,'Value',0,...
            'String','Custom','callback',@selclass_custom,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_custom.KeyPressFcn=  @eeg_binepoch_presskey;
        %%defined class
        Docode_do_mvpa.select_classes_custom = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.select_classes_custom,...
            'String','Class ID','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.selclass_custom_defined = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.select_classes_custom ,'Value',0,...
            'String',' ','callback',@selclass_custom_defined,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.selclass_custom_defined.KeyPressFcn=  @eeg_binepoch_presskey;
        Docode_do_mvpa.selclass_custom_browse = uicontrol('Style', 'pushbutton','Parent', Docode_do_mvpa.select_classes_custom ,'Value',0,...
            'String','Browse','callback',@selclass_custom_browse,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.selclass_custom_browse.KeyPressFcn=  @eeg_binepoch_presskey;
        set(Docode_do_mvpa.select_classes_custom,'Sizes',[60 -1 60]);
        
        
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
            'String','Corss-validation Blocks','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.foldsnum = uicontrol('Style', 'edit','Parent',  Docode_do_mvpa.folds_title,...
            'String',' ','callback',@foldsnum,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.folds_title ,'Sizes',[140 -1]);
        %%channels
        Docode_do_mvpa.channels_custom = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.channels_custom ,...
            'String','Channels','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.channels_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.channels_custom,...
            'String',' ','callback',@channels_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.channels_edit.KeyPressFcn=  @eeg_binepoch_presskey;
        Docode_do_mvpa.channels_browse = uicontrol('Style', 'pushbutton','Parent',Docode_do_mvpa.channels_custom ,...
            'String','Browse','callback',@channels_browse,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.channels_browse.KeyPressFcn=  @eeg_binepoch_presskey;
        set(Docode_do_mvpa.channels_custom,'Sizes',[60 -1 60]);
        
        
        %%Iterations
        Docode_do_mvpa.iter_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', Docode_do_mvpa.iter_title ,...
            'String','Iterations','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.iter_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.iter_title,...
            'String',' ','callback',@iter_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.iter_edit.KeyPressFcn=  @eeg_binepoch_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.iter_title );
        set(Docode_do_mvpa.iter_title,'Sizes',[60 -1 60]);
        
        
        %%Equalize trials
        Docode_do_mvpa.eq_trials_checkbox_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_checkbox = uicontrol('Style', 'checkbox','Parent', Docode_do_mvpa.eq_trials_checkbox_title,'Value',1,...
            'String','Equalize Trials','callback',@eq_trials_checkbox,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_checkbox.KeyPressFcn=  @eeg_binepoch_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_checkbox_title);
        set(Docode_do_mvpa.eq_trials_checkbox_title,'Sizes',[140 -1]);
        
        %%across Classes
        Docode_do_mvpa.eq_trials_acrclass_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrclass_title);
        Docode_do_mvpa.eq_trials_acrclas_radio = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.eq_trials_acrclass_title,'Value',1,...
            'String','Across Classes','callback',@eq_trials_acrclas_radio,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_acrclas_radio.KeyPressFcn=  @eeg_binepoch_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrclass_title);
        set(Docode_do_mvpa.eq_trials_acrclass_title,'Sizes',[20 140 -1]);
        
        %%across bests
        Docode_do_mvpa.eq_trials_acrbest_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrbest_title);
        Docode_do_mvpa.eq_trials_acrbest_checkbox = uicontrol('Style', 'checkbox','Parent', Docode_do_mvpa.eq_trials_acrbest_title,'Value',1,...
            'String','Across BESTsets','callback',@eq_trials_acrbest_checkbox,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.eq_trials_acrclas_radio.KeyPressFcn=  @eeg_binepoch_presskey;
        uiextras.Empty('Parent', Docode_do_mvpa.eq_trials_acrbest_title);
        set(Docode_do_mvpa.eq_trials_acrbest_title,'Sizes',[40 140 -1]);
        
        %%Manual Floor
        Docode_do_mvpa.manfloor_title = uiextras.HBox('Parent',   Docode_do_mvpa.vBox_decode,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', Docode_do_mvpa.manfloor_title);
        Docode_do_mvpa.manfloor_radio = uicontrol('Style', 'radiobutton','Parent', Docode_do_mvpa.manfloor_title,'Value',0,...
            'String','Manual Floor','callback',@manfloor_radio,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Docode_do_mvpa.manfloor_radio.KeyPressFcn=  @eeg_binepoch_presskey;
        Docode_do_mvpa.manfloor_edit = uicontrol('Style', 'edit','Parent', Docode_do_mvpa.manfloor_title,...
            'String','','callback',@manfloor_edit,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(Docode_do_mvpa.manfloor_title,'Sizes',[20 140 -1]);
        
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
            'String','Option','callback',@mvpa_ops,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        Docode_do_mvpa.mvpa_run = uicontrol('Style','pushbutton','Parent',Docode_do_mvpa.detar_run_title,...
            'String','Run','callback',@mvpa_run,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        
        set(Docode_do_mvpa.vBox_decode,'Sizes',[20 25 25 20 25 25 25 25 25 25 16 16 25 100 30]);
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
        end
    end

%%------------------------radio custom classes-----------------------------
    function selclass_custom(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
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
        end
    end
%%-------------------------Browse classes----------------------------------
    function selclass_custom_browse(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        
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
        end
    end
%%------------------------Numbr of class folds-----------------------------
    function foldsnum(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Cossfolds = str2num(Docode_do_mvpa.foldsnum.String);
        if isempty(Cossfolds) || numel(Cossfolds)~=1
            Docode_do_mvpa.foldsnum.String = '3';
            Cossfolds=3;
        end
        if isnumeric(observe_DECODE.BEST.n_trials_per_bin)  &&  any(observe_DECODE.BEST.n_trials_per_bin(:)>=Cossfolds)
              
        end
        
    end

%%------------------------Edit:channels------------------------------------
    function channels_edit(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        
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
    end

%%-------------------------------across classes----------------------------
    function eq_trials_acrclas_radio(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=1;
        Docode_do_mvpa.manfloor_radio.Value=0;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'on';
        Docode_do_mvpa.manfloor_edit.Enable = 'off';
    end

%%-------------------------across bestsets---------------------------------
    function eq_trials_acrbest_checkbox(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        
    end

%%------------------------Manual Floor-------------------------------------
    function manfloor_radio(~,~)
        if isempty(observe_DECODE.BEST) || isempty(observe_DECODE.ALLBEST)
            observe_DECODE.Count_currentbest = 1;
            return;
        end
        Docode_do_mvpa.eq_trials_acrclas_radio.Value=0;
        Docode_do_mvpa.manfloor_radio.Value=1;
        Docode_do_mvpa.eq_trials_acrbest_checkbox.Enable = 'off';
        Docode_do_mvpa.manfloor_edit.Enable = 'on';
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
                    ' ',
                    'Please select BESTsets that match in terms of bins and channels!',
                    'You can:',
                    '1: Select the indicies of the BESTsets that match in terms of bins and channels in the "From BESTset Menu" option'};
                Docode_do_mvpa.table_bins.Data = msgboxText;
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
                Docode_do_mvpa.table_bins.Enable = 'off';
                Docode_do_mvpa.mvpa_cancel.Enable = 'off';
                Docode_do_mvpa.mvpa_ops.Enable = 'off';
                Docode_do_mvpa.mvpa_run.Enable = 'off';
                Docode_do_mvpa.foldsnum.Enable = 'off';
            else
                %%No of blocks
                nBlock = str2num(Docode_do_mvpa.foldsnum.String);
                if isempty(nBlock) || numel(nBlock)~=1 || any(nBlock(:)<=0)
                    nBlock=3;
                    Docode_do_mvpa.foldsnum.String = '3';
                end
                
                decodeTrials = str2num(Docode_do_mvpa.selclass_custom_defined.String);
                if isempty(decodeTrials) || any(decodeTrials(:)>observe_DECODE.BEST.nbin)
                    decodeTrials=1:observe_DECODE.BEST.nbin;
                    ClassArray = vect2colon(decodeTrials,'Sort', 'on');
                    ClassArray = erase(ClassArray,{'[',']'});
                    Docode_do_mvpa.selclass_custom_defined.String = ClassArray;
                end
                Data = updatetable(observe_DECODE.ALLBEST(BESTArray),decodeTrials,1,nBlock);
                Docode_do_mvpa.table_bins.Data = Data;
                Docode_do_mvpa.table_bins.ColumnWidth ={50,50,70,50,60};
            end
            
        end
    end
end





function tmpdata = updatetable(ALLBEST,decodeTrials,trialsbymethod,nBlock)
tmpdata = [];
%%trialsbymethod-1.SVM
if trialsbymethod == 1 %svm
    rowInd = 0;
    for f = 1:numel(ALLBEST)
        nbin= ALLBEST(f).nbin;
        for b = 1:nbin
            rowInd = rowInd +1;
            bestfils{rowInd} = ALLBEST(f).bestname;
            classid{rowInd} = num2str(b);
            try claslabel{rowInd} = ALLBEST(f).bindesc{b};catch claslabel{rowInd} = 'undefined'; end
            try trialnum{rowInd} = num2str(ALLBEST(f).n_trials_per_bin(b));catch trialnum{rowInd} =[]; end
            % N_trial_per_bin_per_bock analysis
            if ismember(b,decodeTrials)
                nPerBinBlock = floor(ALLBEST(f).n_trials_per_bin/nBlock); %subject's n_trial_per_bin
                nPerBin{rowInd} = num2str(nPerBinBlock(b));
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
        for b = 1:nbin
            rowInd = rowInd +1;
            bestfils{rowInd} = ALLBEST(f).bestname;
            classid{rowInd} = b;
            try claslabel{rowInd} = ALLBEST(f).bindesc{b};catch claslabel{rowInd} = 'undefined'; end
            if ismember(b,decodeTrials)
                nPerBinBlock = ALLBEST(f).n_trials_per_bin; %subject's n_trial_per_bin
                nPerBin{rowInd} = num2str(nPerBinBlock(b));
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