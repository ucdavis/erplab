% DEPRECATED
%
%
%
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

function EEG = insertcodeperi(EEG, newcode, guidecode, channel, swindow, rela, thresh, refract, absolud)

if nargin<6
        disp('Error: insertcodeperi needs 6 parameters ')
        return
end

nguidecode =  length(guidecode);
fs         = EEG.srate;
npoints    = EEG.pnts;
datax      = EEG.data(channel,:);
refracsamp = round((refract/1000)*fs);


for c=1:nguidecode

      indexcode = find(cell2mat({EEG.event.type}) == guidecode(c)); % catchs guidecode inside rowdata
      indexlate = cell2mat({EEG.event(indexcode).latency});         % catchs guidecode's latency in rowdata
      ncatchcod = length(indexcode);
      swindpnts = round((swindow/1000)*fs);

      k = 1;

      h = waitbar(0,'Please wait...');
      for g=1:ncatchcod
            
            la = round(indexlate(g));
            p1 = la-swindpnts(1);
            p2 = la+swindpnts(2);
            
            if p2>npoints
                  p2=npoints;
            end      

            if absolud==1
                  datax = abs(EEG.data(channel,:));
            else
                  datax = EEG.data(channel,:);
            end

            numevent = length(EEG.event);
            n = numevent+1;
            i = p1;

            while i <= p2

                  switch rela
                        case {1,2} % ==
                              cond = datax(1,i)==thresh;
                        case 3 % ~=
                              cond = datax(1,i)~=thresh;
                        case 4 % <
                              cond = datax(1,i)<thresh;
                        case 5 % <=
                              cond = datax(1,i)<=thresh;
                        case 6 % >=
                              cond = datax(1,i)>=thresh;
                        case 7 % >
                              cond = datax(1,i)>thresh;
                  end

                  if cond
                        % adding a new event (and latency) at the end of the field
                        EEG.event(n).type     = newcode;
                        EEG.event(n).latency  = i;
                        EEG.event(n).duration = 0;
                        n = n + 1;
                        %next search will start refracsamp samples later
                        i = i + refracsamp;
                  else
                        %next search will start at the next sample
                        i = i + 1;
                  end
            end
            waitbar(g/ncatchcod)
      end
      close(h) 
      % sort all events!
      EEG = eeg_checkset( EEG , 'eventconsistency');
end
