% PURPOSE: subroutine for pop_importeventlist.m
%          imports EVENTLIST, from a text file, into the ERP structure
%
% FORMAT:
%
% [ERP EVENTLIST serror] = importerpeventlist(ERP, elfilename )
%
% INPUTS:
%
% ERP           - ERPset
% elfilename    - text file
%
% OUTPUT
%
% ERP           - EVENTLIST structure
% EVENTLIST     - EVENTLIST structure
% serror        - error flag. 0 means no error; 1 means error found
%
%
% See also pop_importeventlist.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2008

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

function [ERP EVENTLIST serror] = importerpeventlist(ERP, elfilename )

serror = 0; % no error by default

if nargin<1
        help importerpeventlist
        return
elseif nargin>2
        fprintf('importerpeventlist() error:  To many INPUTs!!!\n')
        serror = 1; 
        return
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
fprintf('Working...\n');
while isbin
        
        p0     = ftell(fid_bl);
        tdatas = textscan(fid_bl, '%[^\n]',1);
        [lmatch ltoken] = regexpi(char(tdatas{1}), 'bin\s*(\d+),\s*#\s*(\d+),\s*(.+)','match', 'tokens');
        firstitem = regexpi(char(tdatas{1}), '^1', 'match');
        
        if ~isempty(ltoken)
                
                EVENTLIST.trialsperbin(j)      = str2num(char(ltoken{1}{2}));    % first check. Counter of captured eventcodes per bin
                EVENTLIST.bdf(1,j).expresion   = {};
                EVENTLIST.bdf(1,j).description =  strtrim(char(ltoken{1}{3}));
                EVENTLIST.bdf(1,j).prehome     = {};
                EVENTLIST.bdf(1,j).athome      = {};
                EVENTLIST.bdf(1,j).posthome    = {};
                EVENTLIST.bdf(1,j).namebin     = ['BIN ' num2str(j)];               
                j = j+1;
                detect = 1;
                position = ftell(fid_bl);
                
        elseif isempty(ltoken) && detect
                isbin=0;
        else
                if isempty(firstitem)
                        nada = nada + 1;
                        if nada>100
                                fprintf('\nWARNING: readbinlist() did not find any bin summary.\n');
                                fprintf('Now, reading event''s information...\n\n');
                                position = p0;
                                isbin=0;
                        end
                else
                        position = p0;
                        isbin=0;
                end
        end
end

fseek(fid_bl, position, 'bof');
k = 1;
xbin = [];

while ~feof(fid_bl)
        
        currentline  =  textscan(fid_bl, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s %s\t%s\t%[^\n]', 1);
        firstcar     = strtrim(char(currentline{1})); % first character
        
        if ~strcmp(firstcar, '')
                if ~strcmpi(firstcar(1),'#') && ~strcmpi(firstcar(1),'')
                        
                        EVENTLIST.eventinfo(k).item     = str2num(char(currentline{1}));
                        EVENTLIST.eventinfo(k).bepoch   = str2num(char(currentline{2}));
                        EVENTLIST.eventinfo(k).code     = str2num(char(currentline{3}));
                        EVENTLIST.eventinfo(k).codelabel= char(currentline{4});
                        EVENTLIST.eventinfo(k).time     = single(str2num(char(currentline{5})));
                        EVENTLIST.eventinfo(k).spoint   = 0;
                        EVENTLIST.eventinfo(k).dura     = single(str2num(char(currentline{6})));
                        EVENTLIST.eventinfo(k).flag     = bin2dec([char(currentline{8}) char(currentline{9})]);
                        EVENTLIST.eventinfo(k).enable   = str2num(char(currentline{10}));
                        EVENTLIST.eventinfo(k).bini     = str2num(char(currentline{11}));
                        
                        if isempty(EVENTLIST.eventinfo(k).bini)
                                EVENTLIST.eventinfo(k).binlabel    = '""';
                                EVENTLIST.eventinfo(k).bini = -1; % 8/19/2009
                        else
                                auxname = num2str(EVENTLIST.eventinfo(k).bini);
                                bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % inserts a comma instead blank space
                                binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(k).code) ')']; %B#(Code)
                                EVENTLIST.eventinfo(k).binlabel    = binName;
                                
                                xbin = [xbin EVENTLIST.eventinfo(k).bini];
                        end
                        
                        k = k+1;
                end
        end
