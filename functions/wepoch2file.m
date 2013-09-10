% UNDER CONSTRUCTION...
%
% 
% Write epoch indices into a file.
%
% wepoch2file(filename, epocharray, acolon, overw)
% 
% filename    - full name of the file to write the epoch indices to average
% epocharray  - epoch indices to average (numeric)
% acolon      - enable colon notation: 1=yes; 0=no
% overw       - overwrite a file with the same name: 1=overwrite; 0=append

% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

function wepoch2file(filename, epocharray, acolon, overw)

if ~iscell(epocharray)
      error('ERPLAB says: epocharray must be a cell array.')
end
if nargin<3
        acolon = 0;
end
if nargin<4
        overw = 0;
end
if overw==0
        fid_values  = fopen(filename, 'a'); %append
        fseek(fid_values, 0, 'eof');
else
        fprintf('Creating 1 text output file...\n');
        fid_values  = fopen(filename, 'w'); % overwrite
end

nrow = size(epocharray, 1);

for k=1:nrow
        if acolon==0
                formstr = '%g\t';
                %numcell = num2cell(epocharray(k,:));
                numcell = epocharray(k,:);
        else
                formstr = '%s\t';
                numstring = vect2colon([epocharray{k,:}], 'Delimiter', 'off');
                numcell   = regexp(numstring, '\s*','split');
                numcell   = numcell(~cellfun(@isempty, numcell));
        end
        ncell     = length(numcell);        
        m=1;        
        while m<=ncell
                fprintf(fid_values, formstr, numcell{m});                
                if mod(m,10)==0
                        fprintf(fid_values,'\n');
                end
                m=m+1;
        end
        if mod(m-1,10)==0
                fprintf(fid_values,';\n');
        else
                fprintf(fid_values,'\n;\n');
        end        
end
fclose(fid_values);
