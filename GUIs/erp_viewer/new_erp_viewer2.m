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

function [] = new_erp_viewer2(ERP)
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
plot_elec_n = 20;
plot_pnts = ERP.pnts;
plot_bin = 2;

S.plot_first_elec = 1;

plot_erp_data = zeros(plot_elec_n,ERP.pnts);

plot_erp_data = ERP.bindata(S.plot_first_elec:S.plot_first_elec+plot_elec_n,1:ERP.pnts,2);


% Add offset to each ERP, for simultaneous display
display_offset = -5;
for i=2:plot_elec_n
    plot_erp_data(i,:) = plot_erp_data(i,:) + (i-1)*display_offset;
end


% Get chan labels
chan_label = cell(1,plot_elec_n);
chan_label_place = zeros(1,plot_elec_n);
for i = 1:plot_elec_n
    chan_label{i} = ERP.chanlocs(S.plot_first_elec-1+i).labels;
    chan_label_place(i) = display_offset*(i-1);
end








plot(axes1,plot_erp_data')


xlabel('Time (ms)');
ylabel(['Amplitude (?V) - Electrodes separated by ',num2str(display_offset),' ?V']);

% Construct simple, readable X marker labels
time_range = ERP.times(end) - ERP.times(1);
time_tick_interval = round(time_range/8);
time_tick_0 = find(ERP.times == min(abs(ERP.times))); % Find the index of the time closest to zero
% XTick on those closest to this, for XTicks needed
time_tick_next = 0;
i = 1;
while time_tick_next >= ERP.times(1)   % Populate times < zero
     times_ticks(i) = time_tick_next;
     times_ticks_place(i) = find(abs(ERP.times - time_tick_next) == min(abs(ERP.times - time_tick_next)));
     time_tick_next = time_tick_next - time_tick_interval;
     i=i+1;
end

time_tick_next = 0 + time_tick_interval;
while time_tick_next <= ERP.times(end)+time_tick_interval/2 % Populate times > zero
     times_ticks(i) = time_tick_next;
     times_ticks_place(i) = find(abs(ERP.times - time_tick_next) == min(abs(ERP.times - time_tick_next)));
     time_tick_next = time_tick_next + time_tick_interval;
     i=i+1;
end
times_ticks = sort(times_ticks);
times_ticks_place = sort(times_ticks_place);

set(gca,'XTickLabel',times_ticks,'XTick',times_ticks_place);


% We have chan_label_place going down the screen, becoming more negative.
% This needs to be 'flipped' for the YTicks to be drawn correctly.
set(gca,'YTickLabel',flip(chan_label),'YTick',flip(chan_label_place));


fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',14,'FontName','HelveticaLTStd-Roman')


% tic
% leg = legend(axes1, chan_label);
% toc

% Configure selection buttons in the right panel
box = uix.VButtonBox( 'Parent', panel );
box_e = uix.HButtonBox( 'Parent', box );
chan_text = uicontrol('Parent', box_e,'style','text', 'fontsize',10,'string','Chan:');
chan_select = uicontrol('Parent', box_e,'style','edit', 'fontsize',14,'string',S.plot_first_elec);
box_e2 = uix.HButtonBox( 'Parent', box );
S.em = uicontrol( 'Parent', box_e2, 'String', '-' );
S.ep = uicontrol( 'Parent', box_e2, 'String', '+' );

set([S.ep,S.em],'call',{@update_call,S}); % Shared Callback
end



%% Deal with updating figure on callbacks

function [] = update_call(h,~,S)


switch h % what triggered the callback?
    
    case S.ep  % electode + button
        S.plot_first_elec = S.plot_first_elec + 1;
        
    case S.em % electode - button
        S.plot_first_elec = S.plot_first_elec - 1;
        
end

end
