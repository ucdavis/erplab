%  binlister_smart
%
%  Unified, smarter binlister engine that replaces neobinlister2
%  and neobinlister2_fast with a single function.
%
%  The function detects the complexity of the bin descriptor file (BDF) at
%  startup and selects the appropriate processing path:
%
%  FAST PATH  (more simple cases):
%    - Pre-filters event list to home (time-locking) codes only
%    - Uses vectorized time-window matching (checkBINfnc)
%    - many times faster than the slow path
%    - Used when BDF has no RT specs, no flag conditions, no flag writing,
%      and no forbidden codes within timed sequences
%
%  SLOW PATH  (full-featured fallback):
%    - Used when BDF requires RT measurement, flag testing/writing, or
%      forbidden-code detection inside timed windows
%    - Still applies the home-code pre-filter
%      and pre-extracts event arrays vectorially to reduce struct overhead
%    - Should have identical output to neobinlister2 in all cases
%%
%  Author: Kurt Winsler
%  Based on neobinlister2 (Javier Lopez-Calderon & Steven Luck, 2009)
%  and neobinlister2_fast (Christoph Huber-Huber, 2018)
%
%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
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

function [EEG, EVENTLIST, binOfBins, isparsenum] = binlister_smart(EEG, bdfilename, eventlistFile, neweventlistFile, forbiddenCodeArray, ignoreCodeArray, indexEL, validateMode)
%
% validateMode (optional, default false):
%   When true, both binlister_smart AND neobinlister2 are run on the same
%   input, their outputs are compared field-by-field, and timing for each
%   is printed to the command window. Any discrepancies are reported as
%   warnings. Use this to validate correctness if new version of binlister is in question.

%   Can only be used if binlister_smart is called directly (not through pop_binlister)
%   Validate mode usage:
%     binlister_smart(EEG, 'BDF.txt', 'none', 'none', [], [], 1, true);

binOfBins  = [];
EVENTLIST  = [];
isparsenum = 1;

if nargin < 1
        help pop_binlister
        return
end
if nargin < 8
        validateMode = false;
end
if nargin < 7
        indexEL = 1;
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
        error('ERPLAB says: binlister_smart needs at least 2 inputs.')
end

version = geterplabversion;

if isempty(bdfilename)
        error('ERPLAB says: bdfilename is empty.')
end

% No longer writing backup eventlist files to erplab_Box
if ismember(neweventlistFile, {'none', 'no', ''})
        neweventlistFile = 'none';
end

%
% Parse and decode the bin descriptor file
%
[BIN, nwrongbins] = decodebdf(bdfilename);
if nwrongbins == 0
        % allowMixedSigns=true: allows codes with different signs (~) in
        % the same {}, needed for checkBINfnc's mixed-sign branch.
        [BIN, isparsenum] = bdf2struct(BIN, 1);
        if isparsenum == 0
                return
        end
else
        isparsenum = 0;
        return
end

%
% Read EVENTLIST
%
if ismember(eventlistFile, {'none', 'no', ''})
        if iserpstruct(EEG)
                EVENTLIST = exporterpeventlist(EEG, indexEL);
                fprintf('\n*** binlister_smart is taking EVENTLIST from the current ERPset.\n\n')
        else
                [EEGx, EVENTLIST] = creaeventlist(EEG);
                clear EEGx
        end
else
        [EEGx, EVENTLIST] = readeventlist(EEG, eventlistFile);
        clear EEGx
end

EVENTLIST.bdf = BIN;

%
% Report file setup (reporting not supported in binlister_smart)
%
bdfcrono = datestr(now, 'mmmm dd, yyyy HH:MM:SS AM');
rnameAux = '';

