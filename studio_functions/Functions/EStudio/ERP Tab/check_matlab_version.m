% PURPOSE: 
%   little function to simplify the checking of the version of Matlab
% FORMAT:
%   [Matlab_ver_yr] = check_matlab_version
% OUTPUT:
%    Matlab_ver_yr - a numeric of the release year {like 2018.5 for Matlab
%    R2018b.}
%
% *** This function is part of ERPLAB Toolbox ***
% Andrew X Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2018

function [Matlab_ver_yr] = check_matlab_version

Matlab_ver = version('-release');
Matlab_ver_yr = str2double(Matlab_ver(1:4));


if strcmp(Matlab_ver(5),'b')
    Matlab_ver_yr = Matlab_ver_yr + 0.5; 
    % signify 'b' releases with a 0.5 added to the year
end


% some functions like struct2table don't work in older than 2013b
% let's warn the user

if Matlab_ver_yr < 2013.5
    errortxt = ['Some ERPLAB functions require a somewhat modern version of Matlab. R2013b is the oldest recommended. You are running R' Matlab_ver];
    warning(errortxt);
end

