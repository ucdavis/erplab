% PURPOSE  : 	Interactively epoch bin-based trials
%
% FORMAT   :
%
% EEG = pop_epochbin(EEG, trange, blc);
%
%INPUTS    :
%
% EEG       - EEGLAB structure
% trange    - window for epoching in msec
% blc       - window for baseline correction in msec or either a string like 'pre', 'post', or 'all'
%            (strings with the baseline interval also works. e.g. '-300 100')
%
% OUTPUTS  :
%
% -	Output EEG epoched dataset
%
% Example  :
%
% EEG = pop_epochbin( EEG , [-200 800],  [-100 0]);
% EEG = pop_epochbin( EEG , [-200 800],  '-100 0');
% EEG = pop_epochbin( EEG , [-400 2000],  'post');
%
% See also pop_epoch.m bepoch2EL.m bepoch2EEG.m checkeegzerolat.m
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function [EEG, com] = pop_epochbin(EEG, trange, blc, varargin)
com = '';
if nargin < 1
        help pop_epochbin
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1 % using GUI
        if length(EEG)>1
                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                title      = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText =  'pop_epochbin() error: cannot work with an empty dataset!';
                title      = 'ERPLAB: No data';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG,'EVENTLIST')
                msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
                title      = 'ERPLAB: pop_epochbin() Error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.EVENTLIST)
                msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
                title      = 'ERPLAB: pop_epochbin() Error';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG.EVENTLIST,'eventinfo')
                msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
                title      = 'ERPLAB: pop_epochbin() Error';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG.EVENTLIST.eventinfo,'binlabel')
                msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
                title      = 'ERPLAB: pop_epochbin() Error';
                errorfound(msgboxText, title);
                return
        end
        def  = erpworkingmemory('pop_epochbin');
        if isempty(def)
                def = {[-200 800]  'pre'};
        end
        
        %
        % Call GUI
        %
        answer = epochbinGUI(def);  % open GUI
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        rangtimems =  answer{1};
        blcorr     =  answer{2};
        
        erpworkingmemory('pop_epochbin', {rangtimems, blcorr});
        
        EEG.setname = [EEG.setname '_be']; % suggested name (si queris no mas!)
        %
        % Somersault
        %
        [EEG, com] = pop_epochbin(EEG, rangtimems, blcorr, 'Warning', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('trange', @isnumeric);
p.addRequired('blc');
% option(s)
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, trange, blc, varargin{:});

if strcmpi(p.Results.Warning,'on')
        wchmsgon = 1;
else
        wchmsgon = 0;
end
if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
rangtimems = trange;
rangtime   = rangtimems/1000;% converts msec to seconds
blcorr     = blc;
if length(EEG)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        error(['ERPLAB says: ' msgboxText])
end
if isempty(EEG.data)
        msgboxText =  'pop_epochbin() error: cannot work with an empty dataset!';
        error(['ERPLAB says: ' msgboxText])
end
if ~isfield(EEG,'EVENTLIST')
        msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
        error(['ERPLAB says: ' msgboxText])
end
if isempty(EEG.EVENTLIST)
        msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
        error(['ERPLAB says: ' msgboxText])
end
if ~isfield(EEG.EVENTLIST,'eventinfo')
        msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
        error(['ERPLAB says: ' msgboxText])
end
if ~isfield(EEG.EVENTLIST.eventinfo,'binlabel')
        msgboxText =  'You should create/add an EVENTLIST before perform bin epoching!';
        error(['ERPLAB says: ' msgboxText])
end
if ischar(blcorr)
        if ~ismember_bc2(lower(blcorr),{'all' 'pre' 'post' 'none'})
                internum = str2num(blcorr);
                if length(internum)  ~=2
                        msgboxText = ['pop_epochbin will not be performed.\n'...
                                'Check out your baseline correction values'];
                        error(['ERPLAB says: ' msgboxText])
                end
                if internum(1)>=internum(2)|| internum(1)>rangtimems(2) || internum(2)<rangtimems(1)
                        msgboxText = ['pop_epochbin will not be performed.\n'...
                                'Check out your baseline correction values'];
                        error(['ERPLAB says: ' msgboxText])
                end
                blcorrstr  =  vect2colon(internum/1000);      %         ['[' num2str(internum/1000) ']']; % secs
                blcorrcomm = vect2colon(internum);            %         ['[' num2str(internum) ']'];      % msecs
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
        blcorrstr  = vect2colon(blcorr/1000); % ['[' num2str(blcorr/1000) ']']; % secs
        blcorrcomm = vect2colon(blcorr); % blcorrstr;
end

nbin = EEG.EVENTLIST.nbin;

if isempty(EEG.epoch)
        %
        % Creates new "Bin Types"
        %
        if iscellstr({EEG.EVENTLIST.eventinfo.binlabel}) && isnumeric([EEG.EVENTLIST.eventinfo.code])
                
                othertype    = cell(1);
                bintypecrude = cell(1);
                
                binnames = unique_bc2({EEG.EVENTLIST.eventinfo.binlabel});  % existing binlabels
                
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
                                       'So, you must run Binlister first.\n'];
                        title  =  'ERPLAB: pop_epochbin()';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                binArray = 1:nbin; % Work with all bins!!!, sept 18, 2008
                bintype  = cell(1);
                k = 1;
                for i= 1:bb-1
                        numbin = str2num(char(strbin{i})); %#ok<ST2NM>
                        tf = ismember_bc2(numbin, binArray);
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
        locbin = find(~ismember_bc2({EEG.EVENTLIST.eventinfo.binlabel},'""'));
        bintype = unique_bc2({EEG.EVENTLIST.eventinfo(locbin).binlabel});
end
if isempty(bintype)
        msgboxText  =  'Bins were not detected under current specifications';
        title       = 'ERPLAB: pop_epochbin() Error';
        errorfound(msgboxText, title);
        return
end

%
% Epoching
%
EEG = pop_epoch( EEG, bintype, rangtime, 'newname', EEG.setname, 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );

%
% Double check the time locked stimulus latency (true zero)
%
EEG = checkeegzerolat(EEG);

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

%
% Updates EVENTLIST (EEG.EVENTLIST.eventinfo(k).bepoch) with the information about epoch index.
%
%
% subroutine
%
EEG = bepoch2EL(EEG);
EEG = eeg_checkset( EEG );

%
% Updates EEG (EEG.epoch(k).eventbepoch) with the information about epoch index.
%
%
% subroutine
%
EEG = bepoch2EEG(EEG);
EEG = eeg_checkset( EEG );

% generate text command
rangtimemsstr = sprintf('%.1f  %.1f', rangtimems);
com = sprintf('%s = pop_epochbin( %s ', inputname(1), inputname(1));
com = sprintf('%s, [%s],  %s);', com, rangtimemsstr, blcorrcomm);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return