%
% User login (for EVENTLIST metadata)
%
if ispc
        userdir   = winqueryreg('HKEY_CURRENT_USER', ...
                ['Software\Microsoft\Windows\CurrentVersion\' ...
                'Explorer\Shell Folders'], 'Personal');
        userlogin = regexprep(userdir, '.*\', '');
else
        userdir   = char(java.lang.System.getProperty('user.home'));
        userlogin = regexprep(userdir, '.*/', '');
end

%
% Basic counts
%
nbin  = length(BIN);
nitem = length(EVENTLIST.eventinfo);
binOfBins = zeros(1, nbin);

%
% EVENTLIST metadata
%
EVENTLIST.bdfname  = bdfilename;

if isfield(EEG, 'setname')
        if strcmpi(EEG.setname, '')
                EVENTLIST.setname = 'no_data';
        else
                EVENTLIST.setname = EEG.setname;
        end
elseif isfield(EEG, 'erpname')
        if strcmpi(EEG.erpname, '')
                EVENTLIST.setname = 'no_data';
        else
                EVENTLIST.setname = EEG.erpname;
        end
else
        EVENTLIST.setname = 'no_data';
end

EVENTLIST.elname  = neweventlistFile;
EVENTLIST.report  = rnameAux;
EVENTLIST.version = version;
EVENTLIST.eldate  = bdfcrono;
EVENTLIST.account = userlogin;

%
% Initialise ALL eventinfo items to bini=-1, binlabel='""'
% This is required so that non-home events have proper values
% (the main loop only visits home-code events)
%
for iInit = 1:nitem
        EVENTLIST.eventinfo(iInit).bini     = -1;
        EVENTLIST.eventinfo(iInit).binlabel = '""';
end

%
% Pre-extract event arrays for fast vectorised access (helps both paths)
%
itemEnable = [EVENTLIST.eventinfo.enable];
itemCodes  = [EVENTLIST.eventinfo.code];
itemTimes  = [EVENTLIST.eventinfo.time] * 1000; % convert s -> ms

%
% Apply forbidden / ignore enable flags back to EVENTLIST
% (neobinlister2 does this in the else-branches of its main loop;
%  we do it upfront so the main loop only processes eligible events)
%
cd1array = itemEnable ~= -1 & ~ismember_bc2(itemCodes, forbiddenCodeArray);
cd2array = itemEnable ~= 0  & ~ismember_bc2(itemCodes, ignoreCodeArray);

forbiddenItems = find(~cd1array);
ignoredItems   = find( cd1array & ~cd2array);
for ii = forbiddenItems
        EVENTLIST.eventinfo(ii).enable = -1;
end
for ii = ignoredItems
        EVENTLIST.eventinfo(ii).enable = 0;
end
% Refresh after modifications
itemEnable = [EVENTLIST.eventinfo.enable];

%
% Detect which path is needed, based on BDF content
%
hasRT = isfield(BIN, 'rtname') && any(~cellfun(@isempty, {BIN.rtname}));

hasFlagConds = false;
hasFlagWrite = false;
hasTimedSeqs = false;
for jB = 1:nbin
        for les = {'prehome', 'posthome', 'athome'}
                seq = BIN(jB).(les{1});
                if isempty(seq), continue; end
                for kS = 1:length(seq)
                        if any(seq(kS).flagmask  ~= 0), hasFlagConds = true; end
                        if any(seq(kS).writemask ~= 0), hasFlagWrite = true; end
                        if any(seq(kS).timecode  ~= -1), hasTimedSeqs = true; end
                end
        end
end
% Forbidden codes inside timed windows need the slow path's timetest2 logic
hasForbiddenInTime = ~isempty(forbiddenCodeArray) && hasTimedSeqs;

% Ignore codes have complex "transparent pass-through" semantics: an ignored
% event advances the sequencer step without matching, which cannot be
% replicated in checkBINfnc's vectorized approach.
hasIgnoreCodes = ~isempty(ignoreCodeArray);

useFastPath = ~hasRT && ~hasFlagConds && ~hasFlagWrite && ~hasForbiddenInTime && ~hasIgnoreCodes;

%
% Pre-compute the set of home event codes across all bins
% (used to restrict the outer loop to only relevant events in both paths)
% athome.eventcode may be a vector (multiple codes in one {}), so we
% concatenate across bins rather than using arrayfun.
%
allAtHomeCodes = unique(cell2mat(arrayfun(@(b) double(b.athome(1).eventcode(:))', BIN, 'UniformOutput', false)));

% If any bin uses an all-negated home (e.g. .{~11} with no positive codes),
% the home can match ANY event code, so we cannot pre-filter by code.
hasAllNegatedHome = any(arrayfun(@(b) nnz(b.athome(1).eventsign) == 0, BIN));

% Eligible home items: not forbidden, not ignored, not boundary
% If any bin has an all-negated home, all valid events are candidates.
if hasAllNegatedHome
        homeItemIdx = find(cd1array & cd2array & itemCodes ~= -99);
else
        homeItemIdx = find(cd1array & cd2array & itemCodes ~= -99 & ismember(itemCodes, allAtHomeCodes));
end

%
% Progress display
%
fprintf('\n');
fprintf([repmat('*', 1, 45) '\n']);
fprintf('**\n');
if useFastPath
        fprintf('** Binlister progress (fast path)......\n');
else
        if hasRT
                fprintf('** Binlister progress (RT mode - standard path)......\n');
        elseif hasIgnoreCodes
                fprintf('** Binlister progress (ignore codes - standard path)......\n');
        else
                fprintf('** Binlister progress (flag/forbidden mode - standard path)......\n');
        end
end
ppaux = 1;
tStart = tic;

% =========================================================================
%  FAST PATH
% =========================================================================
if useFastPath

        for iLogitem = homeItemIdx

                % Progress
                pp = round((iLogitem / nitem) * 100);
                if pp >= 0 && mod(pp, 5) == 0 && ppaux ~= pp
                        numze = ceil(log10(pp + 1)) - 1;
                        nstepback = 3 + numze;
                        fprintf([repmat('\b', 1, nstepback) '%d%%\n'], pp);
                        ppaux = pp;
                end

                belongsToBins = [];
                for jBin = 1:nbin
                        if checkBINfnc(iLogitem, itemCodes, itemTimes, BIN(jBin), itemEnable)
                                belongsToBins(end+1) = jBin; %#ok<AGROW>
                                binOfBins(jBin) = binOfBins(jBin) + 1;
                        end
                end

                if isempty(belongsToBins)
                        EVENTLIST.eventinfo(iLogitem).bini     = -1;
                        EVENTLIST.eventinfo(iLogitem).binlabel = '""';
                else
                        EVENTLIST.eventinfo(iLogitem).bini = belongsToBins;
                        auxname = num2str(belongsToBins);
                        bname   = regexprep(auxname, '\s+', ',', 'ignorecase');
                        if strcmp(EVENTLIST.eventinfo(iLogitem).codelabel, '""')
                                binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(iLogitem).code) ')'];
                        else
                                binName = ['B' bname '(' EVENTLIST.eventinfo(iLogitem).codelabel ')'];
                        end
                        EVENTLIST.eventinfo(iLogitem).binlabel = binName;
                end

        end

% =========================================================================
%  SLOW PATH  (RT / flags / forbidden-in-time)
% =========================================================================
else

        for iLogitem = homeItemIdx

                % Progress
                pp = round((iLogitem / nitem) * 100);
                if pp >= 0 && mod(pp, 5) == 0 && ppaux ~= pp
                        numze = ceil(log10(pp + 1)) - 1;
                        nstepback = 3 + numze;
                        fprintf([repmat('\b', 1, nstepback) '%d%%\n'], pp);
                        ppaux = pp;
                end

                % cond3: not a boundary event (-99)
                if itemCodes(iLogitem) == -99, continue; end

                binrow = [];

                for jBin = 1:nbin
                        writeflag = []; writeindx = [];

                        % Basic feasibility checks
                        cond1 = iLogitem > length(BIN(jBin).prehome);
                        cond2 = (nitem - iLogitem) >= length(BIN(jBin).posthome);
                        if ~(cond1 && cond2), continue; end

                        % ----- HOME detection -----
                        isallcode  = ~isempty(find(BIN(jBin).athome(1).eventcode == -7,  1));
                        isnonecode = ~isempty(find(BIN(jBin).athome(1).eventcode == -13, 1));

                        if isallcode
                                ishomedetected    = 1;
                                ishomeFlagdetected = 1;
                                binOfBins(1, jBin) = binOfBins(1, jBin) + 1;
                        elseif isnonecode
                                ishomedetected    = 0;
                                ishomeFlagdetected = 0;
                        else
                                nDesiredCodes   = nnz(BIN(jBin).athome(1).eventsign);
                                ishomedetected  = ~isempty(find(BIN(jBin).athome(1).eventcode == itemCodes(iLogitem), 1));
                                if nDesiredCodes == 0
                                        ishomedetected = ~ishomedetected;
                                end
                                ishomeFlagdetected = flagTest(BIN, EVENTLIST, 'athome', 1, jBin, iLogitem);
                                [writeflag, writeindx] = writeTest(BIN, EVENTLIST, 'athome', 1, jBin, iLogitem, writeflag, writeindx);
                        end

                        if ishomedetected && ishomeFlagdetected
                                isdetectedLES = 1;
                                traffic(1) = -1;
                                traffic(2) =  1;
                        else
                                isdetectedLES = 0;
                        end

                        les    = {'prehome', 'posthome'};
                        nLes   = 2;
                        kles   = 1;
                        capcodeatles = cell(2, 1);

                        while (kles <= nLes) && isdetectedLES

                                offsetLogitem = 1;
                                nSequencer    = length(BIN(jBin).(les{kles}));

                                if kles == 1
                                        previous_t2 = max([EVENTLIST.eventinfo.time]);
                                else
                                        previous_t2 = 0;
                                end

                                kSeq            = 1;
                                islastsequencer = 0;

                                while (kSeq <= nSequencer) && isdetectedLES

                                        targetLogPointer = iLogitem + traffic(kles) * offsetLogitem;

                                        if targetLogPointer > nitem
                                                isdetectedLES = 0;
                                                break
                                        end

                                        targetLogCode = itemCodes(targetLogPointer);
                                        isignoredc    = ismember(targetLogCode, ignoreCodeArray);
                                        isforbiddenc  = ismember(targetLogCode, forbiddenCodeArray);

                                        if isforbiddenc
                                                isdetectedLES = 0;
                                                break
                                        end

                                        if itemEnable(targetLogPointer) ~= -1 && ~isignoredc

                                                if kles == 1
                                                        mSeq = nSequencer - kSeq + 1;
                                                else
                                                        mSeq = kSeq;
                                                end

                                                nDesiredCodes        = nnz(BIN(jBin).(les{kles})(mSeq).eventsign);
                                                targetEventCodeArray = BIN(jBin).(les{kles})(mSeq).eventcode;
                                                rc = find(targetEventCodeArray == targetLogCode, 1);

                                                if nDesiredCodes > 0
                                                        isnegated    = 0;
                                                        ispqdetected = ~isempty(rc);
                                                else
                                                        isnegated    = 1;
                                                        ispqdetected = isempty(rc);
                                                        if ispqdetected
                                                                rc = find(targetEventCodeArray ~= targetLogCode, 1);
                                                        end
                                                end

                                                rt_tc    = find(BIN(jBin).(les{kles})(mSeq).timecode ~= -1, 1);
                                                istimed  = ~isempty(rt_tc);

                                                if kSeq == nSequencer
                                                        islastsequencer = 1;
                                                end
                                                if ~ispqdetected
                                                        isdetectedLES = 0;
                                                end

                                                CA =  isdetectedLES &&  istimed && ~isnegated;
                                                CB = (~isdetectedLES &&  istimed && ~isnegated) ...
                                                  || ( isdetectedLES &&  istimed &&  isnegated) ...
                                                  || (~isdetectedLES &&  istimed &&  isnegated);
                                                CC = ~isdetectedLES && ~istimed;

                                                if CA
                                                        tempi = BIN(jBin).(les{kles})(mSeq).timecode(rc, 1:2);
                                                        t1 = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1, 2^(2-kles)) / 1000;
                                                        t2 = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1, kles) / 1000;

                                                        if kles == 1
                                                                if t2 > previous_t2, t2 = previous_t2; end
                                                        else
                                                                if t1 < previous_t2, t1 = previous_t2; end
                                                        end

                                                        if t1 > t2
                                                                isdetectedLES = 0;
                                                        else
                                                                targetLogTime = EVENTLIST.eventinfo(targetLogPointer).time;
                                                                if targetLogTime >= t1 && targetLogTime <= t2
                                                                        if targetLogPointer > 1 && targetLogPointer < nitem
                                                                                previous_t2 = EVENTLIST.eventinfo(targetLogPointer + traffic(kles)).time;
                                                                        end
                                                                        [ishomeFlagdetected, ~] = flagTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer);
                                                                        [writeflag, writeindx]  = writeTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer, writeflag, writeindx);
                                                                        if ~ishomeFlagdetected
                                                                                isdetectedLES = 0;
                                                                        end
                                                                else
                                                                        [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = ...
                                                                                timetest2(EVENTLIST, BIN, les, isnegated, previous_t2, iLogitem, traffic, islastsequencer, ...
                                                                                writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, forbiddenCodeArray, targetLogPointer, targetEventCodeArray);
                                                                end
                                                        end

                                                elseif CB
                                                        [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = ...
                                                                timetest2(EVENTLIST, BIN, les, isnegated, previous_t2, iLogitem, traffic, islastsequencer, ...
                                                                writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, forbiddenCodeArray, targetLogPointer, targetEventCodeArray);

                                                elseif CC
                                                        [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer);
                                                        [writeflag, writeindx]     = writeTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer, writeflag, writeindx);
                                                        if ~ishomeFlagdetected && flgx && isnegated
                                                                isdetectedLES = 1;
                                                        end

                                                else  % Successful detection, no time spec
                                                        [ishomeFlagdetected, ~] = flagTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer);
                                                        [writeflag, writeindx]  = writeTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer, writeflag, writeindx);
                                                        if isnegated
                                                                isdetectedLES = 1;
                                                        else
                                                                if ~ishomeFlagdetected
                                                                        isdetectedLES = 0;
                                                                end
                                                        end
                                                        if ~islastsequencer && ~isnegated
                                                                previous_t2 = EVENTLIST.eventinfo(targetLogPointer + traffic(kles)).time;
                                                        end
                                                end

                                                kSeq = kSeq + 1;

                                        elseif itemEnable(targetLogPointer) == -1 || isforbiddenc
                                                isdetectedLES = 0;
                                        else
                                                % ignored event - skip over it
                                                kSeq = kSeq + 1;
                                        end

                                        offsetLogitem = offsetLogitem + 1;

                                        if isdetectedLES && ~isignoredc
                                                capcodeatles{kles, mSeq} = targetLogPointer;
                                        end

                                end % sequencer loop

                                kles = kles + 1;

                        end % prehome/posthome loop

                        % ----- Bin matched -----
                        if isdetectedLES

                                % Write flags back to EVENTLIST
                                if ~isempty(writeindx)
                                        wrf = num2cell(writeflag);
                                        [EVENTLIST.eventinfo(writeindx).flag] = wrf{:};
                                end

                                binOfBins(1, jBin) = binOfBins(1, jBin) + 1;
                                indxbin = binOfBins(1, jBin);
                                binrow  = cat(2, binrow, jBin);

                                % RT measurement
                                if hasRT && ~isempty(BIN(jBin).rtname)
                                        rtpointer    = [capcodeatles{2, BIN(jBin).rtindex}];
                                        temp_rt_time = [EVENTLIST.eventinfo(rtpointer).time];
                                        temp_rt_code = [EVENTLIST.eventinfo(rtpointer).code];
                                        for nLoop = 1:length(temp_rt_time)
                                                EVENTLIST.bdf(jBin).rt(indxbin, nLoop)         = 1000 * (temp_rt_time(nLoop) - EVENTLIST.eventinfo(iLogitem).time);
                                                EVENTLIST.bdf(jBin).rtitem(indxbin, nLoop)      = rtpointer(nLoop);
                                                EVENTLIST.bdf(jBin).rtflag(indxbin, nLoop)      = EVENTLIST.eventinfo(rtpointer(nLoop)).flag;
                                                EVENTLIST.bdf(jBin).rthomeitem(indxbin, nLoop)  = iLogitem;
                                                EVENTLIST.bdf(jBin).rthomeflag(indxbin, nLoop)  = EVENTLIST.eventinfo(iLogitem).flag;
                                                EVENTLIST.bdf(jBin).rthomecode(indxbin, nLoop)  = EVENTLIST.eventinfo(iLogitem).code;
                                                EVENTLIST.bdf(jBin).rtbini(indxbin, nLoop)      = jBin;
                                                EVENTLIST.bdf(jBin).rtcode(indxbin, nLoop)      = temp_rt_code(nLoop);
                                        end
                                end

                        end % isdetectedLES

                end % bin loop

                % Write bini and binlabel for this item
                if isempty(binrow)
                        EVENTLIST.eventinfo(iLogitem).bini     = -1;
                        EVENTLIST.eventinfo(iLogitem).binlabel = '""';
                else
                        EVENTLIST.eventinfo(iLogitem).bini = binrow;
                        auxname = num2str(binrow);
                        bname   = regexprep(auxname, '\s+', ',', 'ignorecase');
                        if strcmp(EVENTLIST.eventinfo(iLogitem).codelabel, '""')
                                binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(iLogitem).code) ')'];
                        else
                                binName = ['B' bname '(' EVENTLIST.eventinfo(iLogitem).codelabel ')'];
                        end
                        EVENTLIST.eventinfo(iLogitem).binlabel = binName;
                end

        end % home-item loop

