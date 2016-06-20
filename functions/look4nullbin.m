% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function c = look4nullbin(ERP)

nbin  = ERP.nbin;
nchan = ERP.nchan;
a  = sum(ERP.bindata, 2);
b  = reshape(a,1,nchan*nbin);
c  = find(ismember_bc2(b,0));
if isempty(c)
        c=0;
else
        c = unique_bc2(floor((c-1)/nchan)+1);
end