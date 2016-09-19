% resample ERPset
%
% INPUT
% ERP          - input ERPset
% newsrate     - new sample rate
%
% OUTPUT
% ERP          - resampled ERPset
%
%
% Javier L-C

function ERP = erpresample(ERP, newsrate)
datatype = checkdatatype(ERP);
if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end
[N,D] = rat(newsrate/ERP.srate, 0.0001);
nchan = ERP.nchan;
nbin  = ERP.nbin;
pnts  = ERP.pnts;
x1    = 1:pnts;
Da    = pnts*N/D;
Db    = ceil(Da);
endp  = pnts/Da*Db;
x2    = linspace(1,endp,Db);
aafc  = 128*N/D;
% Anti-aliasing filter
fprintf('Applying anti-aliasing filter at %.1fHz...\n', aafc);
ERP = pop_filterp( ERP,  1:ERP.nchan , 'Cutoff',  (newsrate/4), 'Design', 'butter', 'Filter', 'lowpass', 'Order',  4 );
xbindata = zeros(nchan, Db, nbin);
for k=1:nchan
        for m=1:nbin
                data = ERP.bindata(k,:,m);
                pp   = spline( x1, data);
                xbindata(k,:,m) = ppval(pp, x2)';
        end
end
ERP.bindata  = xbindata;
ERP.binerror = [];
ERP.srate    = ERP.srate*N/D;
ERP.erpname  = [ERP.erpname '_resampled'];
ERP.pnts     = size(ERP.bindata,2);
ERP.xmax     = ERP.xmin + (ERP.pnts-1)/ERP.srate; 
ERP.times    = linspace(ERP.xmin*kktime, ERP.xmax*kktime, ERP.pnts);