end % path selection

fprintf('\n');
tSmartSec = toc(tStart);

%
% Finalise EVENTLIST
%
EVENTLIST.trialsperbin = binOfBins;
EVENTLIST.nbin         = nbin;

% Simplify bin descriptor expressions
for i = 1:nbin
        expcell = EVENTLIST.bdf(i).expression;
        EVENTLIST.bdf(i).expression = [expcell{1} '.' expcell{2} expcell{3}];
end

% Write text EVENTLIST output and update structure
if iserpstruct(EEG)
        EVENTLIST = EEG.EVENTLIST(indexEL);
        exporterpeventlist(EEG, indexEL, neweventlistFile);
else
        [EEGx, EVENTLIST] = creaeventlist(EEG, EVENTLIST, neweventlistFile);
        clear EEGx
end

fprintf('Successful Trials per bin :\t%s\n', num2str(binOfBins));

%
% VALIDATION MODE: run neobinlister2 on the same input, compare outputs
%
if validateMode
        fprintf('\n');
        fprintf([repmat('=', 1, 55) '\n']);
        fprintf('  BINLISTER VALIDATION MODE\n');
        fprintf([repmat('=', 1, 55) '\n']);
        fprintf('  binlister_smart path : %s\n', ternary(useFastPath, 'FAST', 'SLOW'));
        fprintf('  binlister_smart time : %.3f s\n', tSmartSec);
        fprintf('  Running neobinlister2 for comparison...\n\n');

        tRef = tic;
        [~, EVENTLIST_ref, binOfBins_ref, ~] = neobinlister2(EEG, bdfilename, eventlistFile, ...
                'none', forbiddenCodeArray, ignoreCodeArray, 0, indexEL);
        tRefSec = toc(tRef);

        fprintf('  neobinlister2 time   : %.3f s\n', tRefSec);
        fprintf('  Speed-up             : %.1fx\n', tRefSec / max(tSmartSec, 1e-6));
        fprintf([repmat('-', 1, 55) '\n']);

        % Compare outputs
        nDiffs = compareEventLists(EVENTLIST, EVENTLIST_ref, binOfBins, binOfBins_ref);

        if nDiffs == 0
                fprintf('  RESULT: OUTPUTS MATCH EXACTLY. Validation passed.\n');
        else
                fprintf('  RESULT: %d DISCREPANC%s FOUND. See warnings above.\n', ...
                        nDiffs, ternary(nDiffs == 1, 'Y', 'IES'));
        end
        fprintf([repmat('=', 1, 55) '\n\n']);
