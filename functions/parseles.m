% PURPOSE: parses formulas at bin descriptor file
%
%        Log  files  are  generated  during  data  acquisition and recording,  and
%        contain  a  summary  of  the various events, their  times  of  occurrence,
%        the  condition  (as  a  numerical code), and a set of flags  that  denote
%        various miscellaneous information.
%
%        Log event selectors (LESs) form a standardized mechanism  for representing
%        specific log items. LESs consist  of ASCII  text that is usually generated
%        using  a  text  editor, and are evaluated and rebuilding as a data
%        structure by parsingbd.m and bdgetdata.m in the new ERPLAB system.
%
%        These LESs are used by binlister.m.  Hence, mastering the syntax and
%        semantics of LESs will facilitate the use of binlister.m
%
%        A  LES can be as simple as a single numerical event code, or quite com-
%        plicated, including sequential dependencies, tests of various flags, or
%        temporal  contingencies.   As  an  introductory example, here are a few
%        LESs and the events that would be matched by the LES in a logfile:
%
%               LES                      MATCHED BY
%
%             .{3}                 Any event code of 3
%
%             .{3}{4}              Any 3 followed by a 4
%
%         {97}.{2}{5}              Any 2 preceded by a 97
%                                  and followed by a 5
%
%            .{*}{t<200-800>512}   Any event that is followed by
%                                  a 512 between 200 and 800 msec.
%
%        Notice that a sequence of items comprise an LES,  and  that  each  item
%        specification is surrounded by curly brackets '{', and '}'. Also, there
%        is a home item (athome), which is the event in  the  log  file  that is
%        either matched  or not by the LES; athome is denoted by the period '.'
%        immediately to its left. In the case where one  averages  data  on  the
%        basis of matching a LES, the home item is the one to which the EEG data
%        will be temporally aligned, or time-locked.  These examples should give
%        one  a  feeling for the LES system, but by no means demonstrate all the
%        possible constructions (see binlister logic document).
%
%
%   (Adapted from ERPSS Manuals (UCSD). Jonathan C. Hansen, 15 May 1990)
%
% *** This function is part of ERPLAB Toolbox ***
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
% PODER LEER UNA LINEA VIRTUAL QUE TENGA MAS DE UNA LINEA FISICA USANDO '\\'
% LIMITAR ESTA LINEA VIRTUAL.

function [prehome athome posthome isbasicparsed] = parseles(parsingline, iLineBeenParsed, iBinBeenParsed)

if nargin < 3
      help parseles
      return
end

%
% First, eliminates any white space from parsing line
%
pat = '\s+';
parsingline    = regexprep(parsingline, pat, '');

%
% builts a dotted line for hints during parsing feedbacks
%
dottedLine       = repmat('.',1,length(parsingline));
errorPointer     = {};
mistkPointer     = {};
timeErrorPointer = {};
isbasicparsed    = 0;
nTotalErrors     = 0;

%
% BASIC SYNTAX TEST
%
%
% 1) Check the existency of the time-locked point and see if there is more
% than one
parsinglineaux = parsingline;
parsingline = regexprep(parsingline, '".*?"', ''); % hides rt filename's extension (.txt)
[mattimelockpoint errorPointer{1}] = regexp(parsingline, '(\.)',    'match','start');
[postimelockpoint errorPointer{2}] = regexp(parsingline, '(\d\.)|(\.\d)|(\.$)', ...
      'match','start');
errorPointer{2} = {}; % erase later

if isempty(mattimelockpoint)
      fprintf('Error Line %g BIN %g : There is not a time-lock point !!! \n',...
            iLineBeenParsed, iBinBeenParsed);
      nTotalErrors = nTotalErrors + 1;
end
if length(mattimelockpoint)>1
      fprintf('Error Line %g BIN %g :  You have %g time-lock points!!! \n',...
            iLineBeenParsed, iBinBeenParsed, length(mattimelockpoint))
      nTotalErrors = nTotalErrors + 1;
else
      errorPointer{1}={}; %delete the position of the right period
end
if ~isempty(postimelockpoint) % || ~isempty(postimelockpointfin)
      fprintf('Error Line %g BIN %g : time-lock point in a wrong position \n',...
            iLineBeenParsed, iBinBeenParsed);
      nTotalErrors = nTotalErrors + 1;
end

