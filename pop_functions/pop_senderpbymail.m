% PURPOSE  : Sends ERPset(s) (from ERPset menu) by email
%
% FORMAT   :
%
% pop_senderpbymail(ALLERP, erpindex, mailto, subject, message, attach)
%
%
% INPUTS     :
%
%         ALLERP            - structure array of ERP structures (ERPsets)
%         erpindex          - index(ices) of ERPset(s) to be attached.
%         mailto            - email address(es) to be receiver(s).
%         subject           - email's subject
%         message           - email's message
%
%
% OUTPUTS
%
%       email
%
%
% EXAMPLE :
%
% pop_senderpbymail(ALLERP,1, {'javlopez@ucdavis.edu'}, 'You got an ERPmail!', {'/Matlab/eeglab11_0_4_2b/plugins/erplab_3.0.2.2/erplab_Box/Perro-08_atmenu_1.zip'});
%
% See also sendemailGUI.m sendmail.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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
function [ALLERP, erpcom] = pop_senderpbymail(ALLERP, varargin)
erpcom = '';
if nargin==1
        try
                if isempty(getpref('Internet','SMTP_Username')) || isempty(getpref('Internet','SMTP_Password'))
                        msgboxText = ['You have not set neither your gmail nor your yahoo email account to use this tool.\n\n'...
                                'Please, go to Utilities menu, Set Gmail or Yahoo email account'];
                        title = 'ERPLAB: pop_senderpbymail requieres an email account';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        catch
                addpref('Internet','SMTP_Username', [])
                addpref('Internet','SMTP_Password', [])
                msgboxText = ['You have not set neither your gmail nor your yahoo email account to use this tool.\n\n'...
                        'Please, go to Utilities menu, Set Gmail or Yahoo email account'];
                title = 'ERPLAB: pop_senderpbymail requieres an email account';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if isempty(ALLERP)
                msgboxText =  'No ERPset was found!';
                title_msg  = 'ERPLAB: pop_senderpbymail() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        def = erpworkingmemory('sendemailGUI');
        if isempty(def)
                def = {'','You got an ERPmail!', 1};
        end
        
        %
        % Call GUI
        %
        answer  = sendemailGUI(def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        mailto   = answer{1};
        subject  = answer{2};
        msg      = answer{3};
        erpindex = answer{4}; % numeric
        
        erpworkingmemory('sendemailGUI', {mailto, subject, erpindex});
        
        %
        % Somersault
        %
        [ALLERP, erpcom] = pop_senderpbymail(ALLERP, 'Erpsets', erpindex, 'Mailto', mailto, 'Subject', subject, 'Message', msg, 'History', 'gui');
        return
end

%
% Parsing inputs
%
defmsg = {sprintf('...sent from ERPLAB.\n\n')};
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
p.addParamValue('Erpsets', [], @isnumeric);
p.addParamValue('Mailto', '');
p.addParamValue('Subject', 'ERPmail');
p.addParamValue('Message', defmsg);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ALLERP, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
erpindex = p.Results.Erpsets;
mailto   = p.Results.Mailto;
subject  = p.Results.Subject;
message  = p.Results.Message;

if isempty(getpref('Internet','SMTP_Username')) || isempty(getpref('Internet','SMTP_Password'))
        error('prog:input','ERPLAB says: You have not set neither your gmail nor your yahoo email account to use this tool.\n\nPlease, go to Utilities menu, Set Gmail or Yahoo email account');
end
if ~isempty(erpindex)
        p = which('eegplugin_erplab', '-all');
        if length(p)>1
                fprintf('\nERPLAB WARNING: More than one ERPLAB folder was found.\n\n');
        end
        p = p{1};
        p = p(1:findstr(p,'eegplugin_erplab.m')-1);
        pathname = fullfile(p,'erplab_Box'); % path for temporary storage
        
        if exist(pathname, 'dir')~=7
                mkdir(pathname);  % Thanks to Johanna Kreither. Jan 31, 2013
        end
        erpindex = unique_bc2(erpindex);
        nerpset  = length(erpindex);
        
        for i=1:nerpset
                erpname  = ALLERP(erpindex(i)).erpname;
                filename = ALLERP(erpindex(i)).filename;
                if isempty(filename)
                        filename = [erpname '_atmenu_' num2str(erpindex(i))];
                else
                        filename = strtrim(filename);
                        [pxxx, filename] = fileparts(filename) ; % w/o extension
                end
                pop_savemyerp(ALLERP(erpindex(i)), 'erpname', erpname, 'filename', [filename '.erp'], 'filepath', pathname, 'warning', 'off', 'History', 'off');
                pause(0.1)
                attach{i} = fullfile(pathname,[filename '.zip']);
                fprintf('Zipping %s....\n', [filename '.zip']);
                zip(attach{i}, [filename '.erp']);
                pause(0.1)
        end
else
        attach = [];
end

fprintf('Sending e-mail....\n\n');
trycount = 1;
while trycount<=3
        try
                sendmail(mailto,subject,message,attach)
                break
        catch
                pause(2)
                trycount = trycount + 1;
                fprintf('attempt #%g out of 3...please wait. \n', trycount);
        end
end
if trycount>3
        smtps = getpref('Internet','SMTP_Server');
        msgboxText = ['Oops! ERPLAB could not make %s server to work.\n\n'...
                'So, you may try again or, if this problem persists, try moving to another internet connection. '...
                'or set another email account.'];
        title = 'ERPLAB: pop_senderpbymail not working';
        errorfound(sprintf(msgboxText, smtps), title);
        return
else
        fprintf('\nYour email was sent successfully!.\n');
end

%
% Completion statement
%
msg2end

% if iscell(mailto)
%         mailtostr = char(mailto{1});
% end
% if iscell(attach)
%         attachstr = char(attach{1});
% end
% if isempty(attach)
%         erpcom = sprintf('pop_senderpbymail(%s, %s, {''%s''}, ''%s'');', inputname(1), vect2colon(erpindex), mailtostr, subject);
% else
%         erpcom = sprintf('pop_senderpbymail(%s, %s, {''%s''}, ''%s'', {''%s''});', inputname(1), vect2colon(erpindex), mailtostr, subject, attachstr);
% end
skipfields = {'ALLERP', 'History','History'};
if length(erpindex)==1 && erpindex==1
        DATIN = 'ERP';
        skipfields = [skipfields, 'Erpsets'];
else
        DATIN =  inputname(1);
end
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_senderpbymail( %s ', DATIN, DATIN);
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        if ischar([fn2res{:}])
                                                fn2resstr = sprintf('''%s'' ', fn2res{:});
                                        else
                                                fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        end
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                if strcmpi(fn2com,'Criterion')
                                        if p.Results.Criterion<100
                                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                        end
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                for i=1:length(ALLERP)
                        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
                end
        case 3
                % implicit
                %for i=1:length(ALLERP)
                %        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
                %end
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end
return




