% PURPOSE: Detect and remove epochs containing boundary event-codes
%
% FORMAT:
%
%      function EEG = pop_artBoundary(EEG)
%
% Inputs:
%
%   EEG             - epoched EEG dataset
%
%
% Optional Inputs:
%
%   'TimeRange'     - 
%   'Flag'          - Artifact flag number to mark epochs with 
%   'BoundaryCode'  - 
%
%
% Outputs:
%
%   EEG             - averaged ERPset
%
%
% See also pop_averager pop_appenderp
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009
%
%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b

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

function EEG = pop_artBoundary(EEG, varargin)


switch(nargin)
    case 0
        help pop_artBoundary;
        return;
end


%
% Parsing inputs
%
p                   = inputParser;
p.FunctionName      = mfilename;
p.CaseSensitive     = false;
p.addRequired(      'EEG');
p.addParamValue(    'TimeRange'     , single([EEG.xmin EEG.xmax]*1000)  , @isnumeric);
p.addParamValue(    'Flag'          , 1                                 , @isnumeric);
p.addParamValue(    'BoundaryCode'  , {'-99','boundary'}                , @iscell);
% p.addParamValue(  'Review'        , 'off'     , @ischar); % to open a window with the marked epochs
% p.addParamValue(  'History'       , 'script'  , @ischar); % history from scripting

p.parse(EEG, varargin{:});

timeRange           = p.Results.TimeRange;
boundaryCodes       = p.Results.BoundaryCode;
artFlag             = p.Results.Flag;
% _____________________________________________________________________

% _____________________________________________________________________
% Epoch the EEG dataset
% _____________________________________________________________________
if(isempty(EEG.epoch))
    EEG = pop_epochbin(EEG, timeRange, 'pre');
end


% check for time-lock latency
EEG         = checkeegzerolat(EEG);


nepoch      = length(EEG.epoch);
nbin        = EEG.EVENTLIST.nbin;           % total number of described bins
countbinOK  = zeros(1,nbin);                % trial counter (only good trials)
countbinORI = zeros(1,nbin);                % trial counter (ALL trials, originals)
countbinINV = zeros(1,nbin);                % trial counter (invalid trials)




% For each epoch
%  check to see if the epoch contains a boundary code
%  if yes, then disable that epoch

