% PURPOSE: Exports measured values to an Excel file
%
% FORMAT:
%
% exportvalues2xls(ERP, values, binArray, chanArray, condf, op, fname, ncall)
%
% INPUTS:
%
% ERP        - input ERP structure
% values     - single matrix of values from amplitude-related measurements. bins x channels.
%              This matrix can be obtained using ERPLAB function geterpvalues().
%              See example 1 below.
%
%              You can also specify amplitude-related and latency-related measurements
%              for this input variable. Latencies are stored in a structure with 2
%              fields: values and ilimit. value contains the latency info after
%              measurments like "peak amplitude", or "area". Peak amplitude is just
%              the time of the peak. For area, latency means the point in time in which
%              the signal among 2 predefined latencies reaches 50% of the area.
%              ilimit will only be stored if any of both type of area measurement were set.
%              It just stores the limits of integration used for the area assessment.
%
%              This strcuture can also be obtained using ERPLAB function geterpvalues().
%              See example 2 below.
%
% binArray     - index(es) of bin(s) from which values were extracted. e.g. 1:5
% chanArray    - index(es) of channel(s) from which values were extracted. e.g. [10 2238 39 40]
% condf        - 1 means get latencies too.  0 means only amplitude-related
% op           - any string like the following:
%                'instabl'          - finds the relative-to-baseline instantaneous value at a specified latency.
%                'meanbl'           - calculates the relative-to-baseline mean amplitude value between two latencies.
%                'peakampbl'        - finds the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
%                'peaklatbl'        - finds latency of the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
%                'fpeaklat'         - finds the fractional latency of the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
%                'area' or 'areat'  - calculates the (total) area under the curve, between two latencies.
%                'areap'            - calculates the area under the positive values of the curve, between two latencies.
%                'arean'            - calculates the area under the negative values of the curve, between two latencies.
%                'areazt'           - calculates the (total) area value under the curve, between two zero-crossing latencies automatically
%                                     detected (enter one seed latency for searching)
%                'areazp'           - calculates the area value under the positive values of the curve, between two zero-crossing latencies automatically
%                                     detected (enter one seed latency for searching)
%                'areazn'           - calculates the area value under the negative values of the curve, between two zero-crossing latencies automatically
%                                     detected (enter one seed latency for searching)
%                'fareatlat'        - finds the latency corresponding to a specified fraction of the total area.
%                'fareaplat'        - finds the latency corresponding to a specified fraction of the area under the positive values of the curve.
%                'fareanlat'        - finds the latency corresponding to a specified fraction of the area under the negative values of the curve.
%                'ninteg'           - calculates the numerical integration of the curve, between two latencies.
%                'nintegz'          - calculates the numerical integration of the curve, between two zero-crossing latencies automatically
%                                     detected (enter one seed latency for searching)
%                'fninteglat'       - finds the latency corresponding to a specified fraction of the numerical integration (signed area).
%                '50arealat'        - (old) calculates the latency corresponding
%                                     to the 50% area sample between two latencies.
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
% Then, for exportvalues2xls(), you should write;
%
% >> exportvalues2xls(ERP, {A}, [3 7 12], [12 20 25 28 30], 0, 'meanbl', 'Test.xls', 1)
%
% Example 2:
%
% Get the peak amplitude between 100 and 200 ms post stimulus, for
% bins 3,7, and 12, evaluated at channels 12, 20, 25, 28, and 30.
% Use a, the interval between -100 to 0 ms as a baseline correction.
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
% See also geterpvaluesGUI2.m geterpvalues.m exportvaluesV2.m
%
%
% *** This function is part of ERPLAB Toolbox ***
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

[pathstr, filename, ext] = fileparts(fname);

if ~strcmpi(ext,'.xls')
        ext = '.xls';
end

newname1 = fullfile(pathstr, [filename ext]); % 20 oct 2009
binline   = cell(1,nbin);

for b=1:nbin
        binline{b} = ['bin' num2str(binArray(b))];
end
arearelatedop = {'areat', 'areap', 'arean', 'areaz', 'areazt', 'areazp', 'areazn',...
        'fareatlat', 'fareaplat', 'fareanlat', 'ninteg', 'nintegz',...
        'fninteglat', '50arealat'};
%
% First call
%
if ncall==1
        fprintf('Creating 1 .xls file with sheet: VALUES...\n');
        xlswrite(newname1, [{'Subject' 'channel'} binline], 'VALUES','A1')
        if condf
                fprintf('Adding new sheet: LATENCIES...\n');
                xlswrite(newname1, [{'Subject' 'channel'} binline], 'LATENCIES','A1')
                %if strcmpi(op, 'area') || strcmpi(op, 'areaz')
                if ismember_bc2(op, arearelatedop)
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
        valincell = num2cell(VALUES(:,k)); %bin's values for channel k
        infoval(k,:) = {ERP.erpname, extlabel{k}, valincell{:}};
        
        if condf
                latincell = num2cell([LATENCY(:,k).value]);
                infolat(k,:) = {ERP.erpname, extlabel{k}, latincell{:}};
                
                %if strcmpi(op, 'area') || strcmpi(op, 'areaz')
                if ismember_bc2(op, arearelatedop)
                        limincell = {LATENCY(:,k).ilimit};
                        infolimit(k,:) = {ERP.erpname, extlabel{k}, limincell{:}};
                end
        end
end
xlswrite(newname1,infoval , 'VALUES', PPP)
if condf
        xlswrite(newname1, infolat , 'LATENCIES', PPP)
        %if strcmpi(op, 'area') || strcmpi(op, 'areaz')
        if ismember_bc2(op, arearelatedop)
                xlswrite(newname1, infolimit, 'LIMITS', PPP)
        end
end