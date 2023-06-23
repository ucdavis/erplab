% PURPOSE  :	subroutine for pop_export2text
%
% FORMAT   :
%
% serror = export2text(ERP, filename, time, timeunit,  transpose)
%
%
% INPUTS     :
%
% MVPC           - MVPCset (ERPLAB structure)
% filename      - filename of outputted file
% time'         - 1=include time values; 0=don't include time values
% timeunit'     - 1=seconds; 1E-3=milliseconds
% transpose'    - 1= (points=rows) & (values=columns)
%                 0= (values=rows) & (points=column)
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

function  serror = export2text(MVPC, filename, time, timeunit, transpose)
serror = 0; % no errors
%nbin = length(binArray);

[pathstr, prefname1, ext] = fileparts(filename);

if strcmp(ext,'')
        ext = '.txt';
end
precision = 4; 
prefname2 = fullfile(pathstr, prefname1);
try        
        disp('Your MVPC results have been exported into the following files:')
%        for ibin=1:nbin
                
                %
                % ERP data
                %
                data = MVPC.average_score;
                
                %
                % add time axis
                %
                if time==1
                        %fprintf('bin #%g\n', ibin);
                        time_val = (MVPC.times/1000)/timeunit; %Nov 2010
                        auxdata  = zeros(size(data,1) + 1, size(data,2));
                        auxdata(1,:)     = time_val;
                        auxdata(2:end,:) = data;
                        data = auxdata; clear auxdata;
                end
                
                %
                % transpose and write to disk
                %
                %strbindescr = MVPC.bindescr{binArray(ibin)};
               % strbindescr = regexprep(strbindescr,'\\|\/|\*|\#|\$|\@|\:','_'); % replace forbidden characters
                binfilename = [ prefname2 ext ]; % ...and add ext
                fid = fopen(binfilename, 'w');
                
                if transpose==1 % no transpose
                        
                        %
                        % writing electrodes
                        %
                        strprintf = '';
                        for index = 1:size(data,1)
                                if time==1 % show time values
                                        tmpind = index-1;
                                else
                                        tmpind = index;
                                end
                                  
                                if tmpind > 0
%                                     if ~isempty(MVPC.chanlocs)
%                                         labx = MVPC.chanlocs(tmpind).labels;
%                                         labx = regexprep(labx,'\\|\/|\*|\#|\$|\@','_'); % replace forbidden characters
%                                         fprintf(fid, '%s\t', labx);
%                                     else
                                        fprintf(fid, '\t');
%                                     end
                                else
                                    fprintf(fid, 'time\t\n');
                                end

                                strprintf = [ strprintf '%.' num2str(precision) 'f\t' ];
                        end
                        
                        strprintf(end) = 'n';
                        
%                         if electrodes==1
%                                 fprintf(fid, '\n');
%                         end
                        fprintf(fid, strprintf, data);
                else % transpose
                        
                        %
                        % writing electrodes
                        %
                        for index = 1:size(data,1)
                                if time==1
                                        tmpind = index-1;
                                else
                                        tmpind = index;
                                end
%                                 if electrodes==1
%                                         if tmpind > 0
%                                                 if ~isempty(MVPC.chanlocs)
%                                                         labx = MVPC.chanlocs(tmpind).labels;
%                                                         labx = regexprep(labx,'\\|\/|\*|\#|\$|\@','_'); % replace forbidden characters.
%                                                         fprintf(fid,'%s\t', labx);
%                                                 else
%                                                         fprintf(fid,'%d\t', tmpind);
%                                                 end
%                                         else
%                                                 fprintf(fid, 'time\t');
%                                         end
%                                 end
                                fprintf(fid,[ '%.' num2str(precision) 'f\t' ], data(index, :));
                                fprintf(fid, '\n');
                        end
                end
                fclose(fid);
            %    disp(['<a href="matlab: open(''' binfilename ''')">' binfilename]);
%        end
catch
        serror = 1; %something went wrong
end
fprintf('\n');
