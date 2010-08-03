%
% Usage:
%
%   >> ERP = pop_averager(ALLEEG, setindex, artcrite, wavg)
%
%  HELP under construction for this function
%  Write erplab at command window for more information
%
% Inputs:
%
%  ALLEEG        - input epoched datasets
%  setindex      - EEGLAB dataset index
%  artcrite      - Exclude epochs marked during artifact detection:  1=yes; 0=no  ;2 means "include ONLY marked epochs..."
%  wavg          - Get weighted average. 1=yes; 0=no
%                  This only has meaningful when two or more datasets are averaged.
%                  Among erpsets, their corresponding bins will be averaged
%                  according to the number of trial (per bin) per erpset.
%
% Outputs:
%
%   ERP          - "Event related potential" structure
%
%
% Also see: averager.m  averagerGui.m  averagerGui.fig
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

function [ERP erpcom] = pop_averager(ALLEEG, setindex, artcrite, wavg, stdev)

erpcom = '';
ERP = preloadERP;

if nargin < 1
      help pop_averager
      return
end

if nargin > 5
      error('ERPLAB says: pop_averager() works with 5 arguments max!')
end

nloadedset = length(ALLEEG);

if nargin==1
      
      currdata = evalin('base', 'CURRENTSET');
      if currdata==0
            msgboxText{1} =  'pop_averager() error: cannot average an empty dataset!!!';
            title = 'ERPLAB: No data';
            errorfound(msgboxText, title);
            return
      end
      
      answer = averagerGUI(currdata); % Open a GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      setindex = answer{1};   % datasets to average
      
      %
      % Artifact rejection criteria for averaging
      %
      %  artcrite = 0 --> averaging all (good and bad trials)
      %  artcrite = 1 --> averaging only good trials
      %  artcrite = 2 --> averaging only bad trials
      artcrite = answer{2};
      
      %
      % Weighted average option. 1= yes, 0=no
      %
      wavg     = answer{3};
      %
      % Standard deviation option. 1= yes, 0=no
      %
      stdev     = answer{4};
      
      setindexstr = vect2colon(setindex);
else
      if nargin<5
            stdev=0; % no standard deviation by default
      end
      if nargin<4
            wavg=0; % no weighted average, by default
      end
      
      if nargin<3
            artcrite = 1; % averaging only good trials, by default
      end
      setindexstr = vect2colon(setindex);
end

nset        = length(setindex); % all selected sets

nrsetindex = unique(setindex);     % set index but without repetitions!
nrnset     = length(nrsetindex);   % N of setindex but without repetitions!
setindex   = nrsetindex;           % set index upgraded

if nset > nrnset
      msgboxText{1} =  'Repeated dataset index will be ignored!';
      title        = 'ERPLAB: pop_averager() WARNING';
      errorfound(msgboxText, title);
end

nset     = length(setindex);  % nset  upgraded

if nset > nloadedset
      msgboxText{1} =  ['Hey!  There are not ' num2str(nset) ' datasets, but ' num2str(nloadedset) '!'];
      title        = 'ERPLAB: pop_averager() Error';
      errorfound(msgboxText, title);
      return
end

if max(setindex) > nloadedset
      igrtr       = setindex(setindex>nloadedset);
      indxgreater = num2str(igrtr);
      
      if length(igrtr)==1
            msgboxText{1} =  ['Hey!  dataset #' indxgreater ' does not exist!'];
      else
            msgboxText{1} =  ['Hey!  dataset #' indxgreater ' do not exist!'];
      end
      
      title = 'ERPLAB: pop_averager() Error';
      errorfound(msgboxText, title);
      return
end

if nset==1 && wavg
      
      fprintf('\n********************************************************************\n')
      fprintf('WARNING: Weighted averaging is only available for multiple datasets.\n')
      fprintf('WARNING: ERPLAB will perform a classic averaging over this single dataset.\n')
      fprintf('********************************************************************\n\n')
