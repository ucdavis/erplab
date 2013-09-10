% DEPRECATED...SORRY.
%
%
%
% PURPOSE  :	The purpose of this function is to allow multiple dataset loading,
%               while user is working on the EEGLAB GUI. Do not use this function
%               in scripting. Use pop_loadset() with a for loop instead.
%
% FORMAT   :
%
% >> [ALLEEG EEG CURRENTSET] = pop_loadmerplabset(ALLEEG, EEG)
%
% EXAMPLE  :
%
% >> [ALLEEG EEG CURRENTSET] = pop_loadmerplabset(ALLEEG, EEG)  -gui will apear
%
% INPUTS   :
%
% ALLEEG         - ALLEEG structure (containing EEG structures)
% EEG            - EEG structure
%
% OUTPUTS
%
% ERP            - output ERPset
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

function [ALLEEG, EEG, CURRENTSET, com] = pop_loadmerplabset(ALLEEG, EEG)
com = '';
CURRENTSET = 0;
if nargin==2
        version = geterplabversion;
        [filename, pathname] = uigetfile('*.set',['ERPLAB BETA ' version '  Load multiples datasets -- pop_loadmerplabset()'], ...
                'Load multiples bin epoched datasets -- pop_loadmerplabset()', ...
                'MultiSelect', 'on');
        
        if isequal(filename,0)
                disp('User selected Cancel')
                return
        end
        if iscell(filename)
                nfile = length(filename);
                inputfname = filename;
        else
                nfile = 1;
                inputfname{1} = filename;
        end
        inputpath = pathname;
else
        disp('Error: pop_loadmerplabset() needs  2 input')
        return
end
try
        for i=1:nfile
                EEG = pop_loadset( 'filename', inputfname{i}, 'filepath', inputpath);
                EEG = eeg_checkset(EEG);
                xfilename = EEG.filename;
                xfilepath = EEG.filepath;
                [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
                ALLEEG(i).filename = xfilename;
                ALLEEG(i).filepath = xfilepath;
                ALLEEG = eeg_checkset(ALLEEG);
        end
        com = sprintf('[%s %s CURRENTSET com] = pop_loadmerplabset(%s, %s);',...
                inputname(1), inputname(2), inputname(1),inputname(2));
        com = sprintf('%s %% %s', com, datestr(now));
catch
        msgboxText{1} =  sprintf('Your dataset %s is not compatible at all with the current ERPLAB version',EEG.filename);
        msgboxText{2} =  'Please, try upgrading your EVENTLIST structure.';
        title = 'ERPLAB: pop_loadmerplabset() Error';
        errorfound(msgboxText, title);
        return
end

%
% Completion statement
%
msg2end