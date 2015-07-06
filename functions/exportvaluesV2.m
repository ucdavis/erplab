% PURPOSE  :	  subroutine for pop_geterpvalues.m
%                 Creates a text file containing measured values.
%
% FORMAT   :
%
% exportvaluesV2(ERP, values, binArray, chanArray, fname, dig, ncall, binlabop, formatout, mlabel, lat4mea)
%
%
% INPUTS   :
%
% ERP           - ERPLAB's ERPset
% values        - single matrix of values from amplitude-related measurements. bins x channels.
% binArray      - index(es) of bin(s) from which values were extracted. e.g. 1:5
% chanArray     - index(es) of channel(s) from which values were extracted. e.g. [10 2238 39 40]
% fname         - filename for exporting values.
% dig           - numerical precision (number of decimal places)
% ncall         - loop counter. If you are using this function in a loop,
%                 send the loop's pointer using this variable.
% binlabop      - include bin label (1 yes; 0 no)
% formatout     - organization of data: 1 means "long format"; 0 means "wide format"
% mlabel        - measurement label. e.g. 'P1_latency'
% lat4mea       - include latency(ies) from which measurement was taken.
%
% OUTPUT
%
% Text file
%
%
% See also geterpvaluesGUI2.m geterpvalues.m, exportvalues2xls.m, exportvaluesV2.m
%
%
% *** This function is part of ERPLAB Toolbox ***
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
%
% BUGs and Improvements :
% ----------------------
% Measurement label option included. Suggested by Paul Kieffaber
% Local peak bug (when multiple peaks) fixed. Thanks Tanya Zhuravleva

function exportvaluesV2(ERP, values, binArray, chanArray, fname, dig, ncall, binlabop, formatout, mlabel, lat4mea)

if nargin<11
        lat4mea = []; % latencies for measurements given by the user
end
if nargin<10
        mlabel = ''; % label for measurement
end
if nargin<9
        formatout = 0; % 1 means "long format"; 0 means "wide format"
end
if nargin<8
        binlabop  = 0; % 0 means use "bin#" as a label for bin; 1 means use bind descr as a label
end
if nargin<7
        ncall = 1; % single call
end
if nargin<6
        dig = 3; % number of decimals
end
if nargin<5
        error('ERPLAB says: few input arguments for exportvaluesV2.m')
end

nbin  = length(binArray);
nchan = length(chanArray);

if isempty(ERP.chanlocs)
        for e=1:ERP.nchan
                chanlabels{e} = ['Ch' num2str(e)];
        end
else
        chanlabels = {ERP.chanlocs.labels};
end
if ncall==0
        error('ERPLAB says: errot at exportvaluesV2(). ncall must be any integer equal or greater than 1')