end


% =========================================================================
%  VALIDATION HELPERS
% =========================================================================

function nDiffs = compareEventLists(EL, EL_ref, binOfBins, binOfBins_ref)
% Compare two EVENTLIST structures field by field and report differences.
% Returns the total number of discrepancies found.

nDiffs = 0;

% --- binOfBins ---
if ~isequal(binOfBins, binOfBins_ref)
        nDiffs = nDiffs + 1;
        warning('binlister_smart:validation', ...
                'MISMATCH in binOfBins:\n  smart : %s\n  ref   : %s', ...
                num2str(binOfBins), num2str(binOfBins_ref));
else
        fprintf('  binOfBins            : OK  %s\n', mat2str(binOfBins));
end

% --- trialsperbin ---
if ~isequal(EL.trialsperbin, EL_ref.trialsperbin)
        nDiffs = nDiffs + 1;
        warning('binlister_smart:validation', 'MISMATCH in EVENTLIST.trialsperbin');
else
        fprintf('  trialsperbin         : OK\n');
end

% --- nbin ---
if ~isequal(EL.nbin, EL_ref.nbin)
        nDiffs = nDiffs + 1;
        warning('binlister_smart:validation', 'MISMATCH in EVENTLIST.nbin');
else
        fprintf('  nbin                 : OK  (%d)\n', EL.nbin);
