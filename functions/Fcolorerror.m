% PURPOSE: sets ERPLAB's error windows Foreground Color
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

function Fcolorerror(c)
if nargin<1
        c = uisetcolor([0 0 0],'Error window foreground color') ;
end
erpworkingmemory('errorColorF', c);