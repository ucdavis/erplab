% FORMAT:
%
% sampval = ms_to_sample(timems,fs,EpochStart, rounding)
%
% INPUTS:
%
% timems      - time value in milliseconds
% fs          - sampling rate
%
% Optional inputs:
%
% rounding    - 1 means round the result {default}, 0 means do not round
% EpochStart  - the left interval of epoch in ERP data (in milliseconds). Default 0
%
% OUTPUT:
%
% sampval     - time in samples
%
% EXAMPLES:
%
% 1) For a time serie recorded from 0 to 5 secs, at fs=500 sps, get the sample index at the time 674 ms.
%
%>> sampval = ms_to_sample(674, 500)
%
%sampval =
%
%   338
%
% 2) For a time serie recorded from -1 to 5 secs, at fs=500 sps, get the sample index at the time 674 ms.
%>> sampval674 = ms_to_sample(674, 500, -1000)
%
%sampval_all =
%
%   838
%
%
% Author: Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

function sampval = ms_to_sample(timems,fs,offset)
if nargin<1
        help ms_to_sample
        return
end
% if nargin<4
%         rounding = 3;
% end
if nargin<3
        offset = 0;
end
if nargin<2
        error('Two inputs are requiered at least.')
%         return;
end

if timems < offset
    beep;
    error('Input time shoule be larger than offset!!!')
%         return;
end

% offset = round(offset/50)*50;

sampval = round((timems-offset)*fs/1000)+1;