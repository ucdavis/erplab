% PURPOSE: Gets the baseline (mean) value
%
%
% FORMAT:
%
% blv = blvalue2(datax, timex, blcorr)
%
% INPUT:
%
% datax      - input data 
% timex      - time vector
% blcorr     - time window for getting the mean value
%
% OUTPUT:
%
% blv        - mean value from window "blcorr"
%
%
% Example
% Get the baseline value for a window of -200 to 0 ms, at bin 4, channel 23
%
% blv = blvalue(ERP.bindata(23,:,4), ERP.times, [-200 0])
%
%
% See also blvalue2.m geterpvalues.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function blv = blvalue2(datax, timex, blcorr)

%
% Baseline assessment
%
if ischar(blcorr)      
      if ~strcmpi(blcorr,'no') && ~strcmpi(blcorr,'none')
            
            if strcmpi(blcorr,'pre')
                  [bbxx bb] = closest(timex, 0);    % zero-time locked
                  aa = 1;
            elseif strcmpi(blcorr,'post')
                  bb = length(timex);
                  [aax aa] = closest(timex, 0);
            elseif strcmpi(blcorr,'all') || strcmpi(blcorr,'whole')
                  bb = length(timex);
                  aa = 1;
            else
                  blcnum = str2num(blcorr); % in ms
                  
                  %
                  % Check & fix baseline range
                  %
                  if blcnum(1)<min(timex)
                        blcnum(1) = min(timex); %ms
                  end
                  if blcnum(2)>max(timex)
                        blcnum(2) = max(timex); %ms
                  end
                  
                  [xxx, cindex] = closest(timex, blcnum); % 04/21/2011
                  aa = cindex(1); % ms to sample pos
                  bb = cindex(2); % ms to sample pos
            end
            blv = mean(datax(aa:bb));
      else
            blv = 0;
      end
else      
      %
      % Check & fix baseline range
      %
      if blcorr(1)<min(timex)
            blcorr(1) = min(timex); %ms
      end
      if blcorr(2)>max(timex)
            blcorr(2) = max(timex); %ms
      end
      [xxx, cindex] = closest(timex, blcorr); % 04/21/2011
      aa = cindex(1); % ms to sample pos
      bb = cindex(2); % ms to sample pos
      blv = mean(datax(aa:bb));
end
