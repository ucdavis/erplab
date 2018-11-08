% PURPOSE: subroutine for pop_geterpvalues.m
%
% FORMAT:
%
% VALUES  = geterpvalues(ERP, latency, binArray, chanArray, moption, blc, coi, polpeak, sampeak, localopt, frac, fracmearep)
%
% or
%
% [VALUES L] = geterpvalues(...);
%
%
% INPUTS   :
%
% ERP           - ERP structures (ERPLAB ERPset)
% latency       - one or two latencies in msec. e.g. [80 120]
% binArray      - index(es) of bin(s) from which values will be extracted. e.g. 1:5
% chanArray     - index(es) of channel(s) from which values will be extracted. e.g. [10 2238 39 40]
% moption       - option. Any of these:
%         'instabl'          - finds the relative-to-baseline instantaneous value at a specified latency.
%         'meanbl'           - calculates the relative-to-baseline mean amplitude value between two latencies.
%         'peakampbl'        - finds the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
%         'peaklatbl'        - finds latency of the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
%         'fpeaklat'         - finds the fractional latency of the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
%         'area' or 'areat'  - calculates the (total) area under the curve, between two latencies.
%         'areap'            - calculates the area under the positive values of the curve, between two latencies.
%         'arean'            - calculates the area under the negative values of the curve, between two latencies.
%         'areazt'           - calculates the (total) area value under the curve, between two zero-crossing latencies automatically
%                              detected (enter one seed latency for searching)
%         'areazp'           - calculates the area value under the positive values of the curve, between two zero-crossing latencies automatically
%                              detected (enter one seed latency for searching)
%         'areazn'           - calculates the area value under the negative values of the curve, between two zero-crossing latencies automatically
%                              detected (enter one seed latency for searching)
%         'fareatlat'        - finds the latency corresponding to a specified fraction of the total area.
%         'fareaplat'        - finds the latency corresponding to a specified fraction of the area under the positive values of the curve.
%         'fareanlat'        - finds the latency corresponding to a specified fraction of the area under the negative values of the curve.
%         'ninteg'           - calculates the numerical integration of the curve, between two latencies.
%         'nintegz'          - calculates the numerical integration of the curve, between two zero-crossing latencies automatically
%                              detected (enter one seed latency for searching)
%         'fninteglat'       - finds the latency corresponding to a specified fraction of the numerical integration (signed area).
%         '50arealat'        - (old) calculates the latency corresponding to the 50% area sample between two latencies.
%
% blc        - time window for getting baseline value (reference). E.g. [-200 0]
% coi        - component of interest (1 or 2) (only for 'areaz')
% dig        - number of digit to use, for precision, used to write the text file for output. Default is 4
% polpeak    - peak polarity,   1=positive (default), 0=negative
% sampeak    - number of points in the peak's neighborhood (one-side) (0 default)
% localopt   - 0=write a NaN when local peak is not found; 1=get absolute peak when local peak is not found.
% frac       - ratio for calculating fractional area latency.
% fracmearep - 0=write a NaN when fractional area latency is not found; 1 = ? ; 2=shows error message
%
% OUTPUTS
%
% VALUES     - matrix of values. bin(s) x channel(s).
% L          - Latencies structure: fields are:
%              "value"  : latency in msec
%              "ilimit" : limits of integration in msec in case of using "area" or "areaz" as an option
%
%
% See also pop_geterpvalues.m
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

function varargout  = geterpvalues(ERP, latency, binArray, chanArray, moption, blc, coi, polpeak, sampeak, localopt, frac, fracmearep, intfactor,peakonset)

if nargin<1
        help geterpvalues
        return
end
if nargin<2
        error('ERROR geterpvalues(): You must specify ERP struct and latency(ies), at least.')
end
if nargin<14
    peakonset = 1;
end
if nargin<13
        intfactor = 1;
end
if nargin<12
        fracmearep = 0; %0=write a NaN when frac measure is not found.  1 = export frac absolute peak when frac local peak is not found.; 2=shows error message
end
if nargin<11
        frac = 0.5; % 50% area latency (if needed, by default)
end
if nargin<10
        localopt = 0; % 0=write a NaN when local peak is not found.  1=export absolute peak when local peak is not found.
end
if nargin<9
        sampeak = 0; % absolute peak. No neighbor samples
end
if nargin<8
        polpeak = 1; % positive
