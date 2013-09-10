% PURPOSE: exports an ERPset (ERPLAB's ERP structure) to a text file
%
% FORMAT:
%
% erp2asc(ERP, filename, pathname)
%
%
% Inputs:
%
%   ERP          - ERPset
%   filename     - text file name
%   pathname     - text file path
%
%
% Output
% 
% text file
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

function erp2asc(ERP, filename, pathname)
if nargin < 1
        help erp2asc
        return
end

fid_text  = fopen(fullfile(pathname, filename), 'w');

if isempty(ERP.filename)
        expdesc = ERP.erpname;
        ext ='';
else
        [pathstr, erpfile, ext] = fileparts(ERP.filename);
        expdesc   = erpfile;
end

%
% MASTER HEADER -----------------------------------------------------------
%
%
% Required by asctoerp:
%
fprintf(fid_text, '\n');
fprintf(fid_text, 'expdesc="%s"\n', [expdesc ext]);
fprintf(fid_text, 'subdesc="%s"\n', [expdesc ext]);
fprintf(fid_text, 'expname="%s"\n','Marissa');
fprintf(fid_text, 'filedesc=""\n');
nchan = ERP.nchan;
fprintf(fid_text, 'nchans%9d\n', nchan);

for i=1:nchan
        fprintf(fid_text, '%4d  "%s"\n', i-1, ERP.chanlocs(i).labels);
end

% A resolution of 100 allows values from
% -327.67 to 327.67 uV with .01 uV precision.
fprintf(fid_text, 'resolution %5d\n', 100);

%
%	Optional:
%
fprintf(fid_text,'arslots   "Total"\n');
digperiod = round(1e6/ERP.srate);
fprintf(fid_text, 'digperiod %6d\n', digperiod);
fprintf(fid_text, 'calsize %8g\n', 1);
fprintf(fid_text, '\n');

%--------------------------------------------------------------------------

nbin    = ERP.nbin;
npoints = ERP.pnts-1;
sampleperiod = round(1e6/ERP.srate);

% Fake BIN 0 (obsolete in ERPLAB version)

%
% bin header parameters

%
% For verbose
%
fprintf(fid_text, '#\n#  Data file:  %s\n#\n', [expdesc ext]);
fprintf(fid_text, '\n');
fprintf(fid_text, '#\n#\tbinno %10d\n#\n', 0);

%
% Required by asctoerp:
%
fprintf(fid_text, 'bindesc="%s"\n', 'Calibration');
fprintf(fid_text, 'condesc="%s"\n', 'Calibration');
fprintf(fid_text, 'npoints %8d\n', npoints);
fprintf(fid_text, 'sampleperiod %9d\n', sampleperiod);
fprintf(fid_text, 'presampling %10d\n', abs(round(ERP.xmin*1E6)));
fprintf(fid_text, 'sums %11d\n', 1);
fprintf(fid_text, 'procfuncs   "%s"\n', 'avg');
fprintf(fid_text, 'arejects %11d\n', 0);
fprintf(fid_text, '\n');

%
% For verbose
%
fprintf(fid_text, '#\n#  Bin desc:   Calibration\n');
fprintf(fid_text, '#  Cond. desc: Calibration\n');
fprintf(fid_text, '#  Bin %d,    Procfunc %g\n', 0, 0);

%
% fake calibration pulse  data!
%
data = zeros(nchan, npoints);
data(:,round(npoints./2):round(npoints.*(3/4))) = 10;
%
% Print an entire processing function with sample point moving
% fastest.
for j=1:nchan
        
        fprintf(fid_text, '#\n#  Channel %d (%s):\n#\n', j-1, ERP.chanlocs(j).labels);
        lineformat = repmat('%7.2f',1,10);
        fprintf(fid_text, [lineformat '\n'], data(j,:));
        fprintf(fid_text, '\n\n');
end

fprintf(fid_text, '\n');% change bin 3 blank line total

% Writing BINs, starting from BIN 1
for k=1:nbin          
        fprintf(fid_text, '\n');
        fprintf(fid_text, '#\n#\tbinno %10d\n#\n', k);
        
        %
        % Required by asctoerp:
        %
        bindesc= ERP.bindescr{k};
        bindesc = regexprep(bindesc, '  ', '');
        fprintf(fid_text, 'bindesc="%s"\n', bindesc);
        fprintf(fid_text, 'condesc="%s"\n', bindesc);
        fprintf(fid_text, 'npoints %8d\n', npoints);
        fprintf(fid_text, 'sampleperiod %9d\n', sampleperiod);
        fprintf(fid_text, 'presampling %10d\n', abs(round(ERP.xmin*1E6)));
        fprintf(fid_text, 'sums %11d\n', ERP.ntrials.accepted(k));
        fprintf(fid_text, 'procfuncs   "%s"\n', 'avg');
        fprintf(fid_text, 'arejects      %g\n', ERP.ntrials.rejected(k));
        fprintf(fid_text, '\n');
        
        %
        % For verbose
        %
        fprintf(fid_text, '#\n#  Bin desc:   %s\n',bindesc);
        fprintf(fid_text, '#  Cond. desc: %s\n', bindesc);
        fprintf(fid_text, '#  Bin %d,    Procfunc %g\n', k, 0);
        
        for m=1:nchan
                fprintf(fid_text, '#\n#  Channel %d (%s):\n#\n', m-1, ERP.chanlocs(m).labels);
                lineformat = repmat('%8.2f',1,10);
                fprintf(fid_text, [lineformat '\n'], ERP.bindata(m,1:end-1,k));
                fprintf(fid_text, '\n\n');
        end
        
        fprintf(fid_text, '\n');  % change bin 3 blank line total
end
pause(0.1)
fclose(fid_text);
pause(0.1)
disp(['A new file containing your ERP data was created at <a href="matlab: open(''' fullfile(pathname, filename) ''')">' fullfile(pathname, filename) '</a>'])