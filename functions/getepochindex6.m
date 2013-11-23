% PURPOSE: gets epoch indices from epochs that meet a set of criteria.
%
% FORMAT
%
% eindices = getepochindex6(ALLEEG, parameters)
%
% INPUTS
%
%   ALLEEG       - epoched dataset or ERPset
%
% The available parameters are as follows:
%
%        'Dataset'     	- dataset index(ices) (from ALLEEG)
%        'Bin'          - bin index(ices)
%        'Nepoch' 	    - number of epochs per bin
%        'Artifact'     - artifact detection criterion (it means "include the following epochs"): 'all','good', or 'bad'
%        'Catching'     - 'sequential', 'random', 'odd', 'even', 'prime'
%        'Indexing'     - 'absolute', 'relative'
%        'Episode'      - 'any', .25 .75, or 340 1234 or 'any'; proportion of recording [start_1 end_1 ...]
%        'Instance'     - 'anywhere', 'first', 'last'
%        'Warning'      - display warning. 'on'/'off'
%
% OUTPUT:
%
%   eindices            - epoch indices from epochs that meet a set of criteria.
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

function eindices = getepochindex6(ALLEEG, varargin)

eindices = [];

if nargin<1
      help
      return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.addRequired('ALLEEG');

p.addParamValue('Dataset', 1, @isnumeric);         % e.g. [2 5]
p.addParamValue('Bin', [], @isnumeric);            % e.g. [1:4]
p.addParamValue('Nepoch', 1);                      % e.g. 'amap', 100
p.addParamValue('Artifact', 'good', @ischar);      % e.g 'all','good','bad'
p.addParamValue('Catching', 'sequential', @ischar);  % e.g 'sequential', 'random', 'odd', 'even', 'prime'
p.addParamValue('Indexing', 'absolute', @ischar);  % e.g. 'absolute', 'relative'
p.addParamValue('Episode', 'any');                 % e.g. 'any', .25 .75, or 340 1234 or 'any'; proportion of recording [start_1 end_1 ...]
p.addParamValue('Instance', 'anywhere', @ischar);  % e.g. 'anywhere', 'first', 'last'
p.addParamValue('Warning', 'on', @ischar);         % e.g. 'on', 'off'
p.parse(ALLEEG, varargin{:});

dataset  = p.Results.Dataset;
bini     = p.Results.Bin;
if isempty(bini) % JLC
      numbin = ALLEEG(dataset(end)).EVENTLIST.nbin;
      bini = 1:numbin;
end

nepoch   = p.Results.Nepoch;
artifact = p.Results.Artifact;
catching = p.Results.Catching;
indexing = p.Results.Indexing;
episode  = p.Results.Episode;
instance = p.Results.Instance;
warning  = p.Results.Warning;

%
% additional parsing
%
ntset = length(ALLEEG); % total dataset at ALLEEG
nset  = length(dataset);
uset  = unique_bc2(dataset);

if length(uset)~=nset
      %       msgboxText =  'Repeated dataset indices were found.\n';
      %       title = 'ERPLAB: getepochindex() Error';
      %       errorfound(msgboxText, title);
      %       return
      fprintf('\nWARNING: Repeated dataset indices were found.\n')
      fprintf('ERPLAB will ignore the repeated one(s).\n\n')
      dataset = uset;
      nset  = length(dataset);
end
if max(dataset)>ntset
      msgboxText =  'dataset index(ices) out of range.\n';
      title = 'ERPLAB: getepochindex() Error';
      errorfound(msgboxText, title);
      return
end

%
% additional parsing
%
nbin  = length(bini);
uubin = unique_bc2(bini);
if length(uubin)~=nbin
      %       msgboxText =  'Repeated dataset indices were found.\n';
      %       title = 'ERPLAB: getepochindex() Error';
      %       errorfound(msgboxText, title);
      %       return
      fprintf('\nWARNING: Repeated bin indices were found.\n')
      fprintf('ERPLAB will ignore the repeated one(s).\n\n')
      bini = uubin;
      nbin = length(bini);
end
% if max(bini)>nbin
%         msgboxText =  'bin index(ices) out of range.\n';
%         title = 'ERPLAB: getepochindex() Error';
%         errorfound(msgboxText, title);
%         return
% end

%
% Check number of epochs per bin
%
if ischar(nepoch)
      nepoch = Inf; % amap=as much as possible
end
if length(nepoch)==1 && length(bini)>=1
      nepoch = repmat(nepoch,1, length(bini));
elseif length(nepoch)~=1 && length(nepoch)~=length(bini)% && strcmp(nepoch, 'amap')~=1;
      msgboxText =  'Number of epochs value must be a single value OR as many values as bins you have.\n';
      title = 'ERPLAB: getepochindex() Error';
      errorfound(msgboxText, title);
      return
end
if mod(length(episode),2)~=0
      if ischar(episode) && ~strcmpi(episode, 'any')
            msgboxText =  'Episode must have an even amount of values';
            title = 'ERPLAB: getepochindex() Error';
            errorfound(msgboxText, title);
            return
      end
end

