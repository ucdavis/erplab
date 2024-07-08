% PURPOSE: subroutine for ploterpGUI.m
%          Creates default Y ticks for ERPLAB's plotting GUI
%
% FORMAT
%
%  [def miny maxy] = default_amp_ticks(ALLMVPC, yrange)
%
% INPUTS
%
% ALLMVPC       - ALLMVPCset
% yrange    - min and max ALLMVPC amplitudes
%
% OUTPUT
%
% def       - tick values to show in Y axis
% miny      - minimum ALLMVPC amplitude (to be used for auto-Y)
% maxy      - maximum ALLMVPC amplitude (to be used for auto-Y)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012
%
% Rewritten by GH 2024
%
function [def, miny, maxy] = default_amp_ticks_decode(ALLMVPC, yrange)
def   = {'0 1'};

if nargin<2
    yrange = [];
end

nMVPC = length(ALLMVPC);
ymin = zeros(1,nMVPC);
ymax = ymin;
minpnts = 40; % minimum amuount of values for selecting ticks.
for k=1:nMVPC
    ymin(k) = min(ALLMVPC(k).average_score(:));
    ymax(k) = max(ALLMVPC(k).average_score(:));
end
miny = 0.8*min(ymin(:));
maxy = 1.1*max(ymax(:));
if isempty(miny) || isempty(maxy)
    miny  = 0;
    maxy  = 1;
    return
end
if isempty(yrange)
    yrange(1) = miny;
    yrange(2) = maxy;
end
if numel(unique(yrange))==1 || numel(yrange)==1 || (yrange(1)>=yrange(2))
    yrange = [0 1];
end
yrange = roundn(yrange,-2);
miny = round(miny,2);
maxy = round(maxy,2);
def= default_amp_ticks_viewer(yrange);