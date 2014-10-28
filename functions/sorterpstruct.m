% PURPOSE:  sorts ERP structure's field
%
% FORMAT
% 
% [ERP serror] = sorterpstruct(ERP);
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

function [ERP, serror] = sorterpstruct(ERP)

serror = 0; % means no error

% if ~iserpstruct(ERP)
%         disp('aqui*****************************')
%         serror =1; % it is not an ERP struct! Future version this will be serror = 2;
% end

ref_field   = { 'erpname',...
        'filename',...
        'filepath',...
        'workfiles',...
        'subject',...
        'nchan',...
        'nbin',...
        'pnts',...
        'srate',...
        'xmin',...
        'xmax',...
        'times',...
        'bindata',...
        'binerror',...
        'datatype',...
        'ntrials',...
        'pexcluded',...
        'isfilt',...
        'chanlocs',...
        'ref',...
        'bindescr',...
        'binindex',...
        'saved',...
        'history',...
        'version',...
        'splinefile'...
        'EVENTLIST'};
try
        dims    = size(ERP);
        ERP     = ERP(:);
        fnam    = fieldnames(ERP);
        [tf,ix] = ismember_bc2(fnam, ref_field );
        [a, b]  = sort(ix);
        f       =  fnam(b);
        v       = struct2cell(ERP);
        ERP     = cell2struct(v(b,:),f,1);
        ERP     = reshape(ERP,dims);
        
        %
        % Build fields if it was missed
        %
        if ~isfield(ERP.ntrials, 'invalid')
                ERP.ntrials.invalid = zeros(1,ERP.nbin);
        end        
        if ~isfield(ERP.ntrials, 'arflags')
                ERP.ntrials.arflags = zeros(ERP.nbin,8);
        end        
catch
        serror = 1;
        return
end


