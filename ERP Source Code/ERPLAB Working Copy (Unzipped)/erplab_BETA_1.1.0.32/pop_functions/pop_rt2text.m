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

function [values com] = pop_rt2text(EEG, varargin)

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
p.addRequired('EEG');
p.addParamValue('filename','', @ischar);
p.addParamValue('header', 'on', @ischar);
p.addParamValue('format', 'basic', @ischar);
p.parse(EEG, varargin{:});

if isfield(EEG, 'EVENTLIST')
      
      if isempty(EEG.EVENTLIST)
            msgboxText =  'ERPLAB: EVENTLIST structure is empty!';
            title     = 'ERPLAB: pop_rt2text()';
            errorfound(msgboxText, title);
            return
      end
      
      if isfield(EEG.EVENTLIST, 'bdf')
            
            if isempty(EEG.EVENTLIST.bdf)
                  msgboxText =  'ERPLAB: BINLISTER has not been performed yet!';
                  title     = 'ERPLAB: pop_rt2text()';
                  errorfound(msgboxText, title);
                  return
            end
            
            if ~isfield(EEG.EVENTLIST.bdf, 'rt')
                  msgboxText =  'ERPLAB: There is not Reaction Time info in this dataset!';
                  title     = 'ERPLAB: pop_rt2text()';
                  errorfound(msgboxText, title);
                  return
            else
                  valid_rt = nnz(~cellfun(@isempty,{EEG.EVENTLIST.bdf.rt}));
                  
                  if valid_rt==0
                        msgboxText =  'ERPLAB: There is not Reaction Time info in this dataset!';
                        title     = 'ERPLAB: pop_rt2text()';
                        errorfound(msgboxText, title);
                        return
                  end
            end
      else
            msgboxText =  'ERPLAB: BINLISTER has not been performed yet!';
            title     = 'ERPLAB: pop_rt2text()';
            errorfound(msgboxText, title);
            return
      end
else
      msgboxText =  'ERPLAB: EVENTLIST structure has not been created yet!';
      title     = 'ERPLAB: pop_rt2text()';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      
      def  = erpworkingmemory('pop_rt2text');
      
      if isempty(def)
            def = {'' 'basic' 'on' };
      end
      
      param     = saveRTGUI(def);
      
      if isempty(param)
            disp('User selected Cancel')
            return
      end
      
      filenamei = param{1};
      format    = param{2};
      header    = param{3};  % 1 means include header (name of variables)
      
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
      
      erpworkingmemory('pop_rt2text', {filename, format, headstr});
      
      [values com] = pop_rt2text(EEG, 'filename', filename, 'format', format, 'header', headstr );
      return
else
      filename = p.Results.filename;
      format   = p.Results.format;
      header   = p.Results.header;
      
      if isempty(filename)
            error('ERPLAB says: Output filename is missing!.')
      end
      
      [pathstr, filenamei, ext, versn] = fileparts(filename);
      
      if ~strcmpi(ext,'.txt') && ~strcmpi(ext,'.xls') && ~strcmpi(ext,'.dat')
            ext = '.txt';
      end
      
      filename = [filenamei ext];
      filename    = fullfile(pathstr, filename);
end

nbin   = EEG.EVENTLIST.nbin;

if strcmp(format,'basic')
      
      k      = 1;
      values = cell(1);
      label  = cell(1);
      
      for i=1:nbin
            for j=1:length(EEG.EVENTLIST.bdf(i).rtname)
                  
                  rtnamex = EEG.EVENTLIST.bdf(i).rtname{j};
                  
                  if ~isempty(rtnamex)
                        label{k} = strrep(rtnamex, ' ', '_');
                        
                        if isempty([EEG.EVENTLIST.bdf(i).rt])
                              [values{1,k}] = [];
                        else
                              vrt  = num2cell(EEG.EVENTLIST.bdf(i).rt(:,j));
                              [values{1:length(vrt),k}] = vrt{:};
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
            fprintf(fid_rt, [repmat('%15.4f\t', 1,size(values,2)) '\n'] ,CC');
            fclose(fid_rt);
      end
else
      k         = 1;
      values    = [];
      lenbinlab = [];
      binlabelarray  = cell(1);
      
      for i=1:nbin
            for j=1:length(EEG.EVENTLIST.bdf(i).rtname)
                  
                  rtnamex = EEG.EVENTLIST.bdf(i).rtname{j};
                  
                  if ~isempty(rtnamex)
                        
                        if isempty([EEG.EVENTLIST.bdf(i).rt])
                              %[values{1,k}] = [];
                              %disp('NADA...')
                        else
                              vrt  = EEG.EVENTLIST.bdf(i).rt(:,j);
                              irt  = EEG.EVENTLIST.bdf(i).rtitem(:,j);
                              crt  = EEG.EVENTLIST.bdf(i).rtcode(:,j);
                              brt  = EEG.EVENTLIST.bdf(i).rtbini(:,j);
                              
                              istart = size(values, 1) + 1;
                              istop  = length(vrt) + istart - 1;
                              
                              values(istart:istop, 1) = irt;  % item
                              values(istart:istop, 2) = vrt;  % RT value
                              values(istart:istop, 3) = crt;  % event code
                              values(istart:istop, 4) = brt;  % bin index
                              [binlabelarray{istart:istop}] = deal(strrep(rtnamex, ' ', '_'));
                              lenbinlab(k) = length(rtnamex);
                              k = k+1;
                        end
                  end
            end
      end
      
      [vaux,IX] = sort(values(:,1));
      values    = values(IX,:);
      binlabelarray = binlabelarray(IX);
      values    =  num2cell(values);
      FULLTABLE = [values binlabelarray'];
      label = {'Item' 'RTime' 'Ecode' 'Bin#' 'BinLab'};
      
      if strcmp(ext,'.xls')
            xlswrite(filename, [label; FULLTABLE]);
      else
            fid_rt  = fopen(filename, 'w');
            fseek(fid_rt, 0, 'eof');
            
            ndig = 3;
            
            maxitem = num2str(length(num2str(max([values{:,1}]))));
            maxRT   = num2str(length(num2str(round(max([values{:,2}]))))+ ndig + 1);
            maxec   = num2str(length(num2str(max([values{:,3}])))+1);
            maxbini = num2str(length(num2str(max([values{:,4}])))+1);
            maxblab = num2str(max(lenbinlab)+1);
            ndigstr = num2str(ndig);
            
            %
            % Include Header?
            %
            if strcmp(header,'on')
                  fprintf(fid_rt, [repmat('%s ', 1,length(label)) '\n'] , label{:});
            end
            
            %
            % Print values
            %
            for i=1:length(binlabelarray)
                  fprintf(fid_rt, ['%' maxitem 'g %' maxRT '.' ndigstr 'f %' maxec 'g %' ...
                        maxbini 'g %' maxblab 's\n'] ,values{i,:}, binlabelarray{i});
            end
            
            fclose(fid_rt);
      end
end

disp(['A new file containing Reaction Times data was created at <a href="matlab: open(''' filename ''')">' filename '</a>'])

fn = fieldnames(p.Results);
com = sprintf( '[values com] = pop_rt2text(%s', inputname(1));
skipfields = {'EEG'};

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
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return