%
% more checking...
%
ncurrentbin = zeros(1,nset);
for i=1:nset
      if isempty(ALLEEG(dataset(i)).epoch)
            msgboxText =  ['You should epoch your dataset #' ...
                  num2str(dataset(i)) ' before perform getepochindex.m'];
            title = 'ERPLAB: getepochindex() Error';
            errorfound(msgboxText, title);
            return
      end
      if isempty(ALLEEG(dataset(i)).data)
            errormsg = ['ERPLAB says: getepochindex() error cannot work with an empty dataset: ' num2str(dataset(i))];
            error(errormsg)
      end
      if ~isfield(ALLEEG(dataset(i)),'EVENTLIST')
            msgboxText =  'You should create/add a EVENTLIST before perform getepochindex()!';
            title      = 'ERPLAB: getepochindex() Error';
            errorfound(msgboxText, title);
            return
      end
      if isempty(ALLEEG(dataset(i)).EVENTLIST)
            msgboxText =  'You should create/add a EVENTLIST before perform getepochindex()!';
            title      = 'ERPLAB: getepochindex() Error';
            errorfound(msgboxText, title);
            return
      end
      ncurrentbin(i) = ALLEEG(dataset(i)).EVENTLIST.nbin;
      if i>1
            if ncurrentbin(i)~=ncurrentbin(i-1)
                  msgboxText =  'Number of bins are different across specified datasets';
                  title      = 'ERPLAB: getepochindex() Error';
                  errorfound(msgboxText, title);
                  return
            end
      end
end

%
% Get the number of trials (epochs) per dataset
%
numtrials = zeros(1,nset);
for h=1:nset
      numtrials(h) = ALLEEG(dataset(h)).trials;
end

nmaxtrials = max(numtrials); % max number of trials among datasets
nmintrials = min(numtrials); % min number of trials among datasets

