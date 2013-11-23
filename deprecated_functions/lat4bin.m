% DEPRECATED...
%
%

function [latsam latsec] = lat4bin(EEG, varargin)
latsam=[]; latsec=[];
if nargin<1
      help lat4bin
      return
end
if nargin<2
      error('ERPLAB says: lat4bin works with 2 inputs.')
end
if ~isempty(EEG.epoch)
      msgboxText =  'lat4bin() only works with continuous data after creating EVENTLIST.';
      title = 'ERPLAB: lat4bin error';
      errorfound(msgboxText, title);
      return
end
if isfield(EEG, 'EVENTLIST')
      if isfield(EEG.EVENTLIST, 'eventinfo')
            if isempty(EEG.EVENTLIST.eventinfo)
                  msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                        'Use Create EVENTLIST before BINLISTER'];
                  title = 'ERPLAB: Error at lat4bin()';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
      else
            msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
                  'Use Create EVENTLIST before BINLISTER'];
            title = 'ERPLAB: Error at lat4bin()';
            errorfound(sprintf(msgboxText), title);
            return
      end
else
      msgboxText =  ['EVENTLIST structure was not found!\n'...
            'Use Create EVENTLIST before BINLISTER'];
      title = 'ERPLAB: Error at lat4bin()';
      errorfound(sprintf(msgboxText), title);
      return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG', @isstruct);

p.addParamValue('type', []);
p.addParamValue('duration', [], @isnumeric);
p.addParamValue('codelabel', '', @ischar);

p.addParamValue('flag', [], @isnumeric);
p.addParamValue('bini', [], @isnumeric);
p.addParamValue('binlabel', '', @ischar);
p.addParamValue('enable', [], @isnumeric);
p.addParamValue('item', [], @isnumeric);

p.parse(EEG,  varargin{:});

xtype      = p.Results.type;
xduration  = p.Results.duration;
xcodelabel = p.Results.codelabel;
xflag      = p.Results.flag;
xbini      = p.Results.bini;
xbinlabel  = p.Results.binlabel;
xenable    = p.Results.enable;
xitem      = p.Results.item;

neegevent  = length(EEG.event);
indx4type  = []; indx4duration = []; indx4enable = []; indx4codelabel = []; indx4bini=[]; indx4flag = [];

if (~isempty(xtype) || ~isempty(xduration)) && (isempty(xcodelabel)  &&...
            isempty(xflag)  && isempty(xbini)  && isempty(xbinlabel)  && isempty(xenable) && isempty(xitem))
      %
      % type:  search for events based on type value
      %
      if ~isempty(xtype)
            indx4type = geteventcontlat(EEG, xtype);
      end
      %
      % duration:  search for events based on duration value
      %
      if ~isempty(xduration)
            if isfield(EEG.event,'duration')
                  % In case there are empty values at EEG.enable
                  duration  = {EEG.event.duration};
                  empindx = find(cellfun(@isempty, duration));
                  [duration{empindx}] = deal(0);% default value if it is empty
            else
                  % if EEG.enable does not existe it will be full filled with 1s
                  duration = num2cell(zeros(1,neegevent));
            end
            [EEG.event(1:neegevent).duration] = duration{:};
            duridx = [EEG.event.duration];
            for s=1:length(xduration)
                  indx4duration  =  [indx4duration find(duridx==xduration(s))];
            end
            if ~isempty(indx4duration)
                  indx4duration = unique_bc2(indx4duration);
            end
      end
else
      %
      % check for the presence of EVENTLIST structure
      %
      if isfield(EEG, 'EVENTLIST')
            if isfield(EEG.EVENTLIST, 'eventinfo')
                  if isempty(EEG.EVENTLIST.eventinfo)
                        msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                              'Use Create EVENTLIST before BINLISTER'];
                        title = 'ERPLAB: Error at lat4bin()';
                        errorfound(sprintf(msgboxText), title);
                        return
                  end
            else
                  msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
                        'Use Create EVENTLIST before BINLISTER'];
                  title = 'ERPLAB: Error at lat4bin()';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
      else
            msgboxText =  ['EVENTLIST structure was not found!\n'...
                  'Use Create EVENTLIST before BINLISTER'];
            title = 'ERPLAB: Error at lat4bin()';
            errorfound(sprintf(msgboxText), title);
            return
      end
end
%
% enable:  search for events based on enable value
%
if ~isempty(xenable)
      if isfield(EEG.EVENTLIST.eventinfo,'enable')
            % In case there are empty values at EEG.enable
            enable  = {EEG.EVENTLIST.eventinfo.enable};
            empindx = find(cellfun(@isempty, enable));
            [enable{empindx}] = deal(1);% default value if it is empty
      else
            % if EEG.enable does not existe it will be full filled with 1s
            enable = num2cell(ones(1,neegevent));
      end
      
      [EEG.EVENTLIST.eventinfo(1:neegevent).enable] = enable{:};
      enidx = [EEG.EVENTLIST.eventinfo.enable];
      for s=1:length(xenable)
            indx4enable  =  [indx4enable find(enidx==xenable(s))];
      end
      if ~isempty(indx4enable)
            indx4enable = unique_bc2(indx4enable);
      end
