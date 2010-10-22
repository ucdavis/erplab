%
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

function  [acce rej histoflags erpcom] = pop_summary_AR_erp_detection(ERP, fullname)

erpcom     = '';
acce = [];
rej  = [];
histoflags = [];

if nargin<1
        help erp_summary_AR_detection
        return
end
if isempty(ERP)
        msgboxText =  'pop_summary_AR_erp_detection() cannot work with an empty erpset.';
        title = 'ERPLAB: pop_summary_AR_erp_detection error';
        errorfound(msgboxText, title);
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

if nargin==1

        BackERPLABcolor = [1 0.9 0.3];    % ERPLAB main window background
        question{1} = 'In order to see your summary, What would you like to do?';
        title = 'Artifact detection summary';
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
                        [px, fname, ext, versn] = fileparts(filename);

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

                        %fidsumm   = fopen( fullname , 'w');

                        %for i=1:size(fulltext,1)-1
                        %        fprintf(fid_list,'%s\n', fulltext(i,:));
                        %end

                        %fclose(fid_list);
                end

        elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                disp('User selected Cancel')
                return
        end
else
        if nargin>2
                error('ERPLAB says: pop_summary_AR_eeg_detection error -> too many inputs')
        end
end

if isempty(strtrim(fullname))
        fidsumm   = 1; % to command window
else
        fidsumm   = fopen( fullname , 'w'); % to a file
end

%
% Flags' histogram  (bin x flag)
%
histoflags = fliplr(ERP.ntrials.arflags);

%
% Table
%
hdr = {'Bin' '#(%) accepted' '#(%) rejected' '# F2' '# F3' '# F4' '# F5' '# F6' '# F7' '# F8' };
fprintf(fidsumm, '%s %15s %15s %7s %7s %7s %7s %7s %7s %7s\n', hdr{:});

s = warning('off','MATLAB:divideByZero');

rej   = ERP.ntrials.rejected;
acce  = ERP.ntrials.accepted;
pacce = (acce./(rej+acce))*100;
prej  = 100-pacce;

for i=1:ERP.nbin
        paccestr{i} = sprintf('%.1f', pacce(i));
        prejstr{i}  = sprintf('%.1f', prej(i));
        fprintf(fidsumm, '%g  %9g(%5s) %8g(%5s) %7g %7g %7g %7g %7g %7g %7g\n', i,acce(i), paccestr{i}, rej(i), prejstr{i}, histoflags(i,2:8));
end

trej   = sum(rej);
tacce  = sum(acce);
tpacce = (tacce/(tacce+trej))*100;
tprej  = 100-tpacce;

tpaccestr = sprintf('%.1f', tpacce);
tprejstr  = sprintf('%.1f', tprej);

thistoflags = sum(histoflags,1);
fprintf(fidsumm, [repmat('_',1,100) '\n']);
fprintf(fidsumm, 'Total %6g(%5s) %8g(%5s) %7g %7g %7g %7g %7g %7g %7g\n', tacce, tpaccestr, trej, tprejstr, thistoflags(2:8));

if fidsumm>1
        fclose(fidsumm);
        erpcom = sprintf('pop_summary_AR_erp_detection(ERP, ''%s'');', fullname);
else
        erpcom = sprintf('pop_summary_AR_erp_detection(ERP);');
end

warning(s)  % restore state
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end 
return