% FORMAT:
%
% sampval = sample_to_ms(timesam, fs,EpochStart, rounding)
%
% INPUTS:
%
% timesam     - time value in time samples
% fs          - sampling rate (in Hz)
%
%
% Optional inputs:
%
% rounding    - 1 means round the result {default}, 0 means do not round
% EpochStart  - the left interval of epoch/trial (e.g.,  -200ms). Default is 0 ms.


% OUTPUT:
%
% sampval     - time in milliseconds
%
% EXAMPLES:
%
% 1) For a time serie recorded from 0 to 5 secs, at fs=500 sps, get the time in ms for the sample # 337.
%
% msval = sample_to_ms(337, 500)
%
% msval =
%
%    672
%
% 2) For a time serie recorded from -1 to 5 secs, at fs=500 sps, get the absolute time in ms for the sample # 337.
%
% msval = sample_to_ms(337, 500, -1000)
%
% msval =
%
%    -328
%
%
% Author: Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Feb., 2022

function msval = sample_to_ms(timesam,fs,offset, rounding)
if nargin<1
    help sample_to_ms
    return
end

if nargin<4
    rounding = 0;
end
% 
if nargin < 3
    offset = 0;
end

if nargin<2
    error('Two inputs are required at least!!!');
end


msval = 1000*(timesam-1)/fs+offset;

if rounding
    msval = round(msval);
end

