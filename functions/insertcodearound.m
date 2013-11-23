% PURPOSE: subroutine for pop_insertcodearound.m
%          inserts event code(2) at specific latency(ies)
%
% FORMAT:
%
% EEG = insertcodearound(EEG, targetcode, newcode, newlate)
%
% INPUTS:
%
% EEG          - EEG structure (from EEGLAB)
% targetcode   - array of codes that need neighbor(s) code(s)
% newcode      - new code(s) to insert  (new neighbor(s) code(s))
% newlat       - latency(ies) in msec for the new code(s) to insert  (new neighbor(s) code(s) latency(ies))
%
% Note:   targetcode, newcode, and newlate must have the same length.
%
%
% OUTPUT
%
% EEG          - EEG structure 
%
%
% Example 1:
%
% 1)Insert a new code 78  400ms after each code 14
%
% EEG = insertcodearound(EEG, 14, 78, 400);
%
%
% Example 2:
%
% 2)Insert a new code 30  200ms before each code 120
%
% EEG = insertcodearound(EEG, 120, 30, -200);
%
%
% Example 3:
%
% 3)Insert two new codes around each code 102:
%    - a code 254 200msec earlier
%    - and a code 255 300ms later.
%
% EEG = insertcodearound(EEG, [102 102], [254 255], [-200 300]);
%
%
% Example 4:
%
% 3)Insert a new code 'LeftResp'  1000 ms before each code 'L1'
%
% EEG = insertcodearound(EEG, 'L1', 'LeftResp', -1000);
%
%
% Example 5:
%
% 3)Insert a new code 'LeftResp'  1000 ms before each code 'L1' and code 'RightResp' 1000 after 'R1'
%
% EEG = insertcodearound(EEG, {'L1', 'R1'}, {'LeftResp' 'RightResp'}, [-1000 1000]);
%
%
% Example 6:
%
% 3) Replace event code 'Boundary' with event code 'Pause'
%
% EEG = insertcodearound(EEG, 'Boundary', 'Pause', 0);
%
%
% See also pop_insertcodearound.m
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

function EEG = insertcodearound(EEG, targetcode, targetbin, newcode, newlate)
if nargin<1
        help insertcodearound
        return
end
if nargin~=5
        error('ERPLAB says: Error, insertcodearound needs 4 parameters ')
end

auxevent = EEG.event;

%
% Any other custom EEG.event field
%
names   = fieldnames(auxevent);
names   = names(~ismember_bc2(names, {'type','latency', 'duration', 'urevent'})); % only extra event fields
lename  = length(names);
nevent  = length(auxevent);
latpnts = round(newlate*EEG.srate/1000);  %ms to sample

if ~isempty(targetcode) && isempty(targetbin)
        if isnumeric(targetcode) || iscell(targetcode)
                ntargetcode = length(targetcode);
        else
                ntargetcode = size(targetcode,1);
        end    
        searchmode = 1; % code
elseif isempty(targetcode) && ~isempty(targetbin)        
        if ~isfield(EEG.event, 'bini')
                error('ERPLAB says: Error, You specified "targetbin" but EEG.event.bini field does not exist. Run Binlister first.');
        end
        if isnumeric(targetbin) || iscell(targetbin)
                ntargetbin = length(targetbin);
        else
                ntargetbin = size(targetbin,1);
        end      
        searchmode = 2; % bin
elseif ~isempty(targetcode) && ~isempty(targetbin)        
        error('ERPLAB says: Error, You can specify either targetcode or targetbin but not both...');
else
        error('ERPLAB says: Error, You can specify either targetcode or targetbin but not none...');
end
if isnumeric(newcode) || iscell(newcode)
        nnewcode = length(newcode);
else
        nnewcode = size(newcode,1);
end
if searchmode==1 % code
        if ntargetcode~=nnewcode || nnewcode~=length(newlate)
                error('ERPLAB says: At insertcodearound(), targetcode, newcode, and newlate must be of same lenght');
        end
else % bin
        if ntargetbin~=nnewcode || nnewcode~=length(newlate)
                error('ERPLAB says: At insertcodearound(), ntargetbin, newcode, and newlate must be of same lenght');
        end
end

issuccess  = 0;
if searchmode==1 % code
        NN = ntargetcode;
else
        NN = ntargetbin;
