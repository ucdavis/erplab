% PURPOSE  : Decode BEST files after setting parameters/
%
% FORMAT   :
%
% >> BEST = pop_decoding(BEST);
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


function [MVPA] = pop_decoding(varargin) 
com = ''; 

%try preload MVPA

% try 
%     BEST = evalin('base', 'BEST'); 
% catch
%     BEST =[]; 
% end

if nargin<1
    help pop_decoding
    return
end

if nargin == 1
    filename = varargin{1};
    if strcmpi(filename,'workspace')
        filepath = '';
    else
        
        if isempty(filename)
            [filename, filepath] = uigetfile({'*.best','BEST (*.best)'}, ...
                'Load BEST', ...
                'MultiSelect', 'on');
            if isequal(filename,0)
                disp('User selected Cancel')
                return
            end
            
            %
            % test current directory
            %
            %changecd(filepath) % Steve does not like this...
        else
            filepath = cd;
        end
    end
    
    %for for scripting purposes, this is generalizeable? 
    if strcmpi(filename,'workspace')
        filepath = '';
        nfile = 1;
        loadfrom = 0; %load from workspace
    else
        loadfrom = 1;
    end
    
    
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
    
%
% load BEST(s)
%
    for i=1:nfile
        if loadfrom==1
            fullname = fullfile(inputpath, inputfname{i});
            fprintf('Loading %s\n', fullname);
            L   = load(fullname, '-mat');
            if i == 1
                ALLBEST = L.BEST;
            else
                ALLBEST(i) = L.BEST;
            end
        else
            ALLBEST = evalin('base', 'BEST');
        end
    end
    
    checking = checkmultiBEST(ALLBEST);
        
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
    end
    
    
    
    
    
    %Call GUI for decoding parameters parameters
    app = feval('decodingGUI', filename, filepath, ALLBEST); %cludgy way
    waitfor(app,'FinishButton',1);
    decoding_res = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding 
    app.delete; %delete app from view
    pause(0.5); %wait for app to leave
    
    
    %parse arguments 
    nBins = decoding_res{1};
    nIter = decoding_res{2};
    nCrossBlocks = decoding_res{3};
    DataTimes = decoding_res{4};
    times = decoding_res{5};
    decoding_times = decoding_res{6};
    relevantChans = decoding_res{7};
    nPerBinBlock = decoding_res{8};
    ParCompute = decoding_res{9}; 
    
    [MVPA] = erp_decoding(ALLBEST,filepath,nBins,nIter,nCrossBlocks,DataTimes,times,decoding_times,relevantChans,nPerBinBlock,ParCompute); 
    
    





end