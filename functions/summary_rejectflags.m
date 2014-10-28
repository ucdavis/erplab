% PURPOSE:  summarizes marked flag for artifact detection
%
% FORMAT
% 
% histoflags = summary_rejectflags(EEG);
% 
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon 
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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

function histoflags = summary_rejectflags(EEG)

if isempty(EEG.epoch)
        error('ERPLAB: summary_rejectflags() only works with epoched dataset')
end

ntrial  = EEG.trials;
nbin    = EEG.EVENTLIST.nbin;
oldflag = zeros(1,ntrial);

for b=1:nbin
        for i=1:ntrial
                if length(EEG.epoch(i).eventlatency) == 1
                        binix = [EEG.epoch(i).eventbini];
                        if iscell(binix)
                                binix = cell2mat(binix);
                        end
                        if ismember(b, binix)                                
                                flagx = [EEG.epoch(i).eventflag];                                
                                if iscell(flagx)
                                        flagx = cell2mat(flagx);
                                end                                
                                oldflag(b,i)   = flagx;
                        else
                                oldflag(b,i) =0;
                        end
                elseif length(EEG.epoch(i).eventlatency) > 1                        
                        indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0,1,'first'); % catch zero-time locked type                        
                        if ismember(b, EEG.epoch(i).eventbini{indxtimelock})
                                oldflag(b,i)   = EEG.epoch(i).eventflag{indxtimelock};
                        else
                                oldflag(b,i) =0;
                        end
                else
                        errorm  = 1;
                end
        end
end

histoflags = zeros(1,16);
flagbit    = bitshift(1, 0:15);

for b=1:nbin
        for j=1:16
                C = bitand(flagbit(j), oldflag(b,:));
                histoflags(b,j) = nnz(C);
        end
end
