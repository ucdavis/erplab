% Usage
%
% i)  ERP = pop_gaverager(ALLERP, [erp_index], iswavg)
%
% or
%
% ii) ERP = pop_gaverager('loadlist', filename, iswavg)
%
%
% Inputs:
%
% ALLERP       - structure array of ERP structures (ERPsets)
% erp_index    - index(ces) pointing to ERP structures within ALLERP
% filename     - name of a text file containing the list of ERPset filenames (with path)
% iswavg       - 1 means apply weight-average, 0 means classic average.
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

function [ERPout erpcom] = pop_gaverager(varargin)

erpcom = '';
ERPout = preloadERP;

if nargin>4
      error('ERPLAB says: error at pop_gaverager(). Wrong number of inputs.')
elseif nargin<1
      help pop_gaverager
      return
end

if nargin==1  % GUI
      
      aux = varargin{1};
      
      if isstruct(aux)
            iserp = iserpstruct(aux(1));
            
            if iserp
                  ALLERP = aux;
            else
                  ALLERP = [];
            end
      else
            ALLERP = [];
      end
      
      inputgui = grandaveragerGUI(ALLERP);
      
      if isempty(inputgui)
            disp('User selected Cancel')
            return
      end
      
      optioni  = inputgui{1}; %1 means from hard drive, 0 means from erpsets menu
      erpset   = inputgui{2};
      wavg     = inputgui{3};
      stdev    = inputgui{4};
      
      if optioni==1 % from files
            filelist = erpset;
      else % from erpsets
            nfile        = length(erpset);
            erpsetArray = erpset;
      end
      
      menup =1;
      
else  % Scripting
      
      if nargin>4
            error('ERPLAB says: error at pop_gaverager(). Wrong number of inputs')
      end
      if nargin<2
            error('ERPLAB says: error at pop_gaverager(). Missing input')
      end
      if nargin<4
            stdev = 0;
      else
            stdev = varargin{4};
      end
      if nargin<3
            wavg = 0; % 1=weighted average;  0=classic average
      else
            wavg = varargin{3};
      end
      
      aux   = varargin{1};
      iserp = iserpstruct(aux(1));
      
      if iserp
            ALLERP = aux;
            erpsetArray = varargin{2};
            nfile        = length(erpsetArray);
            optioni = 0;
      else
            if ischar(aux)
                  if strcmpi(aux,'loadlist')
                        filelist = varargin{2};
                        optioni  = 1;
                  else
                        error(['ERPLAB says: cannot recognize ' aux ' as an input'])
                  end
            else
                  error(['ERPLAB says: cannot recognize ' aux ' as an input'])
            end
      end
      menup = 0;
end

if optioni==1
      
      disp(['pop_gaverager(): For file-List, user selected ', filelist])
      
      try
            fid_list   = fopen( filelist );
            inputfname   = textscan(fid_list, '%[^\n]','CommentStyle','#');
            fclose(fid_list);
            
            inputfname    = strtrim(cellstr(inputfname{:}));
            nfile = length(inputfname);
      catch
            error([filelist ' couldn''t be loaded'])
      end
end

naccepted = [];
nrejected = [];
ninvalid  = [];
narflags  = [];