end

cversion = geterplabversion;

for i=1:nset
      if isempty(ALLEEG(setindex(i)).epoch)
            
            msgboxText =  ['You should epoch your dataset #' ...
                  num2str(setindex(i)) ' before perform averager.m'];
            title = 'ERPLAB: pop_averager() Error';
            errorfound(msgboxText, title);
            return
      end
      
      if isempty(ALLEEG(setindex(i)).data)
            disp(['pop_averager() error: cannot average an empty dataset: ' num2str(setindex(i))])
            return
      end
      
      if ~isfield(ALLEEG(setindex(i)),'EVENTLIST')
            msgboxText =  'You should create/add a EVENTLIST before perform Averaging!';
            title     = 'ERPLAB: pop_averager() Error';
            errorfound(msgboxText, title);
            return
      end
      
      if isempty(ALLEEG(setindex(i)).EVENTLIST)
            msgboxText =  'You should create/add a EVENTLIST before perform Averaging!';
            title     = 'ERPLAB: pop_averager() Error';
            errorfound(msgboxText, title)
            return
      end
      
      if ~strcmp(ALLEEG(setindex(i)).EVENTLIST.version, cversion) && nargin==1
            
            title       = ['ERPLAB: erp_loaderp() for version: ' ALLEEG(setindex(i)).EVENTLIST.version] ;
            question    = cell(1);
            question{1} = sprintf('WARNING: Dataset %g was created from a different ERPLAB version', setindex(i));
            question{2} = 'ERPLAB will try to make it compatible with the current version.';
            question{3} = 'Do you want to continue?';
            
            button = askquest(question, title);
            
            if ~strcmpi(button,'yes')
                  disp('User selected Cancel')
                  return
            end
      elseif ~strcmp(ALLEEG(setindex(i)).EVENTLIST.version, cversion) && nargin>1
            fprintf('\n\nWARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING\n')
            fprintf('ERPLAB: pop_averager() detected version %s\n', ALLEEG(setindex(i)).EVENTLIST.version);
            fprintf('Dataset #%g was created from an older ERPLAB version\n\n', setindex(i));
      end
end

pause(0.1);

