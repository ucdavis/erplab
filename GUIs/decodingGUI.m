% decodingGUI
% Decoding options dialog for ERPLAB Classic, launched from pop_decoding.
%
% NOTE: This file was migrated from MATLAB App Designer (.mlapp) format to a
% plain .m classdef file to allow version control and code editing. The
% original decodingGUI.mlapp has been archived outside the ERPLAB directory.
% Any future edits should be made here, not in the .mlapp file.
%
% Migrated to .m: September 2026 by Kurt Winsler

classdef decodingGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        HelpButton                      matlab.ui.control.Button
        DecodingAlgorithmOptionsPanel   matlab.ui.container.Panel
        CodingSVMOnlyButtonGroup        matlab.ui.container.ButtonGroup
        OnevsOneButton                  matlab.ui.control.RadioButton
        OnevsAllButton                  matlab.ui.control.RadioButton
        MethodButtonGroup               matlab.ui.container.ButtonGroup
        LDA_regularization_edit         matlab.ui.control.EditField
        SVM_regularization_edit         matlab.ui.control.EditField
        LDAButton                       matlab.ui.control.RadioButton
        RegularizationLabel             matlab.ui.control.Label
        AlgorithmLabel                  matlab.ui.control.Label
        CrossnobisButton                matlab.ui.control.RadioButton
        SVMButton                       matlab.ui.control.RadioButton
        Label_BG2                       matlab.ui.control.Label
        loadBESTRadioGroup              matlab.ui.container.ButtonGroup
        bestmenu                        matlab.ui.control.EditField
        FromBESTsetMenuButton           matlab.ui.control.RadioButton
        CurrentBESTsetButton            matlab.ui.control.RadioButton
        ParallelizationButtonGroup      matlab.ui.container.ButtonGroup
        ParText                         matlab.ui.control.Label
        NoButton                        matlab.ui.control.RadioButton
        YesButton                       matlab.ui.control.RadioButton
        StartDecodingButton             matlab.ui.control.Button
        TimeParametersPanel             matlab.ui.container.Panel
        SubsamplePanel                  matlab.ui.container.Panel
        EffectiveSamplingRateHzEditField  matlab.ui.control.NumericEditField
        EffectiveSamplingRateHzEditFieldLabel  matlab.ui.control.Label
        TPspinner                       matlab.ui.control.Spinner
        DecodeeveryTmsLabel             matlab.ui.control.Label
        TimePoint0msisalwaysincludedLabel  matlab.ui.control.Label
        DownsampleOptionalCheckBox      matlab.ui.control.CheckBox
        DecodingTimeRangeButtonGroup    matlab.ui.container.ButtonGroup
        minmaxinmsLabel                 matlab.ui.control.Label
        EpochRange                      matlab.ui.control.EditField
        PostButton                      matlab.ui.control.RadioButton
        PreButton                       matlab.ui.control.RadioButton
        CustomButton                    matlab.ui.control.RadioButton
        AllButton                       matlab.ui.control.RadioButton
        SelectTimePointstoDecodeLabel   matlab.ui.control.Label
        DecodingParametersPanel         matlab.ui.container.Panel
        TemporalgeneralizationmatrixButtonGroup  matlab.ui.container.ButtonGroup
        OffTGM                          matlab.ui.control.RadioButton
        OnTGM                           matlab.ui.control.RadioButton
        NormalizationButtonGroup        matlab.ui.container.ButtonGroup
        OffButton                       matlab.ui.control.RadioButton
        OnButton                        matlab.ui.control.RadioButton
        MetricButtonGroup               matlab.ui.container.ButtonGroup
        AUCButton_3                     matlab.ui.control.RadioButton
        AUCButton_2                     matlab.ui.control.RadioButton
        ACCButton_2                     matlab.ui.control.RadioButton
        TrialsAVGsButtonGroup           matlab.ui.container.ButtonGroup
        TrialsButtonGroup               matlab.ui.container.ButtonGroup
        FloorValueEditField             matlab.ui.control.NumericEditField
        AcrossBESTsetsCheckBox          matlab.ui.control.CheckBox
        CommonFloorButton               matlab.ui.control.RadioButton
        AcrossClassesButton             matlab.ui.control.RadioButton
        MaxTrialsEqualAVGsButton        matlab.ui.control.RadioButton
        EqualTrialsMaxAVGsButton        matlab.ui.control.RadioButton
        EqualTrialsEqualAVGsButton      matlab.ui.control.RadioButton
        SelectClassesGroup              matlab.ui.container.ButtonGroup
        BrowseButton_2                  matlab.ui.control.Button
        ClassIDEditField                matlab.ui.control.EditField
        ClassIDEditFieldLabel           matlab.ui.control.Label
        CustomButton_2                  matlab.ui.control.RadioButton
        AllButton_2                     matlab.ui.control.RadioButton
        IterationsEditField             matlab.ui.control.NumericEditField
        IterationsEditFieldLabel        matlab.ui.control.Label
        BrowseButton                    matlab.ui.control.Button
        NumberofClassesBinsEditField    matlab.ui.control.NumericEditField
        NumberofClassesBinsEditFieldLabel  matlab.ui.control.Label
        ChanceEditField                 matlab.ui.control.NumericEditField
        ChanceEditFieldLabel            matlab.ui.control.Label
        ChannelsEditField               matlab.ui.control.EditField
        ChannelsEditFieldLabel          matlab.ui.control.Label
        CrossValidationBlocksEditField  matlab.ui.control.NumericEditField
        CrossValidationBlocksEditFieldLabel  matlab.ui.control.Label
        UITable                         matlab.ui.control.Table
    end


    properties (Access = public)
        ALLBEST % Description
        FinishButton
        ChannelsSelected
        decoding_times_index % Description
        BEST_working % Description
        output % Description
        ALLBEST_reset
        indexBEST
        subfoldmethods % Description
    end

    properties (Access = private)
        labeldata % Description
        resample_limit % Description
        epoch_window % Description
        def % Description
        cbesti
        Decode_every_Npoint % Description
        validfloor % Description
        trialsbymethod % Description
    end

    methods (Access = private)

        function ReIndexTime(app, event, cond)
            %routine everytime Decoding Time Period changes

            %obtain timesample value
            value = app.TPspinner.Value;
            %check value if valid from standard
            times = app.ALLBEST(1).times;

            % change "EFFECTIVE SAMPLING RATE" window from standard
            BEST = app.ALLBEST(1);
            npnts_old = BEST.pnts;
            fs = BEST.srate;
            samps = 1/fs; %granularity of data sample in ms
            %epochtime = (samps*npnts_old) * 1000 ; %ms


            %Make sure resampling includes 0 tp
            %find time zero
            tm_zero = find(times==0);
            value_in_samples = round(value/(samps*1000));

            app.Decode_every_Npoint = value_in_samples;

            %start find indexes forward and backward to zero

            if strcmpi(cond,'Pre')
                %tm_zero_to_end = (tm_zero:value_in_samples:length(times));
                tm_zero_to_begin= (tm_zero:-value_in_samples:1);
                decoding_times_index = sort(unique_bc2([tm_zero_to_begin]));
                app.decoding_times_index = decoding_times_index; %save to app

                %change epoch decoding window
                new_window = [times(decoding_times_index(1)) times(decoding_times_index(end))];
                edit_time_range = sprintf('%.2f %.2f', new_window(1), new_window(2));
                app.epoch_window = [new_window(1) new_window(2)];

                %must edit the vars epoch_range uses to make sure user can't change
                %epoch outside of new resampling limints
                app.BEST_working.xmin = new_window(1)/1000; %convert ms to s
                app.BEST_working.xmax = new_window(2)/1000;
                %app.BEST_working.srate = new_FS;
                app.BEST_working.pnts = length(decoding_times_index);
                app.BEST_working.times = times(decoding_times_index);
                app.EpochRange.Value = edit_time_range;
                % EpochRangeValueChanged(app,event);


            elseif strcmpi(cond,'Post')
                tm_zero_to_end = (tm_zero:value_in_samples:length(times));
                %tm_zero_to_begin= (tm_zero-value_in_samples:-value_in_samples:1);
                decoding_times_index = sort(unique_bc2([tm_zero_to_end]));
                app.decoding_times_index = decoding_times_index; %save to app

                %change epoch decoding window
                new_window = [times(decoding_times_index(1)) times(decoding_times_index(end))];
                edit_time_range = sprintf('%.2f %.2f', new_window(1), new_window(2));
                app.epoch_window = [new_window(1) new_window(2)];

                %must edit the vars epoch_range uses to make sure user can't change
                %epoch outside of new resampling limints
                app.BEST_working.xmin = new_window(1)/1000;%convert ms to s
                app.BEST_working.xmax = new_window(2)/1000;
                %app.BEST_working.srate = new_FS;
                app.BEST_working.pnts = length(decoding_times_index);
                app.BEST_working.times = times(decoding_times_index);
                app.EpochRange.Value = edit_time_range;
                %EpochRangeValueChanged(app,event);

            elseif strcmpi(cond, 'All' )
                tm_zero_to_end = (tm_zero:value_in_samples:length(times));
                tm_zero_to_begin= (tm_zero:-value_in_samples:1);
                decoding_times_index = sort(unique_bc2([tm_zero_to_begin tm_zero_to_end]));
                app.decoding_times_index = decoding_times_index; %save to app

                %change epoch decoding window
                new_window = [times(decoding_times_index(1)) times(decoding_times_index(end))];
                edit_time_range = sprintf('%.2f %.2f', new_window(1), new_window(2));
                app.epoch_window = [new_window(1) new_window(2)];

                %must edit the vars epoch_range uses to make sure user can't change
                %epoch outside of new resampling limints
                app.BEST_working.xmin = new_window(1)/1000;%convert ms to s
                app.BEST_working.xmax = new_window(2)/1000;
                %app.BEST_working.srate = new_FS;
                app.BEST_working.pnts = length(decoding_times_index);
                app.BEST_working.times = times(decoding_times_index);
                app.EpochRange.Value = edit_time_range;

                %EpochRangeValueChanged(app,event);
            elseif strcmpi(cond,'Custom')
                % must reset the available time as if original values
                % existed
                tm_zero_to_end = (tm_zero:value_in_samples:length(times));
                tm_zero_to_begin= (tm_zero:-value_in_samples:1);
                decoding_times_index = sort(unique_bc2([tm_zero_to_begin tm_zero_to_end]));
                app.decoding_times_index = decoding_times_index; %save to app

                new_window = [times(decoding_times_index(1)) times(decoding_times_index(end))];
                app.epoch_window = [new_window(1) new_window(2)];

                %for custom, must reset to original values/'all'
                app.BEST_working.xmin = new_window(1)/1000; %convert ms to s
                app.BEST_working.xmax = new_window(2)/1000;
                %app.BEST_working.srate = new_FS;
                app.BEST_working.pnts = length(decoding_times_index);
                app.BEST_working.times = times(decoding_times_index);

                %refresh epoch time
                app.EpochRange.Value = 'Input Custom Range';
            end
        end

        function setall(app)

            ALLBEST = app.ALLBEST;

            %load defaults
            defs = app.def;
            %def{1} set from prior logic
            %def{2} set from prior logic
            chanArray = defs{3};
            %file_out = defs{3};
            iter = defs{4};
            nBlock = defs{5};
            epoch_select = defs{6};
            decodeTimes = defs{7}; %epoch times in s
            Decode_every_Npoint = defs{8}; % must obtain value
            equalize_trials = defs{9};
            floorvalue = defs{10};
            selected_classifier = defs{11};
            SVMcoding = defs{12};
            % file_output = defs{12};
            %  file_path = defs{13};
            par_compute = defs{13};
            decodeClasses = defs{14};
            try regularizationvalues = defs{15};catch regularizationvalues=[]; end %%GH August 2025
            try Outcome_metric = defs{16};catch Outcome_metric=1; end %%GH August 2025 ACC
            if ~isnumeric(Outcome_metric) || numel(Outcome_metric)~=1 || any(Outcome_metric(:)>2)
                Outcome_metric=1;
            end

            try Normalization_par = defs{17}; catch  Normalization_par=0; end
            if ~isnumeric(Normalization_par) || numel(Normalization_par)~=1 ||  (Normalization_par~=0 && Normalization_par~=1)
                Normalization_par=0;
            end

            %%temporal generalization matrix
            try TGM_par = defs{18}; catch  TGM_par=0; end
            if ~isnumeric(TGM_par) || numel(TGM_par)~=1 ||  (TGM_par~=0 && TGM_par~=1)
                TGM_par=0;
            end

            %choose first file as standard
            %create working BEST file for all Sampling/Timing function calls
            BEST1 = ALLBEST(1);
            app.BEST_working = ALLBEST(1); %indexed whenever timing is changed

            if numel(ALLBEST) == 1
                %must convert to string if only 1 BEST file
                filename = convertCharsToStrings(BEST1.bestname);
            else
                filename = {ALLBEST.bestname};
            end


            %Fill parameters
            nbin = BEST1.nbin; %the initial nbin
            app.NumberofClassesBinsEditField.Value = nbin;
            app.ChanceEditField.Value = 1/nbin;
            app.CrossValidationBlocksEditField.Value = nBlock; %default 3
            app.IterationsEditField.Value = iter; %default 100
            app.EqualTrialsMaxAVGsButton.Text={'Equal Trials,','Max AVGs'};
            app.EqualTrialsEqualAVGsButton.Text =  {'Equal Trials,','Equal AVGs'};

            % Channel array
            % Channel array
            if isempty(chanArray)
                chanArray = 1:BEST1.nbchan;
            else
                %test working memory
                nchan = BEST1(1).nbchan;
                if chanArray(end) > nchan
                    listch = {BEST1(1).chanlocs.labels}; %true channels list as labels
                    indxlistch = 1:nchan;  %true array of channel indexs
                    chanArray = indxlistch(indxlistch<=length(listch)); % true array of channel index if less than expected labels
                end
            end
            app.ChannelsSelected = chanArray;
            app.ChannelsEditField.Value = vect2colon(chanArray,'Delimiter','off');


            %set epoch window parameter (for epoch time range)
            tscale(1) = BEST1.times(1);
            tscale(2) = BEST1.times(end);
            app.epoch_window = [tscale(1) tscale(2)];
            event = [];

            %Set timepoints to decode paramter
            % (gets overwritten later if working memory is not empty)
            FS = BEST1.srate;
            set(app.EffectiveSamplingRateHzEditField,'Value', FS);

            time_sample_zero = find(BEST1.times == 0);
            time_sample = BEST1.times(time_sample_zero + 1);
            resample_limit = [time_sample abs(BEST1.times(1))+BEST1.times(end)]; %in ms
            app.resample_limit = resample_limit;

            app.decoding_times_index = 1:(BEST1.pnts);

            set(app.TPspinner,'Editable','on');
            set(app.TPspinner,'Enable','on');
            set(app.TPspinner,'Limits', resample_limit)
            set(app.TPspinner,'Step',resample_limit(1));
            set(app.TPspinner,'Value',time_sample);

            resample_steps = [resample_limit(1):resample_limit(1):resample_limit(1)*50];

            % compare sampling rates of new data vs working memory


            %% Set Resampling/Choosing timepoints to decode
            original_times = BEST1.times;

            tm_zero = find(original_times== 0); %always include tm point = 0ms
            tm_zero_to_begin= (tm_zero:-Decode_every_Npoint:1);
            tm_zero_to_end = (tm_zero:Decode_every_Npoint:length(original_times));
            decoding_times_index = sort(unique_bc2([tm_zero_to_begin tm_zero_to_end]));
            app.decoding_times_index = decoding_times_index;

            npoints = length(decoding_times_index);


            % change "EFFECTIVE SAMPLING RATE" window from standard
            npnts_old = BEST1.pnts;
            fs = BEST1.srate;
            samps = 1/fs; %granularity of data sample in ms
            epochtime = (samps*npnts_old); %s

            value_in_ms = (epochtime/npoints)*1000;
            value_in_ms = closest(resample_steps,value_in_ms);
            new_FS = (npoints/epochtime);

            set(app.EffectiveSamplingRateHzEditField, 'Value', new_FS);
            %update spinner
            set(app.TPspinner,'Value', value_in_ms);
            %TPspinnerValueChanged(app,event);

            app.OnButton.Value = Normalization_par;
            app.OffButton.Value = ~Normalization_par;
            app.OffTGM.Value = ~TGM_par;
            app.OnTGM.Value = TGM_par;
            %time range button group
            if epoch_select == 1
                set(app.AllButton,'Value',1);
                ReIndexTime(app, event, 'All');
                set(app.EpochRange,'BackgroundColor',[0.65 0.65 0.65]);
                set(app.EpochRange,'Editable','off');
            elseif epoch_select == 4
                %ReIndexTime(app, event, 'Custom')
                set(app.CustomButton,'Value',1);
                set(app.EpochRange,'Editable','on');
                set(app.EpochRange,'BackgroundColor',[1 1 1]);

                try
                    new_window(1) = decodeTimes(1) *1000 ; % convert s to ms
                    new_window(2) = decodeTimes(end) *1000; %convert s to ms
                    edit_time_range = sprintf('%.2f %.2f', new_window(1), new_window(2));
                    set(app.EpochRange,'Value',edit_time_range);
                    EpochRangeValueChanged(app, event);
                catch
                    ReIndexTime(app,event,'Custom');
                end

            elseif epoch_select == 2
                %use range xmin to 0
                set(app.PreButton,'Value',1);
                ReIndexTime(app, event, 'Pre');

                set(app.EpochRange,'Editable','off');
                set(app.EpochRange,'BackgroundColor',[0.65 0.65 0.65]);
            elseif epoch_select == 3
                set(app.PostButton,'Value',1);
                ReIndexTime(app, event, 'Post');
                set(app.EpochRange,'Editable','off');
                set(app.EpochRange,'BackgroundColor',[0.65 0.65 0.65]);
            end


            %Labels & Number Trials Per Bin (per file)
            labeldata = {};
            rowInd = 0;
            %rowcolors = zeros(1, numel(ALLBEST)*nbin);
            S1 = uistyle('BackgroundColor', 'white');
            S2 = uistyle('BackgroundColor', [0.8 0.8 0.8]); %light grey
            S3 = uistyle;
            S3.HorizontalAlignment = 'left';

            for f = 1:numel(ALLBEST)

                if f == 1
                    rowcolor  = 0;
                    colswitch = 0;
                end

                for b = 1:nbin
                    rowInd = rowInd +1;
                    labeldata(rowInd,1) = {filename{f}};
                    labeldata(rowInd,2) = num2cell(b);
                    labeldata(rowInd,3) = ALLBEST(f).bindesc(b);
                    labeldata(rowInd,4) = num2cell(ALLBEST(f).n_trials_per_bin(b));
                    % N_trial_per_bin_per_bock analysis
                    nPerBinBlock = floor(ALLBEST(f).n_trials_per_bin/nBlock); %subject's n_trial_per_bin
                    labeldata(rowInd,6) = num2cell(nPerBinBlock(b));
                    labeldata(rowInd,5) = num2cell(nBlock);
                    %hightlight per file
                    app.UITable.Data = labeldata;

                    if rowcolor == 0
                        addStyle(app.UITable,S1,'row', rowInd);
                    else
                        addStyle(app.UITable,S2,'row', rowInd);
                    end
                    if b == nbin
                        if colswitch == 0
                            rowcolor = 1;
                            colswitch = 1;
                        else
                            rowcolor = 0;
                            colswitch = 0;
                        end
                    end
                end

            end



            % styling gui: left align "trials" columns
            addStyle(app.UITable,S3,'column',[1 2 3 4 5 6]);
            %unbold table
            S4 = uistyle('FontWeight','normal');
            addStyle(app.UITable,S4);

            %save in app (always configued first with 5 columns!)
            app.labeldata = labeldata;
            set(app.TrialsAVGsButtonGroup,'Enable','on');%%GH Sep 2025
            if selected_classifier == 1 %svm
                app.TemporalgeneralizationmatrixButtonGroup.Enable = 'on';
                app.NormalizationButtonGroup.Enable = 'on';
                set(app.SVMButton,'Value',1);
                set(app.CodingSVMOnlyButtonGroup,'Enable','on');
                set(app.CrossValidationBlocksEditField,'Enable','on');
                app.trialsbymethod = 1; %equalize trials for N(ERP) column
                %%--------GH August 20 2025--------------------------------
                set(app.SVM_regularization_edit,'Enable','on');
                set(app.LDA_regularization_edit,'Enable','off');
                %%---------------------------------------------------------

                lab_text = ['Common Floor is applied to the number of trials per ERP, and must not be greater ' ...
                    'than the amount of trials per class divided by cross-validation blocks.'];
                % set(app.Label,'Text',lab_text);
                app.CommonFloorButton.Tooltip = lab_text;%%GH August 20 2025

                if isempty(regularizationvalues) || numel(regularizationvalues)~=1 || any(regularizationvalues<=0)
                    % msgboxText =  'The regularization parameter for SVM should be a  positive scalar. The default one of 1 will be used.';
                    % title = 'ERPLAB: ERP decoding GUI input';
                    % errorfound(msgboxText, title);
                    app.SVM_regularization_edit.Value = '1';
                else
                    app.SVM_regularization_edit.Value = num2str(regularizationvalues);
                end

            elseif selected_classifier == 2 %LDA  GH August 20 2025
                app.TemporalgeneralizationmatrixButtonGroup.Enable = 'on';
                app.NormalizationButtonGroup.Enable = 'on';
                set(app.LDAButton,'Value',1);
                set(app.CodingSVMOnlyButtonGroup,'Enable','off');
                set(app.CrossValidationBlocksEditField,'Enable','on');
                app.trialsbymethod = 2; %equalize trials for N(ERP) column
                %%--------GH August 20 2025--------------------------------
                set(app.SVM_regularization_edit,'Enable','off');
                set(app.LDA_regularization_edit,'Enable','on');
                %%---------------------------------------------------------

                lab_text = ['Common Floor is applied to the number of trials per ERP, and must not be greater ' ...
                    'than the amount of trials per class divided by cross-validation blocks.'];
                % set(app.Label,'Text',lab_text);
                app.CommonFloorButton.Tooltip = lab_text;%%GH August 20 2025
                if isempty(regularizationvalues) || numel(regularizationvalues)~=1 || any(regularizationvalues<0) || any(regularizationvalues>1)
                    % msgboxText =  'The regularization parameter for LDA should be a  positive scalar and between 0 and 1. The default one of 0 will be used.';
                    % title = 'ERPLAB: ERP decoding GUI input';
                    % errorfound(msgboxText, title);
                    app.LDA_regularization_edit.Value = '0';
                else
                    app.LDA_regularization_edit.Value = num2str(regularizationvalues);
                end

            elseif selected_classifier == 3 %crossnobis
                app.TemporalgeneralizationmatrixButtonGroup.Enable = 'off';
                app.NormalizationButtonGroup.Enable = 'off';
                set(app.TrialsAVGsButtonGroup,'Enable','off');%%GH Sep 2025
                set(app.CrossnobisButton,'Value',1);
                set(app.CodingSVMOnlyButtonGroup,'Enable','off');
                set(app.CrossValidationBlocksEditField,'Enable','off');
                app.trialsbymethod = 3; %equalize trials for N(Trials) column
                %%--------GH August 20 2025--------------------------------
                set(app.SVM_regularization_edit,'Enable','off');
                set(app.LDA_regularization_edit,'Enable','off');
                %%---------------------------------------------------------
                lab_text = ['Common Floor is applied to the number of trials in each class, and must not be greater ' ...
                    'than the actual amount of trials per class.'];
                % set(app.Label,'Text',lab_text);
                app.CommonFloorButton.Tooltip = lab_text;%%GH August 20 2025
                app.EqualTrialsMaxAVGsButton.Enable = 'off';
                app.MetricButtonGroup.Enable = 'off';
                equalize_trials = 7; %%GH Sep 2025
            end

            %set classes field

            if isempty(decodeClasses)
                decodeClasses = 1:numel(BEST1.binwise_data);
                set(app.AllButton_2,'Value',1);
                set(app.ClassIDEditField,'Value',num2str(mat2colon(decodeClasses,'Delimiter','off')));
                set(app.ClassIDEditField,'Editable','Off');
                set(app.BrowseButton_2,'Enable','Off');
            else
                if  any(decodeClasses>numel(BEST1.binwise_data))%%GH September 2025
                    decodeClasses = [1:numel(BEST1.binwise_data)];
                end
                set(app.CustomButton_2,'Value',1);
                set(app.ClassIDEditField,'Value',num2str(mat2colon(decodeClasses,'Delimiter','off')));
                set(app.ClassIDEditField,'Editable','On');
                set(app.BrowseButton_2,'Enable','On');
            end


            %equalizetrials
            if equalize_trials<6
                set(app.TrialsButtonGroup,'Enable','on');
                if  selected_classifier==3
                    set(app.MetricButtonGroup,'Enable','off');
                end
                app.TrialsAVGsButtonGroup.Buttons(1).Value=1;
                if Outcome_metric==1
                    app.ACCButton_2.Value=1;
                else
                    app.AUCButton_2.Value=1;
                end

            end
            if equalize_trials == 1 %Equal Trials, Max AVGs:across Bins
                set(app.TrialsButtonGroup,'Enable','on');
                % % set(app.EqualizeTrialsCheckBox,'Value',1);
                set(app.AcrossClassesButton,'Value',1);
                set(app.AcrossBESTsetsCheckBox,'Value',0);
                set(app.FloorValueEditField,'Enable','off');
                set(app.AcrossBESTsetsCheckBox,'Value',0);
                set(app.AcrossBESTsetsCheckBox,'Enable','off');
                %do not equalize
                resetTrials(app)
                if selected_classifier==3
                    set(app.MetricButtonGroup,'Enable','off');
                end
                app.TrialsAVGsButtonGroup.Buttons(2).Value=1;

                app.AUCButton_2.Value=1;
                app.ACCButton_2.Enable = 'on';
                resetequatedtrials(app);
            elseif equalize_trials == 2 %Equal Trials, Max AVGs:across BESTsets
                set(app.TrialsButtonGroup,'Enable','on');
                % set(app.EqualizeTrialsCheckBox,'Value',1);
                set(app.AcrossClassesButton,'Value',1);

                if numel(app.indexBEST) == 1
                    %if only one BESTset
                    set(app.AcrossBESTsetsCheckBox,'Value',0);
                    set(app.AcrossBESTsetsCheckBox,'Enable','off');
                    set(app.FloorValueEditField,'Enable','off');
                    resetequatedtrials(app);
                else
                    set(app.AcrossBESTsetsCheckBox,'Value',1);
                    AcrossBESTsetsCheckBoxValueChanged(app, event);
                    set(app.FloorValueEditField,'Enable','off');
                end

            elseif equalize_trials == 4 %Equal Trials, Equal AVGs:across Bins
                set(app.TrialsButtonGroup,'Enable','on');
                % % set(app.EqualizeTrialsCheckBox,'Value',1);
                set(app.AcrossClassesButton,'Value',1);
                set(app.AcrossBESTsetsCheckBox,'Value',0);
                set(app.FloorValueEditField,'Enable','off');
                set(app.AcrossBESTsetsCheckBox,'Value',0);
                set(app.AcrossBESTsetsCheckBox,'Enable','off');
                AcrossBinsCheckBoxValueChanged(app, event);

            elseif equalize_trials == 5 %Equal Trials, Equal AVGs:across BESTsets
                set(app.TrialsButtonGroup,'Enable','on');
                % set(app.EqualizeTrialsCheckBox,'Value',1);
                set(app.AcrossClassesButton,'Value',1);

                if numel(app.indexBEST) == 1
                    %if only one BESTset
                    set(app.AcrossBESTsetsCheckBox,'Value',0);
                    set(app.AcrossBESTsetsCheckBox,'Enable','off');
                    set(app.FloorValueEditField,'Enable','off');
                    AcrossBinsCheckBoxValueChanged(app, event);
                else
                    set(app.AcrossBESTsetsCheckBox,'Value',1);
                    AcrossBESTsetsCheckBoxValueChanged(app, event);
                    set(app.FloorValueEditField,'Enable','off');
                end

            elseif equalize_trials == 6%%Equal Trials, Equal AVGs:common Floor
                set(app.TrialsButtonGroup,'Enable','on');
                % set(app.EqualizeTrialsCheckBox,'Value',1);
                set(app.CommonFloorButton,'Value',1);
                set(app.AcrossBESTsetsCheckBox,'Value',0);
                % AcrossBESTsetsCheckBoxValueChanged(app,event);
                set(app.FloorValueEditField,'Enable','on');
                if isempty(floorvalue)
                    set(app.FloorValueEditField,'Value',1);
                else
                    set(app.FloorValueEditField,'Value',floorvalue);
                end
                app.validfloor = 0;
                set(app.AcrossBESTsetsCheckBox,'Value',0);
                set(app.AcrossBESTsetsCheckBox,'Enable','off');
                FloorValueEditFieldValueChanged(app, event);
                % elseif equalize_trials == 7 %%Equal Trials, Max AVGs
                %     %do not equalize
                %     resetTrials(app)
                %     set(app.TrialsButtonGroup,'Enable','off')
                %     set(app.TrialsButtonGroup,'Enable','off');
                %     if selected_classifier==3
                %         set(app.MetricButtonGroup,'Enable','off');
                %     end
                %     app.TrialsAVGsButtonGroup.Buttons(2).Value=1;
                %
                %     app.AUCButton_2.Value=1;
                %     app.ACCButton_2.Enable = 'on';
                %     resetequatedtrials(app);
            else %%Max Trials, Euqal AVGs

                app.TrialsAVGsButtonGroup.Buttons(3).Value=1;

                set(app.TrialsButtonGroup,'Enable','off');
                set(app.MetricButtonGroup,'Enable','on');
                app.AUCButton_2.Value=1;
                app.ACCButton_2.Enable = 'off';
                if   selected_classifier==3
                    set(app.MetricButtonGroup,'Enable','off');
                end
                resetTrials(app);
            end
            app.MaxTrialsEqualAVGsButton.Enable = 'on';
            if  app.EqualTrialsMaxAVGsButton.Value==1%%GH Apr 2026

                SelectedObject_Text = 'Equal Trials, Max AVGs';
            elseif app.EqualTrialsEqualAVGsButton.Value==1
                SelectedObject_Text = 'Equal Trials, Equal AVGs';
            else
                SelectedObject_Text ='Max Trials, Equal AVGs';
            end
            app.subfoldmethods =SelectedObject_Text;
            %only for SVMs but is set in any case since algorithm ignores
            %this if set to use crossnobis
            if SVMcoding ==1
                set(app.OnevsOneButton,'Value',1);
            elseif SVMcoding == 2
                set(app.OnevsAllButton,'Value',1);
            end

            if par_compute == 0
                set(app.YesButton,'Value',0);
            else
                set(app.YesButton,'Value',1);
            end

            %Make GUI options available if previously closed
            set(app.DecodingParametersPanel,'Enable','on');
            set(app.DecodingAlgorithmOptionsPanel,'Enable','on');
            set(app.TimeParametersPanel,'Enable','on');
            set(app.ParallelizationButtonGroup,'Enable','on');

            if Decode_every_Npoint == 1
                set(app.SubsamplePanel,'Enable','off')
                set(app.DownsampleOptionalCheckBox,'Value',0);
            else
                set(app.SubsamplePanel,'Enable','on')
                set(app.DownsampleOptionalCheckBox,'Value',1);
            end


            % finally, redraw tables to align with classes field
            % needs to happen only after equalize trials
            redrawClasses(app, decodeClasses);

            lab_text = ['By default, the regularization parameter in SVM is 1. This parameter must be a positive number.'];
            % set(app.Label,'Text',lab_text);
            app.SVMButton.Tooltip = lab_text;%%GH August 20 2025

            lab_text = ['By default, the regularization parameter in LDA is 0 which means there is no regularization.This parameter should be between 0 and 1.'];
            % set(app.Label,'Text',lab_text);
            app.LDAButton.Tooltip = lab_text;%%GH August 20 2025

            app.EqualTrialsMaxAVGsButton.Tooltip = 'Highly recommended';
            app.EqualTrialsEqualAVGsButton.Tooltip = 'Recommended';
            app.MaxTrialsEqualAVGsButton.Tooltip = 'Not recommended';
            return
        end



        function setoff(app,issue)
            %in the case the user loads incompatilbe BESTsets

            if issue == 1
                % currently loaded BESTsets do not agree with each other in
                % in terms of bins and/or channels
                msgboxText = {'Welcome to the ERPLAB decoding GUI',
                    'ERPLAB detected that the currently loaded BESTsets as specified in the BESTset menu',
                    'do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.',
                    ' ',
                    ' ',
                    'Please use BESTsets that match in terms of bins and channels!',
                    'You can:',
                    '1: Select the indicies of the BESTsets that match in terms of bins and channels in the "From BESTset Menu" option',
                    '2: Exit this GUI, load BESTsets into the BESTset menu, and restart GUI.'};
            elseif issue == 2
                % Chosen BESTsets do not agree with each other in terms of
                % bins and/or channels.

                if isempty(app.ALLBEST_reset)

                    msgboxText = {'Welcome to the ERPLAB decoding GUI',
                        'ERPLAB detected that the selected BESTsets  ',
                        'do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.',
                        ' ',
                        'Please select BESTsets that match in terms of bins and channels!',
                        'You can: ',
                        '1: Exit this GUI, load BESTsets into the BESTset menu, and restart GUI.'};
                else

                    msgboxText = {'Welcome to the ERPLAB decoding GUI',
                        'ERPLAB detected that the selected BESTsets  ',
                        'do not contain the same number of bins and/or channels, or do not contain at least two classes/bins.',
                        ' ',
                        'Please select BESTsets that match in terms of bins and channels!',
                        'You can: ',
                        '1: Input the indicies of the BESTsets that mach in terms of bins/channels into "From BESTset Menu" option in GUI.',
                        '2: Exit this GUI, load BESTsets into the BESTset menu, and restart GUI.'};

                end
            elseif issue == 3
                % No currently loaded BESTsets

                msgboxText = {'Welcome to the ERPLAB decoding GUI',
                    'ERPLAB did not detect any BESTsets',
                    'Please select BESTsets that match in terms of bins and channels!',
                    ' ',
                    ' ',
                    'You can: ',
                    '1: Exit this GUI, load BESTsets into the BESTset menu, and restart GUI.'};
            end

            app.UITable.Data =msgboxText;
            S1 = uistyle('BackgroundColor', 'white');
            S2 = uistyle('FontWeight','bold');
            addStyle(app.UITable,S2);
            % set(app.LoadBESTWizard,'Enable','on');

            app.ALLBEST= [];
            app.indexBEST = 0;
            addStyle(app.UITable,S1); %add to table
            addStyle(app.UITable,S2);
            set(app.DecodingParametersPanel,'Enable','off');
            set(app.DecodingAlgorithmOptionsPanel,'Enable','off');
            set(app.TimeParametersPanel,'Enable','off');
            set(app.ParallelizationButtonGroup,'Enable','off');

        end



        function resetTrials(app)

            %reset trials
            %redo original N(per ERP) column
            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);

            nbin = ALLBEST(1).nbin; %the same across all files
            nBlock = app.CrossValidationBlocksEditField.Value;

            %grab original data
            tmpdata = app.labeldata;


            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];
            nblockcells = [];
            ntrialscells = [];
            decodeClasses = str2num(app.ClassIDEditField.Value);

            if app.trialsbymethod == 1 || app.trialsbymethod == 2 %svm or LDA
                rowInd = 0;
                nPerBin = app.labeldata(:,4);
                for f = 1:numel(ALLBEST)

                    for b = 1:nbin

                        rowInd = rowInd +1;

                        % N_trial_per_bin_per_bock analysis
                        if ismember(b,decodeClasses)
                            nPerBinBlock = floor(ALLBEST(f).n_trials_per_bin/nBlock); %subject's n_trial_per_bin
                            nPerBin{rowInd} = (nPerBinBlock(b));
                            blackcells(rowInd) = rowInd;
                            nblockcells{rowInd} = nBlock;
                            ntrialscells{rowInd} = ALLBEST(f).n_trials_per_bin(b);
                        else
                            nPerBin{rowInd} = 'NOT USED';
                            redcells(rowInd) = rowInd;
                            nblockcells{rowInd} = 'NOT USED';
                            ntrialscells{rowInd} = 'NOT USED';
                        end

                    end

                end
                tmpdata(:,4) =  ntrialscells;
                tmpdata(:,6) = nPerBin;
                tmpdata(:,5) = nblockcells;

                %    app.UITable.Data = tmpdata; %create 4 column table

            elseif app.trialsbymethod == 3 %crossnobis
                %crossnobis only cares about N(trials)
                rowInd = 0;
                nPerBin = app.labeldata(:,4);

                for f = 1:numel(ALLBEST)

                    for b = 1:nbin

                        rowInd = rowInd +1;


                        if ismember(b,decodeClasses)
                            nPerBinBlock = ALLBEST(f).n_trials_per_bin; %subject's n_trial_per_bin
                            nPerBin{rowInd} = nPerBinBlock(b);
                            blackcells(rowInd) = rowInd;
                        else
                            nPerBin{rowInd} = 'NOT USED';
                            redcells(rowInd) = rowInd;
                        end

                    end

                end

                tmpdata(:,4) = nPerBin;

                tmpdata(:,6) = [];
                tmpdata(:,5) = [];
                %       app.UITable.Data = tmpdata;
            end

            %redraw table
            app.UITable.Data = tmpdata;

            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end
            end
        end



        function redrawClasses(app,decodeClasses)

            %redraw the GUI Table to only the selected classes
            % to decode across

            ALLBEST = app.ALLBEST;
            nbin = ALLBEST(1).nbin; %the original class amount


            if numel(ALLBEST) == 1
                %must convert to string if only 1 BEST file
                filename = convertCharsToStrings(ALLBEST.bestname);
            else
                filename = {ALLBEST.bestname};
            end

            nBlock = app.CrossValidationBlocksEditField.Value;

            %Labels & Number Trials Per Bin (per file)
            % labeldata = app.UITable.Data;

            rowInd = 0;

            S3 = uistyle;
            if numel(decodeClasses) == nbin
                S3.FontColor = 'black';
                S3.FontWeight = 'normal';
            else
                S3.FontColor = 'black';
                S3.FontWeight = 'bold';
            end


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';

            for f = 1:numel(ALLBEST)

                for b = 1:nbin


                    rowInd = rowInd +1;
                    if ismember(b,decodeClasses)
                        useClass = 1;
                        %app.UITable.Data(rowInd,2) = num2cell(b);
                        app.labeldata(rowInd,2) = num2cell(b);
                        % blackcells(rowInd) = rowInd;
                    else
                        useClass = 0;
                        app.labeldata(rowInd,2) = {'NOT USED'};
                        %  redcells(rowInd) = rowInd;
                        % app.UITable.Data(rowInd,2) = {'NOT USED'};
                    end

                    if app.CrossnobisButton.Value == 1
                        tmpdata = app.labeldata;
                        tmpdata(:,[5 6]) = [];
                        app.UITable.Data = tmpdata;

                    else

                        %hightlight per file
                        app.UITable.Data(:,1:3) = app.labeldata(:,1:3);
                    end


                    if useClass == 1
                        addStyle(app.UITable,S3,'cell', [rowInd,2]);
                    else
                        addStyle(app.UITable,S4,'cell', [rowInd,2]);
                    end

                end

            end

            %app.labeldata = app.UITable.Data;


            %change chances and nbins
            app.NumberofClassesBinsEditField.Value = numel(decodeClasses);
            app.ChanceEditField.Value = 1/numel(decodeClasses);


            % update trials equalization parameters based on new classes
            event = [];
            % EqualizeTrialsCheckBoxValueChanged(app,event);

            %equalize across bins across files
            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];
            tmpdata = app.UITable.Data;
            if app.trialsbymethod == 1 || app.trialsbymethod == 2 % svm

                for jjj = 1:size(tmpdata,1)
                    if ischar(tmpdata{jjj,2}) &&  strcmpi(tmpdata{jjj,2},'NOT USED')
                        tmpdata{jjj,5} = 'NOT USED';
                        redcells(jjj) = jjj;
                    else
                        blackcells(jjj) = jjj;
                    end

                end
            elseif app.trialsbymethod == 3 % crossnobis

                for jjj = 1:size(tmpdata,1)
                    if ischar(tmpdata{jjj,2}) &&  strcmpi(tmpdata{jjj,2},'NOT USED')
                        tmpdata{jjj,4} = 'NOT USED';
                        redcells(jjj) = jjj;
                    else
                        blackcells(jjj) = jjj;
                    end
                end
            end

            %redraw table
            app.UITable.Data = tmpdata;
            app.validfloor = 1;
            %color
            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end
            end
        end


        function  resetequatedtrials(app) %%GH August 2025
            %reset trials for Equated-trialsresetequatedtrials(app);
            %redo original N(per ERP) column
            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);

            nbin = ALLBEST(1).nbin; %the same across all files
            nBlock = app.CrossValidationBlocksEditField.Value;

            %grab original data
            tmpdata = app.labeldata;


            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];
            nblockCells = [];
            ntrialscell = [];
            decodeClasses = str2num(app.ClassIDEditField.Value);

            % if app.trialsbymethod == 1 || app.trialsbymethod == 2 %svm or LDA
            rowInd = 0;
            nPerBin = app.labeldata(:,4);
            for f = 1:numel(ALLBEST)

                for b = 1:nbin

                    rowInd = rowInd +1;
                    if ~isempty(decodeClasses)
                        n_trials_per_bin=  ALLBEST(f).n_trials_per_bin;
                        n_trials_per_bin_used = n_trials_per_bin(decodeClasses);
                        n_trials_subfold = floor(min(n_trials_per_bin_used(:))/nBlock);
                    end
                    % N_trial_per_bin_per_bock analysis
                    if ismember(b,decodeClasses)
                        % nPerBinBlock = n_trials_subfold; %subject's n_trial_per_bin
                        nPerBin{rowInd} = n_trials_subfold;%%GH 2025 August
                        blackcells(rowInd) = rowInd;
                        nblockCells{rowInd} = floor(n_trials_per_bin(b)/n_trials_subfold);
                        ntrialscell{rowInd} = n_trials_per_bin(b);
                    else
                        nPerBin{rowInd} = 'NOT USED';
                        redcells(rowInd) = rowInd;
                        nblockCells{rowInd} = 'NOT USED';
                        ntrialscell{rowInd} = 'NOT USED';
                    end
                end

            end
            tmpdata(:,4) =(ntrialscell);
            tmpdata(:,6) = nPerBin;
            tmpdata(:,5) = nblockCells;


            %redraw table
            app.UITable.Data = tmpdata;

            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------across bestsets for equal trials,max AVGs GH Dec. 2025------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function acrossbestEqualMax(app)
            %reset trials for Equated-trialsresetequatedtrials(app);
            %redo original N(per ERP) column
            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);

            nbin = ALLBEST(1).nbin; %the same across all files
            nBlock = app.CrossValidationBlocksEditField.Value;

            %grab original data
            tmpdata = app.labeldata;


            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];
            nblockCells = [];
            ntrialscell = [];
            decodeClasses = str2num(app.ClassIDEditField.Value);
            if isempty(decodeClasses) ||  any(decodeClasses(:)>nbins)%%check the defined classes that will be used for further decoding
                decodeClasses = [1:nbins];
            end
            %%determine the minimal number of trials for each class across
            %%bestsets
            Classes_acrossbest = [];
            for f = 1:numel(ALLBEST)
                n_trials_per_bin=  ALLBEST(f).n_trials_per_bin;
                n_trials_per_bin_used = n_trials_per_bin(decodeClasses);
                Classes_acrossbest = [Classes_acrossbest;n_trials_per_bin_used];
            end
            Classes_acrossbest_min = min(Classes_acrossbest,[],1);



            % if app.trialsbymethod == 1 || app.trialsbymethod == 2 %svm or LDA
            rowInd = 0;
            nPerBin = app.labeldata(:,4);
            for f = 1:numel(ALLBEST)
                count_class_used = 0;
                for b = 1:nbin

                    rowInd = rowInd +1;
                    % if ~isempty(decodeClasses)
                    n_trials_per_bin=  ALLBEST(f).n_trials_per_bin;
                    % n_trials_per_bin_used = n_trials_per_bin(decodeClasses);
                    n_trials_subfold = floor(min(Classes_acrossbest_min(:))/nBlock);
                    % N_trial_per_bin_per_bock analysis
                    if ismember(b,decodeClasses)
                        count_class_used = count_class_used+1;
                        % nPerBinBlock = n_trials_subfold; %subject's n_trial_per_bin
                        nPerBin{rowInd} = n_trials_subfold;%%GH 2025 August
                        blackcells(rowInd) = rowInd;
                        nblockCells{rowInd} = floor(Classes_acrossbest_min(count_class_used)/n_trials_subfold);
                        ntrialscell{rowInd} = n_trials_per_bin(b);
                    else
                        nPerBin{rowInd} = 'NOT USED';
                        redcells(rowInd) = rowInd;
                        nblockCells{rowInd} = 'NOT USED';
                        ntrialscell{rowInd} = 'NOT USED';
                    end
                end

            end
            tmpdata(:,4) =(ntrialscell);
            tmpdata(:,6) = nPerBin;
            tmpdata(:,5) = nblockCells;

            %redraw table
            app.UITable.Data = tmpdata;

            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end
            end

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%--------Floor for equal trials,max AVGs GH Dec. 2025-------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function floorEqualMax(app)
            %reset trials for Equated-trialsresetequatedtrials(app);
            %redo original N(per ERP) column
            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);

            nbin = ALLBEST(1).nbin; %the same across all files
            nBlock = app.CrossValidationBlocksEditField.Value;

            %grab original data
            tmpdata = app.labeldata;


            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];
            nblockCells = [];
            ntrialscell = [];
            decodeClasses = str2num(app.ClassIDEditField.Value);
            if isempty(decodeClasses) ||  any(decodeClasses(:)>nbins)%%check the defined classes that will be used for further decoding
                decodeClasses = [1:nbins];
            end
            %%determine the minimal number of trials for each class
            Classes_acrossbest = [];
            for f = 1:numel(ALLBEST)
                n_trials_per_bin=  ALLBEST(f).n_trials_per_bin;
                n_trials_per_bin_used = n_trials_per_bin(decodeClasses);
                Classes_acrossbest = [Classes_acrossbest;n_trials_per_bin_used];
            end
            Classes_acrossbest_min = min(Classes_acrossbest,[],1);

            n_trials_subfold = floor(min(Classes_acrossbest_min(:))/nBlock);

            Floor_value = app.FloorValueEditField.Value;
            if isempty(Floor_value) || numel(Floor_value)~=1 || any(Floor_value(:)>n_trials_subfold) || any(Floor_value(:)<1)
                msgboxTest = sprintf(['You selected an invalid floor %i. The value exceeds the max the number of trials within cross-validation blocks (SVM) ' ...
                    'or the max number of trials in any class (Crossnobis)'],Floor_value);
                title = 'ERPLAB: Cross-Validation error';
                errorfound(msgboxTest, title);

                Floor_value = n_trials_subfold;
                app.FloorValueEditField.Value = n_trials_subfold;
            end
            % if app.trialsbymethod == 1 || app.trialsbymethod == 2 %svm or LDA
            rowInd = 0;
            nPerBin = app.labeldata(:,4);
            for f = 1:numel(ALLBEST)
                count_class_used = 0;
                for b = 1:nbin

                    rowInd = rowInd +1;
                    % if ~isempty(decodeClasses)
                    n_trials_per_bin=  ALLBEST(f).n_trials_per_bin;
                    % n_trials_per_bin_used = n_trials_per_bin(decodeClasses);

                    % N_trial_per_bin_per_bock analysis
                    if ismember(b,decodeClasses)
                        count_class_used = count_class_used+1;
                        % nPerBinBlock = n_trials_subfold; %subject's n_trial_per_bin
                        nPerBin{rowInd} = Floor_value;%%GH 2025 August
                        blackcells(rowInd) = rowInd;
                        nblockCells{rowInd} = floor(Classes_acrossbest_min(count_class_used)/n_trials_subfold);
                        ntrialscell{rowInd} = n_trials_per_bin(b);
                    else
                        nPerBin{rowInd} = 'NOT USED';
                        redcells(rowInd) = rowInd;
                        nblockCells{rowInd} = 'NOT USED';
                        ntrialscell{rowInd} = 'NOT USED';
                    end
                end

            end
            tmpdata(:,4) =(ntrialscell);
            tmpdata(:,6) = nPerBin;
            tmpdata(:,5) = nblockCells;

            %redraw table
            app.UITable.Data = tmpdata;

            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end
            end

        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)

            %paint GUI
            %painterplabapp(app);
            %inputs
            ALLBEST = varargin{1};
            %filename = (varargin{2}'); %filename
            %filepath = varargin{3}; % list of paths
            def = varargin{2};
            cbesti = varargin{3}';

            %save defaults and currently loaded bestset index
            app.def = def;
            app.cbesti = cbesti;
            app.ALLBEST_reset = ALLBEST; %from GUI input

            if ~isempty(def)
                optioni = def{1}; %1 means from hard drive, 0 means from bestset menu, 2 means current bestset
                bestseti = def{2}; %indices of bestset or filename of list of bestests
            else
                optioni = 1;
                bestseti = 1;
            end

            %figure out a way to load the desired BEST file!
            if isstruct(ALLBEST)
                nsets = numel(ALLBEST);
            else
                nsets = 0;
                indexBEST = 0;
            end

            if nsets > 0 && (optioni == 0 || optioni == 2)
                if optioni == 0 % choose from bestset menu
                    app.FromBESTsetMenuButton.Value = 1;
                    set(app.bestmenu,'Enable','on');
                    %  set(app.LoadBESTWizard,'Enable','off');
                    indexBEST = bestseti;
                    set(app.bestmenu,'Value',num2str(indexBEST));
                else %choose current bestset (option 2)
                    app.CurrentBESTsetButton.Value = 1;
                    set(app.bestmenu,'Enable','off');
                    %  set(app.LoadBESTWizard,'Enable','off');
                    indexBEST = cbesti;
                end

            else % from hard drive
                %                 app.LoadBESTsetsButton.Value = 1;
                set(app.bestmenu,'Enable','off');
                set(app.FromBESTsetMenuButton,'Enable','off');
                set(app.CurrentBESTsetButton,'Enable','off');
                %  set(app.LoadBESTWizard,'Enable','on');

                % make options uneditable if no loaded bestset
                setoff(app,3);

            end


            if unique_bc2(indexBEST >= 1) %set all (if data is loaded )

                chosenBEST = ALLBEST(indexBEST);
                checking = checkmultiBEST(chosenBEST);

                if ~checking

                    setoff(app,1);
                    %
                else
                    checking = checkmultiBEST(chosenBEST);

                    % load into app
                    if ~checking
                        setoff(app,1);
                    else
                        app.ALLBEST = chosenBEST;
                        app.indexBEST = indexBEST;
                    end

                    setall(app);
                end

            end

            %paint GUI
            painterplabapp(app);

            %
            % Name & version
            %
            version = geterplabversion;
            set(app.UIFigure,'Name', ['ERPLAB ' version '   -   DECODING GUI']);




            %to close out gui
            ready = 0;
            if ready == 1
                app.FinishButton = 1;
            end

            %disp('done')


        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)


            BEST1 = app.ALLBEST(1);
            nchan = BEST1(1).nbchan;

            listch = {BEST1(1).chanlocs.labels}; %true channels list as labels
            indxlistch = 1:nchan;  %true array of channel indexs
            indxlistch = indxlistch(indxlistch<=length(listch)); % true array of channel index if less than expected labels
            titlename = 'Select Channel(s)';
            indxlistch_str = arrayfun(@num2str,indxlistch,'UniformOutput',0);

            listch_numbered = strcat(indxlistch_str,' =  ',listch);

            %             if get(hObject, 'Value')
            if ~isempty(listch)
                ch = browsechanbinGUI(listch_numbered, indxlistch, titlename);
                if ~isempty(ch)
                    %set(handles.chwindow, 'String', vect2colon(ch, 'Delimiter', 'off'));
                    app.ChannelsEditField.Value = vect2colon(ch, 'Delimiter','off');
                    %handles.indxlistch = ch;
                    % Update app structure
                    app.ChannelsSelected = ch;
                    %                     guidata(hObject, handles);
                    %                     redraw_outliers(hObject, eventdata, handles);
                    %                     guidata(hObject, handles);

                else
                    disp('User selected Cancel')
                    return
                end
            else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: BrowseChans GUI input';
                errorfound(msgboxText, title);
                return
            end
            %
            %             end




        end

        % Value changed function: EpochRange
        function EpochRangeValueChanged(app, event)
            value = app.EpochRange.Value;
            kktime = 1000; %change from s to ms

            %reset working bestfile
            BEST1 = app.ALLBEST(1);
            orig_times = BEST1.times;
            app.epoch_window = [orig_times(1) orig_times(end)];
            app.BEST_working.xmin = BEST1.xmin;
            app.BEST_working.xmax = BEST1.xmax;
            app.BEST_working.srate = BEST1.srate;
            app.BEST_working.pnts = BEST1.pnts;
            app.BEST_working.times = orig_times;
            fs = BEST1.srate;

            xxlim = str2num(value);
            %xxlim = app.epoch_window;

            if isempty(xxlim) | length(xxlim) <2
                msgboxText =  'You have not specified a time range';
                title = 'ERPLAB: Decoding GUI input';
                errorfound(msgboxText, title);
                %                 set(handles.radiobutton_yauto, 'Value',0)
                %                 drawnow
                return
            end



            if xxlim(1) < round(app.epoch_window(1),2)
                msgboxText = 'You have input an invalid start time; default to earliest start time';
                title = 'ERPLAB: Decoding GUI input';
                errorfound(msgboxText, title);

                % Revert to default time range
                tscale(1) = app.epoch_window(1); %change from s to ms
                %tscale(2) = BEST1.xmax * 1000; %change from s to ms
                edit_time_range = sprintf('%.2f %.2f', tscale(1), xxlim(2));
                app.EpochRange.Value = edit_time_range;
                %                 set(handles.radiobutton_yauto, 'Value',0)
                %
                aux_xxlim(1) = tscale(1);

                %aux_xxlim(1) = round(BEST1.xmin*kktime);
            elseif ~ismember(xxlim(1), round(orig_times,2))
                %check that start time is actually within the new
                %resampling period
                msgboxTest = sprintf('Invalid start time: Not a valid time-sample. Will round to nearest time-sample!');
                title = 'ERPLAB: wrong time-units';
                errorfound(msgboxTest, title);

                %find closest value
                %[~,ind] = min(abs(orig_times-xxlim(1)));
                %value = orig_times(ind);
                [value,ind] = closest(orig_times,xxlim(1));

                %                 set(app.TPspinner,'Value',value);
                %                 app.TPspinner.Value = value;
                tscale(1) = value ;
                tscale(2) = xxlim(2); %change from s to ms
                edit_time_range = sprintf('%.2f %.2f', tscale(1), tscale(2));
                app.EpochRange.Value = edit_time_range;
                app.epoch_window = [tscale(1) tscale(2)];
                aux_xxlim(1) = value;
            else
                aux_xxlim(1) = xxlim(1);
            end

            if xxlim(2)> round(app.epoch_window(end),2)
                msgboxText = 'You have input an invalid end time; default to lateset end time';
                title = 'ERPLAB: Decoding GUI input';
                errorfound(msgboxText, title);
                % Revert to default time range
                %tscale(1) = BEST1(1).xmin * 1000; %change from s to ms
                tscale(2) = app.epoch_window(end); %change from s to ms
                edit_time_range = sprintf('%.2f %.2f', aux_xxlim(1), tscale(2));
                app.EpochRange.Value = edit_time_range;

                aux_xxlim(2)=  tscale(2);

            elseif ~ismember(xxlim(2), round(orig_times,2))
                %check that start time is actually within the new
                %resampling period
                msgboxTest = sprintf('Invalid end time: Not a valid time-sample. Will round!');
                title = 'ERPLAB: wrong time-units';
                errorfound(msgboxTest, title);

                %find closest value
                %[~,ind] = min(abs(orig_times-xxlim(2)));
                %value = orig_times(ind);
                [value,ind] = closest(orig_times,xxlim(2));
                tscale(1) = aux_xxlim(1) ;
                tscale(2) = value ; %change from s to ms
                edit_time_range = sprintf('%.2f %.2f', tscale(1), tscale(2));
                app.EpochRange.Value = edit_time_range;
                app.epoch_window = [tscale(1) tscale(2)];
                aux_xxlim(2) = value;

            else
                aux_xxlim(2) = xxlim(2);
            end


            [xp1, xp2, checkw] = window2sample(BEST1, aux_xxlim(1:2) , fs, 'relaxed');

            if checkw==1
                msgboxText =  'Time window cannot be larger than epoch.';
                title = 'ERPLAB';
                errorfound(msgboxText, title);
                app.EpochRange.Value = 'Input Custom Range';
                %set(handles.radiobutton_yauto, 'Value',0)
                %drawnow
                return
            elseif checkw==2
                msgboxText =  'Too narrow time window (are the start and end times reversed?)';
                title = 'ERPLAB';
                errorfound(msgboxText, title);
                app.EpochRange.Value = 'Input Custom Range';
                %set(handles.radiobutton_yauto, 'Value',0)
                %drawnow
                return
            end

            %apply reindexing of timepoints if custom window
            if app.CustomButton.Value == 1
                %obtain timesample value
                value = app.TPspinner.Value;

                % obtain original sampling rate
                orig_fs = app.ALLBEST(1).srate;
                orig_samps = 1/orig_fs; %granularity of data sample in ms

                %Make sure resampling includes 0 tp
                %find time zero
                tm_zero = find(orig_times==0);
                value_in_samples = floor(value/(orig_samps*1000));
                app.Decode_every_Npoint = value_in_samples;

                %start find indexes forward and backward to timepoints
                %                 tm_end = find(orig_times == aux_xxlim(2));
                %                 tm_begin = find(orig_times == aux_xxlim(1));
                [~,tm_end] = closest(orig_times,aux_xxlim(2));
                [~,tm_begin] = closest(orig_times,aux_xxlim(1));
                tm_zero_to_end = (tm_zero:value_in_samples:tm_end);
                tm_zero_to_begin= (tm_zero:-value_in_samples:tm_begin);
                decoding_times_index = sort(unique_bc2([tm_zero_to_begin tm_zero_to_end])); %includes zero timepoint

                [~,decode_begin] = closest(decoding_times_index,tm_begin);
                [~,decode_end] = closest(decoding_times_index,tm_end);

                %update to user defined times (but also includes 0ms in
                %sampling)
                decoding_times_index = decoding_times_index(decode_begin:decode_end);

                app.decoding_times_index = decoding_times_index; %save to app


                %change epoch decoding window
                new_window = [orig_times(decoding_times_index(1)) orig_times(decoding_times_index(end))];
                edit_time_range = sprintf('%.2f %.2f', new_window(1), new_window(2));
                app.EpochRange.Value = edit_time_range;
                app.epoch_window = new_window;
                %             set(app.AllButton,'Value',1);
                %             EpochRangeValueChanged(app,event);

                %must edit the vars epoch_range uses to make sure user can't change
                %epoch outside of new resampling limints
                app.BEST_working.xmin = new_window(1)/1000;
                app.BEST_working.xmax = new_window(2)/1000;
                %app.BEST_working.srate = new_FS;
                app.BEST_working.pnts = length(decoding_times_index);
                app.BEST_working.times = orig_times(decoding_times_index);
                %set(app.EpochRange,'Value',edit_time_range);
                % print('hi');

            end




        end

        % Callback function
        function AcrossBinsCheckBoxValueChanged(app, event)
            %           value = app.AcrossBinsCheckBox.Value;


            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);

            set(app.FloorValueEditField,'Enable',0);

            tmpdata = app.labeldata;

            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';

            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];

            if app.trialsbymethod == 1 || app.trialsbymethod == 2 %svm
                %equalize across bins within files
                nPerBin = app.labeldata(:,4); %obtain original values
                nBlocks = app.CrossValidationBlocksEditField.Value;

                for s = 1:nsubs


                    subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject

                    %   if app.CustomButton_2.Value == 1
                    decodeClasses = str2num(app.ClassIDEditField.Value);
                    minCnt = min(subj_ntrials(decodeClasses));
                    %  else
                    %      minCnt = min(subj_ntrials);
                    %  end
                    % max # of trials such that # of trials for all bins ...
                    % can be equated within each block
                    nPerBinBlock(s) = floor(minCnt/nBlocks);
                end

                %apply nPerBinBlock to nPerBin values
                indx = 0 ;
                for s = 1:nsubs
                    subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject

                    for b = 1:nbins
                        indx = indx +1;

                        if ismember(b,decodeClasses)
                            nPerBin{indx} = nPerBinBlock(s);
                            ntrailPerbin{indx}  = subj_ntrials(b);
                            blackcells(indx) = indx;
                            nBlockcells{indx} = nBlocks;
                        else
                            nPerBin{indx} = 'NOT USED';
                            redcells(indx) = indx;
                            nBlockcells{indx} = 'NOT USED';
                            ntrailPerbin{indx}  = 'NOT USED';
                        end
                    end
                end

                %replace N(ERP) column
                %tmpdata(:,5) = num2cell(nPerBin);
                tmpdata(:,4) = (ntrailPerbin);
                tmpdata(:,6) = (nPerBin);
                tmpdata(:,5) = (nBlockcells);
            elseif app.trialsbymethod == 3 %crossnobis

                nPerBin = app.labeldata(:,4); %obtain original values
                % nBlocks = app.CrossValidationBlocksEditField.Value;

                for s = 1:nsubs


                    subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject


                    % max # of trials that will eventually be halved in
                    % crossnobis

                    %   if app.CustomButton_2.Value == 1
                    decodeClasses = str2num(app.ClassIDEditField.Value);
                    minCnt = min(subj_ntrials(decodeClasses));
                    %    else
                    %        minCnt = min(subj_ntrials);
                    %    end
                    nPerBinBlock(s) = minCnt;
                end

                %apply nPerBinBlock to nPerBin values
                indx = 0 ;
                for s = 1:nsubs
                    for b = 1:nbins
                        indx = indx +1;

                        if ismember(b,decodeClasses)
                            nPerBin{indx} = nPerBinBlock(s);
                            blackcells(indx) = indx;

                        else
                            nPerBin{indx} = 'NOT USED';
                            redcells(indx) = indx;
                        end
                    end
                end

                %replace N(trial) column
                %tmpdata(:,4) = num2cell(nPerBin);
                tmpdata(:,4) = (nPerBin);
                %delete4th column
                tmpdata(:,6) = [];
                tmpdata(:,5) = [];
            end



            app.labeldata(:,4) = nPerBin;
            %redraw table
            app.UITable.Data = tmpdata;
            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1
                    redcells2(:,2) = 5;
                    % redcells2(:,3) = 6;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 2
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 2
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end


            end


        end

        % Value changed function: CrossValidationBlocksEditField
        function CrossValidationBlocksEditFieldValueChanged(app, event)
            value = app.CrossValidationBlocksEditField.Value;

            if value <= 1
                msgboxTest = sprintf('Cross-Validation Blocks: must be greater than %i block',1);
                title = 'ERPLAB: Cross-Validation error';
                errorfound(msgboxTest, title);
                set(app.CrossValidationBlocksEditField,'Value',3) %default to 3
                return
            end

            app.def{5} = value;

            %%test .Value, not .Text: setall gives the two "Equal Trials" buttons cell-array labels
            if  app.EqualTrialsMaxAVGsButton.Value==1
                selectedButton_subfold = 1;
            elseif app.EqualTrialsEqualAVGsButton.Value==1
                selectedButton_subfold = 2;
            else
                selectedButton_subfold = 3;
            end

            switch selectedButton_subfold

                case 2%'Equal Trials, Equal AVGs'
                    selectedButton12 = app.TrialsButtonGroup.SelectedObject;
                    switch selectedButton12.Text
                        case 'Across Classes'
                            if app.AcrossBESTsetsCheckBox.Value == 1
                                AcrossBESTsetsCheckBoxValueChanged(app,event);
                            else
                                AcrossBinsCheckBoxValueChanged(app,event);
                            end

                        case 'Common Floor'
                            FloorValueEditFieldValueChanged(app,event);
                    end

                case 1%'Equal Trials, Max AVGs'
                    resetequatedtrials(app);
                case 3%'Max Trials, Equal AVGs'
                    resetTrials(app);
            end


        end

        % Value changed function: TPspinner
        function TPspinnerValueChanged(app, event)
            value = app.TPspinner.Value;

            %everytime the TPspinner changes value, we go back to the "ALL"
            % time range, so we need to reset the options accordingly


            %check value if valid from standard
            times = app.ALLBEST(1).times;
            resample_limit = app.resample_limit;

            if ~ismember(value,times)
                msgboxTest = sprintf('Selecting time-points: must be in units of %i ms. Will round!',resample_limit(1));
                title = 'ERPLAB: wrong time-units';
                errorfound(msgboxTest, title);

                %find closest value rounded down
                value = closest(times,xxlim(2));
                %                 tscale(1) = aux_xxlim(1) ;
                %                 tscale(2) = value ; %change from s to ms
                %                 edit_time_range = sprintf('%.2f %.2f', tscale(1), tscale(2));
                %
                %                 [~,ind] = min(abs(times-value));
                %value = times(ind);
                set(app.TPspinner,'Value',value);
                app.TPspinner.Value = value;
            end

            % change "EFFECTIVE SAMPLING RATE" window from standard
            BEST = app.ALLBEST(1);
            npnts_old = BEST.pnts;
            fs = BEST.srate;
            samps = 1/fs; %granularity of data sample in ms
            epochtime = (samps*npnts_old) * 1000 ; %ms
            npnts = round(epochtime/value); %can't have intermediate points
            new_FS = (npnts/epochtime * 1000);

            %save changes
            set(app.EffectiveSamplingRateHzEditField, 'Value', new_FS);

            %Make sure resampling includes 0 tp
            %find time zero
            tm_zero = find(times==0);
            value_in_samples = value/(samps*1000);

            %start find indexes forward and backward to zero
            tm_zero_to_end = (tm_zero:value_in_samples:length(times));
            tm_zero_to_begin= (tm_zero-value_in_samples:-value_in_samples:1);
            decoding_times_index = sort(unique_bc2([tm_zero_to_begin tm_zero_to_end]));

            app.Decode_every_Npoint = value_in_samples;
            app.decoding_times_index = decoding_times_index; %save to app

            %change epoch decoding window
            new_window = [times(decoding_times_index(1)) times(decoding_times_index(end))];
            edit_time_range = sprintf('%.2f %.2f', new_window(1), new_window(2));
            app.EpochRange.Value = edit_time_range;
            app.epoch_window = new_window;
            %             set(app.AllButton,'Value',1);
            %             EpochRangeValueChanged(app,event);

            %must edit the vars epoch_range uses to make sure user can't change
            %epoch outside of new resampling limints
            app.BEST_working.xmin = new_window(1)/1000;
            app.BEST_working.xmax = new_window(2)/1000;
            app.BEST_working.srate = new_FS;
            app.BEST_working.pnts = length(decoding_times_index);
            app.BEST_working.times = times(decoding_times_index);

            %update the epoch window
            set(app.AllButton,'Value',1);
            set(app.EpochRange,'Editable','off');
            EpochRangeValueChanged(app,event);


        end

        % Button pushed function: StartDecodingButton
        function StartDecodingButtonPushed(app, event)

            %Query all outputs
            %output the original selected files (ALLBEST)
            %but the updated parameters are queried via BEST_working
            ALLBEST = app.ALLBEST;

            if app.CurrentBESTsetButton.Value == 1
                inp1 =  2; %currentSet
            elseif app.FromBESTsetMenuButton.Value == 1
                inp1 = 0; %from bestsetmenu
            elseif app.LoadBESTsetsButton.Value == 1
                inp1 = 0; %from HD

            end

            indexBEST = app.indexBEST;
            relevantChans = app.ChannelsSelected;
            % nBins = app.BEST_working.nbin;
            nIter = app.IterationsEditField.Value;
            nCrossBlocks = app.CrossValidationBlocksEditField.Value;

            if app.AllButton.Value == 1
                epochTimes = 1;
            elseif app.PreButton.Value == 1
                epochTimes = 2;
            elseif app.PostButton.Value == 1
                epochTimes = 3;
            else %custom
                epochTimes = 4;
            end

            %decode times
            decodeTimes(1) = app.BEST_working.xmin; %in s
            decodeTimes(2) = app.BEST_working.xmax; %in s

            %translate deocding_times into a "N" sample step across times
            decode_every_Npoint = app.Decode_every_Npoint;

            FloorValue = [];
            %equalize trials
            if app.EqualTrialsEqualAVGsButton.Value==1 && app.AcrossClassesButton.Value ==1 && app.AcrossBESTsetsCheckBox.Value == 0
                equalize_trials = 4;
            elseif app.EqualTrialsEqualAVGsButton.Value==1 && app.AcrossClassesButton.Value == 1 && app.AcrossBESTsetsCheckBox.Value == 1
                equalize_trials = 5;
            elseif app.EqualTrialsEqualAVGsButton.Value==1 &&  app.CommonFloorButton.Value == 1
                %check if editbox is valid
                if app.validfloor == 0
                    msgboxTest = sprintf('The Common Floor value is not valid. Please choose valid value.');
                    title = 'ERPLAB: Not a valid Common Floor value!';
                    errorfound(msgboxTest, title);
                    return
                else
                    equalize_trials = 6;
                    FloorValue = app.FloorValueEditField.Value;
                end
            elseif app.MaxTrialsEqualAVGsButton.Value==1
                equalize_trials = 7;
                Outcome_metric = 1;
            elseif app.EqualTrialsMaxAVGsButton.Value==1 && app.AcrossClassesButton.Value ==1 && app.AcrossBESTsetsCheckBox.Value == 0
                equalize_trials = 1;
            elseif app.EqualTrialsMaxAVGsButton.Value==1 && app.AcrossClassesButton.Value == 1 && app.AcrossBESTsetsCheckBox.Value == 1
                equalize_trials = 2;
            elseif app.EqualTrialsMaxAVGsButton.Value==1 &&  app.CommonFloorButton.Value == 1
                %check if editbox is valid
                if app.validfloor == 0
                    msgboxTest = sprintf('The Common Floor value is not valid. Please choose valid value.');
                    title = 'ERPLAB: Not a valid Common Floor value!';
                    errorfound(msgboxTest, title);
                    return
                else
                    equalize_trials = 3;
                    FloorValue = app.FloorValueEditField.Value;
                end
            else
                equalize_trials = 1;
            end



            if app.ACCButton_2.Value==0 && app.AUCButton_2.Value==0
                msgboxTest = sprintf('Decoding metrics: Please choose one decoding metric to use [accuracy (ACC) or area under the curve (AUC)].');
                title = 'ERPLAB: Decoding GUI';
                errorfound(msgboxTest, title);
                return

            end


            if  app.ACCButton_2.Value==1
                Outcome_metric = 1;
            else
                Outcome_metric = 2;
            end
            file_out = [];

            ParCompute = double(app.YesButton.Value);


            if app.SVMButton.Value == 1
                method = 1; %svm
            elseif app.LDAButton.Value == 1%%GH August 20 2025
                method = 2; %LDA
            elseif app.CrossnobisButton.Value == 1
                method = 3; %crossnobis
                equalize_trials = 7;
            end

            if method == 1  %|| method==3 %%GH August 20 2025
                if app.OnevsOneButton.Value == 1
                    SVMcoding = 1;
                elseif app.OnevsAllButton.Value == 1
                    SVMcoding = 2;
                end
            else
                SVMcoding = 0; %not svm
            end

            if app.CustomButton_2.Value == 1
                %if user selected custom classes to decode across
                try
                    decodeClasses = str2num(app.ClassIDEditField.Value);
                catch
                    msgboxTest = sprintf('The field Custom Classes to Decode Across is invalid');
                    title = 'ERPLAB: Not a valid Custom Class ID selection!';
                    errorfound(msgboxTest, title);
                    return
                end

            else
                decodeClasses = [];
            end
            %%regularization for SVM or LDA
            if app.SVMButton.Value==1
                regularization_Value = str2num(app.SVM_regularization_edit.Value);
            elseif app.LDAButton.Value==1
                regularization_Value = str2num(app.LDA_regularization_edit.Value);
            else
                regularization_Value =[];
            end



            %if crossnobis, SVM coding makes no sense

            %             if app.TPDecodingButton.Value == 1
            %                 decodingAcross = 1;
            %             elseif app.TWAverageButton.Value == 1
            %                 decodingAcross = 2;
            %             end

            %             [res] = mvpc_save_multi_file(ALLBEST,indexBEST,'');
            %
            %             if isempty(res)
            %                 %user pressed cancel
            %                 return
            %             end

            %ALLBEST = res{1};
            %             file_out = {ALLBEST.filename};
            %             file_path = {ALLBEST.filepath};
            if app.CrossnobisButton.Value==1
                Normalization_par=0;
                TGM_par =0;
            else
                Normalization_par = app.OnButton.Value;
                TGM_par=app.OnTGM.Value;
            end

            %output in cell
            outputs = {ALLBEST, inp1, indexBEST, relevantChans, nIter, nCrossBlocks, epochTimes, decodeTimes, decode_every_Npoint, equalize_trials, FloorValue,...
                method, SVMcoding, ParCompute, decodeClasses,regularization_Value,Outcome_metric,Normalization_par,TGM_par};

            app.output = outputs ;
            app.FinishButton = 1;
        end

        % Selection changed function: DecodingTimeRangeButtonGroup
        function DecodingTimeRangeButtonGroupSelectionChanged(app, event)
            selectedButton = app.DecodingTimeRangeButtonGroup.SelectedObject; %string

            selected_range = selectedButton.Text;
            %epoch_range = app.EpochRange.Value; %ms
            %BEST1 = app.BEST_working;
            switch selected_range
                case 'All'
                    %use full range xmin to xmax
                    %                 tscale(1) = BEST1(1).xmin * 1000; %change from s to ms
                    %                 tscale(2) = BEST1(1).xmax * 1000; %change from s to ms
                    %                 edit_time_range = sprintf('%.2f %.2f', tscale(1), tscale(2));
                    %                 app.EpochRange.Value = edit_time_range;
                    %                 EpochRangeValueChanged(app, event);
                    ReIndexTime(app, event, 'All')
                    set(app.EpochRange,'BackgroundColor',[0.65 0.65 0.65]);
                    set(app.EpochRange,'Editable','off');

                case 'Custom'
                    ReIndexTime(app, event, 'Custom')
                    set(app.EpochRange,'Editable','on');
                    set(app.EpochRange,'BackgroundColor',[1 1 1]);

                case 'Pre'
                    %use range xmin to 0
                    ReIndexTime(app, event, 'Pre')

                    set(app.EpochRange,'Editable','off');
                    set(app.EpochRange,'BackgroundColor',[0.65 0.65 0.65]);

                case 'Post'
                    ReIndexTime(app, event, 'Post')

                    set(app.EpochRange,'Editable','off');
                    set(app.EpochRange,'BackgroundColor',[0.65 0.65 0.65]);

            end

            % switch selectedButton.text;

            %if selectedButton

        end

        % Callback function
        function AcrossBESTsetsCheckBoxValueChanged(app, event)


            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);


            set(app.FloorValueEditField,'Enable',0);

            tmpdata = app.labeldata;
            %equalize across bins across files
            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];
            nblockcells = [];
            ntrialscells = [];
            if app.trialsbymethod == 1 || app.trialsbymethod == 2 % svm

                nPerBin = app.labeldata(:,4); %obtain original values
                nBlocks = app.CrossValidationBlocksEditField.Value;

                for s = 1:nsubs


                    subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject

                    %                    if app.CustomButton_2.Value == 1
                    decodeClasses = str2num(app.ClassIDEditField.Value);
                    minCnt = min(subj_ntrials(decodeClasses));
                    %         else
                    %         minCnt = min(subj_ntrials);
                    %       end
                    % max # of trials such that # of trials for all bins ...
                    % can be equated within each block
                    nPerBinBlock(s) = floor(minCnt/nBlocks);
                end

                %apply nPerBinBlock to nPerBin values
                indx = 0 ;
                for s = 1:nsubs
                    subj_ntrials = ALLBEST(s).n_trials_per_bin;
                    for b = 1:nbins
                        indx = indx +1;
                        if ismember(b,decodeClasses)
                            nPerBin{indx} = min(nPerBinBlock);
                            blackcells(indx) = indx;
                            nblockcells{indx} = nBlocks;
                            ntrialscells{indx} = subj_ntrials(b);
                        else
                            nPerBin{indx} = 'NOT USED';
                            redcells(indx) = indx;
                            nblockcells{indx} = 'NOT USED';
                            ntrialscells{indx} = 'NOT USED';
                        end

                    end
                end

                %replace N(ERP) column
                tmpdata(:,4) = (ntrialscells);
                tmpdata(:,5) = (nblockcells);
                tmpdata(:,6) = (nPerBin);

            elseif app.trialsbymethod == 3 % crossnobis

                nPerBin = app.labeldata(:,4); %obtain original values
                % nBlocks = app.CrossValidationBlocksEditField.Value;

                for s = 1:nsubs


                    subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject

                    % max # of trials such that # of trials for all bins ...
                    % can be equated within each block
                    %   if app.CustomButton_2.Value == 1
                    decodeClasses = str2num(app.ClassIDEditField.Value);
                    minCnt = min(subj_ntrials(decodeClasses));
                    %   else
                    %        minCnt = min(subj_ntrials);
                    %    end

                    nPerBinBlock(s) = minCnt;
                end

                %apply nPerBinBlock to nPerBin values
                indx = 0 ;
                for s = 1:nsubs
                    for b = 1:nbins
                        indx = indx +1;
                        if ismember(b,decodeClasses)
                            nPerBin{indx} = min(nPerBinBlock);
                            blackcells(indx) = indx;
                        else

                            nPerBin{indx} = 'NOT USED';
                            redcells(indx) = indx;
                        end


                    end
                end

                %replace N(trial) column
                %tmpdata(:,4) = num2cell(nPerBin);
                tmpdata(:,4) = (nPerBin);
                %delete N(ERP)column

                tmpdata(:,6) = [];
                tmpdata(:,5) = [];
            end


            %redraw table
            app.UITable.Data = tmpdata;

            %color
            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2

                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end
            end

        end

        % Value changed function: IterationsEditField
        function IterationsEditFieldValueChanged(app, event)
            value = app.IterationsEditField.Value;

            if value < 1
                msgboxTest = sprintf('Iterations: must be at least %i iteration',1);
                title = 'ERPLAB: Iterations error';
                errorfound(msgboxTest, title);
                set(app.IterationsEditField,'Value',100) %default to 3
                return
            end

        end

        % Callback function
        function LoadBESTWizardButtonPushed(app, event)
            %             filename = varargin{1};
            %             if strcmpi(filename,'workspace')
            %                 filepath = '';
            %             else
            % set(app.LoadBESTsetsButton,'Value',1);
            set(app.bestmenu,'Enable','off')

            %                 if isempty(filename)
            [filename, filepath] = erplab_uigetfile({'*.best','BEST (*.best)'}, ...
                'Load BEST', ...
                'MultiSelect', 'on');
            if isequal(filename,0)
                disp('User selected Cancel')
                return
            end


            %for for scripting purposes, this is generalizeable?
            %             if strcmpi(filename,'workspace')
            %                 filepath = '';
            %                 nfile = 1;
            %                 loadfrom = 0; %load from workspace
            %             else
            %                 loadfrom = 1;
            %             end


            %% load BEST files in workspace
            if iscell(filename)
                nfile = length(filename);
                inputfname = filename;
            else
                nfile = 1;
                inputfname = {filename};
            end
            inputpath = filepath;


            %file_ERPLAB_versions = nan(nfile,1);

            % % load BEST(s)
            %
            for i=1:nfile
                fullname = fullfile(inputpath, inputfname{i});
                fprintf('Loading %s\n', fullname);
                L   = load(fullname, '-mat');
                if i == 1
                    ALLBEST = L.BEST;
                else
                    ALLBEST(i) = L.BEST;
                end
            end

            %check BESTsets
            checking = checkmultiBEST(ALLBEST);

            if ~checking
                setoff(app,2); %selected choices do not work
            else
                % load into app
                app.ALLBEST = ALLBEST;
                app.indexBEST = 1:numel(ALLBEST);
                app.def{1} = 1;
                setall(app);
            end

            return


        end

        % Selection changed function: loadBESTRadioGroup
        function loadBESTRadioGroupSelectionChanged(app, event)
            selectedButton = app.loadBESTRadioGroup.SelectedObject;

            switch selectedButton.Text
                case 'Current BESTset'%current loaded bestset

                    cbesti = app.cbesti;
                    try
                        ALLBEST = app.ALLBEST_reset(cbesti);
                    catch
                        disp('No currently loaded BESTset!')
                        return;
                    end
                    app.ALLBEST = ALLBEST;
                    app.indexBEST = cbesti;
                    app.def{1} = 2;
                    try
                        setall(app);
                    catch
                        app.def = {2 cbesti [] 100 3 1 [] 1 2 1 1 2 0 []};
                        setall(app);
                    end
                    set(app.bestmenu,'Enable','off');
                    % set(app.LoadBESTWizard,'Enable','off');
                case 'From BESTset Menu' %from bestset menu
                    set(app.bestmenu,'Enable','on');
                    %set(app.LoadBESTWizard,'Enable','off');
                    try
                        idx = str2num(app.bestmenu.Value);
                        ALLBEST = app.ALLBEST_reset(idx);

                        %check BESTsets
                        checking = checkmultiBEST(ALLBEST);

                        if ~checking
                            setoff(app,2); %selected choices do not work
                        else
                            % load into app
                            app.ALLBEST = ALLBEST;
                            app.indexBEST = idx;
                            app.def{1} = 0;

                            setall(app);

                        end
                        return

                    catch ME
                        disp('Error: No valid menu number found!');
                        return
                    end
                case 'Load BESTsets' %hard drive
                    set(app.bestmenu,'Enable','off');
                    % set(app.LoadBESTWizard,'Enable','on');



            end


        end

        % Value changed function: bestmenu
        function bestmenuValueChanged(app, event)
            value = app.bestmenu.Value;

            indx = str2num(value);
            %indx = eval(value);

            ALLBEST = app.ALLBEST_reset;

            try
                chosenBEST = ALLBEST(indx);
                checking = checkmultiBEST(chosenBEST);

                if ~checking
                    %disp('Sorry, your currently loaded BESTset files do not agree with each other in terms of bins and channels')
                    setoff(app,2);
                else
                    % load into app
                    app.ALLBEST = chosenBEST;
                    app.indexBEST = indx;
                    app.def{1} = 0;

                    if app.EqualTrialsEqualAVGsButton.Value==1%%GH Sep 2025
                        if app.AcrossClassesButton.Value==1 && app.AcrossBESTsetsCheckBox.Value==1
                            app.def{9} = 2;
                        elseif app.AcrossClassesButton.Value==1 && app.AcrossBESTsetsCheckBox.Value==0
                            app.def{9} = 1;
                        else
                            app.def{9} = 3;
                        end
                    elseif app.EqualTrialsMaxAVGsButton.Value==1
                        app.def{9} = 5;
                    else
                        app.def{9} = 4;
                    end

                    AcrossBESTsetsCheckBox_value=  app.AcrossBESTsetsCheckBox.Value;
                    setall(app);
                    if app.TrialsAVGsButtonGroup.Buttons(1).Value==1  %across BESTsets

                        set(app.AcrossBESTsetsCheckBox,'Value', AcrossBESTsetsCheckBox_value);
                        % if numel(indx)==1
                        %     app.AcrossBESTsetsCheckBox.Enable = 'off';
                        % else numel(indx)> 1 && app.AcrossClassesButton.Value==1
                        %     app.AcrossBESTsetsCheckBox.Enable = 'on';
                        % end
                    end

                end


                %set(app.LoadBESTWizard,'Enable','off');

            catch
                disp([(value) ' is not a valid BESTmenu range']);
                msgboxText = [num2str(value) ' is not a valid BESTset menu range'];
                title = 'ERPLAB: Decoding GUI input';
                errorfound(msgboxText, title);
                return
            end

            %vect2colon(ch, 'Delimiter','off');

        end

        % Value changed function: ChannelsEditField
        function ChannelsEditFieldValueChanged(app, event)
            value = app.ChannelsEditField.Value;

            %editString = regexprep(value, '[\D]', ' ');

            app.ChannelsSelected = str2num(value);


        end

        % Callback function
        function bestmenuValueChanged2(app, event)
            value = app.bestmenu.Value;

        end

        % Callback function
        function ClearallBESTsetsButtonPushed(app, event)
            %setoff(app,3);

        end

        % Value changed function: FloorValueEditField
        function FloorValueEditFieldValueChanged(app, event)
            value = app.FloorValueEditField.Value;

            %requiste:
            % 1. must be at least 1 trial per ERP
            ALLBEST = app.ALLBEST;
            nbins = ALLBEST.nbin;
            nsubs = numel(ALLBEST);
            nPerBin = [app.labeldata{:,4}];
            nBlocks = app.CrossValidationBlocksEditField.Value;
            if app.EqualTrialsMaxAVGsButton.Value==1
                floorEqualMax(app);
                return;
            end
            if app.CustomButton_2.Value == 1
                if app.SVMButton.Value == 1 || app.LDAButton.Value == 1
                    nPerBin = [app.labeldata{:,4}]; %obtain original values
                    nBlocks = app.CrossValidationBlocksEditField.Value;
                    count_bin = 0;
                    for s = 1:nsubs
                        subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject
                        decodeClasses = str2num(app.ClassIDEditField.Value);
                        minCnt = min(subj_ntrials(decodeClasses));

                        % max # of trials such that # of trials for all bins ...
                        % can be equated within each block
                        nPerBinBlock(s) = floor(minCnt/nBlocks);
                        for binnums = 1:ALLBEST(s).nbin
                            count_bin = count_bin+1;
                            ntrialscells{count_bin} = ALLBEST(s).n_trials_per_bin(binnums);
                        end
                    end
                    value_check = min(nPerBinBlock);

                else
                    %crossnobis check

                    for s = 1:nsubs
                        subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject
                        decodeClasses = str2num(app.ClassIDEditField.Value);
                        nPerBinBlock(s) = min(subj_ntrials(decodeClasses));
                    end
                    value_check = min(nPerBinBlock);

                end

            else
                if app.SVMButton.Value == 1
                    value_check = floor(min(nPerBin)/nBlocks);

                else
                    %crossnobis check
                    value_check = min(nPerBin) ;
                end
            end


            if value > value_check
                msgboxTest = sprintf(['You selected an invalid floor %i. The value exceeds the max the number of trials within cross-validation blocks (SVM) ' ...
                    'or the max number of trials in any class (Crossnobis)'],value);
                title = 'ERPLAB: Cross-Validation error';
                errorfound(msgboxTest, title);
                app.validfloor = 0;
                return
            end


            if value < 1
                msgboxTest = sprintf('You selected an invalid floor %i. You cannot go less than 1 trial',value);
                title = 'ERPLAB: Cross-Validation error';
                errorfound(msgboxTest, title);
                app.validfloor = 0;
                return
            end

            %copy original data with 5 columns
            tmpdata = app.labeldata;

            %apply floor to data
            indx = 0 ;
            for s = 1:nsubs
                for b = 1:nbins
                    indx = indx +1;
                    nPerBin(indx) = value ;

                end
            end

            %

            %equalize across bins across files
            S3 = uistyle;
            S3.FontColor = 'black';
            S3.FontWeight = 'normal';


            S4 = uistyle;
            S4.FontColor = 'red';
            S4.FontWeight = 'bold';
            redcells = [];
            blackcells = [];

            if app.trialsbymethod == 1 || app.trialsbymethod == 2 % svm
                %replace N(ERP) column
                tmpdata(:,6) = num2cell(nPerBin);
                for jjj = 1:size(tmpdata,1)
                    if ischar(tmpdata{jjj,2}) &&  strcmpi(tmpdata{jjj,2},'NOT USED')
                        tmpdata{jjj,6} = 'NOT USED';
                        tmpdata{jjj,5} = 'NOT USED';
                        redcells(jjj) = jjj;
                    else
                        blackcells(jjj) = jjj;
                    end

                end
                ntrialscells = [];
                count_bin = 0;
                for s = 1:nsubs
                    subj_ntrials = ALLBEST(s).n_trials_per_bin; %all trials per subject
                    decodeClasses = str2num(app.ClassIDEditField.Value);
                    minCnt = min(subj_ntrials(decodeClasses));

                    % max # of trials such that # of trials for all bins ...
                    % can be equated within each block
                    nPerBinBlock(s) = floor(minCnt/nBlocks);
                    for binnums = 1:ALLBEST(s).nbin
                        count_bin = count_bin+1;
                        ntrialscells{count_bin} = ALLBEST(s).n_trials_per_bin(binnums);
                    end
                end
                tmpdata(:,4) = (ntrialscells);
            elseif app.trialsbymethod == 3 % crossnobis
                %replace N(trial) column
                tmpdata(:,4) = num2cell(nPerBin);

                %delete N(ERP)column
                tmpdata(:,6) = [];
                tmpdata(:,5) = [];
                for jjj = 1:size(tmpdata,1)
                    if ischar(tmpdata{jjj,2}) &&  strcmpi(tmpdata{jjj,2},'NOT USED')
                        tmpdata{jjj,4} = 'NOT USED';
                        redcells(jjj) = jjj;
                    else
                        blackcells(jjj) = jjj;

                    end

                end

            end

            %redraw table
            app.UITable.Data = tmpdata;
            app.validfloor = 1;
            %color
            redcells2 = redcells(redcells~=0)';
            blackcells2 = blackcells(blackcells~=0)';
            if ~isempty(redcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2

                    redcells2(:,2) = 5;
                    reblackcells = redcells2;
                    reblackcells(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [reblackcells]);
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                    redcells2(:,2) = 6;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                elseif app.trialsbymethod == 3
                    redcells2(:,2) = 4;
                    addStyle(app.UITable,S4,'cell', [redcells2]);
                end
            end

            if ~isempty(blackcells2)
                if app.trialsbymethod == 1 || app.trialsbymethod == 2
                    blackcells2(:,2) = 5;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                    blackcells2(:,2) = 6;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                elseif app.trialsbymethod == 3
                    blackcells2(:,2) = 4;
                    addStyle(app.UITable,S3,'cell', [blackcells2]);
                end


            end


        end

        % Callback function
        function CommonFloorCheckBoxValueChanged(app, event)
            % DEFUNCT
            % value = app.CommonFloorCheckBox.Value;
            %             set(app.FloorValueEditField,'Enable',1);
            %
            %
            %
            %
            %
            %            if value == 1
            %                set(app.AcrossBinsCheckBox,'Value',0);
            %            set(app.AcrossBESTsetsCheckBox,'Value',0);
            %            AcrossBESTsetsCheckBoxValueChanged(app,event);
            %
            %            if app.FloorValueEditField.Value ~= 0
            %                FloorValueEditFieldValueChanged(app,event);
            %            end
            %
            %
            %
            %
            % else
            %  AcrossBESTsetsCheckBoxValueChanged(app,event);
            %
            %
            %  end

        end

        % Selection changed function: ParallelizationButtonGroup
        function ParallelizationButtonGroupSelectionChanged(app, event)
            selectedButton = app.ParallelizationButtonGroup.SelectedObject;

            switch selectedButton.Text
                case 'Yes'
                    %test if have Parallel Computing Toolbox (PCT)
                    v = ver;
                    hasPCT = any(strcmp(cellstr(char(v.Name)), 'Parallel Computing Toolbox'));

                    if hasPCT ~= 1
                        msgboxText =  ['Error: You currently do not have Parallel Computing Toolbox, an offiical MATLAB toolbox add-on. ...' ...
                            'Please contact MATHWORKS or your system admin to install this for your MATLAB version'];
                        title = 'ERPLAB: Missing Parallel Computing Toolbox';
                        errorfound(msgboxText, title);
                        %change value
                        app.NoButton.Value = 1;
                    else
                        disp('User has Parallel Computing Toolbox installed; Will use as many available cores as possible.')
                    end
                case 'No'
                    disp('User has unselected Paralleization option');
            end

        end

        % Callback function
        function TrialsButtonGroupSelectionChanged(app, event)
            selectedButton = app.TrialsButtonGroup.SelectedObject;

            switch selectedButton.Text
                case 'Across Classes'

                    set(app.AcrossBESTsetsCheckBox,'Enable','on');

                    if app.AcrossBESTsetsCheckBox.Value == 0
                        AcrossBinsCheckBoxValueChanged(app, event);
                    else
                        AcrossBESTsetsCheckBoxValueChanged(app,event);
                    end
                    set(app.FloorValueEditField,'Enable','off');

                case 'Common Floor'
                    set(app.AcrossBESTsetsCheckBox,'Enable','off');
                    set(app.AcrossBESTsetsCheckBox,'Value',0);
                    set(app.FloorValueEditField,'Enable','on');
                    app.validfloor = 0;
                    FloorValueEditFieldValueChanged(app,event);

            end



        end

        % Callback function
        function AcrossBESTsetsCheckBox_2ValueChanged(app, event)
            value = app.AcrossBESTsetsCheckBox.Value;
            if value == 1
                AcrossBESTsetsCheckBoxValueChanged(app, event);
            else
                AcrossBinsCheckBoxValueChanged(app,event);
            end
        end

        % Value changed function: DownsampleOptionalCheckBox
        function DownsampleOptionalCheckBoxValueChanged(app, event)
            value = app.DownsampleOptionalCheckBox.Value;

            if value == 1
                set(app.SubsamplePanel,'Enable','on');
            else
                set(app.SubsamplePanel,'Enable','off');

                %reset the subsampling
                val = app.TPspinner.Limits(1);
                set(app.TPspinner,'Value',val);
                TPspinnerValueChanged(app,event);
            end

        end

        % Selection changed function: MethodButtonGroup
        function MethodButtonGroupSelectionChanged(app, event)
            selectedButton = app.MethodButtonGroup.SelectedObject;

            nsubs = numel(app.ALLBEST);
            set(app.CrossValidationBlocksEditField,'Enable','on');
            set(app.CodingSVMOnlyButtonGroup,'Enable','on');
            set(app.EqualTrialsMaxAVGsButton,'Enable','on');

            lab_text = ['Common Floor is applied to the number of trials per ERP, and must not be greater ' ...
                'than the amount of trials per class divided by cross-validation blocks.'];
            app.CommonFloorButton.Tooltip = lab_text;%%GH
            selectedButton_subfold = app.TrialsAVGsButtonGroup.SelectedObject;%%GH August 2025

            switch selectedButton.Text

                case {'SVM','LDA'}
                    set(app.TrialsAVGsButtonGroup,'Enable','on');
                    app.trialsbymethod = 1;
                    set(app.MetricButtonGroup,'Enable','on');
                    app.NormalizationButtonGroup.Enable = 'on';
                    app.TemporalgeneralizationmatrixButtonGroup.Enable = 'on';
                    if  app.EqualTrialsMaxAVGsButton.Value==1%%GH Apr 2026
                        selectedButton_subfold =1;%
                        SelectedObject_Text = 'Equal Trials, Max AVGs';
                    elseif app.EqualTrialsEqualAVGsButton.Value==1
                        selectedButton_subfold=2;%
                        SelectedObject_Text = 'Equal Trials, Equal AVGs';
                    else
                        selectedButton_subfold=3;%
                        SelectedObject_Text ='Max Trials, Equal AVGs';
                    end


                    switch selectedButton_subfold

                        case 2%'Equal Trials, Equal AVGs'
                            set(app.TrialsButtonGroup,'Enable','on');
                            set(app.MetricButtonGroup,'Enable','on');
                            set(app.ACCButton_2,'Enable','on');
                            selectedButton_subsample = app.TrialsButtonGroup.SelectedObject;
                            switch selectedButton_subsample.Text
                                case 'Across Classes'
                                    AcrossBinsCheckBoxValueChanged(app, event);
                                    if nsubs == 1
                                        set(app.AcrossBESTsetsCheckBox,'Enable','off');
                                    else
                                        set(app.AcrossBESTsetsCheckBox,'Enable','on');
                                        if app.AcrossBESTsetsCheckBox.Value == 1
                                            AcrossBESTsetsCheckBoxValueChanged(app,event);
                                        end
                                    end
                                case 'Common Floor'
                                    set(app.FloorValueEditField,'Enable','on');
                                    FloorValueEditFieldValueChanged(app,event);
                            end
                        case 3%'Max Trials, Equal AVGs'%%GH
                            set(app.TrialsButtonGroup,'Enable','off');
                            set(app.ACCButton_2,'Enable','off');
                            set(app.ACCButton_2,'Value',0);
                            set(app.AUCButton_2,'Value',1);
                            resetTrials(app);
                        case 1%'Equal Trials, Max AVGs'%%GH
                            set(app.TrialsButtonGroup,'Enable','on');
                            set(app.ACCButton_2,'Enable','on');
                            selectedButton_subsample = app.TrialsButtonGroup.SelectedObject;
                            switch selectedButton_subsample.Text
                                case 'Across Classes'
                                    resetequatedtrials(app);
                                    if nsubs == 1
                                        set(app.AcrossBESTsetsCheckBox,'Enable','off');
                                    else
                                        set(app.AcrossBESTsetsCheckBox,'Enable','on');
                                        if app.AcrossBESTsetsCheckBox.Value == 1
                                            acrossbestEqualMax(app);
                                        end
                                    end
                                case 'Common Floor'
                                    set(app.FloorValueEditField,'Enable','on');
                                    floorEqualMax(app);
                            end
                            % resetequatedtrials(app);
                    end

                    % end

                    switch selectedButton.Text
                        case  'SVM'
                            app.def{11}=1;
                            %%August 20 2025 GH
                            set(app.LDA_regularization_edit,'Enable','off');
                            set(app.SVM_regularization_edit,'Enable','on');
                            SVM_regularization = str2num(app.SVM_regularization_edit.Value);
                            if isempty(SVM_regularization) || numel(SVM_regularization)~=1 || any(SVM_regularization<=0)
                                % msgboxText =  'The regularization parameter for SVM should be a  positive scalar. The default one of 1 will be used.';
                                % title = 'ERPLAB: ERP decoding GUI input';
                                % errorfound(msgboxText, title);
                                app.SVM_regularization_edit.Value = '1';
                            end

                        case 'LDA'
                            app.def{11}=2;
                            set(app.LDA_regularization_edit,'Enable','on');
                            set(app.SVM_regularization_edit,'Enable','off');
                            LDA_regularization = str2num(app.LDA_regularization_edit.Value);
                            if isempty(LDA_regularization) || numel(LDA_regularization)~=1 || any(LDA_regularization<0)  || any(LDA_regularization>1)
                                % msgboxText =  'The regularization parameter for LDA should be a  positive scalar and between 0 and 1. The default one of 0 will be used.';
                                % title = 'ERPLAB: ERP decoding GUI input';
                                % errorfound(msgboxText, title);
                                app.LDA_regularization_edit.Value = '0';
                            end
                            set(app.CodingSVMOnlyButtonGroup,'Enable','off');
                    end

                case 'Crossvalidated Mahalanobis'
                    app.TemporalgeneralizationmatrixButtonGroup.Enable = 'off';
                    app.NormalizationButtonGroup.Enable = 'off';
                    app.def{11}=3;
                    set(app.CodingSVMOnlyButtonGroup,'Enable','off');
                    set(app.CrossValidationBlocksEditField,'Enable','off');
                    set(app.LDA_regularization_edit,'Enable','off');
                    set(app.SVM_regularization_edit,'Enable','off');
                    set(app.EqualTrialsMaxAVGsButton,'Enable','off');
                    set(app.MetricButtonGroup,'Enable','off');
                    set(app.TrialsAVGsButtonGroup,'Enable','off');%%GH Sep 2025
                    app.trialsbymethod = 3;

                    lab_text = ['Common Floor is applied to the number of trials in each class, and must not be greater ' ...
                        'than the actual amount of trials per class.'];
                    app.CommonFloorButton.Tooltip = lab_text;%%GH August 20 2025

                    % app.TrialsAVGsButtonGroup.Buttons(3).Value=1;%%set "Unequated-trials" as default one
                    set(app.TrialsButtonGroup,'Enable','off');
                    set(app.ACCButton_2,'Enable','off');
                    set(app.ACCButton_2,'Value',0);
                    set(app.AUCButton_2,'Value',1);
                    resetTrials(app);
            end

        end

        % Callback function
        function UIFigureCloseRequest(app, event)
            delete(app)

        end

        % Selection changed function: SelectClassesGroup
        function SelectClassesGroupSelectionChanged(app, event)
            selectedButton = app.SelectClassesGroup.SelectedObject;

            switch selectedButton.Text
                case 'All'
                    set(app.ClassIDEditField,'Enable','Off');
                    %reset to all classses
                    decodeClasses = 1:numel(app.BEST_working.binwise_data);

                    set(app.ClassIDEditField,'Value',num2str(mat2colon(decodeClasses,'Delimiter','off')));
                    set(app.ClassIDEditField,'Editable','Off');
                    set(app.BrowseButton_2,'Enable','Off');

                    %reuse the Class ID handler: it redraws the table and also
                    %recomputes the trial/AVG columns for the new class list
                    ClassIDEditFieldValueChanged(app,event);

                case 'Custom'
                    set(app.ClassIDEditField,'Enable','On');
                    set(app.ClassIDEditField,'Editable','On');
                    set(app.BrowseButton_2,'Enable','On');
                    set(app.ClassIDEditField,'Editable','On');
            end


        end

        % Button pushed function: BrowseButton_2
        function BrowseButton_2Pushed(app, event)


            BEST1 = app.ALLBEST(1);
            nbins = numel(BEST1.binwise_data);

            listbin = BEST1(1).bindesc; %true bins list as labels
            indxlistbin = 1:nbins;  %true array of bin indexs
            indxlistbin = indxlistbin(indxlistbin<=length(listbin)); % true array of bin index if less than expected labels
            titlename = 'Select Class(es)';

            if ~isempty(listbin)
                ch = browsechanbinGUI(listbin, indxlistbin, titlename);
                if ~isempty(ch)
                    %set(handles.chwindow, 'String', vect2colon(ch, 'Delimiter', 'off'));
                    app.ClassIDEditField.Value = vect2colon(ch, 'Delimiter','off');
                    %update gui
                    ClassIDEditFieldValueChanged(app,event);
                else
                    disp('User selected Cancel')
                    return
                end
            else
                msgboxText =  'Invalid input (use only Class ID numbers).';
                title = 'ERPLAB: BrowseClasses GUI input';
                errorfound(msgboxText, title);
                return
            end
        end

        % Value changed function: ClassIDEditField
        function ClassIDEditFieldValueChanged(app, event)
            value = app.ClassIDEditField.Value;

            try
                decodeClasses = str2num(value);
                if numel(decodeClasses) < 2
                    msgboxText =  'Must choose at least two classes to decode across';
                    title = 'ERPLAB: BrowseClasses GUI input';
                    errorfound(msgboxText, title);

                    %reset to all classses
                    decodeClasses = 1:numel(app.BEST_working.binwise_data);
                    set(app.ClassIDEditField,'Value',num2str(mat2colon(decodeClasses,'Delimiter','off')));
                    return
                else
                    % set(app.ClassIDEditField,'Value',value);
                    redrawClasses(app,decodeClasses);
                    %%GH September 2025
                    % selectedButton = app.TrialsAVGsButtonGroup.SelectedObject;
                    if  app.EqualTrialsMaxAVGsButton.Value==1%%GH Apr 2026
                        selectedButton_subfold =1;%'Equal Trials, Max AVGs'
                    elseif app.EqualTrialsEqualAVGsButton.Value==1
                        selectedButton_subfold=2;%'Equal Trials, Equal AVGs'
                    else
                        selectedButton_subfold=3;%'Max Trials, Equal AVGs'
                    end
                    nsubs = numel(app.ALLBEST);
                    switch selectedButton_subfold
                        case 2%'Equal Trials, Equal AVGs'
                            selectedButton12 = app.TrialsButtonGroup.SelectedObject;
                            switch selectedButton12.Text
                                case 'Across Classes'
                                    AcrossBinsCheckBoxValueChanged(app, event);
                                    if nsubs == 1
                                    else
                                        if app.AcrossBESTsetsCheckBox.Value == 1
                                            AcrossBESTsetsCheckBoxValueChanged(app,event);
                                        end
                                    end
                                case 'Common Floor'
                                    FloorValueEditFieldValueChanged(app,event);
                            end
                        case 1%'Equal Trials, Max AVGs'
                            resetequatedtrials(app);
                        case 3%'Max Trials, Equal AVGs'
                            resetTrials(app);
                    end
                end

            catch
                msgboxText =  'Invalid input (use only Class ID numbers)';
                title = 'ERPLAB: BrowseClasses GUI input';
                errorfound(msgboxText, title);

                %reset to all classses
                decodeClasses = 1:numel(app.BEST_working.binwise_data);
                set(app.ClassIDEditField,'Value',num2str(mat2colon(decodeClasses,'Delimiter','off')));

                return


            end

        end

        % Value changed function: SVM_regularization_edit
        function f_SVM_regularization(app, event)
            SVM_regularization = str2num(app.SVM_regularization_edit.Value);
            if isempty(SVM_regularization) || numel(SVM_regularization)~=1 || any(SVM_regularization<=0)
                msgboxText =  'The regularization parameter for SVM should be larger than 0. The default value of 1 will be used.';
                title = 'ERPLAB: ERP decoding GUI input';
                errorfound(msgboxText, title);
                app.SVM_regularization_edit.Value = '1';
            end
        end

        % Value changed function: LDA_regularization_edit
        function f_LDA_regularization(app, event)
            LDA_regularization = app.LDA_regularization_edit.Value;
            if isempty(LDA_regularization) || numel(LDA_regularization)~=1 || any(LDA_regularization<0) || any(LDA_regularization>1)
                msgboxText =  'The regularization parameter for LDA should be  between 0 and 1. The default value of 0 will be used which means there is no regularization.';
                title = 'ERPLAB: ERP decoding GUI input';
                errorfound(msgboxText, title);
                app.LDA_regularization_edit.Value = '0';
            end
        end

        % Selection changed function: TrialsAVGsButtonGroup
        function f_subfoldmethod(app, event)
            %%GH 2025 August
            if  app.EqualTrialsMaxAVGsButton.Value==1%%GH Apr 2026
                selectedButton_subfold =1;%
                SelectedObject_Text = 'Equal Trials, Max AVGs';
            elseif app.EqualTrialsEqualAVGsButton.Value==1
                selectedButton_subfold=2;%
                SelectedObject_Text = 'Equal Trials, Equal AVGs';
            else
                selectedButton_subfold=3;%
                SelectedObject_Text ='Max Trials, Equal AVGs';
            end

            nsubs = numel(app.ALLBEST);
            switch selectedButton_subfold
                case 2%'Equal Trials, Equal AVGs'
                    set(app.ACCButton_2,'Enable','on');
                    set(app.TrialsButtonGroup,'Enable','on');
                    selectedButton12 = app.TrialsButtonGroup.SelectedObject;
                    switch selectedButton12.Text
                        case 'Across Classes'
                            AcrossBinsCheckBoxValueChanged(app, event);
                            if nsubs == 1
                                set(app.AcrossBESTsetsCheckBox,'Enable','off');
                            else
                                set(app.AcrossBESTsetsCheckBox,'Enable','on');
                                if app.AcrossBESTsetsCheckBox.Value == 1
                                    AcrossBESTsetsCheckBoxValueChanged(app,event);
                                end
                            end
                        case 'Common Floor'
                            app.AcrossBESTsetsCheckBox.Enable = 'off';
                            set(app.FloorValueEditField,'Enable','on');
                            FloorValueEditFieldValueChanged(app,event);
                    end

                case 1%'Equal Trials, Max AVGs'
                    set(app.ACCButton_2,'Enable','on');
                    set(app.TrialsButtonGroup,'Enable','on');
                    % resetequatedtrials(app);
                    selectedButton12 = app.TrialsButtonGroup.SelectedObject;
                    switch selectedButton12.Text
                        case 'Across Classes'
                            resetequatedtrials(app);
                            if nsubs == 1
                                set(app.AcrossBESTsetsCheckBox,'Enable','off');
                            else
                                set(app.AcrossBESTsetsCheckBox,'Enable','on');
                                if app.AcrossBESTsetsCheckBox.Value == 1
                                    acrossbestEqualMax(app);
                                end
                            end
                        case 'Common Floor'
                            app.AcrossBESTsetsCheckBox.Enable = 'off';
                            set(app.FloorValueEditField,'Enable','on');
                            floorEqualMax(app);
                    end

                case 3%'Max Trials, Equal AVGs'
                    set(app.ACCButton_2,'Enable','off');
                    set(app.AUCButton_2,'Value',1);
                    set(app.ACCButton_2,'Value',0);
                    set(app.TrialsButtonGroup,'Enable','off');
                    resetTrials(app);
            end
            app.subfoldmethods = SelectedObject_Text;
            if  strcmpi(app.subfoldmethods,'Max Trials, Equal AVGs')
                app.ACCButton_2.Value=0;
                app.AUCButton_2.Value=0;
                app.AUCButton_3.Value=1;
            end
            selectedButton11 = app.MethodButtonGroup.SelectedObject;
            if  strcmpi(selectedButton11.Text,'Crossvalidated Mahalanobis')
                set(app.MetricButtonGroup,'Enable','off');
            end
        end

        % Selection changed function: TrialsButtonGroup
        function f_subsampling_subfunction(app, event)
            selectedButton = app.TrialsButtonGroup.SelectedObject;
            nsubs = numel(app.ALLBEST);
            switch selectedButton.Text
                case 'Across Classes'
                    if app.EqualTrialsMaxAVGsButton.Value==1%%GH Dec. 2025
                        resetequatedtrials(app);
                    else
                        AcrossBinsCheckBoxValueChanged(app, event);
                    end
                    if nsubs == 1
                        set(app.AcrossBESTsetsCheckBox,'Enable','off');
                    else
                        set(app.AcrossBESTsetsCheckBox,'Enable','on');
                        if app.AcrossBESTsetsCheckBox.Value == 1
                            if app.EqualTrialsMaxAVGsButton.Value==1%%GH Dec. 2025
                                acrossbestEqualMax(app);
                            else
                                AcrossBESTsetsCheckBoxValueChanged(app,event);
                            end
                        end
                    end
                    app.FloorValueEditField.Enable = 'off';
                case 'Common Floor'
                    app.AcrossBESTsetsCheckBox.Enable = 'off';
                    set(app.FloorValueEditField,'Enable','on');
                    app.validfloor = 0;
                    if app.EqualTrialsMaxAVGsButton.Value==1%%GH Dec. 2025
                        floorEqualMax(app);
                    else
                        FloorValueEditFieldValueChanged(app,event);
                    end
                    app.FloorValueEditField.Enable = 'on';
            end

        end

        % Value changed function: AcrossBESTsetsCheckBox
        function f_acrossbestsets(app, event)
            value = app.AcrossBESTsetsCheckBox.Value;
            if app.AcrossBESTsetsCheckBox.Value == 1
                if app.EqualTrialsMaxAVGsButton.Value==1
                    acrossbestEqualMax(app);
                else
                    AcrossBESTsetsCheckBoxValueChanged(app,event);
                end
            else
                if app.EqualTrialsMaxAVGsButton.Value==1
                    resetequatedtrials(app);
                else
                    AcrossBinsCheckBoxValueChanged(app, event);
                end
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.851 0.851 0.851];
            app.UIFigure.Position = [100 100 1227 662];
            app.UIFigure.Name = 'MATLAB App';

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {'BEST File'; 'Class ID'; 'Class/Label'; 'N(trials)'; 'B(ERPs)'; 'N(per ERP)'};
            app.UITable.ColumnWidth = {'auto', 100, 'auto', 100, 100};
            app.UITable.RowName = {};
            app.UITable.Position = [20 111 697 443];

            % Create DecodingParametersPanel
            app.DecodingParametersPanel = uipanel(app.UIFigure);
            app.DecodingParametersPanel.Title = 'Decoding Parameters';
            app.DecodingParametersPanel.Position = [734 48 224 587];

            % Create CrossValidationBlocksEditFieldLabel
            app.CrossValidationBlocksEditFieldLabel = uilabel(app.DecodingParametersPanel);
            app.CrossValidationBlocksEditFieldLabel.HorizontalAlignment = 'right';
            app.CrossValidationBlocksEditFieldLabel.Position = [11 480 133 22];
            app.CrossValidationBlocksEditFieldLabel.Text = 'Cross-Validation Blocks';

            % Create CrossValidationBlocksEditField
            app.CrossValidationBlocksEditField = uieditfield(app.DecodingParametersPanel, 'numeric');
            app.CrossValidationBlocksEditField.ValueChangedFcn = createCallbackFcn(app, @CrossValidationBlocksEditFieldValueChanged, true);
            app.CrossValidationBlocksEditField.Position = [159 481 48 21];

            % Create ChannelsEditFieldLabel
            app.ChannelsEditFieldLabel = uilabel(app.DecodingParametersPanel);
            app.ChannelsEditFieldLabel.HorizontalAlignment = 'right';
            app.ChannelsEditFieldLabel.Position = [11 453 56 22];
            app.ChannelsEditFieldLabel.Text = 'Channels';

            % Create ChannelsEditField
            app.ChannelsEditField = uieditfield(app.DecodingParametersPanel, 'text');
            app.ChannelsEditField.ValueChangedFcn = createCallbackFcn(app, @ChannelsEditFieldValueChanged, true);
            app.ChannelsEditField.HorizontalAlignment = 'center';
            app.ChannelsEditField.Position = [73 453 80 20];

            % Create ChanceEditFieldLabel
            app.ChanceEditFieldLabel = uilabel(app.DecodingParametersPanel);
            app.ChanceEditFieldLabel.HorizontalAlignment = 'right';
            app.ChanceEditFieldLabel.Position = [16 508 43 22];
            app.ChanceEditFieldLabel.Text = 'Chance';

            % Create ChanceEditField
            app.ChanceEditField = uieditfield(app.DecodingParametersPanel, 'numeric');
            app.ChanceEditField.Editable = 'off';
            app.ChanceEditField.BackgroundColor = [0.651 0.651 0.651];
            app.ChanceEditField.Position = [158 509 48 21];

            % Create NumberofClassesBinsEditFieldLabel
            app.NumberofClassesBinsEditFieldLabel = uilabel(app.DecodingParametersPanel);
            app.NumberofClassesBinsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofClassesBinsEditFieldLabel.Position = [11 539 136 22];
            app.NumberofClassesBinsEditFieldLabel.Text = 'Number of Classes/Bins';

            % Create NumberofClassesBinsEditField
            app.NumberofClassesBinsEditField = uieditfield(app.DecodingParametersPanel, 'numeric');
            app.NumberofClassesBinsEditField.Editable = 'off';
            app.NumberofClassesBinsEditField.BackgroundColor = [0.651 0.651 0.651];
            app.NumberofClassesBinsEditField.Position = [159 540 51 21];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.DecodingParametersPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [158 452 52 22];
            app.BrowseButton.Text = 'Browse';

            % Create IterationsEditFieldLabel
            app.IterationsEditFieldLabel = uilabel(app.DecodingParametersPanel);
            app.IterationsEditFieldLabel.HorizontalAlignment = 'right';
            app.IterationsEditFieldLabel.Position = [14 428 55 22];
            app.IterationsEditFieldLabel.Text = 'Iterations';

            % Create IterationsEditField
            app.IterationsEditField = uieditfield(app.DecodingParametersPanel, 'numeric');
            app.IterationsEditField.ValueChangedFcn = createCallbackFcn(app, @IterationsEditFieldValueChanged, true);
            app.IterationsEditField.Position = [159 428 46 19];

            % Create SelectClassesGroup
            app.SelectClassesGroup = uibuttongroup(app.DecodingParametersPanel);
            app.SelectClassesGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectClassesGroupSelectionChanged, true);
            app.SelectClassesGroup.Title = 'Select Classes To Decode Across';
            app.SelectClassesGroup.Position = [6 341 210 83];

            % Create AllButton_2
            app.AllButton_2 = uiradiobutton(app.SelectClassesGroup);
            app.AllButton_2.Text = 'All';
            app.AllButton_2.Position = [8 38 35 22];
            app.AllButton_2.Value = true;

            % Create CustomButton_2
            app.CustomButton_2 = uiradiobutton(app.SelectClassesGroup);
            app.CustomButton_2.Text = 'Custom';
            app.CustomButton_2.Position = [58 38 64 22];

            % Create ClassIDEditFieldLabel
            app.ClassIDEditFieldLabel = uilabel(app.SelectClassesGroup);
            app.ClassIDEditFieldLabel.HorizontalAlignment = 'right';
            app.ClassIDEditFieldLabel.Position = [7 9 55 22];
            app.ClassIDEditFieldLabel.Text = 'Class ID';

            % Create ClassIDEditField
            app.ClassIDEditField = uieditfield(app.SelectClassesGroup, 'text');
            app.ClassIDEditField.ValueChangedFcn = createCallbackFcn(app, @ClassIDEditFieldValueChanged, true);
            app.ClassIDEditField.Position = [67 9 80 23];

            % Create BrowseButton_2
            app.BrowseButton_2 = uibutton(app.SelectClassesGroup, 'push');
            app.BrowseButton_2.ButtonPushedFcn = createCallbackFcn(app, @BrowseButton_2Pushed, true);
            app.BrowseButton_2.Position = [154 10 50 22];
            app.BrowseButton_2.Text = {'Browse'; ''};

            % Create TrialsAVGsButtonGroup
            app.TrialsAVGsButtonGroup = uibuttongroup(app.DecodingParametersPanel);
            app.TrialsAVGsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @f_subfoldmethod, true);
            app.TrialsAVGsButtonGroup.Title = '#Trials & #AVGs';
            app.TrialsAVGsButtonGroup.Position = [5 139 213 197];

            % Create EqualTrialsEqualAVGsButton
            app.EqualTrialsEqualAVGsButton = uiradiobutton(app.TrialsAVGsButtonGroup);
            app.EqualTrialsEqualAVGsButton.Text = 'Equal Trials, Equal AVGs';
            app.EqualTrialsEqualAVGsButton.Position = [102 131 155 39];

            % Create EqualTrialsMaxAVGsButton
            app.EqualTrialsMaxAVGsButton = uiradiobutton(app.TrialsAVGsButtonGroup);
            app.EqualTrialsMaxAVGsButton.Text = 'Equal Trials, Max AVGs';
            app.EqualTrialsMaxAVGsButton.Position = [11 130 147 39];

            % Create MaxTrialsEqualAVGsButton
            app.MaxTrialsEqualAVGsButton = uiradiobutton(app.TrialsAVGsButtonGroup);
            app.MaxTrialsEqualAVGsButton.Text = 'Max Trials, Equal AVGs';
            app.MaxTrialsEqualAVGsButton.Position = [10 3 147 22];
            app.MaxTrialsEqualAVGsButton.Value = true;

            % Create TrialsButtonGroup
            app.TrialsButtonGroup = uibuttongroup(app.TrialsAVGsButtonGroup);
            app.TrialsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @f_subsampling_subfunction, true);
            app.TrialsButtonGroup.Position = [16 36 173 90];

            % Create AcrossClassesButton
            app.AcrossClassesButton = uiradiobutton(app.TrialsButtonGroup);
            app.AcrossClassesButton.Text = 'Across Classes';
            app.AcrossClassesButton.Position = [5 64 104 22];
            app.AcrossClassesButton.Value = true;

            % Create CommonFloorButton
            app.CommonFloorButton = uiradiobutton(app.TrialsButtonGroup);
            app.CommonFloorButton.Text = 'Common Floor';
            app.CommonFloorButton.Position = [6 5 102 34];

            % Create AcrossBESTsetsCheckBox
            app.AcrossBESTsetsCheckBox = uicheckbox(app.TrialsButtonGroup);
            app.AcrossBESTsetsCheckBox.ValueChangedFcn = createCallbackFcn(app, @f_acrossbestsets, true);
            app.AcrossBESTsetsCheckBox.Text = 'Across BESTsets';
            app.AcrossBESTsetsCheckBox.Position = [21 41 113 22];

            % Create FloorValueEditField
            app.FloorValueEditField = uieditfield(app.TrialsButtonGroup, 'numeric');
            app.FloorValueEditField.ValueChangedFcn = createCallbackFcn(app, @FloorValueEditFieldValueChanged, true);
            app.FloorValueEditField.Position = [109 10 61 27];
            app.FloorValueEditField.Value = 1;

            % Create MetricButtonGroup
            app.MetricButtonGroup = uibuttongroup(app.DecodingParametersPanel);
            app.MetricButtonGroup.Title = 'Metric';
            app.MetricButtonGroup.Position = [6 94 212 40];

            % Create ACCButton_2
            app.ACCButton_2 = uiradiobutton(app.MetricButtonGroup);
            app.ACCButton_2.Text = 'ACC';
            app.ACCButton_2.Position = [13 -2 58 22];
            app.ACCButton_2.Value = true;

            % Create AUCButton_2
            app.AUCButton_2 = uiradiobutton(app.MetricButtonGroup);
            app.AUCButton_2.Text = 'AUC';
            app.AUCButton_2.Position = [89 -2 65 22];

            % Create AUCButton_3
            app.AUCButton_3 = uiradiobutton(app.MetricButtonGroup);
            app.AUCButton_3.Enable = 'off';
            app.AUCButton_3.Visible = 'off';
            app.AUCButton_3.Text = 'AUC';
            app.AUCButton_3.Position = [141 -2 65 22];

            % Create NormalizationButtonGroup
            app.NormalizationButtonGroup = uibuttongroup(app.DecodingParametersPanel);
            app.NormalizationButtonGroup.Title = 'Normalization ';
            app.NormalizationButtonGroup.Position = [5 49 213 40];

            % Create OnButton
            app.OnButton = uiradiobutton(app.NormalizationButtonGroup);
            app.OnButton.Text = 'On';
            app.OnButton.Position = [11 -2 58 22];
            app.OnButton.Value = true;

            % Create OffButton
            app.OffButton = uiradiobutton(app.NormalizationButtonGroup);
            app.OffButton.Text = 'Off';
            app.OffButton.Position = [90 -2 65 22];

            % Create TemporalgeneralizationmatrixButtonGroup
            app.TemporalgeneralizationmatrixButtonGroup = uibuttongroup(app.DecodingParametersPanel);
            app.TemporalgeneralizationmatrixButtonGroup.Title = 'Temporal generalization matrix';
            app.TemporalgeneralizationmatrixButtonGroup.Position = [5 5 213 40];

            % Create OnTGM
            app.OnTGM = uiradiobutton(app.TemporalgeneralizationmatrixButtonGroup);
            app.OnTGM.Text = 'On';
            app.OnTGM.Position = [11 -2 58 22];
            app.OnTGM.Value = true;

            % Create OffTGM
            app.OffTGM = uiradiobutton(app.TemporalgeneralizationmatrixButtonGroup);
            app.OffTGM.Text = 'Off';
            app.OffTGM.Position = [89 -2 65 22];

            % Create TimeParametersPanel
            app.TimeParametersPanel = uipanel(app.UIFigure);
            app.TimeParametersPanel.Title = 'Time Parameters ';
            app.TimeParametersPanel.Position = [981 21 224 363];

            % Create SelectTimePointstoDecodeLabel
            app.SelectTimePointstoDecodeLabel = uilabel(app.TimeParametersPanel);
            app.SelectTimePointstoDecodeLabel.Position = [12 318 170 23];
            app.SelectTimePointstoDecodeLabel.Text = 'Select Time-Points to Decode';

            % Create DecodingTimeRangeButtonGroup
            app.DecodingTimeRangeButtonGroup = uibuttongroup(app.TimeParametersPanel);
            app.DecodingTimeRangeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @DecodingTimeRangeButtonGroupSelectionChanged, true);
            app.DecodingTimeRangeButtonGroup.Title = 'Decoding Time Range';
            app.DecodingTimeRangeButtonGroup.Position = [12 192 196 125];

            % Create AllButton
            app.AllButton = uiradiobutton(app.DecodingTimeRangeButtonGroup);
            app.AllButton.Text = 'All';
            app.AllButton.Position = [24 82 35 22];
            app.AllButton.Value = true;

            % Create CustomButton
            app.CustomButton = uiradiobutton(app.DecodingTimeRangeButtonGroup);
            app.CustomButton.Text = 'Custom';
            app.CustomButton.Position = [107 82 64 22];

            % Create PreButton
            app.PreButton = uiradiobutton(app.DecodingTimeRangeButtonGroup);
            app.PreButton.Text = 'Pre';
            app.PreButton.Position = [24 61 40 22];

            % Create PostButton
            app.PostButton = uiradiobutton(app.DecodingTimeRangeButtonGroup);
            app.PostButton.Text = 'Post';
            app.PostButton.Position = [107 61 46 22];

            % Create EpochRange
            app.EpochRange = uieditfield(app.DecodingTimeRangeButtonGroup, 'text');
            app.EpochRange.ValueChangedFcn = createCallbackFcn(app, @EpochRangeValueChanged, true);
            app.EpochRange.HorizontalAlignment = 'center';
            app.EpochRange.Position = [23 32 148 25];

            % Create minmaxinmsLabel
            app.minmaxinmsLabel = uilabel(app.DecodingTimeRangeButtonGroup);
            app.minmaxinmsLabel.Position = [47 10 94 22];
            app.minmaxinmsLabel.Text = '(min, max in ms)';

            % Create DownsampleOptionalCheckBox
            app.DownsampleOptionalCheckBox = uicheckbox(app.TimeParametersPanel);
            app.DownsampleOptionalCheckBox.ValueChangedFcn = createCallbackFcn(app, @DownsampleOptionalCheckBoxValueChanged, true);
            app.DownsampleOptionalCheckBox.Text = 'Downsample (Optional)';
            app.DownsampleOptionalCheckBox.Position = [16 162 147 22];

            % Create SubsamplePanel
            app.SubsamplePanel = uipanel(app.TimeParametersPanel);
            app.SubsamplePanel.Position = [13 2 195 156];

            % Create TimePoint0msisalwaysincludedLabel
            app.TimePoint0msisalwaysincludedLabel = uilabel(app.SubsamplePanel);
            app.TimePoint0msisalwaysincludedLabel.FontSize = 11;
            app.TimePoint0msisalwaysincludedLabel.Position = [3 6 192 42];
            app.TimePoint0msisalwaysincludedLabel.Text = '*Time-Point 0 (ms) is always included ';

            % Create DecodeeveryTmsLabel
            app.DecodeeveryTmsLabel = uilabel(app.SubsamplePanel);
            app.DecodeeveryTmsLabel.HorizontalAlignment = 'center';
            app.DecodeeveryTmsLabel.WordWrap = 'on';
            app.DecodeeveryTmsLabel.Position = [16 105 89 45];
            app.DecodeeveryTmsLabel.Text = 'Decode every         T (ms)';

            % Create TPspinner
            app.TPspinner = uispinner(app.SubsamplePanel);
            app.TPspinner.ValueChangedFcn = createCallbackFcn(app, @TPspinnerValueChanged, true);
            app.TPspinner.Position = [114 119 55 22];

            % Create EffectiveSamplingRateHzEditFieldLabel
            app.EffectiveSamplingRateHzEditFieldLabel = uilabel(app.SubsamplePanel);
            app.EffectiveSamplingRateHzEditFieldLabel.HorizontalAlignment = 'center';
            app.EffectiveSamplingRateHzEditFieldLabel.WordWrap = 'on';
            app.EffectiveSamplingRateHzEditFieldLabel.Position = [23 59 76 42];
            app.EffectiveSamplingRateHzEditFieldLabel.Text = 'Effective Sampling Rate (Hz)';

            % Create EffectiveSamplingRateHzEditField
            app.EffectiveSamplingRateHzEditField = uieditfield(app.SubsamplePanel, 'numeric');
            app.EffectiveSamplingRateHzEditField.BackgroundColor = [0.651 0.651 0.651];
            app.EffectiveSamplingRateHzEditField.Position = [114 73 55 20];

            % Create StartDecodingButton
            app.StartDecodingButton = uibutton(app.UIFigure, 'push');
            app.StartDecodingButton.ButtonPushedFcn = createCallbackFcn(app, @StartDecodingButtonPushed, true);
            app.StartDecodingButton.Position = [842 16 116 22];
            app.StartDecodingButton.Text = 'Start Decoding';

            % Create ParallelizationButtonGroup
            app.ParallelizationButtonGroup = uibuttongroup(app.UIFigure);
            app.ParallelizationButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ParallelizationButtonGroupSelectionChanged, true);
            app.ParallelizationButtonGroup.Title = 'Parallelization';
            app.ParallelizationButtonGroup.Position = [20 17 697 77];

            % Create YesButton
            app.YesButton = uiradiobutton(app.ParallelizationButtonGroup);
            app.YesButton.Text = 'Yes';
            app.YesButton.Position = [31 31 41 22];
            app.YesButton.Value = true;

            % Create NoButton
            app.NoButton = uiradiobutton(app.ParallelizationButtonGroup);
            app.NoButton.Text = 'No';
            app.NoButton.Position = [31 10 38 22];

            % Create ParText
            app.ParText = uilabel(app.ParallelizationButtonGroup);
            app.ParText.WordWrap = 'on';
            app.ParText.Position = [108 10 553 43];
            app.ParText.Text = '*If yes, ERPLAB will attempt to speed up the decoding process across all (except one) available CPU cores. This feature requires that the "Parallel Computing Toolbox" is installed in MATLAB.';

            % Create loadBESTRadioGroup
            app.loadBESTRadioGroup = uibuttongroup(app.UIFigure);
            app.loadBESTRadioGroup.SelectionChangedFcn = createCallbackFcn(app, @loadBESTRadioGroupSelectionChanged, true);
            app.loadBESTRadioGroup.Title = 'Choose BESTsets to decode';
            app.loadBESTRadioGroup.Position = [20 573 535 62];

            % Create CurrentBESTsetButton
            app.CurrentBESTsetButton = uiradiobutton(app.loadBESTRadioGroup);
            app.CurrentBESTsetButton.Text = 'Current BESTset';
            app.CurrentBESTsetButton.Position = [11 11 110 22];
            app.CurrentBESTsetButton.Value = true;

            % Create FromBESTsetMenuButton
            app.FromBESTsetMenuButton = uiradiobutton(app.loadBESTRadioGroup);
            app.FromBESTsetMenuButton.Text = 'From BESTset Menu';
            app.FromBESTsetMenuButton.Position = [194 11 132 22];

            % Create bestmenu
            app.bestmenu = uieditfield(app.loadBESTRadioGroup, 'text');
            app.bestmenu.ValueChangedFcn = createCallbackFcn(app, @bestmenuValueChanged, true);
            app.bestmenu.Position = [338 11 169 22];

            % Create Label_BG2
            app.Label_BG2 = uilabel(app.UIFigure);
            app.Label_BG2.Tag = 'Label_BG2';
            app.Label_BG2.WordWrap = 'on';
            app.Label_BG2.Position = [595 573 122 62];
            app.Label_BG2.Text = 'Note: BESTsets must have the same number of bins and channels';

            % Create DecodingAlgorithmOptionsPanel
            app.DecodingAlgorithmOptionsPanel = uipanel(app.UIFigure);
            app.DecodingAlgorithmOptionsPanel.Title = 'Decoding Algorithm Options';
            app.DecodingAlgorithmOptionsPanel.Position = [981 397 224 238];

            % Create MethodButtonGroup
            app.MethodButtonGroup = uibuttongroup(app.DecodingAlgorithmOptionsPanel);
            app.MethodButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MethodButtonGroupSelectionChanged, true);
            app.MethodButtonGroup.Title = 'Method';
            app.MethodButtonGroup.Position = [12 78 197 127];

            % Create SVMButton
            app.SVMButton = uiradiobutton(app.MethodButtonGroup);
            app.SVMButton.Text = 'SVM';
            app.SVMButton.Position = [13 55 48 22];
            app.SVMButton.Value = true;

            % Create CrossnobisButton
            app.CrossnobisButton = uiradiobutton(app.MethodButtonGroup);
            app.CrossnobisButton.Text = 'Crossvalidated Mahalanobis';
            app.CrossnobisButton.Position = [13 4 174 22];

            % Create AlgorithmLabel
            app.AlgorithmLabel = uilabel(app.MethodButtonGroup);
            app.AlgorithmLabel.Position = [14 79 60 23];
            app.AlgorithmLabel.Text = 'Algorithm';

            % Create RegularizationLabel
            app.RegularizationLabel = uilabel(app.MethodButtonGroup);
            app.RegularizationLabel.Position = [100 79 86 23];
            app.RegularizationLabel.Text = 'Regularization';

            % Create LDAButton
            app.LDAButton = uiradiobutton(app.MethodButtonGroup);
            app.LDAButton.Text = 'LDA';
            app.LDAButton.Position = [13 29 45 22];

            % Create SVM_regularization_edit
            app.SVM_regularization_edit = uieditfield(app.MethodButtonGroup, 'text');
            app.SVM_regularization_edit.ValueChangedFcn = createCallbackFcn(app, @f_SVM_regularization, true);
            app.SVM_regularization_edit.HorizontalAlignment = 'center';
            app.SVM_regularization_edit.Position = [99 56 77 20];
            app.SVM_regularization_edit.Value = '0';

            % Create LDA_regularization_edit
            app.LDA_regularization_edit = uieditfield(app.MethodButtonGroup, 'text');
            app.LDA_regularization_edit.ValueChangedFcn = createCallbackFcn(app, @f_LDA_regularization, true);
            app.LDA_regularization_edit.HorizontalAlignment = 'center';
            app.LDA_regularization_edit.Position = [99 31 77 20];

            % Create CodingSVMOnlyButtonGroup
            app.CodingSVMOnlyButtonGroup = uibuttongroup(app.DecodingAlgorithmOptionsPanel);
            app.CodingSVMOnlyButtonGroup.Title = 'Coding (SVM Only)';
            app.CodingSVMOnlyButtonGroup.Position = [12 5 197 56];

            % Create OnevsAllButton
            app.OnevsAllButton = uiradiobutton(app.CodingSVMOnlyButtonGroup);
            app.OnevsAllButton.Text = 'One vs All';
            app.OnevsAllButton.Position = [11 4 76 22];
            app.OnevsAllButton.Value = true;

            % Create OnevsOneButton
            app.OnevsOneButton = uiradiobutton(app.CodingSVMOnlyButtonGroup);
            app.OnevsOneButton.Text = 'One vs One';
            app.OnevsOneButton.Position = [98 4 85 22];

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.Position = [742 15 62 24];
            app.HelpButton.Text = '?';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = decodingGUI(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
