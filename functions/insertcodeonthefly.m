% PURPOSE: subroutine for pop_insertcodeonthefly.m
%          inserts event code when signal amplitude meets a specific criterion.
%
% FORMAT
%
% EEG = insertcodeonthefly(EEG, newcode, channel, rela, thresh, refract, absolud, windowsam, durapercen, latoffset)
%
% INPUTS:
%
% EEG          - EEG structure (from EEGLAB)
% newcode      - new code to be inserted (1 value)
% channel      - working channel. Channel with the phenomenon of interest (1 or more values)
% rela         - relational operator. Operator that tests the kind of relation
%                between signal's amplitude and  thresh. (1 or more values between 1 and 7)
%
%               1 or 2 '=='  is equal to (you can also use just '=')
%               3      '~='  is not equal to
%               4      '<'   is less than
%               5      '<='  is less than or equal to
%               6      '>='  is greater than or equal to
%               7      '>'   is greater than
%
% thresh       - threshold value(current EEG recording amplitude units. Mostly uV). (1 or more values)
% refract      - period of time in msec, following the current detection,
%                which does not allow a new detection.
%
% IMPORTANT NOTE: newcode, channel, rela, and threshold must have the same amount of elements.
%
% Example:
%
% 1)Insert a new code 999 when channel 37 is greater or equal to 60 uV.
%   Use a refractory period of 600 ms.
%
% EEG = insertcodeonthefly(EEG, 999, 37, '>=', 60, 600);
%
%
% See also pop_insertcodeonthefly.m
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function EEG = insertcodeonthefly(EEG, newcode, channel, rela, thresh, refract, absolud, windowsam, durasam, latoffset)

if nargin<1
        help insertcodeonthefly
        return
end
if nargin>10
        disp('ERPLAB says: error at insertcodeonthefly.  more than 10 inputs were detected.')
        return
end
if ~isempty(EEG.epoch)
        error('ERPLAB says: error at insertcodeonthefly().  Only works with continuous data.')
end
if ~isempty(EEG.event)
        if isfield(EEG.event, 'type')
                if ischar(EEG.event(1).type)
                        newcode = num2str(newcode); % convert numeric event code to string one.
                end
        end
end
if nargin<10
        latoffset = 0;
end
if nargin<9
        durasam = 1;
end
if nargin<8
        windowsam = 1;
end

% number of current events
nevent     = length(EEG.event);
% refarctory period in samples
refracsamp   = round((refract/1000)*EEG.srate);
% latency offset in samples
latoffsetsam = round((latoffset/1000)*EEG.srate);
% pecentage of windowsam
% durasam      = round(durapercen*windowsam/100);

% If duration does not exist...
if ~isfield(EEG.event,'duration')
        dura  = num2cell(zeros(1,nevent));
        [EEG.event(1:nevent).duration] = dura{:};
end

% total point of the continuous EEG
npoints = EEG.pnts;
n = nevent+1; % next event
ii = 1;
toggle =1;
p=0;
k=0;
lat=0; % bug fixed (Thanks Tom Campbell)

if absolud==1
        datax = abs(EEG.data(channel,:));
else
        datax = EEG.data(channel,:);
end

fprintf('\nPlease wait, ...........\n\n');

%
% Any other custom EEG.event field
%
names   = fieldnames(EEG.event);
names   = names(~ismember_bc2(names, {'type','latency', 'duration', 'urevent'})); % only extra event fields
lename  = length(names);
% nevent  = length(auxevent);
% latpnts = round(newlate*EEG.srate/1000);  %ms to sample
nchan = length(channel);
%forstr = [repmat('\b',1,11) '%6.2f%% ...'];
fprintf('Searching...\n');
while ii <= npoints
        ch=1;cond = 1;
        while  ch<=nchan && cond==1
                switch rela(ch)
                        case {1,2} % ==
                                condch = datax(ch,ii)==thresh(ch);
                        case 3 % ~=
                                condch = datax(ch,ii)~=thresh(ch);
                        case 4 % <
                                condch = datax(ch,ii)<thresh(ch);
                        case 5 % <=
                                condch = datax(ch,ii)<=thresh(ch);
                        case 6 % >=
                                condch = datax(ch,ii)>=thresh(ch);
                        case 7 % >
                                condch = datax(ch,ii)>thresh(ch);
                    otherwise
                        error('!!!')
                end
                ch=ch+1;
                cond = cond & condch;  % cond is true if all specified channels meet the correspondig conditions;
        end       
        if cond && toggle
                lat = ii;
                toggle = 0;
                p = 1;
        elseif cond && ~toggle
                p = p + 1;
        end
        if toggle==0
                k = k+1;
        end
        if k==windowsam
                if p>=durasam && lat>0 % bug fixed (Thanks Tom Campbell)
                        EEG.event(n).type     = newcode;
                        EEG.event(n).latency  = lat + latoffsetsam;
                        EEG.event(n).duration = 0;
                        EEG.event(n).urevent  = n;
                        
                        for j=1:lename
                              %names{j}
                              %{EEG.event.(names{j})}
                                v = vogue({EEG.event.(names{j})});
                                [EEG.event(n).(names{j})]  = deal(v); % fill extra fields
                        end
                        
                        n = n + 1;
                        %next search will start refracsamp samples later
                        ii = lat + refracsamp;
                end
                k = 0;
                p = 0;
                toggle = 1;
        else
                ii =  ii + 1;
        end
        %fprintf(1, forstr, 100*i/npoints);
end
%fprintf('\n');
% sort all events!
EEG = eeg_checkset( EEG , 'eventconsistency');
% disp('Done.')