for i = 1:nepoch
    %
    % identify values linked to the time-locked events
    %
    
    if length(EEG.epoch(i).eventlatency) == 1
        numbin = EEG.epoch(i).eventbini; % index of bin(s) that own this epoch (can be more than one)
        
        if iscell(numbin)
            numbin = numbin{:};          % allows multiples bins assigning
        end
        
        countbinORI(1,numbin) = countbinORI(1,numbin) + 1; % trial counter (ALL trials, originals)
        
        % Exclude epochs having boundary events, and set corresponding "enable" field to -1. Dec 20, 2012. JLC
        etype  = EEG.epoch(i).eventtype; % event code of the single event in this epoch.
        if iscell(etype)
            etype = etype{:};
        end
        
        %         eitem  = EEG.epoch(i).eventitem; % event code of the single event in this epoch.
        %         if iscell(eitem)
        %             eitem = eitem{:};
        %         end
        
        boundaryCodeFound = false;
        if isnumeric(etype)
            if etype==-99
                boundaryCodeFound=true;
            end
        elseif ismember_bc2(boundaryCodes, etype); % strcmpi(etype, '-99') || strcmpi(etype, 'boundary')
            boundaryCodeFound=true;
        end
        
        
        
        % ===========================================================================
        % Update enable fields at EEG.epoch and EEG.EVENTLIST.eventinfo (set to -1)
        % ===========================================================================
        if boundaryCodeFound
            %             EEG.epoch(i).eventenable                = -1;
            %             EEG.EVENTLIST.eventinfo(eitem).enable   = -1;
            
            % Mark RT for Boundary artifacts __________________________________________
            %             artFlag            = 8;        % arbitrarily use flag 8 to mark boundary
            chanArray       = [];       % don't mark any specific channels
            ch              = [];
            markEpoch       = i;
            updateRT        = 1;        % update RT fields for artifact detection
            updateEEGLAB    = 1;        % update EEGLAB's fiels for artifact detection
            EEG             = markartifacts(EEG, artFlag, chanArray, ch, markEpoch, updateRT);
            %__________________________________________________________________________________
            fprintf('(!) Epoch #%g had a "boundary" event so it was marked with an artifact flag.\n ', i)
        else
            countbinOK(1,numbin) = countbinOK(1,numbin) + 1;  % counter number epoch per bin
        end
        
        % just 1 event at this epoch
        %         enableTL = EEG.epoch(i).eventenable; %  "enable" status of the single event in this epoch.
        %
        %         if iscell(enableTL)
        %             enableTL = enableTL{1};
        %         end
        %         enableALL = enableTL;  % cause there is 1 event
    elseif length(EEG.epoch(i).eventlatency) > 1
        indxtimelock    = find(cell2mat(EEG.epoch(i).eventlatency) == 0);     % catch zero-time locked event (type),
        [numbin]        = [EEG.epoch(i).eventbini{indxtimelock}];             %#ok<FNDSB> % index of bin(s) that own this epoch (can be more than one) at time-locked event.
        numbin          = unique_bc2(numbin(numbin>0));
        %         flagb           = EEG.epoch(i).eventflag{indxtimelock};               % flag status of the time-locked event in this epoch.
        countbinORI(1,numbin) = countbinORI(1,numbin) + 1; % trial counter (ALL trials, originals)
        
        
        
        % Exclude epochs having boundary events, and set corresponding "enable" field to -1. Dec 20, 2012. JLC
        etype     = EEG.epoch(i).eventtype;         % event code of the single event in this epoch.
        boundaryCodeFound = false;
        
        if any(cellfun(@ischar, etype))
            [tfb, ~] = ismember_bc2(boundaryCodes, etype);
            if any(tfb)
                boundaryCodeFound   = true;
                %                 indxb               = nonzeros(indxb);
            end
        else
            etype = [etype{:}]; % double
            [tfb, ~] = ismember_bc2(-99, etype);
            if tfb
                boundaryCodeFound   = true;
            end
        end
        
        
        
        % ===========================================================================
        % Update enable fields at EEG.epoch and EEG.EVENTLIST.eventinfo (set to -1)
        % ===========================================================================
        if boundaryCodeFound
            countbinINV(1,numbin)   = countbinINV(1,numbin) + 1;  % trial counter (invalid trials)
            
            %             [tf, binslot]           = ismember_bc2(numbin, binArray);  % for now...binslot=bin detected at the current epoch
            %             eitem                   = [EEG.epoch(i).eventitem{:}];    % event code of the single event in this epoch.
            %
            %             [EEG.epoch(i).eventenable{indxb}]               = deal(-1);
            %             [EEG.EVENTLIST.eventinfo(eitem(indxb)).enable]  = deal(-1);
            %
            %
            % Mark RT for Boundary artifacts __________________________________________
            %   Link the EPOCH info to RT info
            %   via BIN NUMBER + ITEM NUMBER
            %
            %             epochBins   = unique(cell2mat(EEG.epoch(i).eventbini)); % Collect all the bins in the epoch
            %             epochBins   = epochBins(epochBins>0);
            %             epochItems  = EEG.epoch(i).eventitem; % item index(ices) from event within this epoch
            %             if iscell(epochItems)
            %                 epochItems = cell2mat(epochItems); % this is the position at the continuous eventlist!
            %             end
            
            
            % for each bin
            %    for each item
            %      use the oldflag to set the new flag
            %      set the RTFLAG to the new flag
            %
            %             for binIndex = 1:length(epochBins)
            %                 for itemIndex = 1:length(epochItems)
            %                     epochItemNum = epochItems(itemIndex);
            %                     epochBinNum  = epochBins(binIndex);
            %
            %
            %                     rtFlagIndex = find(epochItemNum==EEG.EVENTLIST.bdf(epochBinNum).rtitem);
            %                     if(~isempty(rtFlagIndex))
            %                         EEG.EVENTLIST.bdf(epochBinNum).rtflag(rtFlagIndex) = bitset(EEG.EVENTLIST.bdf(epochBinNum).rtflag(rtFlagIndex), flag);
            %                     end
            %                 end
            %             end
            
            
            % Mark RT for Boundary artifacts __________________________________________
            %             flag            = 8;        % arbitrarily use flag 8 to mark boundary
            chanArray       = [];       % don't mark any specific channels
            ch              = [];
            markEpoch       = i;
            updateRT        = 1;        % update RT fields for artifact detection
            EEG             = markartifacts(EEG, artFlag, chanArray, ch, markEpoch, updateRT);
            %__________________________________________________________________________________
            fprintf('(!) Epoch #%g had a "boundary" event, so it was marked with an artifact flag.\n ', i)
        else
            countbinOK(1,numbin) = countbinOK(1,numbin) + 1;  % counter number epoch per bin
        end
        
        
        % multiple events at his epoch
        %         enableTL  =  EEG.epoch(i).eventenable{indxtimelock}; % "enable" status of the time-locked event.
        %         enableALL = [EEG.epoch(i).eventenable{:}]; % enable field of all events
    else
        %         numbin =[];
    end
    
    
    
    