end

% --- eventinfo fields ---
nitem = length(EL.eventinfo);
nitem_ref = length(EL_ref.eventinfo);
if nitem ~= nitem_ref
        nDiffs = nDiffs + 1;
        warning('binlister_smart:validation', ...
                'MISMATCH in eventinfo length: smart=%d, ref=%d', nitem, nitem_ref);
        return  % Can't compare item by item
end

biniMismatches   = 0;
binlabelMismatches = 0;
flagMismatches   = 0;
enableMismatches = 0;

for ii = 1:nitem
        % bini
        bi_s = EL.eventinfo(ii).bini;
        bi_r = EL_ref.eventinfo(ii).bini;
        if ~isequal(bi_s, bi_r)
                biniMismatches = biniMismatches + 1;
                if biniMismatches <= 5  % only show first few
                        warning('binlister_smart:validation', ...
                                'bini mismatch at item %d: smart=%s  ref=%s', ...
                                ii, mat2str(bi_s), mat2str(bi_r));
                end
        end
        % binlabel
        if ~strcmp(EL.eventinfo(ii).binlabel, EL_ref.eventinfo(ii).binlabel)
                binlabelMismatches = binlabelMismatches + 1;
                if binlabelMismatches <= 5
                        warning('binlister_smart:validation', ...
                                'binlabel mismatch at item %d: smart="%s"  ref="%s"', ...
                                ii, EL.eventinfo(ii).binlabel, EL_ref.eventinfo(ii).binlabel);
                end
        end
        % flag
        if ~isequal(EL.eventinfo(ii).flag, EL_ref.eventinfo(ii).flag)
                flagMismatches = flagMismatches + 1;
                if flagMismatches <= 5
                        warning('binlister_smart:validation', ...
                                'flag mismatch at item %d: smart=%d  ref=%d', ...
                                ii, EL.eventinfo(ii).flag, EL_ref.eventinfo(ii).flag);
                end
        end
        % enable
        if ~isequal(EL.eventinfo(ii).enable, EL_ref.eventinfo(ii).enable)
                enableMismatches = enableMismatches + 1;
                if enableMismatches <= 5
                        warning('binlister_smart:validation', ...
                                'enable mismatch at item %d: smart=%d  ref=%d', ...
                                ii, EL.eventinfo(ii).enable, EL_ref.eventinfo(ii).enable);
                end
        end
end

if biniMismatches == 0
        fprintf('  eventinfo.bini       : OK  (%d items checked)\n', nitem);
else
        nDiffs = nDiffs + biniMismatches;
        fprintf('  eventinfo.bini       : %d MISMATCHES\n', biniMismatches);
end
if binlabelMismatches == 0
        fprintf('  eventinfo.binlabel   : OK\n');
else
        nDiffs = nDiffs + binlabelMismatches;
        fprintf('  eventinfo.binlabel   : %d MISMATCHES\n', binlabelMismatches);
end
if flagMismatches == 0
        fprintf('  eventinfo.flag       : OK\n');
else
        nDiffs = nDiffs + flagMismatches;
        fprintf('  eventinfo.flag       : %d MISMATCHES\n', flagMismatches);
end
if enableMismatches == 0
        fprintf('  eventinfo.enable     : OK\n');
else
        nDiffs = nDiffs + enableMismatches;
        fprintf('  eventinfo.enable     : %d MISMATCHES\n', enableMismatches);
end

% --- RT fields (only if present in ref) ---
if isfield(EL_ref.bdf, 'rt')
        rtDiffs = 0;
        for jBin = 1:length(EL.bdf)
                has_s = isfield(EL.bdf(jBin),     'rt') && ~isempty(EL.bdf(jBin).rt);
                has_r = isfield(EL_ref.bdf(jBin), 'rt') && ~isempty(EL_ref.bdf(jBin).rt);
                if has_s && has_r
                        if ~isequal(EL.bdf(jBin).rt,        EL_ref.bdf(jBin).rt)        || ...
                           ~isequal(EL.bdf(jBin).rtitem,     EL_ref.bdf(jBin).rtitem)    || ...
                           ~isequal(EL.bdf(jBin).rtflag,     EL_ref.bdf(jBin).rtflag)    || ...
                           ~isequal(EL.bdf(jBin).rthomeitem, EL_ref.bdf(jBin).rthomeitem)|| ...
                           ~isequal(EL.bdf(jBin).rthomeflag, EL_ref.bdf(jBin).rthomeflag)|| ...
                           ~isequal(EL.bdf(jBin).rthomecode, EL_ref.bdf(jBin).rthomecode)|| ...
                           ~isequal(EL.bdf(jBin).rtbini,     EL_ref.bdf(jBin).rtbini)    || ...
                           ~isequal(EL.bdf(jBin).rtcode,     EL_ref.bdf(jBin).rtcode)
                                rtDiffs = rtDiffs + 1;
                                warning('binlister_smart:validation', ...
                                        'RT field mismatch in bin %d', jBin);
                        end
                elseif has_s ~= has_r
                        rtDiffs = rtDiffs + 1;
                        warning('binlister_smart:validation', ...
                                'RT field presence mismatch in bin %d: smart=%d ref=%d', jBin, has_s, has_r);
                end
        end
        if rtDiffs == 0
                fprintf('  bdf RT fields        : OK\n');
        else
                nDiffs = nDiffs + rtDiffs;
                fprintf('  bdf RT fields        : %d MISMATCHES\n', rtDiffs);
        end
