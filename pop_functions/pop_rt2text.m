% Usage
%
% >> pop_rt2text(EEG, fname)
%
% Input
%
% EEG         -  EEG structure. It must contain the EVENTLIST structure already filled, plus the reaction
%                time info at rt fields. For instance:
%
% >> EEG.EVENTLIST.bdf(1)
%
% ans =
%      expression: '.{22;11}{9:rt<"Red_Resp">}{21:rt<"Blue_Resp">}'
%     description: 'Test 1'
%         prehome: []
%          athome: [1x1 struct]
%        posthome: [1x2 struct]
%         namebin: 'BIN 1'
%          rtname: {'Red_Resp'  'Blue_Resp'}
%         rtindex: [1 2]
%              rt: [48x2 single]
%
%
%
% fname          - full name of the exported text file.
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

function [values com] = pop_rt2text(ERPLAB, varargin)

com = '';
values= [];

if nargin<1
      help pop_rt2text
      return
end

% parsing inputs
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERPLAB');
p.addParamValue('filename','', @ischar);
p.addParamValue('header', 'on', @ischar);
p.addParamValue('listformat', 'basic', @ischar);
p.addParamValue('arfilter', 'off', @ischar); % on means filter out RTs with marked flags
p.parse(ERPLAB, varargin{:});

if isempty(ERPLAB)
      msgboxText =  ['Empty data structure.\n'...
            'Please, load a dataset or erpset first...'];
      title     = 'ERPLAB: pop_rt2text()';
      errorfound(sprintf(msgboxText), title);
      return
end
if ~iseegstruct(ERPLAB) && ~iserpstruct(ERPLAB)
      msgboxText =  ['Invalid data structure.\n'...
            'pop_rt2text() only works with EEG and ERP structures.'];
      title     = 'ERPLAB: pop_rt2text()';
      errorfound(sprintf(msgboxText), title);
      return
else
      if iserpstruct(ERPLAB)
            iserp=1;
            dtype = 'erpset';
            varin = 'ERP';            
      else
            iserp=0;
            dtype = 'dataset';
            varin = 'EEG';
      end
end
if isfield(ERPLAB, 'EVENTLIST')     
      if isempty(ERPLAB.EVENTLIST)
            msgboxText =  'EVENTLIST structure is empty!';
            title      = 'ERPLAB: pop_rt2text()';
            errorfound(msgboxText, title);
            return
      end      
      if isfield(ERPLAB.EVENTLIST, 'bdf')
            if isempty(ERPLAB.EVENTLIST.bdf)
                  
                  if iserp
                        msgboxText =  'This erpset has an empty EVENTLIST.bdf structure...';
                  else
                        msgboxText =  'BINLISTER has not been performed yet!';
                  end
                  
                  title     = 'ERPLAB: pop_rt2text()';
                  errorfound(msgboxText, title);
                  return
            end
            if ~isfield(ERPLAB.EVENTLIST.bdf, 'rt')
                  msgboxText =  'There is not reaction time info in this %s!';
                  title     = 'ERPLAB: pop_rt2text()';
                  errorfound(sprintf(msgboxText, dtype), title);
                  return
            else
                  valid_rt = nnz(~cellfun(@isempty,{ERPLAB.EVENTLIST.bdf.rt}));
                  
                  if valid_rt==0
                        msgboxText =  'There is not reaction time info in this %s!';
                        title     = 'ERPLAB: pop_rt2text()';
                        errorfound(sprintf(msgboxText, dtype), title);
                        return
                  end
            end
      else
            msgboxText =  'BINLISTER has not been performed yet!';
            title     = 'ERPLAB: pop_rt2text()';
            errorfound(msgboxText, title);
            return
      end
else
      if iserp
            msgboxText =  'This erpset has not attached an EVENTLIST structure .';
      else
            msgboxText =  'EVENTLIST structure has not been created yet!';
      end
      
      title     = 'ERPLAB: pop_rt2text()';
      errorfound(msgboxText, title);
      return
