% PURPOSE  : 	Create table of ERP artifact detection summary
%
% FORMAT   :
%
% Pop_summary_AR_erp_detection(ERP, fname);
%
% EXAMPLE  :
%
% Pop_summary_AR_erp_detection(ERP, 'C:\Users\Work\Documents\MATLAB\test.txt');
%
%
% INPUTS   :
%
% Fname    	- File name and path
%
% OUTPUTS  :
%
% Text file with saved ERP artifact detection summary table
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

function  [ERP, acce, rej, histoflags, erpcom] = pop_summary_AR_erp_detection(ERP, fullname, varargin)
erpcom = '';
acce   = [];
rej    = [];
histoflags = [];

if nargin<1
        help erp_summary_AR_detection
        return
end
if nargin==1
        if isempty(ERP)
                msgboxText =  'No ERPset was found!';
                title_msg  = 'ERPLAB: pop_summary_AR_erp_detection() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if ~isfield(ERP, 'bindata')
                msgboxText =  'pop_summary_AR_erp_detection() cannot work with an empty erpset.';
                title = 'ERPLAB: pop_summary_AR_erp_detection error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(ERP.bindata)
                msgboxText =  'pop_summary_AR_erp_detection() cannot work with an empty erpset.';
                title = 'ERPLAB: pop_summary_AR_erp_detection error';
                errorfound(msgboxText, title);
                return
        end
        BackERPLABcolor = [1 0.9 0.3];    % ERPLAB main window background
        question = 'In order to see your summary, What would you like to do?';
        title    = 'Artifact detection summary';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(question, title,'Save in a file','Show at Command Window', 'Cancel','Show at Command Window');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        
        if strcmpi(button,'Show at Command Window')
                fullname = '';
        elseif strcmpi(button,'Save in a file')
                
                %
                % Save OUTPUT file
                %
                [filename, filepath, filterindex] = uiputfile({'*.txt';'*.dat';'*.*'},'Save Artifact Detection Summary as', ['AR_summary_' ERP.erpname]);
                
                if isequal(filename,0)
                        disp('User selected Cancel')
                        return
                else
                        [px, fname, ext] = fileparts(filename);
                        
                        if strcmp(ext,'')
                                
                                if filterindex==1 || filterindex==3
                                        ext   = '.txt';
                                else
                                        ext   = '.dat';
                                end
                        end
                        
                        fname = [ fname ext];
                        fullname = fullfile(filepath, fname);
                        disp(['For saving artifact detection summary, user selected <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
                        
                end
        elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                disp('User selected Cancel')
                return
        end
        
        %
        % Somersault
        %
        [ERP, acce, rej, histoflags, erpcom] = pop_summary_AR_erp_detection(ERP, fullname, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('fullname', @ischar);
% option(s)
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERP, fullname, varargin{:});

if isempty(ERP)
        msgboxText =  'No ERPset was found!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if ~isfield(ERP, 'bindata')
        msgboxText =  'pop_summary_AR_erp_detection() cannot work with an empty erpset.';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if isempty(ERP.bindata)
        msgboxText =  'pop_summary_AR_erp_detection() cannot work with an empty erpset.';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
% if isempty(strtrim(fullname))
%         fidsumm   = 1; % to command window
% else
%         fidsumm   = fopen( fullname , 'w'); % to a file
% end
if isempty(strtrim(fullname))
        fidsumm   = 1; % to command window
else
        if strcmpi(strtrim(fullname), 'none')
                fidsumm = -99;
        else
                fidsumm   = fopen( fullname , 'w'); % to a file
        end
end

%
% Flags' histogram  (bin x flag)
%
histoflags = fliplr(ERP.ntrials.arflags);

%
% Table
%
if fidsumm~=-99
        hdr = {'Bin' '#(%) accepted' '#(%) rejected' '# F2' '# F3' '# F4' '# F5' '# F6' '# F7' '# F8' };
        fprintf(fidsumm, '%s %15s %15s %7s %7s %7s %7s %7s %7s %7s\n', hdr{:});
end
s = warning('off','MATLAB:divideByZero');
rej   = ERP.ntrials.rejected;
acce  = ERP.ntrials.accepted;
pacce = (acce./(rej+acce))*100; % percentage of accepted trials by bin
prej  = 100-pacce;

if fidsumm~=-99
        for i=1:ERP.nbin
                paccestr{i} = sprintf('%.1f', pacce(i));
                prejstr{i}  = sprintf('%.1f', prej(i));
                fprintf(fidsumm, '%g  %9g(%5s) %8g(%5s) %7g %7g %7g %7g %7g %7g %7g\n', i,acce(i), paccestr{i}, rej(i), prejstr{i}, histoflags(i,2:8));
        end
end
trej   = sum(rej);
tacce  = sum(acce);
tpacce = (tacce/(tacce+trej))*100; % mean percentage of accepted trials
tprej  = 100-tpacce; % this is MPD

if fidsumm~=-99
        tpaccestr = sprintf('%.1f', tpacce);
        tprejstr  = sprintf('%.1f', tprej);
        thistoflags = sum(histoflags,1);
        fprintf(fidsumm, [repmat('_',1,100) '\n']);
        fprintf(fidsumm, 'Total %6g(%5s) %8g(%5s) %7g %7g %7g %7g %7g %7g %7g\n', tacce, tpaccestr, trej, tprejstr, thistoflags(2:8));
end
if fidsumm>1
        fclose(fidsumm);
        erpcom = sprintf('pop_summary_AR_erp_detection(ERP, ''%s'');', fullname);
else
        erpcom = sprintf('pop_summary_AR_erp_detection(ERP);');
end

warning(s)  % restore state

% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
                %ERP = erphistory(ERP, [], erpcom, 1);
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end
%
% Completion statement
%
msg2end
return