%Usage
%
%>> ERP = pop_smootherp(ERP, pointSG)
%
%
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

function [ERP erpcom] = pop_smootherp(ERP, pointSG)

erpcom = '';

if nargin < 1
      help pop_smootherp
      return
end

if isempty(ERP)
      msgboxText{1} =  'Error: cannot smooth an empty ERP dataset';
      title = 'ERPLAB: pop_smootherp() error:';
      errorfound(msgboxText, title);
      return
end

if nargin<2  %with GUI
      %
      % GUI for plotting
      %
      prompt = {'number of points (less than 1 -> % ):'};
      dlg_title = 'Input points for smooth ERPs';
      num_lines = 1;
      
      def = {'5'};
      
      [answer] = inputvalue(prompt,dlg_title,num_lines,def);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      %
      % Read values from GUI
      %
      pointSGvalue     = eval(answer{1});
else
      pointSGvalue = pointSG;
end

ERP = savgolerp(ERP, pointSGvalue);
ERP.saved  = 'no';
ERP.isfilt = 1;
% checkERP(ERP);

[ERP issave]= pop_savemyerp(ERP,'gui','erplab');

if issave
      erpcom = sprintf( 'pop_smootherp( %s, %s);', inputname(1), num2str(pointSGvalue));
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end 
      return
else
      disp('Warning: Your ERP structure has not yet been saved')
      disp('user canceled')
      return
end