% PURPOSE: subroutine for pop_averager
%
% FORMAT:
%
% [ERP EVENTLIST countbiORI countbinINV countbinOK countflags workfiles] = averager(EEG, artcrite, stderror)
%
% Inputs:
%
% EEG             - bin-epoched dataset
% artcrite        - criterion for artifact detection
% stderror        - calculate standard error of the mean: 1 yes; 0 no
% excbound        - exclude epochs having boundary events: 1 yes; 0 no
%
% Outputs:
%
% ERP             - averaged ERPset
% EVENTLIST       - EVENTLIST structure
% countbiORI      - number of total epochs per bin
% countbinINV     - number of invalid epochs per bin
% countbinOK      - number of good epochs per bin
% countflags      - flag counter
% workfiles       - cell array containing the averaged bin-epoched dataset setnames
%
%
% See also pop_averager pop_appenderp
%
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

function [ERP EVENTLIST countbiORI countbinINV countbinOK countflags workfiles] = averager(EEG, artcrite, stderror, excbound)

if nargin<1
        help averager
        return
end
if nargin<4
        excbound = 0; % 1=exclude epochs having boundary events; 0= do not exclude...
end
if nargin<3
        stderror = 0;    % 1=compute stderror ; 0= do not...
end

% check for time-lock latency
EEG    = checkeegzerolat(EEG);

