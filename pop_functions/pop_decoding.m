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
%        'BESTindex' 	- Index of BESTset to decode.
%                         If supplying one BESTset, use index "1".
%                         Default: "1" for the only/first BESTset in
%                         ALLBEST
%        'chanArray'    - Index of channels to use. Default: all channels
%        'nIter'        - Amount of iterations to run decoding per BESTset.
%                         Default: 100 iterations
%        'nCrossblocks' - Amount of Crossfold Validation blocks where
%                         Ntrials/nCrossblocks = Ntrials(ERP) / default: 3
%        'decodeTimes' 	- [start_epoch_decoding end_epoch_decoding]
%                         Default: use whole epoch length. 
%        'Decode_every_Npoint' -  Decode every N points where 1 point =
%                                 1/sampling rate (in ms)
%                           Default: -1/Do Not Apply
%        'equalizeTrials'  - 1: Across Bins within BESTset
%                            2: Across BESTsets (if more than 1 BESTset) -
%                            defualt 
%                            3: Use common floor value 
%        'floorValue'   - Amount of trials per ERP* 
%                       *Only valid if equalizeTrials == 2
%        'method'       - Classification method 
%                          1:SVM (default), 2: Crossnobis
%        'SVMcoding'    - If classification method == SVM*, then
%                         SVMcoding = 1 -> 'One vs. One' classifiers;
%                         SVMcoding = 2 -> 'One vs. ALL classifiers
%                         if SMM has only two classes, fitcecoc becomes
%                         fitcsvm. 
%        'SaveAs'        -  (optional) open GUI for saving MVPCset. Not
%                       useful if scripting; use separate pop_savemymvpc(). 
%                           'on'/'off' (Default: off)
%                            (if "off", will not update in MVPCset menu)
%        'ParCompute'    - (optional) Use parallelization to make decoding
%                          faster. Uses as many available cores. Must have 'Parallel
%                          Computing Toolbox' installed. 
%
%
% OUTPUTS  :
%
% MVPC           -  output MVPC dataset
%
% EXAMPLE  :
%
% EEG  = pop_artmwppth( EEG , 'Channel',  1:16, 'Flag',  1, 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep',  100 );
%
% See also;  [pop_artblink]
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
        
        def = {inp1 bestseti [] 100 3 1 [] 1 2 1 1 2 0};
      
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
    

%% continue with main logic 
%     checking = checkmultiBEST(ALLBEST);
%     
%     if ~checking 
%         disp('Sorry, your BEST files do not agree with each other in terms of bins and channels')
%         return    
%     end
%      
%     filename = {ALLBEST.filename}; 
%     filepath = {ALLBEST.filepath}; 
%         
        
        
% 
%       I'm not sure if these following checks are needed? 
%
%         [ERP, conti, serror] = olderpscan(ERP, popupwin);
%         if conti==0
%             break
%         end
%         if serror
%             msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
%                 'Please, try upgrading your ERP structure.'];
% 
%             if shist==1
%                 title = 'ERPLAB: pop_loaderp() Error';
%                 errorfound(sprintf(msgboxText, ERP.filename), title);
%                 errorf = 1;
%                 break
%             else
%                 error(sprintf(msgboxText, ERP.filename))
%             end
%         end
% 
%         %
%         % Check (and fix) ERP structure (basic)
%         %
%         checking = checkERP(ERP);
%         file_ERPLAB_versions(nfile) = str2double(ERP.version);
% 
%         try
% 
% 
%             if checking
%                 if i==1 && isempty(ALLERP);
%                     ALLERP = buildERPstruct([]);
%                     ALLERP = ERP;
%                 else
%                     ALLERP(i+preindex) = ERP;
%                 end
%             else
%                 msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
%                     'Please, try upgrading your ERP structure.'];
% 
%                 if shist==1
%                     title = 'ERPLAB: pop_loaderp() Error';
%                     errorfound(sprintf(msgboxText, ERP.filename), title);
%                     errorf = 1;
%                     break
%                 else
%                     error(sprintf(msgboxText, ERP.filename))
%                 end
%             end
%         catch
%             msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
%                 'Please, try upgrading your ERP structure.'];
% 
%             if shist==1
%                 title = 'ERPLAB: pop_loaderp() Error';
%                 errorfound(sprintf(msgboxText, ERP.filename), title);
%                 errorf = 1;
%                 break
%             else
%                 error(sprintf(msgboxText, ERP.filename))
%             end
%         end
% 
%         %
%         % look for null bins
%         %
%         c = look4nullbin(ERP);
%         if c>0
%             msgnull = sprintf('bin #%g has flatlined ERPs.\n', c);
%             msgnull = sprintf('WARNING:\n%s', msgnull);
%             warningatcw(msgnull, [1 0 0]);
%         end
    

    %Call GUI for decoding parameters parameters
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
    SVMcoding = decoding_res{13};
