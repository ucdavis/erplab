%  neobinlister2_fast
%  
%  This function mimics the behavior of ERPLAB's neobinlister2.
%  Events are checked for whether they are in the right order, and for
%  events that have time specification, it is checked whether they
%  occur within the specified time-window and in the specified order.
%  It does, however, not yet allow RT measurement, forbidden/ignoreCodeArray
%  input should be handled with caution, and it's unclear whether flags are
%  treated as they should be.
%  However, tested on a dataset containing 20.000 events, the output is exactly
%  the same as with neobinlister2, and speed-up is in the range of 50-100 times.
%  
%  Code adapted and new subfunction 'checkBINfnc' added
%  by Christoph Huber-Huber, Feb 2018.
% 
%
%  Legacy help text for neobinlister2 below. Although it says "beta version"
%  at some point, neobinlister2 is the default in many standard ERPLAB 
%  situations.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  BINLISTER IX 2010
%
%  binlister2.m is the Matlab  re-written version of the original Ecdbl from
%  ERPSS.  It takes a log file for a given set of data and a bin  descriptor
%  file  containing  specification  defining  the conditions  & contigencies
%  an event should satisfy to be included in a particular average (bin), and
%  produces  a  binlist  file that contains a list of  bins for each item in
%  the log  file into  which the corresponding  raw  data  trial  should  be
%  averaged. It also generates a BINLIST structure  which is currently  added  to
%  the EEGLAB structure (optional).
%
%  Note: beta version.  Only for testing purpose. March  2009
%  Write erplab at command window for help
%
% Usage:
% >> [EEG EVENTLIST binOfBins] = binlister(EEG, bdfilename, eventlistFile,
% neweventlistFile, forbiddenCodeArray, username)
%
% Inputs:
%
% EEG                - input dataset
% eventlistFile          - name of EventList text file to load (optional). Default='none'
% neweventlistFile       - name of the new EventList text file to save.
% forbiddenCodeArray - prohibited eventcodes. For instance -99 for pauses.
% username           - name of operator
%
%  Outputs:
%
% EEG         - output dataset
% EVENTLIST   - EventList output structure (it was previously added to EEGLAB structure by pop_creaeventlist())
% binOfBins   - successful bins counting. For histogram (for instance)
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright ? 2007 The Regents of the University of California
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
%
% Bakan! means "Great!" in chilean-slang.
% pre-home means codes or sequence of codes before home code(s) (before .)
% at-home (or just home) means code(s) to be the zero time locked code (first bracket after the .)
% post-home means codes or sequence of codes after home code(s) (second bracket (and s0) after the . )
% LES means LOG EVENT SELECTOR (prehome)


function [EEG, EVENTLIST, binOfBins, isparsenum] = neobinlister2_fast(EEG, bdfilename, eventlistFile, neweventlistFile, forbiddenCodeArray, ignoreCodeArray, reportable, indexEL)

binOfBins  = [];
EVENTLIST  = [];
isparsenum =1;

if nargin < 1
        help pop_binlister
        return
end
if nargin < 8
        indexEL = 1; % EVENTLIST index, in case of multiple EVENTLIST structures
end
if nargin < 7
        reportable = 0; % do not create report (default)
end
if nargin < 6
        ignoreCodeArray = [];
end
if nargin < 5
        forbiddenCodeArray = [];
end
if nargin < 4
        neweventlistFile = '';
end
if nargin < 3
        eventlistFile = '';
end
if nargin < 2
        error('ERPLAB says: neobinlister needs 2 inputs as least.')
end

% get erplab version
version = geterplabversion;

if isempty(bdfilename)
        error('ERPLAB says: bdfilename is empty.')
end
if ismember(neweventlistFile,{'none', 'no', ''})        
        p = which('eegplugin_erplab');
        path_temp = p(1:findstr(p,'eegplugin_erplab.m')-1);
        newevefilepath = fullfile(path_temp, 'erplab_Box');
        if exist(newevefilepath, 'dir')~=7
                mkdir(newevefilepath);  % Thanks to Johanna Kreither. Jan 31, 2013
        end        
        neweventlistFile = sprintf('eventlist_backup_%g', (datenum(datestr(now))*1e10));    %   ['eventlist_backup_' num2str((datenum(datestr(now))*1e10))];
        neweventlistFile = fullfile(newevefilepath, neweventlistFile);
