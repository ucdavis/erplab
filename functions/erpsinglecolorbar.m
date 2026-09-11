

function erpsinglecolorbar(haxes, hcolorbar, nlat)
if isempty(hcolorbar) || ismember_bc2(0, hcolorbar)
        fprintf('erpsinglecolorbar() got an invalid colorbar handle...\n');
        return
end

%
% When single colorbar is requiered (custom scale)
%
cbpos   = get(hcolorbar, 'Position');
cbwidth = cbpos(3); % as created: 2D and 3D bars are not the same width
xpos    = 0.95 - cbwidth; % maps end at 0.95; tick labels use the margin beyond
set(hcolorbar, 'Position', [xpos .11 cbwidth .8150])
set(hcolorbar, 'Visible','on')