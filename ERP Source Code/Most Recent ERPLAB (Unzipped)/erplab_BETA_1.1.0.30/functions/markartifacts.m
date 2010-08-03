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

function [EEG errorm]= markartifacts(EEG, flagv, chanArray, ch, i)

errorm = 0;
EEG.reject.rejmanual(i) = 1;
EEG.reject.rejmanualE(chanArray(ch), i) = 1;
lf = length(flagv);

for f=1:lf
        flag = flagv(f);
        if flag>=1 && flag<=8
                if length(EEG.epoch(i).eventlatency) == 1
                        
                        oldflag = EEG.epoch(i).eventflag;
                        
                        if iscell(oldflag)
                                oldflag = cell2mat(oldflag);
                        end
                        
                        newflag =  bitset(oldflag, flag);
                        EEG.epoch(i).eventflag = {newflag};
                        
                        xitem = EEG.epoch(i).eventitem;
                        
                        if iscell(xitem)
                                item    = cell2mat(xitem); % this is the position at the continuous eventlist!
                        else
                                item = xitem;
                        end
                        
                        EEG.EVENTLIST.eventinfo(item).flag = newflag;
                        
                elseif length(EEG.epoch(i).eventlatency) > 1
                        indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0,1,'first'); % catch zero-time locked type,
                        oldflag = EEG.epoch(i).eventflag{indxtimelock};
                        
                        newflag =  bitset(oldflag, flag);
                        EEG.epoch(i).eventflag{indxtimelock} = newflag;
                        item    = EEG.epoch(i).eventitem{indxtimelock}; % this is the position at the continuous eventlist!
                        EEG.EVENTLIST.eventinfo(item).flag = newflag;
                else
                        errorm  = 1;
                end
                
        elseif flag<0 || flag>16
                errorm = 2;
        end
end