end

% --- bdf.expression ---
exprDiffs = 0;
for jBin = 1:min(length(EL.bdf), length(EL_ref.bdf))
        if ~isequal(EL.bdf(jBin).expression, EL_ref.bdf(jBin).expression)
                exprDiffs = exprDiffs + 1;
        end
end
if exprDiffs == 0
        fprintf('  bdf.expression       : OK\n');
else
        nDiffs = nDiffs + exprDiffs;
        fprintf('  bdf.expression       : %d MISMATCHES\n', exprDiffs);
end


% =========================================================================

function s = ternary(cond, a, b)
% Simple ternary helper: returns a if cond is true, b otherwise.
if cond
        s = a;
else
        s = b;
end


% =========================================================================
%  FAST PATH: Check whether an item belongs to a given bin
%  (vectorised time-window matching, no flag/RT support)
%  Adapted from neobinlister2_fast (Christoph Huber-Huber, 2018)
% =========================================================================

function binok = checkBINfnc(iLogitem, itemCodes, itemTimes, B, itemEnable)

binok = false;
preok = false;
postok = false;

% itemEnable==0 means ignored: transparent to sequence matching
% Build a logical mask of non-ignored items for timed window scanning
if nargin < 5
        itemEnable = ones(size(itemCodes));
end
notIgnored = (itemEnable ~= 0);  % row vector matching itemCodes/itemTimes orientation

% ----- HOME code check (must match before checking pre/posthome) -----
isallcode  = any(B.athome(1).eventcode == -7);   % take-all (*)
isnonecode = any(B.athome(1).eventcode == -13);  % take-nothing (~*)

if isnonecode
        return  % never matches
end

if ~isallcode
        nDesiredCodes  = nnz(B.athome(1).eventsign);
        ishomedetected = any(B.athome(1).eventcode == itemCodes(iLogitem));
        if nDesiredCodes == 0
                ishomedetected = ~ishomedetected;  % all-negated home
        end
        if ~ishomedetected
                return
        end
end
% (take-all falls through: home is always detected)

iLogitemTime = itemTimes(iLogitem);
ip           = iLogitem - 1;
prehi        = numel(B.prehome);
preTimeLimit = -1;  % relative ms: upper bound for prehome events

while ip > 0 && prehi > 0

        if numel(unique(B.prehome(prehi).eventsign)) == 1
                % All event codes in this sequencer have the same sign
                thisPreSign = all(B.prehome(prehi).eventsign);

                currentTimeWindowPos = unique(B.prehome(prehi).timecode, 'rows');
                if size(currentTimeWindowPos, 1) ~= 1
                        error('''timecode'' not unique across ''eventcodes'' of current ''prehome''');
                end
                currentTimeWindowNeg = sort(-1 * currentTimeWindowPos);

                if thisPreSign
                        currentTimeWindowPresent    = currentTimeWindowNeg;
                        currentTimeWindowPresent(2) = min([preTimeLimit, currentTimeWindowNeg(2)]);
                        currentTimeWindow = currentTimeWindowPresent;
                else
                        currentTimeWindow = currentTimeWindowNeg;
                end

                if all(unique(B.prehome(prehi).timecode, 'rows') >= 0)
                        % Timed sequencer (exclude ignored events)
                        currentIdx      = (itemTimes - iLogitemTime) >= currentTimeWindow(1) & ...
                                          (itemTimes - iLogitemTime) <= currentTimeWindow(2) & notIgnored;
                        currentCodes    = itemCodes(currentIdx);
                        currentTimesRel = itemTimes(currentIdx) - iLogitemTime;

                        if thisPreSign
                                if any(ismember(currentCodes, B.prehome(prehi).eventcode))
                                        preTimeLimit = max(currentTimesRel(ismember(currentCodes, B.prehome(prehi).eventcode)));
                                        prehi = prehi - 1;
                                else
                                        return
                                end
                        else
                                if any(ismember(currentCodes, B.prehome(prehi).eventcode))
                                        return
                                else
                                        prehi = prehi - 1;
                                end
                        end
                else
                        % Untimed sequencer: check event immediately before, skipping ignored events
                        while ip > 0 && ~notIgnored(ip)
                                ip = ip - 1;
                        end
                        if ip < 1, return; end
                        if any(ismember(itemCodes(ip), B.prehome(prehi).eventcode))
                                prehi = prehi - 1;
                                ip    = ip - 1;
                        else
                                return
                        end
                end

        else
                % Mixed-sign sequencer (e.g. {~21;22}): requires time spec
                if size(B.prehome(prehi).timecode, 1) ~= 1
                        error('''timecode'' not unique across ''eventcodes'' of current ''prehome''');
                end
                if ~all(unique(B.prehome(prehi).timecode, 'rows') >= 0)
                        error('Time specification required when mixing required and prohibited codes in one {}-term');
                end

                eventProhibitedIdx = B.prehome(prehi).eventsign == 0;
                eventRequiredIdx   = B.prehome(prehi).eventsign == 1;

                currentTimeWindowPos = unique(double(B.prehome(prehi).timecode), 'rows');
                currentTimeWindowNeg = sort(-1 * currentTimeWindowPos);
                currentTimeWindow    = [currentTimeWindowNeg(1), min([preTimeLimit, currentTimeWindowNeg(2)])];

                currentIdx = (itemTimes - iLogitemTime) >= currentTimeWindow(1) & ...
                             (itemTimes - iLogitemTime) <= currentTimeWindow(2) & notIgnored;

                currentRequiredIdx   = currentIdx & ismember(itemCodes, B.prehome(prehi).eventcode(eventRequiredIdx));
                currentProhibitedIdx = currentIdx & ismember(itemCodes, B.prehome(prehi).eventcode(eventProhibitedIdx));
                currentCodesRequired    = itemCodes(currentRequiredIdx);
                currentCodesProhibited  = itemCodes(currentProhibitedIdx);

                if ~isempty(currentCodesRequired)
                        currentTimesRequiredRel      = itemTimes(currentRequiredIdx) - iLogitemTime;
                        currentTimesRequiredRelLimit = max(currentTimesRequiredRel);
                        if ~isempty(currentCodesProhibited)
                                currentTimesProhibitedRel = itemTimes(currentProhibitedIdx) - iLogitemTime;
                                if all(currentTimesProhibitedRel < currentTimesRequiredRelLimit | ...
                                       currentTimesProhibitedRel > currentTimeWindowNeg(2))
                                        preTimeLimit = currentTimesRequiredRelLimit;
                                        prehi = prehi - 1;
                                else
                                        return
                                end
                        else
                                preTimeLimit = currentTimesRequiredRelLimit;
                                prehi = prehi - 1;
                        end
                else
                        return
                end
        end
