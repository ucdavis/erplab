% PURPOSE: Loads a current BEST structure (if any) from the workspace
%        Otherwise, load ALLBEST(CURRENTBEST); Otherwise, BEST = []
%
%        To avoid clearing an already filled BEST structure after an
%        interrupted process (for instance, after error) or canceling
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

function BEST = preloadBEST
try
        BEST = evalin('base', 'BEST');
catch
        BEST = [];
end
if isempty(BEST)
        try
                ALLBEST = evalin('base', 'ALLBEST');
                k = evalin('base', 'CURRENTBEST');
                BEST = ALLBEST(k);
        catch
                BEST = [];
        end       
end
