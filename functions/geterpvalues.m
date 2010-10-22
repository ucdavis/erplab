% Usage:
% >> VALUES  = geterpvalues(ERP, fname, latency, chanArray, op, dig)
%
% or
%
% >> [VALUES L] = geterpvalues(ERP, fname, latency, chanArray, op, dig)
%
% INPUTS
%
% ERP        - ERP structure
% fname      - name of text file for output. e.g. 'S03_N100_peak.txt'
% latency    - one or two latencies in msec. e.g. [80 120]
% chanArray  - index(es) of channel(s) you want to extract the information. e.g. [10 22  38 39 40]
% op         - option. Any of these:
%                'instabl'    finds the relative-to-baseline instantaneous value at the specified latency.
%                'peakampbl'  finds the relative-to-baseline peak value
%                             between two latencies. See polpeak and sampeak.
%                'peaklatbl'  finds peak latency between two latencies. See polpeak and sampeak.
%                'meanbl'     calculates the relative-to-baseline mean amplitude value between two latencies.
%                'area'       calculates the area under the curve value between two latencies.
%                '50arealat' calculates the latency corresponding to the 50% area sample between two latencies.
%                'areaz'      calculates the area under the curve value. Lower and upper limit of integration
%                             are automatically found starting with a seed
%                             latency.
% coi        - component of interest (1 or 2) (only for 'areaz')
% dig        - number of digit to use, for precision, used to write the text file for output. Default is 4
% polpeak    - polarity of peak:  1=maximum (default), 0=minimum
% sampeak    - number of points in the peak's neighborhood (one-side) (0 default)
%
%
% OUTPUTS
%
% VALUES     - matrix of values. bin(s) x channel(s). geterpvalues() use always all bins.
% L          - Latencies structure: fields are:
%              "value"  : latency in msec
%              "ilimit" : limits of integration in msec in case of using "area" or "areaz" as an option
%
% text file  - text file containing formated values.
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

function varargout  = geterpvalues(ERP, latency, binArray, chanArray, op, blc, coi, polpeak, sampeak, localopt)

if nargin<1
        help geterpvalues
        return
end
if nargin<2
        error('ERROR geterpvalues(): You must specify ERP struct and latency(ies), at least.')
end

% fprintf('geterpvalues.m : START\n');

if nargin<10
        localopt = 0; % 0=write a NaN when local peak is not found.  1=export absolute peak when local peak is not found.
end
if nargin<9
        sampeak = 0; % absolute peak
end
if nargin<8
        polpeak = 1; % positive
end
if nargin<7
        coi = 1;
end
if nargin<6
        blc = 'pre';
end
if nargin<5
        op = 'instabl';
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

                if ~ismember(blc,{'no','none','pre','post','all','whole'})
                        msgboxText =  'Invalid baseline range dude!';
                        title        =  'ERPLAB: geterpvalues() baseline input';
                        errorfound(msgboxText, title);
                        return
                end
        else
                if size(blcnum,1)>1 || size(blcnum,2)>2
                        msgboxText =  'Invalid baseline range dude!';
                        title        =  'ERPLAB: geterpvalues() baseline input';
                        errorfound(msgboxText, title);
                        return
                end
        end
end
if isempty(coi)
        coi = 1;
end
if nargout==1
        condf = 0;
elseif nargout==2
        condf = 1;
else
        error('ERPLAB says: error at geterpvalues(). Too many output arguments!')
end

fs      = ERP.srate;
pnts    = ERP.pnts;
nbin    = length(binArray);
nchan   = length(chanArray);
nlat    = length(latency);
VALUES  = zeros(nbin,nchan);
LATENCY = struct([]);                            % its fields are "value" and "ilimits"
toffsa  = round(ERP.xmin*fs);                    % in samples
latsamp = round(latency*fs/1000) - toffsa + 1;   % msec to samples

if length(latsamp)==2
        if latsamp(1)<-1
                msgboxText =  'ERROR: The onset of your latency window cannot be more than 2 samples away from the real onset ';
                tittle = 'ERPLAB: erp_artmwppth()';
                errorfound(msgboxText, tittle);
                varargout = {[]};
                return
        end
        if latsamp(2)>pnts+2
                msgboxText =  'ERROR: The offset of your latency window cannot be more than 2 samples away from the real offset';
                tittle = 'ERPLAB: erp_artmwppth()';
                errorfound(msgboxText, tittle);
                varargout = {[]};
                return
        end
        if latsamp(1)<1
                latsamp(1) = 1;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Lower latency limit %.1f ms was adjusted to %.1f ms \n', latency(1), 1000*ERP.xmin);
                fprintf('%s\n\n', repmat('*',1,60));
        end
        if latsamp(2)>pnts
                latsamp(2) = pnts;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Upper latency limit %.1f ms was adjusted to %.1f ms \n', latency(2), 1000*ERP.xmax);
                fprintf('%s\n\n', repmat('*',1,60));
        end