end

if prehi == 0
        preok = true;
end

% ----- posthome -----
ip           = iLogitem + 1;
posthi       = 1;
postTimeLimit = 1;

while ip <= numel(itemCodes) && posthi <= numel(B.posthome)

        if numel(unique(B.posthome(posthi).eventsign)) == 1
                thisPostSign = all(B.posthome(posthi).eventsign);

                currentTimeWindow = unique(B.posthome(posthi).timecode, 'rows');
                if size(currentTimeWindow, 1) ~= 1
                        error('''timecode'' not unique across ''eventcodes'' of current ''posthome''');
                end
                if thisPostSign
                        currentTimeWindow(1) = max([currentTimeWindow(1), postTimeLimit]);
                end

                if all(unique(B.posthome(posthi).timecode, 'rows') >= 0)
                        % Timed sequencer (exclude ignored events)
                        currentIdx      = (itemTimes - iLogitemTime) >= currentTimeWindow(1) & ...
                                          (itemTimes - iLogitemTime) <= currentTimeWindow(2) & notIgnored;
                        currentCodes    = itemCodes(currentIdx);
                        currentTimesRel = itemTimes(currentIdx) - iLogitemTime;

                        if thisPostSign
                                if any(ismember(currentCodes, B.posthome(posthi).eventcode))
                                        postTimeLimit = min(currentTimesRel(ismember(currentCodes, B.posthome(posthi).eventcode)));
                                        posthi = posthi + 1;
                                else
                                        return
                                end
                        else
                                if any(ismember(currentCodes, B.posthome(posthi).eventcode))
                                        return
                                else
                                        posthi = posthi + 1;
                                end
                        end
                else
                        % Untimed sequencer: check next event, skipping ignored events
                        while ip <= numel(itemCodes) && ~notIgnored(ip)
                                ip = ip + 1;
                        end
                        if ip > numel(itemCodes), return; end
                        if any(ismember(itemCodes(ip), B.posthome(posthi).eventcode))
                                posthi = posthi + 1;
                                ip     = ip + 1;
                        else
                                return
                        end
                end

        else
                % Mixed-sign posthome sequencer
                currentTimeWindowOrig = unique(B.posthome(posthi).timecode, 'rows');
                if size(currentTimeWindowOrig, 1) ~= 1
                        error('''timecode'' not unique across ''eventcodes'' of current ''posthome''');
                end
                if ~all(currentTimeWindowOrig >= 0)
                        error('Time specification required when mixing required and prohibited codes in one {}-term');
                end

                currentTimeWindowAdj = [max([currentTimeWindowOrig(1), postTimeLimit]), currentTimeWindowOrig(2)];

                currentIdx = (itemTimes - iLogitemTime) >= currentTimeWindowAdj(1) & ...
                             (itemTimes - iLogitemTime) <= currentTimeWindowAdj(2) & notIgnored;

                eventProhibitedIdx = B.posthome(posthi).eventsign == 0;
                eventRequiredIdx   = B.posthome(posthi).eventsign == 1;

                currentRequiredIdx   = currentIdx & ismember(itemCodes, B.posthome(posthi).eventcode(eventRequiredIdx));
                currentProhibitedIdx = currentIdx & ismember(itemCodes, B.posthome(posthi).eventcode(eventProhibitedIdx));
                currentCodesRequired    = itemCodes(currentRequiredIdx);
                currentCodesProhibited  = itemCodes(currentProhibitedIdx);

                if ~isempty(currentCodesRequired)
                        currentTimesRequiredRel      = itemTimes(currentRequiredIdx) - iLogitemTime;
                        currentTimesRequiredRelLimit = min(currentTimesRequiredRel);
                        if ~isempty(currentCodesProhibited)
                                currentTimesProhibitedRel = itemTimes(currentProhibitedIdx) - iLogitemTime;
                                if all(currentTimesProhibitedRel < currentTimeWindowOrig(1) | ...
                                       currentTimesProhibitedRel > currentTimesRequiredRelLimit)
                                        postTimeLimit = currentTimesRequiredRelLimit;
                                        posthi = posthi + 1;
                                else
                                        return
                                end
                        else
                                postTimeLimit = currentTimesRequiredRelLimit;
                                posthi = posthi + 1;
                        end
                else
                        return
                end
        end
end

if posthi == numel(B.posthome) + 1
        postok = true;
end

binok = preok && postok;


% =========================================================================
%  Flag Test Function  (identical to neobinlister2)
% =========================================================================

