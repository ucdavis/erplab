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
%
% Bakan! means "Great!" in chilean-slang.
% pre-home means codes or sequence of codes before home code(s) (before .)
% at-home (or just home) means code(s) to be the zero time locked code (first bracket after the .)
% post-home means codes or sequence of codes after home code(s) (second bracket (and s0) after the . )
% LES means LOG EVENT SELECTOR (prehome)


function [EEG, EVENTLIST, binOfBins, isparsenum] = neobinlister2(EEG, bdfilename, eventlistFile, neweventlistFile, forbiddenCodeArray, ignoreCodeArray, reportable, indexEL)

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
binrow      = [];

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

for iLogitem = 1:nitem  % Reads each log item (item pointer)
        
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
        
        %
        % Current (log) item status should not be forbidden (enable = -1) code
        %
        cd1 = EVENTLIST.eventinfo(iLogitem).enable~=-1 && ~ismember(EVENTLIST.eventinfo(iLogitem).code, forbiddenCodeArray);
        
        %
        % Current event code should not be a ignored (enable = 0) code
        %
        cd2 =  EVENTLIST.eventinfo(iLogitem).enable~=0 && ~ismember(EVENTLIST.eventinfo(iLogitem).code, ignoreCodeArray);
        
        if cd1 && cd2 % check previous conditions
                
