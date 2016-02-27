%% New GUI Layout - Simple ERP viewer
%
% Author: Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2016

% ERPLAB Toolbox
%

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

% Reqs:
% - data loaded in valid ERPset
% - GUI Layout Toolbox

%% Demo to explore an ERP Viewer using the new GUI Layout Toolbox

% First, let's start the window
window = figure( 'Name', 'New ERP Viewer', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'NumberTitle', 'off' );

% Set two boxes, split horizontally
hbox = uix.HBoxFlex('Parent', window, 'Spacing', 3);
axes1 = axes( 'Parent', hbox, 'ActivePositionProperty', 'outerposition' );
panel = uix.BoxPanel( 'Parent', hbox, 'Title', 'Options' );
set( hbox, 'Widths', [-3 -1] );  % width proportion scaling

% Get ERP data
plot_elec_n = 3;
plot_pnts = ERP.pnts;
plot_bin = 2;

plot_erp_data = zeros(plot_elec_n,ERP.pnts);

plot_erp_data = ERP.bindata(1:plot_elec_n,1:ERP.pnts,2);


% Add offset to each ERP, for simultaneous display
display_offeset = -5;
for i=2:plot_elec_n
    plot_erp_data(i,:) = plot_erp_data(i,:) + i*display_offeset;
end

plot(axes1,plot_erp_data')


% Configure selection buttons in the right panel
box = uix.VButtonBox( 'Parent', panel );
uicontrol( 'Parent', box, 'String', 'Electrode +' );
uicontrol( 'Parent', box, 'String', 'Electrode -' );

