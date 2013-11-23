% PURPOSE: Converts decoded "bin descriptor(s)" into a numeric structure, in order to be used by binlister.
%
% FORMAT:
%
% [BIN, isparsednumerically] = bdf2struct(BIN)
%
% Inputs:
%
%   BIN                    - BIN structure containing "bin descriptor(s)"
%
% Output
% 
% BIN                      - BIN structure 
% isparsednumerically      - boolean, 1=everything ok; 0= there is error.
%
%
% See binlister.m, decodebdf.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
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

function [BIN, isparsednumerically] = bdf2struct(BIN)

if nargin < 1
        help bdf2struct
        return
end

%
% For debugging...
%
condition  = 0;  % 1 = displays processing comments;  0 = don't do that!

%
% Since the data extraction routine is the same for prehome, athome, and
% posthome, we will use the variable logEventSelector for looping. 
%
isparsednumerically = 1;    % Numeric parsing is approved by default
logEventSelector{1} = 'prehome';  %(log event selector = LES)
logEventSelector{2} = 'athome';
logEventSelector{3} = 'posthome';
nBin = length(BIN);
fprintf('\n');

for iBin = 1:nBin       % Bin's loop
        
        isworkingFine = 1;   %boolean condition if everything goes well
        jLogES = 1;
        
        while  (jLogES <= length(logEventSelector)) && (isworkingFine) % LES's loop
                
        % Take each field and divide it by curly braces = sequencers
                [segmentedBrackets]    =   regexp(BIN(iBin).expression(jLogES), '.+?\d+.*?}', 'match');
                % Detects special codes as * (all) and ~* (none)
                [spCodes specialCodesToken]    =   regexp(BIN(iBin).expression(jLogES), '(\~)*(\*+)', 'match','tokens');  % 21 febrero 2008!
                
                if ~isempty(segmentedBrackets{:}) && isempty(spCodes{:})  % The sequencer exists and is numeric
                        nSequencer = length(segmentedBrackets{:});             % Number of sequencers
                        auxt1pre = [];
                        auxt2pre = [];
                        
                        for kSequencer = 1:nSequencer                          % Sequencer's loop
                                %
                                % extract each sequencer from one to nSequencer, one by one
                                %
                                sequencerString = char(segmentedBrackets{1}(kSequencer));
                                sequencerString = regexprep(sequencerString, ':rt<".*?">', ''); % hides reaction time (if any)
                                
                                %
                                % Check if sequencer are simple or they
                                % have more complex conditions like time,
                                % flags, etc.
                                
                                storeCode   = [];
                                storeSign   = [];
                                catch_IC    = [];
                                catch_Sign  = []; % catchs interval code ans sign
                                
                                %
                                % First, searchs event code given as an interval e.g {1-10;30-40}
                                % Careful: There might be several of these
                                % defined intervals
                                %
                                [intervalString intervalToken] = regexp(sequencerString, '[{;,>](\~*)(\d+)\-(\d+)',...
                                        'match','tokens'); % 4 February: added on">"
                                
                                if ~isempty(intervalToken)   % Only if intervals were found
                                        coluInTok = size(intervalToken,2);
                                        pointerInterval   = 1;
                                        dispcond( condition, 'There is a specified interval x !')
                                        
                                        % generate all number given by interval
                                        for k = 1:coluInTok
                                                intervalCodeStart = str2double(cell2mat(intervalToken{k}(2)));
                                                intervalCodeStop  = str2double(cell2mat(intervalToken{k}(3)));
                                                
                                                if intervalCodeStart == intervalCodeStop
                                                        catch_IC(pointerInterval) = intervalCodeStart;
                                                        
                                                        if strcmp(char(intervalToken{k}(1)),'~')    % There is negation
                                                                catch_Sign(pointerInterval) = 0;
                                                        else                                        % There is no negation
                                                                catch_Sign(pointerInterval) = 1;
                                                        end
                                                        
                                                        pointerInterval = pointerInterval + 1;
                                                        dispcond( condition, 'but the values are equals...')
                                                        
                                                elseif intervalCodeStart < intervalCodeStop
                                                        
                                                        intervalArray = intervalCodeStart : intervalCodeStop;
                                                        catch_IC( pointerInterval:length(intervalArray) + pointerInterval - 1 ) = intervalArray;
                                                        
                                                        if strcmp(char(intervalToken{k}(1)),'~')  % There is negation
                                                                catch_Sign( pointerInterval:length(intervalArray) + pointerInterval - 1 ) = zeros(1,length(intervalArray));
                                                        else                             % THere is no negation
                                                                catch_Sign( pointerInterval:length(intervalArray) + pointerInterval - 1 ) = ones(1,length(intervalArray));
                                                        end
                                                        
                                                        pointerInterval = pointerInterval + length(intervalArray);
                                                        dispcond( condition, 'building a list from the specified interval !')
                                                        
                                                else
                                                        fprintf('Fatal Error: bad ordered interval at BIN:%g\n', iBin);
                                                        isparsednumerically = 0;  % Numeric parsin was not approved
                                                        return
                                                end
                                                storeCode = catch_IC;      %28 feb 2008
                                                storeSign = catch_Sign;              %28 feb 2008
                                        end
                                        % sort generated event code list
                                        [auxMatrix] = cat(1,storeCode, storeSign)';
                                        [MatSorted] = sortrows(auxMatrix,1);                                        
                                        storeCode   = MatSorted(:,1)';
                                        storeSign   = MatSorted(:,2)';
                                        storeTime   = repmat(-1,length(storeCode),2);
                                        storeFlag   = repmat(uint16(0),1, length(storeCode));
                                        storeFmask  = repmat(uint16(0),1, length(storeCode));
                                        storeWrite  = repmat(uint16(0),1, length(storeCode));
                                        storeWmask  = repmat(uint16(0),1, length(storeCode));
                                        % replacements...
                                        sequencerString = regexprep(sequencerString, '>(\~*)(\d+)\-(\d+)', '>1000000');
                                        sequencerString = regexprep(sequencerString, '(\~*)(\d+)\-(\d+):f', '2000000:f');
                                        sequencerString = regexprep(sequencerString, '(\~*)(\d+)\-(\d+):w', '3000000:w');
                                        sequencerString = regexprep(sequencerString, '(\~*)(\d+)\-(\d+)[,;}]', '');
                                        dispcond(condition,'Erasing Interval Expressions......')
                                else
                                        storeCode  = []; % There is no defined interval eventcode
                                        storeSign  = [];
                                        storeTime  = [];
                                        storeFlag  = [];
                                        storeFmask = [];
                                        storeWrite = [];
                                        storeWmask = [];
                                        dispcond( condition, 'there was not a specified interval ...')
                                end
                                
                                %
                                % Second, detect discrete format for event code e.g {1;2;3;4} or {1,2,3,4}
                                %
                                [ma2 cod] = regexp(sequencerString, '[{;,](\~*)(\d+)(?=[;,}])',...
                                        'match','tokens') ;
                                
                                if ~isempty(cod)
                                        dispcond( condition, 'There is a discrete event code!')
                                        auxSign = zeros(1,length(ma2));
                                        catchSingleCode    = zeros(1,length(ma2));
                                        
                                        for m = 1:length(ma2) % For each unique code detected
                                                dispcond( condition, 'extracting discrete event code!')
                                                catchSingleCode(m) = str2double(cell2mat(cod{m}(2)));
                                                
                                                if strcmp(char(cod{m}(1)),'~')  % There is negation
                                                        auxSign(m) = 0;
                                                else
                                                        auxSign(m) = 1;         % There is no negation
                                                end
                                        end
                                        
                                        storeCode   = cat(2,storeCode, catchSingleCode);
                                        storeSign   = cat(2,storeSign, auxSign);
                                        [auxMatrix] = cat(1,storeCode, storeSign)';
                                        [MatSorted] = sortrows(auxMatrix,1);
                                        dispcond( condition, 'Showing "simple" Values of complex expressions:',...
                                                storeCode, storeSign, storeTime, storeFlag, storeWrite)
                                        storeCode   = MatSorted(:,1)';
                                        storeSign   = MatSorted(:,2)';
                                        storeTime   =  repmat(-1,   length(storeCode),2);
                                        storeFlag   =  repmat(uint16(0),1, length(storeCode));
                                        storeFmask  =  repmat(uint16(0),1, length(storeCode));
                                        storeWmask  =  repmat(uint16(0),1, length(storeCode));
                                        storeWrite  =  repmat(uint16(0),1, length(storeCode));
                                        
                                        %**********************************************************
                                else
                                        dispcond( condition, 'there was not a discret complex interval ...')
                                end
                                
                                %
                                % Now it searches for time specification and/or flag
                                %
                                dispcond( condition, 'EXTRACTING T, F, y W')
                                % All possible combinations!!!
                                
                                expp =  cell(1);
                                expp{1}  = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:f<(\w+)+>:w<(\w+)+>';    % 1  full-flag full-write
                                expp{2}  = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:f<(\w+)+>(\TONGO)*';     % 2  full-flag ----------
                                expp{3}  = 't<(\d+)+-(\d+)+>(\~)*(\d+)+(\TONGO)*:w<(\w+)+>';     % 3  --------- full-write
                                expp{4}  = 't<(\d+)+-(\d+)+>(\~)*(\d+)+(\TONGO)*(\TONGO)*';      % 4  --------- ----------
                                expp{5}  = '(\TONGO)*(\TONGO)*(\~)*(\d+):f<(\w+)+>:w<(\w+)+>';   % 5  full-flag full-write
                                expp{6}  = '(\TONGO)*(\TONGO)*(\~)*(\d+):f<(\w+)+>(\TONGO)*';    % 6  full-flag ----------
                                expp{7}  = '(\TONGO)*(\TONGO)*(\~)*(\d+)+(\TONGO)*:w<(\w+)+>';   % 7  --------- full-write
                                
                                expp{8}  = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:fa<(\w+)+>:wa<(\w+)+>';  % 8  low-flag  low-write
                                expp{9}  = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:fa<(\w+)+>:wb<(\w+)+>';  % 9  low-flag  high-write
                                expp{10} = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:fb<(\w+)+>:wa<(\w+)+>';  % 10  high-flag low-write
                                expp{11} = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:fb<(\w+)+>:wb<(\w+)+>';  % 11 high-flag high-write
                                
                                expp{12} = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:fa<(\w+)+>(\TONGO)*';    % 12 low-flag  ----------
                                expp{13} = 't<(\d+)+-(\d+)+>(\~)*(\d+)+:fb<(\w+)+>(\TONGO)*';    % 13 high-flag ----------
                                expp{14} = 't<(\d+)+-(\d+)+>(\~)*(\d+)+(\TONGO)*:wa<(\w+)+>';    % 14 --------- low-write
                                expp{15} = 't<(\d+)+-(\d+)+>(\~)*(\d+)+(\TONGO)*:wb<(\w+)+>';    % 15 --------- high-write
                                
                                expp{16} = '(\TONGO)*(\TONGO)*(\~)*(\d+):fa<(\w+)+>:wa<(\w+)+>'; % 16 low-flag low-write
                                expp{17} = '(\TONGO)*(\TONGO)*(\~)*(\d+):fa<(\w+)+>:wb<(\w+)+>'; % 17 low-flag high-write
                                expp{18} = '(\TONGO)*(\TONGO)*(\~)*(\d+):fb<(\w+)+>:wa<(\w+)+>'; % 18 high-flag low-write
                                expp{19} = '(\TONGO)*(\TONGO)*(\~)*(\d+):fb<(\w+)+>:wb<(\w+)+>'; % 19 high-flag high-write
                                
                                expp{20} = '(\TONGO)*(\TONGO)*(\~)*(\d+):fa<(\w+)+>(\TONGO)*';   % 20 low-flag  ---------
                                expp{21} = '(\TONGO)*(\TONGO)*(\~)*(\d+):fb<(\w+)+>(\TONGO)*';   % 21 high-flag ---------
                                expp{22} = '(\TONGO)*(\TONGO)*(\~)*(\d+)+(\TONGO)*:wa<(\w+)+>';  % 22 --------- low-write
                                expp{23} = '(\TONGO)*(\TONGO)*(\~)*(\d+)+(\TONGO)*:wb<(\w+)+>';  % 23 --------- high-write                               
                                
                                auxstr   = sequencerString;
                                countexp = zeros(1,length(expp));  % January 28,2008
                                istimedetected = 0;   % boolean
                                isflagdetected = 0;   % boolean
                                isWritedetected= 0;   % boolean
                                
                                for e = 1:length(expp)
                                        
                                        [mtr rtimes] = regexp(auxstr, expp{e},'match','tokens');
                                        
                                        if ~isempty(mtr)
                                                countexp(e) = length(mtr); % Test the take-all event (*)
                                                
                                                for n = 1:countexp(e)
                                                        
                                                        catchComplexExpression = [rtimes{n}(1) rtimes{n}(2) rtimes{n}(4) rtimes{n}(5)...
                                                                rtimes{n}(6)];
                                                        
                                                        t1 = str2double(cell2mat(catchComplexExpression(1)));
                                                        t2 = str2double(cell2mat(catchComplexExpression(2)));
                                                        captureCode = str2double(cell2mat(catchComplexExpression(3)));
                                                        
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        % Capture Flag (f, fa, and fb)
                                                        %
                                                        strflag = catchComplexExpression{4};
                                                        lestrf  = length(strflag);
                                                        
                                                        if ismember_bc2(e,[1 2 5 6]) % full flag (16bits)
                                                                if lestrf > 16
                                                                        fprintf('Fatal Error: BIN %g. 16-bit Flag (f<>) format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                elseif lestrf <= 16 && lestrf >= 1
                                                                        
                                                                        %  Steve's option: always 'x' replaces blanks
                                                                        %  Example:  Flag = 10011  means xxxxxxxxxxx10011
                                                                        %  Example:  Flag = x10011  means xxxxxxxxxxx10011
                                                                        %
                                                                        if strflag(1)=='1' || strflag(1)=='0'
                                                                                strflag = [repmat('x',1, 16-lestrf) strflag];
                                                                        else
                                                                                strflag = [repmat('x',1, 16-lestrf) strflag];
                                                                        end
                                                                end                                                                
                                                        elseif ismember_bc2(e,[8 9 12 16 17 20]) % fa = low flag  = LSB byte = artifact flag
                                                                
                                                                if lestrf > 8
                                                                        fprintf('Fatal Error: BIN %g. 8-bit Flag (fa<>) format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                elseif lestrf <= 8 && lestrf >= 1
                                                                        
                                                                        %  Steve's option: always 'x' replaces blanks
                                                                        %  Example:  Flag = 10011   means xxxxxxxxxxx10011
                                                                        %  Example:  Flag = x10011  means xxxxxxxxxxx10011
                                                                        %
                                                                        if strflag(1)=='1' || strflag(1)=='0'
                                                                                strflag = [repmat('x',1, 16-lestrf) strflag];
                                                                        else
                                                                                strflag = [repmat('x',1, 16-lestrf) strflag];
                                                                        end
                                                                end                                                                
                                                        elseif ismember_bc2(e,[10 11 13 18 19 21]) % fb = high flag  = MSB byte = user? flag
                                                                
                                                                if lestrf > 8
                                                                        fprintf('Fatal Error: BIN %g. 8-bit Flag (fb<>) format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                elseif lestrf <= 8 && lestrf >= 1
                                                                        
                                                                        %  Steve's option: always 'x' replaces blanks
                                                                        %  Example:  Flag = 10011   means xxx10011xxxxxxxx
                                                                        %  Example:  Flag = x10011  means xxx10011xxxxxxxx
                                                                        %
                                                                        if strflag(1)=='1' || strflag(1)=='0'
                                                                                strflag = [repmat('x',1, 8-lestrf) strflag repmat('x',1, 8)];
                                                                        else
                                                                                strflag = [repmat('x',1, 8-lestrf) strflag repmat('x',1, 8)];
                                                                        end
                                                                end
                                                        end
                                                        
                                                        [matf, tokf, indxf] = regexpi(strflag, '0|1','match','tokens','start');
                                                        
                                                        if isempty(indxf)
                                                                captureFlag    = uint16(bin2dec(strflag));
                                                                maskFlagstring = '1111111111111111';
                                                                captFlagMask   = uint16(bin2dec(maskFlagstring)); % Flag's Logic Mask
                                                        else
                                                                strflag        =  regexprep(strflag, 'x','0','ignorecase');
                                                                captureFlag    = uint16(bin2dec(strflag));
                                                                maskFlagstring = repmat('0', 1, 16);
                                                                maskFlagstring(indxf) = '1';
                                                                captFlagMask   = uint16(bin2dec(maskFlagstring)); % Flag's Logic Mask
                                                        end                                                        
                                                        
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        % Capture Write and masking  10-27-2008
                                                        %
                                                        strWrite = catchComplexExpression{5};
                                                        lestrs  = length(strWrite);
                                                        
                                                        if ismember_bc2(e,[1 3 5 7]) % full Write (16bits)
                                                                if lestrs > 16
                                                                        fprintf('Fatal Error: BIN %g. 16-bit Write (w<>) format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                elseif lestrs <= 16 && lestrs >= 1
                                                                        
                                                                        %  Steve's option: always 'x' replaces blanks
                                                                        %  Example:  Flag = 10011  means xxxxxxxxxxx10011
                                                                        %  Example:  Flag = x10011  means xxxxxxxxxxx10011
                                                                        %
                                                                        if strWrite(1)=='1' || strWrite(1)=='0'
                                                                                strWrite = [repmat('x',1, 16-lestrs) strWrite];
                                                                        else
                                                                                strWrite = [repmat('x',1, 16-lestrs) strWrite];
                                                                        end
                                                                end                                                                
                                                        elseif ismember_bc2(e,[8 10 14 16 18 22]) % wa = low write  = LSB byte = artifact write
                                                                
                                                                if lestrs > 8
                                                                        fprintf('Fatal Error: BIN %g. 8-bit Write (wa<>) format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                elseif lestrs <= 8 && lestrs >= 1
                                                                        
                                                                        %  Steve's option: always 'x' replaces blanks
                                                                        %  Example:  write = 10011   means xxxxxxxxxxx10011
                                                                        %  Example:  write = x10011  means xxxxxxxxxxx10011
                                                                        %
                                                                        if strWrite(1)=='1' || strWrite(1)=='0'
                                                                                strWrite = [repmat('x',1, 16-lestrs) strWrite];
                                                                        else
                                                                                strWrite = [repmat('x',1, 16-lestrs) strWrite];
                                                                        end
                                                                end                                                                
                                                        elseif ismember_bc2(e,[9 11 15 17 19 23]) % wb = high write  = MSB byte = user? write
                                                                
                                                                if lestrs > 8
                                                                        fprintf('Fatal Error: BIN %g. 8-bit Write (wb<>) format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                elseif lestrs <= 8 && lestrs >= 1
                                                                        
                                                                        %  Steve's option: always 'x' replaces blanks
                                                                        %  Example:  write = 10011   means xxx10011xxxxxxxx
                                                                        %  Example:  write = x10011  means xxx10011xxxxxxxx
                                                                        %
                                                                        if strWrite(1)=='1' || strWrite(1)=='0'
                                                                                strWrite = [repmat('x',1, 8-lestrs) strWrite repmat('x',1, 8)];
                                                                        else
                                                                                strWrite = [repmat('x',1, 8-lestrs) strWrite repmat('x',1, 8)];
                                                                        end
                                                                end
                                                        end
                                                        
                                                        [mats, toks, indxs] = regexpi(strWrite, '0|1','match','tokens','start');
                                                        
                                                        if isempty(indxs)
                                                                captureWrite    = uint16(bin2dec(strWrite));
                                                                maskWriteString = '1111111111111111';
                                                                captWriteMask   = uint16(bin2dec(maskWriteString)); % Write's Logic Mask
                                                        else
                                                                strWrite        =  regexprep(strWrite, 'x','0','ignorecase');
                                                                captureWrite    = uint16(bin2dec(strWrite));
                                                                maskWriteString = repmat('0', 1, 16);
                                                                maskWriteString(indxs) = '1';
                                                                captWriteMask   = uint16(bin2dec(maskWriteString)); % Write's Logic Mask
                                                        end                                                        
                                                        if ~isempty(t1) && ~isempty(t2)                                                                
                                                                if t1 >= t2
                                                                        fprintf('\nFatal Error: BIN %g, Sequencer %g, from "%s", has a erroneous time condition range\n',...
                                                                                iBin, kSequencer, logEventSelector{jLogES})
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                end
                                                                
                                                                if countexp(e) > 1
                                                                        dispcond(condition,'Hey! you are using more than one definition of time')
                                                                end
                                                                storeTime      = cat(1,storeTime, [t1 t2]);
                                                                t1catch        = t1;
                                                                t2catch        = t2;
                                                                istimedetected = 1;
                                                        else
                                                                if captureCode ~= 1000000 && captureCode ~= 2000000 && captureCode ~= 3000000
                                                                        storeTime = cat(1,storeTime, [-1 -1]);
                                                                end
                                                        end                                                        
                                                        if ~isempty(captureCode)                                                                
                                                                if captureCode ~= 1000000 && captureCode ~= 2000000 && captureCode ~= 3000000
                                                                        storeCode = cat(2,storeCode, captureCode);
                                                                        if char(rtimes{n}(3))=='~' % There is negation
                                                                                storeSign = cat(2,storeSign, 0);
                                                                        else                       % There is no negation
                                                                                storeSign = cat(2,storeSign, 1);
                                                                        end
                                                                end
                                                        else
                                                                fprintf('Fatal Error: expression without code!!! \n');
                                                                isparsednumerically = 0;  % Numeric parsing was not approved
                                                                return
                                                        end                                                        
                                                        if ~isempty(captureFlag)                                                                
                                                                if captureFlag > 65535
                                                                        fprintf('Fatal Error: BIN %g. 16-bit Flag format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                else
                                                                        flagcatch      = captureFlag;
                                                                        fmaskcatch     = captFlagMask;
                                                                        isflagdetected = 1; 
                                                                        if captureCode ~= 2000000
                                                                                storeFlag   = cat(2,storeFlag, captureFlag );
                                                                                storeFmask  = cat(2,storeFmask, captFlagMask );
                                                                        end
                                                                end
                                                        else
                                                                if captureCode ~= 1000000 && captureCode ~= 2000000 && captureCode ~= 3000000
                                                                        storeFlag   = cat(2,storeFlag, 0);
                                                                        storeFmask  = cat(2,storeFmask, 0 );
                                                                end
                                                        end                                                        
                                                        if ~isempty(captureWrite)                                                                
                                                                if captureWrite > 65535
                                                                        fprintf('Fatal Error: BIN %g. 16-bit Write format was violated',iBin)
                                                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                                                        return
                                                                else
                                                                        Writecatch     = captureWrite;
                                                                        smaskcatch     = captWriteMask;
                                                                        isWritedetected  = 1; 
                                                                        if captureCode ~= 3000000
                                                                                storeWrite   = cat(2,storeWrite, captureWrite);
                                                                                storeWmask   = cat(2,storeWmask, captWriteMask );
                                                                        end
                                                                end
                                                        else
                                                                
                                                                if captureCode ~= 1000000 && captureCode ~= 2000000 && captureCode ~= 3000000
                                                                        storeWrite   = cat(2,storeWrite, 0);
                                                                        storeWmask   = cat(2,storeWmask, 0 );
                                                                end
                                                        end
                                                end
                                                auxstr = regexprep(auxstr, expp{e}, '');
                                        else
                                                countexp(e) = 0;  %for future application
                                        end
                                end                                
                                if istimedetected
                                        lco = size(storeCode,2);
                                        storeTime = repmat([t1catch t2catch],lco,1);
                                end
                                if isflagdetected
                                        lco = size(storeCode,2); 
                                        storeFlag  = repmat(flagcatch,1,lco);
                                        storeFmask = repmat(fmaskcatch,1,lco);
                                end
                                if isWritedetected
                                        lco = size(storeCode,2);  
                                        storeWrite = repmat(Writecatch,1,lco);
                                        storeWmask = repmat(smaskcatch,1,lco);
                                end
                                
                                %
                                % Structure
                                % Sorting by eventcode from lesser to
                                % greater including its time interval, flags, and writes
                                %
                                [ValMatrix]  = cat(1,num2cell(storeCode), num2cell(storeSign), num2cell(storeTime'), num2cell(storeFlag),...
                                        num2cell(storeFmask), num2cell(storeWrite), num2cell(storeWmask))';
                                
                                auxforsort   = ValMatrix(:,1);
                                auxforsort   = [auxforsort{:}];
                                [indx, indx] = sort(auxforsort);                                
                                [MatrixSorted] = ValMatrix(indx,:);
                                storeCode      = cell2mat(MatrixSorted(:,1)');
                                storeSign      = cell2mat(MatrixSorted(:,2)');
                                storeTime      = cell2mat(MatrixSorted(:,3:4));
                                storeFlag      = cell2mat(MatrixSorted(:,5)');
                                storeFmask     = cell2mat(MatrixSorted(:,6)');
                                storeWrite     = cell2mat(MatrixSorted(:,7)');
                                storeWmask     = cell2mat(MatrixSorted(:,8)');
                                
                                % Bad values filter
                                ecodeneg = find(storeCode <= 0, 1);
                                etimeneg = find(storeTime ~= -1 & storeTime <= 0 , 1);
                                
                                if ~isempty(ecodeneg) || ~isempty(etimeneg)
                                        fprintf('Fatal Error: BIN %g has a bad numeric expression for event code or time range\n',iBin)
                                        isparsednumerically = 0;  % Numeric parsing was not approved
                                        return
                                end
                                %
                                % Detect if there is at least one negation and if so, everything is negated. 
                                nWishedCodes  = nnz(storeSign); % number of nonzero elements in storeSign (nWishedCodes).
                                nDifferentSign = length(storeSign)-nWishedCodes;
                                
                                if nDifferentSign ~= length(storeSign) && nDifferentSign ~= 0
                                        storeSign = storeSign*0;
                                end                                
                                if istimedetected
                                        t1now  = storeTime(1,1);
                                        t2now  = storeTime(1,2);
                                        sense =  jLogES-2;
                                        
                                        if ~isempty(auxt1pre)
                                                if ((sense*t2now)<(sense*auxt2pre)) || ((sense*t1now)<(sense*auxt1pre))
                                                        fprintf('\nFatal Error: BIN %g, Sequencer %g, from "%s", has a time condition range LESSER than previous one\n',...
                                                                iBin, kSequencer, logEventSelector{jLogES})
                                                        isparsednumerically = 0;  % No paso el parsing numerico
                                                        return
                                                end
                                        end                                        
                                        auxt1pre = t1now;
                                        auxt2pre = t2now;
                                end

                                % Build a datastructure for the bin
                                % descriptor values 
                                dispcond( condition, 'Showing Values (of complex expressions):',...
                                        storeCode, storeSign, storeTime, storeFlag, storeWrite)
                                %******************************************************
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).eventcode    =   single(storeCode);
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).eventsign    =   single(storeSign);
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).timecode     =   single(storeTime);
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).flagcode     =   uint16(storeFlag);
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).flagmask     =   uint16(storeFmask);
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).writecode    =   uint16(storeWrite);
                                BIN(iBin).(logEventSelector{jLogES})(kSequencer).writemask    =   uint16(storeWmask);
                        end  % Sequencer's loop
                        
                elseif   isempty(segmentedBrackets{:}) && ~isempty(spCodes{:})    % The sequencer is not numeric
                        
                        if char(specialCodesToken{1,1}{1,1}(1)) == '~'
                                BIN(iBin).(logEventSelector{jLogES}).eventcode =   -13;  % Code is a non-value!
                                BIN(iBin).(logEventSelector{jLogES}).eventsign =   0;
                        else
                                BIN(iBin).(logEventSelector{jLogES}).eventcode =   -7;   % Code is a non-value! 
                                BIN(iBin).(logEventSelector{jLogES}).eventsign =   1;
                        end
                        
                        BIN(iBin).(logEventSelector{jLogES-1})            =  []; % delete the prehome
                        BIN(iBin).(logEventSelector{jLogES}).timecode     =  single([-1 -1]);
                        BIN(iBin).(logEventSelector{jLogES}).flagcode     =  uint16(0);
                        BIN(iBin).(logEventSelector{jLogES}).flagmask     =  uint16(65535);
                        BIN(iBin).(logEventSelector{jLogES}).writecode    =  uint16(0);
                        BIN(iBin).(logEventSelector{jLogES}).writemask    =  uint16(65535);
                        BIN(iBin).(logEventSelector{jLogES+1})            =  [];  % Delete the posthome
                        isworkingFine = 0;  % Don't continue with the post home because the prehome was rejected.
                        
                else   % No numeric sequencer and no special sequencer (~* or *)
                        BIN(iBin).(logEventSelector{jLogES}) =  []; % If there is no expression for the field, then it will be empty
                end
                jLogES = jLogES + 1;  % Field Number (pre, at, and post)
        end   % LES's loop
        % name the bin been processed
        BIN(iBin).namebin  =   ['BIN ' num2str(iBin)];
end % Bin's loop