% Usage:
% EEG = pop_epochbin(EEG, trange, blc)
%
% EEG     -  EEGLAB structure
% trange  - window for epoching in msec
% blc     - window for baseline correction in msec  or either a string like 'pre', 'post', or 'all'
%           (strings with the baseline interval also works. e.g. '-300 100')
%
% Example:
% >> EEG = pop_epochbin( EEG , [-200 800],  [-100 0]);
% >> EEG = pop_epochbin( EEG , [-200 800],  '-100 0');
% >> EEG = pop_epochbin( EEG , [-400 2000],  'post');
%
% pop_epochbin() - interactively epoch bin-based trials
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
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

function [EEG, com] = pop_epochbin(EEG, trange, blc)

com = '';
fprintf('pop_epochbin : START\n');

if nargin < 1
      help pop_epochbin
      return
end

if isempty(EEG.data)
      msgboxText{1} =  'pop_epochbin() error: cannot work with an empty dataset!';
      title = 'ERPLAB: No data';
      errorfound(msgboxText, title);
      return
end

if ~isfield(EEG,'EVENTLIST')
      msgboxText{1} =  'You should create/add an EVENTLIST before perform bin epoching!';
      title        = 'ERPLAB: pop_epochbin() Error';
      errorfound(msgboxText, title);
      return
end

if isempty(EEG.EVENTLIST)
      msgboxText{1} =  'You should create/add an EVENTLIST before perform bin epoching!';
      title        = 'ERPLAB: pop_epochbin() Error';
      errorfound(msgboxText, title);
      return
end

if ~isfield(EEG.EVENTLIST,'eventinfo')
      msgboxText{1} =  'You should create/add an EVENTLIST before perform bin epoching!';
      title        = 'ERPLAB: pop_epochbin() Error';
      errorfound(msgboxText, title);
      return
end

if ~isfield(EEG.EVENTLIST.eventinfo,'binlabel')
      msgboxText{1} =  'You should create/add an EVENTLIST before perform bin epoching!';
      title        = 'ERPLAB: pop_epochbin() Error';
      errorfound(msgboxText, title);
      return
end

%
% Gui is working...
%
nvar = 3;
if nargin <nvar
      
      answer = epochbinGUI;  % open GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      rangtimems =  answer{1};
      rangtime   = rangtimems/1000;% converts msec to seconds
      blcorr     =  answer{2};
      
else   % without Gui
      rangtimems = trange;
      rangtime   = rangtimems/1000;% converts msec to seconds
      blcorr     = blc;
end

