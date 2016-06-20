% PURPOSE: Removes white space from EEG alphanumeric event codes
%          Deletes non-digit character from alphanumeric even codes.
%          Converts remaining codes into numeric codes.
%          Unconvertibles event codes (non digit info at all) will be renamed as -88
%
% FORMAT:
%
% EEG = letterkilla(EEG);
%
% INPUT:
% EEG     - continous dataset with alphanumeric event codes
%
% OUTPUT
% EEG     - continous dataset with numeric event codes
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% January 25th, 2011
%
% Thanks to Erik St Louis and Lucas Dueffert for their valuable feedbacks.

function [EEG, EVENTLIST] = letterkilla2(EEG, EVENTLIST)

if nargin<1
        help letterkilla
        EVENTLIST = [];
        return
end
if nargin<2
        EVENTLIST = [];
end
nevent = length(EEG.event);
if nevent<1
        msgboxText = 'Event codes were not found!';
        title = 'ERPLAB: letterkilla() error';
        errordlg(msgboxText,title);
        return
end
fprintf('\nletterkilla() is working...\n');
EEG = wspacekiller(EEG);
detchar = 0;
for i=1:nevent
        codeaux = EEG.event(i).type;
        
        if ischar(codeaux) && ~strcmpi(codeaux, 'boundary')
                code    = regexprep(codeaux,'\D*','', 'ignorecase'); % deletes any non-digit character
                if isempty(code)
                        code = -88;
                else
                        code = str2num(code);
                end
                codelabel = codeaux;
                detchar = 1;
        else
                code = codeaux;
                codelabel = '""';
        end
        EEG.event(i).type =  code;
        if ~isempty(EVENTLIST)
                
                disp('xxx')
                EVENTLIST.eventinfo(i).code = code;
                EVENTLIST.eventinfo(i).codelabel = char(codelabel);
        end
end
if detchar
        fprintf('letterkilla() got rid of alphabetic characters from your alphanumeric event codes.\n');
        fprintf('NOTE: Event codes without any digit character, except ''boundary'', are renamed as -88 (numeric).\n\n');
else
        fprintf('letterkilla() did not detect any alphabetic characters from your event codes. This is OK.\n');
end