% PURPOSE  : Decode BEST files after setting parameters. 
%
% FORMAT   :
%
% >> MVPC = pop_decoding(ALLBEST)
%
% INPUTS   :
%
% BEST or ALLBEST       - input dataset (BESTset) or input ALLBEST (via
%                           decoding toolbox GUI)
%
% The available parameters are as follows:
%
%        'BESTindex' 	- Index of BESTset(s) to decode when contained
%                         within the ALLBEST structure
%                         If supplying one BESTset using BEST structure this value
%                         must be equal to 1 or left unspecified.
%                         Def: [1]
%
%        'Classes '     - Index array of classes to decode across.
%                       Classes are defined as the index of the bins
%                       contained within the BESTset prior to decoding. 
%
%        'Channels'     - Index of channels to use. Def: all channels
%
%        'nIter'        - Amount of iterations to run decoding per BESTset.
%                         Def: 100 
%
%        'nCrossblocks' - Amount of Crossfold Validation blocks where
%                         Ntrials/nCrossblocks = Ntrials(ERP) / Def: 3
%
%        'DecodeTimes' 	- 2-element array denoting epoch start and end times
%                         e.g.: [start_epoch_decoding end_epoch_decoding]
%                         Default: use whole epoch length. 
%
%        'Decode_Every_Npoint' -  Decode every timepoint (T) points where 1 point =
%                                 1/sampling rate (in ms). Effectively resampling
%                                 the decoding analysis. For example, a
%                                 value of 1 decodes every timepoint. 
%                           Def: [1] 
%
%        'EqualizeTrials'  - (Optional) Equalizing the amount of trials per ERP.
%                            - 'classes': Across classes within BESTset
%                            - 'best': Across BESTsets (if more than 1 BESTset)
%                            - 'floor': Using Common Floor Value 
%                           
%        'FloorValue'   - (Optional) Equalize amount of trials per ERP across all
%                           classes (and BESTsets) to this value. If
%                           specified, overides the 'EqualizeTrials'
%                           argument. 
%                          
%                      
%        'Method'       - Classification method:
%                          - 'SVM' (default) using fitcecoc()
%                               - if BESTset has only two classes/binary,
%                                    algorithm uses fitcsvm()
%                          - 'Crossnobis'
%
%        'classcoding'    - If classification method is 'SVM':
%                         - 'OneVsOne' 
%                         - 'OneVsAll' (def)
%
%        'SaveAs'        -  (optional) open GUI for saving MVPCset. Not
%                       useful if scripting; use separate pop_savemymvpc(). 
%                           'on'/'off' (Default: off)
%                            (if "off", will not update in MVPCset menu)
%        'ParCompute'    - (optional) Use parallelization to make decoding
%                          faster. Uses as many available cores. Must have 'Parallel
%                          Computing Toolbox' installed. 'on'/'off' (Def)
%
%
% OUTPUTS  :
%
% MVPC           -  output MVPC dataset
%
% EXAMPLE  :
%
%  MVPC = pop_decoding(BEST,'Classes',[1:4],'Channels',[1:27 33:64], 'nIter', 10, 'nCrossblocks',3, ...
%         'DecodeTimes',[-500,1496], 'Decode_Every_Npoint',5,'EqualizeTrials','classes',...
%         'Method','SVM', 'classcoding','OneVsAll', ...
%         'ParCompute','on');
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


function [MVPC] = pop_decoding(ALLBEST, varargin) 
com = ''; 

% check Signal Processing Toolbox (SPT)
if exist('filtfilt','file')~= 2
    msgboxText =  'ERROR: You currently do not have the Signal Processing Toolbox installed. Please contact your system administration or MATLAB to install "Signal Processing Toolbox" to your MATLAB version';
    title = 'ERPLAB: Missing Signal Processing Toolbox';
    errorfound(msgboxText, title);
    return
end

% check Statistics and Machine Learning toolbox
v = ver;
hasSMT = any(strcmp(cellstr(char(v.Name)), 'Statistics and Machine Learning Toolbox'));

