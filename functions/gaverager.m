% PURPOSE  : 	Averages bin-based ERPsets (grand average)
%
% FORMAT   :
%
% ERP = pop_gaverager( ALLERP , Parameters);
%
%
% INPUTS   :
%
% ALLERP            - structure array of ERP structures (ERPsets)
%                     To read the ERPset from a list in a text file,
%                     replace ALLERP by the whole filename.
%
% The available parameters are as follows:
%
% 'Erpsets'         - index(es) pointing to ERP structures within ALLERP (only valid when ALLERP is specified)
% 'Weighted'        - 'on' means apply weighted-average, 'off' means classic average.
% 'SEM'             - Get standard error of the mean. 'on' or 'off'
% 'Warning'         - Warning 'on' or 'off'
% 'Criterion'       - Max allowed mean artifact detection proportion
%
% OUTPUTS  :
%
% ERP               - data structure containing the average of all specified datasets.
%
%
% EXAMPLE  :
%
% ERP = pop_gaverager( ALLERP , 'Erpsets',1:4, 'Criterion',100, 'SEM',...
% 'on', 'Warning', 'on', 'Weighted', 'on' );
%
% or
%
% ERP = pop_gaverager('C:\Users\Work\Documents\MATLAB\ERP_List.txt', 'Criterion',100,...
% 'SEM', 'on', 'Warning', 'on', 'Weighted', 'on');
%
%
% See also grandaveragerGUI.m  pop_gaverager.m pop_averager.m averager.m
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

function [ERP, serror, msgboxText ] =  gaverager(ALLERP, lista, optioni, erpset, nfile, wavg, stderror, artcrite, exclunullbin, warn)

% ERPaux = ERP; % original ERP
naccepted    = [];
auxnaccepted = []; % ###
nrejected    = [];
ninvalid     = [];
narflags     = [];
serror       = 0;
msgboxText   = '';
ds=1;

