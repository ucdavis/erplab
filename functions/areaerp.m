% Usage
%
% >> A = areaerp(data, fs,latsam, op, coi)
%
% or
%
% >> [A L] = areaerp(data, fs,latsam, op, coi)
%
% where
%
% data     - input array of data
% fs       - sampling frequency
% latsam   - integration limits in samples. Two values for fixed integration limits.
%            One or two values for automatic interation limit seeding.
% op       - 'auto' means look for automatic interation limits. Otherwise is fixed.
% coi      - Only for op='auto'. When an ERP waveform is not delimited by 2 zero-crossing latencies,
%            but the first one (lower integration limit), the second latency (upper integration limit)
%            will be the offset (if any) of a second or higher ERP waveform.
%            Then coi=1 will set the first zero crossing as the lower integration limit, and the
%            latency of the minimum values between the first and the second
%            ERP as the upper integration limit.
%            Then coi=2 will set the latency of the minimum values between the first and the second
%            ERP as the lower integration limit, and the second zero crossing as the upper integration limit.
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

function varargout = areaerp(data, fs,latsam, op, coi)

if nargin<4
        op = 'late';
end
if nargin<5
        coi = 1; % component of interest
end

if length(latsam)==1 && ~strcmpi(op,'auto')
        error('ERPLAB says: error at areaerp(). You must enter 2 latencies for non-automatic limits')
end

fsn = 10000;     % new sample rate 10Khz
Tsn = 1/fsn;     % new sample period
Fk   = fsn/fs;   % oversampling factor

if strcmpi(op,'auto')
        if length(latsam)==2
                
                %
                % estimates a seed latency to search integration limits, according with
                % the weighted average of the two given latencies.
                %
                vl1 = abs(data(latsam(1)));
                vl2 = abs(data(latsam(2)));
                k1  = vl1/(vl1 + vl2);
                k2  = vl2/(vl1 + vl2);
                latsam = round(k1*latsam(1) +  k2*latsam(2));
        end
        
        if length(data)>31
                dataaux    = sgolayfilt(data, 3, 31);  % Apply 3rd-order polinomial filter
        else
                dataaux = data; % no filtered
        end
        
        %
        % Limit of integrations (automatics)
        %
        vinit      = dataaux(latsam);   % voltage at latency
        vsign      = sign(vinit);
        b          = find(sign(dataaux(latsam:end))~= vsign,1,'first') + latsam -1;
        a          = find(sign(dataaux(1:latsam))  ~= vsign,1,'last');
        
        if isempty(b)
                b = length(dataaux);
        end
        if isempty(a)
                a = 1;
        end
        
        %
        % Test for detection of overlaped components
        %
        dataaux(1:a)   = 0;
        dataaux(b:end) = 0;
        dataaux = abs(dataaux);
        ndata = length(dataaux);
        [datamax imax] = max(dataaux) ;        
        ion    = find(dataaux(1:imax)>0.2*datamax, 1,'first'); % onset, at 10% max
        ioff   = find(dataaux((imax+1):end)>0.2*datamax, 1,'last') + imax; % onset, at 10% max
        onset  = dataaux(ion);
        offset = dataaux(ioff);        
        x  = [a ion imax ioff b];
        y  = [0 onset datamax offset 0];
        xx = linspace(a,b,b-a+1);
        simerp = interp1(x, y,xx,'cubic');
        
        AT1 = single(trapz(dataaux(a:b)));
        AT2 = single(trapz(simerp));
        ATrate = AT1/AT2;
        
        if ATrate<0.9
                fprintf('***************************************\n')
                fprintf('overlapping component detected!\n')
                fprintf('***************************************\n\n')
                
                if coi==1
                        fprintf('Correcting upper integration limit...\n');
                elseif coi==2
                        fprintf('Correcting lower integration limit...\n');
                end
                
                step = 5;
                
                for i = (1+step):ndata-step
                        
                        leftp  = dataaux(i-step:i-1);
                        rigthp = dataaux(i+1:i+step);
                        targp  = dataaux(i);
                        conL = length(find(leftp>targp));
                        conR = length(find(rigthp>=targp));
                        
                        if conL==5 && conR==5
                                
                                if coi==1
                                        fprintf('old upper limit: %g\n', b)
                                        fprintf('corrected upper limit: %g\n', i)
                                        b = i;
                                elseif coi==2
                                        fprintf('old lower limit: %g\n', a)
                                        fprintf('corrected lower limit: %g\n', i)
                                        a = i;
                                end
                                break
                        end
                end
        end
else
        a = latsam(1);
        b = latsam(2);
end

if isempty(a) || isempty(b)
        
        A = 0;   % either of the integration limits failed
else
        signmode   = mode(sign(data(a:b))); % positive or negative component?
        
        if signmode==0
                signmode =1;
        end
        
        newsam     = linspace(a,b,Fk*(b-a+1));
        resamp     = signmode * spline(a:b, data(a:b),newsam);
        resamp(resamp<0) = 0;
        A = single(Tsn*trapz(resamp));
end

if nargout==1
        varargout{1} = A;
elseif nargout>=2
        varargout{1} = A;
        
        if A~=0
                
                %
                % Finds 50% area latency  (in samples)
                %
                
                %
                % (convergent) binary search algorithm
                %
                Ao    = single(A/2);
                plow  = 1;
                phigh = numel(resamp);
                
                while plow <= phigh
                        
                        pmid = round((plow + phigh) / 2);
                        Ax = single(Tsn*trapz(resamp(1:pmid)));
                        
                        if Ax > Ao
                                phigh = pmid - 1;
                        elseif Ax < Ao
                                plow = pmid + 1;
                        else
                                break     % It was found!
                        end
                end
                
                L = pmid/Fk + a - 1;  % latency in (non-integer) samples
        else
                L=0;                  % there was not Area, so won't have a latency...
        end
        varargout{2} = L;
elseif nargout>3
        error('ERPLAB says: error at areaerp(). Too many output arguments!')
end

if nargout==3
        varargout{3} = [a b]; %in samples
end