% PURPOSE: subroutine for binlister.m
%          Convert formulas at bin descriptor file into a structure (BIN)
%
% FORMAT
%
% [BIN, nwrongbins] = decodebdf(bdfilename)
%
% Inputs:
%
%   bdfilename  - name of bin descriptor file to read (*.txt)
%
% Outputs:
%
%   BIN          - output structure with bin conditioning (numeric format)
%  nwrongbins    - numeric parsing, wrong-bin counter.
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% May 2008

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

function [BIN, nwrongbins] = decodebdf(bdfilename)

if nargin < 1
        help decodebdf
        return
end

% Part1: Read Bin Descriptor File
% Line by line
fprintf('\nParsing Bin Descriptor File and creating BIN structure...\n');
fid_bdf     = fopen(bdfilename);
pointerLine = 1;
bincounter  = 1;
bdcounter   = 1;
binToggling = 0;
BIN         = struct([]);
nwrongbins  = 0;
isbdpresent = 0;

% read first line from bdfilename bd file
currentBdfLine = fgetl(fid_bdf);

while ischar(currentBdfLine)
        
        % Remove leading and trailing white space from current line
        healthyLine      = strtrim(currentBdfLine);
        
        % Is this a comment line?
        [lookbincomment] = regexpi(healthyLine, '^#','match');
        
        if isempty(lookbincomment) % when the line is not a comment.
                
                % caputure wrong sintax for bin expression
                [lookbinaround1] = regexpi(healthyLine, '.+bin.*\D+','match');
                [lookbinaround2] = regexpi(healthyLine, 'bin\s*\d+\D+.*','match');
                
                if ~isempty(lookbinaround1)
                        fprintf('**************************************************\n');
                        fprintf('ERROR LINE %g: Expected BIN %g, found "%s" \n',...
                                pointerLine, bincounter, char(lookbinaround1));
                        fprintf('**************************************************\n');

                        %increase error counter
                        nwrongbins = nwrongbins+1;
                        break
                end                
                if ~isempty(lookbinaround2)
                        fprintf('**************************************************\n');
                        fprintf('ERROR LINE %g: Expected BIN %g, found additional character "%s" \n',...
                                pointerLine, bincounter, char(lookbinaround2));
                        fprintf('**************************************************\n');
                        %increase error counter
                        nwrongbins = nwrongbins+1;
                        break
                end
                
                % If everything was OK with bin expression, let's read it! (upper or lower case)
                [readBinLine captureBinNum] = regexpi(healthyLine, 'bin\s*(\d+)','match','tokens');
                
                % Read LES suspected 10 de marzo 2008
                [lessuspected]   = regexp(healthyLine, '.*{', 'match') ;
                [bdsuspected]    = regexp(healthyLine, '\S+', 'match') ;
                
                if ~isempty(readBinLine)
                        numberbin = str2num(cell2mat(captureBinNum{1}(1))); % numeric format for bin's order.
                        
                        if numberbin ~= bincounter % is the bin's number the expected number?
                                fprintf('**************************************************\n');
                                fprintf('FATAL ERROR:  Bad numbered bin was found! \n');
                                fprintf('ERROR LINE %g: Expected BIN %g, found BIN %g ! \n',...
                                        pointerLine, bincounter, numberbin);           
                                fprintf('**************************************************\n');
                                %increase error counter
                                nwrongbins = nwrongbins+1;
                                break
                        end                        
                        if binToggling ~= 0 % Should this line be a bin number?
                                fprintf('**************************************************\n');
                                fprintf('FATAL ERROR:  Bad numbered bin was found! \n');
                                fprintf('ERROR LINE %g: Expected Bin Descriptor for BIN %g, found BIN %g ! \n',...
                                        pointerLine, bincounter-1, numberbin);
                                fprintf('**************************************************\n');
                                %increase error counter
                                nwrongbins = nwrongbins+1;
                                break
                        else
                                bincounter = bincounter+1;
                                % Now, let's wait a bin descriptor at next line...
                                binToggling = 1;
                        end
                        
                        % Read Bin Descriptor (bd) suspected
                        %[lessuspected]  = regexp(healthyLine, '.*{', 'match');     % 20 febrero *                        
                elseif ~isempty(lessuspected) %bd detected?                        
                        if binToggling % Should this line be a bd?                                
                                % Perform a complete syntax parsing and get bd expressions for this BIN
                                % Call to The Main Parsing Test Function
                                [prehome athome posthome isbasicparsed] = parseles(healthyLine, pointerLine, numberbin);
                                
                                if isbasicparsed % Was parsed OK?
                                        
                                        %Yes, then let's capture separated sintax expressions related to home codes
                                        BIN(numberbin).expression(1)  = prehome;
                                        BIN(numberbin).expression(2)  = athome;
                                        BIN(numberbin).expression(3)  = posthome;
                                        
                                        if isbdpresent
                                                BIN(numberbin).description  = storedescription;
                                        else
                                                BIN(numberbin).description  = blanks(100);
                                        end
                                        
                                        BIN(numberbin).prehome     = [];
                                        BIN(numberbin).athome      = [];
                                        BIN(numberbin).posthome    = [];
                                        BIN(numberbin).namebin     = [];                                        
                                        isbdpresent = 0;
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%% Check if there is ouput processing
                                        [healthyLine, rtname, rtindex] = get_rtname(healthyLine);
                                        
                                        %BIN(numberbin).rtname = '';
                                        
                                        if ~isempty(rtname)
                                                BIN(numberbin).rtname = rtname;
                                                BIN(numberbin).rtindex = rtindex;                                                
                                        else
                                                BIN(numberbin).rtname = [];
                                                BIN(numberbin).rtindex = [];
                                        end
                                        
                                        BIN(numberbin).rt = [];
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                else
                                        % parsing was not ok, let's increase error counter
                                        nwrongbins = nwrongbins+1;
                                end
                                
                                % increase bd counter
                                bdcounter   = bdcounter+1;
                                
                                % Now, let's wait a bin number at next line...
                                binToggling = 0;                                
                        else % Should this line be a bd?
                                fprintf('**************************************************\n');
                                fprintf('ERROR LINE %g: Expected BIN %g, found additional Bin Descriptor \n',...
                                        pointerLine, bincounter);
                                fprintf('**************************************************\n');
                                
                                %increase error counter
                                nwrongbins = nwrongbins+1;
                                break
                        end
                else
                        if binToggling && ~isempty(bdsuspected) % Should this line be a bd?                                
                                if length(healthyLine)>100
                                        storedescription = [healthyLine(1:97) '...'];
                                else
                                        storedescription  = [healthyLine blanks(100-length(healthyLine))];  %  entera una descripcion de 100 caracteres homogeneamente
                                end
                                isbdpresent = 1;
                        end
                end
        end
        
        %increase line pointer
        pointerLine = pointerLine + 1;
        % read next line from bdfilename bd file
        currentBdfLine = fgetl(fid_bdf);
