% PURPOSE  : Decode BEST files after setting parameters/
%
% FORMAT   :
%
% >> BEST = pop_decoding(BEST); or
% >> BEST = pop_decoding(ALLBEST)
%
% INPUTS   :
%
% EEG           - input dataset
%
% The available parameters are as follows:
%
%        'Twindow' 	- time period (in ms) to apply this tool (start end). Example [-200 800]
%        'Threshold'    - range of amplitude (in uV). e.g  -100 100
%        'Windowsize'   - moving window width in ms.
%        'Windowstep'   - moving window step in ms.
%        'Channel' 	- channel(s) to search artifacts.
%        'LowPass' - Apply low pass filter at provided half-amplitude
%                           cutoff (FIR @ 26 filter order). 
%                           Default: -1/Do Not Apply
%        'Flag'         - flag value between 1 to 8 to be marked when an artifact is found.(1 value)
%        'Review'       - open a popup window for scrolling marked epochs.
%
% OUTPUTS  :
%
% MVPA           -  output BEST dataset
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


function [MVPA, ALLMVPA] = pop_decoding(ALLBEST, varargin) 
com = ''; 

try
        ALLMVPA   = evalin('base', 'ALLMVPA');
       % preindex = length(ALLMVPA);
catch
        disp('WARNING: ALLMVPA structure was not found. ERPLAB will create an empty one.')
        ALLMVPA = [];
       % preindex = 0;
end

%preload MVPA
MVPA = preloadMVPA; 

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
    %def = erpworkingmemory('pop_decoding');
    def = []; %for now, def always empty, always default to "load from hard drive". 
    if isempty(def)
        if isempty(ALLBEST)
            inp1 = 1; %from hard drive
            bestseti = []; %index of bestsets to use
        else
            inp1 = 0; %from bestset menu
            bestseti = 1:length(ALLBEST); 
            
        end
        
        def = {inp1 bestseti [] 3 100 1 [] [] [] 2 0};
        %def1 = input mode (1 means from HD, 0 from bestsetmenu, 2 current bestset) 
        %def2 = bestset index (see above)
        %def3 = output filename (def = filename.mvpa in pwd)
        %def4 = nCrossBlocks (def = 3)
        %def5 = nIter (def = 100)
        %def6 = DataTimes (1:all, 2: pre, 3: post, 4:custom) (Def = 1/all)
        %def7 = times (full array of epoch times) 
        %def8 = time_sample(logical index of epoch)
        %def9 = relevantChans
        %def10 = nPerBinBlock 
        %   (0: don't equalize/ 1:equalize across bins/ 2: eqalize across
        %   bins & best (def))
        %def11  = parComute (def: 0)
    else
        %if working memory is NOT empty (?) 
        
        
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
    decoding_res = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding 
    app.delete; %delete app from view
    pause(0.5); %wait for app to leave
    
    
    %parse arguments
    ALLBEST = decoding_res{1}; 
    indexBEST = decoding_res{2};
    fname = decoding_res{3}; 
    nBins = decoding_res{4};
    nIter = decoding_res{5};
    nCrossBlocks = decoding_res{6};
    DataTimes = decoding_res{7};
    times = decoding_res{8};
    decoding_times = decoding_res{9};
    relevantChans = decoding_res{10};
    nPerBinBlock = decoding_res{11};
    ParCompute = decoding_res{12}; 
    
   [MVPA] = pop_decoding(ALLBEST,'BESTindex',indexBEST, 'file_out', fname, ... 
       'nIter',nIter,'nCrossblocks',nCrossBlocks, 'nDatatimes', DataTimes, ...
   'SampleTimes',times,'DecodingTimes',decoding_times, 'Chans', relevantChans, ...
   'nPerBinBlock', nPerBinBlock,'ParCompute',ParCompute); 
  


end
    
%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLBEST');

% option(s)
p.addParamValue('BESTindex', 1); % erpset index or input file
p.addParamValue('file_out', []); % output file name 
%p.addParamValue('nBins',0); %total number of bins/decoding labels/decoding levels
p.addParamValue('nIter',100); % total number of decoding iterations (def: 100 iters)
p.addParamValue('nCrossblocks',3); % total number of crossblock validations (def: 3 crossblocks)
p.addParamValue('nDatatimes',[]); %struct with fields pre(start),post(end) epoch times (def: entire epoch)
p.addParamValue('SampleTimes',[]); %array of epoch sampling times in ms, i.e. EEG.times (def: all times)
p.addParamValue('DecodingTimes',[]); %logical index array of selected epoch times for decoding (def: all times)
p.addParamValue('Chans', []); %array of channel indicies (def: all channels)
p.addParamValue('nPerBinBlock', []); % number of trials per bin (req: length must equal nBins // def: equalize trials across bins & BESTsets)
p.addParamValue('ParCompute',0); %attempt parallization across CPU cores (def: false) 

% Parsing
p.parse(ALLBEST, varargin{:}); 


   
    
    [MVPA] = erp_decoding(ALLBEST,filepath,nBins,nIter,nCrossBlocks,DataTimes,times,decoding_times,relevantChans,nPerBinBlock,ParCompute); 
    
    %erp_decoding(ALLBEST,filepath,nBins,nIter,nCrossBlocks,DataTimes,times,decoding_times,relevantChans,nPerBinBlock,ParCompute); 
    





end


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