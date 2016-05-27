% PURPOSE: subroutine for pop_fourierp.m pop_fourieeg.m
%          calculates Single-Sided Power Spectrum of a dataset
%
% FORMAT
%
% varargout = fourieeg(ERPLAB, chanArray, f1, f2, np, latwindow)
%
% INPUTS
%
%   ERPLAB          - continuous or epoched dataset
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
% [ym f] = fourieeg(ERPLAB,chanArray,f1,f2) returns the squared module, ym, of the FFT output
% of your dataset, evaluated at channel chanArray, between the frequencies f1 and f2 (in Hz).
% f contains the frequency range.
%
% [ym f] = fourieeg(ERPLAB,chanArray,f1) returns the squared module of the FFT output
% of your dataset, evaluated at channel chanArray, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist).f contains the frequency range.
%
% [ym f] = fourieeg(ERPLAB,chanArray) returns the squared module of the FFT output
% of your dataset, evaluated at channel chanArray, between ~0 hz and fs/2
% (fnyquist). f contains the frequency range.
%
% [ym f] = fourieeg(ERPLAB) returns the squared module of the FFT output
% of your dataset, evaluated at channel 1, between the frequencies f1 (in
% Hz) and fs/2 (fnyquist). f contains the frequency range.
%
% ym = fourieeg(ERPLAB...) returns only the squared module of the FFT output
% of your dataset.
%
% ... = fourieeg(ERPLAB,chanArray,f1,f2,np, latwindow).
%
% fourieeg(ERPLAB...) plots the Single-Sided Power Spectrum of your
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

function ERS = fourierplab(ERPLAB, chanArray, binArray, f1, f2, np, latwindow)

ERS = [];
%yout = [];
%fout = [];
if nargin < 1
        help fourieeg
        return
end
if nargin<7
        latwindow = [ERPLAB.xmin ERPLAB.xmax]*1000; % msec
end
if nargin<6
        np = [];
end
if nargin<5
        f2 = ERPLAB.srate/2;
end
if nargin<4
        f1 = 0;
end
if nargin<3
        binArray = [];
end
if nargin<2
        chanArray = [];
end
if (iseegstruct(ERPLAB) && isempty(ERPLAB(1).data)) || (iserpstruct(ERPLAB) && isempty(ERPLAB(1).bindata))
        msgboxText =  'fourieeg() error: cannot filter an empty dataset';
        title_msg  = 'ERPLAB: fourieeg():';
        errorfound(msgboxText, title_msg);
        return
end
disp('Working...')


if nargin<2
        chanArray = [];
end
ERS = buildERPstruct([]);
fs    = ERPLAB.srate;
fnyq  = fs/2;
if iseegstruct(ERPLAB) && isempty(ERPLAB.epoch)  % continuous data
        if isempty(chanArray)
                chanArray = 1:ERPLAB.nbchan;
        end
        nchan = length(chanArray);
        sizeeg = ERPLAB.pnts;
        L      = fs*5 ;  %5 seconds of signal
        nwindows = round(sizeeg/L);
        if isempty(np)
                NFFT   = 2^nextpow2(L);
        else
                NFFT = 2*np;
        end
        f      = fnyq*linspace(0,1,NFFT/2);
        ffterp = zeros(nwindows, NFFT/2);
        FFTdata = zeros(nchan, NFFT/2,1);
        for k=1:nchan
                a = 1; b = L; i = 1;
                while i<=nwindows && b<=sizeeg
                        y = detrend(ERPLAB.data(chanArray(k),a:b));
                        Y = fft(y,NFFT)/L;
                        ffterp(i,:) = 2*abs(Y(1:NFFT/2));
                        a = b - round(L/2); % 50% overlap
                        b = b + round(L/2); % 50% overlap
                        i = i+1;
                end
                
                FFTdata(k,:,1) =  mean(ffterp,1);
        end
        msgn = 'whole';
%         f1sam  = round((f1*NFFT/2)/fnyq);
%         f2sam  = round((f2*NFFT/2)/fnyq);
%         if f1sam<1
%                 f1sam=1;
%         end
%         if f2sam>NFFT/2
%                 f2sam=NFFT/2;
%         end
        %fout = f(f1sam:f2sam);
        %yout = avgfft(1,f1sam:f2sam);
        ERS.bindescr = {'none'};
elseif iseegstruct(ERPLAB) &&  ~isempty(ERPLAB.epoch)  % epoched data
        if isempty(binArray)
                binArray = 1:ERPLAB.EVENTLIST(1).nbin;
        end
        if isempty(chanArray)
                chanArray = 1:ERPLAB.nbchan;
        end
        nchan = length(chanArray);
        nbin  = length(binArray);
        indxtimewin = ismember_bc2(ERPLAB.times, ERPLAB.times(ERPLAB.times>=latwindow(1) & ERPLAB.times<=latwindow(2)));
        datax  = ERPLAB.data(:,indxtimewin,:);
        L      = length(datax); %ERPLAB.pnts;
        ntrial = ERPLAB.trials;
        if isempty(np)
                NFFT   = 2^nextpow2(L);
        else
                NFFT = 2*np;
        end
        f = fnyq*linspace(0,1,NFFT/2);