function [ishomeFlagdetected, varargout] = flagTest(BIN, EVENTLIST, auxles, seq, currentbin, currentlogitem)

auxflag     = BIN(currentbin).(auxles)(seq).flagcode(1,1);
auxflagmask = BIN(currentbin).(auxles)(seq).flagmask(1,1);

if auxflagmask ~= 0
        maskedEventFlag    = bitand(EVENTLIST.eventinfo(currentlogitem).flag, auxflagmask);
        ishomeFlagdetected = ~isempty(find(auxflag == maskedEventFlag, 1));
        flgx = 1;
else
        ishomeFlagdetected = 1;
        flgx = 0;
end
varargout(1) = {flgx};


% =========================================================================
%  Write Test Function  (identical to neobinlister2)
% =========================================================================

function [writeflag, writeindx] = writeTest(BIN, EVENTLIST, auxles, seq, currentbin, currentlogitem, writeflag, writeindx)

auxwrite     = BIN(currentbin).(auxles)(seq).writecode(1,1);
auxwritemask = BIN(currentbin).(auxles)(seq).writemask(1,1);

if auxwritemask ~= 0
        flagnegmasked = bitand(EVENTLIST.eventinfo(currentlogitem).flag, bitcmp(auxwritemask));
        newflag       = bitor(flagnegmasked, auxwrite);
        writeflag     = [writeflag newflag];
        writeindx     = [writeindx currentlogitem];
end


% =========================================================================
%  Time-Range Test 2  (identical to neobinlister2 — used in slow path only)
% =========================================================================

function [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2( ...
        EVENTLIST, BIN, les, isnegated, previous_t2, iLogitem, traffic, islastsequencer, ...
        writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, forbiddenCodeArray, ...
        targetLogPointer, targetEventCodeArray)

nitem = length(EVENTLIST.eventinfo);
tempi = BIN(jBin).(les{kles})(mSeq).timecode(1, 1:2);

t1 = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1, 2^(2-kles)) / 1000;
t2 = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1, kles) / 1000;

if t2 > previous_t2 && kles == 1
        t2 = previous_t2;
elseif t1 < previous_t2 && kles == 2
        t1 = previous_t2;
end

% Forbidden code detector within [t0 t2]
t0      = EVENTLIST.eventinfo(iLogitem).time;
rfrbddn = find([EVENTLIST.eventinfo.time] >= t0 & [EVENTLIST.eventinfo.time] <= t2);

if ~isempty(rfrbddn)
        codesrangefrbddn = [EVENTLIST.eventinfo(rfrbddn).code];
        timecodesfrbddn  = [EVENTLIST.eventinfo(rfrbddn).time];
        [tf, rp2]        = ismember_bc2(codesrangefrbddn, forbiddenCodeArray);
        timefrbddn       = timecodesfrbddn(find(rp2, 1));
        isfrbddndetected = nnz(tf) > 0;
else
        isfrbddndetected = 0;
end

targetLogItemArray = find([EVENTLIST.eventinfo.time] >= t1 & [EVENTLIST.eventinfo.time] <= t2);

if ~isempty(targetLogItemArray)
        targetLogCodeArray = [EVENTLIST.eventinfo(targetLogItemArray).code];
        targetLogTimeArray = [EVENTLIST.eventinfo(targetLogItemArray).time];
        tf  = ismember(targetLogCodeArray, targetEventCodeArray);
        rcr = find(tf, 1, 'first');
        israngedetected = ~isempty(rcr);
else
        israngedetected = 0;
end

if israngedetected && isfrbddndetected

        timecodOK        = targetLogTimeArray(rcr);
        targetLogPointer = targetLogItemArray(rcr);

        if (timefrbddn >= timecodOK && kles == 1) || (timefrbddn <= timecodOK && kles == 2)
                isdetectedLES = 0;
        else
                if isnegated
                        [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogItemArray(rcr));
                        [writeflag, writeindx]     = writeTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer, writeflag, writeindx);
                        if ishomeFlagdetected && ~flgx
                                isdetectedLES = 0;
                        elseif ishomeFlagdetected && flgx
                                isdetectedLES = 0;
                        else
                                isdetectedLES = 1;
                        end
                else
                        [ishomeFlagdetected, ~] = flagTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogItemArray(rcr));
                        [writeflag, writeindx]  = writeTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer, writeflag, writeindx);
                        if ~ishomeFlagdetected
                                isdetectedLES = 0;
                        end
                        offsetLogitem = abs(targetLogItemArray(rcr) - iLogitem);
                        if targetLogPointer > 1 && targetLogPointer < nitem
                                previous_t2 = EVENTLIST.eventinfo(targetLogItemArray(rcr) + traffic(kles)).time;
                        end
                end
        end

elseif israngedetected && ~isfrbddndetected

        timecodOK        = targetLogTimeArray(rcr);
        targetLogPointer = targetLogItemArray(rcr);

        [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogItemArray(rcr));
        [writeflag, writeindx]     = writeTest(BIN, EVENTLIST, les{kles}, mSeq, jBin, targetLogPointer, writeflag, writeindx);

        if isnegated
                if EVENTLIST.eventinfo(targetLogItemArray(rcr)).enable
                        if ishomeFlagdetected
                                isdetectedLES = 0;
                        else
                                isdetectedLES = 1;
                        end
                else
                        isdetectedLES = 1;
                end
        else
                if EVENTLIST.eventinfo(targetLogItemArray(rcr)).enable
                        if ishomeFlagdetected
                                isdetectedLES = 1;
                        else
                                isdetectedLES = 0;
                        end
                else
                        isdetectedLES = 0;
                end
                if isdetectedLES
                        offsetLogitem = abs(targetLogItemArray(rcr) - iLogitem);
                        if targetLogPointer > 1 && targetLogPointer < nitem && ~islastsequencer
                                previous_t2 = EVENTLIST.eventinfo(targetLogItemArray(rcr) + traffic(kles)).time;
                        end
                end
        end

else  % not detected
        if isnegated
                isdetectedLES = 1;
        else
                isdetectedLES = 0;
        end
end