else
        if latsamp(1)<-1 || latsamp(1)>pnts+2
                msgboxText{1} =  'ERROR: The specified latency is more than 2 samples away from the ERP window.';
                tittle = 'ERPLAB: erp_artmwppth()';
                errorfound(msgboxText, tittle);
                varargout = {[]};
                return
        end
        if latsamp(1)<1
                latsamp(1) = 1;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Latency %.1f ms was adjusted to %.1f ms \n', latency(2), 1000*ERP.xmin);
                fprintf('%s\n\n', repmat('*',1,60));
        elseif latsamp(1)>pnts
                latsamp(1) = pnts;
                fprintf('\n%s\n', repmat('*',1,60));
                fprintf('WARNING: Latency %.1f ms was adjusted to %.1f ms \n', latency(2), 1000*ERP.xmax);
                fprintf('%s\n\n', repmat('*',1,60));
        end
end

try
        for b=1:nbin
                for ch = 1:nchan
                        if nlat==1
                                if strcmpi(op,'areaz')

                                        if condf
                                                [A L il] =  areaerp(ERP.bindata(chanArray(ch), :, binArray(b)), ERP.srate, latsamp, 'auto', coi);
                                                LATENCY(b,ch).value  = ((L-1)/fs + ERP.xmin)*1000 ;
                                                LATENCY(b,ch).ilimit = num2str(((il-1)/fs + ERP.xmin)*1000)  ;
                                        else
                                                A = areaerp(ERP.bindata(chanArray(ch), :, binArray(b)), ERP.srate,latsamp, 'auto', coi) ;
                                        end

                                        VALUES(b,ch)  = A;

                                elseif strcmpi(op,'instabl')

                                        blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        VALUES(b,ch) = ERP.bindata(chanArray(ch),latsamp, binArray(b)) - blv;

                                        if condf
                                                LATENCY(b,ch).value  = latency;
                                        end
                                else
                                        stre1  = 'ERROR in geterpvalues.m: You must enter 2 latencies for ';
                                        stre2  = '''meanbl'', ''peakampbl'', ''peaklatbl'', or ''area''';
                                        strerr = [stre1 stre2];
                                        error( strerr )
                                end
                        else % between 2 latencies measurements.

                                if strcmpi(op,'meanbl')

                                        blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        VALUES(b,ch)  = mean(ERP.bindata(chanArray(ch),latsamp(1):latsamp(2), binArray(b))) - blv;

                                        if condf
                                                LATENCY(b,ch).value  = mean(latency); %msec
                                        end

                                elseif strcmpi(op,'peakampbl')

                                        blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        try
                                                dataux  = ERP.bindata(chanArray(ch),latsamp(1)-sampeak:latsamp(2)+sampeak, binArray(b));  % no filtered
                                                %valmaxf = localpeak(dataux, sampeak, polpeak)
                                        catch
                                                error(sprintf('ERPLAB says: The requested measurement range (%g - %g +/- %g ms) exceeds the time range of the data (%.1f - %.1f ms).',...
                                                        round(latency(1)), round(latency(2)), round(1000*sampeak/fs), ERP.xmin*1000, ERP.xmax*1000))
                                        end

                                        [vlocalpf, vabspf] = localpeak(dataux, sampeak, polpeak);

                                        if isempty(vlocalpf)
                                                if localopt==0
                                                        valx = NaN;
                                                else
                                                        valx = vabspf; % export the absolue peak/valley instead
                                                end
                                        else
                                                valx = vlocalpf; % local peak value
                                        end

                                        VALUES(b,ch)  = valx - blv; % value of amplitude

                                elseif strcmpi(op,'peaklatbl')

                                        try
                                                dataux  = ERP.bindata(chanArray(ch),latsamp(1)-sampeak:latsamp(2)+sampeak, binArray(b));  % no filtered
                                                %[valmaxf posmaxf ]= localpeak(dataux, sampeak, polpeak);
                                        catch
                                                error(sprintf('ERPLAB says: The requested measurement range (%g - %g +/- %g ms) exceeds the time range of the data (%.1f - %.1f ms).',...
                                                        round(latency(1)), round(latency(2)), round(1000*sampeak/fs), ERP.xmin*1000, ERP.xmax*1000))
                                        end

                                        [vlocalpf, vabspf, poslocalpf, posabspf] = localpeak(dataux, sampeak, polpeak);

                                        if isempty(vlocalpf)
                                                if localopt==0
                                                        latx = NaN;
                                                else
                                                        latx = posabspf; % export the absolue peak/valley position instead
                                                end
                                        else
                                                latx = poslocalpf; % local peak position
                                        end

                                        if isnan(latx)
                                                VALUES(b,ch) = latx; % value of latency
                                        else
                                                VALUES(b,ch) = ERP.times(latx+latsamp(1)-sampeak-1); % value of latency
                                        end

                                elseif strcmpi(op,'area')

                                        blv    = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;

                                        if condf
                                                [A L il] = areaerp(dataux, ERP.srate,latsamp) ;
                                                LATENCY(b,ch).value  = ((L-1)/fs + ERP.xmin)*1000 ;
                                                LATENCY(b,ch).ilimit = num2str(((il-1)/fs + ERP.xmin)*1000);
                                        else
                                                A  =  areaerp(dataux, ERP.srate,latsamp) ;
                                        end

                                        VALUES(b,ch)  = A;

                                elseif strcmpi(op,'50arealat') % percentage area latency

                                        blv = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;

                                        [A L il]   =  areaerp(dataux, ERP.srate,latsamp) ;
                                        %LATENCY(b,ch).value  = ((L-1)/fs + ERP.xmin)*1000 ;
                                        %LATENCY(b,ch).ilimit = num2str(((il-1)/fs+ ERP.xmin)*1000);
                                        VALUES(b,ch)  = ((L-1)/fs + ERP.xmin)*1000; % 50 % area latency (temporary)

                                elseif strcmpi(op,'areaz')

                                        blv = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        dataux = ERP.bindata(chanArray(ch), :, binArray(b)) - blv;

                                        if condf
                                                [A L il]  =  areaerp(dataux, ERP.srate,latsamp, 'auto', coi) ;

                                                LATENCY(b,ch).value  = ((L-1)/fs + ERP.xmin)*1000 ;
                                                LATENCY(b,ch).ilimit = num2str(((il-1)/fs + ERP.xmin)*1000);
                                        else
                                                A  =  areaerp(dataux, ERP.srate,latsamp, 'auto', coi) ;
                                        end

                                        VALUES(b,ch)  = A;

                                elseif strcmpi(op,'errorbl') % for Rick Addante

                                        if isempty(ERP.binerror)
                                                error('ERPLAB says: Rick, the data field for standard deviation is empty!')
                                        end

                                        dataux = ERP.bindata; % temporary store for data field
                                        ERP.bindata = ERP.binerror;  % error data to data
                                        blv  = blvalue(ERP, chanArray(ch), binArray(b), blc); % baseline value
                                        VALUES(b,ch) = mean(ERP.bindata(chanArray(ch),latsamp(1):latsamp(2), binArray(b))) - blv;
                                        ERP.bindata  = dataux; % recover original data
                                end
                        end
                end
        end
