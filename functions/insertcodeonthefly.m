% Usage
%
% >> EEG = insertcodeonthefly(EEG, newcode, channel, relop, thresh, refract)
%
% EEG          - EEG structure (from EEGLAB)
% newcode      - new code to be inserted (1 value)
% channel      - working channel. Channel with the phenomenon of interest (1 value)
% rela         - relational operator. Operator that tests the kind of relation
%                between signal's amplitude and  thresh. (1 value between 1 and 7)
%
%               1 or 2 '=='  is equal to (you can also use just '=')
%               3      '~='  is not equal to 
%               4      '<'   is less than 
%               5      '<='  is less than or equal to 
%               6      '>='  is greater than or equal to 
%               7      '>'   is greater than
%
% thresh       - threshold value(current EEG recording amplitude units. Mostly uV)
% refract      - period of time in msec, following the current detection,
%                which does not allow a new detection.
%
% Example:
%
% 1)Insert a new code 999 when channel 37 is greater or equal to 60 uV.
%   Use a refractory period of 600 ms.
%
% >> EEG = insertcodeonthefly(EEG, 999, 37, '>=', 60, 600);
%
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

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

function EEG = insertcodeonthefly(EEG, newcode, channel, rela, thresh, refract, absolud, windowsam, durapercen)

if nargin<1
        help insertcodeonthefly
        return
end
if nargin>9
        disp('ERPLAB says: error at insertcodeonthefly.  9 inputs are needed for this function.')
        return
end
if ~isempty(EEG.epoch)
        error('ERPLAB says: error at insertcodeonthefly().  Only works with continuous data.')
end

if ischar(EEG.event(1).type)
        newcode = num2str(newcode); % convert numeric event code to string one.
end


if nargin<9
        durapercen = 100;
end
if nargin<8
        windowsam = 1;
end

% number of current events
nevent     = length(EEG.event);
% refarctory period in samples
refracsamp = round((refract/1000)*EEG.srate);
durasam    = round(durapercen*windowsam/100); % x pecentage of windowsam

% If duration does not exist...
if ~isfield(EEG.event,'duration')
        dura  = num2cell(zeros(1,nevent));
        [EEG.event(1:nevent).duration] = dura{:};
end

% total point of the continuous EEG
npoints = EEG.pnts;
n = nevent+1; % next event
i = 1;
toggle =1;
p=0;
k=0;

if absolud==1
        datax = abs(EEG.data(channel,:));
else
        datax = EEG.data(channel,:);
end

fprintf('\nPlease wait, this could take several seconds...\n\n'); 

%
% Any other custom EEG.event field
%
names   = fieldnames(EEG.event);
names   = names(~ismember(names, {'type','latency', 'duration', 'urevent'})); % only extra event fields
lename  = length(names);
% nevent  = length(auxevent);
% latpnts = round(newlate*EEG.srate/1000);  %ms to sample

while i <= npoints
              
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

        if cond && toggle
                lat = i;
                toggle = 0;
                p = 1;
        elseif cond && ~toggle
                p = p + 1;
        end
        
        if toggle==0
                k = k+1;
        end
        
        if k==windowsam
                if p>=durasam
                        EEG.event(n).type     = newcode;
                        EEG.event(n).latency  = lat;
                        EEG.event(n).duration = 0;
                        EEG.event(n).urevent  = n;
                        
                        for j=1:lename
                                v = vogue({EEG.event.(names{j})});                                
                                [EEG.event(n).(names{j})]  = deal(v); % fill extra fields
                        end
                        
                        n = n + 1;
                        %next search will start refracsamp samples later
                        i = lat + refracsamp;
                end
                k = 0;
                p = 0;
                toggle = 1;
        else
                i =  i + 1;
        end
end

% sort all events!
EEG = eeg_checkset( EEG , 'eventconsistency');
% disp('Done.')