% build ERP strucure (keeping some of the EEGLAB's EEG structure fields)
ERP    = buildERPstruct(EEG);
nepoch = length(EEG.epoch);
nchan  = EEG.nbchan;
points = EEG.pnts;

if isempty(EEG.filename)
        workfiles = EEG.setname;
else
        workfiles = EEG.filename;
end

EVENTLIST   = EEG.EVENTLIST;
nbin        = EEG.EVENTLIST.nbin;           % total number of described bins
binsum      = zeros(nchan, points, nbin);   % bin sumatory
countbinOK  = zeros(1,nbin);              % trial counter (only good trials)
countbiORI  = zeros(1,nbin);              % trial counter (ALL trials, originals)
countbinINV = zeros(1,nbin);              % trial counter (invalid trials)
countflags  = zeros(nbin,nepoch);
ERP.bindata = zeros(nchan,points,nbin);   % All averages are zeros at the beginning
F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
fields4reject  = regexprep(sfields2,'E','');

if stderror
        ERP.binerror = zeros(nchan, points, nbin); % bins standard error
        sumERP2 = zeros(nchan, points, nbin);   % sum of squares: Sum(xi^2)
end

%
% In case of there is not channel labels specified.
%
if isempty(ERP.chanlocs)
        for cc = 1:ERP.nchan
                ERP.chanlocs(cc).labels = ['Ch:' num2str(cc)];
        end
end

%
% Read file
%
if ischar(artcrite) % read a file having indices (only for 1 dataset so far)
        
        error('ERPLAB says: artcrite cannot be a string. Use pop_averager if you want to load a file for reading the epoch indices.')
        %       %
        %       % open file containing epoch indices
        %       %
        %       fid_list = fopen( artcrite );
        %       formcell = textscan(fid_list, '%s');
        %       artcrite = formcell{:};
        %       semcol = find(ismember(artcrite,';'));
        %       r = sprintf('%s  ', artcrite{1:semcol(1)-1});
        %       artcrite = str2num(r);
        %       artcrite = num2cell(artcrite);
        %       fclose(fid_list);
end

%
% Bin's fusion routine
%
binArray =1:nbin;  % always average all bins.

for i = 1:nepoch
        %
        % identify values linked to the time-locked events
        %
        if length(EEG.epoch(i).eventlatency) == 1
                numbin = EEG.epoch(i).eventbini; % index of bin(s) that own this epoch (can be more than one)
                flagb  = EEG.epoch(i).eventflag; % flag status of the single event in this epoch.
                
                if iscell(numbin)
                        numbin = numbin{:}; % allows multiples bins assigning
                end
                if iscell(flagb)
                        flagb = flagb{:};
                end
                
                % Exclude epochs having boundary events, and set corresponding "enable" field to -1. Dec 20, 2012. JLC
                if excbound==1
                        etype  = EEG.epoch(i).eventtype; % event code of the single event in this epoch.
                        eitem  = EEG.epoch(i).eventitem; % event code of the single event in this epoch.
                        if iscell(etype)
                                etype = etype{:};
                        end
                        if iscell(eitem)
                                eitem = eitem{:};
                        end
                        
                        condbound = 0;
                        if isnumeric(etype)
                                if etype==-99
                                        condbound=1;
                                end
                        else
                                if strcmpi(etype, '-99') || strcmpi(etype, 'boundary')
                                        condbound=1;
                                end
                        end
                        if condbound==1
                                EEG.epoch(i).eventenable = -1;
                                EEG.EVENTLIST.eventinfo(eitem).enable = -1;
                                fprintf('(!) Epoch #%g had a "boundary" event so it won''t be included in the averaging process.\n ', i)
                        end
                end
                
                % just 1 event at this epoch
                enableTL = EEG.epoch(i).eventenable; %  "enable" status of the single event in this epoch.
                
                if iscell(enableTL)
                        enableTL = enableTL{1};
                end
                enableALL = enableTL;  % cause there is 1 event
        elseif length(EEG.epoch(i).eventlatency) > 1
                indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0); % catch zero-time locked event (type),
                [numbin]  = [EEG.epoch(i).eventbini{indxtimelock}]; % index of bin(s) that own this epoch (can be more than one) at time-locked event.
                numbin    = unique(numbin(numbin>0)); % flag status of the time-locked event in this epoch.
                flagb     = EEG.epoch(i).eventflag{indxtimelock};
                
                % Exclude epochs having boundary events, and set corresponding "enable" field to -1. Dec 20, 2012. JLC
                if excbound==1
                        etype     = EEG.epoch(i).eventtype; % event code of the single event in this epoch.
                        eitem     = [EEG.epoch(i).eventitem{:}]; % event code of the single event in this epoch.
                        condbound = 0;
                        if any(cellfun(@ischar, etype))
                                [tfb indxb] = ismember({'-99' 'boundary'}, etype);
                                
                                if any(tfb)
                                        condbound=1;
                                        indxb = nonzeros(indxb);
                                end
                        else
                                etype = [etype{:}];% double
                                [tfb indxb] = ismember(-99, etype);
                                if tfb
                                        condbound=1;
                                end
                        end
                        % update enable fields at EEG.epoch and EEG.EVENTLIST.eventinfo (set to -1)
                        if condbound==1                               
                                [EEG.epoch(i).eventenable{indxb}] = deal(-1);
                                [EEG.EVENTLIST.eventinfo(eitem(indxb)).enable] = deal(-1);
                                % fprintf('(!) Epoch #%g had a "boundary" event, so it won''t be included in the averaging process.\n ', i)
                        end
                end
                
                % multiple events at his epoch
                enableTL  =  EEG.epoch(i).eventenable{indxtimelock}; % "enable" status of the time-locked event.
                enableALL = [EEG.epoch(i).eventenable{:}]; % enable field of all events
        else
                numbin =[];
        end
        if ~isempty(numbin)  % if any bin was found in this epoch (at the time-locked event)
                [tf, binslot]  = ismember(numbin, binArray);  % for now...binslot=bin detected at the current epoch
                if ~isempty(find(tf==1, 1))
                        countbiORI(1,binslot) = countbiORI(1,binslot) + 1; % trial counter (ALL trials, originals)
                        countflags(binslot,i) = repmat(flagb, 1, length(binslot));
                        
                        %
                        % Counter for invalid epochs due to invalid codes inside them
                        %
                        if (enableTL==0 || enableTL==-1) && excbound % time-lock event's enable fields was 0 or -1
                                countbinINV(1,binslot) = countbinINV(1,binslot) + 1;  % trial counter (invalid trials)
                                binslot = [];
                                try
                                        cprintf([1 0 0],'(!) Epoch #%g had either a "boundary" or an invalid event, so it won''t be included in the averaging process.\n ', i);
                                catch
                                        fprintf('(!) Epoch #%g had either a "boundary" or an invalid event, so it won''t be included in the averaging process.\n ', i);
                                end
                        elseif ismember(-1, enableALL) && excbound % any event's (within this epoch) enable fields was -1
                                countbinINV(1,binslot) = countbinINV(1,binslot) + 1;  % trial counter (invalid trials)
                                binslot = [];                                
                                try
                                        cprintf([1 0 0],'(!) Epoch #%g had either a "boundary" or an invalid event, so it won''t be included in the averaging process.\n ', i);
                                catch
                                        fprintf('(!) Epoch #%g had either a "boundary" or an invalid event, so it won''t be included in the averaging process.\n ', i);
                                end
                        else
                                if ~iscell(artcrite)
                                        
                                        % fprintf('******* EPOCH #%g is being checked for artifact labeling.\n', i)
                                        %
                                        % Checks artifact detection
                                        %
                                        if artcrite~=0
                                                observa = eegartifacts(EEG.reject, fields4reject, i); % 1 or 0
                                                if artcrite==1      % exclude artifacts option is enable
                                                        binslot = nonzeros(binslot * observa)';
                                                elseif artcrite==2  % include "only artifacts" option is enable
                                                        binslot = nonzeros(binslot * ~observa)';
                                                end
                                        end
                                else
                                        %
                                        % Custom epoch indices
                                        %
                                        epindx    = cell2mat(artcrite);
                                        specepoch = ismember(i, epindx); % Is this epoch one of the specified ones?
                                        
                                        if specepoch
                                                fprintf('******* EPOCH #%g was included for averaging.\n', i)
                                        end
                                        %binslot
                                        %specepoch
                                        binslot   = nonzeros(binslot * specepoch)';
                                end
                        end
                        
                        %
                        % Prepare sum, and good trials counter
                        %
                        if ~isempty(binslot)
                                repetibin = length(binslot);
                                bouncebin = repmat(i,1,repetibin);
                                binsum(:,:,binslot)   = binsum(:,:,binslot) + EEG.data(:,:,bouncebin);
                                
                                %
                                % Sum of squares for standard error
                                %
                                if stderror
                                        sumERP2(:,:,binslot) = sumERP2(:,:,binslot) + EEG.data(:,:,bouncebin).^2; % sum of squares: Sum(xi^2)
                                end
                                %fprintf('epoch = %g\n', i);
                                %fprintf('bin   = %g\n',binslot);
                                countbinOK(1,binslot) = countbinOK(1,binslot) + 1;  % counter number epoch per bin
                        end
                else
                        error(['ERPLAB says: averager.m cannot recognize bin '  num2str(numbin) '. Invalid number of Bin at epoch: ' num2str(i)]);
                end
        else
                error(['ERPLAB says: averager.m cannot find time-locked event at epoch: ' num2str(i)]);
        end