%                 %
%                 % Inform remaining time
%                 %
%                 if nitem>10 && iLogitem==10
%                         ttoc = 1.1*((toc/10)*nitem)/60;
%                         if ttoc>1
%                                 fprintf('%.2f minutes (aprox)\n', ttoc)
%                         else
%                                 fprintf('%.1f seconds (aprox)\n', ttoc*60)
%                         end
%                 end     
                
                %
                % loop bins
                %
                for jBin=1:nbin  % BIN's loop                        
                        writeflag = []; writeindx = [];
                        
                        %
                        % Conditions for bin
                        %
                        cond1 = iLogitem > length(BIN(jBin).prehome);             % current item's pointer has to be greater than the amount of pre-home sequencer at the current bin.
                        cond2 = (nitem - iLogitem) >= length(BIN(jBin).posthome); % remaining number of items has to be greater than the amount of post-home sequencer at the current bin.
                        cond3 = EVENTLIST.eventinfo(iLogitem).code~=-99;          % WARNING: current event codes should not be equal to -99 (this is the default code for 'boundary' events)
                        
                        if cond1 && cond2 && cond3 % % check conditions
                                
                                %
                                % HOME START
                                %                                
                                %
                                % Special event codes (take-all and take-nothing)
                                %
                                isallcode  = ~isempty(find(BIN(jBin).athome(1).eventcode == -7, 1));  % check for take-all event code (*)
                                isnonecode = ~isempty(find(BIN(jBin).athome(1).eventcode == -13, 1)); % check for take-nothing event code (~*)
                                
                                if isallcode %(Take-All code case: -7)
                                        %
                                        %current BIN has a TAKE-ALL event code. So home is detected by default.
                                        ishomedetected    = 0;                     % This variable is used to detect home (1: detected)   0: stop searching
                                        binOfBins(1,jBin) = binOfBins(1,jBin) + 1; % Bin counter vector
                                elseif isnonecode  %(Take-nothing code case: -13)
                                        ishomedetected = 0; % 0=stop searching
                                else
                                        %
                                        % otherwise, compares home against the current event code
                                        %                                        
                                        nDesiredCodes   = nnz(BIN(jBin).athome(1).eventsign); % Number of non-negated codes (wanted codes)
                                        ishomedetected = ~isempty(find(BIN(jBin).athome(1).eventcode == EVENTLIST.eventinfo(iLogitem).code, 1));
                                        
                                        if nDesiredCodes == 0     % this means all event codes at home were negated.
                                                ishomedetected = ~ishomedetected;    % So, the detection was positive (This variable is used to detect pre & post home (~0: detected))
                                        end
                                        
                                        % flag test
                                        ishomeFlagdetected     = flagTest(BIN, EVENTLIST, 'athome', 1, jBin, iLogitem ); % This variable is used to detect flag (1: detected)
                                        % write test
                                        [writeflag, writeindx] = writeTest(BIN, EVENTLIST, 'athome', 1, jBin, iLogitem, writeflag, writeindx);                                        
                                end
                                
                                %
                                % If home matchs then it can do the rest of checking
                                %                                
                                if ishomedetected && ishomeFlagdetected

                                        %Home code of current BIN was detected at current item <iLogitem>                                        
                                        %
                                        % PreHome & PostHome Test.
                                        % PQ Sequencers
                                        %
                                        traffic(1)    = -1;               % going to athome's left side   <-<-<-.{}
                                        traffic(2)    =  1;               % going to athome's right side  .{}->->->
                                        isdetectedLES =  1;               % This variable is used to detect pre & post home (1: detected)
                                elseif ishomedetected && ~ishomeFlagdetected   % 03-13-2008
                                        
                                        % Home code of current BIN was detected at current item. 
                                        % However, flag condition does not match. 
                                        % Sorry, current BIN was not completely successful for current item 
                                        isdetectedLES = 0; %This variable (positive logic) is used to detect pre & post home
                                else
                                        isdetectedLES = 0; %This variable (positive logic) is used to detect pre & post home
                                end
                                
                                les    = cell(1);
                                les{1} = 'prehome';
                                les{2} = 'posthome';
                                nLes   = length(les);
                                kles   = 1;   % les's (Log Event Selector) iterator
                                capcodeatles = cell(2,1); % for RT measurements
                                
                                while (kles <= nLes) && isdetectedLES   % fields: {prehome} -->{posthome}
                                        
                                        offsetLogitem = 1;  % this variable allows iterator jumpings
                                        nSequencer    = length(BIN(jBin).(les{kles})); % total number of sequencer ({}s) for the current les
                                        
                                        if kles==1
                                                previous_t2   = max([EVENTLIST.eventinfo.time]);
                                        else
                                                previous_t2   = 0;
                                        end
                                        
                                        kSeq            = 1; % auxiliar sequencer's iterator
                                        islastsequencer = 0; % is this the las sequencer (last {}) for the current les?  1:yes, 0:no
                                        
                                        %
                                        %  PREHOME & POSTHOME START
                                        %                                                                          
                                        while (kSeq <= nSequencer) && (isdetectedLES) % each sequencer
                                                targetLogPointer = iLogitem + traffic(kles)*offsetLogitem;     % current log item to be tested (from EVENTLIST)
                                                
                                                if targetLogPointer>nitem % Oct 15, 2012
                                                        isdetectedLES=0;
                                                        break
                                                end
                                                
                                                targetLogCode    = EVENTLIST.eventinfo(targetLogPointer).code;  % current event code to be tested, at current log item = targetLogPointer, from bin descriptor file.
                                                isignoredc       = ismember(targetLogCode, ignoreCodeArray);    % is this code an ignored one?
                                                isforbiddenc     = ismember(targetLogCode, forbiddenCodeArray); % is this code a forbidden one?
                                                
                                                if isforbiddenc
                                                        % 'Stop! Forbidden code was found!
                                                        isdetectedLES=0;
                                                        break
                                                end                                                
                                                if EVENTLIST.eventinfo(targetLogPointer).enable~=-1 && ~isignoredc % is enable the current event code to test?
                                                        
                                                        if kles == 1
                                                                mSeq = nSequencer - kSeq + 1;    % sequencer's iterator (countdown)
                                                        else
                                                                mSeq = kSeq;                     % sequencer's iterator (countup)
                                                        end
                                                        
                                                        nDesiredCodes        = nnz(BIN(jBin).(les{kles})(mSeq).eventsign);   % Number of desired codes. "desired codes" (wanted ones) are codes which sign is 1. Sign 0 means "negated codes"
                                                        targetEventCodeArray = BIN(jBin).(les{kles})(mSeq).eventcode;        % Code(s) inside the current sequencer ({}), at current les, that are going to be compared with the current event code at current item.
                                                        rc = find(targetEventCodeArray == targetLogCode, 1);                 % location of matching code at current sequencer. Empty means unsuccessful "detection" for desired codes (see below)
                                                        
                                                        if nDesiredCodes > 0
                                                                %'matching';                                                                
                                                                isnegated    = 0;                % NON NEGATED codes (desired codes)
                                                                ispqdetected = ~isempty(rc);     % not empty means successful "detection" for desired codes
                                                        else
                                                                %'mismatching';                                                                
                                                                isnegated     = 1;               % NEGATED codes
                                                                ispqdetected  = isempty(rc);     % empty means (ispqdetected=1) successful "NO detection" for NEGATED codes
                                                                
                                                                if ispqdetected
                                                                        % if "NO detection" is successful then look for the first "different" code at current sequencer
                                                                        rc    = find(targetEventCodeArray ~= targetLogCode, 1);
                                                                end
                                                        end                                                       
                                                        
                                                        %
                                                        % Time condition detector
                                                        %
                                                        
                                                        rt = find(BIN(jBin).(les{kles})(mSeq).timecode ~= -1, 1);  % is there time spec for the current sequencer?
                                                        istimed = ~isempty(rt);                                    % 1 means time spec was detected
                                                        
                                                        if kSeq == nSequencer       % is this the last sequencer for the current les?
                                                                islastsequencer = 1;
                                                        end                                                        
                                                        if ~ispqdetected
                                                                isdetectedLES = 0;  % Current sequencer was not successful...so far...
                                                        end
                                                        
                                                        CA =       isdetectedLES &&  istimed && ~isnegated;        % a) successful detection of (not negated) sequencer. However, there was time condition...
                                                        CB =     (~isdetectedLES &&  istimed && ~isnegated)...
                                                                || ( isdetectedLES &&  istimed &&  isnegated)...
                                                                || (~isdetectedLES &&  istimed &&  isnegated);     % b) unsuccessful detection of (not negated) sequencer. However, there was time condition,
                                                                                                                   %    or successful detection of negated sequencer. However, there was time condition,
                                                                                                                   %    or unsuccessful detection of (not negated) sequencer. However, there was time condition...
                                                        CC =      ~isdetectedLES && ~istimed;                      % c) successful detection of (not negated) sequencer. However, there was time condition...
                                                        
                                                        if CA % a)                                                                
                                                                
                                                                %
                                                                % PREHOME & POSTHOME TIME-RANGE TEST 1
                                                                %
    
                                                                tempi = BIN(jBin).(les{kles})(mSeq).timecode(rc,1:2); % get time interval (time spec)                                                               
                                                                t1 = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1,2^(2-kles)) / 1000;
                                                                t2 = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1,kles) / 1000;                                                                
                                                                
                                                                if kles==1
                                                                        if t2 > previous_t2     % avoids earlier event codes detection by prehome time.
                                                                                
                                                                                % due to the presence of the previous sequencer the last
                                                                                % window is being corrected
                                                                                t2 = previous_t2;                                                                                
                                                                        end
                                                                elseif kles==2
                                                                        if t1 < previous_t2    % avoids earlier event codes detection by posthome time.OK
                                                                                % due to the presence of the previous sequencer the last
                                                                                % window is being corrected
                                                                                t1 = previous_t2;
                                                                        end
                                                                else
                                                                        error('ERPLAB says: "kles" variable got a wrong value. It must be 1 or 2.')
                                                                end
                                                                if t1>t2  % t1 must be always lesser or equal to t2, either for pre or post home (time increases rightward)
                                                                          % Sorry, now this window is unreachable.
                                                                        isdetectedLES = 0;
                                                                else
                                                                        targetLogTime = EVENTLIST.eventinfo(targetLogPointer).time;
                                                                        
                                                                        if targetLogTime >= t1 && targetLogTime <= t2 % TIME-RANGE TEST was approved!                                                                                
                                                                                if targetLogPointer>1  &&  targetLogPointer<nitem
                                                                                        previous_t2 = EVENTLIST.eventinfo(targetLogPointer + traffic(kles)).time ;   %targetLogTimeArray(rcr);  % 10 March  % 12 March
                                                                                end
                                                                                
                                                                                % flag test
                                                                                [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin, targetLogPointer );
                                                                                % write test
                                                                                [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                                                                        targetLogPointer, writeflag, writeindx);
                                                                                
                                                                                if ~ishomeFlagdetected 
                                                                                        % flag condition did not match with the event
                                                                                        isdetectedLES = 0;
                                                                                end
                                                                        else
                                                                                % I) The basic detection said there was no event code that matches,
                                                                                % but there is a description of time range for a non-negated code.
                                                                                % II) Or the basic detection said that there was an event code that mached, but
                                                                                % there is a description of the time range for a negated code.
                                                                                % III) Code match, but we need to check the specified time range.
                                                                                % *Remember that isdetectedLES = 0 for non-negated and isdetectedLES = 1 for negated
                                                                                % chance = 2;
                                                                                
                                                                                %
                                                                                % Call Time Test 2
                                                                                %
                                                                                [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2(EVENTLIST, BIN, les, isnegated, previous_t2, ...
                                                                                        iLogitem, traffic, islastsequencer, writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, forbiddenCodeArray, ...
                                                                                        targetLogPointer, targetEventCodeArray);                                          
                                                                        end
                                                                end                                                                
                                                        elseif CB
                                                                % I) The basic detection said there was no event code that matches,
                                                                % but there is a description of time range for a non-negated code.
                                                                % II) Or the basic detection said that there was an event code that mached, but
                                                                % there is a description of the time range for a negated code.
                                                                % III) Code match, but we need to check the specified time range.
                                                                % *Remember that isdetectedLES = 0 for non-negated and isdetectedLES = 1 for negated
                                                                % chance = 1;
                                                                
                                                                %
                                                                % Call Time Test 2
                                                                %                                                                
                                                                [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2(EVENTLIST, BIN, les, isnegated, previous_t2, ...
                                                                        iLogitem, traffic, islastsequencer, writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, forbiddenCodeArray, targetLogPointer, targetEventCodeArray);
                                                                                                                                
                                                        elseif CC % The basic detection said there is no match for the specified event code and there is no time range specified.
                                                                
                                                                % flag test
                                                                [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                                                                        jBin, targetLogPointer ); 
                                                                % write test
                                                                [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                                                        targetLogPointer, writeflag, writeindx);
                                                                
                                                                if ~ishomeFlagdetected && flgx && isnegated
                                                                        % not successful??? however, current working code is negated.
                                                                        isdetectedLES = 1;
                                                                end
                                                        else              % The basic detection was successful and no time interval is specified
                                                                
                                                                % flag test
                                                                [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                                                                        jBin, targetLogPointer );
                                                                % write test
                                                                [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                                                        targetLogPointer, writeflag, writeindx);
                                                                
                                                                if isnegated   % 21 February 2008
                                                                        % good news, working event code is different(s). It was not necessary to test flag
                                                                        isdetectedLES = 1;                                                                        
                                                                else
                                                                        % working event code matchs. working event code satisfies time
                                                                        % condition by default.
                                                                        if ~ishomeFlagdetected
                                                                                % working event code does not satisfy flag condition
                                                                                isdetectedLES = 0;
                                                                        end
                                                                end
                                                                if ~islastsequencer && ~isnegated   % sept 22,2010 JLC
                                                                        previous_t2 = EVENTLIST.eventinfo(targetLogPointer + traffic(kles)).time ;
                                                                end
                                                        end
                                                        
                                                        kSeq = kSeq+1; %sequence number**********
                                                        
                                                elseif EVENTLIST.eventinfo(targetLogPointer).enable==-1 || isforbiddenc    %12-12-2008                                                        
                                                        %current working event code is a forbidden one (-1). 
                                                        %Sequencer will be rejected
                                                        isdetectedLES = 0;
                                                else % is enable current event code to test?                                                        
                                                        % current working event code is not enable for working (0).
                                                        % I''ll test the next one.         
                                                        kSeq = kSeq+1; %sequence number**********
                                                end  % Check enable condition
                                                
                                                offsetLogitem = offsetLogitem + 1;  % check next (or previous) logcode                                                
                                                
                                                if isdetectedLES && ~isignoredc  % Apr 6, 2013
                                                        capcodeatles{kles, mSeq} = targetLogPointer; 
                                                end
                                        end     % each sequencer
                                                                                
                                        kles = kles + 1;   % 1 = prehome; 2 = posthome. February 15, 2008
                                        
                                end % fields
                                
                                %
                                % Write bin's number in the output file (fully successful case)
                                %
                                if isdetectedLES %% && detectp 02-15-2008                                        
                                        wrf = num2cell(writeflag);                                        
                                        if ~isempty(writeindx)
                                                [EVENTLIST.eventinfo(writeindx).flag] = wrf{:};  %Overwrite flags    10-29-2008
                                        end
                                        
                                        binOfBins(1,jBin) = binOfBins(1,jBin) + 1;
                                        indxbin = binOfBins(1,jBin);
                                        binrow  = cat(2, binrow, jBin);
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%% Added field to get reaction time in milliseconds%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        if isfield(BIN, 'rtname')                                                
                                                if ~isempty(BIN(jBin).rtname)                                                        
                                                        rtpointer = [capcodeatles{2,BIN(jBin).rtindex}]; % only posthome reaction times
                                                        temp_rt_time = [EVENTLIST.eventinfo(rtpointer).time];
                                                        temp_rt_code = [EVENTLIST.eventinfo(rtpointer).code];                                                        
                                                        for nLoop = 1:length(temp_rt_time)
                                                                EVENTLIST.bdf(jBin).rt(indxbin, nLoop) = 1000*(temp_rt_time(nLoop) - EVENTLIST.eventinfo(iLogitem).time); %*************************
                                                                EVENTLIST.bdf(jBin).rtitem(indxbin, nLoop) = rtpointer(nLoop);
                                                                EVENTLIST.bdf(jBin).rtflag(indxbin, nLoop) = EVENTLIST.eventinfo(rtpointer(nLoop)).flag; % EEG
                                                                EVENTLIST.bdf(jBin).rthomeitem(indxbin, nLoop) = iLogitem;
                                                                EVENTLIST.bdf(jBin).rthomeflag(indxbin, nLoop) = EVENTLIST.eventinfo(iLogitem).flag; % EEG
                                                                EVENTLIST.bdf(jBin).rthomecode(indxbin, nLoop) = EVENTLIST.eventinfo(iLogitem).code; % EEG
                                                                EVENTLIST.bdf(jBin).rtbini(indxbin, nLoop) = jBin;
                                                                EVENTLIST.bdf(jBin).rtcode(indxbin, nLoop) = temp_rt_code(nLoop);
                                                        end
                                                end
                                        end % reaction time                                        
                                end % isdetectedLES
                        end  % conditions for BIN checking
                end  % BIN's loop
        elseif cd1 && ~cd2 %02-09-2009  checks ignored Codes
                EVENTLIST.eventinfo(iLogitem).enable = 0;
        elseif ~cd1 && cd2 %02-09-2009  checks forbidden Codes
                EVENTLIST.eventinfo(iLogitem).enable = -1;
        else % forbidden
                EVENTLIST.eventinfo(iLogitem).enable = -1;
        end % checks enable condition  10-16-2008      
        % write bin number in EVENTLIST.eventinfo(iLogitem).bini
        if isempty(binrow)
                EVENTLIST.eventinfo(iLogitem).bini = -1;
                % Creates BIN LABELS
                binName = '""';
        else
                EVENTLIST.eventinfo(iLogitem).bini = binrow;
                % Creates BIN LABELS
                auxname = num2str(binrow);
                bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % inserts a comma instead blank space
                
                if strcmp(EVENTLIST.eventinfo(iLogitem).codelabel,'""')
                        binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(iLogitem).code) ')']; %B#(code)
                else
                        binName = ['B' bname '(' EVENTLIST.eventinfo(iLogitem).codelabel ')']; %B#(codelabel)
                end
        end
        
        EVENTLIST.eventinfo(iLogitem).binlabel = binName;
        binrow = [];        
        
        %         tiempostim(iLogitem) = toc;       
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
