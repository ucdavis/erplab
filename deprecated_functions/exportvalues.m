% DEPRECATED...
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function exportvalues(ERP, values, binArray, chanArray, condf, dig, op, fname, ncall, binlabop)


if nargin<10
        binlabop = 0; % 0 means use "bin#" as a label for bin. 1 means use bind descr as a label
end

nbin  = length(binArray);
nchan = length(chanArray);

if ncall==0
        error('ERPLAB says: errot at exportvaluesV2(). ncall must be any integer equal or greater than 1')
end
if ncall==1
        fprintf('Creating 1 text output file...\n');
        disp(['An output file with your measuring work was create at <a href="matlab: open(''' fname ''')">' fname '</a>'])
        fid_values  = fopen(fname, 'w');
        
        disp('Nuevo')
else
        fid_values  = fopen(fname, 'a'); %append
        fseek(fid_values, 0, 'eof');
                disp('pega')
end

VALUES  = values{1};

formatstr = repmat(['%.' num2str(dig) 'f\t'],1, nbin);
formatstr = ['%s\t%s\t' formatstr '\n']; % each line format
extlabel  = {[]};

if ncall==1
        binline   = '';
        for b=1:nbin
                if binlabop==0
                        binline = [binline sprintf('bin%g\t', binArray(b))];
                else
                        binline = [binline sprintf('%s\t', ERP.bindescr{binArray(b)})];
                end
        end
        binline = [blanks(11) binline];
        fprintf(fid_values,  'ERPset\tchannel\t%s\n', binline);
end

for i =1:nchan  %01-09-2009
        try
                blk = 10 - length(ERP.chanlocs(chanArray(i)).labels);
                extlabel{i} = [ERP.chanlocs(chanArray(i)).labels blanks(blk)];
        catch
                extlabel{i} = '  no_label';
        end
end

for k=1:nchan
        fprintf(fid_values,  formatstr, ERP.erpname, extlabel{k}, VALUES(:,k));
end

fclose(fid_values);

