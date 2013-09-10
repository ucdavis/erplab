% PURPOSE: shows pop function ending statement (located at msg2end.txt)
%
% Format:
%
% msg2end
%
% See also readmsg2end.m msg2end.txt
%
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

function msg2end
[msg2show x colormsg] = readmsg2end;
try
        cprintf(colormsg, msg2show');
catch
        fprintf(msg2show);
end 
fprintf('\n');