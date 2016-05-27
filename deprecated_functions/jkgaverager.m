% DEPRECATED
%
%
%
% Author: Javier Lopez-Calderon 
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012
%
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

function [ALLERP erpcom] = pop_jkgaverager(ALLERP, varargin)
erpcom = '';
if nargin<1
      help jkgaverager
      return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');

p.addParamValue('ERPindex', [], @isnumeric);
p.addParamValue('Loadlist', '', @ischar);
p.addParamValue('Criterion', 1, @isnumeric); %  0-100 %
p.addParamValue('Weighted', 'off', @ischar); % 'on', 'off'
p.addParamValue('Stdev', 'off', @ischar);    % 'on', 'off'
p.addParamValue('Warning', 'on', @ischar);   % 'on', 'off'

p.parse(ALLERP, varargin{:});

erpindx  = p.Results.ERPindex;
filelist = p.Results.Loadlist;
artcrite = p.Results.Criterion;
stdsstr  = p.Results.Stdev;
wavgstr  = p.Results.Weighted;

if isempty(erpindx) && ~isempty(filelist)
      try
            fid_list   = fopen( filelist );
            inputfname = textscan(fid_list, '%[^\n]','CommentStyle','#');
            fclose(fid_list);
            
            inputfname    = strtrim(cellstr(inputfname{:}));
            nfile = length(inputfname);
            optioni = 1;
      catch
            error('ERPLAB:jkgaverager', '\nERPLAB says: "%s" couldn''t be loaded', filelist)
      end
elseif  ~isempty(erpindx) && isempty(filelist)
      nfile      = length(erpindx);
      inputfname = '';
      optioni = 0;
elseif  isempty(erpindx) && isempty(filelist)
      error('ERPLAB:jkgaverager', '\nERPLAB says: Both ERPindex and Loadlist are empty')
else
      error('ERPLAB:jkgaverager', '\nERPLAB says: ERPindex and Loadlist were specified. ERPLAB got confused by this...')
end

%
% Reads and sums ERPsets
%
for k=0:nfile
      if optioni==1
            jkindx = erpindx(~ismember_bc2(1:length(erpindx), k));       
            jklist = inputfname(jkindx);
      else
            jkerpindx = erpindx(~ismember_bc2(1:length(erpindx), k));
      end
      
      ERP = pop_gaverager(ALLERP, 'ERPindex', jkerpindx, 'Loadlist', jklist,'Criterion', artcrite,...
            'Stdev', stdsstr, 'Weighted', wavgstr);
      
      try 
                  if k==0 && isempty(ALLERP);
                        ALLERP = buildERPstruct([]);
                        ALLERP = ERP;
                  else
                        ALLERP(k+1+preindex) = ERP;
                  end
      catch
            msgboxText = 'A fatal problem was found while getting the ERPs';
            error('Error:jkgaverager', msgboxText);
      end     
end

% if updatemaingui % update erpset menu at main gui
%       assignin('base','ALLERP',ALLERP);  % save to workspace
%       updatemenuerp(ALLERP); % add a new erpset to the erpset menu
% end




