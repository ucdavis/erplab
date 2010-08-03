% Author: Javier Lopez-Calderon & Steven Luck
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

function EVENTLIST = creaeventinfo(EEG, boundarystrcode, newboundarynumcode)

if nargin<1
        help creaeventinfo
end

if nargin<3
        newboundarynumcode = {-99};
end

if nargin<2
        boundarystrcode   = {'boundary'};
end

EVENTLIST.eventinfo = [];

fin = length(EEG.event);

if isfield(EEG.event, 'codelabel')
        codelabel = {EEG.event.codelabel};
        empindx   = find(cellfun(@isempty, codelabel));
        [codelabel{empindx}] = deal('""'); % default value if it is empty
else
        codelabel = repmat({'""'},1,fin);
end

code   = num2cell(NaN(1,fin));

if isempty(boundarystrcode)
        boundarystrcode = '';
        newboundarynumcode = [];
end

if isfield(EEG.event,'type')
        if ischar(EEG.event(1).type)
                for i=1:fin
                        
                        [vty indxty] = ismember(EEG.event(i).type, boundarystrcode);
                        
                        if nnz(vty)>0
                                
                                %
                                % Special case: "boundary"
                                %
                                code{i} = newboundarynumcode{indxty}; % code for boundaries
                                codelabel{i} = 'boundary';
                                fprintf('WARNING: "%s" event, at latency %g (samples), was encoded as %g.\n',...
                                        boundarystrcode{indxty}, EEG.event(i).latency, newboundarynumcode{indxty} )
                                
                        else
                                numc = str2num(EEG.event(i).type);
                                
                                if isempty(numc)
                                        if strcmp(codelabel{i},'""')
                                                codelabel{i} = EEG.event(i).type;
                                        end
                                else
                                        code{i} = numc;
                                end
                        end
                end
                
        else
                code = {EEG.event.type};
        end
end

if isfield(EEG.event,'binlabel')
        binlabel = {EEG.event.binlabel};
        empindx  = find(cellfun(@isempty, binlabel));
        [binlabel{empindx}] = deal('""');% default value if it is empty
else
        binlabel   = repmat({'""'},1,fin);
end

if isfield(EEG.event,'latency')
        spoint  = {EEG.event.latency};
        auxtime = single(([EEG.event.latency]-1)/EEG.srate); % samples points to seconds
        time    = num2cell(auxtime);
else
        time    = num2cell(zeros(1,fin));
end

if isfield(EEG.event,'duration')
        dura  = num2cell((round(([EEG.event.duration]/EEG.srate)*1000))); %msec
else
        dura  = num2cell(zeros(1,fin));
end

if isfield(EEG.event,'flag')
        flag    = {EEG.event.flag};
        empindx = find(cellfun(@isempty, flag));
        [flag{empindx}] = deal(0);% default value if it is empty
else
        flag  = num2cell(zeros(1,fin));
end

if isfield(EEG.event,'enable')
        enable  = {EEG.event.enable};
        empindx = find(cellfun(@isempty, enable));
        [enable{empindx}] = deal(1);% default value if it is empty
else
        enable = num2cell(ones(1,fin));
end

if isfield(EEG.event,'bini')
        bini    = {EEG.event.bini};
        empindx = find(cellfun(@isempty, bini));
        [bini{empindx}] = deal([]); % default value if it is empty
else
        bini  = num2cell(ones(1,fin)*(-1));
end

if isfield(EEG.event,'bepoch')
        bepoch    = {EEG.event.bepoch};
        empindx  = find(cellfun(@isempty, bepoch));
        [bepoch{empindx}] = deal(0); % default value if it is empty
else
        bepoch  = num2cell(zeros(1,fin));
end

%
% Basic eventinfo fields
%
item = num2cell(1:fin);
[EVENTLIST.eventinfo(1:fin).item]      = item{:};
[EVENTLIST.eventinfo(1:fin).code]      = code{:};
[EVENTLIST.eventinfo(1:fin).binlabel]  = binlabel{:};
[EVENTLIST.eventinfo(1:fin).codelabel] = codelabel{:};
[EVENTLIST.eventinfo(1:fin).time]      = time{:};
[EVENTLIST.eventinfo(1:fin).spoint]    = spoint{:};
[EVENTLIST.eventinfo(1:fin).dura]      = dura{:};
[EVENTLIST.eventinfo(1:fin).flag]      = flag{:};
[EVENTLIST.eventinfo(1:fin).enable]    = enable{:};
[EVENTLIST.eventinfo(1:fin).bini]      = bini{:};
[EVENTLIST.eventinfo(1:fin).bepoch]    = bepoch{:};

%
% Additional custom EEG.event fields. If any, eventinfo will take it.
%
names  = fieldnames(EEG.event);
lename = length(names);

for i=1:lename
        if ~ismember(names{i}, {'urevent','type','codelabel','binlabel','latency','duration', ...
                        'flag','enable','bini'})
                [EVENTLIST.eventinfo(1:fin).(names{i})] = EEG.event.(names{i});
        end
end

EVENTLIST.nbin = max([EVENTLIST.eventinfo.bini]);


lbin = EVENTLIST.nbin;
ubin = 1:lbin;
countrb = zeros(1, lbin); % trial per bin counter
binaux    = [EVENTLIST.eventinfo.bini];
binhunter = sort(binaux(binaux>0)); %8/19/2009

if lbin>=1
        [c detbin] = ismember(ubin,binhunter);
        detnonz = nonzeros(detbin)';
        
        if ~isempty(detnonz)
                countra = [detnonz(1) diff(detnonz)];
                countrb(c) = countra;
        end
        
        EVENTLIST.trialsperbin = countrb;
        EVENTLIST.nbin  = length(EVENTLIST.trialsperbin);
else
        EVENTLIST.trialsperbin = 0;
        EVENTLIST.nbin  = 0;
end
