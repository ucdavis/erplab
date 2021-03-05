% PURPOSE: subroutine of pop_geterpvalues.m
%
% Format
%
% A = areaerp(data, fs, latsam, op, coi)
%
% or
%
% [A L] = areaerp(data, fs,latsam, op, coi)
%
% where
%
% data     - input array of data
% fs       - sampling frequency
% latsam   - integration limits in samples. Two values for fixed integration limits.
%            One or two values for automatic integration limit seeding.
% op       - 'auto'  gets area under the curve, using automatic integration limits (otherwise is fixed)
%            'autot' gets area under the curve, using automatic integration limits (total area. same as 'auto')
%            'autop' gets area under the curve, using automatic integration limits (positive area only)
%            'auton' gets area under the curve, using automatic integration limits (negative area only)
%          - 'integral' gets integral of the curve (positive and negative areas get subtracted)
%          -
% coi      - Only for op='auto'. When an ERP waveform is not delimited by 2 zero-crossing latencies,
%            but the first one (lower integration limit), the second latency (upper integration limit)
%            will be the offset (if any) of a second or higher ERP waveform.
%            Then coi=1 will set the first zero crossing as the lower integration limit, and the
%            latency of the minimum values between the first and the second
%            ERP as the upper integration limit.
%            Then coi=2 will set the latency of the minimum values between the first and the second
%            ERP as the lower integration limit, and the second zero crossing as the upper integration limit.
%
%
% See also pop_geterpvalues.m trapz.m
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

function varargout = areaerp(data, fs,latsam, op, coi, frac, fracarearep, intfactor)
if nargin<8
                intfactor = 1;
end
if nargin<7
        fracarearep = 0; %NaN;  in case frac area lat is not found.
end
if nargin<6
        frac = 0.5; % for 50% fractional area latency, by default
end
if nargin<5
        coi = 1; % component of interest
end
if nargin<4
        op = 'integral';
end
if length(latsam)==1 && ~ismember({op},{'auto','autot','autop','auton'})
        error('ERPLAB says: error at areaerp(). You must enter 2 latencies for non-automatic limits')
end
if ~isempty(frac) && (frac<0 || frac>1)
        error('ERPLAB says: error at areaerp(). Fractional area value must be between 0 and 1')
end
if intfactor>1 % interpolate data
        fsn  = fs*intfactor;      % new sample rate
        Ts   = 1/fsn;             % sample period
        nsam = length(data);
        aa   = 1; bb = nsam;
        newsam   = linspace(aa,bb,intfactor*(bb-aa+1));
        data     = spline(aa:bb, data(aa:bb),newsam); % interpoled data
        latsam   = round(latsam*intfactor)-1;
else
        Ts = 1/fs;     % sample period
end
if ismember({op},{'auto','autot','autop','auton'})
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
        
        %
        % Limit of integrations (automatic)
        %
        vinit = data(latsam);   % voltage at latency
        vsign = sign(vinit);
        b     = find(sign(data(latsam:end))~= vsign,1,'first') + latsam -1; % in sample
        a     = find(sign(data(1:latsam))  ~= vsign,1,'last'); % in sample
        
        if isempty(b)
                b = length(data);
        end
        if isempty(a)
                a = 1;
        end
        if ~isempty(coi) && coi>0
                %
                % Test for detection of overlaped components
                %
                data(1:a)   = 0;
                data(b:end) = 0;
                data   = abs(data); % rectification
                ndata  = length(data);
                [datamax imax] = max(data) ;
                ion     = find(data(1:imax)>0.2*datamax, 1,'first'); % onset, at 10% max
                ioff    = find(data((imax+1):end)>0.2*datamax, 1,'last') + imax; % onset, at 10% max
                onset   = data(ion);
                offset  = data(ioff);
                x  = [a ion imax ioff b];
                y  = [0 onset datamax offset 0];
                xx = linspace(a,b,b-a+1);
                simerp = interp1(x, y,xx,'cubic');
                AT1    = single(trapz(data(a:b)));
                AT2    = single(trapz(simerp));
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
                                leftp  = data(i-step:i-1);
                                rigthp = data(i+1:i+step);
                                targp  = data(i);
                                conL   = length(find(leftp>targp));
                                conR   = length(find(rigthp>=targp));
                                
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
        end
else
        try
                a = latsam(1); % in sample
                b = latsam(2); % in sample
        catch
                error('ERPLAB says: 2 latency values are required.')
        end
end
if isempty(a) || isempty(b)
        A = 0;   % either of the integration limits failed
else
        if ismember({op},{'autot','total'})
                data = abs(data);
        elseif ismember({op},{'autop','positive'})
                data(data<0) = 0;
        elseif ismember({op},{'auton','negative'})
                data = -data;
                data(data<0) = 0; % negative values get positive, and the previously positive ones get zeroed.
        end
        
        %
        %  Calculates area
        %
        A = single(Ts*trapz(data(a:b))); % April 21, 2011
end
if nargout==1
        varargout{1} = A;
elseif nargout==2 || nargout==3
        varargout{1} = A;
        if A~=0
                
                %
                % Finds fractional (50% by default) area latency  (in samples)
                %
                Ao = single(A*frac); % Fractional area
                
                if Ao~=0
                        %
                        % (convergent) binary search algorithm
                        %
                        plow  = a;
                        phigh = b;
                        
                        while plow <= phigh
                                pmid = round((plow + phigh) / 2);
                                Ax   = single(Ts*trapz(data(a:pmid)));
                                
                                if Ax > Ao
                                        phigh = pmid - 1;
                                elseif Ax < Ao
                                        plow = pmid + 1;
                                else
                                        break     % It was found!
                                end
                        end
                        L = pmid;  % Frac latency in (non-integer) samples
                else
                        L = a;     % if Ao=0 then L=lower area limit
                end
        else
                if fracarearep==0 % Fractional area latency replacement
                        L = NaN; % if Ao=0 then fractional latency = NaN
                else
                        error('ERPLAB:zeroarea',['Sorry, fractional area latency was not found because area value is zero.\n'...
                                'You may use fractional area latency replacement option.'])
                end
        end
        
        %
        % Frac latency
        %       
        varargout{2} = L/intfactor; % rescale. samples
        
        if nargout==3
                
                %
                % Integration limits
                %
                varargout{3} = [a b]/intfactor; %in samples
        end
elseif nargout>3
        error('ERPLAB says: error at areaerp(). Too many output arguments!')
end