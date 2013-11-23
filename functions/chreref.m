% PURPOSE: re-references channels
%
% FORMAT:
%
% [ERPLAB cherror] = chreref(ERPLAB, formula, excludechan)
% However syntax is chreref(formula, excludechan) in pop_eegchanoperator/pop_erpchanoperator.
%
% INPUT:
%
% ERPLAB          - dataset or erpset
% formula         - algebraic expression for the (virtual) reference channel
% excludechan     - channel(s) to be excluded
%
%
% OUTPUT
%
% ERPLAB          - re-referenced dataset or erpset
% cherror         - error checking. 0 means no error; 1 means error found
%
%
% EXAMPLE (in channel operations) re-reference channels 1:31, out of 40, to averaged mastoids (33,34)
%
% EEG = pop_eegchanoperator( EEG, {'chreref(''0.5*ch33 + 0.5*ch34'', 33:40)'')'});
% ERP = pop_erpchanoperator( ERP, {'chreref(''0.5*ch33 + 0.5*ch34'', 33:40)'')'});
%
%
% See also re-reference assistant at channel operations GUI
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon and Steven Luck
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

function  [ERPLAB cherror] = chreref(ERPLAB, formula, excludechan)
cherror = 0;
if nargin<1
        help chreref
        return
end
if nargin<3
       excludechan = [];
end
if ~iserpstruct(ERPLAB) && ~iseegstruct(ERPLAB)
        error('ERPLAB says: chreref() only works with ERP and EEG structure.')
end
if iseegstruct(ERPLAB)  % EEG
      ntrial    = ERPLAB.trials;
      nchan     = ERPLAB.nbchan;
      datafield = 'data';
      ERPLABaux = [];
      ntrial    = ERPLAB.trials;
else  % ERP
      ntrial    = ERPLAB.nbin;
      nchan     = ERPLAB.nchan;
      datafield = 'bindata';
      ERPLABaux = buildERPstruct([]);
      ntrial = ERPLAB.nbin;
end

chanArray = 1:nchan;
chanArray = chanArray(~ismember_bc2(chanArray,excludechan));

if iseegstruct(ERPLAB)  % EEG
      ERPLABaux = pop_eegchanoperator( ERPLAB, {['nch1=' formula]});
else
      ERPLABaux = pop_erpchanoperator( ERPLAB, {['nch1=' formula]});
end

nchan2ref = length(chanArray);

for i = 1:ntrial
      dataref = ERPLABaux.(datafield)(1,:,i);
      ERPLAB.(datafield)(chanArray,:,i) = ERPLAB.(datafield)(chanArray,:,i) - repmat(dataref, nchan2ref,1);
end