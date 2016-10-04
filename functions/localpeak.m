% PURPOSE: subroutine for pop_geterpvalues.m
%          gets local peak measurements
%
% FORMAT
%
% measure = localpeak(datax, timex, parameters)
%
% or
%
% [measure, latlocalpeak, latfracpeak, errorcode] = localpeak(datax, timex, parameters)
%
%
% INPUTS
%
% datax       - epoched dataset or ERPset
% timex       - 
%
% The available parameters are as follows:
%
%        'Neighborhood' 	- number of points, in each side, for comparing the local peak value.
%                               Local peak value must reach the following two criteria:(i) be larger than both adjacent points,
%                               and (ii) be larger than the average of the two adjacent neighborhood (specified by "Neighborhood")
%        'Peakpolarity'       - {'positive'/'negative'} | peak polarity for peak detection.
%        'Multipeak' 	      - 
%        'Fraction'           - fractional percent for getting fractional (local) peak latency 
%        'Sfactor'            - Sampling factor. 1 means same means keep sampling rate. >1 means oversampling. <1 means
%                               subsampling.
%        'Measure'            - 'amplitude', 'peaklat', 'fraclat'
%        'Peakreplace'        - alterantive outcome (when no local peak was found). 'NaN' or 'abs'
%                               in case local peak is not found, replace the output by the absolute peak value (absolute) or a not-a-number
%                               value (NaN).
%        'Fracpeakreplace'    - alterantive outcome (when no fractional (local) peak latency was found). 'NaN' or 'abs'
%                               in case fractional local peak is not found replace the output by the absolute fractional peak value
%                               (absolute) or a not-a-number value (NaN).
%
% OUTPUT:
%
% measure                     - the actual measurement (either local peak amplitude, local peak latency,
%                               or fractional local peak amplitude latency)
% latlocalpeak                - (optional) the actual latency of 'measure'
% latfracpeak                 - (optional) fractional local peak amplitude latency 
% errorcode                   - error flag. 0 means no error. otherwise >0 
%
%
% See also pop_geterpvalues.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon % Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% January 25th, 2011

function [measure, latlocalpeak, latfracpeak, errorcode] = localpeak(datax, timex, varargin)

measure      = [];
vlocalpf     = [];
latlocalpeak = [];
latfracpeak  = [];
errorcode    = [];

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('datax', @isnumeric);
p.addRequired('timex', @isnumeric);

p.addParamValue('Neighborhood', 1); 
p.addParamValue('Peakpolarity', 1, @isnumeric);
p.addParamValue('Multipeak', 'off', @ischar);
p.addParamValue('Fraction', [], @isnumeric);
p.addParamValue('Sfactor', 1, @isnumeric);
p.addParamValue('Measure', 'amplitude', @ischar); % 'amplitude', 'peaklat', 'fraclat'
p.addParamValue('Peakreplace', 'NaN', @ischar); % alterantive amplitude (when no local peak was found)
p.addParamValue('Fracpeakreplace', 'NaN', @ischar); % alterantive amplitude (when no local peak was found)
p.addParamValue('Peakonset', 1, @isnumeric);



try
      p.parse(datax, timex, varargin{:});
catch
      errorcode = 1;
      return
end

%
% Tests flat data
%
du = unique_bc2(datax);
if length(du)<=round(length(datax)*0.1) % unique values are less than 10% of total sample values
      errorcode = 6;
      return
end
if strcmpi(p.Results.Multipeak,'on') || strcmpi(p.Results.Multipeak,'yes')
      multi = 1;
else
      multi = 0;
end

frac     = p.Results.Fraction;             % Fractional peak
npoints  = round(p.Results.Neighborhood);  % sample(s) at one side of the peak
nsamples = length(datax);
peakpol  = p.Results.Peakpolarity;
Fk       = round(p.Results.Sfactor);  % oversampling factor
peakonset = p.Results.Peakonset;

%
% Oversampling
%
if Fk~=1
      p1  = timex(1);
      p2  = timex(end);
      timex2   = linspace(p1,p2,Fk*(p2-p1+1));
      datax    = spline(timex, datax, timex2); % over sampled data
      timex    = timex2;
      %npoints  = npoints*Fk;    % scale neighborhood
      nsamples = length(datax); % new size
end
if nsamples<=(2*npoints)
      errorcode = 1; % error. few samples.
      return
end

%
% Starting points, npoints=neighbors, nsamples=#of samples of the window of interest + 2*npoints
%
a = npoints + 1;
b = nsamples - npoints;

%
% Absolute peaks
%
try
      if peakpol==1 % positive peak -> finds maximum
            [vabspf posabspf] = max(datax(a:b));
      else  % negative peak -> finds minimum
            [vabspf posabspf] = min(datax(a:b));
      end
      posabspf = posabspf + npoints;
      %latabspeak = timex(posabspf); % latency for absolute peak
catch
      errorcode = 1;
      return
end

%
% local peaks
%
k = 1;
valmax = [];

