% PURPOSE: sets ERPLAB's GUIs' font 
%
% FORMAT:
%
% handles = setfonterplab(handles, fontsize, fontunits);
%
% INPUT
%
% handles      - GUI's handles stucture
% fontsize     - font size
% fontunits    - font units ('pixels', 'points')
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
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

function handles = setfonterplab(handles, fontsize, fontunits)

if nargin<3
        fontunits = [];
end
if nargin<2
        fontsize = [];
end
if isempty(fontsize)
        %
        % GUI's fontsize
        %
        fontsize = erpworkingmemory('fontsizeGUI');
end
if isempty(fontsize)
        fontsize = 8.8;
end
if isempty(fontunits)
        %
        % GUI's fontsize
        %
        fontunits = erpworkingmemory('fontunitsGUI');
end
if isempty(fontunits)
        fontunits = 'points';
end

filedsn = fieldnames(handles);

for j=1:length(filedsn)
        %mstr = regexp(filedsn{j},'^nbin|^edit|^listbox|^EEG|^ERP|togglebutton_summary|^pushbutton|totline|indxline|Plotting_ERP|Scalp|counterchanwin|counterbinwin|text_erpset','match');
        mstr = regexp(filedsn{j},'^EEG|^ERP|totline|Plotting_ERP|Scalp|text_erpset','match');
        if isempty(mstr)
                num = handles.(filedsn{j});                
                if ~iscell(num) && ~isstruct(num)
                        if num~=1
                                try
                                        set(num, 'FontUnits', fontunits)
                                        set(num, 'FontSize' , fontsize)
                                catch
                                        
                                end                               
                        end
                end
        end
end