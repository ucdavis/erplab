% PURPOSE  : sets background and foreground color of the current ERPLAB's GUI
% Updated for APP designer
%
% FORMAT   :
%
% handles = painterplab(handles, type);
%
% handles  - GUI's handles structure
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

function painterplabapp(app, type)
if nargin<2
        type = 0;
end
if type==0
        %
        % Color GUI
        %
        ColorB = erpworkingmemory('ColorB');
        ColorF = erpworkingmemory('ColorF');
elseif type==1
        ColorB = [1 0.9 0.3];
        ColorF = [0 0 0];
end
if isempty(ColorB)
        ColorB = [0.7020 0.7647 0.8392];
        %ColorB = [0.83 0.82 0.79];
end
if isempty(ColorF)
        ColorF = [0 0 0];
end
ColorB2 = [0.6020 0.6647 0.7392];
filedsn = fieldnames(app);

% GUI's objects' color background
for kk=1:length(filedsn)
    mstr = regexpi(filedsn{kk},'^figure|^axes1|^nbin|^edit|^listbox|^EEG|^ERP|togglebutton_summary|^pushbutton|totline|indxline|ERP_figure|Scalp_figure|counterchanwin|counterbinwin|Label_BG1|Label_BG2','match');
    if isempty(mstr)
        try
            num = app.(filedsn{kk});
            numType = num.Type;
            if (~strcmpi(numType,'uinumericeditfield') && ~strcmpi(numType,'uieditfield') && ~strcmpi(numType,'uibutton') && ~strcmpi(numType,'uitable'))
                if ~iscell(num) && ~isstruct(num)
                    if num~=1
                        try
                            set(num, 'BackgroundColor', ColorB2)
                        catch
                        end
                        
                        try
                            set(num,'HighlightColor',[1 1 1])
                        catch
                        end
                        
                        
                        try
                            set(num, 'ForegroundColor', ColorF)
                        catch
                            
                        end
                    end
                end
            end
        catch
        end
        
    end
end

% GUI's color background
try
        set(app.UIFigure, 'Color', ColorB)
        %disp('Mira:')
        %num
        %filedsn{kk}
catch
end