end
if nargin<7
        coi = 0; % 0= as it is; 1=first component; 2=2nd component
end
if nargin<6
        blc = 'pre';
end
if nargin<5
        moption = 'instabl';
end
if nargin<4
        chanArray = 1:ERP.nchan;
end
if nargin<3
        binArray = 1:ERP.nbin;
end
if ischar(blc)
        blcnum = str2num(blc);
        if isempty(blcnum)
                if ~ismember_bc2(blc,{'no','none','pre','post','all','whole'})
                        msgboxText =  'Invalid baseline range dude!';
                        %title      =  'ERPLAB: geterpvalues() baseline input';
                        %errorfound(msgboxText, title);
                        %return
                        varargout{1} = msgboxText;
                        varargout{2} = [];
                        return
                end
        else
                if size(blcnum,1)>1 || size(blcnum,2)>2
                        msgboxText =  'Invalid baseline range, dude!';
                        %title      =  'ERPLAB: geterpvalues() baseline input';
                        %errorfound(msgboxText, title);
                        %return
                        varargout{1} = msgboxText;
                        varargout{2} = [];
                        return
                end
        end
end
if ~ismember_bc2({moption}, {'instabl', 'meanbl', 'peakampbl', 'peaklatbl', 'fpeaklat',...
                'area','areat', 'areap', 'arean','areazt','areazp','areazn','fareatlat',...
                'fareaplat', 'fninteglat', 'fareanlat', 'ninteg','nintegz' });
        msgboxText =  [moption ' is not a valid option for geterpvalues!'];
        %title = 'ERPLAB: geterpvalues wrong inputs';
        %errorfound(msgboxText, title);
        %return
        varargout{1} = msgboxText;
        varargout{2} = [];
        return
end
if isempty(coi)
        coi = 1;
end
if nargout==1
        condf = 0; % only includes area values
elseif nargout==2
        condf = 1; % include latency values and limits...
else
        error('ERPLAB says: error at geterpvalues(). Too many output arguments!')
end
if isempty(sampeak)
        sampeak =0;
end

fs      = ERP.srate;
pnts    = ERP.pnts;
nbin    = length(binArray);
nchan   = length(chanArray);
nlat    = length(latency);
VALUES  = zeros(nbin,nchan);
LATENCY = struct([]);
timeor  = ERP.times; % original time vector
mintime = ERP.xmin*1000;
maxtime = ERP.xmax*1000;
%mintime_round_ms = round(mintime,0);
p1      = timeor(1);
p2      = timeor(end);
if intfactor~=1
        timex = linspace(p1,p2,round(pnts*intfactor));
        pnts  = length(timex);
        fs    = round(fs*intfactor);
else
        timex = timeor;
end

msgboxText4peak = ['The requested measurement window is invalid given the number of points specified for finding a local peak '...
        'and the epoch length of the ERP waveform.\n\n You have specified a local peak over ±%g points, which means that '...
        'there must be %g sample points between the onset of your measurement window and the onset of the waveform, '...
        'and/or %g sample points between the end of your measurement window and the end of the waveform.\n\n'...
        'Because the waveform starts at %.1f ms and ends at %.1f ms, your measurement window cannot go beyond [%.1f  %.1f] ms (unless you reduce '...
        'the number of points required to define the local peak).'];

% latsamp = [find(ERP.times>=latency(1), 1, 'first') find(ERP.times<=550, 1, 'last')];
% % its fields are "value" and "ilimits"
% toffsa  = round(ERP.xmin*fs);                    % in samples
% latsamp = round(latency*fs/1000) - toffsa + 1;   % msec to samples

[worklate{1:nbin,1:nchan}] = deal(latency); % specified latency(ies) for getting measurements.

if length(latency)==2
        [xxx, latsamp, latdiffms] = closest(timex, latency);
        if latency(1)<mintime && ms2sample(latdiffms(1),fs)>2 %JLC.10/16/2013
                msgboxText =  sprintf('The onset of your measurement window cannot be more than 2 samples earlier than the ERP window (%.1f ms)\n', timex(1));
                varargout{1} = msgboxText;
                varargout{2} = 'limit';
                return
        end
        if latency(2)<maxtime && ms2sample(latdiffms(2),fs)<-2 %JLC.10/16/2013
                msgboxText =  sprintf('The offset of your measurement window cannot be more than 2 samples later than the ERP window (%.1f ms)\n', timex(end));
                varargout{1} = msgboxText;
                varargout{2} = 'limit';
                return
        end
        if latsamp(1)==1 && ms2sample(latdiffms(1),fs)~=0 %JLC.10/16/2013
                latsamp(1) = 1;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Lower latency limit %.3f ms was adjusted to %.3f ms \n', latency(1), mintime);
                fprintf('%s\n\n', repmat('*',1,60));
        end
        if latsamp(2)==pnts && ms2sample(latdiffms(2),fs)~=0 %JLC.10/16/2013
                latsamp(2) = pnts;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Upper latency limit %.3f ms was adjusted to %.3f ms \n', latency(2), maxtime);
                fprintf('%s\n\n', repmat('*',1,60));
        end
