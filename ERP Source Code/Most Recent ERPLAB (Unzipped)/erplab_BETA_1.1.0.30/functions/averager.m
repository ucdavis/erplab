%
% Usage:
%
%   >> [ERP countbiORI countbinINV countbinOK stderp workfiles] =  averager(EEG, artcrite, stdev)
%
%  HELP under construction for this function
%  Write erplab at command window for more information
%
% Inputs:
%
% EEG          - input epoched dataset
% artcrite     - Exclude epochs marked during artifact detection:  1=yes; 0=no
% stdev        - assess standar deviation values per bin (under construction)
%                1=yes;  0=no.  Keep 0 for this current release.
%
% Outputs:
%
% ERP          - output averaged dataset
% countbinORI  - number epoch per bin, counter.
% countbinINV  - number epoch per bin, counter.
% countbinOK   - number epoch per bin, counter.
% stderp       - stdev of average
% workfiles    - name of averaged dataset
%
%
% Also see: pop_averager.m  averagerGui.m  averagerGui.fig
%
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

function [ERP EVENTLIST countbiORI countbinINV countbinOK countflags workfiles] = averager(EEG, artcrite, stdev)

fprintf('averager.m : START\n');

ERP = builtERPstruct(EEG);  % build ERP strucure (keeping some of the EEGLAB's EEG structure fields)

nepoch = length(EEG.epoch);
nchan  = EEG.nbchan;
points = EEG.pnts;

if isempty(EEG.filename)
        workfiles = EEG.setname;
else
        workfiles = EEG.filename;
end

EVENTLIST = EEG.EVENTLIST;
nbin      = EEG.EVENTLIST.nbin;           % total number of described bins
binsum    = zeros(nchan, points, nbin);   % bin sumatory
countbinOK  = zeros(1,nbin);              % trial counter (only good trials)
countbiORI  = zeros(1,nbin);              % trial counter (ALL trials, originals)
countbinINV = zeros(1,nbin);              % trial counter (invalid trials)
countflags  = zeros(nbin,nepoch);
ERP.bindata = zeros(nchan,points,nbin);   % All averages are zeros at the beginning

if stdev
        ERP.binerror = zeros(nchan, points, nbin); % bins standard deviation
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
% Bin's fusion routine
%
binArray =1:nbin;  % always average all bins.

for i = 1:nepoch

        if length(EEG.epoch(i).eventlatency) == 1

                numbin = EEG.epoch(i).eventbini;
                flagb  = EEG.epoch(i).eventflag;

                if iscell(numbin)
                        numbin = numbin{:}; % allows multiples bins assigning
                end
                if iscell(flagb)
                        flagb = flagb{:};
                end

                % just 1 event at this epoch
                enableTL = EEG.epoch(i).eventenable; % enable field of time-locked event

                if iscell(enableTL)
                        enableTL = enableTL{1};
                end

                enableALL = enableTL;  % cause there is 1 event

        elseif length(EEG.epoch(i).eventlatency) > 1

                indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0); % catch zero-time locked type,
                [numbin]  = [EEG.epoch(i).eventbini{indxtimelock}];
                numbin    = unique(numbin(numbin>0));
                flagb     = EEG.epoch(i).eventflag{indxtimelock};
                % multiple events at his epoch
                enableTL  =  EEG.epoch(i).eventenable{indxtimelock}; % enable field of time-locked event
                enableALL = EEG.epoch(i).eventenable{:}; % enable field of all events
        else
                numbin =[];
        end

        if ~isempty(numbin)

                [tf, binslot]  = ismember(numbin, binArray);  % for now...binslot=bin detected at the current epoch

                if ~isempty(find(tf==1, 1))

                        countbiORI(1,binslot)   = countbiORI(1,binslot) + 1; % trial counter (ALL trials, originals)
                        countflags(binslot,i) = repmat(flagb, 1, length(binslot));

                        %
                        % Counter for invalid epochs because of invalid codes inside them
                        %
                        if enableTL==0 || enableTL==-1
                                countbinINV(1,binslot) = countbinINV(1,binslot) + 1;  % trial counter (invalid trials)
                                binslot = [];

                        elseif ismember(-1, enableALL)
                                countbinINV(1,binslot) = countbinINV(1,binslot) + 1;  % trial counter (invalid trials)
                                binslot=[];

                        else % checks artifact detection

                                if artcrite~=0

                                        observa = eegartifacts(EEG.reject, i);
                                        if artcrite==1      % exclude artifacts option is enable
                                                binslot = nonzeros(binslot * observa)';
                                        elseif artcrite==2  % include "only artifacts" option is enable
                                                binslot = nonzeros(binslot * ~observa)';
                                        end
                                end
                        end

                        if ~isempty(binslot)

                                repetibin = length(binslot);
                                bouncebin = repmat(i,1,repetibin);
                                binsum(:,:,binslot)   = binsum(:,:,binslot) + EEG.data(:,:,bouncebin);

                                if stdev
                                        sumERP2(:,:,binslot)  = sumERP2(:,:,binslot) + EEG.data(:,:,bouncebin).^2; % sum of squares: Sum(xi^2)
                                end

                                countbinOK(1,binslot) = countbinOK(1,binslot) + 1;  % counter number epoch per bin
                        end
                else
                        error(['ERPLAB says: averager.m cannot recognize bin '  num2str(numbin) '. Invalid number of Bin at epoch: ' num2str(i)]);
                end
        else
                error(['ERPLAB says: averager.m cannot find time-locked event at epoch: ' num2str(i)]);
        end
end

TotalOri = sum(countbiORI,2);
TotalOK  = sum(countbinOK,2);
TotalINV = sum(countbinINV,2);

pREJ     = (TotalOri-TotalOK)*100/TotalOri;  % Total trials rejected percentage
pINV     = TotalINV*100/TotalOri;            % Total trials invalid in percentage

fprintf('\n----------------------------------------------------------------------------------------\n');
fprintf('The dataset %s has a %.1f %% of rejected trials\n', EEG.setname, pREJ);
fprintf('The dataset %s has a %.1f %% of invalid trials\n\n', EEG.setname, pINV);
fprintf('TOTAL:\n');
fprintf('The dataset %s has a %.1f %% of  discarded trials\n\n', EEG.setname, pINV+pREJ);

fprintf('Summary per bin:\n');

for k=1:nbin
        if countbinOK(k)~=0
                N = countbinOK(1,k);
                ERP.bindata(:,:,k)  = binsum(:,:,k)./N;  % get average!

                if stdev
                        ERP.binerror(:,:,k) = sqrt((1/N)*sumERP2(:,:,k) - ERP.bindata(:,:,k).^2)./sqrt(N); % ERP stdev
                end
                
                prejectedT = (countbiORI(1,k)-countbinOK(1,k))*100/countbiORI(1,k);                 %19 setp 2008
                pinvalidT  = countbinINV(1,k)*100/countbiORI(1,k);                 %19 setp 2008

                fprintf('Bin %g was created with a %.1f %% of rejected trials\n', k, prejectedT);
                fprintf('Bin %g was created with a %.1f %% of invalid trials\n', k, pinvalidT);
        end
end

fprintf('----------------------------------------------------------------------------------------\n');

fprintf('averager.m : END\n');