%         ffterp = zeros(ntrial, NFFT/2, nchan);
        FFTdata = zeros(nchan, NFFT/2,nbin);
        for k=1:nchan
                for ibin=1:nbin                        
                        ffterp = zeros(ntrial, NFFT/2);
                        for i=1:ntrial
                                if ~isempty(binArray) && isfield(ERPLAB.epoch,'eventbini')
                                        if length(ERPLAB.epoch(i).eventlatency) == 1
                                                numbin = ERPLAB.epoch(i).eventbini; % index of bin(s) that own this epoch (can be more than one)
                                        elseif length(ERPLAB.epoch(i).eventlatency) > 1
                                                indxtimelock = find(cell2mat(ERPLAB.epoch(i).eventlatency) == 0); % catch zero-time locked event (type),
                                                [numbin]  = [ERPLAB.epoch(i).eventbini{indxtimelock}]; % index of bin(s) that own this epoch (can be more than one) at time-locked event.
                                                numbin    = unique_bc2(numbin(numbin>0));
                                        else
                                                numbin =[];
                                        end
                                        if iscell(numbin)
                                                numbin = numbin{:}; % allows multiples bins assigning
                                        end
                                elseif ~isempty(binArray) && ~isfield(ERPLAB.epoch,'eventbini')
                                        numbin =[];
                                else
                                        numbin =[];
                                end
                                if ~isempty(binArray) && ~isempty(numbin) && ismember_bc2(numbin, binArray(ibin))
                                        y = detrend(datax(chanArray(k),:,i));
                                        Y = fft(y,NFFT)/L;
                                        ffterp(i,:) = abs(Y(1:NFFT/2)).^2; % power
                                        if rem(NFFT, 2) % odd NFFT excludes Nyquist point
                                                ffterp(i,2:end) = ffterp(i,2:end)*2;
                                        else
                                                ffterp(i,2:end-1) = ffterp(i,2:end-1)*2;
                                        end
                                else
                                        
                                end
                        end
                        FFTdata(k,:, ibin) =  mean(ffterp,1);
                end
                
        end
        msgn = 'all epochs';
%         f1sam  = round((f1*NFFT/2)/fnyq);
%         f2sam  = round((f2*NFFT/2)/fnyq);
%         if f1sam<1
%                 f1sam=1;
%         end
%         if f2sam>NFFT/2
%                 f2sam=NFFT/2;
%         end
        
        %fout = f(f1sam:f2sam)
        %yout = avgfft(1,f1sam:f2sam);
        
        ERS.bindescr = {ERPLAB.EVENTLIST(1).bdf.description};
elseif iserpstruct(ERPLAB)
        if isempty(binArray)
                binArray =1:ERPLAB.nbin;
        end
        if isempty(chanArray)
                chanArray = 1:ERPLAB.nchan;
        end
        nchan = length(chanArray);
        nbin  = length(binArray);
        indxtimewin = ismember_bc2(ERPLAB.times, ERPLAB.times(ERPLAB.times>=latwindow(1) & ERPLAB.times<=latwindow(2)));
        datax  = ERPLAB.bindata(:,indxtimewin,:);
        L      = length(datax); %ERPLAB.pnts;
        nbin   = length(binArray);
        if isempty(np)
                NFFT = 2^nextpow2(L);
        else
                NFFT = 2*np;
        end
        f      = fnyq*linspace(0,1,NFFT/2);
        FFTdata = zeros(nchan, NFFT/2,nbin);
        for k=1:nchan
                for ibin=1:nbin
                        y = detrend(datax(chanArray(k),:,binArray(ibin)));
                        Y = fft(y,NFFT)/L;
                        ffterp = abs(Y(1:NFFT/2)).^2; % power
                        if rem(NFFT, 2) % odd NFFT excludes Nyquist point
                                ffterp(2:end) = ffterp(2:end)*2;
                        else
                                ffterp(2:end-1) = ffterp(2:end-1)*2;
                        end
                        FFTdata(k,:, ibin) =  ffterp;
                end
        end
        msgn   = 'all bins';
%         f1sam  = round((f1*NFFT/2)/fnyq);
%         f2sam  = round((f2*NFFT/2)/fnyq);
%         if f1sam<1
%                 f1sam=1;
%         end
%         if f2sam>NFFT/2
%                 f2sam=NFFT/2;
%         end
        %fout = f(f1sam:f2sam);
        %yout = avgfft(1,f1sam:f2sam);
        ERS.bindescr = ERPLAB.bindescr(binArray);
else
        error('ERPLAB says: Invalid data structure or EVENTLIST was not found!')
end

ERS.bindata = FFTdata;
ERS.xmin  = min(f)/1000; %min(fout)/1000;
ERS.xmax  = max(f)/1000; %max(fout)/1000;
ERS.nchan = size(FFTdata, 1);
ERS.nbin  = size(FFTdata, 3);
ERS.pnts  = size(FFTdata, 2);
ERS.srate = ((ERPLAB.pnts-1)/(ERPLAB.xmax-ERPLAB.xmin));
ERS.chanlocs = ERPLAB.chanlocs(chanArray);
ERS.times = f; %fout;
ERS.bindescr
msgn




