% PURPOSE  : 	Restore messy event code values.
%                 pop_setcodebit sets the bit(s) at position(s) "bitindex" in each EEG.event(i).type value to 0 (off).
%                 "bitindex" must contain number(s) between 1 and 16.
%
% FORMAT   :
%
% EEG = pop_setcodebit(EEG, bitindex, newvalue)
%
% or
%
% pop_rt2text(ERPLAB, varargin)
%
%
% INPUTS   :
%
%    EEG           - continuous dataset
%    bitindex      - bit position(s). From 1-16
%    newvalue      - 1 or 0 (zero).
%
%
% OUTPUTS :
%
%    EEG           - updated continuous dataset%
%
%
% Example:
%
% In Biosemi system you have a 16-bit word for sending your event codes. However, you generally only use event codes from 1 to 255
% (8-bit numbers). In this case, the upper byte (bits 9 to 16) should be silent, and these bits should be zero.
% Unfortunately, sometimes this does not happen and you get different and larger event codes.
% You may find some discussions and proposed solutions about this subject in many blogs on the internet.
% However, as a general way to deal with this issue, setcodebit.m will help you to control every single bit from this 16-bit word.
% Hence, you will be able to set each bit, or a group of them, to either "0" or "1", using a single line command.
% For example, if you want to assure that your event codes keep values from 1 to 255, you must set the upper byte
% (bits 9 to 16) to zero (cleaning any spuriously activated bit), using a command like the following:
%
%
% EEG = pop_setcodebit(EEG, 9:16, 0);
%
%
% Note, EEG = pop_setcodebit(EEG, 9:16);  will work as well, since "0" is the default value for "newvalue".
%
%
% See also setcodebitGUI.m setcodebit.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011
%
% Thanks to Eric Foo for helping with testing and the help section.

function [EEG, com ] = pop_setcodebit(EEG, bitindex, newvalue, varargin)
com = '';
if nargin<1
        help setcodebit
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if ~isempty(EEG.epoch)
        msgboxText = 'pop_setcodebit.m only works for continuous dataset.';
        title = 'ERPLAB: setcodebitGUI few inputs';
        errorfound(msgboxText, title);
        return
end
if ischar(EEG.event(1).type)
        msgboxText = 'Your event codes are not numeric.';
        title = 'ERPLAB: pop_setcodebit few inputs';
        errorfound(msgboxText, title);
        return
end
if nargin==1
        % call GUI
        answer = setcodebitGUI;
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        todo =  answer{1};
        if strcmpi(todo, 'all')
                bitindex = 1:16;
                newvalue = 0;
        elseif strcmpi(todo, 'lower')
                bitindex = 1:8;
                newvalue = 0;
        elseif strcmpi(todo, 'upper')
                bitindex = 9:16;
                newvalue = 0;
        else
                if ~isempty(answer{2})
                        bitindex = answer{2};
                        newvalue = 0;
                        [EEG, com ] = pop_setcodebit(EEG, bitindex, newvalue, 'History', 'off');
                end
                if ~isempty(answer{3})
                        bitindex = answer{3};
                        newvalue = 1;
                        [EEG, com2 ] = pop_setcodebit(EEG, bitindex, newvalue, 'History', 'off');
                        com = sprintf('%s\n%s', com, com2);
                end
                return
        end
        
        %
        % Somersault
        %
        [EEG, com ] = pop_setcodebit(EEG, bitindex, newvalue, 'History', 'gui');
        return
end
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('bitindex', @isnumeric);
p.addRequired('newvalue', @isnumeric);
p.addParamValue('History', 'script', @ischar);             % history from scripting
p.parse(EEG, bitindex, newvalue, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if isempty(bitindex)
        msgboxText = 'Error: you must specify one bit index, at least.';
        title = 'ERPLAB: pop_setcodebit few inputs';
        errorfound(msgboxText, title);
        return
else
        if isnumeric(bitindex)
                if min(bitindex)<1 || max(bitindex)>16
                        msgboxText = 'Error: bit index must be a positive integer between 1 and 16.';
                        title = 'ERPLAB: setcodebitGUI few inputs';
                        errorfound(msgboxText, title);
                        return
                end
        else
                msgboxText = 'Error: bit index must be numeric.';
                title = 'ERPLAB: pop_setcodebit few inputs';
                errorfound(msgboxText, title);
                return
        end
        bitindex = unique_bc2(bitindex);
end
if ischar(newvalue)
        msgboxText = 'Error: new value must be numeric.';
        title = 'ERPLAB: setcodebitGUI few inputs';
        errorfound(msgboxText, title);
        return
else
        if length(newvalue)~=1
                msgboxText = 'Error: new value must be a single value, either 0 or 1.';
                title = 'ERPLAB: pop_setcodebit few inputs';
                errorfound(msgboxText, title);
                return
        end
        if newvalue~=0 && newvalue~=1
                msgboxText = 'Error: new value must be a single value, either 0 or 1.';
                title = 'ERPLAB: pop_setcodebit few inputs';
                errorfound(msgboxText, title);
                return
        end
end

EEG = setcodebit(EEG, bitindex, newvalue);

% History
bitindexstr = vect2colon(bitindex);
newvalue    = vect2colon(newvalue);
com = sprintf('%s = pop_setcodebit( %s, %s, %s);', inputname(1), inputname(1), bitindexstr, newvalue);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
                % EEG = erphistory(EEG, [], com, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', com);
        otherwise %off or none
                com = '';
                return
end

%
% Completion statement
%
msg2end
return