% DEPRECATED
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012


function errorhunter

err = lasterror;
message = cellstr(err.message);
message = regexprep(message,'Error\s*using\s*==>','');
message = regexprep(message,'<.*>','');
tittle = ['ERPLAB: ' err.stack.name];
errorfound(message, tittle);