% get ar fields
F = fieldnames(ALLEEG(dataset(end)).reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
fields4reject  = regexprep(sfields2,'E','');
nf = length(fields4reject);
wannago  = 1;
% eindices = repmat({[]}, 1,nset);
eindices = {[]};


for h=1:nset % dataset
      Tempeindices = [];
      for ibin=1:nbin % bin
            
            %
            % Get epochs indices per each specified bin
            %
            bepochArray = epoch4bin(ALLEEG(dataset(h)), bini(ibin)); % absolute epoch indices (meaning related to the beginning of the current dataset)
            
            if isempty(bepochArray)
                  fprintf('WARNING: There was not found any epoch for bin %g ', ibin)
            else
                  %
                  % ARTIFACT DETECTION CRITERION
                  %
                  arepochindx = zeros(1,numtrials(h)); % vector for storing AR values
                  
                  for i=1:nf  % AR field
                        if ~isempty(ALLEEG(dataset(h)).reject.(fields4reject{i}))
                              arepochindx(i,:) = ALLEEG(dataset(h)).reject.(fields4reject{i});
                        end
                  end
                  
                  arepochindx   = arepochindx(:,bepochArray); % artifact marks across different fields and only epochs for the current bin's epochs
                  sumat         = sum(arepochindx,1);     % sum across fields
                  badepochindx  = find(sumat);    % find bad epoch indices (any element higher than zero)
                  goodepochindx = find(sumat==0); % find good epoch indices (any zero value element)
                  
                  if strcmpi(artifact, 'good')
                        if isempty(goodepochindx)
                              error('prog:input', 'ERPLAB says: There was not found any %s epoch for bin %g ', artifact, ibin)
                        end
                        selectedepochs = bepochArray(goodepochindx);
                        str4ep = 'good';
                  elseif strcmpi(artifact, 'bad')
                        if isempty(badepochindx)
                              error('prog:input', 'ERPLAB says: There was not found any %s epoch for bin %g ', artifact, ibin)
                        end
                        str4ep = 'bad';
                        selectedepochs = bepochArray(badepochindx);
                  elseif strcmpi(artifact, 'all')
                        str4ep = '';
                        selectedepochs = bepochArray;    % all
                  else
                        error('prog:input', 'ERPLAB says: Unrecognizable criterion "%s"', artifact)
                  end
                  
                  %
                  % CATCHING
                  %
                  if strcmpi(catching, 'random') || strcmpi(catching, 'rand')
                        nsel = length(selectedepochs);
                        nselrindx = randperm(nsel);
                        selectedepochs = selectedepochs(nselrindx); %  random and sorted again
                  elseif strcmpi(catching, 'odd')
                        %
                        % absolute or relative indexing?
                        %
                        if strcmpi(indexing, 'absolute')
                              selectedepochs = selectedepochs(logical(mod(selectedepochs,2)));
                        else % relative
                              nsel = length(selectedepochs);
                              oddindx = 1:2:nsel;
                              selectedepochs = selectedepochs(oddindx);
                        end
                  elseif strcmpi(catching, 'even')
                        %
                        % absolute or relative indexing?
                        %
                        if strcmpi(indexing, 'absolute')
                              selectedepochs = selectedepochs(~logical(mod(selectedepochs,2)));
                        else % relative
                              nsel = length(selectedepochs);
                              evenindx = 2:2:nsel;
                              selectedepochs = selectedepochs(evenindx);
                        end
                  elseif strcmpi(catching, 'prime')
                        %
                        % absolute or relative indexing?
                        %
                        if strcmpi(indexing, 'absolute')
                              selectedepochs = selectedepochs(isprime(selectedepochs));
                        else % relative
                              nsel = length(selectedepochs);
                              primeindx = primes(nsel); % prime relative (local) indices
                              selectedepochs = selectedepochs(primeindx);
                        end
                  else
                        %sequential (on the fly) --> default
                  end
                  
                  %
                  % EPISODE
                  %
                  %pepisode = episode;
                  if ~ischar(episode)
                        if episode(1)>1 && episode(2)>1 %correct time if it is not proportion
                              totaltime=(ALLEEG(dataset(h)).xmax-ALLEEG(dataset(h)).xmin)*ALLEEG(dataset(h)).trials;
                              episode(1)=episode(1)/totaltime;
                              episode(2)=episode(2)/totaltime;
                        end
                        nsegelem  = length(episode);
                        pepisode  = reshape(reshape(episode,nsegelem/2,2), 2,nsegelem/2)'; % reorganize each couple as a row.
                        npepi     = size(pepisode,1); % how many proportional episodes we got
                        total     = 100;
                        part      = [];
                        
                        for pe=1:npepi
                              part  = [part round(pepisode(pe,1)*100):round(pepisode(pe,2)*100)];
                        end
                        if max(part)>total
                              error('prog:input', 'ERPLAB says: Specified part value is larger than the specified total value!.')
                        end
                        nevent   = length(ALLEEG(dataset(h)).EVENTLIST.eventinfo); % total number of original events
                        segevent = round(nevent/total);
                        iteme    = [];
                        for vv=1:length(part)
                              iteme = [iteme ((part(vv)-1)*segevent+1):((part(vv))*segevent)];
                        end
                        okepoch = [];
                        g = 1;
                        for t=1:length(selectedepochs)
                              xitem = cell2mat(ALLEEG(dataset(h)).epoch(selectedepochs(t)).eventitem);
                              if nnz(ismember_bc2(xitem, iteme))>0
                                    okepoch(g) = selectedepochs(t);
                                    g = g + 1;
                              end
                        end
                        selectedepochs = okepoch;
                  end
                  
                  %
                  % NUMBER OF EPOCHS PER BIN  (N FOR AVERAGING)
                  %
                  %nepoch(ibin)
                  
                  if ~isinf(nepoch(ibin))
                        if length(selectedepochs)<nepoch(ibin) % !!!
                              %disp('no alcanza')
                              if strcmpi(warning, 'on')
                                    BackERPLABcolor = [1 0.9 0.3];    % yellow
                                    question = ['There is not such amount of %s %s epochs in your dataset #%g, for bin #%g!\n\n'...
                                          'What would you like to do?'];
                                    title = 'WARNING: criterion was not met';
                                    oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                                    set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                                    button = questdlg(sprintf(question, catching, str4ep, dataset(h), bini(ibin)), title,'Cancel','Continue','Continue');
                                    set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                                    fprintf(question, catching, str4ep, dataset(h), bini(ibin));
                                    
                                    if ~strcmpi(button,'Continue')
                                          wannago = 0; % abort
                                    end
                              end
                        else
                              % Instances
                              if strcmpi(instance, 'first')
                                    selectedepochs = selectedepochs(1:nepoch(ibin));         % first instances
                              elseif strcmpi(instance, 'last')
                                    selectedepochs = selectedepochs(end-nepoch(ibin)+1:end); % last instances
                              else
                                    nsel = length(selectedepochs);
                                    nselrindx = randperm(nsel);
                                    selectedepochs = sort(selectedepochs(nselrindx(1:nepoch(ibin)))); %  random and sorted again...
                              end
                        end
                  else
                        if strcmpi(instance, 'first') || strcmpi(instance, 'last')
                              BackERPLABcolor = [1 0.9 0.3];    % yellow
                              question = ['There is a problem with the input parameters.\n'...
                                    'This is,\n'...
                                    'If the "' instance '" instances are required then a finite amount of them must be specified.'];
                              title = 'WARNING: logical flaw';
                              oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                              set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                              button = questdlg(sprintf(question, catching, str4ep, dataset(h), bini(ibin)), title,'Cancel','Continue','Continue');
                              set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                              fprintf(question, catching, str4ep, dataset(h), bini(ibin));
                              
                              if ~strcmpi(button,'Continue')
                                    wannago = 0; % abort
                              end
                        end
                  end
                  if wannago==0
                        break % abort
                  else
                        %selectedepochs
                        Tempeindices = [Tempeindices selectedepochs];
                  end
            end
      end
      % is everythig going well?
      if wannago==0 % no
            break
      else % yes
            Tempeindices = sort(Tempeindices);
            eindices{h,:}  = Tempeindices; % rows are datasets
      end
end
if wannago==0
      % abort
      eindices = [];
      return
end
