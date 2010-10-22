function errorhunter

err = lasterror;
message = cellstr(err.message);
message = regexprep(message,'Error\s*using\s*==>','');
message = regexprep(message,'<.*>','');
tittle = ['ERPLAB: ' err.stack.name];
errorfound(message, tittle);
