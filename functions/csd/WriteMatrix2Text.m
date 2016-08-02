% function WriteMatrix2Text ( X, FileName, FmtStg, CaseCol )
% 
% This is a generic routine to write a data matrix to an ASCII file.
%
% Usage: WriteMatrix2Text ( X, FileName, FmtStg, CaseCol );
%
%   Input arguments:         X  data matrix
%                     FileName  file name string
%                       FmtStg  formating string (default = '%9.3f')
%                     CaseCol   numeric value indicating column offset
%                               requesting to also list case numbers
%                               (default = 0 to suppress case numbers)
%        
% Updated: $Date: 2009/05/15 15:55:00 $ $Author: jk $
%
function WriteMatrix2File ( X, FileName, FmtStg, CaseCol )
if nargin < 2
   help WriteMatrix2Text
   disp('*** Error: Specify at least <X> and <FileName> as input');
   return
end
if nargin < 3
   FmtStg = '%9.3f';
end;
if nargin < 4
   CaseCol = 0;
end;
disp(sprintf('Creating formatted (%s) matrix text file: %s',FmtStg,FileName));
if CaseCol > 0
   disp(sprintf('Adding case numbers (%d chars)',CaseCol));
end;
fid = fopen(FileName,'w');          % open output file for write
for n = 1:size(X,1);
    if CaseCol > 0
       fprintf(fid, strcat('%',int2str(CaseCol),'d'), n); % print case#
    end   
    fprintf(fid, FmtStg, X(n,:) );  % print all columns
    fprintf(fid, char([13 10]) );   % print carriage return
end;
fclose(fid);                        % close output file