%
% 2) Search for non-valid characters
%
mataux       = regexprep(parsingline, '[tfwab{}<>;,:.~*xrt-]', '');
mataux       = regexprep(mataux, '".*?"', ''); % removes rt filename(s)
[matoddword] = regexp(mataux, '\D', 'match');

if ~isempty(matoddword)
      sform1 = repmat('%c ',1,length(matoddword));
      fprintf(['Error Line %g BIN %g : Unknow caracter "' sform1 '"\n'], iLineBeenParsed,...
            iBinBeenParsed, char(matoddword(:)));
      nTotalErrors = nTotalErrors + 1;
end

%
% 3) Search for non-numeric repeated characters
%
[matrep tokrep errorPointer{3}] = regexp(parsingline, '(\[^x])\1', 'match','tokens',...
      'start');

if ~isempty(matrep) && (length(mattimelockpoint) == 1)
      sform2 = repmat('%s ',1,length(matrep));
      fprintf(['Error Line %g BIN %g : Duplicated character ' sform2 ' \n'],...
            iLineBeenParsed, iBinBeenParsed, char(matrep(:)));
      nTotalErrors = nTotalErrors + 1;
else
      errorPointer{3} = [];
end

%
% 4) Checks that parenthesis are balanced and correct
%
[matleftbrack ]      = regexp(parsingline, '({)', 'match');
[matrightbrack]      = regexp(parsingline, '(})', 'match');
[matoddbrack errorPointer{4}]  = regexp(parsingline, '\(*\)*\[*\]*','match','start');

if length(matleftbrack) ~= length(matrightbrack);
      fprintf('Error Line %g BIN %g : Unbalanced or unexpected braces\n', iLineBeenParsed,...
            iBinBeenParsed);
      nTotalErrors = nTotalErrors + 1;
end
if ~isempty(matoddbrack);
      fprintf('Error Line %g BIN %g : wrong bracket or parentheses\n', iLineBeenParsed,...
            iBinBeenParsed);
      nTotalErrors = nTotalErrors + 1;
end

if isempty(matleftbrack);
      fprintf('Error Line %g BIN %g : What happen with you?????\n', iLineBeenParsed,...
            iBinBeenParsed);
      nTotalErrors = nTotalErrors + 1;
end
[matleftbrack2 ]  = regexp(parsingline, '(<)', 'match');
[matrightbrack2]  = regexp(parsingline, '(>)', 'match');

