% Usage
%
% >> pop_fourierp(ERP, channel, f1, f2)
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

function erpcom = pop_fourierp(ERP, channel, f1, f2)

erpcom = '';

if nargin < 1
      help pop_fourierp
      return
end

if isempty(ERP.bindata)
      msgboxText = 'cannot work with an empty ERP erpset';
      title      = 'ERPLAB: pop_fourierp() error:';
      errorfound(msgboxText, title);
      return
end

if nargin==1 %with GUI
      
      answer = fourieegGUI(ERP);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      channel = answer{1};
      f1  = answer{2};
      f2  = answer{3};
else
      if nargin<4
            f2 = ERP.srate/2;
      end
      if nargin<3
            f1 = 0;
      end
      if nargin<2
            channel = 1;
      end
end

fourierp(ERP,channel,f1,f2)

erpcom = sprintf( '%s = pop_fourierp( %s, %s, %s, %s);', inputname(1),...
      num2str(channel), num2str(f1), num2str(f2));
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