end
if nargin==1
      
      def  = erpworkingmemory('pop_rt2text');
      
      if isempty(def)
            def = {'' 'basic' 'on' 'off'};
      end
      
      param  = saveRTGUI(def);
      
      if isempty(param)
            disp('User selected Cancel')
            return
      end
      
      filenamei = param{1};
      listformat    = param{2};
      header    = param{3};  % 1 means include header (name of variables)
      arfilt    = param{4};  % 1 means filter out RTs with marked flags
      
      [pathx, filename, ext, verx] = fileparts(filenamei);
      
      if ~strcmpi(ext,'.txt') && ~strcmpi(ext,'.xls')  && ~strcmpi(ext,'.dat')
            ext = '.txt';
      end
      
      filename = [filename ext];
      filename = fullfile(pathx, filename);
      
      if header==1
            headstr = 'on';
      else
            headstr = 'off';
      end
      if arfilt==1
            arfilter = 'on';
      else
            arfilter = 'off';
      end
      
      erpworkingmemory('pop_rt2text', {filename, listformat, headstr, arfilter});      
      [values com] = pop_rt2text(ERPLAB, 'filename', filename, 'listformat', listformat, 'header', headstr, 'arfilter', arfilter);
      return
else
      filename = p.Results.filename;
      listformat   = p.Results.listformat;
      header   = p.Results.header;
      arfilter = p.Results.arfilter;
      
      if isempty(filename)
            error('ERPLAB says: Output filename is missing!.')
      end
      
      [pathstr, filenamei, ext, versn] = fileparts(filename);
      
      if ~strcmpi(ext,'.txt') && ~strcmpi(ext,'.xls') && ~strcmpi(ext,'.dat')
            ext = '.txt';
      end
      
      filename = [filenamei ext];
      filename    = fullfile(pathstr, filename);
      
      if strcmpi(arfilter,'on')
            eliminAR = 1;
      else
            eliminAR = 0;
      end
end

nbin    = ERPLAB.EVENTLIST.nbin;
ndig    = 3; % decimal places
ndigstr = num2str(ndig);