%
% FURTHER SYNTAX TEST
% 1) If the angle bracket <> exists search for the following combinations
%                 {t<  :f<   :~f<   :s<   :c<
if ~isempty(matleftbrack); % Implies that should have time flag set or clear
      
      if length(matleftbrack2) ~= length(matrightbrack2);
            fprintf('Error Line %g BIN %g : Unbalanced or unexpected angle brackets\n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end
      
      %
      % Probable error syntax
      %
      [mistk1  mistkPointer{1}]   = regexp(parsingline, '[^tfwab]<'  ,'match','start');
      [mistk2  mistkPointer{2}]   = regexp(parsingline, 't[^<]|f[^ab<]|w[^ab<]|rt[^<]'  ,'match','start');
      [mistk3  mistkPointer{3}]   = regexp(parsingline, '{}'           ,'match','start');
      [mistk4  mistkPointer{4}]   = regexp(parsingline, '[fwab]<>'           ,'match','start');
      [mistk5  mistkPointer{5}]   = regexp(parsingline, '>{'           ,'match','start');
      [mistk6  mistkPointer{6}]   = regexp(parsingline, '[^:][fwr]'     ,'match','start');
      [mistk7  mistkPointer{7}]   = regexp(parsingline, '[{<]['':;-]'    ,'match','start');
      [mistk8  mistkPointer{8}]   = regexp(parsingline, '[:;-][}>]'    ,'match','start');
      [mistk9  mistkPointer{9}]   = regexp(parsingline, '[:;-][{<]'    ,'match','start');
      [mistk10 mistkPointer{10}]  = regexp(parsingline, '[}][:;-]'     ,'match','start');
      [mistk11 mistkPointer{11}]  = regexp(parsingline, '\d+t'         ,'match','start');
      [mistk12 mistkPointer{12}]  = regexp(parsingline, ':f<\d+[-;:{}]','match','start');
      [mistk13 mistkPointer{13}]  = regexp(parsingline, ':w<\d+[-;:{}]','match','start');
      [mistk14 mistkPointer{14}]  = regexp(parsingline, 't<(\d*)[-](\d*)+>[^~0-9]','match','start');
      [mistk15 mistkPointer{15}]  = regexp(parsingline, 'f<(\d*)+>(\d+)','match','start');
      [mistk16 mistkPointer{16}]  = regexp(parsingline, 'w<(\d*)+>(\d+)','match','start');
      [mistk17 mistkPointer{17}]  = regexp(parsingline, '[;:-]+[;:-]+'  ,'match','start');
      [mistk18 mistkPointer{18}]  = regexp(parsingline, '(\d+\{)|(\}\d+)','match','start');
      [mistk19 mistkPointer{19}]  = regexp(parsingline, '\:(\d+)','match','start');
      % First Special constraint while we get some agreement.
      [mistk20 mistkPointer{20}] = regexp(parsingline, '[^{r]t','match','start');
      
      %new
      [mistk21 mistkPointer{21}]  = regexp(parsingline, ':fa<\d+[-;:{}]' ,'match','start');
      [mistk22 mistkPointer{22}]  = regexp(parsingline, ':fb<\d+[-;:{}]' ,'match','start');
      [mistk23 mistkPointer{23}]  = regexp(parsingline, 'wa<(\d*)+>(\d+)','match','start');
      [mistk24 mistkPointer{24}]  = regexp(parsingline, 'wb<(\d*)+>(\d+)','match','start');
      [mistk25 mistkPointer{25}]   = regexp(parsingline, '[:][^fwr]'      ,'match','start');
      
      %
      % Error messages and error counters
      %
      if ~isempty(mistk1) || ~isempty(mistk2)
            fprintf('Error Line %g BIN %g : Incorrect syntaxes using "t<" "f<" or "w<" \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk3) || ~isempty(mistk4)
            fprintf('Error Line %g BIN %g : Empty brackets {} or angle <> \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk5)
            fprintf('Error Line %g BIN %g : Incorrect syntaxes using ">" and "{" \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk6)
            fprintf('Error Line %g BIN %g : Incorrect syntaxes using ":f or :w" \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk7) || ~isempty(mistk8) || ~isempty(mistk9) || ~isempty(mistk10)
            fprintf('Error Line %g BIN %g : Incorrect syntaxes using "{<:;->}" \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk11)
            fprintf('Error Line %g BIN %g : Incorrect syntax using event code and time \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk12) || ~isempty(mistk21) || ~isempty(mistk22)
            
            fprintf('Error Line %g BIN %g : Incorrect syntax using flag operand \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk13) || ~isempty(mistk23) || ~isempty(mistk24)
            fprintf('Error Line %g BIN %g : Incorrect syntax using write operand \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk14)
            fprintf('Error Line %g BIN %g : Incorrect syntax. No event code for time interval \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk15) || ~isempty(mistk16) || ~isempty(mistk18)
            
            fprintf('Error Line %g BIN %g : Numeric argument in wrong position \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk14)
            fprintf('Error Line %g BIN %g : Incorrect syntax. No event code for time interval \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk17)
            fprintf('Error Line %g BIN %g : jointed metacharacters  ";:" ":;" ";-" "-;" ":-"  or  "-:" \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk19)
            
            fprintf('Error Line %g BIN %g : numeric argument in wrong position or wrong separator \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end
      
      % First Special constraint while we get some agreement.
      
      if ~isempty(mistk20)
            fprintf('Error Line %g BIN %g : time condition should be declared one time, and at the beginning of the sequencer\n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end      
      if ~isempty(mistk25)
            fprintf('Error Line %g BIN %g : Incorrect syntaxes using ":" \n',...
                  iLineBeenParsed, iBinBeenParsed);
            nTotalErrors = nTotalErrors + 1;
      end
      
      % TIME ARGUMENTS syntax
      %
      % 6)  Search for errors within the time brackets
      %
      % detect where the time range is defined
      
      [mm targ timeErrorPointer{1}] = regexp(parsingline, '{t/?<(.*?)>', 'match', 'tokens',...
            'start');
      
      if ~isempty(mm)
            timearg = targ{:};
            [mx]    = regexp(timearg(:), '([:;-]*\d+[:;-]*)','match');
            
            if length(mx{:}) ~= 2
                  sform3 = repmat('%s ',1,length(mx));
                  fprintf(['Error Line %g BIN %g : Incorrect format for time interval: ' sform3 ...
                        '"\n'], iLineBeenParsed, iBinBeenParsed, char(timearg));
                  nTotalErrors = nTotalErrors + 1;
            else
                  [mi]  = regexp(timearg{:}, '[:;<>{}]','match');
                  
                  if ~isempty(mi)
                        fprintf('Error Line %g BIN %g : Bad separator in time interval \n',...
                              iLineBeenParsed, iBinBeenParsed);
                        nTotalErrors = nTotalErrors + 1;
                  else
                        timeErrorPointer{1}=[];
                  end
            end
      end
      
      % Later, we'll need to verify that the interval was entered in the
      % right order. For prehome - greater/lesser; For posthome -
      % greater/lesser
end

% WHAT TO DO?   ANY DETECTED ERROR WILL FINISH PROCESSING
% 7)  Any error detected will finish the process, so if it finds errors in
% the parsed line, then display a summary of errors and indicated where the
% errros are in the line (except unbalanced parenthesis)

if nTotalErrors==0
      
      parsingline = parsinglineaux; % recover original line
      parsingline = regexprep(parsingline, '\.\w*?"', '9999999999999999"'); % mask the extension (.txt)      
      isbasicparsed = 1;
      prehome  = [];
      athome   = [];
      posthome = [];
      
      %
      % 5) Divide the file into two parts around the time-lock prehome
      % point and hresidue
      %
      % Matlab 7.3 and higher  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %
      [pspliter preeventpost] = regexp(parsingline, '\.','match','split');
      prehome     =   preeventpost(1);  % Expression before the period(to the left)
      hresidue    =   preeventpost(2); % Expression after the period(to the right)
      [pspliter2 atandpost]    =   regexp(hresidue, '^{~*(\d+).*?}','match','split');
      
      if ~isempty(atandpost{:})
            athome      =   pspliter2{1}(1);
            posthome    =   atandpost{1}(2);
      else
            athome      =   hresidue(1);
            posthome    =   {''};
      end
      
      %just in case...(should be only for posthome) recovers the extension (.txt)
      prehome  = regexprep(prehome,'9999999999999999','.txt');
      athome   = regexprep(athome,'9999999999999999','.txt');
      posthome = regexprep(posthome,'9999999999999999','.txt');      
      [preall]     = regexp(prehome, '[*]','match');
      [postall]    = regexp(posthome,'[*]','match');
      [allhome]    = regexp(athome,'[*]','match');
      [allmixhome] = regexp(athome,'[0-9]','match');
      
      if ~isempty(preall{:})
            fprintf('Error FATAL at BIN %g: You cannot use "*" in a prehome expression!\n', iBinBeenParsed)
            isbasicparsed=0;
            return
      end      
      if ~isempty(postall{:})
            fprintf('Error FATAL at BIN %g: You cannot use "*" in a posthome expression!\n', iBinBeenParsed)
            isbasicparsed=0;
            return
      end      
      if isempty(athome{:})
            fprintf('Error FATAL at BIN %g: Home is empty!!!\n', iBinBeenParsed)
            isbasicparsed=0;
            return
      end      
      if ~isempty(allhome{:}) && ~isempty(allmixhome{:})
            fprintf('Warning: Is not too smart to use some code and "*" together in BIN %g...\n', iBinBeenParsed)
            isbasicparsed=0;
            return
      end      
else
      prehome  = {''};
      athome   = {''};
      posthome = {''};
      fprintf('...\n');
      fprintf('Line %g Error Resume: \n', iLineBeenParsed);
      fprintf('Line %g has %g errors during syntax parsing.... \n', iLineBeenParsed,...
            nTotalErrors);
      fprintf('HINT:\n');
      fprintf([parsingline '\n']);
      
      for v = 1:length(errorPointer)
            
            if ~isempty(errorPointer{v})
                  dottedLine(1,errorPointer{v})='x';
            end
      end      
      for v = 1:length(mistkPointer)
            
            if ~isempty(mistkPointer{v})
                  dottedLine(1,mistkPointer{v})='X';
            end
      end      
      for v = 1:length(timeErrorPointer)
            
            if ~isempty(timeErrorPointer{v})
                  dottedLine(1,timeErrorPointer{v})='X';
            end
      end
      fprintf([dottedLine '\n']);
      lowLine = repmat('_',1,60);
      fprintf([lowLine '\n']);
      return
end
