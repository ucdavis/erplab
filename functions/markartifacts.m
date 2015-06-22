% PURPOSE: subroutine for pop functions working on artifact detection
%          marks epoch containing artifact
%
% FORMAT
% 
% [EEG errorm] = markartifacts(EEG, flagv, chanArray, ch, currEpochNum, isRT, issincro)
%
% INPUTS:
%
% EEG           - epoched dataset
% flagv         - flag(s) to mark (1-8). Flag 0 means unmark flags
% chanArray     - whole channel indices array
% ch            - channel(s) to mark
% currEpochNum  - current epoch
% isRT          - sync artifact info on RTs
% issincro      - mark also EEGLAB's fields for artifact detection (1=yes; 0=no)
%
% OUTPUT
%
% EEG           - epoched dataset (with marked epochs and flags)
% errorm        - error flag. 0 means no error; 1 otherwise.
%
% See also pop_artblink pop_artderiv pop_artdiff pop_artflatline pop_artmwppth pop_artstep artifactmenuGUI.m 
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon % Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% January 25th, 2011
%
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

function [EEG, errorm]= markartifacts(EEG, flagv, chanArray, ch, currEpochNum, isRT, issincro)

if nargin<7
      issincro=0;
end

% currEpochNum: current trial (epoch)
errorm = 0;

if ~issincro %not for sincro
      EEG.reject.rejmanual(currEpochNum)                    = 1;   % mark epoch with artifact
      EEG.reject.rejmanualE(chanArray(ch), currEpochNum)    = 1;   % mark channel with artifact
end

nflag = length(flagv);
xitem = EEG.epoch(currEpochNum).eventitem;                      % item index(ices) from event within this epoch
nitem = length(xitem);

if iscell(xitem)
      item = cell2mat(xitem); % this is the position at the continuous eventlist!
else
      item = xitem;
end

oldflag = EEG.epoch(currEpochNum).eventflag; % flags from event within this epoch

%
%
%

if iscell(oldflag)
      %oldflag = cell2mat(oldflag);
      oldflag = uint16([oldflag{:}]); % giving some problems with uint16 type of flags
      isfcell = 1;
else
      isfcell = 0;
end

laten = EEG.epoch(currEpochNum).eventlatency;

if iscell(laten)
      laten = cell2mat(laten);
end

indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
oldflag  = oldflag(indxtimelock);
itemzero = item(indxtimelock);

for f=1:nflag
      flag = flagv(f);
      %if flag>=1 && flag<=8
      if nitem >= 1
            if flag>=1 && flag<=8
                  newflag =  bitset(oldflag, flag);
                  oldflag = newflag; % JLC Sept 2012
            elseif flag==0
                  newflag = uint16(0); % unset flag, unmark. JLC, Sept 1, 2012
            end            
            if flag>=0 && flag<=8
                  if isfcell==1
                        EEG.epoch(currEpochNum).eventflag{indxtimelock}  = newflag;
                  else
                        EEG.epoch(currEpochNum).eventflag(indxtimelock)  = newflag;
                  end
                  EEG.EVENTLIST.eventinfo(itemzero).flag = newflag;
            end
      else
            errorm  = 1;
            return
      end
      %else
      %      errorm = 2;
      %      return
      %end
end

%
% RTs
%
if isRT && isFieldNested(EEG, 'rtitem')
      bin = unique_bc2(cell2mat(EEG.epoch(currEpochNum).eventbini)); 
      bin = bin(bin>0);
      rtitem = EEG.EVENTLIST.bdf(bin).rtitem;
      
      if ~isempty(rtitem)
            col = size(rtitem,2);            
            for it=1:nitem
                  for icol=1:col
                        p = find(item(it)==rtitem(:,icol));
                        if ~isempty(p)
                              for ib = 1:length(bin)
                                    [EEG.EVENTLIST.bdf(bin(ib)).rthomeflag(p,icol)] = deal(newflag); % check this out. JLC
                              end
                        end
                  end
            end
      end
      
      % Jason: Mark the RTFLAG variable -----------------------
      epochBins         = unique(cell2mat(EEG.epoch(currEpochNum).eventbini));    % Select all the bins the epoch belongs to
      epochBins         = epochBins(epochBins>0);
      epochEventNums    = EEG.epoch(currEpochNum).eventitem;                      % Select the event-code index(ices) within this epoch
      if iscell(epochEventNums)
          epochEventNums = cell2mat(epochEventNums);                              % Convert the cell array to a matrix array for the FOR-loop
      end
      
      for binIndex = 1:length(epochBins)                                          % A single epoch may belong to multple bins
          for eventNumIndex = 1:length(epochEventNums)                            %  A single epoch may also contain multiple event codes
              epochEventNum = epochEventNums(eventNumIndex);
              epochBinNum   = epochBins(binIndex);
              
              % Set the RTFLAG
              %    First, find the RT-index via the epoch event num
              rtFlagIndex = find(epochEventNum==EEG.EVENTLIST.bdf(epochBinNum).rtitem);
              %    Use that RT-index to set the RTFLAG
              if(~isempty(rtFlagIndex))
                  EEG.EVENTLIST.bdf(epochBinNum).rtflag(rtFlagIndex) = newflag;
              end
              
              % Set the RTHOMEFLAG
              %    First, find the RT-index via the epoch event num
              rtHomeFlagIndex = find(epochEventNum==EEG.EVENTLIST.bdf(epochBinNum).rthomeitem);
              %    Use that RT-index to set the RTHOMEFLAG
              if(~isempty(rtHomeFlagIndex))
                  EEG.EVENTLIST.bdf(epochBinNum).rthomeflag(rtHomeFlagIndex) = newflag;
              end
              
              
          end
      end
      %-------------------------------------------------------------------------------
      
      
end




function isFieldResult = isFieldNested(inStruct, fieldName)
% inStruct is the name of the structure or an array of structures to search
% fieldName is the name of the field for which the function searches
isFieldResult = 0;
f = fieldnames(inStruct(1));
for i=1:length(f)
    if(strcmp(f{i},strtrim(fieldName)))
        isFieldResult = 1;
        return;
    elseif isstruct(inStruct(1).(f{i}))
        isFieldResult = isFieldNested(inStruct(1).(f{i}), fieldName);
        if isFieldResult
            return;
        end
    end
end

