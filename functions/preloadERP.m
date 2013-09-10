% PURPOSE: Loads current ERP structure (if any) from de the workspace.
%          Otherwise, load ALLERP(CURRENTERP); Otherwise ERP = [];
%
%          To avoid clearing an already filled ERP structure after an interrupted
%          process (for instance, after an error)
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function ERP = preloadERP
try
        ERP = evalin('base', 'ERP');
catch
        ERP = [];
end
if isempty(ERP)
        try
                ALLERP = evalin('base', 'ALLERP');
                k = evalin('base', 'CURRENTERP');
                ERP = ALLERP(k);
        catch
                ERP = [];
        end       
end