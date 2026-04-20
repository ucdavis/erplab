function [MVPC, serror, msgboxText] = mvpcaverager(ALLMVPC, lista, optioni, mvpcset, nfile, stderror,warnon)
%Only averages  across decoding accuracy per subject (SVM 1vall).
%Does not yet average across SMV (1v1) and Crossnobis Distance.

serror = 0 ;
msgboxText = '';

%Reads in the correct ALLMVPC set
ds = 1;
for j = 1:nfile

    if optioni==1
        fprintf('Loading %s...\n', lista{j});
        MVPCX = load(lista{j}, '-mat');
        MVPCT  = MVPCX.MVPC;
    else
        MVPCT = ALLMVPC(mvpcset(j));
    end

    if j>1

        % basic test for number of points
        if pre_pnts  ~= MVPCT.pnts
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of points!', mvpcset(j-1), mvpcset(j));
            title = 'ERPLAB: pop_gaverager() Error';
            errorfound(msgboxText, title);
            serror = 1;
            break
        end

        % basic test for data type (for now...)
        if ~strcmpi(pre_dtype, MVPCT.DecodingMethod)
            msgwrng =  sprintf('MVPCsets #%g and #%g have different decoding methods of data (see ALLMVPC.DecodingMethod)', j-1, j);
            cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            %                 serror = 1;
            %                 break
        end



        if ~strcmpi(pre_DecodingUnit, MVPCT.DecodingUnit)%%GH Sep 2025
            msgwrng =  sprintf('MVPCsets #%g and #%g have different Decoding Units (see ALLMVPC.DecodingUnit)', j-1, j);
            cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            %                 serror = 1;
            %                 break
        end


        if ~strcmpi(Pre_equalTrials, MVPCT.equalTrials)%%GH Sep 2025
            msgwrng =  sprintf('MVPCsets #%g and #%g have different equalTrials methods (see ALLMVPC.equalTrials)', j-1, j);
            cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %errorfound(msgboxText, title);
            %return
            %                 serror = 1;
            %                 break
        end

        if warnon == 1
            % basic test for number of channels (for now...)
            if  pre_nchan ~= size(MVPCT.electrodes,2)
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of channels!', mvpcset(j-1), mvpcset(j));
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);

                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %serror = 1;
                %break
            end



            % basic test for number of bins (for now...)
            if pre_nClasses  ~= MVPCT.nClasses
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of classes!', mvpcset(j-1), mvpcset(j));
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %return
                %serror = 1;
                %break
            end

            if pre_nIter  ~= MVPCT.nIter
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of Iterations!', mvpcset(j-1), mvpcset(j));
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %return
                %serror = 1;
                %break
            end

            if pre_nCrossfolds  ~= MVPCT.nCrossfolds
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of Iterations!', mvpcset(j-1), mvpcset(j));
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %return
                %serror = 1;
                %break
            end


            %
            % % basic test for data type (for now...)
            % if ~strcmpi(pre_dtype, MVPCT.DecodingMethod)
            %     msgwrng =  sprintf('MVPCsets #%g and #%g have different decoding methods of data (see ALLMVPC.DecodingMethod)', j-1, j);
            %     cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %     %errorfound(msgboxText, title);
            %     %return
            %     %                 serror = 1;
            %     %                 break
            % end
            %
            %
            %
            % if ~strcmpi(pre_DecodingUnit, MVPCT.DecodingUnit)%%GH Sep 2025
            %     msgwrng =  sprintf('MVPCsets #%g and #%g have different Decoding Units (see ALLMVPC.DecodingUnit)', j-1, j);
            %     cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %     %errorfound(msgboxText, title);
            %     %return
            %     %                 serror = 1;
            %     %                 break
            % end
            %
            %
            % if ~strcmpi(Pre_equalTrials, MVPCT.equalTrials)%%GH Sep 2025
            %     msgwrng =  sprintf('MVPCsets #%g and #%g have different equalTrials methods (see ALLMVPC.equalTrials)', j-1, j);
            %     cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
            %     %errorfound(msgboxText, title);
            %     %return
            %     %                 serror = 1;
            %     %                 break
            % end


        end

    end




    pre_nchan  = size(MVPCT.electrodes,2);
    pre_pnts   = MVPCT.pnts;
    pre_nCrossfolds = MVPCT.nCrossfolds;
    pre_nClasses   = MVPCT.nClasses;
    pre_nIter   = MVPCT.nIter;
    pre_dtype  = MVPCT.DecodingMethod;
    pre_DecodingUnit= MVPCT.DecodingUnit;%%
    Pre_equalTrials = MVPCT.equalTrials;
    %
    % Preparing MVPC struct (first MVPC)
    %
    if ds==1
        %         workfileArray    = ERPT.workfiles;
        %         [nch, npnts, nbin] = size(ERPT.bindata);
        sumMVPC           = zeros(1,MVPCT.pnts);
        sumMVPC_TGM     = zeros(MVPCT.pnts,MVPCT.pnts);%%GH Jan 2026
        % sumMVPC_spaweight = zeros(MVPCT.pnts,pre_nchan);%%GH Mar 2026
        if stderror
            sumMVPC2  = zeros(nfile,MVPCT.pnts);
        end
        sumCFs           =zeros(MVPCT.nClasses,MVPCT.nClasses,MVPCT.pnts);
        %         naccepted      = zeros(1,nbin);
        %         auxnaccepted   = zeros(1,nbin); % ###
        %         nrejected      = zeros(1,nbin);
        %         ninvalid       = zeros(1,nbin);
        %         narflags       = zeros(nbin,8);
        % ERPset
        MVPC.mvpcname    = [];
        MVPC.filename   = [];
        MVPC.filepath   = [];
        MVPC.electrodes      = MVPCT.electrodes;
        MVPC.chanlocs   = MVPCT.chanlocs;
        MVPC.nClasses       = MVPCT.nClasses;
        MVPC.chance    = MVPCT.chance;
        MVPC.classlabels = MVPCT.classlabels;
        MVPC.nIter      = MVPCT.nIter;
        MVPC.nCrossfolds = MVPCT.nCrossfolds;
        MVPC.srate  = MVPCT.srate;
        MVPC.pnts       = MVPCT.pnts;
        MVPC.classcoding.OneVsOne      = MVPCT.classcoding.OneVsOne;
        MVPC.classcoding.OneVsAll       = MVPCT.classcoding.OneVsAll;
        MVPC.DecodingUnit       = MVPCT.DecodingUnit;
        MVPC.DecodingMethod     = MVPCT.DecodingMethod;
        MVPC.average_status   = 'grandaverage';
        MVPC.equalTrials   = 'grandavg'; %%%%%%%%%%%%%%%%%%%%%%%
        MVPC.n_trials_per_class    = 'grandavg'; %%%%%%%%%%%%%%%%
        MVPC.saved = 'no';
        MVPC.epoch          = MVPCT.epoch;
        MVPC.times          = MVPCT.times;
        MVPC.mvpc_version    = MVPCT.mvpc_version;
        MVPC.details        = 'grandavg';
        % MVPC.details.info= 'grandavg';%%GH Jan 2026
        % MVPC.details.n_trials_per_erp= 'grandavg';%%GH Jan 2026
        % MVPC.details.regularization= 'grandavg';%%GH Jan 2026
        % MVPC.details.normalization= 'grandavg';%%GH Jan 2026

        MVPC.raw_predictions = 'grandavg';
        MVPC.average_score = [];
        MVPC.confusions.scores = [];
        MVPC.confusions.labels = MVPCT.confusions.labels;

        MVPC.AvgPerClass = 'grandavg';%%GH Sep 2025
        MVPC.TGM = [];%%GH Dec. 2025
        % MVPC.regularization = [];%%GH Oct 2025
        %         EVEL           = ERPT.EVENTLIST;
        %         ALLEVENTLIST(1:length(EVEL)) = EVEL;
    else
        %         EVEL =  ERPT.EVENTLIST;
        %         ALLEVENTLIST(end+1:end+length(EVEL)) = EVEL;
    end

    sumMVPC    = sumMVPC + MVPCT.average_score;                % cumulative sum: Sum(xi)
    sumCFs     = sumCFs  + MVPCT.confusions.scores;
    if ~isempty(MVPCT.TGM) %%GH Jan 2026
        sumMVPC_TGM = sumMVPC_TGM+MVPCT.TGM;
    else
        sumMVPC_TGM = zeros(MVPCT.pnts,MVPCT.pnts);
    end

    %  if ~isempty(MVPCT.details.BetaWeightsRaw) %%GH Jan 2026
    %     sumMVPC_spaweight = sumMVPC_spaweight+MVPCT.details.BetaWeightsRaw;
    % else
    %     sumMVPC_spaweight = zeros(MVPCT.pnts,pre_nchan);
    %  end


    if stderror
        sumMVPC2(j,:) = MVPCT.average_score;

    end

    ds = ds+1; % counter for clean MVPCsets (keep it that way until Steve might eventually decide to reject subjects automatically...)


end

%get average across MVPCsets
MVPC.average_score = sumMVPC/nfile;
MVPC.confusions.scores = sumCFs/nfile;
MVPC.TGM = sumMVPC_TGM/nfile;
% MVPC.details.BetaWeightsRaw = sumMVPC_spaweight/nfile;
if stderror
    MVPC.stderror = squeeze(std(sumMVPC2,1))/sqrt(nfile);
end

end