if nset>1
      
      %
      % basic test for number of channels (for now...)19 sept 2008
      %
      totalchannelA = sum(cell2mat({ALLEEG(setindex).nbchan}));  % fixed october 03, 2008 JLC
      totalchannelB = (cell2mat({ALLEEG(setindex(1)).nbchan}))*nset;  % fixed october 03, 2008 JLC
      
      if totalchannelA~=totalchannelB
            msgboxText{1} =  'Datasets have different number of channels!';
            title = 'ERPLAB: pop_averager() Error';
            errorfound(msgboxText, title);
            return
      end
      
      %
      % basic test for number of points (for now...)19 sept 2008
      %
      totalpointA = sum(cell2mat({ALLEEG(setindex).pnts})); % fixed october 03, 2008 JLC
      totalpointB = (cell2mat({ALLEEG(setindex(1)).pnts}))*nset; % fixed october 03, 2008 JLC
      
      if totalpointA ~= totalpointB
            msgboxText{1} =  'Datasets have different number of points!';
            title = 'ERPLAB: pop_averager() Error';
            errorfound(msgboxText, title);
            return
      end
      
      %
      % basic test for time axis (for now...)
      %
      tminB = ALLEEG(setindex(1)).xmin;
      tmaxB = ALLEEG(setindex(1)).xmax;
      
      for j=2:nset
            
            tminA = ALLEEG(setindex(j)).xmin;
            tmaxA = ALLEEG(setindex(j)).xmax;
            
            if tminA ~= tminB || tmaxA~=tmaxB
                  msgboxText =  'Datasets have different time axis!';
                  title = 'ERPLAB: pop_averager() Error';
                  errorfound(msgboxText, title);
                  return
            end
      end
      
      %
      % basic test for channel labels
      %
      labelsB = {ALLEEG(setindex(1)).chanlocs.labels};
      
      for j=2:nset
            
            labelsA = {ALLEEG(setindex(j)).chanlocs.labels};
            [tla, indexla] = ismember(labelsA, labelsB);
            
            condlab1 = length(tla)==nnz(tla);   % do both datasets have the same channel labels?
            
            if ~condlab1
                  msgboxText =cell(1);
                  
                  msgboxText{1} =  'Datasets have different channel labels!';
                  msgboxText{2} =  'Do you want to continue anyway?';
                  title = 'ERPLAB: pop_averager() WARNING';
                  button = askquest(msgboxText, title);
                  
                  if ~strcmpi(button,'yes')
                        disp('User selected Cancel')
                        return
                  end
            end
            
            if isrepeated(indexla)
                  
                  fprintf('\nWARNING: Some channels have the same label.\n\n')
                  
                  if ismember(0,strcmp(labelsA, labelsB))
                        msgboxText =cell(1);
                        
                        msgboxText{1} =  'Datasets have different channel labels!';
                        msgboxText{2} =  'Do you want to continue anyway?';
                        title = 'ERPLAB: pop_averager() WARNING';
                        button = askquest(msgboxText, title);
                        
                        if ~strcmpi(button,'yes')
                              disp('User selected Cancel')
                              return
                        end
                  end
                  
            else
                  condlab2 = issorted(indexla);       % do the channel labels match by channel number?
                  
                  if ~condlab2
                        msgboxText =cell(1);
                        msgboxText{1} =  'Channel numbering and channel labeling do not match among datasets!';
                        msgboxText{2} =  'Do you want to continue anyway?';
                        title = 'ERPLAB: pop_averager() WARNING';
                        button = askquest(msgboxText, title);
                        if ~strcmpi(button,'yes')
                              disp('User selected Cancel')
                              return
                        end
                  end
            end
      end
end

%
% Define ERP
%
nch  = ALLEEG(setindex(1)).nbchan;
pnts = ALLEEG(setindex(1)).pnts;
nbin = ALLEEG(setindex(1)).EVENTLIST.nbin;
histoflags = zeros(nbin,16);
flagbit    = bitshift(1, 0:15);