end

fclose(fid_bl);

if ~isfield(EVENTLIST, 'eventinfo')
       msgboxText{1} =  sprintf('%s does not seem to be a correct EVENTLIST file to import.',elfilename);
       title = 'ERPLAB: importerpeventlist() Error';
       errorfound(msgboxText, title);
       serror =1;
       return
end

if isfield(ERP,'srate')
        srate = ERP.srate;
else
        
        Ts = mode(diff([EVENTLIST.eventinfo.time]));
        srate = 1/Ts;
end

neve = length(EVENTLIST.eventinfo);
spo  = num2cell([EVENTLIST.eventinfo.time]*srate+1);
[EVENTLIST.eventinfo(1:neve).spoint]   = spo{:};

ubin  = sort(unique_bc2(xbin));
lbin  = length(ubin);

binaux    = [EVENTLIST.eventinfo.bini];
binhunter = sort(binaux(binaux>0)); %8/19/2009

EVENTLIST.nbin  = lbin;

if lbin>=1
        [c, detbin] = ismember_bc2(ubin,binhunter);
        EVENTLIST.trialsperbin = [detbin(1) diff(detbin)];
else
        EVENTLIST.trialsperbin = [];
        fprintf('\nWARNING: importerpeventlist() did not found any assigned bin .\n');
end

fprintf('Total Events (eventcodes + pauses) = %g \n', neve);

if ~isfield(EVENTLIST, 'setname')
        if isfield(ERP, 'workfiles')
                EVENTLIST.setname = ERP.workfiles{1};
        else
                EVENTLIST.setname = 'none_specified';
        end
end
if ~isfield(EVENTLIST, 'report')
        EVENTLIST.report = '';
end
if ~isfield(EVENTLIST, 'bdfname')
        EVENTLIST.bdfname = '';
end
if ~isfield(EVENTLIST, 'nbin')
        EVENTLIST.nbin = [];
end
if ~isfield(EVENTLIST, 'version')
        EVENTLIST.version = geterplabversion;
end
if ~isfield(EVENTLIST, 'account')
        EVENTLIST.account = '';
end
if ~isfield(EVENTLIST, 'username')
        EVENTLIST.username = '';
end
if ~isfield(EVENTLIST, 'trialsperbin')
        EVENTLIST.trialsperbin = [];
end

EVENTLIST.elname  = elfilename;

if isfield(EVENTLIST, 'bdf')
        
        if isempty(EVENTLIST.bdf)
                EVENTLIST.bdf.expression  = [];
                EVENTLIST.bdf.description = [];
                EVENTLIST.bdf.prehome     = [];
                EVENTLIST.bdf.athome      = [];
                EVENTLIST.bdf.posthome    = [];
                EVENTLIST.bdf.namebin     = [];
                EVENTLIST.trialsperbin    = [];
        end
else
        EVENTLIST.bdf.expression  = [];
        EVENTLIST.bdf.description = [];
        EVENTLIST.bdf.prehome     = [];
        EVENTLIST.bdf.athome      = [];
        EVENTLIST.bdf.posthome    = [];
        EVENTLIST.bdf.namebin     = [];
        EVENTLIST.trialsperbin    = [];
end

EVENTLIST.eldate  = datestr(now);
[EVENTLIST serror] = sorteventliststruct(EVENTLIST);  % organizes EVENTLIST

% fprintf('importerpeventlist.m : END\n');