end
%
% codelabel:  search for events based on code label
%
if ~isempty(xcodelabel)
      if isfield(EEG.EVENTLIST.eventinfo,'codelabel')
            % In case there are empty values at EEG.enable
            codelabel  = {EEG.EVENTLIST.eventinfo.codelabel};
            empindx = find(cellfun(@isempty, codelabel));
            [codelabel{empindx}] = deal('edit');% default value if it is empty
      else
            % if EEG.enable does not existe it will be full filled with 1s
            codelabel = repmat({'edit'},1, neegevent);
      end
      
      [EEG.EVENTLIST.eventinfo(1:neegevent).codelabel] = codelabel{:};
      clidx = [EEG.EVENTLIST.eventinfo.codelabel];
      for s=1:length(xcodelabel)
            indx4codelabel  =  [indx4codelabel find(clidx==xcodelabel(s))];
      end
      if ~isempty(indx4codelabel)
            indx4codelabel = unique_bc2(indx4codelabel);
      end
end
%
% bini:  search for events based on bin index
%
if ~isempty(xbini)
      bini = {EEG.EVENTLIST.eventinfo.bini};
      nb = length(bini);
      for s=1:length(xbini)
            for b=1:nb
                  if ismember_bc2(xbini(s), [bini{b}]);
                        indx4bini = [indx4bini b];
                  end
            end
      end
      if ~isempty(indx4bini)
            indx4bini = unique_bc2(indx4bini);
      end
end
%
% flag:  search for events based on flag values
%
if ~isempty(xflag)
      if isfield(EEG.EVENTLIST.eventinfo,'flag')
            % In case there are empty values at EEG.enable
            flag  = {EEG.EVENTLIST.eventinfo.flag};
            empindx = find(cellfun(@isempty, flag));
            [flag{empindx}] = deal(0);% default value if it is empty
      else
            % if EEG.enable does not existe it will be full filled with 1s
            flag = num2cell(zeros(1,neegevent));
      end
      
      [EEG.EVENTLIST.eventinfo(1:neegevent).flag] = flag{:};
      flgidx = [EEG.EVENTLIST.eventinfo.flag];
      for s=1:length(xflag)
            indx4flag  =  [indx4flag find(flgidx==xflag(s))];
      end
      if ~isempty(indx4flag)
            indx4flag = unique_bc2(indx4flag);
      end
end

indx4type  
indx4duration 
indx4enable 
indx4codelabel 
indx4bini
indx4flag





% 
% 
% 
% 
% 
% tbindx= [EEG.event.bini]; %numeric code
% ntbindx
% for s=1:necode
%       indxevcode  =  [indxevcode find(codebound==evcode(s))];
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% if nargin<2
%       if ischar(EEG.event(1).type)
%             evcode = unique_bc2({EEG.event.type}); %strings
%       else
%             evcode = unique_bc2([EEG.event.type]); %numeric code
%       end
% end
% 
% 
% 
% 
% 
% 
% 
% 
% if isempty(evcode)
%       if ischar(EEG.event(1).type)
%             evcode = unique_bc2({EEG.event.type}); %strings
%       else
%             evcode = unique_bc2([EEG.event.type]); %numeric code
%       end
% end
% if length(EEG)>1
%       msgboxText =  'Unfortunately, this function does not work with multiple datasets';
%       error(msgboxText)
% end
% if ~isempty(EEG.epoch)
%       msgboxText =  'lat4bin() only works for continuous datasets.';
%       error(msgboxText)
% end
% if ischar(EEG.event(1).type)
%       codebound = {EEG.event.type}; %cellstrings
% else
%       codebound = [EEG.event.type]; %numeric code
% end
% 
% %
% % search for boundaries
% %
% indxevcode = [];
% necode = length(evcode);
% 
% if iscell(evcode)
%       if ischar(evcode{1}) % evcode is char
%             if iscell(codebound) % string % string
%                   for s=1:necode
%                         indxevcode  = [indxevcode strmatch(evcode(s), codebound, 'exact')'];
%                   end
%             else  % string % numeric
%                   for s=1:necode
%                         numt = str2num(evcode{s});
%                         if ~isempty(numt)
%                               indxevcode  =  [indxevcode find(codebound==numt)];
%                         else
%                               msgboxText = 'You specified a string as event code, but your events are numeric.';
%                               title = 'ERPLAB: evcode format error';
%                               errorfound(msgboxText, title);
%                               return
%                         end
%                   end
%             end
%       else % evcode is numeric
%             if iscell(codebound) % number & string
%                   for s=1:necode
%                         indxevcode  =  [ indxevcode strmatch({num2str(evcode{s})}, codebound, 'exact')'];
%                   end
%             else % number & number
%                   for s=1:necode
%                         indxevcode  =  [indxevcode find(codebound==evcode(s))];
%                   end
%             end
%       end
% else
%       if ischar(evcode) && iscell(codebound)
%             for s=1:necode
%                   indxevcode  = [indxevcode strmatch(evcode(s), codebound, 'exact')'];
%             end
%       elseif ~ischar(evcode) && ~iscell(codebound)
%             for s=1:necode
%                   indxevcode  =  [indxevcode find(codebound==evcode(s))];
%             end
%       elseif ischar(evcode) && ~iscell(codebound)
%             for s=1:necode
%                   numt = str2num(evcode(s));
%                   if ~isempty(numt)
%                         indxevcode  =  [indxevcode find(codebound==numt)];
%                   else
%                         msgboxText = 'You specified a string as event code, but your events are numeric.';
%                         title = 'ERPLAB: evcode format error';
%                         errorfound(msgboxText, title);
%                         return
%                   end
%             end
%       elseif ~ischar(evcode) && iscell(codebound)
%             for s=1:necode
%                   indxevcode  =  [ indxevcode strmatch(num2str(evcode(s)), codebound, 'exact')'];
%             end
%       end
% end
% 
% indxevcode = unique_bc2(indxevcode);