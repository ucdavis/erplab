% Usage
%
% >> EEG = pop_lindetrend( EEG, interval)
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

function [EEG, com] = pop_eeglindetrend( EEG, interval)

com = '';

if nargin < 1
      help pop_lindetrend
      return
end

if isempty(EEG.data)
      msgboxText =  'pop_lindetrend() cannot read an empty dataset!';
      title = 'ERPLAB: pop_lindetrend error';
      errorfound(msgboxText, title);
      return
end

if isempty(EEG.epoch)
      msgboxText =  'pop_lindetrend has been tested for epoched data only';
      title = 'ERPLAB: pop_lindetrend error';
      errorfound(msgboxText, title);
      return
end

%
% Gui is working...
%
if nargin <2
      
      titlegui = 'Linear Detrend';
      answer = blcerpGUI(EEG, titlegui );  % open GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      interval = answer{1};
end

% in case of an error
if ~strcmpi(interval,'all') && ~strcmpi(interval,'pre') && ~strcmpi(interval,'post')
      internum = str2double(interval);
      if length(internum)~=2
            disp('Error:  Linear detrending will not be performed. Check your parameters.')
            return
      end
end

EEG = lindetrend( EEG, interval);
EEG.setname = [EEG.setname '_ld']; % suggested name (si queris no mas!)

com = sprintf( '%s = pop_eeglindetrend( %s, ''%s'' );', inputname(1), inputname(1), interval);
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return


