% PURPOSE  : Smooth ERP data (ERPLAB ERP structure)
%
% FORMAT   :
%
% ERP = pop_smootherp(ERP, npoints, stype);
%
% INPUTS     :
%
%         ERP              - ERP structures (ERPset)
%         npoints          - odd number of points.
%         stype            - 0=Savitzky-Golay smoothing filter
%                            1=moving average filter method
%
%
% OUTPUTS
%
%         ERP              - smoothed ERP data
%
%
% EXAMPLE 1 : Smooth the data using a 11 points Savitzky-Golay smoothing filter.
%
% ERP = pop_smootherp(ERP, 11, 1);
%
% EXAMPLE 2 : Smooth the data using a 7 points moving average filter method.
%
% ERP = pop_smootherp(ERP, 7, 0);
%
% See also smootherp.m smootherp2.m smooth.m sgolayfilt.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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

function [ERP, erpcom] = pop_smootherp(ERP, npoints, stype)
erpcom = '';
if nargin < 1
      help pop_smootherp
      return
end
if isempty(ERP)
      msgboxText =  'Error: cannot smooth an empty ERP dataset';
      title = 'ERPLAB: pop_smootherp() error:';
      errorfound(msgboxText, title);
      return
end
if nargin==1 
        
      %
      % GUI
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
      
      npoints     = eval(answer{1});
      stype       = 0; % moving average filter methods
      
      %
      % Somersault
      %
      [ERP, erpcom] = pop_smootherp(ERP, npoints, stype);
      pause(0.1);
      return
end
if stype==0
        ERP = smootherp(ERP, npoints); % Smooth the data using a moving average filter methods
else
        ERP = smootherp2(ERP, npoints);% Smooth the data using a Savitzky-Golay smoothing filters
end

ERP.saved  = 'no';
ERP.isfilt = 1;

%
% Completion statement
%
msg2end

[ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');

if issave>0
      erpcom = sprintf( 'pop_smootherp( %s, %s, %s);', inputname(1), num2str(npoints), num2str(stype));
      if issave==2
            erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your ERPset was saved on your hard drive.***';
      else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
      end
      fprintf('\n%s\n\n', msgwrng)
else
      disp('Warning: Your ERP structure has not yet been saved')
      disp('user canceled')
end
return