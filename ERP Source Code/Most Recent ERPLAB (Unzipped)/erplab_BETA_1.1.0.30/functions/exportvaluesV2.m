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

function exportvaluesV2(ERP, values, binArray, chanArray, condf, dig, op, fname, ncall, binlabop, formatout)


if nargin<10
        binlabop = 0; % 0 means use "bin#" as a label for bin. 1 means use bind descr as a label
end
if nargin<11
        formatout = 0; % 0 means "one measurement per line". 1 means "one erpset per line"
end

nbin  = length(binArray);
nchan = length(chanArray);

if ncall==0
        error('ERPLAB: ncall must be any integer equal or greater than 1')
end
if ncall==1
        fprintf('Creating 1 text output file...\n');
        disp(['An output file with your measuring work was create at <a href="matlab: open(''' fname ''')">' fname '</a>'])
        fid_values  = fopen(fname, 'w');
else
        fid_values  = fopen(fname, 'a'); %append
        fseek(fid_values, 0, 'eof');
end

VALUES  = values{1};

% formatstr = repmat(['%.' num2str(dig) 'f\t'],1, nbin*nchan);
% formatstr = ['%s\t' formatstr '\n']; % each line format
extlabel  = {[]};

if ncall==1
        if formatout==0
                binline   = '';
                for b=1:nbin
                        for ch=1:nchan
                                if binlabop==0
                                        binline = [binline sprintf('bin%g_%s', binArray(b), ERP.chanlocs(chanArray(ch)).labels) '\t' ];
                                else
                                        binlabstr = regexprep(ERP.bindescr{binArray(b)},' ','_'); % replace whitespace(s)
                                        binline = [binline sprintf('%s_%s', binlabstr, ERP.chanlocs(chanArray(ch)).labels) '\t' ];
                                end
                        end
                end
                
                binline = sprintf(binline);
                fprintf(fid_values,  '%s%s\n', ['ERPset' blanks(35)], binline);
                
        elseif formatout==1
                fprintf(fid_values,  '%s%s\t%s\t%s\n', ['ERPset' blanks(34)], 'bin    ', 'channel', 'value  ');        
        else
                error('ERPLAB says: Unknown specified output format')
        end
end

% for i =1:nchan  %01-09-2009
%         try
%                 blk = 10 - length(ERP.chanlocs(chanArray(i)).labels);
%                 extlabel{i} = [ERP.chanlocs(chanArray(i)).labels blanks(blk)];
%         catch
%                 extlabel{i} = '  no_label';
%         end
% end

% formatstr = repmat(['%.' num2str(dig) 'f\t'],1, nbin*nchan)
% formatstr = [formatstr '\n']; % each line format

if formatout==0
        
        fprintf(fid_values,  '%s', [ERP.erpname blanks(40-length(ERP.erpname))]);
        fstr1 = ['%.' num2str(dig) 'f'];
        
        for b=1:nbin
                for k=1:nchan
                        valstr =  sprintf(fstr1, VALUES(b,k));
                        blk = dig + 3 - length(valstr);
                        fprintf(fid_values,  '%s\t', [blanks(blk) valstr]);
                end
        end
        
        fprintf(fid_values,'\n')
        
elseif formatout==1
        
%         fprintf(fid_values,  '%s', [ERP.erpname blanks(16-length(ERP.erpname))]);
        fstr1 = ['%.' num2str(dig) 'f'];
        
        for b=1:nbin
                for k=1:nchan
                        valstr =  sprintf(fstr1, VALUES(b,k));
                        blk = dig + 3 - length(valstr);
                        binstr  = [num2str(b) blanks(7-length(num2str(b)))]; 
                        chanstr = [num2str(k) blanks(7-length(num2str(k)))]; 
                        fprintf(fid_values,  '%s %s\t%s\t%s\n', [ERP.erpname blanks(40-length(ERP.erpname))],...
                                binstr, chanstr, [blanks(blk) valstr]);
                end
        end
        
        %fprintf(fid_values,'\n')
end

fclose(fid_values);






% formatstr = repmat(['%.' num2str(dig) 'f\t'],1, nbin);
% formatstr = ['%s\t%s\t' formatstr '\n']; % each line format
% extlabel  = {[]};
% 
% if ncall==1
%         binline   = '';
%         for b=1:nbin
%                 if binlabop==0
%                         binline = [binline sprintf('bin%g\t', binArray(b))];
%                 else
%                         binline = [binline sprintf('%s\t', ERP.bindescr{binArray(b)})];
%                 end
%         end
%         binline = [blanks(11) binline];
%         fprintf(fid_values,  'ERPset\tchannel\t%s\n', binline);
% end
% 
% for i =1:nchan  %01-09-2009
%         try
%                 blk = 10 - length(ERP.chanlocs(chanArray(i)).labels);
%                 extlabel{i} = [ERP.chanlocs(chanArray(i)).labels blanks(blk)];
%         catch
%                 extlabel{i} = '  no_label';
%         end
% end
% 
% for k=1:nchan
%         fprintf(fid_values,  formatstr, ERP.erpname, extlabel{k}, VALUES(:,k));
% end
% 
% fclose(fid_values);
% 