end

%
% segments and parses bdf 03-05-2008
%
[BIN, nwrongbins] = decodebdf(bdfilename);
if nwrongbins == 0
        
        %
        % BDF Decoder.
        % Converts BIN Descriptor into numeric parameters (struct).
        %
        [BIN, isparsenum] = bdf2struct(BIN);
        
        if isparsenum==0
                % parsing was not approved
                return
        end
else
        isparsenum = 0; % parsing was not approved
        return
end

%
% Read EVENTLIST
%
if ismember(eventlistFile,{'none', 'no', ''}) % from dataset or erpset
        if iserpstruct(EEG)
                EVENTLIST = exporterpeventlist(EEG, indexEL);
                fprintf('\n*** neobinlister is taking EVENTLIST from the current ERPset.\n\n')
        else
                [EEGx, EVENTLIST] = creaeventlist(EEG);
                clear EEGx
        end
else % from text file
        % Read EVENTLIST file into EEG.EVENTLIST.eventinfo (also EEG.EVENTLIST.bdf )
        [EEGx, EVENTLIST] = readeventlist(EEG, eventlistFile); % ok
        clear EEGx
end

%
% Add bin descriptor structure to EVENTLIST struct
%
EVENTLIST.bdf = BIN;
% fprintf('Detecting succesful BINs in the EVENTLIST.eventinfo structure....\n');

%
%  Open a new Bin List File
%
bdfcrono   = datestr(now, 'mmmm dd, yyyy HH:MM:SS AM');

