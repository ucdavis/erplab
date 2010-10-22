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

function [EEG errorm]= markartifacts(EEG, flagv, chanArray, ch, i, isRT, issincro)

if nargin<7
      issincro=0;
end

% i: current trial (epoch)
errorm = 0;

if ~issincro %not for sincro
      EEG.reject.rejmanual(i) = 1; % marks epoch with artifact
      EEG.reject.rejmanualE(chanArray(ch), i) = 1; % marks channel with artifact
end

nflag = length(flagv);
xitem = EEG.epoch(i).eventitem; % item index(ices) from event within this epoch
nitem = length(xitem);

if iscell(xitem)
      item = cell2mat(xitem); % this is the position at the continuous eventlist!
else
      item = xitem;
end

oldflag = EEG.epoch(i).eventflag; % flags from event within this epoch

if iscell(oldflag)
      oldflag = cell2mat(oldflag);
      isfcell = 1;
else
      isfcell = 0;
end

laten = EEG.epoch(i).eventlatency;

if iscell(laten)
      laten = cell2mat(laten);
end

indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
oldflag  = oldflag(indxtimelock);
itemzero = item(indxtimelock);

for f=1:nflag
      
      flag = flagv(f);
      
      if flag>=1 && flag<=8
            if nitem >= 1                  
                  newflag =  bitset(oldflag, flag);                  
                  if isfcell==1
                        EEG.epoch(i).eventflag{indxtimelock}  = newflag;
                  else
                        EEG.epoch(i).eventflag(indxtimelock)  = newflag;
                  end                  
                  EEG.EVENTLIST.eventinfo(itemzero).flag = newflag;
            else
                  errorm  = 1;
                  return
            end
      else
            errorm = 2;
            return
      end
end

if isRT
      bin = unique(cell2mat(EEG.epoch(i).eventbini)); % since each event within an epoch has the same bin, matching home item's bin
      bin = bin(bin>0);
      rtitem = EEG.EVENTLIST.bdf(bin).rtitem;
      
      if ~isempty(rtitem)
            col = size(rtitem,2);            
            for it=1:nitem
                  for icol=1:col
                        p = find(item(it)==rtitem(:,icol));
                        if ~isempty(p)
                              for ib = 1:length(bin)
                                    [EEG.EVENTLIST.bdf(bin(ib)).rthomeflag(p,icol)] = deal(newflag);
                              end
                        end
                  end
            end
      end
end