end

fclose(fid_bdf);

if isempty(BIN)
        msgboxText =  'This file is anything else but a bin descriptor file!';
        tittle = 'ERPLAB: Error, unrecognized bin descriptor file';
        errorfound(msgboxText, tittle);
        nwrongbins=1;
        return
end

fprintf('\nSintax Report:\n');
fprintf('File %s has %g wrong bins.\n', bdfilename, nwrongbins)

%--------------------------------------------------------------------------
function [bdf_line, rtname, rtindex] = get_rtname(bdf_line)
%%% Get RT file name and index in the post-home condition.
%
% Inputs:
% 1. bdf_line - BDF line
%
% Outputs:
% 1. bdf_line - Modified BDF line
% 2. rtname - RT variable name
% 3. rtindex - Indices of the post-home conditions
%

rtindex = [];
rtname = '';
bdf_line = strtrim(bdf_line);

%%% Check output processing
checkOp = regexpi(bdf_line, '(.*[.].*{.*})({.*:\s*rt<".*?">}.*)', 'tokens');

try        
        % Check on output processing
        if ~isempty(checkOp)
                
                %%% Group pre-home and home as one
                matchedPos = findstr(bdf_line, '.');
                
                %%% (opening) curly bracket positions (= number of sequencers)
                bracketPos = findstr(bdf_line(matchedPos(1) + 1:end), '{');
                
                %%% Exclude at home from this
                numPostHome = length(bracketPos) - 1;
                
                % Check number of post-home conditions
                if (numPostHome > 0)
                        
                        postHomeStrings = repmat('({.*})', 1, numPostHome);
                        regExpStr = ['(.*[.].*{.*})', postHomeStrings];
                        clear postHomeStrings;
                        
                        %%% Parse the line into two tokens (pre-home & home) and post-home
                        matchedTokens = regexpi(bdf_line, regExpStr, 'tokens');
                        
                        % Check tokens
                        if ~isempty(matchedTokens)
                                
                                matchedTokens = matchedTokens{1};
                                %firstToken = matchedTokens{1};
                                postHomeStrs = matchedTokens(2:end);
                                
                                %%% Output String
                                outStr = ':\s*rt<".*?">';
                                startInd = regexpi(postHomeStrs, outStr);
                                startInd = find(beh_scripts_good_cells(startInd) ~= 0);
                                rtindex  = startInd;
                                
                                %%% RT file names and post-home strings
                                rtname = strtrim(regexprep(postHomeStrs(startInd), '.*:\s*rt<\"(.*)\">}', '$1'));
                                
                                %%% Modified BDF line
                                %bdf_line = [firstToken, postHomeStrs{:}];                                
                        end
                        % End for check on matched tokens
                end
                % End for check on number of post-home conditionss
        end
        % End for check on output processing        
catch
      return        
end
