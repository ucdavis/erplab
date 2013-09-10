% [arflag usflag] = dec2flag(value);
%
% Example. identify artifact and user flags encoded within the decimal value 1860
%
%  [arflag usflag] = dec2flag(1860)
% 
% arflag =
% 
%      3     7
% 
% 
% usflag =
% 
%      1     2     3
%
% See also flag2dec
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013
%

function [arflag usflag] = dec2flag(value)
arflag = [];
usflag = [];
if nargin<1
        help dec2flag
        return
end
if isempty(value)
        error('value must be an integer number between 0 and 65535')
end
if ~isnumeric(value)
        error('value must be numeric')
end
if value<0
        error('value must be an integer number between 0 and 65535')
end
if value>65535
        error('value must be an integer number between 0 and 65535')
end
value = round(value);
binaryflag = fliplr(dec2bin(value, 16));
bitnum = strfind(binaryflag,'1');
arflag = bitnum(bitnum<9);
usflag = bitnum(bitnum>8)-8;

