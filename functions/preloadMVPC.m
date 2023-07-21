% PURPOSE: Loads a current MVPC structure (if any) from the workspace
%        Otherwise, load ALLMVPC(CURRENTMVPC); Otherwise, MVPC = []
%
%        To avoid clearing an already filled MVPA structure after an
%        interrupted process (for instance, after error) or canceling
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

function MVPC = preloadMVPC
try
        MVPC = evalin('base', 'MVPC');
catch
        MVPC = [];
end
if isempty(MVPC)
        try
                ALLMVPC = evalin('base', 'ALLMVPC');
                k = evalin('base', 'CURRENTMVPC');
                MVPC = ALLMVPC(k);
        catch
                MVPC = [];
        end       
end
