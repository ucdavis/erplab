% PURPOSE: subroutine for pop_setcodebit.m
%          sets the bit(s) at position(s) "bitindex" in each EEG.event(i).type value to 0 (off).
%          "bitindex" must contain number(s) between 1 and 16.
% 
% EEG = setcodebit(EEG, bitindex, newvalue) sets the bit(s) at position(s) "bitindex" to the value "newvalue", which must be either 0 or 1.
% 
% Example:
% In Biosemi system you have a 16-bit word for sending your event codes. However, you generally use event codes from 1 to 255
% (8-bit numbers). In this case, the upper byte (bits 9 to 16) should be silent, and these bits should be zero.
% Unfortunately, sometimes this does not happen and you get different and larger event codes.
% You may find some discussions and proposed solutions about this subject in many blogs on the internet.
% However, as a workaround, setcodebit.m will help you to control every single bit from this 16-bit word.
% Hence, you will be able to set each bit, or a group of them, to either "0" or "1", using a single line command.
% For example, if you want to assure that your event codes keep values from 1 to 255, you must set the upper byte
% (bits 9 to 16) to zero (cleaning any spuriously activated bit), using a command like the following:
% 
% EEG = setcodebit(EEG, 9:16, 0);
% 
% Note, EEG = setcodebit(EEG, 9:16);  will work as well, since "0" is the default value for "newvalue".
% 
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis
% 2011
%
% Thanks to Eric Foo for helping with testing and the help section.

function EEG = setcodebit(EEG,bitindex, newvalue)

if nargin<1
      help setcodebit
      return
end
if nargin<3
      newvalue = 0;
end
if nargin<2
      msgboxText = 'Error: setcodebit() works with 3 inputs.';
      error(msgboxText)
end
if ~isempty(EEG.epoch)
      msgboxText = 'setcodebit.m only works for continuous dataset.';
      error(msgboxText)
end
if isempty(bitindex)
      msgboxText = 'Error: you must specify one bit index, at least.';
      error(msgboxText)
else
      if isnumeric(bitindex)
            if min(bitindex)<1 || max(bitindex)>16
                  msgboxText = 'Error: bit index must be a positive integer between 1 and 16.';
                  error(msgboxText)
            end
      else
            msgboxText = 'Error: bit index must be numeric.';
            error(msgboxText)            
      end
      bitindex = unique_bc2(bitindex);      
end
if ischar(newvalue)
      msgboxText = 'Error: new value must be numeric.';
      error(msgboxText)
else
      if length(newvalue)~=1
            msgboxText = 'Error: new value must be a single value, either 0 or 1.';
            error(msgboxText)
      end
      if newvalue~=0 && newvalue~=1
            msgboxText = 'Error: new value must be a single value, either 0 or 1.';
            error(msgboxText)
      end
end
if ischar(EEG.event(1).type)
      msgboxText = 'Your event codes are not numeric.';
      error(msgboxText)
else
      currentcodes = uint16([EEG.event.type]); %numeric codes
end
nevents = length(currentcodes);
bitbase = dec2bin(0,16);
bitbase(16-bitindex+1) = '1';
bitbase = uint16(bin2dec(bitbase)); % create 16-bit mask

for i=1:nevents
    if newvalue==0 % set to zero
          EEG.event(i).type = double(bitand(currentcodes(i), bitcmp(bitbase,16)));
    else % set to one
          EEG.event(i).type = double(bitor(currentcodes(i), bitbase));
    end
end
EEG = eeg_checkset( EEG, 'eventconsistency' );
disp('Complete');