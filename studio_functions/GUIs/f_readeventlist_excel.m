% PURPOSE: reads an EVENTLIST from a .xls file
%
% FORMAT:
%
% [EEG EVENTLIST] = f_readeventlist_excel(EEG, elfilename );
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

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

function [EEG EVENTLIST] = f_readeventlist_excel(EEG, elfilename )

fprintf('reading EVENTLIST...\n');

if nargin<1
    help f_readeventlist_excel
    return
elseif nargin>2
    error('ERPLAB says: error at f_readeventlist_excel().  To many INPUTs!!!\n');
end

EVENTLIST = [];
fid_bl    = fopen( elfilename );

%
% Reads Header
%
EVENTLIST.bdf = [];
isbin  = 1;
detect = 0;
nada   = 0;
j      = 1;

% while isbin
%         p0     = ftell(fid_bl);
%         tdatas = textscan(fid_bl, '%[^\n]',1);
%         [lmatch ltoken] = regexpi(char(tdatas{1}), 'bin\s*(\d+),\s*#\s*(\d+),\s*(.+)','match', 'tokens');
%         firstitem = regexpi(char(tdatas{1}), '^1', 'match');
%
%         if ~isempty(ltoken)
%                 EVENTLIST.trialsperbin(j)    = str2num(char(ltoken{1}{2}));    % first check. Counter of captured eventcodes per bin
%                 EVENTLIST.bdf(1,j).expresion = {};
%                 EVENTLIST.bdf(j).description =  strtrim(char(ltoken{1}{3}));
%                 EVENTLIST.bdf(j).prehome     = {};
%                 EVENTLIST.bdf(j).athome      = {};
%                 EVENTLIST.bdf(j).posthome    = {};
%                 EVENTLIST.bdf(j).namebin     = ['BIN ' num2str(j)];
%                 j = j+1;
%                 detect = 1;
%                 position = ftell(fid_bl);
%         elseif isempty(ltoken) && detect
%                 isbin=0;
%         else
%                 if isempty(firstitem)
%                         nada = nada + 1;
%                         if nada>100
%                                 fprintf('\nWARNING: readbinlist() did not find any bin summary.\n');
%                                 fprintf('Now, reading event''s information...\n\n');
%                                 position = p0;
%                                 isbin=0;
%                         end
%                 else
%                         position = p0;
%                         isbin=0;
%                 end
%         end
% end

% EVENTLIST.info.flink = elfilename;
try
    EVENTLIST.trialsperbin    =EEG.EVENTLIST.trialsperbin;
catch
    EVENTLIST.trialsperbin = [];
end
% first check. Counter of captured eventcodes per bin
try
    EVENTLIST.bdf = EEG.EVENTLIST.bdf;
catch
    EVENTLIST.bdf =[];
end


% fseek(fid_bl, position, 'bof');
xbin = [];
currentline= readtable(elfilename);
currentline = table2cell(currentline);

for k = 1:size(currentline,1)
    EVENTLIST.eventinfo(k).item     = str2num(char(currentline{k,1}));
    EVENTLIST.eventinfo(k).bepoch   = str2num(char(currentline{k,2}));
    EVENTLIST.eventinfo(k).code     = str2num(char(currentline{k,3}));
    EVENTLIST.eventinfo(k).codelabel= char(currentline{k,4});
    EVENTLIST.eventinfo(k).time     = single(str2num(char(currentline{k,5})));
    EVENTLIST.eventinfo(k).spoint   = 0;
    EVENTLIST.eventinfo(k).dura     = single(str2num(char(currentline{k,7}))); % thanks to Ahren Fitzroy
    EVENTLIST.eventinfo(k).flag     = bin2dec([char(currentline{k,8}) char(currentline{k,9})]);
    EVENTLIST.eventinfo(k).enable   = str2num(char(currentline{k,10}));
    EVENTLIST.eventinfo(k).bini     = str2num(char(currentline{k,11}));
    
    if isempty(EVENTLIST.eventinfo(k).bini)
        EVENTLIST.eventinfo(k).binlabel    = '""';
        EVENTLIST.eventinfo(k).bini = -1; % 8/19/2009
    else
        auxname = num2str(EVENTLIST.eventinfo(k).bini);
        bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % inserts a comma instead blank space
        binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(k).code) ')']; %B#(Code)
        EVENTLIST.eventinfo(k).binlabel  = binName;
        
        xbin = [xbin EVENTLIST.eventinfo(k).bini];
    end
    %     k = k+1;
    
end


if isfield(EEG,'srate')
    srate = EEG.srate;
    %         EVENTLIST.info.srate = srate;
else
    Ts = mode(diff([EVENTLIST.eventinfo.time]));
    srate = 1/Ts;
end

neve = length(EVENTLIST.eventinfo);
spo  = num2cell([EVENTLIST.eventinfo.time]*srate+1);
[EVENTLIST.eventinfo(1:neve).spoint] = spo{:};
ubin = 1:max(unique_bc2(xbin)); %2/14/2010
lbin = length(ubin);
binaux    = [EVENTLIST.eventinfo.bini]; % pending: see multiple bins case...
binhunter = sort(binaux(binaux>0)); %8/19/2009
EVENTLIST.nbin  = lbin;

if lbin>=1
    for q=1:lbin
        EVENTLIST.trialsperbin(q) = nnz(ismember_bc2(binhunter,q)); % 2/14/2010
    end
else
    EVENTLIST.trialsperbin = 0;
    fprintf('\nWARNING: f_readeventlist_excel() did not found bin assigned.\n');
    fprintf('You will need to use Create EventList or Binlister as a further step.\n\n');
end

[EEG EVENTLIST] = creaeventlist(EEG, EVENTLIST,'', 0);
