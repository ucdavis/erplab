% Usage
%
% exportvalues2xls(ERP, values, binArray, chanArray, condf, op, fname, ncall)
%
% ERP        - input ERP structure
% values     - single matrix of values from amplitud-related measurements,
% which dimension is bins x channels.
%
% This matrix can be obtained using ERPLAB function geterpvalues().
% See example 1 below.
%
% You can also specify amplitud-related and latency-related measurements
% for this input variable. Latencies are stored in an structure with 2
% fields: values and ilimit. value contains the latency info after
% measurments like "peak amplitud", or "area". For peak amplitud is just
% the time of the peak. For area, latency means the point in time in which
% the signal among 2 predefined latencies reachs the 50% of the area.
% ilimit will only stored if any of both type of area measurement was set.
% It just stores the limits of integration used for the area assessment.
%
% This strcuture can also be obtained using ERPLAB function geterpvalues().
% See example 2 below.
%
% binArray     - array with the bin indexes you are going to get measurements.
% chanArray    - array with the channel indexes you are going to get measurements.
% condf        - 1 means get latencies, too.  0 means only amplitud-related
% op           - any string like 'instabl', 'peakbl', 'meanbl',  'area', or 'areaz'
%                 instabl = instantaneous value, baseline referenced.
%                 peakbl = peak (or valley) value, baseline referenced.
%                 meanbl = mean value, baseline referenced.
%                 area = area value, fixed integration limits (latencies),
%                 baseline referenced.
%                 areaz = area value, automatic integration limits
%                 (latencies), baseline referenced.
%
% fname        - name of the output file (extension .xls).
% ncall        - loop counter. If you are using this function in a loop,
%                send the loop's pointer using this variable.
%
% Example 1:
%
% Get the mean amplitud between 100 and 200 ms post stimulus, for
% bins 3,7, and 12, evaluated at channels 12, 20, 25, 28, and 30.
% Use a prestimulus baseline correction.
%
% >> A  = geterpvalues(ERP, [100 200], [3 7 12], [12 20 25 28 30], 'meanbl', 'pre', 0)
%
%       A =
%
%       -1.2971   -2.7223   -3.9208   -6.0047   -3.3538
%       -0.3751    4.4539    2.3570    1.4819    2.3894
%       0.6265  -10.4775   -0.9944   -7.7830   -7.4780
%
% Then, for exportvalues2xls(), you shoul write;
%
% >> exportvalues2xls(ERP, {A}, [3 7 12], [12 20 25 28 30], 0, 'meanbl', 'Test.xls', 1)
%
% Example 2:
%
% Get the peak amplitud between 100 and 200 ms post stimulus, for
% bins 3,7, and 12, evaluated at channels 12, 20, 25, 28, and 30.
% Use a the interval between -100 to 0 ms as a baseline correction.
%
%>> [A L] = geterpvalues(ERP, [100 200], [3 7 12], [12 20 25 28 30], 'peakbl', [-100 0], 0)
%
% A =
%    -3.8460   -7.3004   -4.9385   -6.5970   -1.3019
%    -4.5300    7.7207    4.0416    3.5710    3.7953
%     3.1165   -2.3055    3.2501   -8.5088   -9.5730
% L =
% 3x5 struct array with fields:
%     value
%
%>> [L.value]
% ans =
%   Columns 1 through 13
%   187.5000  191.4063  128.9063  199.2188  117.1875  128.9063  199.2188  101.5625  101.5625  199.2188  101.5625  156.2500  101.5625
%   Columns 14 through 15
%   171.8750  148.4375
%
% Then, for exportvalues2xls(), you shoul write;
%
% >> exportvalues2xls(ERP, {A,L}, [3 7 12], [12 20 25 28 30], 1, 'meanbl', 'TestplusLat.xls', 1)
%
%
% Author: Javier Lopez-Calderon & Johanna Kreither
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

function exportvalues2xls(ERP, values, binArray, chanArray, condf, op, fname, ncall)

if nargin<1
        help exportvalues2xls
        return
end

nbin  = length(binArray);
nchan = length(chanArray);

if ncall==0
        error('ERPLAB says: errot at exportvaluesV2(). ncall must be any integer equal or greater than 1')
end

if length(values)==1
        condf = 0;
        disp('WARNING: latencies measuring was not requested.')
        VALUES  = values{1};
elseif length(values)==2
        VALUES  = values{1};
        LATENCY = values{2};
end

[pathstr, filename, ext, versn] = fileparts(fname);

if ~strcmpi(ext,'.xls')
        ext = '.xls';
end

newname1 = fullfile(pathstr, [filename ext]); % 20 oct 2009
binline   = cell(1,nbin);

for b=1:nbin
        binline{b} = ['bin' num2str(binArray(b))];
end

%
% First call
%
if ncall==1
        fprintf('Creating 1 .xls file with sheet: VALUES...\n');
        xlswrite(newname1, [{'Subject' 'channel'} binline], 'VALUES','A1')
        if condf
                fprintf('Adding new sheet: LATENCIES...\n');
                xlswrite(newname1, [{'Subject' 'channel'} binline], 'LATENCIES','A1')
                if strcmpi(op, 'area') || strcmpi(op, 'areaz')
                        fprintf('Adding new sheet: LIMITS...\n');
                        xlswrite(newname1, [{'Subject' 'channel'} binline], 'LIMITS','A1')
                end
        end
end

extlabel  = cell(1,nchan);
for i =1:nchan  %01-09-2009
        extlabel{i} = ERP.chanlocs(chanArray(i)).labels;
end

nPPP = (ncall-1)*nchan + 2;
PPP = ['A' num2str(nPPP)]; % Excel's cell pointer
infoval   = cell(nchan,nbin+2);
infolat   = cell(nchan,nbin+2);
infolimit = cell(nchan,nbin+2);

for k=1:nchan
        
        valincell = num2cell(VALUES(:,k)); %bin's values of channel k
        infoval(k,:) = {ERP.erpname, extlabel{k}, valincell{:}};
        
        if condf
                latincell = num2cell([LATENCY(:,k).value]);
                infolat(k,:) = {ERP.erpname, extlabel{k}, latincell{:}};
                
                if strcmpi(op, 'area') || strcmpi(op, 'areaz')
                        limincell = {LATENCY(:,k).ilimit};
                        infolimit(k,:) = {ERP.erpname, extlabel{k}, limincell{:}};
                end
        end
end
xlswrite(newname1,infoval , 'VALUES', PPP)
if condf
        xlswrite(newname1, infolat , 'LATENCIES', PPP)
        if strcmpi(op, 'area') || strcmpi(op, 'areaz')
                xlswrite(newname1, infolimit, 'LIMITS', PPP)
        end
end