%
% Reads and sums ERPsets
%
for j=1:nfile
        if optioni==1
                fprintf('Loading %s...\n', lista{j});
                ERPTX = load(lista{j}, '-mat');
                ERPT  = ERPTX.ERP;
        else
                ERPT = ALLERP(erpset(j));
        end
        
        [ERPT, conti, serror] = olderpscan(ERPT, warn);
        
        if conti==0
                break
        end
        if serror
                msgboxText =  sprintf(['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
                        'Please, try upgrading your ERP structure.'], ERP.filename);
                %title = 'ERPLAB: erp_loaderp() Error';
                %errorfound(sprintf(msgboxText, ERP.filename), title);
                break
        end
        if j>1
                % basic test for number of channels (for now...)
                if  pre_nchan ~= ERPT.nchan
                        msgboxText =  sprintf('Erpsets #%g and #%g have different number of channels!', j-1, j);
                        %title = 'ERPLAB: pop_gaverager() Error';
                        %errorfound(msgboxText, title);
                        serror = 1;
                        break
                end
                % basic test for number of points (for now...)
                if pre_pnts  ~= ERPT.pnts
                        msgboxText =  sprintf('Erpsets #%g and #%g have different number of points!', j-1, j);
                        %title = 'ERPLAB: pop_gaverager() Error';
                        %errorfound(msgboxText, title);
                        %return
                        serror = 1;
                        break
                end
                % basic test for number of bins (for now...)
                if pre_nbin  ~= ERPT.nbin
                        msgboxText =  sprintf('Erpsets #%g and #%g have different number of bins!', j-1, j);
                        %title = 'ERPLAB: pop_gaverager() Error';
                        %errorfound(msgboxText, title);
                        %return
                        serror = 1;
                        break
                end
                % basic test for data type (for now...)
                if ~strcmpi(pre_dtype, ERPT.datatype)
                        msgboxText =  sprintf('Erpsets #%g and #%g have different type of data (see ERP.datatype)', j-1, j);
                        %title = 'ERPLAB: pop_gaverager() Error';
                        %errorfound(msgboxText, title);
                        %return
                        serror = 1;
                        break
                end
        end
        
        pre_nchan  = ERPT.nchan;
        pre_pnts   = ERPT.pnts;
        pre_nbin   = ERPT.nbin;
        pre_dtype  = ERPT.datatype;
        
        %
        % Sum ERPsets
        %
        if isempty(ERPT.pexcluded)
                ERPT.pexcluded = 0;
        end
        
        %
        % Artifact detection threshold test
        %
        if ERPT.pexcluded> artcrite  % test the mean artifact detection prop per ERPset
                callwarning(sprintf('%d) ', j),'');
                fprintf(' ERPset # %d "%s" has %.1f %% of mean artifact detection.\n', j, ERPT.erpname, ERPT.pexcluded);
                fprintf(' ERP #%g is being included anyway...\n', j);
        else
                fprintf(' %d) Including %s...\n', j, ERPT.erpname);
        end
        
        %
        % Preparing ERP struct (first ERP)
        %
        if ds==1
                workfileArray    = ERPT.workfiles;
                [nch, npnts, nbin] = size(ERPT.bindata);
                sumERP           = zeros(nch,npnts,nbin);
                if stderror
                        sumERP2  = zeros(nch,npnts,nbin);
                end
                naccepted      = zeros(1,nbin);
                auxnaccepted   = zeros(1,nbin); % ###
                nrejected      = zeros(1,nbin);
                ninvalid       = zeros(1,nbin);
                narflags       = zeros(nbin,8);
                % ERPset
                ERP.erpname    = [];
                ERP.filename   = [];
                ERP.filepath   = [];
                ERP.subject    = ERPT.subject;
                ERP.nchan      = ERPT.nchan;
                ERP.nbin       = ERPT.nbin;
                ERP.pnts       = ERPT.pnts;
                ERP.srate      = ERPT.srate;
                ERP.xmin       = ERPT.xmin;
                ERP.xmax       = ERPT.xmax;
                ERP.times      = ERPT.times;
                ERP.bindata    = [];
                ERP.binerror   = [];
                
                ERP.datatype   = ERPT.datatype;
                
                ERP.chanlocs   = ERPT.chanlocs;
                ERP.ref        = ERPT.ref;
                ERP.bindescr   = ERPT.bindescr;
                ERP.history    = ERPT.history;
                ERP.saved      = ERPT.saved;
                ERP.isfilt     = ERPT.isfilt;
                ERP.version    = ERPT.version;
                ERP.splinefile = ERPT.splinefile;
                EVEL           = ERPT.EVENTLIST;
                ALLEVENTLIST(1:length(EVEL)) = EVEL;
        else
                workfileArray = [workfileArray ERPT.workfiles];
                EVEL =  ERPT.EVENTLIST;
                ALLEVENTLIST(end+1:end+length(EVEL)) = EVEL;
        end
        
        countbinOK = [ERPT.ntrials.accepted]; % These work as weights
        auxbinok   = countbinOK;   % ###
        
        if wavg || exclunullbin % weighted or exclude null bins. JLC    
                if exclunullbin
                        countbinOK = ~ismember_bc2(countbinOK, 0); % converts a weighted averaging into a classic averaging when exclunullbin is set .
                        if ~all(countbinOK)
                                inullb = find(~countbinOK);
                                fprintf('\nNOTE: Excluding null bin(s) %s from ERPset # %d "%s"\n\n', num2str(inullb), j, ERPT.erpname);
                        end
                end
                for bb=1:pre_nbin
                        sumERP(:,:,bb)  = sumERP(:,:,bb)  + ERPT.bindata(:,:,bb).*countbinOK(bb);               % cumulative weighted sum: Sum(wi*xi)
                        if stderror
                                sumERP2(:,:,bb) = sumERP2(:,:,bb)  + (ERPT.bindata(:,:,bb).^2).*countbinOK(bb); % cumulative weighted sum of squares: Sum(wi*xi^2)
                        end
                end
        else % classic
                if ~all(countbinOK)
                        inullb = find(~countbinOK);
                        fprintf('\n');
                        %callwarning;
                        %fprintf(' ERPset # %d "%s" contains null bin(s) (bin # = %s).\n', j, ERPT.erpname, num2str(inullb));
                        %fprintf(' Nevertheless, ERP #%g is being included in the grand avarage.\n', j);
                        %fprintf(' Use the option "Exclude any null bin from non-weighted averaging" to avoid this behavior.\n\n');
                        
                        msgnullbin = [' ERPset #%d "%s" contains one or more null bin(s) (bin #%s).\n'...
                                'These are bins in which the number of trials was zero, which may distort the resulting grand average.\n'...
                                'Nevertheless, this ERPset is being included in the grand avarage.\n'...
                                'If you want to excluded null bins, use the option "Exclude any null bin from non-weighted averaging."\n\n'];
                        msgnullbin = sprintf(msgnullbin, j, ERPT.erpname, num2str(inullb));
                        callwarning(msgnullbin)
                end
                sumERP    = sumERP + ERPT.bindata;                % cumulative sum: Sum(xi)
                if stderror
                        sumERP2   = sumERP2 + ERPT.bindata.^2;    % cumulative sum of squares: Sum(xi^2)
                end
        end   
        if length(naccepted)==length(countbinOK)
            naccepted    = naccepted + countbinOK;                      % cumulative sum of weights: Sum(wi)
            auxnaccepted = auxnaccepted + auxbinok;                      % ###
            nrejected    = nrejected + ERPT.ntrials.rejected;
            ninvalid     = ninvalid  + ERPT.ntrials.invalid;
            
            %
            % Sum flags counter per bin
            %
            if isfield(ERPT.ntrials, 'arflags')
                narflags  = narflags  + ERPT.ntrials.arflags;
            end
        else
            warning('naccepted field size does not match the number of current bins')
            naccepted    = naccepted + ones(1,nbin);                       % cumulative sum of weights: Sum(wi)
            auxnaccepted = auxnaccepted + ones(1,nbin) ;                      % ###
            nrejected    = nrejected + zeros(1,nbin);
            ninvalid     = ninvalid  + zeros(1,nbin);
            
            %
            % Sum flags counter per bin
            %
            if isfield(ERPT.ntrials, 'arflags')
                narflags  = narflags  + zeros(nbin,8);
            end
        end
        
        ds = ds+1; % counter for clean ERPsets (keep it that way until Steve might eventually decide to reject subjects automatically...)
        %       else
        %             callwarning(sprintf('%d) ', j),'');
        %             fprintf(' ERPset # %d "%s" was skipped because it had %.1f %% of mean artifact detection.\n', j, ERPT.erpname, ERPT.pexcluded);
        %       end
