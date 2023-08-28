% PURPOSE: Loads a current MVPA structure (if any) from the workspace
%        Otherwise, load ALLMVPA(CURRENTMVPA); Otherwise, MVPA = []
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

function MVPA = preloadMVPA
try
        MVPA = evalin('base', 'MVPA');
catch
        MVPA = [];
end
if isempty(MVPA)
        try
                ALLMVPA = evalin('base', 'ALLMVPA');
                k = evalin('base', 'CURRENTMVPA');
                MVPA = ALLMVPA(k);
        catch
                MVPA = [];
        end       
end
