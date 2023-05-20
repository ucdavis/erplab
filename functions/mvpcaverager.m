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
            msgboxText =  sprintf('MVPCsets #%g and #%g have different number of points!', j-1, j);
            title = 'ERPLAB: pop_gaverager() Error';
            errorfound(msgboxText, title);
            serror = 1;
            break
        end
        
        if warnon == 1
            % basic test for number of channels (for now...)
            if  pre_nchan ~= size(MVPCT.electrodes,2)
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of channels!', j-1, j);
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %serror = 1;
                %break
            end
            
            
            
            % basic test for number of bins (for now...)
            if pre_nClasses  ~= MVPCT.nClasses
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of classes!', j-1, j);
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %return
                %serror = 1;
                %break
            end
            
            if pre_nIter  ~= MVPCT.nIter
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of Iterations!', j-1, j);
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %return
                %serror = 1;
                %break
            end
            
            if pre_nCrossfolds  ~= MVPCT.nCrossfolds
                msgwrng =  sprintf('MVPCsets #%g and #%g have different number of Iterations!', j-1, j);
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %title = 'ERPLAB: pop_gaverager() Error';
                %errorfound(msgboxText, title);
                %return
                %serror = 1;
                %break
            end
            
            
            
            % basic test for data type (for now...)
            if ~strcmpi(pre_dtype, MVPCT.DecodingMethod)
                msgwrng =  sprintf('MVPCsets #%g and #%g have different type of data (see ERP.datatype)', j-1, j);
                cprintf([1 0.52 0.2], '%s\n\n', msgwrng);
                %errorfound(msgboxText, title);
                %return
%                 serror = 1;
%                 break
            end
            
            
        end
        
    end
    



    pre_nchan  = size(MVPCT.electrodes,2);
    pre_pnts   = MVPCT.pnts;
    pre_nCrossfolds = MVPCT.nCrossfolds; 
    pre_nClasses   = MVPCT.nClasses;
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
        MVPC.electrodes      = MVPCT.electrodes;
        MVPC.chanlocs   = MVPCT.chanlocs; 
        MVPC.nClasses       = MVPCT.nClasses;
        MVPC.nChance    = MVPCT.nChance;
        MVPC.classlabels = MVPCT.classlabels; 
        MVPC.nIter      = MVPCT.nIter;
        MVPC.nCrossfolds = MVPCT.nCrossfolds;  
        MVPC.nSampling  = MVPCT.nSampling;
        MVPC.pnts       = MVPCT.pnts;
        MVPC.SVM.OneVsOne      = MVPCT.SVM.OneVsOne;
        MVPC.SVM.OneVsAll       = MVPCT.SVM.OneVsAll;
        MVPC.DecodingUnit       = MVPCT.DecodingUnit;
        MVPC.DecodingMethod     = MVPCT.DecodingMethod;
        MVPC.average_status   = 'grandaverage'; 
        MVPC.equalTrials   = 'grandavg'; %%%%%%%%%%%%%%%%%%%%%%%
        MVPC.n_trials_per_class    = 'grandavg'; %%%%%%%%%%%%%%%%
        MVPC.saved = 'no'; 
        MVPC.epoch          = MVPCT.epoch;
        MVPC.times          = MVPCT.times;
        MVPC.mvpc_version    = MVPCT.mvpc_version;
        MVPC.SVMinfo        = 'grandavg'; 
        MVPC.raw_predictions = 'grandavg'; 
        MVPC.average_accuracy_1vAll = []; 
        

%         EVEL           = ERPT.EVENTLIST;
%         ALLEVENTLIST(1:length(EVEL)) = EVEL;
    else
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