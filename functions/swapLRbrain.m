% PURPOSE  : swap left and right channel location to create a mirrored scalp map.
%            If you do not specify channel indices for left and right the swapLRbrain.m will use splitbrain2.m to get them.
%
% FORMAT   :
%
% ERP = swapLRbrain(ERP, LH, RH);
%
%
% INPUTS   :
%
% ERP             - input ERPset
% LH              - all left channel indices
% RH              - all right channel indices (same length as LH)
%
%
% OUTPUTS  :
%
% ERP             - input ERPset having mirrored (swapped) channel info
%
%
% See also pop_eegchanoperator.m chanoperGUI.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function ERP = swapLRbrain(ERP, LH, RH)
if nargin<1
        help swapLRbrain
        return
end
if nargin<2
        [LH RH] = splitbrain2(ERP);
end
if nargin ==2 || nargin>3
        error('ERPLAB says: swapLRbrain works either using 1 or 3 input variables. Check the help.')
end
chfields = {'labels', 'theta', 'radius', 'X', 'Y', 'Z', 'sph_theta', 'sph_phi', 'sph_radius', 'type', 'urchan'};
N1= length(LH);
for f=1:length(chfields)
        for k=1:N1
                if isfield(ERP.chanlocs, chfields{f})
                        aux = ERP.chanlocs(LH(k)).(chfields{f});
                        ERP.chanlocs(LH(k)).(chfields{f}) = ERP.chanlocs(RH(k)).(chfields{f});
                        ERP.chanlocs(RH(k)).(chfields{f}) = aux;
                        clear aux
                end
        end
end


