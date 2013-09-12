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

function newERP = erp2contraipsi(ERPout, ERP)
newERP = ERP;
if nargin<1
        help swapLRbrain
        return
end

% if nargin<2
%         [LH RH] = splitbrain2(ERP);
% end
% if nargin ==2 || nargin>3
%         error('ERPLAB says: swapLRbrain works either using 1 or 3 input variables. Check the help.')
% end

chfields = {'theta', 'radius', 'X', 'Y', 'Z', 'sph_theta', 'sph_phi', 'sph_radius', 'type', 'urchan'};

newERP.bindata = zeros(ERP.nchan, ERP.pnts, ERPout.nbin);
newERP.nbin    = ERPout.nbin;
newERP.bindescr = ERPout.bindescr;

nch = length(ERPout.chanlocs);

for k=1:nch
        cilabel = ERPout.chanlocs(k).labels;        
        [a, b] = regexp(strtrim(cilabel), '/|&','match','split');
        
        if length(b)==2
                lb1 = strtrim(b{1});
                lb2 = strtrim(b{2});
                indxch1 = find(strncmpi(lb1, {ERP.chanlocs.labels}, length(lb1)),1,'first');
                indxch2 = find(strncmpi(lb2, {ERP.chanlocs.labels}, length(lb2)),1,'first');
                newERP.chanlocs(indxch1).labels = sprintf('%s/%s',lb1, lb2);
                
                newERP.bindata(indxch1,:,:) = ERPout.bindata(k,:,:);
                
                for f=1:length(chfields)
                        if isfield(ERP.chanlocs, chfields{f})
                                newERP.chanlocs(indxch1).(chfields{f}) = ERP.chanlocs(indxch1).(chfields{f});
                        end
                end
                if indxch1~=indxch2
                        newERP.chanlocs(indxch2).labels = sprintf('%s/%s',lb2, lb1);
                        newERP.bindata(indxch2,:) = ERPout.bindata(k,:);
                        for f=1:length(chfields)
                                if isfield(ERP.chanlocs, chfields{f})
                                        newERP.chanlocs(indxch2).(chfields{f}) = ERP.chanlocs(indxch2).(chfields{f});
                                end
                        end
                end
        end
end