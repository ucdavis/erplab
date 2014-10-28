% PURPOSE: subroutine for pop_fourierp.m pop_fourierp.m
%          calculates Single-Sided Power Spectrum of a dataset
%
% FORMAT
%
% varargout = fourierp(ERP, chanArray, f1, f2, np, latwindow)
%
% INPUTS
%
%   ERP          - continuous or epoched dataset
%   chanArray    - channel to be processed
%   f1           - lower frequency limit
%   f2           - upper frequency limit
%   np           - number of points for FFT
%   latwindow    - time window of interest, in msec, for epoched data.
%
%
% OUTPUT:
%
%   captured     - flag. 1 means data has a flatline or blocking behavior.
%
%
% EXAMPLE
%
% [ym f] = fourierp(ERP,chanArray,f1,f2) returns the squared module, ym, of the FFT output
% of your dataset, evaluated at channel chanArray, between the frequencies f1 and f2 (in Hz).
% f contains the frequency range.
%
% [ym f] = fourierp(ERP,chanArray,f1) returns the squared module of the FFT output
% of your dataset, evaluated at channel chanArray, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist).f contains the frequency range.
%
% [ym f] = fourierp(ERP,chanArray) returns the squared module of the FFT output
% of your dataset, evaluated at channel chanArray, between ~0 hz and fs/2
% (fnyquist). f contains the frequency range.
%
% [ym f] = fourierp(ERP) returns the squared module of the FFT output
% of your dataset, evaluated at channel 1, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist). f contains the frequency range.
%
% ym = fourierp(ERP...) returns only the squared module of the FFT output
% of your dataset.
%
% ... = fourierp(ERP,chanArray,f1,f2,np, latwindow).
%
% fourierp(ERP...) plots the Single-Sided Power Spectrum of your
% dataset.
%
%
% See also fft.
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function varargout = fourierp(ERP, chanArray, binArray, f1,f2, np, latwindow, includelege, isdb)
if nargin < 1
        help fourierp
        if nargout == 1
                varargout{1} = [];
        elseif nargout == 2
                varargout{1} = [];
                varargout{2} = [];
        end
        return
end
if nargin<9
        isdb = 0; % 1 means power in dB, 0 means power in uV2...
end
if nargin<8
        includelege = 1; % 1 means include leyend, 0 means do not...
end
if nargin<7
        latwindow = [ERP.xmin ERP.xmax]*1000; % in msec
end
if nargin<6
        np = [];
end
if nargin<5
        f2 = round(ERP.srate/2);
end
if nargin<4
        f1 = 0;
end
if nargin<3
        binArray =1:ERP.nbin;
end
if nargin<2
        chanArray =1:ERP.nchan;
end
if isempty(ERP(1).bindata)
        msgboxText =  'ERPset has no data!';
        title_msg  = 'ERPLAB: fourierp():';
        errorfound(msgboxText, title_msg);
        return
end
if isempty(binArray)
        binArray =1:ERP.nbin;
end
disp('Working...')
fs    = ERP.srate;
fnyq  = fs/2;
nchan = length(chanArray);

indxtimewin = ismember_bc2(ERP.times, ERP.times(ERP.times>=latwindow(1) & ERP.times<=latwindow(2)));
datax  = ERP.bindata(:,indxtimewin,:);
L      = length(datax); %ERP.pnts;
nbin   = length(binArray);
if isempty(np)
        NFFT = 2^nextpow2(L);
else
        NFFT = 2*np;
end
f      = fnyq*linspace(0,1,NFFT/2);
ffterp = zeros(nbin, NFFT/2, nchan);
for k=1:nchan
        for i=1:nbin
                y = detrend(datax(chanArray(k),:,binArray(i)));
                Y = fft(y,NFFT)/L;
                ffterp(i,:,k) = abs(Y(1:NFFT/2)).^2; % power
                if rem(NFFT, 2) % odd NFFT excludes Nyquist point
                        ffterp(i,2:end,k) = ffterp(i,2:end,k)*2;
                else
                        ffterp(i,2:end-1,k) = ffterp(i,2:end-1,k)*2;
                end
                if isdb
                        ffterp(i,:,k) = 10*log10(ffterp(i,:,k)/max(ffterp(i,:,k))); % dB
                end
        end
end
msgn    = 'all bins';
avgfft  = mean(ffterp,1);
avgdim3 = size(avgfft,3);
if avgdim3>1
    avgfft = mean(avgfft,3);
end
f1sam  = round((f1*NFFT/2)/fnyq);
f2sam  = round((f2*NFFT/2)/fnyq);
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
        fname = ERP.erpname;
        h = figure('Name',['<< ' fname ' >>  ERPLAB Amplitude Spectrum'],...
                'NumberTitle','on', 'Tag','Plotting Spectrum',...
                'Color',[1 1 1]);
        plot(fout,yout)
        axis([min(fout)  max(fout)  min(yout)*0.9 max(yout)*1.1])
        
        if includelege
                if isfield(ERP.chanlocs,'labels')
                        lege = sprintf('ERP Channel: ');
                        for i=1:length(chanArray)
                                lege =   sprintf('%s %s', lege, ERP.chanlocs(chanArray(i)).labels);
                        end
                        lege = sprintf('%s *%s', lege, msgn);
                        legend(lege)
                else
                        legend(['ERP Channel: ' num2str(chanArray) '  *' msgn])
                end
        end
        title('Single-Sided Amplitude Spectrum of y(t)')
        xlabel('Frequency (Hz)')
        ylabel('|Y(f)|')
end