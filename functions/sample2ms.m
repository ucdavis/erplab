% FORMAT:
%
% sampval = ms2sample(timems, fs, rounding, offset)
%
% INPUTS:
%
% timesam     - time value in samples
% fs          - sample rate
%
% Optional inputs:
%
% rounding    - 1 means round the result {default}, 0 means do not round
% offset      - offset time in milliseconds (you can use sample2ms recursively here). Default 0
%
% OUTPUT:
%
% sampval     - time in milliseconds
%
% EXAMPLES:
%
% 1) For a time serie recorded from 0 to 5 secs, at fs=500 sps, get the time in ms for the sample # 337.
%
% msval = sample2ms(337, 500)
% 
% msval =
% 
%    674
%
% 2) For a time serie recorded from -1 to 5 secs, at fs=500 sps, get the absolute time in ms for the sample # 337.
%
% msval = sample2ms(337, 500, 0, sample2ms(500,500))
% 
% msval =
% 
%    1674
%
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function msval = sample2ms(timesam, fs, rounding, offset)
if nargin<1
        help sample2ms
        return
end
if nargin<4
        offset = 0;
end
if nargin<3
        rounding = 1;
end
if nargin<2
        error('Two inputs are requiered at least.')
end
msval = offset + 1000*timesam/fs;
if rounding
        msval = round(msval);
end