for j=1:nfile
      
      fprintf('Including ERP #%g...\n', j);
      
      if optioni==1
            ERPTX = load(inputfname{j}, '-mat');
            ERPT  = ERPTX.ERP;
      else
            ERPT = ALLERP(erpsetArray(j));
      end
      
      [ERPT conti serror] = olderpscan(ERPT, menup);
      
      if conti==0
            break
      end
      
      if serror
            msgboxText{1} =  sprintf('Your erpset %s is not compatible at all with the current ERPLAB version',ERP.filename);
            msgboxText{2} =  'Please, try upgrading your ERP structure.';
            title = 'ERPLAB: erp_loaderp() Error';
            errorfound(msgboxText, title);
            break
      end
      
      if j>1
            % basic test for number of channels (for now...)
            if  pre_nchan ~= ERPT.nchan
                  msgboxText =  sprintf('Erpsets #%g and #%g have different number of channels!', j-1, j);
                  title = 'ERPLAB: pop_gaverager() Error';
                  errorfound(msgboxText, title);
                  return
            end
            
            % basic test for number of points (for now...)
            if pre_pnts  ~= ERPT.pnts
                  msgboxText =  sprintf('Erpsets #%g and #%g have different number of points!', j-1, j);
                  title = 'ERPLAB: pop_gaverager() Error';
                  errorfound(msgboxText, title);
                  return
            end
            
            % basic test for number of bins (for now...)
            if pre_nbin  ~= ERPT.nbin
                  msgboxText =  sprintf('Erpsets #%g and #%g have different number of bins!', j-1, j);
                  title = 'ERPLAB: pop_gaverager() Error';
                  errorfound(msgboxText, title);
                  return
            end
      end
      
      pre_nchan = ERPT.nchan;
      pre_pnts  = ERPT.pnts;
      pre_nbin  = ERPT.nbin;
      
      if j==1
            workfileArray = ERPT.workfiles;
            [nch npnts nbin] = size(ERPT.bindata);
            sumERP       = zeros(nch,npnts,nbin);
            if stdev
                  sumERP2      = zeros(nch,npnts,nbin);
            end
            naccepted    = zeros(1,nbin);
            nrejected    = zeros(1,nbin);
            ninvalid     = zeros(1,nbin);
            narflags     = zeros(nbin,8);
            ERP.erpname  = [];
            ERP.filename = [];
            ERP.filepath = [];
            ERP.subject  = ERPT.subject;
            ERP.nchan    = ERPT.nchan;
            ERP.nbin     = ERPT.nbin;
            ERP.pnts     = ERPT.pnts;
            ERP.srate    = ERPT.srate;
            ERP.xmin     = ERPT.xmin;
            ERP.xmax     = ERPT.xmax;
            ERP.times    = ERPT.times;
            ERP.bindata  = [];
            ERP.binerror = [];
            ERP.chanlocs = ERPT.chanlocs;
            ERP.ref      = ERPT.ref;
            ERP.bindescr = ERPT.bindescr;
            ERP.history  = ERPT.history;
            ERP.saved    = ERPT.saved;
            ERP.isfilt   = ERPT.isfilt;
            ERP.version  = ERPT.version;
            EVEL         = ERPT.EVENTLIST;
            ALLEVENTLIST(1:length(EVEL)) = EVEL;
      else
            workfileArray = [workfileArray ERPT.workfiles];
            EVEL =  ERPT.EVENTLIST;
            ALLEVENTLIST(end+1:end+length(EVEL)) = EVEL;
      end
      
      countbinOK = [ERPT.ntrials.accepted]; % These work as weights
      
      if wavg
            for bb=1:pre_nbin
                  sumERP(:,:,bb)  = sumERP(:,:,bb)  + ERPT.bindata(:,:,bb).*countbinOK(bb);      % weighted sum: Sum(wi*xi)
                  if stdev
                        sumERP2(:,:,bb) = sumERP2(:,:,bb)  + (ERPT.bindata(:,:,bb).^2).*countbinOK(bb); % weighted sum of squares: Sum(wi*xi^2)
                  end
            end
      else
            sumERP    = sumERP + ERPT.bindata;              % general sum: Sum(xi)
            if stdev
                  sumERP2   = sumERP2 + ERPT.bindata.^2;  % general sum of squares: Sum(xi^2)
            end
      end
      
      naccepted = naccepted + countbinOK;             % sum of (current) weights: Sum(wi)
      nrejected = nrejected + ERPT.ntrials.rejected;
      ninvalid  = ninvalid  + ERPT.ntrials.invalid;
      
      %
      % Sum flags counter per bin
      %
      if isfield(ERPT.ntrials, 'arflags')
            narflags  = narflags  + ERPT.ntrials.arflags;
      end
end

if conti==0
      return
end
if serror==1
      fprintf('pop_gaverager() cancelled.\n');
      return
end

ERP.erpname   = [];
ERP.workfiles = workfileArray;
ERP.EVENTLIST = ALLEVENTLIST;

if wavg
      for bb=1:pre_nbin
            
            if naccepted(bb)>0
                  
                  ERP.bindata(:,:,bb) = sumERP(:,:,bb)./naccepted(bb); % get ERP!  --> weighted sum is divided by the sum of the weights
                  
                  if stdev
                        if bb==1
                              fprintf('\nEstimating weighted standard deviation of data...\n');
                        end
                        
                        insqrt = sumERP2(:,:,bb).*naccepted(bb) - sumERP(:,:,bb).^2;
                        
                        if nnz(insqrt<0)>0
                              ERP.binerror(:,:,bb)= zeros(nch,npnts,1);
                        else
                              ERP.binerror(:,:,bb)= (1/naccepted(bb))*sqrt(insqrt);
                        end
                  end
            else
                  ERP.bindata(:,:,bb) = zeros(nch,npnts,1);            % makes a zero erp
                  if stdev
                        ERP.binerror(:,:,bb)= zeros(nch,npnts,1);
                  end
            end
      end
else
      ERP.bindata   = sumERP./nfile; % get ERP!  --> general sum is divided by the number of files (erpsets)
      if stdev
            fprintf('\nEstimating standard deviation of data...\n');
            ERP.binerror  = sqrt(sumERP2.*(1/nfile) - ERP.bindata.^2) ; % ERP stdev
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

ERP.ntrials.accepted = naccepted;
ERP.ntrials.rejected = nrejected;
ERP.ntrials.invalid  = ninvalid;
ERP.ntrials.arflags  = narflags;

if wavg
      fprintf('\n %g ERPs were (weight) averaged.\n', nfile);
else
      fprintf('\n %g ERPs were (classic) averaged.\n', nfile);
end

[ERP serror] = sorterpstruct(ERP);

ERP.saved  = 'no';
ERP.isfilt = 1;

if menup
      [ERP issave] = pop_savemyerp(ERP,'gui','erplab');
else
      issave = 1;
end

ERPout = ERP;

if issave
      if optioni
            erpcom = sprintf('ERP = pop_gaverager(''loadlist'', ''%s'', %s, %s);', filelist, num2str(wavg), num2str(stdev));
      else
            erpcom = sprintf('ERP = pop_gaverager(ALLERP, %s, %s, %s);', vect2colon(erpsetArray), num2str(wavg), num2str(stdev));
      end
      
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      return
else
      disp('Warning: Your ERP structure has not yet been saved')
      disp('user canceled')
      return
end