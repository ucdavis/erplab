function [MVPC, serror, msgboxText] = mvpcaverager(ALLMVPC, lista, optioni, mvpcset, nfile, stderror)

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
        % basic test for number of channels (for now...)
        if  pre_nchan ~= size(MVPCT.electrodes,2); 
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of channels!', j-1, j);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            serror = 1;
            break
        end
        % basic test for number of points (for now...)
        if pre_pnts  ~= MVPCT.pnts
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of points!', j-1, j);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end
        % basic test for number of bins (for now...)
        if pre_nClasses  ~= MVPCT.nClasses
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of bins!', j-1, j);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end

        if pre_nIter  ~= MVPCT.nIter
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of Iterations!', j-1, j);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end

        if pre_nCrossfolds  ~= MVPCT.nCrossfolds
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of Iterations!', j-1, j);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end



        % basic test for data type (for now...)
        if ~strcmpi(pre_dtype, MVPCT.DecodingMethod)
            msgboxText =  sprintf('MVPCsets #%g and #%g have different type of data (see ERP.datatype)', j-1, j);
            %title = 'ERPLAB: pop_gaverager() Error';
            %errorfound(msgboxText, title);
            %return
            serror = 1;
            break
        end
    end


    pre_nchan  = size(MVPCT.electrodes,2);
    pre_pnts   = MVPCT.pnts;
    pre_nClasses   = MVPCT.nClasses;
    pre_nCrossfolds = MVPCT.nCrossfolds; 
    pre_nIter   = MVPCT.nIter; 
    pre_dtype  = MVPCT.DecodingMethod;
   %
    % Preparing MVPC struct (first MVPC)
    %
    if ds==1
%         workfileArray    = ERPT.workfiles;
%         [nch, npnts, nbin] = size(ERPT.bindata);
         sumMVPC           = zeros(1,MVPCT.pnts);
        if stderror
            sumMVPC2  = zeros(nfile,MVPCT.pnts);
        end
%         naccepted      = zeros(1,nbin);
%         auxnaccepted   = zeros(1,nbin); % ###
%         nrejected      = zeros(1,nbin);
%         ninvalid       = zeros(1,nbin);
%         narflags       = zeros(nbin,8);
        % ERPset
        MVPC.mvpcname    = [];
        MVPC.filename   = [];
        MVPC.filepath   = [];
        MVPC.mvpc_version    = MVPCT.mvpc_version;
        MVPC.electrodes      = MVPCT.electrodes;
        MVPC.nClasses       = MVPCT.nClasses;
        MVPC.nIter      = MVPCT.nIter;
        MVPC.nCrossfolds = MVPCT.nCrossfolds;
        MVPC.nChance    = MVPCT.nChance; 
        MVPC.nSampling  = MVPCT.nSampling;
        MVPC.pnts       = MVPCT.pnts;
        MVPC.OneVsOne      = MVPCT.OneVsOne;
        MVPC.OneVsAll       = MVPCT.OneVsAll;
        MVPC.DecodingAccuracy       = MVPCT.DecodingAccuracy;
        MVPC.DecodingMethod     = MVPCT.DecodingMethod;
        MVPC.DecodingDistance = MVPCT.DecodingDistance; 
        MVPC.grandaverage   = 'yes'; 
        MVPC.window         = MVPCT.window;
        MVPC.equalTrials   = 'grandavg';
        MVPC.n_trials_per_bin    = 'grandavg';
        MVPC.epoch          = MVPCT.epoch;
        MVPC.times          = MVPCT.times; 
        MVPC.SVMinfo        = 'grandavg'; 
        MVPC.raw_predictions = 'grandavg'; 
        MVPC.average_accuracy_1vAll = []; 
        MVPC.saved = 'no'; 
%         MVPC.binerror   = [];
%         
%         MVPC.datatype   = ERPT.datatype;
%         
%         MVPC.chanlocs   = ERPT.chanlocs;
%         MVPC.ref        = ERPT.ref;
%         MVPC.bindescr   = ERPT.bindescr;
%         MVPC.history    = ERPT.history;
%         MVPC.saved      = ERPT.saved;
%         MVPC.isfilt     = ERPT.isfilt;
%         MVPC.version    = ERPT.version;
%         MVPC.splinefile = ERPT.splinefile;
%         EVEL           = ERPT.EVENTLIST;
%         ALLEVENTLIST(1:length(EVEL)) = EVEL;
    else
%         workfileArray = [workfileArray ERPT.workfiles];
%         EVEL =  ERPT.EVENTLIST;
%         ALLEVENTLIST(end+1:end+length(EVEL)) = EVEL;
    end

    sumMVPC    = sumMVPC + MVPCT.average_accuracy_1vAll;                % cumulative sum: Sum(xi)
    
    if stderror 
        sumMVPC2(j,:) = MVPCT.average_accuracy_1vAll; 

    end

    ds = ds+1; % counter for clean MVPCsets (keep it that way until Steve might eventually decide to reject subjects automatically...)


end

%get average across MVPCsets
MVPC.average_accuracy_1vAll = sumMVPC/nfile;
if stderror
    MVPC.stderror = squeeze(std(sumMVPC2,1))/sqrt(nfile);
end

end