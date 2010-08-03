% pop_export2text() - export ERP erpset to text
%
% pop_export2text()
%
% Usage:
%   >> ERP = pop_export2text(ERP);   % a window pops up
%   >> ERP = pop_export2text(ERP, filename, 'key', 'val', ... );
%
% Inputs:
%   ERP            - eeglab dataset
%   filename       - file name
%
% Optional inputs:
%
%   'time'         - ['on'|'off'] include time values. Default 'on'.
%   'timeunit'     - [float] time unit rel. to seconds. Default: 1E-3 = msec.
%   'elec'         - ['on'|'off'] include electrodes names or component numbers.
%                    Default 'on'.
%   'transpose'    - ['on'|'off'] 'off'-> electrode data = rows; 'on' -> electrode
%                    data = columns. Default 'off'.
%   'precision'    - [float] number of significant digits in output. Default 4.
%
% Outputs:
%        text file
%
% Note: tabulation are used as a delimiter.
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

function erpcom = pop_export2text(ERP, filename, binArray, varargin)

erpcom = '';

if nargin < 1
      help pop_export2text;
      return;
end;

if isempty(ERP)
      msgboxText{1} =  'pop_export2text cannot export an empty ERP dataset';
      title = 'ERPLAB: pop_export2text() error:';
      errorfound(msgboxText, title);
      return
end

if ~isfield(ERP, 'bindata')
      msgboxText{1} =  'pop_export2text cannot export an empty ERP dataset';
      title = 'ERPLAB: pop_export2text() error:';
      errorfound(msgboxText, title);
      return
end

if isempty(ERP.bindata)
      msgboxText{1} =  'pop_export2text cannot export an empty ERP dataset';
      title = 'ERPLAB: pop_export2text() error:';
      errorfound(msgboxText, title);
      return
end

if nargin < 3
      
      answer = export2textGUI(ERP); %open GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      istime    = answer{1};
      tunit     = answer{2};
      islabeled = answer{3};
      transpa   = answer{4};
      prec      = answer{5};
      binArray  = answer{6};
      filename  = answer{7};
      
      if istime
            time = 'on';
      else
            time = 'off';
      end
      
      if islabeled
            elabel = 'on';
      else
            elabel = 'off';
      end
      if transpa
            tra = 'on';
      else
            tra = 'off';
      end
      
      erpcom = pop_export2text(ERP, filename, binArray, 'time', time, 'timeunit', tunit, 'elec', elabel,...
            'transpose', tra, 'precision', prec);
      return
end;

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP', @isstruct);
p.addRequired('filename', @ischar);
p.addRequired('binArray', @isnumeric);
p.addParamValue('time', 'on', @ischar);
p.addParamValue('timeunit', 1E-3, @isnumeric); % milliseconds by default
p.addParamValue('elec', 'on', @ischar);
p.addParamValue('transpose', 'on', @ischar);
p.addParamValue('precision', 4, @isnumeric);
p.parse(ERP, filename, binArray, varargin{:});

nbin = length(binArray);

[pathstr, prefname1, ext, versn] = fileparts(filename);

if strcmp(ext,'')
      ext = '.txt';
end

prefname2 = fullfile(pathstr, prefname1);

for ibin=1:nbin
      
      %
      % ERP data
      %
      data = ERP.bindata(:,:,binArray(ibin));
      
      %
      % add time axis
      %
      if strcmpi(p.Results.time, 'on');
            
            fprintf('bin #%g\n', ibin);
            time_val = linspace(ERP.xmin, ERP.xmax, ERP.pnts)/p.Results.timeunit;
            auxdata  = zeros(size(data,1) + 1, size(data,2));
            auxdata(1,:)     = time_val;
            auxdata(2:end,:) = data;
            data = auxdata; clear auxdata;
      end
      
      %
      % transpose and write to disk
      %
      binfilename = [ prefname2 '_' ERP.bindescr{binArray(ibin)} ext ]; % ...and add ext
      fid = fopen(binfilename, 'w');
      
      if strcmpi(p.Results.transpose, 'off')
            
            %
            % writing electrodes
            %
            strprintf = '';
            for index = 1:size(data,1)
                  
                  if strcmpi(p.Results.time, 'on')
                        tmpind = index-1;
                  else
                        tmpind = index;
                  end
                  
                  if strcmpi(p.Results.elec, 'on')
                        
                        if tmpind > 0
                              if ~isempty(ERP.chanlocs)
                                    fprintf(fid, '%s\t', ERP.chanlocs(tmpind).labels);
                              else
                                    fprintf(fid, '%d\t', tmpind);
                              end
                        else
                              fprintf(fid, ' \t');
                        end
                  end
                  strprintf = [ strprintf '%.' num2str(p.Results.precision) 'f\t' ];
            end
            
            strprintf(end) = 'n';
            
            if strcmpi(p.Results.elec, 'on')
                  fprintf(fid, '\n');
            end
            fprintf(fid, strprintf, data);
      else
            
            %
            % writing electrodes
            %
            for index = 1:size(data,1)
                  
                  if strcmpi(p.Results.time, 'on')
                        tmpind = index-1;
                  else
                        tmpind = index;
                  end
                  if strcmpi(p.Results.elec, 'on')
                        if tmpind > 0
                              if ~isempty(ERP.chanlocs)
                                    fprintf(fid,'%s\t', ERP.chanlocs(tmpind).labels);
                              else
                                    fprintf(fid,'%d\t', tmpind);
                              end
                        else
                              fprintf(fid, ' \t');
                        end
                  end
                  fprintf(fid,[ '%.' num2str(p.Results.precision) 'f\t' ], data(index, :));
                  fprintf(fid, '\n');
            end
      end
      
      fclose(fid);
      
      disp(['A new file containing your ERP data was created at <a href="matlab: open(''' binfilename ''')">' binfilename '</a>'])
end

erpcom = sprintf( 'pop_export2text( %s, ''%s'', %s', inputname(1), filename, vect2colon(binArray));

for i=1:length(varargin)
      if ischar(varargin{i})
            erpcom = [erpcom ',''' varargin{i} ''''];
      else
            erpcom = [erpcom ',' num2str(varargin{i})];
      end
end

erpcom = [erpcom ');'];
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
