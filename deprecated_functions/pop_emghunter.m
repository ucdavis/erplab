%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
% Usage:
%
%   >> [EEG com] = pop_emghunter(EEG, chan, evecode, newcod, twin, thres)
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
%  See analog2code()
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

function [EEG, com] = pop_emghunter(EEG, chan, evecode, newcod, twin, thres)
com = '';
if nargin<1
        help pop_emghunter
        return
end
if isobject(EEG) % eegobj
      whenEEGisanObject % calls a script for showing an error window
      return
end
if isempty(EEG.data)
        msgboxText =  'ERROR: pop_emghunter() cannot read an empty dataset!';
        title = 'ERPLAB: pop_emghunter() error';
        errorfound(msgboxText, title);
        return
end
if ~isempty(EEG.epoch)
        msgboxText =  'pop_emghunter has been tested for continuous data only';
        title = 'ERPLAB: pop_emghunter() permission denied';
        errorfound(msgboxText, title);
        return
end

%
% Gui is working...
%
if nargin==1   
        prompt = {'channel', 'guide code','new code', 'search window (sec)', 'normalized threshold'};
        dlg_title = 'Inputs for EMG detection';
        num_lines = 1;
        
        fco = unique_bc2(cell2mat({EEG.event.type}));
        
        def = {num2str(EEG.nbchan), num2str(fco(1)), '100', '-0.5 1', '0.6'};
        answer = inputvalue(prompt,dlg_title,num_lines,def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        channel    = str2num(answer{1});
        guicode    = str2num(answer{2});
        newcode    = str2num(answer{3});
        swindow    = str2double(answer{4});
        nthresh    = str2double(answer{5});
        
        if isempty(answer{1}) || isempty(answer{2}) || isempty(answer{3}) || isempty(answer{4})...
                        || isempty(answer{5})
                disp('Error: Empty field(s) was/were found.')
                return
        end
        if length(channel)>1
                disp('Error: Please, specify only one channel for detection.')
                disp('Suggestion: You can use ERPLAB Channel Operation GUI to create a new channel.')
                return
        end
        if length(guicode)>1 && length(newcode)>1 && length(newcode)<length(guicode)
                disp('Error: The length of new code have to be either one or the same as guide code.')
                return
        end
        if length(swindow)~=2
                disp('Error: Please, specify only two values in seconds.')
                return
        end
        if nthresh>1
                disp('Error: Normalized threshold is 0-1')
                return
        end        
end











        channel    = chan;
        guicode    = evecode;
        newcode    = newcod;
        swindow    = twin;
        nthresh    = thres;

if length(guicode)>1 && length(newcode)==1
        newaux  = repmat(newcode,1,length(guicode));
        newcode = [];
        newcode = newaux;
end

%
% subroutine
%
EEG = analog2code(EEG, channel, guicode, newcode, swindow, nthresh);
EEG = eeg_checkset( EEG );
com = sprintf( '%s = pop_emghunter( %s, %s, [%s], [%s],[%s], %s);', ...
        inputname(1), inputname(1), num2str(channel), num2str(guicode),...
        num2str(newcode), num2str(swindow), num2str(nthresh));
% get history from script
if shist
        EEG = erphistory(EEG, [], com, 1);
else
        com = sprintf('%s %% %s', com, datestr(now));
        fprintf('*Equivalent command:\n%s\n\n', com);
end

eeglab redraw;

%
% Completion statement
%
msg2end
return
