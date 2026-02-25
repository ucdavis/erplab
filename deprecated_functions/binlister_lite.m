% same as binlister...(little faster though)
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


function [EEG EVENTLIST binOfBins] = binlister_lite(EEG, bdfilename, eventlist, neweventlist, forbiddenCodeArray, ignoreCodeArray, reportable)

version    = geterplabversion;

if ~strcmp(strtrim(neweventlist),'')  % it is not a lite call...
      [EEG EVENTLIST binOfBins] = binlister(EEG, bdfilename, eventlist, neweventlist, forbiddenCodeArray, ignoreCodeArray, reportable);
      return
end

% fprintf('binlister.m : START\n');
binOfBins  = [];
EVENTLIST  = [];

if nargin < 1
      help binlister_lite
      return
elseif nargin>1 && nargin~=7
      error('ERPLAB says: binlister_lite() works with 7 inputs \n')
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
      [BIN, isparsednumerically] = bdf2struct(BIN);
      
else
      isparsednumerically = 0;
end
if isparsednumerically
      
      if strcmpi(eventlist, 'no')
            [EEGx EVENTLIST] = creaeventlist(EEG);
            clear EEGx
      else
            %
            % Read EVENTLIST file into EEG.EVENTLIST.eventinfo (also EEG.EVENTLIST.bdf )
            %
            [EEGx EVENTLIST] = readeventlist(EEG, eventlist); % ok
            clear EEGx
      end
      
      %
      % Add bin descriptor structure to EVENTLIST struct
      %
      EVENTLIST.bdf = BIN;      
      fprintf('Detecting succesful BINs in the EVENTLIST.eventinfo structure....\n');
      
      %
      %  Open a new Bin List File
      %
      bdfcrono   = datestr(now, 'mmmm dd, yyyy HH:MM:SS AM');
      rnameAux    = '';
      
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
      nbin        = length(BIN);
      
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
                  EVENTLIST.setname = 'there_is_no_eeg';
            else
                  EVENTLIST.setname = EEG.setname;
            end
      else
            EVENTLIST.setname = 'there_is_no_eeg';
      end
      
      EVENTLIST.elname   = neweventlist;  % text output EVENTLIST
      EVENTLIST.report   = rnameAux;      % text output REPORT
      EVENTLIST.version  = version;
      EVENTLIST.eldate   = bdfcrono;
      EVENTLIST.account  = userlogin;
      
      disp('Please wait...')
      
      %
      % BINLISTER Core Test
      %
      ColorB = erpworkingmemory('ColorB');
      
      for iLogitem = 1:nitem  % Reads each log item (item pointer)
            
            %
            % Current (log) item status should not be forbidden (enable = -1) code
            %
            cd1 = EVENTLIST.eventinfo(iLogitem).enable~=-1 && ~ismember_bc2(EVENTLIST.eventinfo(iLogitem).code, forbiddenCodeArray);
            
            %
            % Current event code should not be a ignored (enable = 0) code
            %
            cd2 =  EVENTLIST.eventinfo(iLogitem).enable~=0 && ~ismember_bc2(EVENTLIST.eventinfo(iLogitem).code, ignoreCodeArray);
            
            if cd1 && cd2 % check previous conditions
                  
                  for jBin=1:nbin  % BIN's loop
                        
                        writeflag=[]; writeindx=[];
                        
                        %
                        % Conditions for bin
                        %
                        cond1 = iLogitem > length(BIN(jBin).prehome);             % current item pointer has to be greater than the amount of pre-home sequencer at the current bin.
                        cond2 = (nitem - iLogitem) >= length(BIN(jBin).posthome); % remaining number of items has to be greater than the amount of post-home sequencer at the current bin.
                        cond3 = EVENTLIST.eventinfo(iLogitem).code~=-99;          % WARNING: current event codes should not be equal to -99 (this is the default code for 'boundary' events)
                        
                        if cond1 && cond2 && cond3 % % check previous conditions
                              
                              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %
                              %
                              %                      HOME START
                              %
                              %
                              %
                              
                              %
                              % Special event codes (take-all and take-nothing)
                              %
                              isallcode  = ~isempty(find(BIN(jBin).athome(1).eventcode == -7, 1));  % check for take-all event code (*)
                              isnonecode = ~isempty(find(BIN(jBin).athome(1).eventcode == -13, 1)); % check for take-nothing event code (~*)
                              
                              if isallcode
                                    
                                    %
                                    % Writes the bin's number in the output file  (Take-All code case: -7)
                                    %
                                    ishomedetected    = 0;                     % This variable is used to detect home (1: detected)   0: stop searching
                                    binOfBins(1,jBin) = binOfBins(1,jBin) + 1; % Bin counter vector
                                    
                              elseif isnonecode         %(Take-nothing code case: -13)
                                    ishomedetected = 0; % 0=stop searching
                              else
                                    %
                                    % otherwise, compares home with the current event code
                                    %
                                    nDesiredCodes   = nnz(BIN(jBin).athome(1).eventsign); % Number of non-negated codes (wanted codes)
                                    ishomedetected = ~isempty(find(BIN(jBin).athome(1).eventcode == EVENTLIST.eventinfo(iLogitem).code, 1));
                                    
                                    if nDesiredCodes == 0     % this means all event codes at home were negated.
                                          ishomedetected = ~ishomedetected;    % So, the detection was positive (This variable is used to detect pre & post home (~0: detected))
                                    end
                                    
                                    ishomeFlagdetected     = flagTest(BIN, EVENTLIST, 'athome', 1, jBin, iLogitem ); % This variable is used to detect flag (1: detected)
                                    [writeflag, writeindx] = writeTest(BIN, EVENTLIST, 'athome', 1, jBin, iLogitem,...
                                          writeflag, writeindx);
                              end
                              
                              %
                              % If home matchs then it can do the rest of checking
                              %
                              if ishomedetected && ishomeFlagdetected
                                    
                                    %
                                    % start the report for this (eventually) captured item
                                    %
                                    
                                    %
                                    % PreHome & PostHome Test.
                                    % PQ Sequencers
                                    %
                                    traffic(1)    = -1;               % going to athome's left side   <-<-<-.{}
                                    traffic(2)    =  1;               % going to athome's right side  .{}->->->
                                    isdetectedLES =  1;               % This variable is used to detect pre & post home (1: detected)
                                    
                              elseif ishomedetected && ~ishomeFlagdetected   % 03-13-2008
                                    
                                    %
                                    % start the report for this (eventually) captured item
                                    %
                                    
                                    isdetectedLES = 0; %This variable (positive logic) is used to detect pre & post home
                              else
                                    isdetectedLES = 0; %This variable (positive logic) is used to detect pre & post home
                              end
                              
                              les = cell(1);
                              les{1} = 'prehome';
                              les{2} = 'posthome';
                              nLes   = length(les);
                              kles = 1;   % les's (Log Event Selector) iterator
                              
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
                                    
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    %
                                    %
                                    %                      PREHOME & POSTHOME START
                                    %
                                    %
                                    %
                                    
                                    while (kSeq <= nSequencer) && (isdetectedLES) % each sequencer
                                          
                                          targetLogPointer = iLogitem + traffic(kles)*offsetLogitem;      % current log item to be tested (from EVENTLIST)
                                          targetLogCode    = EVENTLIST.eventinfo(targetLogPointer).code;  % current event code to be tested, at current log item = targetLogPointer, from bin descriptor file.
                                          
                                          isignoredc   = ismember_bc2(targetLogCode, ignoreCodeArray);   % is this code an ignored one?
                                          isforbiddenc = ismember_bc2(targetLogCode, forbiddenCodeArray); % is this code a forbidden one?
                                          
                                          
                                          if isforbiddenc
                                                isdetectedLES=0;
                                                break
                                          end
                                          
                                          
                                          if EVENTLIST.eventinfo(targetLogPointer).enable~=-1 && ~isignoredc % is enable the current event code to test?
                                                
                                                if kles == 1
                                                      mSeq   = nSequencer - kSeq + 1;    % sequencer's iterator (countdown)
                                                else
                                                      mSeq   = kSeq;                     % sequencer's iterator (countup)
                                                end
                                                
                                                nDesiredCodes        = nnz(BIN(jBin).(les{kles})(mSeq).eventsign);   % Number of desired codes. "desired codes" (wanted ones) are codes which sign is 1. Sign 0 means "negated codes"
                                                targetEventCodeArray = BIN(jBin).(les{kles})(mSeq).eventcode;        % Code(s) inside the current sequencer ({}), at current les, that are going to be compared with the current event code at current item.
                                                
                                                rc = find(targetEventCodeArray == targetLogCode, 1); % location of matching code at current sequencer. Empty means unsuccessful "detection" for desired codes (see below)
                                                
                                                if nDesiredCodes > 0
                                                      detectionProcess = 'matching';
                                                      negWord   = '';
                                                      isnegated = 0;                      % NON NEGATED codes (desired codes)
                                                      ispqdetected = ~isempty(rc);        % not empty means successful "detection" for desired codes
                                                else
                                                      detectionProcess = 'not-matching';
                                                      negWord          = 'not';
                                                      isnegated        = 1;               % NEGATED codes
                                                      ispqdetected     = isempty(rc);     % empty means (ispqdetected=1) successful "NO detection" for NEGATED codes
                                                      
                                                      if ispqdetected
                                                            % if successful "NO detection" then finds the first "different" codes at  current sequencer
                                                            rc       = find(targetEventCodeArray ~= targetLogCode, 1);
                                                      end
                                                end
                                                
                                                %
                                                % truncates the displayed codes belonging to the current sequencer (only for REPORT)
                                                %
                                                if length(targetEventCodeArray)>16
                                                      codestocompareString = [num2str(targetEventCodeArray(1:16)) '...and so on '];
                                                else
                                                      codestocompareString = num2str(targetEventCodeArray);
                                                end
                                                
                                                %
                                                % Time condition detector
                                                %
                                                rt = find(BIN(jBin).(les{kles})(mSeq).timecode ~= -1, 1);  % is there time spec for the current sequencer?
                                                istimed = ~isempty(rt); % 1 means time spec was detected
                                                
                                                if kSeq == nSequencer   % is this the last sequencer for the current les
                                                      islastsequencer = 1;
                                                end
                                                
                                                if ~ispqdetected
                                                      isdetectedLES = 0;  % Current sequencer was not successful...so far...
                                                end
                                                
                                                CA =       isdetectedLES &&  istimed && ~isnegated;      % a) successful detection of (not negated) sequencer. However, there was time condition...
                                                CB =     (~isdetectedLES &&  istimed && ~isnegated)...
                                                      || ( isdetectedLES &&  istimed &&  isnegated)...
                                                      || (~isdetectedLES &&  istimed &&  isnegated);     % b) unsuccessful detection of (not negated) sequencer. However, there was time condition,
                                                %    or successful detection of negated sequencer. However, there was time condition,
                                                %    or unsuccessful detection of (not negated) sequencer. However, there was time condition...
                                                CC =      ~isdetectedLES && ~istimed;                    % c) successful detection of (not negated) sequencer. However, there was time condition...
                                                
                                                if CA % a)
                                                      
                                                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                      %
                                                      %
                                                      %         PREHOME & POSTHOME TIME-RANGE TEST 01
                                                      %
                                                      %
                                                      %
                                                      %
                                                      
                                                      tempi = BIN(jBin).(les{kles})(mSeq).timecode(rc,1:2); % get time interval (time spec)
                                                      
                                                      %
                                                      % Report: start time-range test 01
                                                      %
                                                      
                                                      t1    = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1,2^(2-kles)) / 1000;
                                                      t2    = EVENTLIST.eventinfo(iLogitem).time + traffic(kles) * tempi(1,kles) / 1000;
                                                      
                                                      if       t2 > previous_t2 && kles==1     % avoids earlier event codes detection by prehome time.
                                                            t2 = previous_t2;
                                                      elseif   t1 < previous_t2 && kles==2    % avoids earlier event codes detection by posthome time.
                                                            t1 = previous_t2;
                                                      end
                                                      
                                                      targetLogTime = EVENTLIST.eventinfo(targetLogPointer).time;
                                                      
                                                      if targetLogTime >= t1 && targetLogTime <= t2
                                                            
                                                            if targetLogPointer>1  &&  targetLogPointer<nitem
                                                                  previous_t2 = EVENTLIST.eventinfo(targetLogPointer + traffic(kles)).time ;   %targetLogTimeArray(rcr);  % 10 March  % 12 March
                                                            end
                                                            
                                                            %
                                                            % Calling to flagTest 03-12-2008
                                                            %
                                                            [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST,...
                                                                  (les{kles}), mSeq, jBin, targetLogPointer );
                                                            
                                                            [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                                                  targetLogPointer, writeflag, writeindx);
                                                            
                                                            if ishomeFlagdetected && ~flgx
                                                                  
                                                                  
                                                            elseif ishomeFlagdetected && flgx
                                                                  
                                                            else
                                                                  isdetectedLES = 0;
                                                            end
                                                      else
                                                            % I) The basic detection said there was no event code that matches,
                                                            % but there is a description of time range for a non-negated code.
                                                            % II) Or the basic detection said that there was an event code that mached, but
                                                            % there is a description of the time range for a negated code.
                                                            % III) Code match, but we need to check the specified time range.
                                                            % *Remember that isdetectedLES = 0 for non-negated and isdetectedLES = 1 for negated
                                                            chance = 2;
                                                            [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2(EVENTLIST, BIN, les, isnegated, ispqdetected, reportable,  targetLogCode, previous_t2, ...
                                                                  iLogitem, traffic, islastsequencer, writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, negWord, codestocompareString, forbiddenCodeArray, ...
                                                                  ignoreCodeArray, targetLogPointer, targetEventCodeArray, chance);
                                                            
                                                      end
                                                      
                                                elseif CB
                                                      % I) The basic detection said there was no event code that matches,
                                                      % but there is a description of time range for a non-negated code.
                                                      % II) Or the basic detection said that there was an event code that mached, but
                                                      % there is a description of the time range for a negated code.
                                                      % III) Code match, but we need to check the specified time range.
                                                      % *Remember that isdetectedLES = 0 for non-negated and isdetectedLES = 1 for negated
                                                      chance = 1;
                                                      [targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2(EVENTLIST, BIN, les, isnegated, ispqdetected, reportable,  targetLogCode, previous_t2, ...
                                                            iLogitem, traffic, islastsequencer, writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, negWord, codestocompareString, forbiddenCodeArray, ...
                                                            ignoreCodeArray, targetLogPointer, targetEventCodeArray, chance);
                                                      
                                                      
                                                elseif CC         % The basic detection said there is no match for the specified event code and there is no time range specified.
                                                      
                                                      [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                                                            jBin, targetLogPointer );  % call to the function flagTest 12 March 2008
                                                      [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                                            targetLogPointer, writeflag, writeindx);
                                                      
                                                      if ~ishomeFlagdetected && flgx && isnegated
                                                            isdetectedLES = 1;
                                                      end
                                                      
                                                else              % The basic detection was successful and no time interval is specified
                                                      
                                                      [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                                                            jBin, targetLogPointer );  % Call to the function flagTest 12 March 2008
                                                      [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                                                            targetLogPointer, writeflag, writeindx);
                                                      
                                                      if isnegated   % 21 February 2008
                                                            isdetectedLES = 1;
                                                      else
                                                            if ishomeFlagdetected && ~flgx
                                                                  
                                                            elseif ishomeFlagdetected && flgx
                                                                  
                                                            else
                                                                  isdetectedLES = 0;
                                                            end
                                                      end
                                                      
                                                      if ~islastsequencer
                                                            %if targetLogPointer>1  &&  targetLogPointer<nitem
                                                            previous_t2 = EVENTLIST.eventinfo(targetLogPointer + traffic(kles)).time ;
                                                      end
                                                end
                                                
                                                kSeq = kSeq+1; %sequence number**********
                                                
                                                
                                          elseif EVENTLIST.eventinfo(targetLogPointer).enable==-1 || isforbiddenc    %12-12-2008
                                                
                                                %
                                                %  If logcode was not enable
                                                %
                                                isdetectedLES = 0;
                                                
                                          else % is enable current event code to test?
                                                
                                                %
                                                %  If logcode was not enable
                                                %
                                                
                                          end  % Check enable condition
                                          
                                          offsetLogitem = offsetLogitem + 1;  % check next (or previous) logcode
                                          
                                          if isdetectedLES
                                                
                                                % % targetLogPointer = iLogitem + traffic(kles)*offsetLogitem;      % current log item to be tested (from EVENTLIST)
                                                % % targetLogCode    = EVENTLIST.eventinfo(targetLogPointer).code;  % current event code to be tested, at current log item = targetLogPointer, from bin descriptor file.
                                                %
                                                % for RT measurements
                                                %
                                                %jBin
                                                %targetLogPointer
                                                %kles
                                                %mSeq
                                                capcodeatles{kles, mSeq} = targetLogPointer; % kles =1 --> prehome;  kles=1 -->posthome
                                                
                                                %if mSeq==1 && jBin==1
                                                %        disp('STOP')
                                                %end
                                          end
                                    end     % For each sequencer
                                    
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    %
                                    %
                                    %                      PREHOME & POSTHOME END
                                    %
                                    %
                                    %
                                    kles = kles + 1;   % 1 = prehome     2 = posthome     15 February 2008
                                    
                              end % fields
                              
                              %            Writes bin's number in the output file (full tested case)
                              % Si la secuencias prehome y posthome del home eran buenas, entonces ANOTA EL BIN!!!
                              
                              if isdetectedLES %% && detectp 02-15-2008
                                    
                                    %
                                    % finish the report for the current bin and current log item with good news
                                    %
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
                                                      EVENTLIST.bdf(jBin).rtflag(indxbin, nLoop) = EEG.EVENTLIST.eventinfo(rtpointer(nLoop)).flag;
                                                      
                                                      EVENTLIST.bdf(jBin).rthomeitem(indxbin, nLoop) = iLogitem;
                                                      EVENTLIST.bdf(jBin).rthomeflag(indxbin, nLoop) = EEG.EVENTLIST.eventinfo(iLogitem).flag;
                                                      EVENTLIST.bdf(jBin).rthomecode(indxbin, nLoop) = EEG.EVENTLIST.eventinfo(iLogitem).code;
                                                      
                                                      
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
            if isempty(binrow)
                  EVENTLIST.eventinfo(iLogitem).bini = -1;
                  % Creates BIN LABELS
                  binName = '""';
            else
                  EVENTLIST.eventinfo(iLogitem).bini = binrow;
                  % Creates BIN LABELS
                  auxname = num2str(binrow);
                  bname   = regexprep(auxname, '\s+', ',', 'ignorecase'); % insterts a comma instead blank space
                  
                  if strcmp(EVENTLIST.eventinfo(iLogitem).codelabel,'""')
                        binName = ['B' bname '(' num2str(EVENTLIST.eventinfo(iLogitem).code) ')']; %B#(code)
                  else
                        binName = ['B' bname '(' EVENTLIST.eventinfo(iLogitem).codelabel ')']; %B#(codelabel)
                  end
            end
            
            EVENTLIST.eventinfo(iLogitem).binlabel = binName;            
            binrow = [];            
            fprintf('.');
            if ismember_bc2(iLogitem,100:100:10000) || (100*iLogitem/nitem)>=100
                  fprintf('%g(%.1f%%)\n', iLogitem, 100*iLogitem/nitem);
            end           
      end  % Reads each log item (iLogitem loop)
      
      pause(0.1)
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
      [EEGx EVENTLIST] = creaeventlist(EEG, EVENTLIST, neweventlist);
      clear EEGx
      
      fprintf('Successful Trials per bin :\t%s\n', num2str(binOfBins));      
else      
      fprintf('Fatal Error:\n');
      fprintf('\nNumeric parsing was not aproved...Game Over\n');
end %IF isparsednumerically?   10 May

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Flag Test Function
%
%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PREHOME & POSTHOME TIME-RANGE TEST 02
%

function[targetLogPointer, isdetectedLES, writeflag, writeindx, offsetLogitem] = timetest2(EVENTLIST, BIN, les, isnegated, ispqdetected, reportable,  targetLogCode, previous_t2, ...
      iLogitem, traffic, islastsequencer, writeflag, writeindx, jBin, kles, mSeq, offsetLogitem, negWord, codestocompareString, forbiddenCodeArray, ...
      ignoreCodeArray, targetLogPointer, targetEventCodeArray, chance)
% I) The basic detection said there was no event code that matches,
% but there is a description of time range for a non-negated code.
% II) Or the basic detection said that there was an event code that mached, but
% there is a description of the time range for a negated code.
% III) Code match, but we need to check the specified time range.
% *Remember that isdetectedLES = 0 for non-negated and isdetectedLES = 1 for negated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%         PREHOME & POSTHOME TIME-RANGE TEST 02
%  timetest = 1;  % means TIME-RANGE TEST was required
%
%
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

