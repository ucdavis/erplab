% PURPOSE: subroutine for ploterpGUI.m
%          Creates default Y ticks for ERPLAB's plotting GUI
%
% FORMAT
%
%  [def miny maxy] = default_amp_ticks(ERP, yrange)
%
% INPUTS
%
% ERP       - ERPset
% yrange    - min and max ERP amplitudes
%
% OUTPUT
%
% def       - tick values to show in Y axis
% miny      - minimum ERP amplitude (to be used for auto-Y)
% maxy      - maximum ERP amplitude (to be used for auto-Y)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012
%
% Rewritten by JLC. Nov 10th, 2013
%
function [def, miny, maxy] = default_amp_ticks(ERP, binArray, yrange)
def   = {'-1 1'};
if nargin<3
        yrange = [];
end
if nargin<2
        binArray = 1:ERP.nbin;
end
nbin = length(binArray);
ymin = zeros(1,nbin);
ymax = ymin;
minpnts = 40; % minimum amuount of values for selecting ticks.
for k=1:nbin
        ymin(k) = min(min(ERP.bindata(:,:,binArray(k))'));
        ymax(k) = max(max(ERP.bindata(:,:,binArray(k))'));
end
miny = min(ymin);
maxy = max(ymax);
if isempty(miny) || isempty(maxy)
        miny  = 0;
        maxy  = 0;
        return
end
if isempty(yrange)
        yrange(1) = miny*1.2;
        yrange(2) = maxy*1.1;
end
if sum(sign(yrange))==0 % when yscale goes from - to +
        yrmax = max(abs(yrange));
        yarray = -round(yrmax):0.1:round(yrmax);
        if length(yarray)<40
                yarray = linspace(-yrmax, yrmax, minpnts);
        end
else % when yscale goes from - to - or + to +
        yarray = round(yrange(1)):0.1:round(yrange(2));
        if length(yarray)<40
                yarray = linspace(yrange(1), yrange(2), minpnts);
        end
end
a1 = yarray(yarray>0);
b1 = closest(a1, [ min(a1)+(max(a1)-min(a1))*0.25 min(a1)+(max(a1)-min(a1))*0.5 min(a1)+(max(a1)-min(a1))*0.75 max(a1)]);
a2 = yarray(yarray<0);
if ~isempty(a2) && ~isempty(b1)
        b2 = -1*fliplr(b1);
elseif ~isempty(a2) && isempty(b1)
        b2 = closest(a2, [ min(a2) min(a2)+(max(a2)-min(a2))*0.25 min(a2)+(max(a2)-min(a2))*0.5 min(a2)+(max(a2)-min(a2))*0.75]);
        b1 = -1*fliplr(b2);
else
        b2 = [];
end
def = {vect2colon([b2 0 b1],'Delimiter','off')};