end
if ncall==1
        fprintf('Creating 1 text output file...\n');
        %disp(['An output file with your measuring work was create at <a href="matlab: open(''' fname ''')">' fname '</a>'])
        fid_values  = fopen(fname, 'w');
else
        fid_values  = fopen(fname, 'a'); %append
        fseek(fid_values, 0, 'eof');
end
if fid_values<0      % JLC. Jul 1, 2015
      warning('ERPLAB says: Check your Current Folder settings. It looks like you do not have privileges to create a file there... ')
      return
end

VALUES  = values{1};

%
% OUTPUT
%
erpname = ERP.erpname;
lenerpn = length(erpname);
binstr  = {[]};
lml     = length(mlabel);
L       = zeros(1, nbin);

for b=1:nbin        
        if binlabop==0
                binstr{b}  = num2str(binArray(b));
        else
                bd = strtrim(ERP.bindescr{binArray(b)});
                binstr{b} = regexprep(bd,' ','_'); % replace whitespace(s)
        end
        L(b) = length(binstr{b});
end
lenbinstr = max(L);

%
% Header
%
z0 = floor(log10(nbin)); % number of characters - 1 for bin index

if ncall==1
        if formatout==0 % one erpset per line (WIDE)
                binline   = '';
                for b=1:nbin                        
                        zi   = z0 - floor(log10(b)); % number of characters - 1
                        zstr = repmat('0',1,zi); % number of zeros to keep constant bin index lenght

                        for ch=1:nchan
                                if binlabop==0
                                        binline = [binline sprintf('bin%s%g_%s', zstr, binArray(b), chanlabels{chanArray(ch)}) '\t' ];
                                else
                                        binlabstr = regexprep(ERP.bindescr{binArray(b)},' ','_'); % replace whitespace(s)
                                        binlabstr = sprintf('bin%s%g_%s', zstr, binArray(b), binlabstr);
                                        binline = [binline sprintf('%s_%s', binlabstr, chanlabels{chanArray(ch)}) '\t' ];
                                end
                        end
                end  
                binline = sprintf(binline);
                fprintf(fid_values,  '%s\t', binline); 
                if isempty(mlabel)
                    frmt = [ '%' num2str(round(lenerpn/2)) 's\n'];
                    fprintf(fid_values, frmt, 'ERPset');
                else
                    frmt = [ '%' num2str(round((length(mlabel))/2)) 's\t%' num2str(round(lenerpn/2)) 's\n'];
                    fprintf(fid_values, frmt, 'mlabel', 'ERPset');
                end
        elseif formatout==1 % one measurement per line (LONG)
                headerline = {'value', 'chindex','chlabel',  'bini'};
                lenheader  = length(headerline);
                formatoh   = repmat('%12s\t',1,lenheader); 
                
                if ~isempty(mlabel)
                        headerline = ['mlabel' headerline];                        
                        formatoh   = ['%' num2str(lml) 's\t' formatoh];
                end
                if ~isempty(lat4mea)
                        headerline = ['worklat' headerline];
                        formatoh   = ['%' num2str(16) 's\t' formatoh];
                end
                if binlabop~=0
                        headerline = [headerline 'binlabel'];
                        formatoh   = [formatoh '%' num2str(lenbinstr) 's\t'];
                end     
                
                headerline = [headerline 'ERPset'];                
                formatoh   = [formatoh '%' num2str(lenerpn) 's\n'];
                
                %lenheader = length(headerline);
                %formatoh = ['%12s\t' repmat('%12s\t',1,lenheader-3) '%' num2str(lenbinstr) 's\t' '%' num2str(lenerpn) 's\n'];
                fprintf(fid_values, formatoh, headerline{:});
        else
                error('ERPLAB says: errot at exportvaluesV2(). Unknown specified output format')
        end
end

%
% Values
%
if formatout==0 % one erpset per line (WIDE)
        fstr1 = ['%.' num2str(dig) 'f'];
        for b=1:nbin
                for k=1:nchan
                        valstr =  sprintf(fstr1, VALUES(b,k));
                        if binlabop==0
                                lenerpnvalstr = 10; %length(valstr);  
                        else
                                lenerpnvalstr = length(ERP.bindescr{binArray(b)})+ 2; 
                        end
                                              
                        frmt = ['%' num2str(lenerpnvalstr) 's\t'];                        
                        fprintf(fid_values,  frmt, valstr);
                end
        end
        if isempty(mlabel)
            frmt = ['%' num2str(lenerpn) 's'];
            fprintf(fid_values,  frmt, ERP.erpname );
        else
            frmt = ['%' num2str(length(mlabel)) 's\t%' num2str(lenerpn) 's'];
            fprintf(fid_values,  frmt, mlabel, ERP.erpname );
        end
        fprintf(fid_values,'\n');        
elseif formatout==1 % one measurement per line (LONG)        
        fstr1 = ['%.' num2str(dig) 'f'];
        
        for b=1:nbin
                for k=1:nchan
                        valstr =  sprintf(fstr1, VALUES(b,k));
                         
                        if isempty(lat4mea)
                                clat4meastr = '';
                        else
                                clat4mea = lat4mea{b,k};
                                
                                if length(clat4mea)==1
                                        clat4meastr = sprintf('[%s]', num2str(clat4mea));
                                elseif length(clat4mea)==2
                                        ss1 = sprintf('%.1f', clat4mea(1));
                                        ss2 = sprintf('%.1f', clat4mea(2));
                                        clat4meastr = sprintf('[%s  %s]', ss1, ss2);
                                else
                                        clat4meastr = 'error';
                                end
                        end                            
                        if ~isempty(clat4meastr)
                              fprintf(fid_values,  '%16s\t', clat4meastr); % print latency(ies)
                        end
                        if ~isempty(mlabel)
                                frmt = ['%' num2str(lml) 's\t'];
                                fprintf(fid_values, frmt, mlabel);  % print measurement label
                        end
                        
                        fprintf(fid_values,  '%12s\t', valstr); % print value
                        
                        chanstr    = num2str(chanArray(k));
                        chanlabstr = chanlabels{chanArray(k)};
                        binistr    = num2str(binArray(b));
                        
                        frmt = '%12s\t%12s\t%12s\t';
                        fprintf(fid_values,  frmt, chanstr, chanlabstr, binistr);  % print channel index, channel label, bin index
                        
                        if binlabop~=0
                                frmt = [ '%' num2str(lenbinstr) 's\t'];
                                fprintf(fid_values,  frmt, binstr{b});
                        end
                        
                        frmt = [ '%' num2str(lenerpn) 's\n'];
                        fprintf(fid_values,  frmt, ERP.erpname);                        
                end
        end
end

fclose(fid_values);