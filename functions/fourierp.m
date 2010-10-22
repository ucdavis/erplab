% fourieeg Single-Sided Amplitude Spectrum of your continuous dataset
%
% [ym f] = fourieeg(ERP,ch,f1,f2) returns the module (magnitude) ym of the FFT output
% of your dataset, evaluated at channel ch, between the frequencies f1 and f2 (in Hz).
% f contains the frequency range.
%
% [ym f] = fourieeg(ERP,ch,f1) returns the module (magnitude) of the FFT output
% of your dataset, evaluated at channel ch, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist).f contains the frequency range.
%
% [ym f] = fourieeg(ERP,ch) returns the module (magnitude) of the FFT output
% of your dataset, evaluated at channel ch, between ~0 hz and fs/2
% (fnyquist). f contains the frequency range.
%
% [ym f] = fourieeg(ERP) returns the module (magnitude) of the FFT output
% of your dataset, evaluated at channel 1, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist). f contains the frequency range.
%
% ym = fourieeg(ERP...) returns only the module (magnitude) of the FFT output
% of your dataset.

% fourieeg(ERP...) plots the Single-Sided Amplitude Spectrum of your continuous
% dataset.
%
%
% See also fft.
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

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

function varargout = fourierp(ERP,ch,f1,f2,np)

if nargin < 1
      help fourierp
      if nargout == 1
            varargout{1} = [];
      elseif nargout == 2
            varargout{1} = [];
            varargout{2} = [];
      else
            return
      end
      return
end

if nargin<5
      np = [];
end

if isempty(ERP.bindata)
      msgboxText{1} =  'fourierp() error: cannot filter an empty erpset';
      title_msg = 'ERPLAB: fourierp():';
      errorfound(msgboxText, title_msg);
      return
end

fs = ERP.srate;
fnyq = fs/2;
L  = ERP.pnts;
nbin = ERP.nbin;

if isempty(np)
      NFFT   = 2^nextpow2(L);
else
      NFFT = 2*np;
end

f = fnyq*linspace(0,1,NFFT/2);

ffterp =zeros(nbin, NFFT/2);


if length(ch)==1 % single channel
      DataWork = ERP.bindata(ch,:,:);
else  %all channel ---> average them
      DataWork = mean(ERP.bindata(ch,:,:),1);
end

for i=1:nbin
      y = detrend(DataWork(1,:,i));
      Y = fft(y,NFFT)/L;
      ffterp(i,:) = 2*abs(Y(1:NFFT/2));
end

avgfft = mean(ffterp,1);

f1sam =round((f1*NFFT/2)/fnyq);
f2sam =round((f2*NFFT/2)/fnyq);

if f1sam<1
      f1sam=1;
end
if f2sam>NFFT/2
      f2sam=NFFT/2;
end

fout = f(f1sam:f2sam);
yout = avgfft(1,f1sam:f2sam);

if nargout ==1
      varargout{1} = yout;
elseif nargout == 2
      varargout{1} = yout;
      varargout{2} = fout;
else
      %
      % Plot single-sided amplitude spectrum.
      %
      msgn = 'all bins';
      fname = ERP.erpname;
      figure('Name',['<< ' fname ' >>  ERPLAB Amplitude Spectrum for ERPs'],...
            'NumberTitle','on', 'Tag','Plotting Spectrum',...
            'Color',[1 1 1]);
      
      plot(fout,yout)
      axis([min(fout)  max(fout)  min(yout)*0.9 max(yout)*1.1])
      
      if isfield(ERP.chanlocs,'labels')
            legend(['ERP Channel: ' ERP.chanlocs(ch).labels ' * ' msgn])
      else
            legend(['ERP Channel: ' num2str(ch) '  * ' msgn])
      end
      
      title('Single-Sided Amplitude Spectrum of y(t)')
      xlabel('Frequency (Hz)')
      ylabel('|Y(f)|')
end
