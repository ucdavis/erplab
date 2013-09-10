% UNDER CONSTRUCTION
%
% Author: Javier Lopez-Calderon

function [ERP conti] = swapbinlabel(ERP, b1,b2)

conti = 1;

try
        aux = ERP.bindescr{b1};
        ERP.bindescr{b1} = ERP.bindescr{b2};
        ERP.bindescr{b2}= aux;     
catch
        conti = 0;
end
