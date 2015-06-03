function [EEG, com]= pop_syncroartifacts(EEG, varargin)
%POP_SYNCROARTIFACTS
% PURPOSE  :	Synchonizes artifact dtection information between EEGLAB and ERPLAB
%                 (EEG.reject, EEG.epoch.eventflag, EEG.EVENTLIST.eventinfo.flag, EEG.EVENTLIST.eventinfo.bepoch)
%
% FORMAT   :
%
% EEG = pop_syncroartifacts(EEG,direction)
%
%
% INPUTS   :
%
% EEG           - epoched dataset
% direction     - 1= erplab to eeglab synchro
%                 2= eeglab to erplab synchro
%                 3= both
%                 0= none
%
% OUTPUTS
%
% EEG           - updated epoched dataset
%
% EXAMPLE  : EEGLAB fields for artifact detection get updated from info at EEG.EVENTLIST
%
% EEG = pop_syncroartifacts(EEG, 1);
%
% See also synchroartifactsGUI.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

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

com = '';
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        serror = erplab_eegscanner(EEG, 'pop_syncroartifacts', 2, 0, 1, 2, 1);
        if serror
                return
        end
        
        %
        % Call GUI
        %
        direction = synchroartifactsGUI;
        %     direction = 1; % erplab to eeglab synchro
        %     direction = 2; % eeglab to erplab synchro
        %     direction = 3; % both
        %     direction = 0; % none
        if isempty(direction)
                disp('User selected Cancel')
                return
        end       
        if direction==1      % erplab to eeglab synchro
                dircom = 'erplab2eeglab';
        elseif direction==2  %eeglab to erplab synchro
                dircom = 'eeglab2erplab';
        elseif direction==3 % both
                dircom = 'bidirectional';
        else
                dircom = 'none';
        end
        if length(EEG)==1
                EEG.setname = [EEG.setname '_synctrej']; %suggest a new name
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_syncroartifacts(EEG, 'Direction', dircom, 'History', 'gui');
        pause(0.1);
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addParamValue('Direction', 'bidirectional', @ischar); % synchronization direction
p.addParamValue('History', 'script', @ischar);             % history from scripting
p.parse(EEG, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end

%
% process multiple datasets. Updated August 23, 2013 JLC
%
if length(EEG) > 1
        options1 = {'Direction', p.Results.Direction, 'History', 'gui'};
        [ EEG, com ] = eeg_eval( 'pop_syncroartifacts', EEG, 'warning', 'on', 'params', options1);
        return;
end

%erplab_eegscanner(EEG, funcname, chckmultieeg, chckemptyeeg, chckepocheeg, chcknoevents, chckeventlist, varargin)
erplab_eegscanner(EEG, 'pop_syncroartifacts', 2, 0, 1, 2, 1); % bug fixed. JLC. May 26, 2015


if strcmpi(p.Results.Direction,'no') || strcmpi(p.Results.Direction,'none')
        direction = 0;
elseif strcmpi(p.Results.Direction,'erplab2eeglab')
        direction = 1;
elseif strcmpi(p.Results.Direction,'eeglab2erplab')
        direction = 2;
elseif strcmpi(p.Results.Direction,'bidirectional')
        direction = 3;
else
        msgboxText = 'ERPLAB says: Invalid synchronization direction parameter.';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if direction==0
        fprintf('User decided not to synchronize.\n');
        return
end

%
% Tests RT info
%
isRT = 1; % there is RT info by default
if ~isfield(EEG.EVENTLIST.bdf, 'rt')
        isRT = 0; % no RT info
else
        valid_rt = nnz(~cellfun(@isempty,{EEG.EVENTLIST.bdf.rt}));
        if valid_rt==0
                isRT = 0; % no RT info
        end
end

%
% Synchronization
%
if direction==1      % erplab to eeglab synchro
        EEG = synchroner1(EEG);
elseif direction==2  %eeglab to erplab synchro
        EEG = synchroner2(EEG, isRT);
elseif direction==3 % both
        %EEG = synchroner1(EEG);
        %EEG = synchroner2(EEG, isRT);
        EEG = synchroner3(EEG, isRT);
else
        fprintf('no synchronization.\n');
end

com = sprintf( '%s = pop_syncroartifacts(%s, %s);', inputname(1), inputname(1), num2str(direction));

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
                % EEG = erphistory(EEG, [], com, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', com);
        otherwise %off or none
                com = '';
                return
end

%
% Completion statement
%
msg2end
return

% ---------------------------------------------------------------------------
function EEG = synchroner1(EEG)

%
% erplab to eeglab synchro by info at EEG.epoch.eventflag
%
fprintf('\n---------------------------------------------------------\n');
fprintf('STEP 1: Synchronizing EEG.reject.rejmanual by EEG.epoch.eventflag...\n');
fprintf('---------------------------------------------------------\n\n');
nepoch = EEG.trials;
for i=1:nepoch
        cflag = EEG.epoch(i).eventflag; % flag(s) from event(s) within this epoch
        if iscell(cflag)
                %cflag = cell2mat(cflag);
                cflag = uint16([cflag{:}]); % giving some problems with uint16 type of flags
        end
        laten = EEG.epoch(i).eventlatency;% latency(ies) from event(s) within this epoch
        if iscell(laten)
                laten = cell2mat(laten);
        end
        
        indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
        flag  = cflag(indxtimelock);
        
        if flag>0
                if EEG.reject.rejmanual(i)==0
                        EEG.reject.rejmanual(i) = 1; % marks epoch with artifact
                        %EEG.reject.rejmanualE(chanArray(ch), i) = 1; % marks channel with artifact
                        iflag = find(bitget(flag,1:8));
                        fprintf('Epoch # %g was marked due to flag(s) # %s was(were) set for its home item.\n',i, num2str(iflag));
                end
        else
                if EEG.reject.rejmanual(i)==1
                        EEG.reject.rejmanual(i)=0;
                        fprintf('The mark at epoch # %g was removed due to no set flag was found at its home item.\n',i);
                end
        end
end

%
% erplab to eeglab synchro by info at EEG.EVENTLIST.eventinfo.flag and EEG.EVENTLIST.eventinfo.bepoch
%
fprintf('\n---------------------------------------------------------\n');
fprintf('STEP 2: Synchronizing EEG.reject.rejmanual by EEG.EVENTLIST.eventinfo.flag and EEG.EVENTLIST.eventinfo.bepoch...\n');
fprintf('---------------------------------------------------------\n\n');
nitem = length(EEG.EVENTLIST.eventinfo);
for i=1:nitem
        flag   = EEG.EVENTLIST.eventinfo(i).flag;
        bepoch = EEG.EVENTLIST.eventinfo(i).bepoch;
        if bepoch>0
                if flag>0
                        if EEG.reject.rejmanual(bepoch)==0
                                EEG.reject.rejmanual(bepoch) = 1; % marks epoch with artifact
                                iflag = find(bitget(flag,1:8));
                                fprintf('Epoch # %g was marked due to flag(s) # %s was(were) set for item # %g.\n',bepoch, num2str(iflag), i);
                        end
                else
                        if EEG.reject.rejmanual(bepoch)==1
                                EEG.reject.rejmanual(bepoch)=0;
                                fprintf('The mark at epoch # %g was removed due to no set flag was found at item # %g.\n', bepoch, i);
                        end
                end
        end
end
fprintf('\nEEG.reject.rejmanual(i) was synchronized according to EEG.epoch(i).eventflag values.\n')
return

% ---------------------------------------------------------------------------
function EEG = synchroner2(EEG, isRT)
%eeglab to erplab synchro

ntrial = EEG.trials;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'rejjp' 'rejkurt' 'rejmanual' 'rejthresh' 'rejconst' 'rejfreq'...
% 'icarejjp' 'icarejkurt' 'icarejmanual' 'icarejthresh' 'icarejconst'...
% 'icarejfreq' 'rejglobal'
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
arfields  = regexprep(sfields2,'E',''); % EEGLAB's artifact rejection fields

indx = [];
for i=1:length(arfields)
        if ~isempty(EEG.reject.(arfields{i}))
                indx = [indx i];
        end
end

fprintf('\n---------------------------------------------------------\n');
fprintf('Synchronizing EEG.EVENTLIST.eventinfo and EEG.epoch by EEG.reject.{ar_tool}...\n');
fprintf('---------------------------------------------------------\n\n');

selarfields = arfields(indx); % not empty EEGLAB's artifact rejection fields
nsarf = length(selarfields);
for i=1:ntrial;
        r = zeros(1,nsarf);
        for j=1:nsarf
                r(j) = EEG.reject.(selarfields{j})(i);
        end
        if nnz(r)>0
                EEG = markartifacts(EEG, 1, [], [], i, isRT, 1);
        else
                EEG = markartifacts(EEG, 0, [], [], i, isRT, 1); % JLC Sept 1, 2012
        end
end

fprintf('\nFlag 1 was marked at EEG.EVENTLIST.eventinfo and EEG.epoch, according to EEG.reject.{ar_tool}.\n');

if isRT
        fprintf('For reaction time filtering, EEG.EVENTLIST.bdf was synchronized with artifact detection info as well.\n\n');
else
        fprintf('EEG.EVENTLIST.bdf was not synchronized due to reaction time measurement was not found in this dataset.\n\n');
end
return

% ---------------------------------------------------------------------------
function EEG = synchroner3(EEG, isRT)

%
% eeglab <--> erplab synchro (bidirectional: This function only performs marking, not unmarking)
%
nepoch = EEG.trials;

%
% Step 1
% eeglab to erplab synchro by info at EEGLAB's artifact rejection fields
%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'rejjp' 'rejkurt' 'rejmanual' 'rejthresh' 'rejconst' 'rejfreq'...
% 'icarejjp' 'icarejkurt' 'icarejmanual' 'icarejthresh' 'icarejconst'...
% 'icarejfreq' 'rejglobal'
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
arfields  = regexprep(sfields2,'E',''); % EEGLAB's artifact rejection fields

indx = [];
for i=1:length(arfields)
        if ~isempty(EEG.reject.(arfields{i}))
                indx = [indx i];
        end
end

fprintf('\n---------------------------------------------------------\n');
fprintf('STEP 1: Synchronizing EEG.EVENTLIST.eventinfo and EEG.epoch by EEG.reject.{ar_tool}...\n');
fprintf('---------------------------------------------------------\n\n');

if isempty(indx)
    fprintf('All EEG.reject fields are empty, so no artifact rejection has been performed in EEGLAB...\n');
    EEG.reject.rejmanual = zeros(1, nepoch); % initiating EEG.reject.rejmanual since it was empty
else
    selarfields = arfields(indx); % not empty EEGLAB's artifact rejection fields
    nsarf = length(selarfields);
    for i=1:nepoch;
        r = zeros(1,nsarf);
        for j=1:nsarf
            r(j) = EEG.reject.(selarfields{j})(i);
        end
        if nnz(r)>0
            EEG = markartifacts(EEG, 1, [], [], i, isRT, 1); % mark at ERPLAB, if values >0
        end
    end
end
%
% Step 2
% erplab to eeglab synchro by info at EEG.epoch.eventflag
%
fprintf('\n---------------------------------------------------------\n');
fprintf('STEP 2: Synchronizing EEG.reject.rejmanual by EEG.epoch.eventflag...\n');
fprintf('---------------------------------------------------------\n\n');

for qEpoch=1:nepoch
        cflag = EEG.epoch(qEpoch).eventflag; % flag(s) from event(s) within this epoch
        if iscell(cflag)
                %cflag = cell2mat(cflag);
                cflag = uint16([cflag{:}]); % giving some problems with uint16 type of flags
        end
        laten = EEG.epoch(qEpoch).eventlatency;% latency(ies) from event(s) within this epoch
        if iscell(laten)
                laten = cell2mat(laten);
        end
        
        indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
        flag  = cflag(indxtimelock);
        
        if flag>0 && EEG.reject.rejmanual(qEpoch) == 0
                EEG.reject.rejmanual(qEpoch) = 1; % % marks epoch with artifact only if flag is marked (no unmarking)
                %EEG.reject.rejmanualE(chanArray(ch), qEpoch) = 1; % marks channel with artifact
                iflag = find(bitget(flag,1:8));
                fprintf('Epoch # %g was marked due to flag(s) # %s was(were) set for its home item.\n',qEpoch, num2str(iflag));
        end
end

%
% erplab to eeglab synchro by info at EEG.EVENTLIST.eventinfo.flag and EEG.EVENTLIST.eventinfo.bepoch
%
fprintf('\n---------------------------------------------------------\n');
fprintf('STEP 3: Synchronizing EEG.reject.rejmanual by EEG.EVENTLIST.eventinfo.flag and EEG.EVENTLIST.eventinfo.bepoch...\n');
fprintf('---------------------------------------------------------\n\n');
nitem = length(EEG.EVENTLIST.eventinfo);

for qItem=1:nitem
    flag   = EEG.EVENTLIST.eventinfo(qItem).flag;
    bepoch = EEG.EVENTLIST.eventinfo(qItem).bepoch;
    if bepoch>0
        if bepoch<=nepoch
            if flag>0 && EEG.reject.rejmanual(bepoch) == 0
                EEG.reject.rejmanual(bepoch) = 1; % marks epoch with artifact only if flag is marked (no unmarking)
                iflag = find(bitget(flag,1:8));
                fprintf('Epoch # %g was marked due to flag(s) # %s was(were) set for item # %g.\n',bepoch, num2str(iflag), qItem);
            end
        else
            if flag>0
                warning('off', 'Epoch # %g containing item # %g does not longer exist in this dataset.\n',bepoch, qItem);
            end
        end
    end
end
% fprintf('\nEEG.reject.rejmanual(i) was synchronized according to EEG.epoch(i).eventflag values.\n')
return