if reportable
        
        %
        % Creates a Report about Binlister performance
        %
        [pr, namer] = fileparts(neweventlistFile);
        auxrname = fullfile(pr,namer);
        rnameAux = [auxrname '_REPORT.txt'];
        fid_report  = fopen(rnameAux, 'w');
        flinkname = rnameAux;
        disp(['You can find a report about binlister processing at <a href="matlab: open(''' flinkname ''')">' flinkname '</a>'])
else
        fid_report  = 1;
        rnameAux    = '';
end

%
% Returns the user home directory using the registry on windows systems, and using Java
% on non windows systems as a string.
%
if ispc
        userdir = winqueryreg('HKEY_CURRENT_USER',...
                ['Software\Microsoft\Windows\CurrentVersion\' ...
                'Explorer\Shell Folders'],'Personal');
        %
        % Captures user login
        %
        userlogin  = regexprep(userdir, '.*\', '');
else
        userdir = char(java.lang.System.getProperty('user.home'));
        
        %
        % Captures user login
        %
        userlogin  = regexprep(userdir, '.*/', '');
end

%
% Number of BINs
%
nbin = length(BIN);

%
% Tracks successful bins (histogram)
%
binOfBins   = zeros(1,nbin);
nitem       = length(EVENTLIST.eventinfo);
% binrow      = []; % never used in this version, neobinlister2_fast (Christoph)

%
% Saves bin descriptor file name
%
EVENTLIST.bdfname = bdfilename;

%
% Saves setname for EEG work
%
if isfield(EEG,'setname')
        if strcmpi(EEG.setname, '')
                EVENTLIST.setname = 'no_data';
        else
                EVENTLIST.setname = EEG.setname;
        end
elseif isfield(EEG,'erpname')
        if strcmpi(EEG.erpname, '')
                EVENTLIST.setname = 'no_data';
        else
                EVENTLIST.setname = EEG.erpname;
        end
else
        EVENTLIST.setname = 'no_data';
end

EVENTLIST.elname   = neweventlistFile;  % text output EVENTLIST
EVENTLIST.report   = rnameAux;          % text output REPORT
EVENTLIST.version  = version;
EVENTLIST.eldate   = bdfcrono;
EVENTLIST.account  = userlogin;
% fprintf('\nHUNTING BINs...This process might take...');

%
% Set progress report at command window
%
fprintf('\n');
fprintf([repmat('*',1, 45) '\n']);
fprintf('**\n');
msg = '** Binlister progress to completion......\n'; % carriage return included in case error interrupts loop
fprintf(msg);
ppaux=1;
% tic;


% coded for enhanced speed by Christoph, 2018-01.
itemEnable = [EVENTLIST.eventinfo.enable];
itemCodes = [EVENTLIST.eventinfo.code];
itemTimes = [EVENTLIST.eventinfo.time] * 1000; % probably in seconds, convert to ms!

% cd1:
% Current (log) item status should not be forbidden (enable = -1) code
cd1array = itemEnable ~= -1 & ~ismember_bc2(itemCodes, forbiddenCodeArray);

% cd2:
% Current event code should not be a ignored (enable = 0) code
cd2array = itemEnable ~= 0 & ~ismember_bc2(itemCodes, ignoreCodeArray);

% athome event codes
atHomeCodes = unique(arrayfun(@(b) double(b.athome.eventcode), BIN));

% numeric index to all home/time-locking events
TLitemNumIdx = find(cd1array & cd2array & itemCodes ~= -99 & ...
    ismember(itemCodes, atHomeCodes));


% for iLogitem = 1:nitem  % Reads each log item (item pointer)
% loop only through home code items (timelocking events, TL)
for iLogitem = TLitemNumIdx
    
    %
        % Progress report at command window
        %
        pp = round((iLogitem/nitem)*100);
        if pp>=0 && mod(pp,5)==0 && ppaux~=pp
                %                 if pp>1 && pp<10
                %                         nstepback = 3;
                %                 elseif pp>=10 && pp<100
                %                         nstepback = 4;
                %                 else
                %                         nstepback = 5;
                %                 end
                numze = ceil(log10(pp + 1))-1; % number of zeros
                nstepback = 3 + numze;
                
                fprintf([repmat('\b',1, nstepback) '%d%%\n'], pp);
                ppaux=pp; % to avoid multiple printing for the same value
        end
        
        
        % check to which bin, or multiple bins, this item belongs
        belongsToBins = [];
        for jBin = 1:nbin
            binok = checkBINfnc(iLogitem, itemCodes, itemTimes, BIN(jBin));
            if binok
                belongsToBins = [belongsToBins, jBin];
                binOfBins(jBin) = binOfBins(jBin) + 1; % the counter for trials per bin
            end
        end
        
        if numel(belongsToBins) > 1
            warning('Not clear whether an event can belong to more than one bin. Might be problem for epoching later on...');
        end
        
        EVENTLIST.eventinfo(iLogitem).bini = belongsToBins;
        
        % assign bin number(s) to EVENTLIST
        if isempty(belongsToBins) % no bin found
            EVENTLIST.eventinfo(iLogitem).bini = -1;
            % Creates BIN LABELS
            binName = '""';
        else % found a bin
            EVENTLIST.eventinfo(iLogitem).bini = belongsToBins;
            % Creates BIN LABELS
            auxname = num2str(belongsToBins);
            bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % inserts a comma instead blank space
            
            if strcmp(EVENTLIST.eventinfo(iLogitem).codelabel,'""')
                binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(iLogitem).code) ')']; %B#(code)
            else
                binName = ['B' bname '(' EVENTLIST.eventinfo(iLogitem).codelabel ')']; %B#(codelabel)
            end
        end
        EVENTLIST.eventinfo(iLogitem).binlabel = binName;


end  % Reads each log item (iLogitem loop)

% assignin('base', 'tiemporesp', tiempostim);

% pause(0.01)
fprintf('\n');

%
%  Replace the old EVENT LIST (LOG) Text File Output
%
EVENTLIST.trialsperbin = binOfBins; % 07-21-2008
EVENTLIST.nbin = nbin; % total number of specified bins (at bin descriptor file)

%
% Simplify bin descriptor expressions (Steve's request)
%
for i=1:nbin
        expcell = EVENTLIST.bdf(i).expression;
        EVENTLIST.bdf(i).expression = [expcell{1} '.' expcell{2} expcell{3}];
end

%
%  Creates a EVENTLIST Text Output and updates EVENTLIST structure
%
if iserpstruct(EEG)
        EVENTLIST = EEG.EVENTLIST(indexEL);
        exporterpeventlist(EEG, indexEL, neweventlistFile);
else
        [EEGx, EVENTLIST] = creaeventlist(EEG, EVENTLIST, neweventlistFile);
        clear EEGx
end

fprintf('Successful Trials per bin :\t%s\n', num2str(binOfBins));
if reportable
        fclose(fid_report);        % Closes the file where you wrote the report
end



%--------------------------------------------------------------------------------------------------------------------------------
%
%   Determine whether certain time-lock event belongs to certain bin
% 
function binok = checkBINfnc(iLogitem, itemCodes, itemTimes, B)
    % The central function added by Christoph, Feb 2018.
    
    binok = false;
    
    preok = false;
    postok = false;
    
    iLogitemTime = itemTimes(iLogitem);
    ip = iLogitem - 1;
    prehi = numel(B.prehome); % will move from last to first 'prehome' event
    preTimeLimit = -1; % an event with 'timecode' can occur at max at this time
    
    % Actually twice almost exactly the same code, once for 'pre' and once
    % for 'post'.
    while ip > 0 && prehi > 0
        % whats the "event sign"?
        % (if more than one element, both usually the same)
        if numel(unique(B.prehome(prehi).eventsign)) ~= 1, error('Unexpected case!'); end
        thisPreSign = all(B.prehome(prehi).eventsign); % all 'eventsign' supposed to be the same
        
        % So, is time relevant?
        currentTimeWindowPos = unique(B.prehome(prehi).timecode, 'rows');
        currentTimeWindow = sort(-1 * currentTimeWindowPos);
        % replace upper limit by 'preTimeLimit', to ensure that sequences
        % of prehome expressions occur in the order in which they are
        % specified.
        currentTimeWindow(2) = min([preTimeLimit, currentTimeWindow(2)]);
        
        if size(currentTimeWindow, 1) ~= 1 % is not a row vector
            % 'timecode' are not unique across all 'eventcodes'
            % of the current 'prehome'. that's unexpected!
            error('''timecode'' not unique across ''eventcodes'' of current ''prehome'' - how come?');
        end
        if all(unique(B.prehome(prehi).timecode, 'rows') >= 0) % time is relevant
            % use B.prehome.timecode, since currentTimeWindow has been
            % ajusted and might be negative although relevant!
            % get index to all events in the time window
            currentIdx = (itemTimes - iLogitemTime) >= currentTimeWindow(1) & ...
                (itemTimes - iLogitemTime) <= currentTimeWindow(2);
            currentCodes = itemCodes(currentIdx);
            currentTimesAbs = itemTimes(currentIdx);
            currentTimesRel = currentTimesAbs - iLogitemTime;
            if thisPreSign % = 1
                % there has to be an event of current prehome code
                if any(ismember(currentCodes, B.prehome(prehi).eventcode))
                    % all good
                    % set a new time limit: the lowest time of all the
                    % occuring prehome events
                    preTimeLimit = min(currentTimesRel(ismember(currentCodes, B.prehome(prehi).eventcode)));
                    % can go to next prehome
                    prehi = prehi - 1;
                else
                    % condition violated
                    return
                end
            else % thisPreSign == 0, the prehome event codes must not be there
                if any(ismember(currentCodes, B.prehome(prehi).eventcode))
                    return
                else
                    % they are not there
                    % can go to next prehome
                    prehi = prehi - 1;
                    % but, keep the current time limit! if the time limit
                    % was adjusted here to the maximum of the not-occurring
                    % events (because of sign == 0!), it would be too
                    % restrictive for the next time critical event!
                end
            end
        else % time is _not_ relevant
            % is current event an event code we are looking for?
            if any(ismember(itemCodes(ip), B.prehome(prehi).eventcode))
                % YES
                % (if-statement could probably also be without 'ismember',
                %  because itemCodes can only contain one element, right?)
                prehi = prehi - 1; % also go to next prehome event
                ip = ip - 1; % and go to next event/item
            else % NO
                return
            end
        end
    end
    
    % all prehome events are satisfied
    if prehi == 0
        preok = true;
    end
    
    % check posthome events
    ip = iLogitem + 1;
    posthi = 1;
    postTimeLimit = 1;
    while ip <= numel(itemCodes) && posthi <= numel(B.posthome)
        % What sign does next event have?
        % (if more than one element, both usually the same)
        if numel(unique(B.posthome(posthi).eventsign)) ~= 1, error('Unexpected case!'); end
        thisPostSign = all(B.posthome(posthi).eventsign);
        % So, is time relevant?
        currentTimeWindow = unique(B.posthome(posthi).timecode, 'rows');
        currentTimeWindow(1) = max([currentTimeWindow(1), postTimeLimit]);
        if size(currentTimeWindow, 1) ~= 1 % is not a row vector
            % 'timecode' are not unique across all 'eventcodes'
            % of the current 'posthome'. that's unexpected!
            error('''timecode'' not unique across ''eventcodes'' of current ''posthome'' - home come?');
        end
        if all(unique(B.posthome(posthi).timecode, 'rows') >= 0) % time is relevant
            % get index to all events in the time window
            currentIdx = (itemTimes - iLogitemTime) >= currentTimeWindow(1) & ...
                (itemTimes - iLogitemTime) <= currentTimeWindow(2);
            currentCodes = itemCodes(currentIdx);
            currentTimesAbs = itemTimes(currentIdx);
            currentTimesRel = currentTimesAbs - iLogitemTime;
            if thisPostSign % = 1
                % there has to be an event of current posthome code
                if any(ismember(currentCodes, B.posthome(posthi).eventcode))
                    % set a new time limit: the largest time of all the
                    % occuring prehome events
                    postTimeLimit = max(currentTimesRel(ismember(currentCodes, B.posthome(posthi).eventcode)));
                    % all good, can go to next posthome
                    posthi = posthi + 1;
                else
                    % condition violated
                    return
                end
            else % thisPostSign == 0, the posthome event codes must not be there
                if any(ismember(currentCodes, B.posthome(posthi).eventcode))
                    return
                else
                    % they are _not_ there, so can go to next posthome
                    posthi = posthi + 1;
                    % but, keep the current time limit! if the time limit
                    % was adjusted here to the maximum of the not-occurring
                    % events (because of sign == 0!), it would be too
                    % restrictive for the next time critical event!
                end
            end
        else % time is _not_ relevant
            % is current event an event code we are looking for?
            if any(ismember(itemCodes(ip), B.posthome(posthi).eventcode))
                % YES
                % (if-statement could probably also be without 'ismember',
                %  because itemCodes can only contain one element, right?)
                posthi = posthi + 1; % also go to next posthome event
                ip = ip + 1; % and go to next event/item
            else % NO
                return
            end
        end
    end
    
    % all posthome events are satisfied
    if posthi == numel(B.posthome)+1
        postok = true;
    end
    
    if preok && postok
        binok = true;
    end

% FUNCTION END


%--------------------------------------------------------------------------------------------------------------------------------
%
% Flag Test Function
%

function [ishomeFlagdetected, varargout] = flagTest(BIN, EVENTLIST, auxles, seq, currentbin, currentlogitem)

auxflag     = BIN(currentbin).(auxles)(seq).flagcode(1,1); % first flag sequencer
auxflagmask = BIN(currentbin).(auxles)(seq).flagmask(1,1); % first flag logic-mask per sequencer

if auxflagmask~=0
        maskedEventFlag    = bitand(EVENTLIST.eventinfo(currentlogitem).flag, auxflagmask); % apply the mask
        ishomeFlagdetected = ~isempty(find(auxflag == maskedEventFlag, 1));    % compare flag condition
        flgx=1;                                                                % There is flag condition
else
        ishomeFlagdetected = 1;  % by default, because there was not flag condition
        flgx = 0;                % There was not flag condition
end
varargout(1)= {flgx};

%--------------------------------------------------------------------------------------------------------------------------------
%
% Write Test Function
%
function [writeflag, writeindx] = writeTest(BIN, EVENTLIST, auxles, seq, currentbin,...
        currentlogitem, writeflag, writeindx)

auxwrite     = BIN(currentbin).(auxles)(seq).writecode(1,1); % first flag sequencer
auxwritemask = BIN(currentbin).(auxles)(seq).writemask(1,1); % first flag logic-mask per sequencer

if auxwritemask~=0
        flagnegmasked    = bitand(EVENTLIST.eventinfo(currentlogitem).flag, bitcmp(auxwritemask)); % apply the complemented write mask
        newflag = bitor(flagnegmasked, auxwrite );  % Bitwise OR between write setting and the current sequencer's flag
        writeflag = [writeflag newflag];
        writeindx = [writeindx currentlogitem];
end

%--------------------------------------------------------------------------------------------------------------------------------
%
% PREHOME & POSTHOME TIME-RANGE TEST 02
%

function[targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2(EVENTLIST, BIN, les, isnegated, previous_t2, ...
        iLogitem, traffic, islastsequencer, writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, forbiddenCodeArray, targetLogPointer, targetEventCodeArray)

% I) The basic detection said there was no event code that matches,
% but there is a description of time range for a non-negated code.
% II) Or the basic detection said that there was an event code that mached, but
% there is a description of the time range for a negated code.
% III) Code match, but we need to check the specified time range.
% *Remember that isdetectedLES = 0 for non-negated and isdetectedLES = 1 for negated

%
%         PREHOME & POSTHOME TIME-RANGE TEST 02
%  timetest = 1;  % means TIME-RANGE TEST was required
%
%
% Report: start time-range test 02
%
nitem = length(EVENTLIST.eventinfo);
tempi = BIN(jBin).(les{kles})(mSeq).timecode(1,1:2);

%
% home-referenced time window  [t1 t2]
%
t1   = EVENTLIST.eventinfo(iLogitem).time + traffic(kles)*tempi(1,2^(2-kles))/1000 ;
t2   = EVENTLIST.eventinfo(iLogitem).time + traffic(kles)*tempi(1,kles)/1000;

if t2 > previous_t2 && kles==1
        t2 = previous_t2;
elseif t1 < previous_t2  && kles==2
        t1 = previous_t2;
end

%
%                     Forbidden's event detector
%
%
t0        = EVENTLIST.eventinfo(iLogitem).time;
rfrbddn   = find([EVENTLIST.eventinfo.time] >= t0 & [EVENTLIST.eventinfo.time] <= t2) ;

if ~isempty(rfrbddn)
        codesrangefrbddn  = [EVENTLIST.eventinfo(rfrbddn).code];
        timecodesfrbddn   = [EVENTLIST.eventinfo(rfrbddn).time];
        [tf, rp2]         = ismember_bc2(codesrangefrbddn, forbiddenCodeArray);
        timefrbddn        = timecodesfrbddn(find(rp2,1));
        codefrbddn        = codesrangefrbddn(find(rp2,1));
        isfrbddndetected  = nnz(tf)>0;  % 1 means forbidden code(s) was(were) found within [t0 t2] time range.
else
        isfrbddndetected  = 0;
end

targetLogItemArray  = find([EVENTLIST.eventinfo.time] >= t1 & [EVENTLIST.eventinfo.time] <= t2); % items for events within T1-T2

if ~isempty(targetLogItemArray)
        targetLogCodeArray = [EVENTLIST.eventinfo(targetLogItemArray).code];      % LOGCODES within targetLogItemArray range
        targetLogTimeArray = [EVENTLIST.eventinfo(targetLogItemArray).time];      % Log times within targetLogItemArray range (T1 - T2)
        tf   = ismember(targetLogCodeArray, targetEventCodeArray);
        rcr  = find(tf,1,'first'); % local pointer!
        israngedetected = ~isempty(rcr);
else
        israngedetected = 0;
end


%*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


if israngedetected && isfrbddndetected   % Codes were detected but there was a pause code 04 February 2008
        timecodOK = targetLogTimeArray(rcr);
        targetLogPointer = targetLogItemArray(rcr);
        
        if (timefrbddn >= timecodOK && kles==1) || (timefrbddn <= timecodOK && kles==2)
                % the pause was between the home and the current code...bad news
                % Oops! Event code was preceded by a forbiden code.
                isdetectedLES = 0;
        else
                if isnegated   % 02-21-2008
                        % We have a problem...event code was found inside this time range.                        
                        [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                                jBin, targetLogItemArray(rcr) );  % call the function flagTest 12 March 2008
                        [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                targetLogPointer, writeflag, writeindx);
                        if ishomeFlagdetected && ~flgx
                                % And event code satisfied flag condition (by default) also...
                                isdetectedLES = 0;
                        elseif ishomeFlagdetected && flgx
                                % Even worse, event code satisfied flag condition:
                                isdetectedLES = 0;
                        else
                                % However, event code did not satisfy flag condition:
                                isdetectedLES = 1;
                        end
                else
                        % The pause was further away from the current code, so good news. Event code was found inside this time range.
                        % Event code satisfied condition by time.
                        [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                                jBin, targetLogItemArray(rcr) );  % Call the function flagTest 12 March 2008
                        [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                targetLogPointer, writeflag, writeindx);
                          
                          
                        %*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                        %*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                        %*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                        
                        
                        if ~ishomeFlagdetected   % BUG: isdetectedLES may not be declared!                              
                                % event code did not satisfy flag condition:
                                isdetectedLES = 0;
                        end
                        
                        % Now, the Log item pointer (offsetLogitem), which moves around the detected
                        % home logitem, is moved until the next successful detection by a time
                        % criterion. This will imply that the sequencer's pointer (mSeq) will go
                        % faster than offsetLogitem, for this bin
                        
                        offsetLogitem = abs(targetLogItemArray(rcr) - iLogitem);
                        if targetLogPointer>1  &&  targetLogPointer<nitem
                                previous_t2 = [EVENTLIST.eventinfo(targetLogItemArray(rcr) + traffic(kles)).time];
                        end
                end
        end
elseif israngedetected && ~isfrbddndetected   % Code was detected and there was no pause 04 February 2008
        
        %
        % Stores the time of the detected logcode (within the time range)
        %
        timecodOK = targetLogTimeArray(rcr);
        targetLogPointer = targetLogItemArray(rcr);
        
        [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                targetLogItemArray(rcr) );
        [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                targetLogPointer, writeflag, writeindx);
        
        if isnegated   % 02-21-2008
                % We have a problem...event code was found inside this time range (%g).
                
                if EVENTLIST.eventinfo(targetLogItemArray(rcr)).enable  % checks enable  10-16-2008. Bug fixed Mar 28 2011
                        if ishomeFlagdetected 
                                isdetectedLES = 0;
                        else
                                % However, event code did not satisfy flag condition.
                                isdetectedLES = 1;
                        end
                else  % checks enable  10-16-2008
                        % However, event code is not enable.
                        isdetectedLES = 1;
                end
        else
                % Event code was found inside this time range. Event code satisfied condition by time.
                
                if EVENTLIST.eventinfo(targetLogItemArray(rcr)).enable  % checks enable  10-16-2008. Bug fixed Mar 28 2011
                        if ishomeFlagdetected 
                                isdetectedLES = 1;
                        else
                                % However, event code did not satisfy flag condition.
                                isdetectedLES = 0;
                        end
                else  % checks enable  10-16-2008
                        % However, event code is not enable.
                        isdetectedLES = 0;
                end
                
                % Now, the Log item pointer (offsetLogitem), which moves around the detected
                % home logitem, is moved until the next successful detection by a time
                % criterion. This will imply that the sequencer's pointer (mSeq) will go
                % faster than offsetLogitem, for this bin
                if isdetectedLES
                        offsetLogitem = abs(targetLogItemArray(rcr) - iLogitem);
                        if targetLogPointer>1 && targetLogPointer<nitem && ~islastsequencer
                                previous_t2 = [EVENTLIST.eventinfo(targetLogItemArray(rcr) + traffic(kles)).time] ;
                        end
                end
        end
else   % event codes were not detected. Bad news?
        if isnegated   % 02-21-2008
                %Since event code is negated, and it was not found inside this time range, then good news.
                isdetectedLES = 1;
        else
                %event code was not found inside this time range. Bad news.
                isdetectedLES = 0;  % 12 March 2008
        end
end
return
