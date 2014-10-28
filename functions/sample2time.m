% FORMAT:
%
% sampval = sample2time(timeop, timems, fs, rounding, offset)
%
% INPUTS:
%
% timeop      - second or millisecond; 0 or 1
% timeval     - time value in samples
% fs          - sample rate
%
% Optional inputs:
%
% rounding    - 1 means round the result {default}, 0 means do not round
% offset      - offset time in milliseconds (depends on timeop) or seconds (you can use sample2time recursively here). Default 0
%
% OUTPUT:
%
% sampval     - time in milliseconds or seconds
%
%
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function msval = sample2time(timeop, timeval, fs, rounding, offset)
if nargin<1
        help sample2time
        return
end
if nargin<5
        offset = 0;
end
if nargin<4
        rounding = 1;
end
if nargin<3
        fs = 1;
end
if nargin<2
        error('Two inputs are requiered at least.')
end
if timeop==0 % sec
    kktime=1;
elseif timeop==1 % msec
    kktime=1000;
else
    error('unknow timeop input.')
end
msval = offset + kktime*timeval/fs;
if rounding
        msval = round(msval);
end