if ischar(blcorr)
      
      if ~ismember(lower(blcorr),{'all' 'pre' 'post' 'none'})
            
            internum = str2double(blcorr);
            
            if length(internum)  ~=2
                  msgboxText{1} =  'pop_epochbin will not be performed.';
                  msgboxText{2} =  'Check out your baseline correction values';
                  title        =  'ERPLAB: pop_epochbin() error';
                  errorfound(msgboxText, title);
                  return
            end
            
            if internum(1)>=internum(2)|| internum(1)>rangtimems(2) || internum(2)<rangtimems(1)
                  msgboxText{1} =  'pop_epochbin will not be performed.';
                  msgboxText{2} =  'Check out your baseline correction values';
                  title        =  'ERPLAB: pop_epochbin() error';
                  errorfound(msgboxText, title);
                  return
            end
            
            blcorrstr  = ['[' num2str(internum/1000) ']']; % secs
            blcorrcomm = blcorrstr;
      else
            
            if strcmpi(blcorr,'pre')
                  blcorrstr  = '[EEG.xmin 0]';        % secs
                  blcorrcomm = ['''' blcorr ''''];
            elseif strcmpi(blcorr,'post')
                  blcorrstr  = '[0 EEG.xmax]';        % secs
                  blcorrcomm = ['''' blcorr ''''];
            elseif strcmpi(blcorr,'all')
                  blcorrstr  = '[EEG.xmin EEG.xmax]'; % secs
                  blcorrcomm = ['''' blcorr ''''];
            else
                  blcorrstr  = 'none';
                  blcorrcomm = '''none''';
            end
      end
      
else
      if length(blcorr)~=2
            error('ERPLAB says:  pop_epochbin will not be performed. Check your parameters.')
      end
      if blcorr(1)>=blcorr(2)|| blcorr(1)>rangtimems(2) || blcorr(2)<rangtimems(1)
            error('ERPLAB says:  pop_epochbin will not be performed. Check your parameters.')
      end
      blcorrstr  = ['[' num2str(blcorr/1000) ']']; % secs
      blcorrcomm = blcorrstr;
end

nbin      = EEG.EVENTLIST.nbin;

if isempty(EEG.epoch)
      %
      % Creates new "Bin Types"
      %
      if iscellstr({EEG.EVENTLIST.eventinfo.binlabel}) && isnumeric([EEG.EVENTLIST.eventinfo.code])
            
            othertype    = cell(1);
            bintypecrude = cell(1);
            
            binnames = unique({EEG.EVENTLIST.eventinfo.binlabel});  % existing binlabels
            
            %
            % identifies bin labels
            %
            mbin     = regexp(binnames,'^B(\d+\,*)+(\(\d+\))|^B(\d+\,*)+(\(\w+.*?\))', 'match', 'ignorecase'); % same length as binnames
            
            aa = 1;
            bb = 1;
            
            for ib=1:length(binnames)
                  
                  % multiple event types must be entered as {'a', 'cell', 'array'}
                  if isempty(mbin{ib})
                        othertype{aa} = binnames{ib};
                        aa = aa + 1;   % detected (string) event code counter
                  else
                        bintypecrude{bb} = char(mbin{ib});  % this is a detected bin label
                        bb = bb + 1;                        % detected bin label counter
                  end
            end
            
            strbin   = regexprep(bintypecrude, 'B|(\(\d+\))|(\(\w+.*?\))', ''); % capture bin index(es), delete the rest
            
            fprintf('\n');
            fprintf('* Detected non-binlabeled event codes: \n');
            
            for n=1:length(othertype)
                  fprintf('%s ', othertype{n});
            end
            
            fprintf('\n\n');
            fprintf('* Detected bin-labeled event codes: \n');
            
            for n=1:length(bintypecrude)
                  fprintf('%s ', bintypecrude{n});
            end
            
            fprintf('\n\n');
            
            if isempty([bintypecrude{:}])
                  msgboxText =  ['Unfortunately, no valid bin-related codes were found.\n'...
                        'So, You have to assign bins first.\n'...
                        'Otherwise, you will need to use ''''Extract Epoch'''' from EEGLAB'];
                  title        =  'ERPLAB: pop_epochbin() Permission';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
            
            binArray = 1:nbin; % Work with all bins!!!, sept 18, 2008
            bintype  = cell(1);
            k = 1;
            
            for i= 1:bb-1
                  
                  numbin = str2double(char(strbin{i}));
                  tf = ismember(numbin, binArray);
                  
                  if ~isempty(find(tf==1, 1))
                        bintype{k} = bintypecrude{i}; % EEGLAB can use the same "type" multiples times
                        k = k+1;
                  end
            end
      else
            fprintf('\n-------------------------------------\n');
            error('ERPLAB says: ERROR. BIN ASSIGNING WAS NOT PROPERLY MADE');
      end
      
      %
      % Replaces EEG.event.type field by EEG.EVENTLIST.eventinfo.binlabel
      %
      EEG = update_EEG_event_field(EEG, 'binlabel');
else
      
      %
      % loc binlabels at EEG.EVENTLIST.eventinfo.binlabel
      %
      locbin = find(~ismember({EEG.EVENTLIST.eventinfo.binlabel},'""'));
      bintype = unique({EEG.EVENTLIST.eventinfo(locbin).binlabel});
end

if isempty(bintype)
      msgboxText{1} =  'Bins were not detected under current specifications';
      title         = 'ERPLAB: pop_epochbin() Error';
      errorfound(msgboxText, title);
      return
end

EEG = pop_epoch( EEG, bintype, rangtime, 'newname', [EEG.setname '_be'], 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );

%
% Warning
%
fprintf('\n\n-------------------------------------------------------------------------------\n');
fprintf('Warning: EEG.event and EEG.EVENTLIST.eventinfo structure will not longer match.\n');
fprintf('EEG.event only contains info about events within each epoch.\n');
fprintf('EEG.EVENTLIST.eventinfo still contains all the original (continuous) events info.\n');
fprintf('The purpose of this is to allow users to set flags during artifact detection,');
fprintf('and to rebuild a continuous EVENTLIST with this info.\n');
fprintf('-------------------------------------------------------------------------------\n\n');

%
% baseline correction  01-14-2009
%
adj = 0;
if ~strcmpi(blcorrstr,'none')
      
      blcorrnum = single(eval(blcorrstr));
      
      if blcorrnum(1)<EEG.xmin
            blcorrnum(1) = EEG.xmin;
            adj = 1;
      end
      
      if blcorrnum(2)>EEG.xmax
            blcorrnum(2) = EEG.xmax;
            adj = 1;
      end
      
      blcorrnum = blcorrnum*1000;   % sec to msec
      
      if adj
            fprintf('pop_epochbin(): baseline correction range has been adjusted to [%.2f %.2f] to fit data points limits', blcorrnum)
      end
      
      EEG = pop_rmbase( EEG, blcorrnum);
      EEG = eeg_checkset( EEG );
      fprintf('\nBaseline correction was performed at [%s] \n\n', num2str(blcorrnum));
else
      fprintf('\n\nWarning: No baseline correction was performed\n\n');
end

EEG = bepoch2EL(EEG);
EEG = eeg_checkset( EEG );

rangtimemsstr = sprintf('%.1f  %.1f', rangtimems);

% generate text command
com = sprintf('%s = pop_epochbin( %s ', inputname(1), inputname(1));
com = sprintf('%s, [%s],  %s);', com, rangtimemsstr, blcorrcomm);

fprintf('pop_epochbin : END\n');
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return