end
if ~iscell(artcrite)
        TotalOri = sum(countbiORI,2);
        TotalOK  = sum(countbinOK,2);
        TotalINV = sum(countbinINV,2);
        pREJ     = (TotalOri-TotalOK)*100/TotalOri;  % Total trials rejected percentage
        pINV     = TotalINV*100/TotalOri;            % Total trials invalid in percentage
        
        fprintf('\n----------------------------------------------------------------------------------------\n');
        fprintf('The dataset %s has a %.1f %% of rejected trials\n', EEG.setname, pREJ);
        fprintf('The dataset %s has a %.1f %% of invalid trials\n\n', EEG.setname, pINV);
        fprintf('TOTAL:\n');
        fprintf('The dataset %s has a %.1f %% of  discarded trials\n\n', EEG.setname, pINV + pREJ);
        fprintf('Summary per bin:\n');
end

%
% Averaged ERP
%
for k=1:nbin
        if countbinOK(k)~=0
                N = countbinOK(1,k);
                ERP.bindata(:,:,k)  = binsum(:,:,k)./N;  % get the average!
                
                %
                % Standard deviation/error
                %
                if stderror
                        ERP.binerror(:,:,k) = sqrt((1/(N-1))*sumERP2(:,:,k) - ERP.bindata(:,:,k).^2)./sqrt(N); % get ERP's standard error
                        %ERP.binerror(:,:,k) = sqrt((1/(N-1))*sumERP2(:,:,k) - ERP.bindata(:,:,k).^2); % get ERP's standard deviation
                end
                if ~iscell(artcrite)
                        prejectedT = (countbiORI(1,k)-countbinOK(1,k))*100/countbiORI(1,k);                 %19 setp 2008
                        pinvalidT  = countbinINV(1,k)*100/countbiORI(1,k);                 %19 setp 2008
                        fprintf('Bin %g was created with a %.1f %% of rejected trials\n', k, prejectedT);
                        fprintf('Bin %g was created with a %.1f %% of invalid trials\n', k, pinvalidT);
                else
                        fprintf('Bin %g was customly created from %g epochs specified by you.\n', k, N);
                end
        end
end
if ~iscell(artcrite)
        fprintf('----------------------------------------------------------------------------------------\n');
else
        countbiORI  = countbinOK;
        countbinINV = countbinOK*0;
end
