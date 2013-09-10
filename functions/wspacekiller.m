% PURPOSE: Removes white space from EEG alphanumeric event codes
% 
% FORMAT:
% 
% EEG = wspacekiller(EEG, warn);
%
% INPUT:
% EEG     - continous dataset with alphanumeric event codes
% warn    - display warning. 1 means yes; o means no
% 
% OUTPUT
% EEG     - continous dataset with white-space characters removed from alphanumeric event codes
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

function EEG = wspacekiller(EEG, warn)

if nargin<1
      help wspacekiller
      return
end
if nargin<2
      warn = 1; % warning on
end
nevent = length(EEG.event);
if nevent<1
      error('ERPLAB:eventsnotfound', 'Event codes were not found!')
end
try
      for i=1:nevent
            if ischar(EEG.event(i).type)
                  EEG.event(i).type = strrep(strtrim(EEG.event(i).type),' ','');
            end
      end
catch
      if warn
            fprintf('WARNING: wspacekiller() could not clean white spaces from your event codes. Please, check event consistency...\n');
      end
end