% PURPOSE: Gets the halfamp cutoff frequency value using filtfilt.m
% 
% WARNING: For working with filtfilt.m function!
% 
% filtfilt result has the following characteristics:
%       a) Zero-phase distortion
%       b) A filter transfer function, which equals the squared magnitude of the original filter transfer function
%           WARNING by JLC: THIS IMPLIES THAT THE CUTOFF FREQUENCY IS NOT AT -3dB ANYMORE, IT IS AT -6dB INSTEAD!!!
%       c) A filter order that is double the order of the filter specified by b and a
%     
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function frec3dB = halfamp(b, a, fs)
try
        [hf,f1] = freqz(b,a,10000,fs);
        hf2 = hf^2; % filtfilt has a transfer function, which equals the squared magnitude of the original filter transfer function.
        [v loc] = min(abs(0.707-abs(hf2))); % frequency at gain 70.7%
        frec3dB = f1(loc);
catch
        frec3dB = [];
end