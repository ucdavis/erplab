% DEPRECATED...Sorry
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

function [EEG, com]= pop_str2code(EEG, stringscode, numcode)
com='';
if nargin<1
        help pop_str2code
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if length(EEG)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        title = 'ERPLAB: multiple inputs';
        errorfound(msgboxText, title);
        return
end
nvar = 3;
if nargin<nvar  % using GUI
        if ~isempty(EEG)
                if ischar(EEG.event(1).type)
                        nevent = length(EEG.event);
                        icode = 0;
                        for i=1:nevent
                                capnum = str2num(EEG.event(i).type); %#ok<ST2NM>
                                if isempty(capnum)
                                        icode = icode + 1;
                                end
                        end
                        
                        question{1} = ['Your dataset contains ' num2str(icode)...
                                ' non-numeric eventcodes from ' num2str(nevent) ' total.'];
                        question{2} = 'You must have a modified Event File in order to use Binlister,';
                        question{3} = '           or you can use str2code GUI for that.';
                        question{4} = ' ';
                        question{5} = '           Do you want to use str2code GUI now ?';
                        title = 'ERPLAB: Confirmation';
                        button = askquest(question, title);
                        
                        if strcmpi(button,'no')
                                disp('User continued ahead...')
                        elseif strcmpi(button,'yes')
                                
                                [EEG, com]= str2codeGUI(EEG); %open a GUI for replacements
                                
                                if strcmp(com, '')
                                        disp('User selected Cancel')
                                        return
                                end
                                
                                com = regexprep(com,'@#@', inputname(1)); % trick to get inputname from GUI
                                EEG = eeg_checkset(EEG, 'eventconsistency');
                                EEG.setname = [EEG.setname '_s2c'];
                        else
                                disp('User selected Cancel')
                                return
                        end
                        return
                else
                        question{1} = 'Your dataset only contains numeric events';
                        question{2} = 'So, it''s not necessary to use str2code.';
                        title      = 'ERPLAB: Function str2code() does not apply';
                        errorfound(question, title);
                        return
                end
        else
                disp('ERROR: str2code cannot work with an empty EEG dataset')
                return
        end
        
else  % using scripting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~ischar(EEG.event(1).type)
                disp('Warning: str2code did not detect any string code-------------')
                return
        end
        
        nevent = length(EEG.event);
        
        for i=1:nevent
                [tf, loc] = ismember_bc2(EEG.event(i).type, stringscode);
                if tf
                        EEG.event(i).type = numcode(loc);
                else
                        capnum = str2double(EEG.event(i).type);
                        if isempty(capnum)
                                fprintf('Warning: Unfortunately string code %s was not specified.\n',...
                                        EEG.event(i).type);
                                fprintf('Warning: Luckily, ERPLAB will use code -99 instead.\n');
                                EEG.event(i).type = -99;
                        else
                                EEG.event(i).type = capnum;
                        end
                end
        end
        
        com = sprintf('%s = pop_str2code( %s, { ', inputname(1), inputname(1));
        
        for j=1:length(numcode)
                com = sprintf('%s ''%s'' ', com, stringscode{j} );
        end;
        
        newcodestr = num2str(numcode);
        com = sprintf('%s }, [%s]);', com, newcodestr);
        % get history from script
        if shist
                EEG = erphistory(EEG, [], com, 1);
        else
                com = sprintf('%s %% %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        end
end

%
% Completion statement
%
msg2end
return