if hasSMT ~= 1
    msgboxText =  ['Error: You currently do not have the Statistics and Machine Learning toolbox, an offiical MATLAB toolbox add-on. ...' ...
        'Please contact MATHWORKS or your system admin to install this for your MATLAB version'];
    title = 'ERPLAB: Missing Statistics and Machine Learning Toolbox';
    errorfound(msgboxText, title);
    return
end



try
        ALLMVPC   = evalin('base', 'ALLMVPC');
       % preindex = length(ALLMVPC);
catch
        disp('WARNING: ALLMVPC structure was not found. ERPLAB will create an empty one.')
        ALLMVPC = [];
       % preindex = 0;
end

%preload MVPAC
MVPC = preloadMVPC; 

if nargin<1
    help pop_decoding
    return
end

if nargin == 1 %GUI
    
    if isstruct(ALLBEST) 
        if ~isbeststruct(ALLBEST(1))
            ALLBEST = [];
            %nbinx = 1;
            %nchanx = 1;
        else
            %nbinx = ALLBEST(1).nbin;
            %nchanx = ALLBEST(1).nbchan; 
        end
        
    else
        ALLBEST = []; 
       % nbinx = 1;
       % nchanx = 1; 
    end

    cbesti = evalin('base','CURRENTBEST'); %current BEST index
    
    %working memory
    def = erpworkingmemory('pop_decoding');
    %def = []; %for now, def always empty, always default to "load from hard drive". 
    if isempty(def)
        if isempty(ALLBEST)
            inp1 = 1; %from hard drive
            bestseti = []; %index of bestsets to use
        else
            inp1 = 0; %from bestset menu
            bestseti = 1:length(ALLBEST); 
            
        end
        
        %decodeClassInd = 1:numel(ALLBEST(indexBEST(1)).binwise_data)
        def = {inp1 bestseti [] 100 3 1 [] 1 2 1 1 2 0 []};
      
        %def1 = input mode (1 means from HD, 0 from bestsetmenu, 2 current bestset) 
        %def2 = bestset index (see above)
        %def3 = chanArray
        %def4 = nIter (def = 100)
        %def5 = nCrossBlocks (def = 3)
        %def6 = epochTimes (1:all, 2: pre, 3: post, 4:custom) (Def = 1/all)
        %def7 = decodeTimes ([start,end]; def = []); % IN MS!
        %def8 = decode_every_Npoint (1 = every point)
        %def9 = Equalize Trials (0: don't equalize/ 1:equalize across bins/ 2: eqalize across
        %   bins & best (def)/ 3: Common Floor)
        %def10 = Common  Floor Value (def: 1); 
        %def11 = classifer (1: SVM / 2: Crossnobis - def: SVM)
        %def12 = SVM coding (1: 1vs1 / 2: 1vsAll or empty - def: 1vsALL)
        %def13 = parCompute (def = 0)
        %def14 = DecodeClasses ; 

        %DEFUNCT = output filename (def = filename.mvpa in pwd) *DEFUNCT
        %DEFUNCT = output path (def = cd); *DEFUNCT 
        
       

    else
        %if working memory is NOT empty 
        if ~isempty(ALLBEST)
            if isnumeric(def{2})
                [uu,mm] = unique_bc2(def{2},'first'); 
                bestset_list_sorted = [def{2}(sort(mm))];
                bestset_list = bestset_list_sorted(bestset_list_sorted <= length(ALLBEST));
                if isempty(bestset_list)
                    def{2} = cbesti; %if nothing in list, just go with current
                else
                    def{2} = bestset_list;
                end
            

            
            
            end
        end
        
        
        
    end
    

    %% Call GUI for decoding parameters parameters
    %app = feval('decodingGUI', ALLBEST, filename, filepath, cbesti); %cludgy way
    app = feval('decodingGUI', ALLBEST, def, cbesti); %cludgy way
    waitfor(app,'FinishButton',1);
    try
        decoding_res = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.5); %wait for app to leave
    catch
        disp('User selected Cancel')
        return
    end
    
    %parse arguments
    if isempty(ALLBEST) %if no BESTset was passed to GUI
        ALLBEST = decoding_res{1}; %use the GUI output
        %but if BESTset was passed to GUI, use indexes to index
        %the desired BESTsets
    end 
    inp1 = decoding_res{2}; 
    indexBEST = decoding_res{3};
    relevantChans = decoding_res{4};
    nIter = decoding_res{5};
    nCrossBlocks = decoding_res{6};
    epoch_times = decoding_res{7};
    decodeTimes = decoding_res{8}; %in s
    decode_every_Npoint = decoding_res{9};
    equalizeTrials = decoding_res{10};
    floorValue = decoding_res{11};
    selected_method = decoding_res{12};
    classcoding = decoding_res{13};
