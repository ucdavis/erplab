%   >> EEG = pop_editeventlist(EEG)
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
% Inputs:
%
%   EEG       - input dataset
%
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

function [EEG com] = pop_editeventlist(EEG, editlistname, newelname, boundarystrcode, newboundarynumcode, rwwarn)

com = '';

if nargin < 1
      help pop_editeventlist
      return
end

if nargin >6
      error('ERPLAB says: error at pop_editeventlist(). Too many inputs!');
end

if nargin==1
      
      if isempty(EEG.data)
            msgboxText{1} =  'pop_editeventlist() cannot work with an empty dataset!';
            title = 'ERPLAB: pop_editeventlist() error';
            errorfound(msgboxText, title);
            return
      end
      
      inputstrMat = assigncodesGUI;  % open GUI
      
      if ~isempty(inputstrMat)
            
            editlistname = inputstrMat{1};
            newelname    = inputstrMat{2};
            updateEEG    = inputstrMat{3};
            boundarystrcode    = inputstrMat{4};
            newboundarynumcode = inputstrMat{5};
            rwwarn = 1;
      else
            disp('User selected Cancel')
            return
      end
else
      if nargin <6
            rwwarn = 0;  % no warning about previous EVENTLIST struct
      end
      if nargin <5
            newboundarynumcode = -99;
      end
      if nargin <4
            boundarystrcode = 'boundary';
      end
      
      boundarystrcode = strtrim(boundarystrcode);
      boundarystrcode = regexprep(boundarystrcode, '''|"','');
end

if rwwarn
      if isfield(EEG, 'EVENTLIST')
            if isfield(EEG.EVENTLIST, 'eventinfo')
                  if ~isempty(EEG.EVENTLIST.eventinfo)
                        
                        question{1} = ['dataset ' EEG.setname '  already has attached an EVENTLIST structure.'];
                        question{2} = 'So, pop_editeventlist()  will totally overwrite it?';
                        question{3} = '           Do you want to continue anyway?';
                        title      = 'ERPLAB: pop_editeventlist, Overwriting Confirmation';
                        button      = askquest(question, title);
                        
                        if ~strcmpi(button,'yes')
                              disp('User selected Cancel')
                              return
                        end
                        
                        if ischar(EEG.event(1).type)
                              [ EEG.event.type ]= EEG.EVENTLIST.eventinfo.code;
                        end
                        
                        EEG.EVENTLIST = [];
                        
                        field2del = {'bepoch','bini','binlabel','codelabel','enable','flag','item'};
                        EEG.event = rmfield(EEG.event, field2del);
                  end
            end
      end
end

if isfield(EEG, 'EVENTLIST')
      
      EVENTLIST = EEG.EVENTLIST;
      
      %
      % Creates an EVENTLIST.eventinfo in case there was not one.
      %
      if ~isfield(EVENTLIST, 'eventinfo')
            fprintf('\nCreating an EVENTINFO by the first time...\n');
            EVENTLIST = creaeventinfo(EEG, boundarystrcode, newboundarynumcode);
      else
            if isempty(EVENTLIST.eventinfo)
                  fprintf('\nCreating an EVENTINFO by the first time...\n');
                  EVENTLIST = creaeventinfo(EEG, boundarystrcode, newboundarynumcode);
            end
      end
      
      if ~isfield(EVENTLIST, 'bdf')
            EVENTLIST.bdf = [];
      end
      if ~isfield(EVENTLIST, 'nbin')
            EVENTLIST.nbin = 0;
      end
      if ~isfield(EVENTLIST, 'trialsperbin')
            EVENTLIST.trialsperbin = [];
      end
      
else
      EVENTLIST = [];
      fprintf('\nCreating an EVENTINFO by the first time...\n');
      EVENTLIST = creaeventinfo(EEG, boundarystrcode, newboundarynumcode);
      EVENTLIST.bdf  = [];
      EVENTLIST.nbin = 0;
      EVENTLIST.trialsperbin = [];
end

EVENTLIST.setname = EEG.setname;

if ~strcmp(editlistname,'')
      if isempty(editlistname)
            error('ERPLAB says: Invalid editlist name')
      end
      
      inputLine = readeditedlist(editlistname);
      nline = length(inputLine);
      
      if nline>=1
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%% a) detects by event code (number), assigns event label          %%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xbin = []; % bin number accumulator
            
            for i=1:nline
                  
                  codex = str2num(inputLine{i}{1});
                  indxm = find([EVENTLIST.eventinfo.code] == codex);
                  
                  if ~isempty(indxm)
                        
                        codelabelx = inputLine{i}{2};
                        
                        if strcmpi(codelabelx,'')
                              codelabelx = '""';
                        end
                        
                        [EVENTLIST.eventinfo(indxm).codelabel] = deal(codelabelx);
                        
                        if ~strcmpi(codelabelx,'""')
                              fprintf('\n #: Event codes %g were labeled %s . \n', codex, codelabelx);
                        end
                  end
                  
                  %
                  % Bin assignment
                  %
                  numbin = str2num(inputLine{i}{3});
                  prebin = [EVENTLIST.eventinfo(indxm).bini]; % previous bin(s)
                  prebin(prebin<1)=[]; % only valid bin indexes
                  
                  binlabelx = inputLine{i}{4};
                  
                  if strcmpi(binlabelx,'')
                        binlabelx = '""';
                  end
                  
                  if ~isempty(numbin) && ~isempty(indxm)   % bin was specified, code was found
                        
                        binII = unique([numbin prebin]);
                        [EVENTLIST.eventinfo(indxm).bini] = deal(binII);
                        
                        fprintf('\n #: Event codes %g were bined %d . \n', codex, numbin);
                        
                        [EVENTLIST.eventinfo(indxm).binlabel]  = deal(binlabelx);
                        
                        if ~strcmpi(binlabelx,'""')
                              fprintf('\n #: Event codes %g were bin-labeled %s . \n', codex, binlabelx);
                        end
                        
                        EVENTLIST.bdf(numbin).description = binlabelx;
                        EVENTLIST.bdf(numbin).namebin     = ['BIN' num2str(numbin)];
                        
                  elseif ~isempty(numbin) && isempty(indxm) % bin was specified, code was not found
                        
                        EVENTLIST.bdf(numbin).description = binlabelx;
                        
                        EVENTLIST.bdf(numbin).namebin     = ['BIN' num2str(numbin)];
                        
                  elseif isempty(numbin) && ~isempty(indxm)  % bin was not specified, code was found
                        
                        [EVENTLIST.eventinfo(indxm).bini] = deal(-1);
                        [EVENTLIST.eventinfo(indxm).binlabel] = deal('""');
                        
                  else
                        fprintf('\n\nWARNING:  Event code %g was not found at %s .\n\n', codex, EEG.setname)
                  end
                  
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%% b) detects by event label, assigns event number       %%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i=1:nline
                  
                  codelabelx = inputLine{i}{2};
                  
                  if ~strcmpi(codelabelx,'""') && ~strcmpi(codelabelx,'')
                        
                        indxm  = find(ismember({EVENTLIST.eventinfo.codelabel}', codelabelx));
                        
                        if ~isempty(indxm)
                              
                              codex = str2num(inputLine{i}{1});
                              [EVENTLIST.eventinfo(indxm).code] = deal(codex);
                              fprintf('\n #: Event codelabels %s were encoded %d . \n', codelabelx, codex);
                        end
                        
                        numbin = str2num(inputLine{i}{3});
                        prebin = [EVENTLIST.eventinfo(indxm).bini]; % previous bin(s)
                        prebin(prebin<1)=[]; % only valid bin indexes
                        
                        binlabelx = inputLine{i}{4};
                        
                        if strcmpi(binlabelx,'')
                              binlabelx = '""';
                        end
                        
                        if ~isempty(numbin) && ~isempty(indxm)
                              
                              binII = unique([numbin prebin]);
                              [EVENTLIST.eventinfo(indxm).bini] = deal(binII);
                              
                              xbin = [xbin numbin];
                              
                              [EVENTLIST.eventinfo(indxm).binlabel]  = deal(binlabelx);
                              
                              if ~strcmpi(binlabelx,'""')
                                    fprintf('\n #: Event codes %g were bin-labeled %s . \n', codex, binlabelx);
                              end
                              
                              EVENTLIST.bdf(numbin).description = binlabelx;
                              EVENTLIST.bdf(numbin).namebin     = ['BIN' num2str(numbin)];
                              
                              if numbin>0
                                    fprintf('\n #: Event codelabels %s were bined %d . \n', codelabelx, numbin);
                              end
                        elseif ~isempty(numbin) && isempty(indxm)
                              
                              EVENTLIST.bdf(numbin).description = binlabelx;
                              EVENTLIST.bdf(numbin).namebin     = ['BIN' num2str(numbin)];
                              
                        elseif isempty(numbin) && ~isempty(indxm)
                              
                              if isempty(prebin)
                                    [EVENTLIST.eventinfo(indxm).bini] = deal(-1);
                                    [EVENTLIST.eventinfo(indxm).binlabel] = deal('""');
                              end
                        else
                              fprintf('\n\nWARNING:  Event codelabel %s was not found at %s .\n\n', codelabelx, EEG.setname)
                        end
                  end
                  
            end
            
            lbin = length(EVENTLIST.bdf);
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
            
            if EVENTLIST.nbin~=max(ubin)
                  error('ERPLAB says: Number of bin was wrongly assigned. Please, contact to javlopez@ucdavis.edu.')
            end
            
            lenbdf = length(EVENTLIST.bdf);
            
            if lenbdf<max(ubin)
                  EVENTLIST.bdf(max(ubin)).description = '""';
                  EVENTLIST.bdf(max(ubin)).namebin     = ['BIN' num2str(max(ubin))];
            end
            
            %
            % Complete EVENTLIST.bdf field
            %
            for h=1:max(ubin)
                  if isempty(EVENTLIST.bdf(max(ubin)).description)
                        EVENTLIST.bdf(h).description = '""';
                        EVENTLIST.bdf(h).namebin     = ['BIN' num2str(h)];
                  end
            end
      end
end

if strcmp(newelname,'')
      [EEG EVENTLIST] = creaeventlist(EEG,EVENTLIST);
else
      [EEG EVENTLIST] = creaeventlist(EEG, EVENTLIST, newelname);
end

EEG = pasteeventlist(EEG, EVENTLIST, 1); % joints both structs
EEG = creabinlabel(EEG);

%
% works with the GUI
%
if nargin==1
      if updateEEG
            EEG = pop_overwritevent(EEG);
      end
end

[EEG serror] = sorteegeventfields(EEG);
EEG = eeg_checkset(EEG, 'eventconsistency');
EEG.setname = [EEG.setname '_elist']; %suggest a new name

if length(boundarystrcode)==1
      com = sprintf( '%s = pop_editeventlist(%s, ''%s'', ''%s'', {''%s''}, {%s});', inputname(1),...
            inputname(1), editlistname, newelname, boundarystrcode{1}, num2str(newboundarynumcode{1}));
elseif length(boundarystrcode)==2
      com = sprintf( '%s = pop_editeventlist(%s, ''%s'', ''%s'', {''%s'',''%s'' }, {%s, %s});', inputname(1),...
            inputname(1), editlistname, newelname, boundarystrcode{1}, boundarystrcode{2},...
            num2str(newboundarynumcode{1}), num2str(newboundarynumcode{2}));
else
      com = sprintf( '%s = pop_editeventlist(%s, ''%s'', ''%s'');', inputname(1), inputname(1), editlistname, newelname);
end

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return;

%--------------------------------------------------------------------------
function inputLine2 = readeditedlist(editlistname)

disp(['For pre-edited list of changes, user selected  <a href="matlab: open(''' editlistname ''')">' editlistname '</a>'])

fid_edition = fopen( editlistname );
formcell    = textscan(fid_edition, '%[^\n]', 'whitespace', '');
fclose(fid_edition);
inputLine1    = cellstr(formcell{:});
nline = length(inputLine1);
strtok = regexp(inputLine1, '([-+]*\d+)\s*"(.*)"\s*(\d+|[[]]+)\s*"(.*)"', 'tokens');
inputLine2 = cell(1,nline);

for m=1:nline
      inputLine2{m} = strtok{m}{1};
end
