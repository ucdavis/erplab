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

function [ERP erpcom] = pop_diffcontraipsi(ERP, chanArray, defcontra, binArray)

erpcom = '';

if nargin < 1
      help pop_diffcontraipsi
      return
end

if exist('ERP','var')
      
      if isempty(ERP) %(ERP.bindata)
            msgboxText{1} =  'cannot work with an empty ERP dataset';
            title = 'ERPLAB: pop_diffcontraipsi() error:';
            errorfound(msgboxText, title);
            return
      end
      
else
      msgboxText{1} =  'cannot find an ERP structure in your workspace.';
      title = 'ERPLAB: pop_diffcontraipsi() cancelled:';
      errorfound(msgboxText, title)
      return
end

%
% Gui is working...
%
nvar = 4;
if nargin<nvar
      
      prompt = {'Bins at work', 'Set CONTRA side per each bin', 'Channel(s) (even amount)'};
      dlg_title = 'Inputs for contra-ipsi substractions';
      num_lines = 1;
      
      def = {['1' ':' num2str(ERP.nbin)], repmat('R ', 1, ERP.nbin) ,['1:' num2str(ERP.nchan)]};
      answer = inputvalue(prompt,dlg_title,num_lines,def);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      binArray   =  str2num(answer{1});
      defcontra  =  regexp(answer{2},'[LR]+', 'match');
      chanArray  =  unique(str2num(answer{3}));
      
elseif nargin==nvar
      
      if ~iscell(defcontra)
            error('ERPLAB says: You have to define contra-side using a cell array of strings: Example: {''''R'''' ''''L'''' ''''R''''}''''');
      end
      
      chanArray  = unique(chanArray); % avoids repeated channels
else
      disp('Error says: pop_diffcontraipsi() works with 4 arguments')
      return
end

if length(chanArray)>ERP.nchan
      error('Error says: pop_diffcontraipsi() You don''''t have so many channels!')
end


if length(binArray)>ERP.nbin
      error('Error says: pop_diffcontraipsi() You don''''t have so many bins!')
end

binArraystr = vect2colon(binArray);
chArraystr  = vect2colon(chanArray);

ERP = diffcontraipsi(ERP, chanArray, defcontra, binArray);

[ERP issave]= pop_savemyerp(ERP,'gui','erplab');

if issave
      erpcom = sprintf( 'pop_diffcontraipsi( %s, %s, ', inputname(1), chArraystr);
      erpcom = [erpcom '{'];
      
      for i=1:length(defcontra)
            erpcom = [erpcom '''' defcontra{i} '''' ' ']; %#ok<AGROW>
      end
      erpcom = sprintf( '%s}, %s );', erpcom, binArraystr);
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      return
else
      disp('Warning: Your ERP structure has not yet been saved')
      disp('user canceled')
      return
end