catch
        serr = lasterror;
        msgboxText = ['Please, check your inputs:\n\n'...
                      serr.message];
        tittle = 'ERPLAB: geterpvalues() error:';
        errorfound(sprintf(msgboxText), tittle);
        varargout = {[]};
        return
end

%
% Creates Output
%
if ~condf
        varargout{1} = VALUES;
elseif condf
        varargout{1} = VALUES;
        varargout{2} = LATENCY;
else
        error('ERPLAB says: error at geterpvalues.  Too many output arguments!')
end

% fprintf('geterpvalues.m : END\n');
% fprintf('Done.\n');

%---------------------------------------------------------------------------------------------------
%-----------------base line mean value--------------------------------------------------------------
function blv = blvalue(ERP, chan, bin, blcorr)

%
% Baseline assessment
%
if ischar(blcorr)

        if ~strcmpi(blcorr,'no') && ~strcmpi(blcorr,'none')

                if strcmpi(blcorr,'pre')
                        bb = find(ERP.times==0);    % zero-time locked
                        aa = 1;
                elseif strcmpi(blcorr,'post')
                        bb = length(ERP.times);
                        aa = find(ERP.times==0);
                elseif strcmpi(blcorr,'all') || strcmpi(blcorr,'whole')
                        bb = length(ERP.times);
                        aa = 1;
                else
                        toffsa = abs(round(ERP.xmin*ERP.srate))+1;
                        blcnum = str2num(blcorr)/1000;               % from msec to secs  03-28-2009

                        %
                        % Check & fix baseline range
                        %
                        if blcnum(1)<ERP.xmin
                                blcnum(1) = ERP.xmin;
                        end
                        if blcnum(2)>ERP.xmax
                                blcnum(2) = ERP.xmax;
                        end

                        aa     = round(blcnum(1)*ERP.srate) + toffsa; % in samples 12-16-2008
                        bb     = round(blcnum(2)*ERP.srate) + toffsa  ;    % in samples
                end

                blv = mean(ERP.bindata(chan,aa:bb, bin));
        else
                blv = 0;
        end
else
        toffsa = abs(round(ERP.xmin*ERP.srate))+1;
        blcnum = blcorr/1000;               % from msec to secs  03-28-2009

        %
        % Check & fix baseline range
        %
        if blcnum(1)<ERP.xmin
                blcnum(1) = ERP.xmin;
        end
        if blcnum(2)>ERP.xmax
                blcnum(2) = ERP.xmax;
        end

        aa     = round(blcnum(1)*ERP.srate) + toffsa;      % in samples 12-16-2008
        bb     = round(blcnum(2)*ERP.srate) + toffsa  ;    % in samples
        blv = mean(ERP.bindata(chan,aa:bb, bin));
end

