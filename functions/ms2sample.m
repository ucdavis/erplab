% FORMAT:
%
% sampval = ms2sample(timems, fs, rounding, offset)
%
% INPUTS:
%
% timems      - time value in milliseconds
% fs          - sample rate
%
% Optional inputs:
%
% rounding    - 1 means round the result {default}, 0 means do not round
% offset      - offset time in samples (you can use ms2sample recursively here). Default 0
%
% OUTPUT:
%
% sampval     - time in samples
%
% EXAMPLES:
%
% 1) For a time serie recorded from 0 to 5 secs, at fs=500 sps, get the sample index at the time 674 ms.
%
%>> sampval = ms2sample(674, 500)
%
%sampval =
%
%   337
%
% 2) For a time serie recorded from -1 to 5 secs, at fs=500 sps, get the sample index at the time 674 ms.
%
%>> sampval = ms2sample(674, 500, 1, ms2sample(1000, 500))
%
%sampval =
%
%   837
%
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function sampval = ms2sample(timems, fs, rounding, offset)
if nargin<1
        help ms2sample
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
sampval = offset + timems*fs/1000;
if rounding
        sampval = round(sampval);
end