if       t2 > previous_t2 && kles==1
      t2 = previous_t2;
elseif   t1 < previous_t2  && kles==2
      t1 = previous_t2;
end

phrase1 = ['Should ' negWord ' be an event code %s  between %g and %g secs\n'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
      isfrbddndetected    = 0;
end

% -----------------------------------------------------------------------

r2  = find([EVENTLIST.eventinfo.time] >= t1 & [EVENTLIST.eventinfo.time] <= t2);

if ~isempty(r2)
      targetLogCodeArray = [EVENTLIST.eventinfo(r2).code];      % LOGCODES are in this time range
      targetLogItemArray = r2 ;                                 % Logiterms for these times
      targetLogTimeArray = [EVENTLIST.eventinfo(r2).time];      % Log times for the time range T1 - T2
      tf   = ismember_bc2(targetLogCodeArray, targetEventCodeArray);
      rcr  = find(tf,1,'first');
      israngedetected = ~isempty(rcr);
else
      israngedetected = 0;
end

if israngedetected && isfrbddndetected   % Codes were detected but there was a pause code 04 February 2008
      
      timecodOK = targetLogTimeArray(rcr);
      targetLogPointer = targetLogItemArray(rcr);
      
      if (timefrbddn >= timecodOK && kles==1) || (timefrbddn <= timecodOK && kles==2)
            % the pause was between the home and the current code...bad
            % news
            isdetectedLES = 0;
      else            
            if isnegated   % 02-21-2008
                  [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                        jBin, targetLogItemArray(rcr) );  % call the function flagTest 12 March 2008
                  
                  [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                        targetLogPointer, writeflag, writeindx);
                  
                  if ishomeFlagdetected && ~flgx
                        isdetectedLES = 0;
                        
                  elseif ishomeFlagdetected && flgx
                        isdetectedLES = 0;
                  else
                        isdetectedLES = 1;
                  end                  
            else
                  
                  % The pause was further away from the current code,
                  % so good news
                  [ishomeFlagdetected, flgx] = flagTest(BIN, EVENTLIST, (les{kles}), mSeq,...
                        jBin, targetLogItemArray(rcr) );  % Call the function flagTest 12 March 2008
                  [writeflag, writeindx] = writeTest(BIN, EVENTLIST, (les{kles}), mSeq, jBin,...
                        targetLogPointer, writeflag, writeindx);
                  
                  if ishomeFlagdetected && ~flgx
                        %isdetectedLES = 1;
                  elseif ishomeFlagdetected && flgx
                        %isdetectedLES = 1;
                  else
                        isdetectedLES = 0;
                  end                  
                  
                  %isdetectedLES = 1;
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
            if EVENTLIST.eventinfo(rcr).enable  % checks enable  10-16-2008
                  
                  if ishomeFlagdetected && ~flgx
                        isdetectedLES = 0;
                  elseif ishomeFlagdetected && flgx
                        isdetectedLES = 0;
                  else
                        isdetectedLES = 1;
                  end
                  
            else  % checks enable  10-16-2008
                  isdetectedLES = 1;
            end            
      else
            if EVENTLIST.eventinfo(rcr).enable  % checks enable  10-16-2008
                  
                  if ishomeFlagdetected && ~flgx
                        isdetectedLES = 1;
                  elseif ishomeFlagdetected && flgx
                        isdetectedLES = 1;
                  else
                        isdetectedLES = 0;
                  end
            else  % checks enable  10-16-2008
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
else   % event codes were not detected. Bad news...
      
      if isnegated   % 02-21-2008
            isdetectedLES = 1;
      else
            isdetectedLES = 0;  % 12 March 2008
      end
end
return