%
% Local peak
%
if npoints>0
      while a<=b            
            avgneighborLeft  = mean(datax(a-npoints:a-1));
            avgneighborRight = mean(datax(a+1:(a+npoints)));
            prea  = datax(a-1);
            posta = datax(a+1);
            
            if peakpol==1 % maximum for positives
                  if datax(a)>avgneighborLeft && datax(a)>avgneighborRight && datax(a)>prea && datax(a)>posta
                        valmax(k) = datax(a);
                        posmax(k) = a;
                        k=k+1;
                  end
            else  % minimum for negatives
                  if datax(a)<avgneighborLeft && datax(a)<avgneighborRight && datax(a)<prea && datax(a)<posta
                        valmax(k) = datax(a);
                        posmax(k) = a;
                        k=k+1;
                  end
            end
            a = a+1;
      end            
      if ~isempty(valmax)            
            if length(unique_bc2(valmax))==1 && length(valmax)>1 % this is when more than one sample meets the criterias for a local peak (e.g. saturated segments)
                  poslocalpf   = round(median(posmax));      % position of local peak
                  %latlocalpeak = timex(poslocalpf);         % latency for absolute peak
                  vlocalpf     = unique_bc2(valmax);             % value of local peak                  
            elseif length(unique_bc2(valmax))>1                  
                  %if multi
                  %        vlocalpf = valmax; % values for multiple local peaks
                  %        [tfxxclc, poslocalpf] = ismember_bc2(valmax, datax);
                  %              latlocalpeak    = timex(poslocalpf);   % latencies for multiple local peaks
                  %        else
                  %        if peakpol==1 % positive peak -> finds maximum
                  %                [vlocalpf indx] = max(valmax);
                  %        else  % negative peak -> finds minimum
                  %                [vlocalpf indx] = min(valmax);
                  %        end
                  %        poslocalpf      = posmax(indx);
                  %        latlocalpeak    = timex(poslocalpf);   % latency for local peak
                  %end                  
                  if multi
                        vlocalpf = valmax;
                        [tf, poslocalpf] = ismember_bc2(valmax, array);                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CHANGED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  else                        
                        if peakpol==1
                              [vlocalpf indx] = max(valmax);
                              poslocalpf      = posmax(indx);
                        else
                              [vlocalpf indx] = min(valmax);
                              poslocalpf      = posmax(indx);
                        end
                  end                  
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CHANGED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                  vlocalpf     = valmax;
                  poslocalpf   = posmax;
                  %latlocalpeak = timex(poslocalpf);   % latency for local peak
            end            
            latlocalpeak = timex(poslocalpf);   % latency for local peak
            ltypeoutput  = 1; % local peak
      else
            if strcmpi(p.Results.Peakreplace,'abs') % replaces with abs peak values
                  vlocalpf     = vabspf;
                  poslocalpf   = posabspf;
                  latlocalpeak = timex(posabspf);
                  ltypeoutput  = 2; % abs peak
            else % replace with NaN
                  vlocalpf     = NaN;
                  poslocalpf   = NaN;
                  latlocalpeak = NaN;                  
                  ltypeoutput  = 3; % NaN instead of a peak
            end
      end
      
else % if no neighbors then ABSOLUTE peak is taken.
      vlocalpf     = vabspf;
      poslocalpf   = posabspf;
      latlocalpeak = timex(posabspf);
      ltypeoutput  = 2; % abs peak
end

%
% Fractional peak latency
%
if strcmpi(p.Results.Measure,'fraclat') % fractional latency assessment
      if ~isempty(frac)
            if frac>0 && ltypeoutput~=3
                  
                a_change = -1;  % by default, have the index decrease by one, moving back thru the datapoints, looking for peak onset
                if peakonset == 2
                    a_change = 1; % if instead looking for the peak 'offset', have the index increase by one on each loop
                end
                
                
                
                  %if ~isnan(poslocalpf)
                  a = poslocalpf; % this might be local or absolute...
                  while a>0
                        currval  = datax(a);
                        if (peakpol==1 && currval<=vlocalpf*frac) || (peakpol==0 && currval>=vlocalpf*frac) % maximum for positives; miniumum for negative peak
                              posfrac = a;
                              latfracpeak = timex(posfrac);   % latency for fractional peak
                              break
                        end
                        a = a + a_change;
                  end
                  if isempty(latfracpeak) %&& strcmpi(p.Results.Fracpeakreplace,'abs') % replaces with frac abs peak values
                        latfracpeak = NaN;
                  end
                  
                  %else
                  %        latfracpeak = NaN;
                  %end
            elseif frac==0 && ltypeoutput~=3
                  %posfrac = 1;
                  latfracpeak = timex(1);   % latency for fractional peak
            else
                  latfracpeak = NaN;   % latency for fractional peak                  
            end
      else
            errorcode = 1; % no fractional value was specified
            return
      end
end

%
% Output(s)
%
if nargout==1
      if strcmpi(p.Results.Measure,'amplitude')
            measure = vlocalpf;
      elseif strcmpi(p.Results.Measure,'peaklat')
            measure = latlocalpeak;
      elseif strcmpi(p.Results.Measure,'fraclat')
            measure = latfracpeak;
      end
else
      measure = vlocalpf;
end