end











%% Summary Feedback to User
% ==========================================
EEG = eeg_checkset( EEG );
pop_summary_AR_eeg_detection(EEG, ''); % show table at the command window










%% 
% TotalOri = sum(countbinORI  ,2);
% TotalOK  = sum(countbinOK   ,2);
% TotalINV = sum(countbinINV  ,2);
% 
% fprintf('Summary per bin:\n\n');
% fprintf('Bin #\t\tOriginal \tExcluded \tResult\n----------------------------------------------------------\n');
% for binNumber = 1:nbin
%     fprintf('Bin %d\t\t%d\t\t%d\t\t%d\n', binNumber, countbinORI(binNumber), countbinINV(binNumber), countbinOK(binNumber));
% end
% fprintf('__________________________________________________________\n');
% fprintf('Total \t\t%d\t\t%d\t\t%d\n', TotalOri, TotalINV, TotalOK);
% 
% 
% 
%
% skipfields  = {'EEG', 'Review', 'History'};
% fn          = fieldnames(p.Results);
% com         = sprintf( '%s  = pop_artBoundary( %s ', inputname(1), inputname(1));
% for q=1:length(fn)
%         fn2com = fn{q};
%         if ~ismember_bc2(fn2com, skipfields)
%                 fn2res = p.Results.(fn2com);
%                 if ~isempty(fn2res)
%                         if ischar(fn2res)
%                                 if ~strcmpi(fn2res,'off')
%                                         com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
%                                 end
%                         else
%                             if iscell(fn2res)
%                                 fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
%                                 fnformat = '{%s}';
%                             else
%                                 fn2resstr = vect2colon(fn2res, 'Sort','on');
%                                 fnformat = '%s';
%                             end
%                             com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
%                         end
%                 end
%         end
% end
% com = sprintf( '%s );', com);
% 
% % get history from script
% switch shist
%         case 1 % from GUI
%                 com = sprintf('%s %% GUI: %s', com, datestr(now));
%                 %fprintf('%%Equivalent command:\n%s\n\n', com);
%                 displayEquiComERP(com);
%         case 2 % from script
%                 EEG = erphistory(EEG, [], com, 1);
%         case 3
%                 % implicit
%         otherwise %off or none
%                 com = '';
% end
% 
% %
% % Completion statement
% %
% msg2end
