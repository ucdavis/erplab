% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon and Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2014 & 2022

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function ERP = f_getFFTfromERP(ERP,iswindowed)


if nargin<1
    help f_getFFTfromERP
    return;
end


if nargin<2
    iswindowed =0;
end
fnyqx = round(ERP.srate/2);
NFFT    = 2.^nextpow2(4*fnyqx);
NFFT = NFFT*2;
fs = ERP.srate;
fnyq     = fs/2;
nbin     = ERP.nbin;
nchan    = ERP.nchan;
freq     = fnyq*linspace(0,1,NFFT/2);
data4fft = zeros(nchan, NFFT/2, nbin);

for k=1:nbin
    %  [freq, data4fft(:,:,k)] = getTrialFFT(ERP.bindata(:,:,k), ERP.srate, 2*nfft, iswindowed); % FFT
    datax = ERP.bindata(:,:,k);
    L      = size(datax,2);
    %nchan  = size(datax,1);
    %FFTdata = zeros(nchan, NFFT/2);
    y  = datax';
    if iswindowed
        y  = y.*repmat(hamming(size(y,1)),1,size(y,2)); % data tapered with a Hamming window.
    end
    Y = fft(y,NFFT)'/L;
    fftepo = Y(:,1:NFFT/2); % Complex values
    
    if rem(NFFT, 2) % odd NFFT excludes Nyquist point
        fftepo(:, 2:end) = fftepo(:, 2:end).*2;
    else
        fftepo(:, 2:end-1) = fftepo(:, 2:end-1).*2;
    end
    data4fft(:,:,k) = fftepo;
end
ERP.bindata  = data4fft;
ERP.binerror = [];
%ERP.pnts  = size(ERP.bindata, 2);
ERP.times = freq;
ERP.xmin  = min(ERP.times);
ERP.xmax  = max(ERP.times);
ERP.datatype = 'EFFT';

ERP.pnts  = size(ERP.bindata, 2);