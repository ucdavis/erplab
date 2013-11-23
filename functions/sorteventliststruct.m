% PURPOSE:  sorts EVENTLIST structure's field
%
% FORMAT
% 
% [EVENTLIST serror] = sorteventliststruct(EVENTLIST);
% 
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

function [EVENTLIST serror] = sorteventliststruct(EVENTLIST)

serror = 0; % means no error
ref_field   = { 'setname',...
        'report',...
        'bdfname',...
        'nbin',...
        'version',...
        'account',...
        'username',...
        'trialsperbin',...
        'elname',...
        'bdf',...
        'eldate',...
        'eventinfo'};
try        
        dims    = size(EVENTLIST);
        EVENTLIST     = EVENTLIST(:);
        fnam    = fieldnames(EVENTLIST);
        [tf,ix] = ismember_bc2(fnam, ref_field );
        [a, b]  = sort(ix);
        f       =  fnam(b);
        v       = struct2cell(EVENTLIST);
        EVENTLIST     = cell2struct(v(b,:),f,1);
        EVENTLIST     = reshape(EVENTLIST,dims);        
catch
        serror = 1;
        return
end




