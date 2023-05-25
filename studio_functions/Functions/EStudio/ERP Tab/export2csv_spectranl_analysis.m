% PURPOSE  :	import the data to be ".CSV" file
%
% FORMAT   :
%
% serror = export2csv_spectranl_analysis(ERP, filename, binArray, time, timeunit, electrodes, transpose, precision)
%
%
% INPUTS     :
%
% ERP           - ERPset (ERPLAB structure)
% filename      - filename of outputted file
% binArray      - bins to export
% time'         - 1=include time values; 0=don't include time values
% electrodes'   - 1=include electrode labels;  0=don't include electrode labels
% transpose'    - 1= (points=rows) & (electrode=columns)
%                 0= (electrode=rows) & (points=column)
% precision'    - [float] number of significant digits in output. Default 4.
%
% OUTPUTS
%
% serror        - error report. 0 means no errors found; 1 means something went wrong...
% file          - csv file
%
%
% See also pop_export2text.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon && Eric Foo && Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009 & 2023

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2022 The Regents of the University of California
% Created by Javier Lopez-Calderon, Steven Luck and Guanghui ZHANG
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu, and ghzhang@ucdavis.edu
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



function  serror = export2csv_spectranl_analysis(ERP, filename, binArray, time, electrodes, transpose, precision)
serror = 0; % no errors
nbin = length(binArray);

[pathstr, prefname1, ext] = fileparts(filename);

if strcmp(ext,'')
    ext = '.csv';
end

binfilename = [ prefname1   ext ]; % ...and add ext
fid = fopen(fullfile(pathstr,binfilename), 'w');

try
    %         disp('Your specified bins have been separated into the following files:')fprintf(fid_text, '\n');
    nbin = ERP.nbin;
    nchan = ERP.nchan;
    Frebin = numel(ERP.times);
    ERPname = ERP.erpname;
    fprintf(fid, '%s,%s\n',['Bins:,', num2str(nbin)]);
    fprintf(fid, '\n');
    fprintf(fid, '%s,%s\n',['Channels:,', num2str(nchan)]);
    fprintf(fid, '\n');
    fprintf(fid, '%s,%s\n',['Frequencies:,', num2str(Frebin)]);
    fprintf(fid, '\n');
    fprintf(fid, '%s,%s\n',['ERPset name:,',ERPname]);
    
    
    fprintf(fid, '\n\n\n\n');
    for ibin=1:nbin
        
        data = ERP.bindata(:,:,binArray(ibin));
        fprintf(fid, '#\n#');
        labx_bin = strcat(num2str(ibin),'-',ERP.bindescr{ibin});
        labx_bin = regexprep(labx_bin,'\\|\/|\*|\#|\$|\@,','_');
        try
            labx_bin = strrep(labx_bin,',','-');
        catch
            labx_bin= labx_bin;
        end
        %                 fprintf(fid, 'Bin: %s\t\n', labx_bin);num2str(ibin)
        fprintf(fid, '%s %f \n',strcat('Bin:', labx_bin));
        fprintf(fid, '\n');
        fprintf(fid, '%s\n','#');
        % add time axis
        %
        if time==1
            %                         fprintf('bin #%g\n', ibin);
            time_val = ERP.times; %Nov 2010
            auxdata  = zeros(size(data,1) + 1, size(data,2));
            auxdata(1,:)     = time_val;
            auxdata(2:end,:) = data;
            data = auxdata; clear auxdata;
        end
        
        %
        % transpose and write to disk
        %
        if transpose==0 % no transpose
            
            %
            % writing electrodes
            %
            headName = '';
            strprintf = '';
            for index = 1:size(data,1)
                if time==1 % show time values
                    tmpind = index-1;
                else
                    tmpind = index;
                end
                if electrodes==1
                    if tmpind > 0
                        if ~isempty(ERP.chanlocs)
                            labx = '';
                            labx = ERP.chanlocs(tmpind).labels;
                            labx = regexprep(labx,'\\|\/|\*|\#|\$|\@','_'); % replace forbidden characters
                            headName = [headName,strcat(num2str(tmpind),'-',labx),','];
                        else
                            headName = [headName,strcat(num2str(tmpind)),','];
                        end
                    else
                        headName = [headName,strcat('Frequency  (Hz)'),','];
                    end
                else
                    %                     if tmpind > 0
                    %                         headName = [headName,'',','];
                    %                     else
                    %                         headName = [headName,strcat('Frequency  (Hz)'),','];
                    %                     end
                end
                if  index~= size(data,1)
                    strprintf = [ strprintf '%.' num2str(precision) 'f,' ];
                else
                    strprintf = [ strprintf '%.' num2str(precision) 'f\n' ];
                end
                
            end
            
            if electrodes==1
                headName(end) = '\';
                headName = [headName,'n'];
                fprintf(fid, headName);
            end
            for jj = 1:size(data,2)
                fprintf(fid, strprintf, data(:,jj)); %#ok<PFCEL>
            end
            fprintf(fid, '\n\n\n\n\n');
        else % transpose
            
            %
            % writing electrodes
            %
            
            for index = 1:size(data,1)
                headName = '';
                if time==1
                    tmpind = index-1;
                else
                    tmpind = index;
                end
                if electrodes==1
                    
                    if tmpind > 0
                        if ~isempty(ERP.chanlocs)
                            labx = ERP.chanlocs(tmpind).labels;
                            labx = regexprep(labx,'\\|\/|\*|\#|\$|\@','_'); % replace forbidden characters.
                            headName =  strcat(num2str(tmpind),'-',labx);
                        else
                            headName = num2str(tmpind);
                        end
                    else
                        headName = 'Frequency. (Hz)';
                    end
                end
                if electrodes==1
                    strprintf = '%s,';
                else
                    strprintf = '';
                end
                for jj = 1:size(data,2)
                    if  jj~= size(data,2)
                        strprintf = [ strprintf '%.' num2str(precision) 'f,' ];
                    else
                        strprintf = [ strprintf '%.' num2str(precision) 'f\n' ];
                    end
                end
                if electrodes==1
                    fprintf(fid,strprintf, headName,data(index, :));
                else
                    fprintf(fid,strprintf,data(index, :));
                end
            end
            fprintf(fid, '\n\n\n\n\n');
        end
        
    end
    fclose(fid);
    
    
catch
    serror = 1; %something went wrong
end
fprintf('\n');