end
for c=1:NN
        if iscell(newcode)
                newcodeK = newcode{c};
        else
                if isnumeric(newcode)
                        newcodeK = newcode(c);
                else
                        newcodeK = newcode;
                end
        end
        if searchmode==1 % code
                if iscell(targetcode)
                        targetcodeK = targetcode{c};
                else
                        if isnumeric(targetcode)
                                targetcodeK = targetcode(c);
                        else
                                targetcodeK = targetcode;
                        end
                end
        else % bin
                if iscell(targetbin)
                        targetbinK = targetbin{c};
                else
                        if isnumeric(targetbin)
                                targetbinK = targetbin(c);
                        else
                                targetbinK = targetbin;
                        end
                end
        end
        
        
        
        if searchmode==1 % code
                if ischar(auxevent(1).type) % string eventcodes
                        if isnumeric(targetcodeK)
                                targetcodeK = num2str(targetcodeK);
                                fprintf('\n\nWARNING: master code was converted into string code to match the EEG.event current format.\n\n')
                        end
                        if isnumeric(newcodeK)
                                newcodeK = num2str(newcodeK);
                                fprintf('\n\nWARNING: new code was converted into string code to match the EEG.event current format.\n\n')
                        end
                        anystr = regexp(targetcodeK,'[*]$','match');
                        if ~isempty(anystr)
                                targetcodestr = targetcodeK;
                                targetcodeK   = char(regexprep(targetcodeK,'[*]',''));
                                indexcode     = strmatch(targetcodeK,{auxevent.type});
                        else
                                indexcode     = strmatch(targetcodeK,{auxevent.type},'exact');
                                targetcodestr = targetcodeK;
                        end
                        newcodeKstr = newcodeK;
                else % numeric eventcodes
                        if ischar(targetcodeK)
                                targetcodeK = str2num(targetcodeK);
                                if isempty(targetcodeK)
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
                        
                        indexcode     = find(cell2mat({auxevent.type}) == targetcodeK);
                        targetcodestr = num2str(targetcodeK);
                        newcodeKstr = num2str(newcodeK);
                end
                if ~isempty(indexcode)
                        if latpnts(c)==0  % replacement option
                                [auxevent(indexcode).type ]  = deal(newcodeK);
                                fprintf('\n\nWARNING: master code %s was replaced by new code %s. \n',targetcodestr, newcodeKstr)
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
                        fprintf('\n************** Event code %s was not found in this dataset **************\n\n', targetcodestr)
                end
        else    
                disp('Under Progress...Sorry')
                return
                
                
                %                 auxbini = cell(1);
                %                 for kk=1:length(auxevent)
                %                    if iscell(auxevent(kk).bini)
                %                            auxb = [auxevent(kk).bini{:}];
                %                            if length(auxb)>1
                %                                    auxb = auxb(1); % only 1 bin (first one) is taking as the event's bin. Sorry...
                %                            end
                %                            auxbini{kk} = auxb;
                %                    else
                %                            auxbini{kk} = auxevent(kk).bini;
                %                    end
                %                 end
                %                 if all([auxbini{:}]<1)
                %                         auxeventinfo = EEG.EVENTLIST.eventinfo;
                %                         auxbini = cell(1);
                %                         for kk=1:length(auxeventinfo)
                %                                 if iscell(auxeventinfo(kk).bini)
                %                                         auxb = [auxeventinfo(kk).bini{:}];
                %                                         if length(auxb)>1
                %                                                 auxb = auxb(1); % only 1 bin (first one) is taking as the event's bin. Sorry...
                %                                         end
                %                                         auxbini{kk} = auxb;
                %                                 else
                %                                         auxbini{kk} = auxeventinfo(kk).bini;
                %                                 end
                %                         end
                %                 end
                %
                %                 indexbin     = find(cell2mat(auxbini) == targetbinK); % indices for detected events having the corresponding bin.
                %                 if isnumeric(newcodeK)
                %                         newcodeKstr = num2str(newcodeK);
                %                 else
                %                         newcodeKstr = newcodeK;
                %                 end
                %                 if ~isempty(indexbin)
                %                         if latpnts(c)==0  % replacement option
                %                                 [auxevent(indexbin).type ]  = deal(newcodeK);
                %                                 fprintf('\n\nWARNING: Target bin #%g was replaced by new code %s. \n', targetbinK, newcodeKstr)
                %                                 fprintf('If this was not what you expected, please check your new latencies.\n')
                %                                 fprintf('Take into account that your sample rate is fs=%g [Hz], then your time resolution is Ts=%.2f [msec].\n\n',...
                %                                         EEG.srate,1000/EEG.srate)
                %                         else   % insert option
                %                                 latencies = cell2mat({auxevent(indexbin).latency});
                %                                 ncatchcod = length(indexbin);
                %                                 [auxevent(nevent+1:nevent+ncatchcod).type ]  = deal(newcodeK);
                %                                 newlatArray = num2cell(latencies + latpnts(c));
                %                                 [auxevent(nevent+1:nevent+ncatchcod).latency]= newlatArray{:};
                %
                %                                 for j=1:lename
                %                                         if ischar(auxevent(1).(names{j}))
                %                                                 [auxevent(nevent+1:nevent+ncatchcod).(names{j}) ]  = deal('edit');
                %                                         else
                %                                                 Modevalue = mode([auxevent(1:nevent).(names{j})]);
                %                                                 [auxevent(nevent+1:nevent+ncatchcod).(names{j}) ]  = deal(Modevalue);
                %                                         end
                %                                 end
                %                         end
                %
                %                         issuccess  = 1;
                %                         nevent     = length(auxevent);
                %                 else
                %                         issuccess  = 0;
                %                         fprintf('\n************** Bin #%g was not found in this dataset **************\n\n', targetbinK)
                %                 end
        end
end
if issuccess==1
        EEG.event = auxevent;
        EEG = eeg_checkset( EEG , 'eventconsistency');
%         if searchmode==2 % bin
%                 
%         end
end