if strcmp(listformat,'basic')   %%%%%%%%%% BASIC FORMAT %%%%%%%%%%%
                                %%%%%%%%%%              %%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
      k      = 1;
      values = cell(1);
      label  = cell(1);
      
      for i=1:nbin            
            for j=1:length(ERPLAB.EVENTLIST.bdf(i).rtname)   
                    
                  rtnamex = ERPLAB.EVENTLIST.bdf(i).rtname{j};     
                  
                  if ~isempty(rtnamex)
                        
                        label{k} = strrep(rtnamex, ' ', '_');
                        
                        if isempty([ERPLAB.EVENTLIST.bdf(i).rt])
                              [values{1,k}] = [];
                        else
                              vrt   = ERPLAB.EVENTLIST.bdf(i).rt(:,j);
                              if eliminAR  % eliminates RTs with Artifact Rejection (detection) marks.
                                    flgrt = ERPLAB.EVENTLIST.bdf(i).rthomeflag(:,j);
                                    vrt(flgrt>0) = [];
                              end
                              valrt = num2cell(vrt);
                              [values{1:length(vrt),k}] = valrt{:};
                        end
                        k = k + 1;
                  end
            end
      end
      
      %
      % Empty values will be NaN
      %
      aa = find(cellfun(@isempty, values));
      [values{aa}] = deal(NaN);
      
      if strcmp(ext,'.xls')
            xlswrite(filename, [label; values]);
      else
            CC      = cell2mat(values);
            fid_rt  = fopen(filename, 'w');
            fseek(fid_rt, 0, 'eof');
            
            %
            % Include Header?
            %
            if strcmp(header,'on')
                  fprintf(fid_rt, [repmat('%s\t', 1,length(label)) '\n'] , label{:});
            end
            
            %
            % Print values
            %
            fprintf(fid_rt, [repmat(['%15.' ndigstr 'f\t'], 1,size(values,2)) '\n'] ,CC');
            fclose(fid_rt);
      end
else        %%%%%%%%%% DETAILED FORMAT (ITEMIZED)%%%%%%%%%%%
            %%%%%%%%%%                           %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      k         = 1;
      values    = [];
      lenbinlab = [];
      binlabelarray  = cell(1);
      
      for i=1:nbin
            for j=1:length(ERPLAB.EVENTLIST.bdf(i).rtname)
                  
                  rtnamex = ERPLAB.EVENTLIST.bdf(i).rtname{j};
                  
                  if ~isempty(rtnamex)
                        
                        if ~isempty([ERPLAB.EVENTLIST.bdf(i).rt])
                              
                              vrt  = ERPLAB.EVENTLIST.bdf(i).rt(:,j); % RTs
                              
                              if eliminAR  % changes to NaN RTs with Artifact Rejection (detection) marks.
                                    flgrt = ERPLAB.EVENTLIST.bdf(i).rthomeflag(:,j);
                                    vrt(flgrt>0) = NaN;
                              end
                              
                              irt  = ERPLAB.EVENTLIST.bdf(i).rtitem(:,j);      % item
                              hrt  = ERPLAB.EVENTLIST.bdf(i).rthomecode(:,j);  % home code
                              crt  = ERPLAB.EVENTLIST.bdf(i).rtcode(:,j);      % evaluated event code (about RT)
                              brt  = ERPLAB.EVENTLIST.bdf(i).rtbini(:,j);      % bin index
                              
                              istart = size(values, 1) + 1;
                              istop  = length(vrt) + istart - 1;
                              
                              values(istart:istop, 1) = irt;  % item
                              values(istart:istop, 2) = vrt;  % RT value
                              values(istart:istop, 3) = hrt;  % home code
                              values(istart:istop, 4) = crt;  % evaluated event code
                              values(istart:istop, 5) = brt;  % bin index
                              
                              [binlabelarray{istart:istop}] = deal(strrep(rtnamex, ' ', '_'));
                              lenbinlab(k) = length(rtnamex);
                              k = k+1;
                        end
                  end
                  
                  disp('stop')
            end
      end
      
      if eliminAR  % deletes RTs with Artifact Rejection (detection) marks.
              idxnan = find(isnan(values(:,2)));
              binlabelarray(idxnan)=[];
              values(idxnan,:)=[];
      end
      
      % Sort "values" matrix according to the item value (column #1)
      [vaux,IX] = sort(values(:,1));
      values    = values(IX,:);
      binlabelarray = binlabelarray(IX);
      values    =  num2cell(values);
      FULLTABLE = [values binlabelarray'];
      %label = {'Item' 'RTime' 'Ecode' 'Bin#' 'BinLab'};
      label = {'Item' 'RTime' 'HomeCode' 'EvalCode' 'Bin#' 'BinLab'};
      % Item RTime HomeCode RespCode Bin# BinLab
      
      if strcmp(ext,'.xls')
            xlswrite(filename, [label; FULLTABLE]);
      else
            fid_rt  = fopen(filename, 'w');
            fseek(fid_rt, 0, 'eof');
            %ndig = 3;
            maxitem = num2str(length(num2str(max([values{:,1}]))));
            maxRT   = num2str(length(num2str(round(max([values{:,2}]))))+ ndig + 1);
            maxhc   = num2str(length(num2str(max([values{:,3}])))+1);
            maxec   = num2str(length(num2str(max([values{:,4}])))+1);
            maxbini = num2str(length(num2str(max([values{:,5}])))+1);
            maxblab = num2str(max(lenbinlab)+1);
            
            %
            % Include Header?
            %
            if strcmp(header,'on')
                  fprintf(fid_rt, [repmat('%s\t', 1,length(label)) '\n'] , label{:});
            end
            
            %
            % Print values
            %
            for i=1:length(binlabelarray)
                  fprintf(fid_rt, ['%' maxitem 'g\t%' maxRT '.' ndigstr 'f\t%' maxhc 'g\t%' maxec 'g\t%' ...
                        maxbini 'g\t%' maxblab 's\n'] ,values{i,:}, binlabelarray{i});
            end            
            fclose(fid_rt);
      end
end

disp(['A new file containing Reaction Times data was created at <a href="matlab: open(''' filename ''')">' filename '</a>'])
fn  = fieldnames(p.Results);   
com = sprintf( 'values = pop_rt2text(%s', varin);
skipfields = {'ERPLAB'};

for q=1:length(fn)
      fn2com = fn{q};
      if ~ismember(fn2com, skipfields)
            
            fn2res = p.Results.(fn2com);
            
            if ~isempty(fn2res)
                  if ischar(fn2res)
                        if ~strcmpi(fn2res,'off')
                              com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                        end
                  else
                        com = sprintf( '%s, ''%s'', %s', com, fn2com, vect2colon(fn2res,'Repeat','on'));
                  end
            end
      end
end

com = sprintf( '%s );', com);
try cprintf([0 0 1], 'COMPLETE\n\n');catch fprintf('COMPLETE\n\n');end ;
return