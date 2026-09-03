% PURPOSE: hides the axes interaction toolbar on the given axes.
%
% FORMAT:
%
% erplab_hideaxestoolbar(ax)
%
% INPUT
%
% ax        - axes handle, or array of axes handles
%
%
% From R2025a a collapsed axes toolbar is drawn as a persistent "..." button on
% top of the plot, where earlier releases showed it only while hovering. On a
% multi-panel ERP figure that puts a "..." over every panel. Hiding the toolbar
% leaves ax.Interactions untouched, so scroll zoom, drag pan and data tips all
% still work, and the figure toolbar still offers zoom and pan.
%
% The Expanded property exists only on releases that draw the persistent
% button, so testing for it leaves the hover behaviour of older releases alone.
%
% *** This function is part of ERPLAB Toolbox ***

function erplab_hideaxestoolbar(ax)

for k = 1:numel(ax)
        h = ax(k);
        if ~isgraphics(h) || ~isprop(h,'Toolbar')
                continue
        end
        tb = h.Toolbar;
        if ~isempty(tb) && isprop(tb,'Expanded')
                tb.Visible = 'off';
        end
end
