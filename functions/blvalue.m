% PURPOSE: Gets the base line mean value from channel "chan", bin "bin", and window (for baseline) "blcorr"
%
%
% FORMAT:
%
% blv = blvalue(ERP, chan, bin, blcorr)
%
% INPUT:
%
% ERP        - input ERPset
% chan       - channel to be measured
% bin        - bin to be measured
% blcorr     - time window for getting the mean value
%
% OUTPUT:
%
% blv        - mean value from channel "chan", bin "bin", and window (for baseline) "blcorr"
%
%
% Example
% Get the baseline value for a window of -200 to 0 ms, at bin 4, channel 23
%
% blv = blvalue(ERP, 23, 4, [-200 0])
%
%
% See also geterpvalues.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function blv = blvalue(ERP, chan, bin, blcorr)

%
% Baseline assessment
%
datatype = checkdatatype(ERP);
if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end
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
                  blcnum = str2num(blcorr); % in ms
                  
                  %
                  % Check & fix baseline range
                  %
                  if blcnum(1)<ERP.xmin*kktime
                        blcnum(1) = ERP.xmin*kktime; %ms
                  end
                  if blcnum(2)>ERP.xmax*kktime
                        blcnum(2) = ERP.xmax*kktime; %ms
                  end
                  
                  [xxx, cindex] = closest(ERP.times, blcnum); % 04/21/2011
                  aa = cindex(1); % ms to sample pos
                  bb = cindex(2); % ms to sample pos
            end
            blv = mean(ERP.bindata(chan,aa:bb, bin));
      else
            blv = 0;
      end
else      
      %
      % Check & fix baseline range
      %
      if blcorr(1)<ERP.xmin*kktime
            blcorr(1) = ERP.xmin*kktime; %ms
      end
      if blcorr(2)>ERP.xmax*kktime
            blcorr(2) = ERP.xmax*kktime; %ms
      end
      [xxx, cindex] = closest(ERP.times, blcorr); % 04/21/2011
      aa = cindex(1); % ms to sample pos
      bb = cindex(2); % ms to sample pos
      blv = mean(ERP.bindata(chan,aa:bb, bin));
end
