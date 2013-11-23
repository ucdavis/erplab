% PURPOSE  : subroutine for pop_eventshuffler.m
%            shuffles event codes or bin indices (e.g. for permutation analysis)
%
% FORMAT   :
%
% EEG = eventshuffler(EEG, valueatfield, specfield)
%
% INPUTS   :
%
%         EEG              - input dataset
%         valueatfield     - codes or bin indices to shuffle. It can be any numerical value or the string 'all'
%         specfield        - for shuffling numeric event codes-> 0
%                            for shuffling bin indices-> 1
%
% OUTPUTS  :
%
% EEG              - updated dataset
%
%
% EXAMPLE  : Shuffle event codes 121 and 149
%
% EEG = pop_eventshuffler(EEG, [121 149], );
%
%
% See also pop_eventshuffler.m
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


function EEG = eventshuffler(EEG, valueatfield, specfield)
if nargin<1
        help eventshuffler
        return
end
if nargin<2
        specfield = 0; % codes {default}
end
if specfield==0 || specfield==2  % codes or samples
        %
else % bins
        if isfield(EEG, 'EVENTLIST')
                if isempty(EEG.EVENTLIST)
                        %fprintf('\nWARNING: eventshuffler() did not shuffle your bins.\n');
                        error('ERPLAB says: eventshuffler() cannot work on an empty EEG.EVENTLIST structure.');
                end
        else
                %fprintf('\nWARNING: eventshuffler() did not shuffle your bins.\n');
                error('ERPLAB says: eventshuffler() cannot shuffle bins without EEG.EVENTLIST structure.');
        end
end
if specfield~=2 % not samples
        if isnumeric(valueatfield) && length(valueatfield)>1
                if specfield==0
                        if isfield(EEG, 'EVENTLIST') && ~isempty(EEG.EVENTLIST)
                                indx = find(ismember_bc2([EEG.EVENTLIST.eventinfo.code], valueatfield));
                        else
                                indx = find(ismember_bc2([EEG.event.type], valueatfield));
                        end
                else
                        k=1;
                        for a=1:length(EEG.EVENTLIST.eventinfo)
                                if nnz(ismember_bc2( valueatfield, [EEG.EVENTLIST.eventinfo(a).bini]))>0;
                                        indx(k) = a;
                                        k = k+1;
                                end
                        end
                end
        elseif ischar(valueatfield) && strcmpi(valueatfield, 'all')
                if specfield==0
                        indx = 1:length(EEG.EVENTLIST.eventinfo);
                else
                        k=1;
                        for a=1:length(EEG.EVENTLIST.eventinfo)
                                if nnz([EEG.EVENTLIST.eventinfo(a).bini]>0)>0
                                        indx(k) = a;
                                        k = k+1;
                                end
                        end
                end
        else
                %fprintf('\nWARNING: eventshuffler() did not shuffle your %ss.\n', w);
                error('ERROR:eventshuffler', ['ERPLAB says: eventshuffler() needs two or more codes to do the job.\n'...
                        'For shuffling all your codes please specify ''all'' as the second input']);
        end
end
if specfield==0 && isempty(EEG.epoch) % shuffle codes (only continuous)
        if isfield(EEG, 'EVENTLIST') && ~isempty(EEG.EVENTLIST)
                codes  = [EEG.EVENTLIST.eventinfo(indx).code];
                ncodes = length(codes);
                p      = randperm(ncodes);
                codes  = num2cell(codes(p));
                [EEG.EVENTLIST.eventinfo(indx).code] = codes{:};
                EEG = pop_overwritevent( EEG, 'code');
        else
                codes  = [EEG.event(indx).type];
                ncodes = length(codes);
                p      = randperm(ncodes);
                codes  = num2cell(codes(p));
                [EEG.event(indx).type] = codes{:};
        end
elseif specfield==1 % shuffle bins (continuous & epoched)
        if isempty(EEG.epoch) % continuous
                nindx = length(indx);
                p     = randperm(nindx);
                rindx = indx(p);                
                for a=1:length(indx)
                        bini   = EEG.EVENTLIST.eventinfo(rindx(a)).bini;
                        flag   = EEG.EVENTLIST.eventinfo(rindx(a)).flag;
                        enable = EEG.EVENTLIST.eventinfo(rindx(a)).enable;                        
                        EEG.EVENTLIST.eventinfo(indx(a)).bini   = bini;
                        EEG.EVENTLIST.eventinfo(indx(a)).flag   = flag;
                        EEG.EVENTLIST.eventinfo(indx(a)).enable = enable;
                        
                        % Creates BIN LABELS
                        auxname = num2str(bini);
                        bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % inserts a comma instead blank space
                        
                        if strcmp(EEG.EVENTLIST.eventinfo(rindx(a)).codelabel,'""')
                                binName = ['B' bname '(' num2str(EEG.EVENTLIST.eventinfo(rindx(a)).code) ')']; %B#(code)
                        else
                                binName = ['B' bname '(' EEG.EVENTLIST.eventinfo(rindx(a)).codelabel ')']; %B#(codelabel)
                        end
                        
                        EEG.EVENTLIST.eventinfo(indx(a)).binlabel = binName;
                end                
                EEG = pop_overwritevent( EEG, 'binlabel');
        else
                %fprintf('\nWARNING: eventshuffler() did not shuffle your %ss.\n', w);
                error('ERPLAB says: eventshuffler() can shuffle events in continuous data only.');
                %nepoch = EEG.trials;
                %for e=1:nepoch
                %
                %end
        end
elseif specfield==2 % shuffle samples (continuous & epoched)
        nchan  = EEG.nbchan;
        pnts   = EEG.pnts;
        trials = length(EEG.epoch);
        if trials==0
                trials=1;
        end
        for k=1:nchan
                for t=1:trials
                        shfflindex = randperm(pnts);
                        EEG.data(k, :, t) = EEG.data(k, shfflindex, t);
                end
        end
else
        %fprintf('\nWARNING: eventshuffler() did not shuffle your %ss.\n', w);
        error('ERPLAB says: eventshuffler() does not recognize this type of shuffling...');
end

% EEG = eeg_checkset( EEG );