%     file_out = decoding_res{13};
%     path_out = decoding_res{14}; 
    ParCompute = decoding_res{14};
    decodeClasses = decoding_res{15}; 
    
    %save in working memory
    %Steve decided that equalize trials should always be defaulted if using
    %the GUI
    
    def = { inp1, indexBEST, relevantChans, nIter, nCrossBlocks, epoch_times, ...
        decodeTimes, decode_every_Npoint, 2, floorValue, ...
        selected_method, classcoding, ParCompute,decodeClasses}; 
    erpworkingmemory('pop_decoding',def); 
    
    %for input into sommersault, change decodeTimes to ms
    decodeTimes = decodeTimes* 1000; 
    
    if equalizeTrials == 1 
        seqtr = 'classes';
        floorValue = [];
        
    elseif equalizeTrials == 2
        seqtr = 'best';
        floorValue = [];
    elseif equalizeTrials == 3
        seqtr = 'floor'; 
        
    else
        seqtr ='none'; 
        floorValue = [];
    end
    
    if selected_method == 1 %svm
        smethod = 'SVM';
        
    elseif selected_method == 2
        smethod = 'Crossnobis'; 
    end
    
    if classcoding == 1
        strcoding = 'OneVsOne';
    elseif classcoding == 2
        strcoding = 'OneVsAll'; 
    else
        strcoding = 'none'; 
    end
    
    if ParCompute
        spar = 'on';
    else
        spar = 'off';
    end
        
    if isempty(decodeClasses)
        %across all classes in BESTset(s)
        decodeClasses = 1:numel(ALLBEST(indexBEST(1)).binwise_data);
    end
        
   
    
   [MVPC] = pop_decoding(ALLBEST,'BESTindex', indexBEST, 'Classes', decodeClasses, ...
       'Channels', relevantChans, ...
       'nIter',nIter,'nCrossblocks',nCrossBlocks,  ...
   'DecodeTimes', decodeTimes, 'Decode_Every_Npoint',decode_every_Npoint,  ...
   'EqualizeTrials', seqtr, 'FloorValue',floorValue,'Method', smethod, ...
   'classcoding',strcoding, 'Saveas','on', 'ParCompute',spar, 'History','gui'); 

    pause(0.1);
    return



end
    
%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLBEST');

