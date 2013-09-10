% UNDER CONSTRUCTION
%
%
%
% Workaround that updates the ERP.history or EEG.history field adding the last used command from scripting.
% 
% USAGE:
%
% ERP = updatehistory(ERP);
% EEG = updatehistory(EEG);
%
%
% Example:
% 
% ERP = pop_binoperator( ERP, {'b3 = (b1+b2)/2 label attended left' });                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
% ERP = updatehistory(ERP);
% 
% >>ERP.history
% 
% ans =
% 
% ERP = erp_loaderp({ 'a1.erp' }, '/Users/javlopez/Desktop/Tutorial/S1/');  
% ERP = pop_binoperator( ERP, {'b3 = (b1+b2)/2 label attended left' });        
%
%
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

function ERPLAB = updatehistory(ERPLAB)
if nargin<1
      help updatehistory
end

if ~iserpstruct(ERPLAB) && ~iseegstruct(ERPLAB)
      error('ERPLAB says: updatehistory() only works with valid ERP or EEG structures.')
end

if isempty(ERPLAB.history)
      history ={};
else
      history = cellstr(ERPLAB.history)';
end

ERPLAB.history = [];
lastcom = getlastcommand;
datecom = datestr(now);
history = [history {[lastcom '% added by updatehistory() on ' datecom]}]';
ERPLAB.history = char(history);