%     file_out = decoding_res{13};
%     path_out = decoding_res{14}; 
    ParCompute = decoding_res{14}; 
    
    %save in working memory
    
    def = { inp1, indexBEST, relevantChans, nIter, nCrossBlocks, epoch_times, ...
        decodeTimes, decode_every_Npoint, equalizeTrials, floorValue, ...
        selected_method, SVMcoding, ParCompute}; 
    erpworkingmemory('pop_decoding',def); 
    
    %for input into sommersault, change decodeTimes to ms
    decodeTimes = decodeTimes* 1000; 
   
    
   [MVPC] = pop_decoding(ALLBEST,'BESTindex', indexBEST, 'chanArray', relevantChans, ...
       'nIter',nIter,'nCrossblocks',nCrossBlocks,  ...
   'decodeTimes', decodeTimes, 'Decode_every_Npoint',decode_every_Npoint,  ...
   'equalizeTrials', equalizeTrials,'floorValue',floorValue,'method', selected_method, ...
   'SVMcoding',SVMcoding, 'Saveas','on', 'ParCompute',ParCompute); 

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
p.addParamValue('BESTindex', [1],@isnumeric); % erpset index or input file (default: first BESTset in ALLBEST)
p.addParamValue('chanArray',[], @isnumeric); %array of channel indicies (def: all channels)
%p.addParamValue('nBins',0); %total number of bins/decoding labels/decoding levels
p.addParamValue('nIter',100, @isnumeric); % total number of decoding iterations (def: 100 iters)
p.addParamValue('nCrossblocks',3, @isnumeric); % total number of crossblock validations (def: 3 crossblocks)
%p.addParamValue('nDatatimes',[]); %struct with fields pre(start),post(end) epoch times (def: entire epoch)
%p.addParamValue('SampleTimes',[]); %array of epoch sampling times in ms, i.e. EEG.times (def: all times)
p.addParamValue('decodeTimes',[],@isnumeric); %[start end](in ms)
p.addParamValue('Decode_every_Npoint',1, @isnumeric); %(def = all times(1) // must be positive number )
p.addParamValue('equalizeTrials', 2, @isnumeric); % def: equalize trials across bins & BESTsets (2)
p.addParamValue('floorValue', 0, @isnumeric); 
p.addParamValue('method',1,@isnumeric); %method (1:SVM/2:Crossnobis);
p.addParamValue('SVMcoding',2,@isnumeric); % SVMcoding(1:oneVsone/2:oneVsall); 
p.addParamValue('Saveas','off',@ischar); 
p.addParamValue('ParCompute',0, @isnumeric); %attempt parallization across CPU cores (def: false) 

% Parsing
p.parse(ALLBEST, varargin{:});
idx_bestset = p.Results.BESTindex;
chanArray = p.Results.chanArray;
nIter = p.Results.nIter;
nCrossblocks = p.Results.nCrossblocks;
decodeTimes = p.Results.decodeTimes; 
Decode_every_Npoint = p.Results.Decode_every_Npoint; 
equalize_trials = p.Results.equalizeTrials;
floor_value = p.Results.floorValue; 
method = p.Results.method; 
SVMcoding = p.Results.SVMcoding;
% filename_out = p.Results.filename_out; 
% pathname_out = p.Results.path_out; 
ParCompute = p.Results.ParCompute; 


%% choose BESTsets
if ~isempty(idx_bestset)  
    ALLBEST = ALLBEST(idx_bestset) ; 
else
    ALLBEST = ALLBEST(1); %just do the first one 
end


%% Check ALLBEST
checking = checkmultiBEST(ALLBEST);

if ~checking
    disp('Sorry, your BEST files do not agree with each other in terms of bins and channels')
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
                %user pressed cancel
                return
            end

          ALLBEST = res{1};
         % file_out = {ALLBEST.filename}; 
         % file_path = {ALLBEST.filepath}; 

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



% update ALLBEST.times & ALLBEST.binwisedata, ALLBEST.pnts, 

k = numel(ALLBEST);
bins = numel(ALLBEST(1).binwise_data);
for b = 1:k
    ALLBEST(b).xmin = decodeTimes(1)/1000;
    ALLBEST(b).xmax = decodeTimes(2)/1000;
    npnts_old = ALLBEST(b).pnts; 
    ALLBEST(b).pnts = ntimes;
    ALLBEST(b).times = original_times(decoding_times_index);
    
    %update fs
    fs = ALLBEST(b).srate;
    samps = 1/fs; 
    epochtime = (samps*npnts_old) *1000;% ms
    new_fs = (ntimes/epochtime) *1000; 
    ALLBEST(b).srate = new_fs; 
    
    for i = 1:bins
        ALLBEST(b).binwise_data(i).data = ALLBEST(b).binwise_data(i).data(:,decoding_times_index,:);
    end
end

% reset the trial counts according to nperbinblock/Equalize Trials
% if equalize_trials = 0 explicitly, we don't equalize.  
nbins = ALLBEST.nbin; 
nsubs = numel(ALLBEST); 

if nsubs == 1 && equalize_trials == 2
    %cannot equalize trials across BESTset if only one BESTset
    equalize_trials = 1; 
end

if equalize_trials == 2 % equalize across best files 
    
    trials_acr_best = [ALLBEST(:).n_trials_per_bin]; 
    minCnt = min(trials_acr_best); 
   %nPerBinBlock = floor(minCnt/nCrossblocks); 
   
   for s = 1:nsubs
       for tr = 1:nbins
           ALLBEST(s).n_trials_per_bin(tr) = minCnt;
       end
   end
    
   
elseif equalize_trials == 1 %equalize bins within best files
    
    for s = 1:nsubs
        trials_acr_sub = ALLBEST(s).n_trials_per_bin;
        minCnt = min(trials_acr_sub);
        
        for tr = 1:nbins
            ALLBEST(s).n_trials_per_bin(tr) = minCnt;
        end
        
    end
elseif equalize_trials == 3
    
    for s = 1:nsubs
        for tr = 1:nbins
            %ALLBEST(s).n_trials_per_bin(tr) = floor_value * nCrossblocks ;
            ALLBEST(s).n_trials_per_bin(tr) = floor_value * nCrossblocks;
        end
    end
    

end


%% delete any unnecessary paramters like nPerBinBlock (due to simplification in pop_decoding
% p.parse(ALLBEST, varargin{:});
% idx_bestset = p.Results.BESTindex;
% chanArray = p.Results.chanArray;
% nIter = p.Results.nIter;
% nCrossblocks = p.Results.nCrossblocks;
% decodeTimes = p.Results.decodeTimes; 
% Decode_every_Npoint = p.Results.Decode_every_Npoint; 
% equalize_trials = p.Results.equalizeTrials;
% classifer = p.Results.classifier; 
% SVMcoding = p.Results.SVMcoding;
% fname = p.Results.filename_out; 
% ParCompute = p.Results.ParCompute; 


if ParCompute == 1
   % delete(gcp)
   try
    par_profile = parpool;
    ParWorkers = par_profile.NumWorkers; 
   catch
       %opened parallel pool profile already
       par_profile = gcp ;
       ParWorkers = par_profile.NumWorkers;
   end
else
    ParWorkers = 0; %makes parfor run without workers, even if pool is open. 
end


if method == 1 %SVM
    [MVPC, ALLMVPC] = erp_decoding(ALLBEST,nIter,nCrossblocks,decodeTimes,chanArray,SVMcoding,equalize_trials,ParWorkers,method);
end

%if saveas == 0, use pop_decoding per subject to output 1 MVPC file (even
%though pop_decoding has the ability to do multiple decodings at one time (do through GUI). 
if issaveas == 1
  [MVPC,issave]  = pop_savemymvpc(MVPC,'ALLMVPC',ALLMVPC,'gui','erplab'); 
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
    






%% defunct method of loading in BESTsets        
%     filename = varargin{1};
%     if strcmpi(filename,'workspace')
%         filepath = '';
%     else
%         
%         if isempty(filename)
%             [filename, filepath] = uigetfile({'*.best','BEST (*.best)'}, ...
%                 'Load BEST', ...
%                 'MultiSelect', 'on');
%             if isequal(filename,0)
%                 disp('User selected Cancel')
%                 return
%             end
%             
%             %
%             % test current directory
%             %
%             %changecd(filepath) % Steve does not like this...
%         else
%             filepath = cd;
%         end
%     end
%     
%     %for for scripting purposes, this is generalizeable? 
%     if strcmpi(filename,'workspace')
%         filepath = '';
%         nfile = 1;
%         loadfrom = 0; %load from workspace
%     else
%         loadfrom = 1;
%     end
%     
%     
%     %% load BEST files in workspace 
%     if iscell(filename)
%         nfile = length(filename);
%         inputfname = filename;
%     else
%         nfile = 1;
%         inputfname = {filename}; 
%     end
%     inputpath = filepath; 
%     
%     
%     %file_ERPLAB_versions = nan(nfile,1);
%     
% %
% % load BEST(s)
% %
%     for i=1:nfile
%         if loadfrom==1
%             fullname = fullfile(inputpath, inputfname{i});
%             fprintf('Loading %s\n', fullname);
%             L   = load(fullname, '-mat');
%             if i == 1
%                 ALLBEST = L.BEST;
%             else
%                 ALLBEST(i) = L.BEST;
%             end
%         else
%             ALLBEST = evalin('base', 'BEST');
%         end
%     end
% %   