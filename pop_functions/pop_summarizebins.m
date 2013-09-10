% UNDER CONSTRUCTION
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
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

function pop_summarizebins(eventlistinputs, summaryoutput)
if nargin<2
        [eventlistinputs, elpathname] = uigetfile('*.txt','Load EventList file(s) (*.txt)',...
                'Select an edited file', ...
                'MultiSelect', 'on');
        
        if isequal(eventlistinputs,0)
                disp('User selected Cancel')
                return
        else
                if ~iscell(eventlistinputs)
                        eventlistinputs = {eventlistinputs};
                end
        end
end
nel = length(eventlistinputs);
for i=1:nel
        [Summary, detect] = summarizebins(fullfile(elpathname, eventlistinputs{i}));
        if i==1
                nbin = length(Summary);
                fields{1} = 'Subject';
                for k=1:nbin
                        fields{k+1}      = ['Bin' num2str(k)];
                        description{k}   = char(Summary(k).description);
                end
        end        
        data(i,1:nbin) = [Summary.ntrial];
end

values = num2cell(data);
q =[eventlistinputs' values];
r = [fields; q];
b = [{'Bin number','description'}; fields(2:end)' description'];
[file,path] = uiputfile('*.xls','Save Bin Summary As');
[pathstr, fxname, ext] = fileparts(file);
if ~strcmp(ext,'.xls')
        ext = '.xls';
end
fullname = fullfile(path, [fxname ext]);
warning off MATLAB:xlswrite:AddSheet
xlswrite(fullname, b, 'Bin_Descriptions', 'A1');
xlswrite(fullname, r, 'Bin_Captured', 'A1');
disp(['User saved bin summary at ' fullname]);

%
% Completion statement
%
msg2end
return


