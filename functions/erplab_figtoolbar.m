% PURPOSE: Adds ERPLAB buttons to figure toolbar
%
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

function erplab_figtoolbar(hsig, mtype)

if nargin<2
        mtype= '2d';
end
tagx =  get(hsig, 'Tag');
ht = findall(hsig,'Type','uitoolbar');

% plot ERP waveforms Gui
icon = imread('plot2_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','Open "Plot ERP waveforms" GUI',...
        'Separator','on',...
        'ClickedCallback','[ERP, erpcom] = pop_ploterps(ERP); ERP = erphistory(ERP, [], erpcom, 0);');

% ERP scalp maps Gui
icon = imread('scalp_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','Open "Plot ERP Scalp Maps" GUI',...
        'Separator','on',...
        'ClickedCallback','[ERP, erpcom] = pop_scalplot(ERP); ERP = erphistory(ERP, [], erpcom, 0);');

% Close all ERPLAB figures
icon = imread('close_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','Close all ERPLAB figures',...
        'ClickedCallback','clerpf;');

% Export ERPLAB figures to PDF and others
icon = imread('pdf_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','Export ERPLAB figures to PDF and others',...
        'ClickedCallback',['[ERP, erpcom] = pop_exporterplabfigure(ERP, ''Tag'',{''' tagx '''},''SaveMode'', ''saveascurrent''); ERP = erphistory(ERP, [], erpcom, 0);']);

% pop_exporterplabfigure(ERP, 'Tag', figtag, 'SaveMode', saveasmode, 'Filepath', filepath, 'Format', fileformat, 'Resolution', resolution, 'History', 'gui');
                

% bring EEGLAB GUI to the front
icon = imread('eeglab_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','bring EEGLAB GUI to the front',...
        'ClickedCallback','hheegh = findobj(0, ''tag'', ''EEGLAB''); figure(hheegh)');

% Open "ERP Measurement Tool" GUI
icon = imread('ruler_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','Open "ERP Measurement Tool" GUI ',...
        'ClickedCallback','[ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP); ERP = erphistory(ERP, [], erpcom, 0);');

% Open ERP Viewer
icon = imread('viewer_icongui.png');
hpt = uipushtool(ht,'CData',icon,...
        'TooltipString','Open "ERP Viewer" GUI ',...
        'ClickedCallback','[ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP,[],[],[],''Erpsets'', [],''Viewer'', ''on'');');

% hide unnecessary buttons
a = findall(hsig);
b = findall(a,'ToolTipString','New Figure');
set(b,'Visible','Off')

b = findall(a,'ToolTipString','Open File');
set(b,'Visible','Off')

b = findall(a,'ToolTipString','Link Plot');
set(b,'Visible','Off')

b = findall(a,'ToolTipString','Brush/Select Data');
set(b,'Visible','Off')

b = findall(a,'ToolTipString','Insert Colorbar');
set(b,'Visible','Off')

b = findall(a,'ToolTipString','Insert Legend');
set(b,'Visible','Off')

if strcmpi(mtype, '2d')
        b = findall(a,'ToolTipString','Rotate 3D');
        set(b,'Visible','Off')
end

hToolbar = findall(hsig,'tag','FigureToolBar');

% reorganize erplab figure buttons
oldState = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')
hButtons = get(hToolbar,'Children');
hButtons = circshift(hButtons,-7);
set(hToolbar,'children',hButtons);
set(0,'ShowHiddenHandles',oldState)
