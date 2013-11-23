% ALPHA VERSION
%
% doubleresponsekiller() version 2
%
% Usage
%
% EEG = doubleresponsekiller(EEG, code, pos);
%
% Input
%
% EEG      - EEG struct
% code     - response event code (could be numerical or string)
% pos      - 'first' means keep the first response, delete the rest of those (for the current trial)
%          - 'last' means keep the last response, delete the previous ones (for the current trial)
%
% Output
%
% EEG      - (updated) EEG struct
%
% Example 1
%
% Find double response for event code 11. Keep the first 11, delete the rest of them
%
% >> EEG = doubleresponsekiller(EEG, 11, 'first')
%
% Example 2
%
% Find double response for event code 'Resp4'. Keep the last 'Resp4', delete the rest of them
%
% >> EEG = doubleresponsekiller(EEG, 'Resp4', 'Last')
%
% Alpha version
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function EEG = doubleresponsekiller(EEG, code, pos)

if nargin < 1
        help doubleresponsekiller
        return
end
if isempty(EEG.data)
        error('ERPLAB says: errot at doubleresponsekiller(). Cannot work with an empty dataset')
end
if ~isempty(EEG.epoch)
        error('ERPLAB says: errot at doubleresponsekiller(). Only works on continuous data!')
end

auxevent = EEG.event;

if ischar(auxevent(1).type)
        
        if isnumeric(code)
                error(['ERPLAB says: errot at doubleresponsekiller(). Your event codes are string, but you specify a numeric code ' num2str(code)])
        end
        
        currcodestr = {auxevent.type};
        unicodestr = unique_bc2(currcodestr);
        
        for k=1:length(auxevent)
                [tfx, currcode(k)] = ismember_bc2(currcodestr{k}, unicodestr) ;
        end
        
        [tfx, code] = ismember_bc2(code, unicodestr);
        
        isstringcode = 1;
else
        if ischar(code)
                error(['ERPLAB says: errot at doubleresponsekiller(). Your event codes are numeric, but you specified a string code ' code])
        end
        currcode = cell2mat({auxevent.type});
        isstringcode = 0;
end

currlate = cell2mat({auxevent.latency});

%
% Any other custom EEG.EVENTLIST.eventinfo field
%
names    = fieldnames(auxevent);
names    = names(~ismember_bc2(names, {'type','latency', 'duration', 'urevent'})); % only extra event fields
lename   = length(names);

for j=1:lename
        curraux{j} = {auxevent.(names{j})};
end

diffcode = diff(currcode);

if strcmpi(pos,'first')
        loc = find(diffcode==0)+1;
elseif strcmpi(pos,'last')
        loc = find(diffcode==0);
else
        error('ERPLAB says: errot at doubleresponsekiller(). "first" and "last" are valid as position option')
end

loc = loc(currcode(loc)==code);

try
        if ~isempty(loc)
                
                %
                % delete repeated ones
                %
                currcode(loc) = [];
                currlate(loc) = [];
                
                for j=1:lename
                        [curraux{j}{loc}] = deal([]);
                        indc = find(~cellfun(@isempty, curraux{j}));
                        currauxnew{j} = [curraux{j}{indc}];
                end
                
                levent = length(currcode);
                
                if isfield(auxevent, 'duration')
                        currdura      = cell2mat({auxevent.duration});
                        currdura(loc) = [];
                else
                        currdura      = ones(1,levent);
                end
                
                levent    = length(currcode);
                auxevent = [];
                
                tt = num2cell(currcode);
                ll = num2cell(currlate);
                dd = num2cell(currdura);
                
                [auxevent(1:levent).type]     = tt{:};
                [auxevent(1:levent).urevent]  = tt{:};
                [auxevent(1:levent).latency]  = ll{:};
                [auxevent(1:levent).duration] = dd{:};
                
                for j=1:lename
                        
                        if ischar(currauxnew{j}(1))
                                auxfieldval = cellstr(currauxnew{j}(:))';
                        else
                                auxfieldval = num2cell(currauxnew{j});
                        end
                        
                        [auxevent(1:levent).(names{j})] = auxfieldval{:};
                end
                
                if isstringcode
                        for k=1:levent
                                [tfx, posc] = ismember_bc2(auxevent(k).type, 1:length(unicodestr));
                                auxevent(k).type = unicodestr{posc};
                        end
                        
                        codedisp = unicodestr{code};
                else
                        codedisp = num2str(code);
                end
                
                EEG.event = auxevent;
                EEG = eeg_checkset( EEG, 'eventconsistency' );
                
                fprintf('\n************** %g double responses (%s) were found in this dataset **************\n\n',...
                        length(loc), codedisp)
                
                disp('EEG.event was updated.')
        else
                fprintf('\n************** Double responses were not found in this dataset **************\n\n')
        end
catch
        fprintf('\n\nWARNING: There was a problem. EEG.event was NOT updated.\n\n')
        return
end

