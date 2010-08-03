%   >> EEG = pop_creaeventlist(EEG, elname)
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

function [EEG com] = pop_creaeventlist(EEG, elname)

com = '';

if nargin < 1
      help pop_creaeventlist
      return
end

if nargin >2
      error('ERPLAB says: error at pop_creaeventlist(). Too many inputs!');
end

if ~isempty(EEG.epoch)
      msgboxText{1} =  'pop_creaeventlist() has been tested for continuous data only.';
      msgboxText{2} =  '';
      msgboxText{3} =  'HINT: You may use "Export EVENTLIST to text file", instead.';
      title = 'ERPLAB: pop_creaeventlist Permission denied';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      
      if isempty(EEG.data)
            msgboxText{1} =  'cannot work with an empty dataset!';
            title = 'ERPLAB: pop_creaeventlist() error: ';
            errorfound(msgboxText, title);
            return
      end
      
      inputstrMat = assigncodesGUI;  % GUI
      
      if ~isempty(inputstrMat)
            elname    = inputstrMat{end};
            updateEEG = inputstrMat{end-1};
      else
            disp('User selected Cancel')
            return
      end
else
      inputstrMat = {[0],''};  % temporary solution...
end

nline = length(inputstrMat)-2;

if isfield(EEG, 'EVENTLIST')
      
      EVENTLIST = EEG.EVENTLIST;
      
      %
      % Creates an EVENTLIST.eventinfo in case there was not one.
      %
      if ~isfield(EVENTLIST, 'eventinfo')
            fprintf('\nCreating an EVENTINFO by the first time...\n');
            EVENTLIST = creaeventinfo(EEG);
      else
            if isempty(EVENTLIST.eventinfo)
                  fprintf('\nCreating an EVENTINFO by the first time...\n');
                  EVENTLIST = creaeventinfo(EEG);
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
      EVENTLIST           = [];
      
      fprintf('\nCreating an EVENTINFO by the first time...\n');
      EVENTLIST = creaeventinfo(EEG);
      EVENTLIST.bdf       = [];
      EVENTLIST.nbin = 0;
      EVENTLIST.trialsperbin = [];
end

EVENTLIST.setname = EEG.setname;

if nline>=1
      
      %
      % a) detects by event code (number), assigns event label
      %
      xbin = []; % bin number accumulator
      
      for i=1:nline
            
            codex = str2num(inputstrMat{i}{1});
            indxm = find([EVENTLIST.eventinfo.code] == codex);
            
            if ~isempty(indxm)
                  
                  codelabelx = inputstrMat{i}{2};
                  [EVENTLIST.eventinfo(indxm).codelabel]  = deal(codelabelx);
                  
                  if ~strcmpi(codelabelx,'""')
                        fprintf('\n #: Event codes %g were labeled %s . \n', codex, codelabelx);
                  end
                  
                  numbin = str2num(inputstrMat{i}{3});
                  
                  if ~isempty(numbin)
                        
                        [EVENTLIST.eventinfo(indxm).bini]  = deal(numbin);
                        fprintf('\n #: Event codes %g were bined %d . \n', codex, numbin);
                        
                        xbin = [xbin numbin];
                        EVENTLIST.bdf(numbin).description = inputstrMat{i}{4};
                        EVENTLIST.bdf(numbin).namebin = ['BIN' num2str(numbin)];
                  else
                        [EVENTLIST.eventinfo(indxm).bini]  = deal(-1);
                  end
            end
      end
      
      ubin  = sort(unique(xbin));
      lbin  = length(ubin);
      binaux    = [EVENTLIST.eventinfo.bini];
      binhunter = sort(binaux(binaux>0)); %8/19/2009
      
      if lbin>=1
            [c detbin] = ismember(ubin,binhunter);
            EVENTLIST.trialsperbin = [detbin(1) diff(detbin)];
            EVENTLIST.nbin  = length(EVENTLIST.trialsperbin);
      else
            EVENTLIST.trialsperbin = 0;
            EVENTLIST.nbin  = 0;
      end
      
      %
      % b) detects by event label, assigns event number
      %
      for i=1:nline
            
            codelabelx = inputstrMat{i}{2};
            
            if ~strcmpi(codelabelx,'""')
                  
                  indxm  = find(ismember({EVENTLIST.eventinfo.codelabel}', codelabelx));
                  
                  if ~isempty(indxm)
                        codex = str2num(inputstrMat{i}{1});
                        [EVENTLIST.eventinfo(indxm).code] = deal(codex);
                        fprintf('\n #: Event codelabels %s were encoded %d . \n', codelabelx, codex);
                        numbin = str2num(inputstrMat{i}{3});
                        [EVENTLIST.eventinfo(indxm).bini] = deal(numbin);
                        
                        if ~isempty(numbin)
                              if ~isnan(numbin)
                                    fprintf('\n #: Event codelabels %s were bined %d . \n', codelabelx, numbin);
                              end
                        end
                  end
            end
      end
end

if strcmp(elname,'')
      [EEG EVENTLIST] = creaeventlist(EEG,EVENTLIST);
else
      [EEG EVENTLIST] = creaeventlist(EEG, EVENTLIST, elname);
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

EEG = eeg_checkset(EEG, 'eventconsistency');
EEG.setname = [EEG.setname '_elist']; %suggest a new name

com = sprintf( '%s = pop_creaeventlist(%s, ''%s'');', inputname(1),...
      inputname(1), elname);
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return;