% option(s)
p.addParamValue('BESTindex', 1,@isnumeric); % erpset index or input file (default: first BESTset in ALLBEST)
p.addParamValue('Classes',[],@isnumeric); 
p.addParamValue('Channels',[], @isnumeric); %array of channel indicies (def: all channels)
%p.addParamValue('nBins',0); %total number of bins/decoding labels/decoding levels
p.addParamValue('nIter',100, @isnumeric); % total number of decoding iterations (def: 100 iters)
p.addParamValue('nCrossblocks',3, @isnumeric); % total number of crossblock validations (def: 3 crossblocks)
%p.addParamValue('nDatatimes',[]); %struct with fields pre(start),post(end) epoch times (def: entire epoch)
%p.addParamValue('SampleTimes',[]); %array of epoch sampling times in ms, i.e. EEG.times (def: all times)
p.addParamValue('DecodeTimes',[],@isnumeric); %[start end](in ms)
p.addParamValue('Decode_Every_Npoint',1, @isnumeric); %(def = all times(1) // must be positive number )
p.addParamValue('EqualizeTrials', 'none', @ischar); % def: equalize trials across bins & BESTsets (2)
p.addParamValue('FloorValue', [], @isnumeric); 
p.addParamValue('Method','SVM',@ischar); %method (1:SVM/2:Crossnobis);
p.addParamValue('classcoding','OneVsAll',@ischar); % SVMcoding(1:oneVsone/2:oneVsall); 
p.addParamValue('Saveas','off',@ischar); 
p.addParamValue('ParCompute','off', @ischar); %attempt parallization across CPU cores (def: false)
p.addParamValue('History','script'); 

% Parsing
p.parse(ALLBEST, varargin{:});
idx_bestset = p.Results.BESTindex;
decodeClasses = p.Results.Classes; 
chanArray = p.Results.Channels;
nIter = p.Results.nIter;
nCrossblocks = p.Results.nCrossblocks;
decodeTimes = p.Results.DecodeTimes; 
Decode_every_Npoint = p.Results.Decode_Every_Npoint; 
equalize_trials = p.Results.EqualizeTrials;
floor_value = p.Results.FloorValue; 
smethod = p.Results.Method; 
strcoding = p.Results.classcoding;
% filename_out = p.Results.filename_out; 
% pathname_out = p.Results.path_out; 
sParCompute = p.Results.ParCompute; 


%if user is scripting command
if isempty(decodeClasses) 
    decodeClasses = 1:numel(ALLBEST(idx_bestset(1)).binwise_data);  
end

%history
if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end

%parallelization
if strcmpi(sParCompute, 'on') || strcmpi(sParCompute,'yes')
    ParCompute = 1; 
else
    ParCompute = 0;
end
    
    


%% choose BESTsets
if ~isempty(idx_bestset)  
    ALLBEST = ALLBEST(idx_bestset) ; 
else
    ALLBEST = ALLBEST(1); %just do the first one 
end


%% Check ALLBEST
checking = checkmultiBEST(ALLBEST);

if ~checking
    disp('Sorry, your BEST files do not agree with each other in terms of classes and channels')
    return
end

if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
end

% Save routine only for Decoding Toolbox GUI
if issaveas == 1
       [res] = mvpc_save_multi_file(ALLBEST,1:numel(ALLBEST),''); 
%             
            if isempty(res)
                disp('User selected cancel'); 
                return
            end

          ALLBEST = res{1};
         % file_out = {ALLBEST.filename}; 
         % file_path = {ALLBEST.filepath}; 
         
         %after using the save multple files, 
         %don't automaticaly assume they want to save

end



%create/update the times field in each BESTset 

% use the specificed [start,end] epoch variable (which need to be
% specified)
% test requirement that 0 time-sample point must be included! 

if Decode_every_Npoint < 1
    msgText = 'Must specify a positive value > 1 for decoding every Nth point'
    title = 'ERPLAB: Wrong Value for Decoding every Nth point'
    errorfound(msgText,title); 
    return  
end

original_times = ALLBEST(1).times; %take first BESTset as standard
if isempty(decodeTimes)
    
    decodeTimes = [ALLBEST(1).xmin*1000 ALLBEST(1).xmax*1000]; %convert s to ms
    
end

fs = ALLBEST(1).srate; 
[xp1, xp2, checkw] = window2sample(ALLBEST(1), decodeTimes(1:2) , fs, 'relaxed');

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


start_epoch = decodeTimes(1); %ms 
end_epoch = decodeTimes(2);%ms  


%check valid times and round to nearest time
[startms,ind_start,latdiffms(1)] = closest(original_times,start_epoch); 
[endms,ind_end,latdiffms(2)] = closest(original_times,end_epoch); 

tm_zero = find(original_times== 0); %always include tm point = 0ms
tm_zero_to_begin= (tm_zero:-Decode_every_Npoint:ind_start);
tm_zero_to_end = (tm_zero:Decode_every_Npoint:ind_end);
decoding_times_index = sort(unique_bc2([tm_zero_to_begin tm_zero_to_end]));

[~,decode_begin] = closest(decoding_times_index,ind_start);
[~,decode_end] = closest(decoding_times_index,ind_end);

%update to user defined times (but also includes 0ms in
%sampling)
decoding_times_index = decoding_times_index(decode_begin:decode_end);

if ms2sample(latdiffms(1),fs)~=0 %JLC.10/16/2013
    latency(1) = start_epoch;
    fprintf('\n%s\n', repmat('*',1,60));
    fprintf('WARNING: Lower latency limit %.3f ms was adjusted to %.3f ms \n', latency(1), original_times(decoding_times_index(1)));
    fprintf('WARNING: This adjustment was necessary due to sampling \n'); 
    fprintf('%s\n\n', repmat('*',1,60));
    
    start_epoch = original_times(decoding_times_index(1)); 
    

end

if ms2sample(latdiffms(2),fs)~=0 %JLC.10/16/2013
    latency(2) = end_epoch;
    fprintf('\n%s\n', repmat('*',1,60));
    fprintf('WARNING: Upper latency limit %.3f ms was adjusted to %.3f ms \n', latency(2), original_times(decoding_times_index(end)));
    fprintf('WARNING: This adjustment was necessary due to sampling \n'); 
    fprintf('%s\n\n', repmat('*',1,60));
    end_epoch = original_times(decoding_times_index(end)); 
      
end

if (start_epoch ~= original_times(decoding_times_index(1))) | ...
        (end_epoch ~= original_times(decoding_times_index(end)))
     fprintf('\n%s\n', repmat('*',1,60));
    fprintf('WARNING: Lower latency limit %.3f ms was adjusted to %.3f ms \n', start_epoch, original_times(decoding_times_index(1)));
    fprintf('WARNING: Upper latency limit %.3f ms was adjusted to %.3f ms \n', end_epoch, original_times(decoding_times_index(end)));
    fprintf('WARNING: This adjustment was necessary due to sampling.  \n'); 
    fprintf('%s\n\n', repmat('*',1,60));
end


decodeTimes = [original_times(decoding_times_index(1)) original_times(decoding_times_index(end))];

%decode_index = decoding_times_index; 
ntimes = numel(decoding_times_index); 



%% update ALLBEST.times & ALLBEST.binwisedata, ALLBEST.pnts, 

k = numel(ALLBEST);
bins = numel(ALLBEST(1).binwise_data);
for b = 1:k
    ALLBEST(b).xmin = decodeTimes(1)/1000;
    ALLBEST(b).xmax = decodeTimes(2)/1000;
    npnts_old = ALLBEST(b).pnts; 
    ALLBEST(b).pnts = ntimes;
    ALLBEST(b).times = original_times(decoding_times_index);
    if Decode_every_Npoint ~= 1
        %update fs if not decoding every timepoint
        fs = ALLBEST(b).srate;
        samps = 1/fs;
        epochtime = (samps*npnts_old) *1000;% ms
        new_fs = (ntimes/epochtime) *1000;
        ALLBEST(b).srate = new_fs;
    end
    
    for i = 1:bins
        ALLBEST(b).binwise_data(i).data = ALLBEST(b).binwise_data(i).data(:,decoding_times_index,:);
    end
    
    
    %% logic for choosing the classes and chance prior to equalizing trials
    

    %select chosen classes
    ALLBEST(b).binwise_data = ALLBEST(b).binwise_data(decodeClasses);
    ALLBEST(b).bindesc = ALLBEST(b).bindesc(decodeClasses);
    ALLBEST(b).original_bin = ALLBEST(b).original_bin(decodeClasses);
    ALLBEST(b).n_trials_per_bin = ALLBEST(b).n_trials_per_bin(decodeClasses);
    ALLBEST(b).nbin = numel(decodeClasses);

    
end




%% reset the trial counts according to nperbinblock/Equalize Trials

nbins = ALLBEST.nbin; 
nsubs = numel(ALLBEST); 

if ~isempty(floor_value)
    %in case user only supplies the floor value
    % we will assume they meant to floor 
    equalize_trials = 'floor';
end

if nsubs == 1 && strcmpi(equalize_trials,'best')
    %cannot equalize trials across BESTset if only one BESTset
    equalize_trials = 'classes'; 
end

if strcmpi(equalize_trials,'best') % equalize across best files 
    
    trials_acr_best = [ALLBEST(:).n_trials_per_bin]; 
    minCnt = min(trials_acr_best); 
   %nPerBinBlock = floor(minCnt/nCrossblocks); 
   
   for s = 1:nsubs
       for tr = 1:nbins
           ALLBEST(s).n_trials_per_bin(tr) = minCnt;
       end
   end
    
   
elseif strcmpi(equalize_trials,'classes') %equalize bins within best files
    
    for s = 1:nsubs
        trials_acr_sub = ALLBEST(s).n_trials_per_bin;
        minCnt = min(trials_acr_sub);
        
        for tr = 1:nbins
            ALLBEST(s).n_trials_per_bin(tr) = minCnt;
        end
        
    end
elseif strcmpi(equalize_trials,'floor')
    
    
    %use common floor_value
    for s = 1:nsubs
        
        %check floor value validity
        if strcmpi(smethod,'SVM')
            test_val = floor(min(ALLBEST(s).n_trials_per_bin)/nCrossblocks);
        else
            test_val = min(ALLBEST(s).n_trials_per_bin);
        end
        
        if floor_value > test_val
            msgboxTest = sprintf('You selected an invalid floor %i. The value exceeds the max the number of trials within cross-validation blocks',floor_value);
            title = 'ERPLAB: Cross-Validation error';
            errorfound(msgboxTest, title);
            
            return
        end
        
        if floor_value < 1
            msgboxTest = sprintf('You selected an invalid floor %i. You cannot go less than 1 trial per ERP',floor_value);
            title = 'ERPLAB: Cross-Validation error';
            errorfound(msgboxTest, title);
            
            return
            
        end
        
        
        for tr = 1:nbins
             if strcmpi(smethod,'SVM')   
                ALLBEST(s).n_trials_per_bin(tr) = floor_value * nCrossblocks;
             else
                ALLBEST(s).n_trials_per_bin(tr) = floor_value; %crossnobis
             end
        end
    end
    
    %error check this floor_value 
    
    
    
else
    if strcmpi(smethod,'SVM')
        fprintf('\n%s\n', repmat('*',1,60));
        fprintf('WARNING: You have disabled the option for equating the number of trials across classes. \n');
        fprintf('WARNING: This is almost always a very bad idea.  \n');
        fprintf('WARNING: Disabling this option will almost certainly artificially inflate the decoding accuracy, creating bogus effects.  \n');
        fprintf('WARNING:In addition, you should report that you disabled it in your Method section, which will likely cause your paper to be rejected  \n');
        fprintf('%s\n\n', repmat('*',1,60));
    end
end


if ParCompute == 1
   % delete(gcp)
   try
    par_profile = parpool;
    ParWorkers = (par_profile.NumWorkers) -1 ; %all but one  
   catch
       %opened parallel pool profile already
       par_profile = gcp ;
       ParWorkers = par_profile.NumWorkers - 1 ; %all but one
   end
   %display num of parallel workers 
   fprintf('ERPLAB will use %i parallel workers (Max # Workers - 1) for decoding...\n',ParWorkers); 
   
else
    ParWorkers = 0; %makes parfor run without workers, even if pool is open. 
end

if strcmpi(smethod,'SVM')
    method = 1;
else
    method = 2; %crossnobis
end

if strcmpi(strcoding,'OneVsOne')
    classcoding = 1;
elseif strcmpi(strcoding,'OneVsAll')
    classcoding = 2;
else
    classcoding = 0; %any not-multinomial pattern classification (binary decoders, crossnobis, etc)
end


%% Enter algorithm


if method == 1 %SVM
    [MVPC, ALLMVPC] = erp_decoding(ALLBEST,nIter,nCrossblocks,decodeTimes,chanArray,classcoding,equalize_trials,ParWorkers,method);
elseif method == 2 %crossnobis 
    [MVPC, ALLMVPC] = crossnobis(ALLBEST,nIter,0,decodeTimes,chanArray,classcoding,equalize_trials,ParWorkers,method);
end


%
%History
%



skipfields = {'ALLBEST', 'Saveas','History'};


fn      = fieldnames(p.Results);
explica = 0;
if length(idx_bestset)==1 && idx_bestset(1)==1
    inputvari  = 'BEST'; % Thanks to Felix Bacigalupo for this suggestion. Dic 12, 2011
    skipfields = [skipfields 'BESTindex']; % SL
else
    if length(idx_bestset)==1
        explica   = 1;
    end
    inputvari = inputname(1);
end

if method == 2 
    %crossfolds don't matter in crossnobis
     skipfields = [skipfields 'ALLBEST' 'nCrossblocks']; % SL
end


% if strcmpi(smethod,'Crossnobis')
%     skipfields = [skipfields 'classcoding'];
% end

bestcom = sprintf( 'MVPC = pop_decoding( %s ', inputvari);
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    bestcom = sprintf( '%s, ''%s'', ''%s''', bestcom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    if all(cellfun(@isnumeric, fn2res))
                        %fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                        fn2resstr =cell2mat(cellfun(@vect2colon,fn2res,'UniformOutput',false));
                        
                    else
                        fn2resstr = '';
                        for kk=1:numel(fn2res)
                            auxcont = fn2res{kk};
                            if ischar(auxcont)
                                fn2resstr = [fn2resstr '''' auxcont ''',' ];
                            else
                                fn2resstr = [fn2resstr ' ' vect2colon(auxcont, 'Delimiter', 'on')];
                            end
                            
                        end
                        fn2resstr(end) = []; %take out last comma

                    end
                    fnformat = '{%s}';
                elseif isnumeric(fn2res)
                    fn2res = mat2colon(fn2res); 
                    fn2resstr = num2str(fn2res); fnformat = '%s';
                elseif isstruct(fn2res)
                    fn2resstr = 'ALLBEST'; fnformat = '%s';
                else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                
%                 if strcmpi(fn2com,'BESTindex') 
%                     bestcom = sprintf( ['%s, ''%s'', [', fnformat,']'], bestcom, fn2com, fn2resstr);
%                 else
                bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
%                 end
                
                %bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
            end
        end
    end
end
bestcom = sprintf( '%s );', bestcom);



switch shist
    case 1 % from GUI
        % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        displayEquiComERP(bestcom);
        if explica
            try
                cprintf([0.1333, 0.5451, 0.1333], '%%IMPORTANT: For pop_decoding(), you may use BEST instead of ALLBEST, and remove "''BESTindex'',%g"\n',idx_bestset);
            catch
                fprintf('%%IMPORTANT: For pop_decoding(), you may use BEST instead of ALLBEST, and remove ''BESTindex'',%g:\n',idx_bestset);
            end
        end
    case 2 % from script
       % ERP = erphistory(ERP, [], bestcom, 1);
    case 3
        % implicit
    otherwise % off or none
        bestcom = '';
end


%if saveas == 0, use pop_decoding per subject to output 1 MVPC file (even
%though pop_decoding has the ability to do multiple decodings at one time (do through GUI). 
if issaveas == 1
  [MVPC,issave]  = pop_savemymvpc(MVPC,'ALLMVPC',ALLMVPC,'gui','erplab','History','erplab'); 
  %since argument is 'erplab', will save as specified in MVPC fields, and
  %update MVPC menu accordingly. 
  if issave > 0 
      if issave == 2 
           msgwrng = '*** Your MVPCset was saved on your hard drive.***';
      else
           msgwrng = '*** Warning: Your MVPCset was only saved on the workspace.***';
      end
  else
    msgwrng = 'ERPLAB Warning: Your changes were not saved';
  end
  
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end




return
    