if nset>1
      
      sumERP     = zeros(nch,pnts,nbin);   % makes a zero erp
      if stdev
            sumERP2 = zeros(nch,pnts,nbin);   % makes a zero weighted sum of squares: Sum(wi*xi^2)
      end
      oriperbin  = zeros(1,nbin);         % original number of trials per bin counter init
      tperbin    = zeros(1,nbin);
      invperbin  = zeros(1,nbin);
      workfnameArray = {[]};
      chanlocs       = [];
      
      for j=1:nset
            
            %
            % Note: the standard deviation (std) for multiple epoched datasets is the std across the corresponding averages;
            % Individual stds will be lost.
            
            fprintf('\nAveraging dataset #%g...\n', setindex(j));
            
            [ERP EVENTLISTi countbiORI countbinINV countbinOK countflags workfname] = averager(ALLEEG(setindex(j)), artcrite, stdev);
            
            oriperbin = oriperbin + countbiORI;
            tperbin   = tperbin   + countbinOK;    % only good trials (total)
            invperbin = invperbin + countbinINV;   % invalid trials
            ALLEVENTLIST(j) = EVENTLISTi;
            
            for bb=1:nbin
                  for m=1:16
                        C = bitand(flagbit(m), countflags(bb,:));
                        histoflags(bb, m) = histoflags(bb, m) + nnz(C);
                  end
            end
            
            if wavg
                  for bb=1:nbin
                        sumERP(:,:,bb) = sumERP(:,:,bb)  + ERP.bindata(:,:,bb).*countbinOK(bb);
                        if stdev
                              sumERP2(:,:,bb) = sumERP2(:,:,bb)  + (ERP.bindata(:,:,bb).^2).*countbinOK(bb); % weighted sum of squares: Sum(wi*xi^2)
                        end
                  end
            else
                  sumERP = sumERP + ERP.bindata;
                  if stdev
                        sumERP2   = sumERP2 + ERP.bindata.^2;  % general sum of squares: Sum(xi^2)
                  end
            end
            
            workfnameArray{j}  = workfname;
            
            if isfield(ERP.chanlocs, 'theta')
                  chanlocs = ERP.chanlocs;
            else
                  [chanlocs(1:length(ERP.chanlocs)).labels] = deal(ERP.chanlocs.labels);
            end
      end
      
      ERP.chanlocs = chanlocs;
      
      if wavg
            for bb=1:nbin
                  if tperbin(bb)>0
                        
                        ERP.bindata(:,:,bb) = sumERP(:,:,bb)./tperbin(bb); % get ERP!
                        
                        if stdev
                              fprintf('\nEstimating weighted standard deviation of data...\n');
                              
                              insqrt = sumERP2(:,:,bb).*tperbin(bb) - sumERP(:,:,bb).^2;
                              
                              if nnz(insqrt<0)>0
                                    ERP.binerror(:,:,bb)= zeros(nch, pnts, 1);
                              else
                                    ERP.binerror(:,:,bb)= (1/tperbin(bb))*sqrt(insqrt);
                              end
                        end
                  else
                        ERP.bindata(:,:,bb) = zeros(nch,pnts,1);  % makes a zero erp
                  end
            end
      else
            ERP.bindata = sumERP./nset; % get ERP!
            if stdev
                  fprintf('\nEstimating standard deviation of data...\n');
                  ERP.binerror  = sqrt(sumERP2.*(1/nset) - ERP.bindata.^2) ; % ERP stdev
            end
      end
else
      
      fprintf('\nAveraging  a unique dataset #%g...\n', setindex(1));
      
      [ERP EVENTLISTi countbiORI countbinINV countbinOK countflags workfname] = averager(ALLEEG(setindex(1)), artcrite, stdev);
      
      oriperbin = countbiORI;
      tperbin   = countbinOK;  % only good trials
      invperbin = countbinINV; % invalid trials
      ALLEVENTLIST = EVENTLISTi;
      
      for bb=1:nbin
            for m=1:16
                  C = bitand(flagbit(m), countflags(bb,:));
                  histoflags(bb, m) = nnz(C);
            end
      end
      
      workfnameArray  = cellstr(workfname);
      
      %
      % Note: the standard deviation (std) for a unique epoched dataset is the std across the corresponding epochs;
      %
end

ERP.erpname   = [];
ERP.workfiles = workfnameArray;

if wavg
      fprintf('\n *** %g datasets were weight-averaged. ***\n\n', nset);
else
      fprintf('\n *** %g datasets were averaged (arithmetic mean). ***\n\n', nset);
end

ERP.ntrials.accepted  = tperbin;
ERP.ntrials.rejected  = oriperbin - tperbin;
ERP.ntrials.invalid   = invperbin;
tempflagcount         = fliplr(histoflags); % Total per flag. Flag 1 (LSB) at the rightmost bit
ERP.ntrials.arflags   = tempflagcount(:,9:16);       % show only the less significative byte (artifact flags)
ERP.EVENTLIST         = ALLEVENTLIST;

if nargin==1
      [ERP issave] = pop_savemyerp(ERP,'gui','erplab');
else
      issave = 1;
end

[ERP serror] = sorterpstruct(ERP);
if serror
      error('ERPLAB says: pop_averager() Your datasets are not compatibles')
end
if issave
      erpcom = sprintf( 'ERP = pop_averager( %s, %s, %s, %s );', inputname(1), setindexstr,...
            num2str(artcrite), num2str(wavg));
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      return
else
      disp('user canceled')
      return
end
