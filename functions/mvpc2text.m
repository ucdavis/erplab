% PURPOSE  :	subroutine for pop_export2text
%
% FORMAT   :
%
% serror = mvpc2text(ERP, filename, time, timeunit,  transpose,DecodingUnit)
%
%
% INPUTS     :
%
% MVPC           - MVPCset (ERPLAB structure)
% filename      - filename of outputted file
% time'         - 1=include time values; 0=don't include time values
% timeunit'     - 1=seconds; 1E-3=milliseconds
% transpose'    - 1= (points=rows) & (MVPCsets=columns)
%                 0= (MVPCsets=rows) & (points=column)
%
% OUTPUTS
%
% serror        - error report. 0 means no errors found; 1 means something went wrong...
% file          - text file
%
%
% See also pop_mvpc2text.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

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

function  serror = mvpc2text(ALLMVPC, filename, time, timeunit, transpose,DecodingUnit)
serror = 0; % no errors
%nbin = length(binArray);

[pathstr, prefname1, ext] = fileparts(filename);

if strcmp(ext,'')
    ext = '.txt';
end
precision = 4;
prefname2 = fullfile(pathstr, prefname1);
try
    
    data = [];
    count = 0;
    count1= 0;
    warmsg = '';
    for Nummofmvpc = 1:length(ALLMVPC)
        MVPC = ALLMVPC(Nummofmvpc);
        if strcmpi(MVPC.DecodingUnit,DecodingUnit)
            count = count+1;
            data(:,count) = MVPC.average_score;
            MVPCNames{1,count}=MVPC.mvpcname;
        else
            count1 = count1+1;
            if count1==1;
                warmsg =  MVPC.mvpcname;
            else
                warmsg = [warmsg,',\n',32, MVPC.mvpcname];
            end
            
        end
    end
    if ~isempty(warmsg)
        msgboxText = ['Warning message: The MVPC value “',DecodingUnit,'” does not exist in these MVPCsets:\n',...
            warmsg,'.\n',...
            'These MVPCsets will not be exportable.'];
        etitle = 'ERPLAB: pop_mvpc2text';
        errorfound(sprintf(msgboxText), etitle);
    end
    %
    % add time axis
    %
    if time==1
        %fprintf('bin #%g\n', ibin);
        time_val = (MVPC.times/1000)/timeunit; %Nov 2010
        MVPCNames = {'Time',MVPCNames{:}};
        data = [time_val',data];
    end
    
    %
    % transpose and write to disk
    %
    %strbindescr = MVPC.bindescr{binArray(ibin)};
    % strbindescr = regexprep(strbindescr,'\\|\/|\*|\#|\$|\@|\:','_'); % replace forbidden characters
    binfilename = [ prefname2 ext ]; % ...and add ext
    fid = fopen(binfilename, 'w');
    
    if transpose==1 % no transpose
        dataF = data';
        MVPCNamesF = MVPCNames';
        columNums = size(dataF,2)+1;
    else % transpose
        dataF = data;
        MVPCNamesF = MVPCNames;
        columNums = size(dataF,2);
    end
    
    formatSpec2 = '';
    if columNums==1
        formatSpec2 = [formatSpec2,'%s\n'];
    else
        for Numofcolumns = 1:columNums-1
            formatSpec2 =[formatSpec2,'%s\t',32];
        end
        formatSpec2 = [formatSpec2,'%s\n'];
    end
    if transpose==1
        for Numofrow = 1:size(dataF,1)
            data = [];
            data{1,1} = MVPCNamesF{Numofrow};
            for Numofcolumn = 1:size(dataF,2)
                data{1,Numofcolumn+1} = sprintf(['%.',num2str(precision),'f'],dataF(Numofrow,Numofcolumn));
            end
            fprintf(fid,formatSpec2,data{1,:});
        end
    else
        fprintf(fid,formatSpec2,MVPCNamesF{1,:});
        for Numofrow = 1:size(dataF,1)
            data = [];
            for Numofcolumn = 1:size(dataF,2)
                data{1,Numofcolumn} = sprintf(['%.',num2str(precision),'f'],dataF(Numofrow,Numofcolumn));
            end
            fprintf(fid,formatSpec2,data{1,:});
        end
        
    end
    fclose(fid);
    try
        disp(['A new file for MVPCset values was created at <a href="matlab: open(''' binfilename ''')">' binfilename '</a>'])
    catch
    end
catch
    serror = 1; %something went wrong
end
fprintf('\n');
