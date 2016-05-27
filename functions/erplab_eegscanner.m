% erplab_eegscanner
%
% PURPOSE: checks EEG dataset according to set of criteria
% Format:
% serror = erplab_eegscanner(EEG, funcname, chckmultieeg, chckemptyeeg, chckepocheeg, chckeventlist)
%
% Inputs:
%
% EEG           - EEGLAB dataset
% funcname      - function name that calls erplab_eegscanner.
%
% Criteria:
% chckmultieeg  = check for multiple dataset (md).    0= do not accept md;    1=accept only md;  2=do not care
% chckemptyeeg  = check for empty dataset (ed).       0= do not accept ed;    1=accept only ed;  2=do not care
% chckepocheeg  = check for epoched dataset (epd).    0= do not accept epd;   1=accept only epd; 2=do not care
% chcknoevents  = check for no event codes (ev).      0= do not accept if no event   1=accept if no events; 
% chckeventlist = check for EVENTLIST structure (ES). 0= do not accept ES;    1=accept only ES;  2=do not care
%
% Option (parameter-value)
%
% 'ErrorMsg'   - 'popup': display popup window with error message when criteria are not met
%              - 'error': display error message (command window) when criteria are not met
%              - 'off'  ; % do not display error msg (just get outcome through "serror")
%
%
% Output:
% serror        - 0 means Ok.no problem found. 1 means criteria were not met.
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function serror = erplab_eegscanner(EEG, funcname, chckmultieeg, chckemptyeeg, chckepocheeg, chcknoevents, chckeventlist, varargin)

serror = 0; % no problem by default
if nargin<1
        help erplab_eegscanner
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('funcname',@ischar);
p.addRequired('chckmultieeg', @isnumeric);
p.addRequired('chckemptyeeg', @isnumeric);
p.addRequired('chckepocheeg', @isnumeric);
p.addRequired('chcknoevents', @isnumeric);
p.addRequired('chckeventlist',@isnumeric);
% Parameters
p.addParamValue('ErrorMsg', 'popup', @ischar);
p.parse(EEG, funcname, chckmultieeg, chckemptyeeg, chckepocheeg, chcknoevents, chckeventlist, varargin{:});

if strcmpi(p.Results.ErrorMsg, 'popup') || strcmpi(p.Results.ErrorMsg, 'on')
        errormsg = 1; % popup window with error message
elseif strcmpi(p.Results.ErrorMsg, 'error')
        errormsg = 2;       % error message
else % off
        errormsg = 0; % do not display error msg
end

title = sprintf('ERPLAB: Error at %s', funcname);
N = length(EEG);
if chckmultieeg==0 && N>1
        serror = 1;
        msgboxText =  'Unfortunately, %s does not work with multiple datasets';
        if errormsg==1
                errorfound(sprintf(msgboxText, funcname), title);
                return
        elseif errormsg==2
                error('prog:input', msgboxText, funcname)
        end
        return
end
if chckmultieeg==1 && N<2
        serror = 1;
        msgboxText =  'Unfortunately, %s only works with multiple datasets';
        if errormsg==1
                errorfound(sprintf(msgboxText, funcname), title);
                return
        elseif errormsg==2
                error('prog:input', msgboxText, funcname)
        end
        return
end

for k=1:N
        if chckemptyeeg==0 && isempty(EEG(k).data)
                msgboxText =  '%s cannot read an empty dataset!';
                serror = 1;
                break
        end
        if chckemptyeeg==1 && ~isempty(EEG(k).data)
                msgboxText =  '%s only works with empty dataset(s)';
                serror = 1;
                break
        end
        if chckepocheeg==0 && ~isempty(EEG(k).epoch)
                msgboxText =  '%s only works with continuous data';
                serror = 1;
                break
        end
        if chckepocheeg==1 && isempty(EEG(k).epoch)
                msgboxText =  '%s only works with epoched data';
                serror = 1;
                break
        end        
        if chcknoevents==0 && isempty(EEG(k).event)
                msgboxText =  '%s : There is not event codes in this dataset!';
                serror = 1;
                break
        end
        if chcknoevents==1 && ~isempty(EEG(k).event)
                msgboxText =  '%s : This dataset has event codes already!';
                serror = 1;
                break
        end        
        if chckeventlist~=2
                if isfield(EEG(k), 'EVENTLIST')
                        if chckeventlist==1 % accept only
                                if isempty(EEG(k).EVENTLIST)
                                        msgboxText = '%s : EEG.EVENTLIST structure is empty!';
                                        serror = 1;
                                        break
                                end
                                if isfield(EEG(k).EVENTLIST, 'eventinfo')
                                        if chckeventlist==1 && isempty(EEG(k).EVENTLIST.eventinfo)
                                                msgboxText = '%s : EVENTLIST.eventinfo structure is empty!';
                                                serror = 1;
                                                break
                                        end
                                else
                                        msgboxText =  '%s : EVENTLIST.eventinfo structure was not found!';
                                        serror = 1;
                                        break
                                end
                        else % do not accept EVENTLIST
                                if ~isempty(EEG(k).EVENTLIST)
                                        msgboxText = '%s does not work with EEG.EVENTLIST structure.';
                                        serror = 1;
                                        break
                                end
                        end
                else
                        if chckeventlist==1 % accept only
                                msgboxText =  '%s : EVENTLIST structure was not found!';
                                serror = 1;
                                break
                        end
                end
        end
end
if serror>0
        if errormsg==1
                errorfound(sprintf(msgboxText, funcname), title);
                return
        elseif errormsg==2
                error('prog:input', ['ERPLAB says: ' msgboxText], funcname)
        end
end
return
