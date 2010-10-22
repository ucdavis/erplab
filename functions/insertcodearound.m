% Usage
%
% EEG = insertcodearound(EEG, mastercode, newcode, newlate)
%
% EEG          - EEG structure (from EEGLAB)
% mastercode   - array of codes that need neighbor(s) code(s)
% newcode      - new code(s) to insert  (new neighbor(s) code(s))
% newlat       - latency(ies) in msec for the new code(s) to insert  (new neighbor(s) code(s) latency(ies))
%
% Note:   mastercode, newcode, and newlate must have the same length.
%
% Example 1:
%
% 1)Insert a new code 78  400ms after each code 14
%
% >> EEG = insertcodearound(EEG, 14, 78, 400);
%
%
% Example 2:
%
% 2)Insert a new code 30  200ms before each code 120
%
% >> EEG = insertcodearound(EEG, 120, 30, -200);
%
%
% Example 3:
%
% 3)Insert two new codes around each code 102:
%    - a code 254 200msec earlier
%    - and a code 255 300ms later.
%
% >>EEG = insertcodearound(EEG, [102 102], [254 255], [-200 300]);
%
%
% Example 4:
%
% 3)Insert a new code 'LeftResp'  1000 ms before each code 'L1'
%
% >>EEG = insertcodearound(EEG, 'L1', 'LeftResp', -1000);
%
%
% Example 5:
%
% 3)Insert a new code 'LeftResp'  1000 ms before each code 'L1' and code 'RightResp' 1000 after 'R1'
%
% >>EEG = insertcodearound(EEG, {'L1', 'R1'}, {'LeftResp' 'RightResp'}, [-1000 1000]);
%
%
% Example 6:
%
% 3) Replace event code 'Boundary' with event code 'Pause'
%
% >>EEG = insertcodearound(EEG, 'Boundary', 'Pause', 0);
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

function EEG = insertcodearound(EEG, mastercode, newcode, newlate)

if nargin<1
        help insertcodearound
        return
end
if nargin>4
        error('ERPLAB says: Error, insertcodearound needs 4 parameters ')
end

auxevent = EEG.event;

%
% Any other custom EEG.event field
%
names   = fieldnames(auxevent);
names   = names(~ismember(names, {'type','latency', 'duration', 'urevent'})); % only extra event fields
lename  = length(names);
nevent  = length(auxevent);
latpnts = round(newlate*EEG.srate/1000);  %ms to sample

if isnumeric(mastercode) || iscell(mastercode)
        nmastercode = length(mastercode);
else
        nmastercode = size(mastercode,1);
end
if isnumeric(newcode) || iscell(newcode)
        nnewcode = length(newcode);
else
        nnewcode = size(newcode,1);
end

if nmastercode~=nnewcode || nnewcode~=length(newlate)
        error('ERPLAB says: At insertcodearound(), mastercode, newcode, and newlate must be of same lenght')
end

issuccess  = 0;

for c=1:nmastercode
        
        if iscell(newcode)
                newcodeK = newcode{c};
        else
                if isnumeric(newcode)
                        newcodeK = newcode(c);
                else
                        newcodeK = newcode;
                end
        end
        if iscell(mastercode)
                mastercodeK = mastercode{c};
        else
                if isnumeric(mastercode)
                        mastercodeK = mastercode(c);
                else
                        mastercodeK = mastercode;
                end
        end
        if ischar(auxevent(1).type) % string eventcodes
                if isnumeric(mastercodeK)
                        mastercodeK = num2str(mastercodeK);
                        fprintf('\n\nWARNING: master code was converted into string code to match the EEG.event current format.\n\n')
                end
                if isnumeric(newcodeK)
                        newcodeK = num2str(newcodeK);
                        fprintf('\n\nWARNING: new code was converted into string code to match the EEG.event current format.\n\n')
                end
                
                anystr = regexp(mastercodeK,'[*]$','match');
                
                if ~isempty(anystr)
                        mastercodestr = mastercodeK;
                        mastercodeK = char(regexprep(mastercodeK,'[*]',''));
                        indexcode = strmatch(mastercodeK,{auxevent.type});
                else
                        indexcode = strmatch(mastercodeK,{auxevent.type},'exact');
                        mastercodestr = mastercodeK;
                end
                
                newcodeKstr = newcodeK;
                
        else % numeric eventcodes
                if ischar(mastercodeK)
                        mastercodeK = str2num(mastercodeK);
                        
                        if isempty(mastercodeK)
                                error('ERPLAB says: Error,  Your event codes are numerical, so your master code has to be as well.')
                        else
                                fprintf('\n\nWARNING: master code was converted into numeric code to match the EEG.event current format.\n\n')
                        end
                end
                if ischar(newcodeK)
                        newcodeK = str2num(newcodeK);
                        if isempty(newcodeK)
                                error('ERPLAB says: Error, Your event codes are numerical, so your new code has to be as well.')
                        else
                                fprintf('\n\nWARNING: master code was converted into numeric code to match the EEG.event current format.\n\n')
                        end
                end
                
                indexcode     = find(cell2mat({auxevent.type}) == mastercodeK);
                mastercodestr = num2str(mastercodeK);
                newcodeKstr = num2str(newcodeK);
        end
        
        if ~isempty(indexcode)
                if latpnts(c)==0  % replacement option
                        [auxevent(indexcode).type ]  = deal(newcodeK);
                        fprintf('\n\nWARNING: master code %s was replaced by new code %s. \n',mastercodestr, newcodeKstr)
                        fprintf('If this was not what you expected, please check your new latencies.\n')
                        fprintf('Take into account that your sample rate is fs=%g [Hz], then your time resolution is Ts=%.2f [msec].\n\n',...
                                EEG.srate,1000/EEG.srate)
                else   % insert option
                        latencies = cell2mat({auxevent(indexcode).latency});
                        ncatchcod = length(indexcode);
                        [auxevent(nevent+1:nevent+ncatchcod).type ]  = deal(newcodeK);
                        newlatArray = num2cell(latencies + latpnts(c));
                        [auxevent(nevent+1:nevent+ncatchcod).latency]= newlatArray{:};
                        
                        for j=1:lename
                                if ischar(auxevent(1).(names{j}))
                                        [auxevent(nevent+1:nevent+ncatchcod).(names{j}) ]  = deal('edit');
                                else
                                        Modevalue = mode([auxevent(1:nevent).(names{j})]);
                                        [auxevent(nevent+1:nevent+ncatchcod).(names{j}) ]  = deal(Modevalue);
                                end
                        end
                end
                
                issuccess  = 1;
                nevent     = length(auxevent);
        else
                issuccess  = 0;
                fprintf('\n************** Event code %s was not found in this dataset **************\n\n', mastercodestr)
        end
end

if issuccess==1
        EEG.event = auxevent;
        EEG = eeg_checkset( EEG , 'eventconsistency');
end