elseif length(latency)==1
        [xxx, latsamp, latdiffms] = closest(timex, latency(1));
        if  (latsamp(1)<=(1+sampeak) || latsamp(1)>=(pnts-sampeak)) && (ms2sample(latdiffms(1),fs)<(-2+sampeak) || ms2sample(latdiffms(1),fs)>(2-sampeak)) %JLC.20/08/13
                msgboxText =  sprintf('The specified latency is more than 2 samples away from the ERP window [%.1f %.1f] ms\n', timex(1), timex(end));
                varargout{1} = msgboxText;
                varargout{2} = 'limit';
                return
        end
        if latsamp(1)<1
                latsamp(1) = 1;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Latency %.1f ms was adjusted to %.1f ms \n', latency(2), mintime);
                fprintf('%s\n\n', repmat('*',1,60));
        elseif latsamp(1)>pnts
                latsamp(1) = pnts;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Latency %.1f ms was adjusted to %.1f ms \n', latency(2), maxtime);
                fprintf('%s\n\n', repmat('*',1,60));
        end
else
        error('Wrong number of latencies...')
end
try
        for b=1:nbin
                for ch = 1:nchan
                        %
                        % Get data
                        %
                        dataux = ERP.bindata(chanArray(ch), :, binArray(b));
                        
                        %
                        % re-sampling
                        %
                        if intfactor~=1
                                dataux  = spline(timeor, dataux, timex); % re-sampled data
                        end
                        
                        %
                        % Baseline correction
                        %
                        blv    = blvalue2(dataux, timex, blc);
                        dataux = dataux - blv;
                        
                        if nlat==1   % 1 latency was specified
                                if strcmpi(moption,'areazt') || strcmpi(moption,'areazp') || strcmpi(moption,'areazn')
                                        
                                        %
                                        % get area (automatic limits, 1 seed latency)
                                        %
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        switch moption
                                                case 'areazt'
                                                        aoption = 'autot';
                                                case 'areazp'
                                                        aoption = 'autop';
                                                case 'areazn'
                                                        aoption = 'auton';
                                        end
                                        
                                        % gets values
                                        [A, Lx, il] =  areaerp(dataux, fs, latsamp, aoption, coi);
                                        worklate{b,ch} = sample2ms((il-1),fs,0) + mintime;   % integratin limits
                                        VALUES(b,ch)   = A;
                                elseif strcmpi(moption,'nintegz')
                                        
                                        %
                                        % get numerical integration (automatic limits)
                                        %
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        [A, Lx, il]  =  areaerp(dataux, fs,latsamp, 'auto', coi);
                                        worklate{b,ch} = sample2ms((il-1),fs,0) + mintime;   % integratin limits
                                        VALUES(b,ch)  = A;
                                elseif strcmpi(moption,'instabl')
                                        
                                        %
                                        % get instantaneous amplitud (at 1 latency)
                                        %
                                        %blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        VALUES(b,ch) = dataux(latsamp);
                                else
                                        stre1  = 'ERROR in geterpvalues.m: You must enter 2 latencies for ';
                                        stre2  = '''meanbl'', ''peakampbl'', ''peaklatbl'', or ''area''';
                                        strerr = [stre1 stre2];
                                        error( strerr )
                                end
                        else % between 2 latencies measurements.
                                if strcmpi(moption,'meanbl')
                                        
                                        %
                                        % get mean value
                                        %
                                        %blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        VALUES(b,ch)  = mean(dataux(latsamp(1):latsamp(2)));
                                elseif strcmpi(moption,'peakampbl')
                                        
                                        %
                                        % get peak amplitude
                                        %
                                        %blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        try
                                                dataux  = dataux(latsamp(1)-sampeak:latsamp(2)+sampeak);  % no filtered
                                                timex2  = timex(latsamp(1)-sampeak:latsamp(2)+sampeak);
                                        catch
                                                extrastr = msgboxText4peak;
                                                error('Error:peakampbl', extrastr, sampeak, sampeak, sampeak, mintime, maxtime, mintime+sample2ms(sampeak,fs), maxtime-sample2ms(sampeak,fs));
                                        end
                                        
                                        if localopt==1 %0=writes a NaN when local peak is not found.  1=export absolute peak when local peak is not found.
                                                localoptstr = 'abs';
                                        else
                                                localoptstr = 'NaN';
                                        end
                                        
                                        % gets values
                                        [valx, latpeak] = localpeak(dataux, timex2, 'Neighborhood',sampeak, 'Peakpolarity', polpeak, 'Measure','amplitude',...
                                                'Peakreplace', localoptstr);
                                        
                                        if isempty(valx)
                                                error('Peak-related measurement failed...')
                                        end
                                        
                                        worklate{b,ch} = latpeak; %((il-1)/fs + ERP.xmin)*1000;
                                        VALUES(b,ch)   = valx; % value of amplitude
                                elseif strcmpi(moption,'peaklatbl')
                                        
                                        %
                                        % get peak latency
                                        %
                                        %blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        
                                        try
                                                dataux  = dataux(latsamp(1)-sampeak:latsamp(2)+sampeak);  % no filtered
                                                timex2  = timex(latsamp(1)-sampeak:latsamp(2)+sampeak);
                                        catch
                                                extrastr = msgboxText4peak;
                                                error('Error:peaklatbl', extrastr, sampeak, sampeak, sampeak, mintime, maxtime, mintime+sample2ms(sampeak,fs), maxtime-sample2ms(sampeak,fs));
                                        end
                                        if localopt==1 %0=writes a NaN when local peak is not found.  1=export absolute peak when local peak is not found.
                                                localoptstr = 'abs';
                                        else
                                                localoptstr = 'NaN';
                                        end
                                        
                                        % gets values
                                        valx = localpeak(dataux, timex2, 'Neighborhood', sampeak, 'Peakpolarity', polpeak, 'Measure','peaklat',...
                                                'Peakreplace', localoptstr);
                                        if isempty(valx)
                                                error('Peak-related measurement failed...')
                                        end
                                        
                                        VALUES(b,ch) = valx;
                                elseif strcmpi(moption,'area') || strcmpi(moption,'areat') || strcmpi(moption,'areap') || strcmpi(moption,'arean')
                                        
                                        %
                                        % get area
                                        %
                                        switch moption
                                                case {'areat', 'area'}
                                                        aoption = 'total';
                                                case 'areap'
                                                        aoption = 'positive';
                                                case 'arean'
                                                        aoption = 'negative';
                                        end
                                        
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        A  =  areaerp(dataux, fs, latsamp, aoption, coi);
                                        VALUES(b,ch)  = A;
                                elseif strcmpi(moption,'50arealat')  % deprecated
                                        
                                        %
                                        % get 50% area latency (old)
                                        %
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        [aaaxxx, L]  =  areaerp(dataux, fs,latsamp, 'total', coi);
                                        VALUES(b,ch) = sample2ms((L-1),fs,0) + mintime; % 50 % area latency (temporary)
                                elseif strcmpi(moption,'fareatlat') || strcmpi(moption,'fninteglat') ||  strcmpi(moption,'fareaplat') || strcmpi(moption,'fareanlat')
                                        
                                        %
                                        % get fractional area latency
                                        %
                                        if frac<0 || frac>1
                                                error('ERPLAB says: error at geterpvalues(). Fractional area value must be between 0 and 1')
                                        end
                                        switch moption
                                                case 'fareatlat'
                                                        aoption = 'total';
                                                case 'fninteglat'
                                                        aoption = 'integral'; % default
                                                case 'fareaplat'
                                                        aoption = 'positive';
                                                case 'fareanlat'
                                                        aoption = 'negative';
                                        end
                                        
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        [aaaxxx, L]  =  areaerp(dataux, fs,latsamp, aoption, coi, frac, fracmearep);
                                        VALUES(b,ch) = sample2ms((L-1),fs,0) + mintime; % frac area latency
                                elseif strcmpi(moption,'fpeaklat')
                                        
                                        %
                                        % get fractional "peak" latency
                                        %
                                        if frac<0 || frac>1
                                                error('ERPLAB says: error at geterpvalues(). Fractional peak value must be between 0 and 1')
                                        end
                                        
                                        %                               try
                                        %blv = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        
                                        try
                                                dataux  = dataux(latsamp(1)-sampeak:latsamp(2)+sampeak);  % no filtered
                                                timex2  = timex(latsamp(1)-sampeak:latsamp(2)+sampeak);
                                        catch
                                                extrastr = msgboxText4peak;
                                                error('Error:fpeaklat', extrastr, sampeak, sampeak, sampeak, mintime, maxtime, mintime+sample2ms(sampeak,fs), maxtime-sample2ms(sampeak,fs));
                                        end
                                        if localopt==1 %0=writes a NaN when local peak is not found.  1=export absolute peak when local peak is not found.
                                                localoptstr = 'abs';
                                        else
                                                localoptstr = 'NaN';
                                        end
                                        if fracmearep==1 %0=writes a NaN when local peak is not found.  1=export absolute peak when local peak is not found.
                                                fracmearepstr = 'abs';
                                        else
                                                fracmearepstr = 'NaN';
                                        end
                                        
                                        % gets values
                                        [aaaxxx, latpeak, latfracpeak] = localpeak(dataux, timex2, 'Neighborhood',sampeak, 'Peakpolarity', polpeak, 'Measure','fraclat',...
                                                'Peakreplace', localoptstr, 'Fraction', frac, 'Fracpeakreplace', fracmearepstr, 'Peakonset',peakonset);
                                        
                                        if isempty(aaaxxx)
                                                error('Peak-related measurement failed...')
                                        end
                                        
                                        worklate{b,ch} = latpeak; % peak
                                        VALUES(b,ch)   = latfracpeak; % fractional peak
                                elseif strcmpi(moption,'areazt') || strcmpi(moption,'areazp') || strcmpi(moption,'areazn')
                                        
                                        %
                                        % get area (automatic limits)
                                        %
                                        switch moption
                                                case 'areazt'
                                                        aoption = 'autot';
                                                case 'areazp'
                                                        aoption = 'autop';
                                                case 'areazn'
                                                        aoption = 'auton';
                                        end
                                        
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        [A, L, il]     =  areaerp(dataux, fs,latsamp, aoption, coi);
                                        worklate{b,ch} = sample2ms((il-1),fs,0) + mintime; % integration limits
                                        VALUES(b,ch)   = A;
                                elseif strcmpi(moption,'errorbl') % for Rick Addante
                                        
                                        %
                                        % get standard deviation
                                        %
                                        if isempty(ERP.binerror)
                                                error('ERPLAB says: The data field for standard deviation is empty!')
                                        end
                                        
                                        dataux       = ERP.bindata; % temporary store for data field
                                        ERP.bindata  = ERP.binerror;  % error data to data
                                        blv          = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        VALUES(b,ch) = mean(ERP.bindata(chanArray(ch),latsamp(1):latsamp(2), binArray(b))) - blv;
                                        ERP.bindata  = dataux; % recover original data
                                elseif strcmpi(moption,'rmsbl')
                                        
                                        %
                                        % get root mean square value (RMS)
                                        %
                                        VALUES(b,ch) = sqrt(mean(dataux(latsamp(1):latsamp(2)).^2));
                                elseif strcmpi(moption,'ninteg')
                                        
                                        %
                                        % get numerical integration
                                        %
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        A  =  areaerp(dataux, fs,latsamp, 'integral', coi);
                                        VALUES(b,ch)  = A;
                                elseif strcmpi(moption,'nintegz')
                                        
                                        %
                                        % get numerical integration (automatic limits)
                                        %
                                        %blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        %dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;
                                        
                                        % gets values
                                        [A, Lx, il]    =  areaerp(dataux, fs,latsamp, 'auto', coi);
                                        worklate{b,ch} = sample2ms((il-1),fs,0) + mintime; % integratin limits
                                        VALUES(b,ch)   = A;
                                end
                        end
                end
        end
catch
        serr = lasterror;
        varargout{1} = serr.message;
        varargout{2} = [];
        return
end

%
% Creates Output
%
if ~condf
        varargout{1} = VALUES;
elseif condf
        varargout{1} = VALUES;
        varargout{2} = worklate;
else
        error('ERPLAB says: error at geterpvalues.  Too many output arguments!')
end
