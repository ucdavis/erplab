% ONLY FOR DEBUGGING PURPOSE (Javier)
% 
%

function dispcond(cond,text,storecode, storesign, storetime, storeflag, storewrite)
% Despliega texto en el command window si cond=1
% Pensado para ocupar mensajes durante debbugin.
% Author: Javier
if nargin==2
        if cond
                disp(text)
        end
elseif nargin==7
        if cond
                disp(text)
                storecode %#ok<NOPRT>
                storesign %#ok<NOPRT>
                storetime %#ok<NOPRT>
                storeflag %#ok<NOPRT>
                storewrite %#ok<NOPRT>
        end
else
        return
end