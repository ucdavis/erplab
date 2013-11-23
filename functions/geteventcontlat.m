% Under construction...(alpha version)
%
%
% By Javier Lopez-Calderon
%
function indxevcode = geteventcontlat(EEG, evcode)

if nargin<1
      help geteventcontlat
      return
end
if nargin<2
      if ischar(EEG.event(1).type)
            evcode = unique_bc2({EEG.event.type}); %strings
      else
            evcode = unique_bc2([EEG.event.type]); %numeric code
      end
end
if isempty(evcode)
      if ischar(EEG.event(1).type)
            evcode = unique_bc2({EEG.event.type}); %strings
      else
            evcode = unique_bc2([EEG.event.type]); %numeric code
      end
end
if length(EEG)>1
      msgboxText =  'Unfortunately, this function does not work with multiple datasets';
      error(msgboxText)
end
if ~isempty(EEG.epoch)
      msgboxText =  'geteventcontlat() only works for continuous datasets.';
      error(msgboxText)
end
if ischar(EEG.event(1).type)
      codebound = {EEG.event.type}; %cellstrings
else
      codebound = [EEG.event.type]; %numeric code
end

%
% search for boundaries
%
indxevcode = [];
necode = length(evcode);

if iscell(evcode)
      if ischar(evcode{1}) % evcode is char
            if iscell(codebound) % string % string
                  for s=1:necode
                        indxevcode  = [indxevcode strmatch(evcode(s), codebound, 'exact')'];
                  end
            else  % string % numeric
                  for s=1:necode
                        numt = str2num(evcode{s});
                        if ~isempty(numt)
                              indxevcode  =  [indxevcode find(codebound==numt)];
                        else
                              msgboxText = 'You specified a string as event code, but your events are numeric.';
                              title = 'ERPLAB: evcode format error';
                              errorfound(msgboxText, title);
                              return
                        end
                  end
            end
      else % evcode is numeric
            if iscell(codebound) % number & string
                  for s=1:necode
                        indxevcode  =  [ indxevcode strmatch({num2str(evcode{s})}, codebound, 'exact')'];
                  end
            else % number & number
                  for s=1:necode
                        indxevcode  =  [indxevcode find(codebound==evcode(s))];
                  end
            end
      end
else
      if ischar(evcode) && iscell(codebound)
            for s=1:necode
                  indxevcode  = [indxevcode strmatch(evcode(s), codebound, 'exact')'];
            end
      elseif ~ischar(evcode) && ~iscell(codebound)
            for s=1:necode
                  indxevcode  =  [indxevcode find(codebound==evcode(s))];
            end
      elseif ischar(evcode) && ~iscell(codebound)
            for s=1:necode
                  numt = str2num(evcode(s));
                  if ~isempty(numt)
                        indxevcode  =  [indxevcode find(codebound==numt)];
                  else
                        msgboxText = 'You specified a string as event code, but your events are numeric.';
                        title = 'ERPLAB: evcode format error';
                        errorfound(msgboxText, title);
                        return
                  end
            end
      elseif ~ischar(evcode) && iscell(codebound)
            for s=1:necode
                  indxevcode  =  [ indxevcode strmatch(num2str(evcode(s)), codebound, 'exact')'];
            end
      end
end

indxevcode = unique_bc2(indxevcode);