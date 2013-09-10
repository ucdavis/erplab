% PURPOSE: sets ERPLAB Foreground Color
%
% FORMAT
%
% Fcolorerplab(c)
%
% INPUT
%
% c      - color. e.g. [0 1 0] -> green
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

function Fcolorerplab(c)
if nargin<1
        c = uisetcolor([0.83 0.82 0.79],'ERPLAB Foreground Color') ;
end
erpworkingmemory('ColorF', c);