end
if conti==0
        return
end
if serror>0
        fprintf('pop_gaverager() aborted.\n');
        return
end
if ~exist('sumERP', 'var')
        error('ERPLAB:emptyERP','\nERPLAB says: Your grand average is empty which means none of your ERPset met the artifact proportion criterion you specified.\n\n')
end
ERP.erpname   = [];
ERP.workfiles = workfileArray;
ERP.EVENTLIST = ALLEVENTLIST;

%
% Gets the grand averaged ERPset
%
if wavg || exclunullbin % weighted or exclude null bins
        for bb=1:pre_nbin
                if naccepted(bb)>0
                        ERP.bindata(:,:,bb) = sumERP(:,:,bb)./naccepted(bb); % get ERP!  --> weighted sum is divided by the sum of the weights
                        if stderror
                                if bb==1
                                        fprintf('\nEstimating weighted standard error of the mean...\n');
                                end
                                insqrt = sumERP2(:,:,bb).*naccepted(bb) - sumERP(:,:,bb).^2;
                                if nnz(insqrt<0)>0
                                        ERP.binerror(:,:,bb) = zeros(nch,npnts,1);
                                else
                                        ERP.binerror(:,:,bb) = (1/naccepted(bb))*sqrt(insqrt);
                                end
                        end
                else
                        ERP.bindata(:,:,bb) = zeros(nch,npnts,1);            % makes a zero erp
                        if stderror
                                ERP.binerror(:,:,bb)= zeros(nch,npnts,1);
                        end
                end
        end
else % classic
        ERP.bindata = sumERP./nfile; % get ERP!  --> general sum is divided by the number of files (erpsets)
        if stderror
                fprintf('\nEstimating standard error of the mean...\n');
                ERP.binerror  = sqrt(sumERP2.*(1/nfile) - ERP.bindata.^2) ; % ERP stderror
        end
end
if ~isempty(ERP.binerror)
        if nnz(ERP.binerror>0)==0
                fprintf('\n*******************************************************\n');
                fprintf('WARNING: There is not variance in the data! So, ERP.binerror = [] \n');
                fprintf('*******************************************************\n\n');
                ERP.binerror = [];
        end
end

ERP.ntrials.accepted = auxnaccepted;  % ###
ERP.ntrials.rejected = nrejected;
ERP.ntrials.invalid  = ninvalid;
ERP.ntrials.arflags  = narflags;
vali = round(1000*(sum(nrejected)/(sum(auxnaccepted)+sum(nrejected))))/10;  % ###
ERP.pexcluded = vali;

[ERP, serror] = sorterpstruct(ERP);
if serror
        error('ERPLAB:pop_gaverager','\nERPLAB says: Your ERPsets are not compatibles')
end
if wavg
        fprintf('\n %g ERPs were (weight) averaged.\n', ds-1);
else
        fprintf('\n %g ERPs were (classic) averaged.\n', ds-1);
end
