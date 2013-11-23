% PURPOSE: tests whether input is a valid ERP structure or not.
%
% FORMAT:
%
% value = iserpstruct(input);
%
% value = 1 means input is a valid ERP structure; 0 otherwise.
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function value = iserpstruct(input)
try
        if ~isstruct(input)
                value = 0;
                return
        end
        
        %
        % Main ERP fields
        %
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
                'ntrials',...
                'isfilt',...
                'chanlocs',...
                'ref',...
                'bindescr',...
                'saved',...
                'history',...
                'version'};
        
        ERPX     = input(:);
        fnam    = fieldnames(ERPX);
        tf = ismember_bc2(ref_field, fnam );
        
        if nnz(tf)== length(ref_field)
                value = 1;
        else
                value = 0;
        end        
catch
        value = 0;
        return
end


