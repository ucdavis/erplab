% ERP = preloadERP
%
% Load the current ERP structure (if any) from de the workspace.
% Otherwise, ERP = [];
% Purpose:
% To avoid to clear an already filled ERP structure after an interrupted
% process (for instance, after an error)
%
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