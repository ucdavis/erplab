% PURPOSE: syntactic parsing of formulas for binoperator and pop_eegchanoperator/pop_erpchanoperator
%
% FORMAT:
%
% [option recall conti] = checkformulas(formulaArray, funcname, editormode)
%
%
% INPUT:
%
% formulaArray     - cell array containing formulas
% funcname         - 'pop_binoperator' or'pop_eegchanoperator'/'pop_erpchanoperator'
% editormode       - 0:appends new chans/bins to the current EEG/ERP
%                    1:creates chans/bins at a new EEG/ERP
%
% OUTPUT
%
% option           -  0:appends new chans/bins to the current EEG/ERP
%                     1:creates chans/bins at a new EEG/ERP
%                    -1: I dunno...
% conti            - continue; 1 yes; 0 no
%
%
% See also pop_binoperator.m pop_eegchanoperator.m pop_erpchanoperator.m
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

function [option, recall, conti] = checkformulas(formulaArray, funcname, editormode)

if nargin<1
        help checkformulas
        return
end
if nargin>3
        error('ERPLAB: you entered too many inputs for checkformulas()')
end
if nargin<3
        editormode = 2;
end
if nargin<2
        funcname = '';
end
option = [];
recall = 1;
conti  = 0;
if strcmpi(funcname, 'pop_binoperator3') || strcmpi(funcname, 'pop_binoperator') ||...
                strcmpi(funcname,'binoperGUI')
        exp01 = '\<(\s*[n]*b[in]*\d+\s*=)';
        exp02 = '(\s*nb[in]*\d+)';
        exp03 = 'bin';
        exp04 = '(\s*[n]*b[in]*\d+)';
        exp05 = '\<(\s*nb[in]*\d+\s*=)';
        datatype = 'ERPset';
elseif strcmpi(funcname, 'pop_eegchanoperator') || strcmpi(funcname, 'pop_erpchanoperator')||...
                strcmpi(funcname,'eegchanoperGUI') || strcmpi(funcname,'erpchanoperGUI')
        exp01 = '\<(\s*[n]*ch[an]*\d+\s*=)';
        exp02 = '(\s*nch[an]*\d+)';
        exp03 = 'chan';
        exp04 = '(\s*[n]*ch[an]*\d+)';
        exp05 = '\<(\s*nch[an]*\d+\s*=)';
        
        if strcmpi(funcname, 'pop_eegchanoperator') || strcmpi(funcname,'eegchanoperGUI')
                datatype = 'dataset';
        else
                datatype = 'ERPset';
        end
else
        msgboxText =  sprintf('Error: formulas are not related to the function %s.', funcname);
        tittle = 'ERPLAB: checkformulas() error:';
        errorfound(msgboxText, tittle);
        return
end

noemptyf     = ~cellfun(@isempty,formulaArray);
formulaArray = formulaArray(noemptyf);
nformulas    = length(formulaArray);

if nformulas==0
        msgboxText =  sprintf('Error: There is not formula!');
        tittle = 'ERPLAB: checkformulas() error:';
        errorfound(msgboxText, tittle);
        return
end

%
% Remove label
%
%
delchan = 0;
reref   = 0;
% cimode  = 0; % contra ipsi mode disabled by default
chlabel = 0;
specfuncerror = 0;

for i=1:nformulas
        tokdelchan = regexpi(formulaArray{i}, '\s*delerpchan\((.*)?\)', 'tokens','ignorecase');
        tokreref   = regexpi(formulaArray{i}, '\s*chreref\((.*)?\)', 'tokens','ignorecase');
        tokprepci  = regexpi(formulaArray{i}, '^\s*prepareContraIpsi', 'match','ignorecase');
        
        if ~isempty(tokdelchan)
                delchan = 1;
                break
        end
        if ~isempty(tokreref)
                reref = 1;
                break
        end
        if ~isempty(tokprepci)
                fprintf('\nNOTE: ERPLAB has detected a contra/ipsi mode call. Channels and data will be reorganized and renamed.\n')
                %cimode = 1; % contra ipsi mode detected
                %break
        end
        
        tokdelchlab  = regexpi(formulaArray{i}, '\s*changebinlabel\((.*)?\)', 'tokens','ignorecase');
        tokswbdatach = regexpi(formulaArray{i}, '\s*swapbindata\((.*)?\)', 'tokens','ignorecase');
        tokswbinlab  = regexpi(formulaArray{i}, '\s*swapbinlabel\((.*)?\)', 'tokens','ignorecase');
        tokcommentb  = regexpi(formulaArray{i}, '^#', 'match'); % comment symbol
        
        if ~isempty(tokdelchlab) || ~isempty(tokswbdatach) || ~isempty(tokswbinlab) || ~isempty(tokcommentb)                
                if (editormode==0 || editormode==2) || ~isempty(tokcommentb)
                        formulaArray{i} = '';
                        chlabel = 1;
                else
                        specfuncerror = 1;
                        break
                end
        else    
                toklabel = {};
                toklabel = regexpi(formulaArray{i}, '\s*(label\s*\=*\s*.*)', 'tokens');
                
                while any(cellfun('isclass',toklabel,'cell'))
                        toklabel = cat(2,toklabel{:});
                end
                if ~isempty(toklabel)
                        formulaArray = strrep(formulaArray, char(toklabel), '');
                end
        end
end
if specfuncerror==1
        % Create chans/bins at a new EEG/ERP does not match with mode option
        msgboxText =  sprintf('Error: This function only works on recursive mode.');
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
end
if delchan
        fprintf('\nWARNING ERPLAB: delerpchan() function was called.\n')
        fprintf('WARNING ERPLAB: From this point on, channel indices will refear to the modified channel list.\n')
        option = 0;
        recall = 0;
        conti  = 1;
        return
end
if reref
        option = 0;
        recall = 0;
        conti  = 1;
        return
end
% if cimode % contra ipsi mode detected. JLC
%         fprintf('\nNOTE: ERPLAB has detected a contra/ipsi mode call. Channels and data will be reorganized and renamed.\n')
%         option = 0;
%         recall = 0;
%         conti  = 1;
%         return
% end

noemptyf     = ~cellfun(@isempty,formulaArray);
formulaArray = formulaArray(noemptyf);
nformulas    = length(formulaArray);

if nformulas==0 && chlabel == 1
        option = 0;
        recall = 0;
        conti  = 1;
        return
end

%
% Matlab 7.3 and higher %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
[expspliter, parts] = regexpi(strtrim(formulaArray), '=|prepareContraIpsi','match','split'); % I included prepareContraIpsi actually to skip its evaluation(since it does not have an "=" sign)
assymerr = 0;

for t=1:nformulas
        pleft  = regexpi(parts{t}{1}, exp04, 'tokens');
        pright = regexpi(parts{t}{2}, exp04, 'tokens');
        if ~isempty(pright) && isempty(pleft)
                assymerr = 1;
                indexf = t;
                break
        end
end
if assymerr == 1;
        msgboxText =  sprintf('Error: Left side of formula %s must be a %s variable', formulaArray{indexf}, exp03);
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
end

%
% Check1: nchan to the right? || nbin to the right?
%
% capure any nbin & bin or nchan & chan, at the left side
%
tokleft = regexpi(formulaArray, exp01, 'tokens');

while any(cellfun('isclass',tokleft,'cell'))
        tokleft = cat(2,tokleft{:});
end

%
% remove left side
%
tokrightr = regexprep(formulaArray, exp01, '', 'ignorecase')  ;

%
% capture nbin or nchan at the right side
%
tokrightnew = regexpi(tokrightr, exp02, 'tokens')   ;

while any(cellfun('isclass',tokrightnew,'cell'))
        tokrightnew = cat(2,tokrightnew{:});
end
if ~isempty(tokrightnew)
        msgboxText =  sprintf('Error: You cannot use "n%s" syntax on the right side of the formulas.', exp03);
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
end

%
% Check2: nchan or chan? ||  nbin or bin?
%
% capture only nbin or nchan, at the left side
%
tokleftnew = regexpi(formulaArray, exp05, 'tokens') ;

while any(cellfun('isclass',tokleftnew,'cell'))
        tokleftnew = cat(2,tokleftnew{:});
end

%
% total nbin & bin or nchan & chan, at the left side (total bin or chan-related formulas)
%
ntokleft  = length(tokleft) ;

%
% total nbin or nchan, at the left side
%
ntokleftnew  = length(tokleftnew);

if ntokleft==ntokleftnew && ntokleftnew>0 && (editormode==1 || editormode==2)
        % Create chans/bins at a new EEG/ERP
        option = 1;
        recall = 0;
        conti  = 1;
elseif ntokleftnew==0 && ntokleft>0 && (editormode==0 || editormode==2)
        % Append new chans/bins to the current EEG/ERP
        option = 0;
        recall = 0;
        conti  = 1;
elseif ntokleft==ntokleftnew && ntokleftnew>0 && editormode==0
        % Create chans/bins at a new EEG/ERP does not match with mode option
        msgboxText =  sprintf('Error: %s cannot modify an existing %s using "n%s" syntax.', funcname, datatype, exp03);
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
elseif ntokleftnew==0 && ntokleft>0 && editormode==1
        % Create chans/bins at a new EEG/ERP  does not match with mode option
        msgboxText =  sprintf('Error: %s cannot create a new %s without "n%s" syntax.', funcname, datatype, exp03);
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
elseif ntokleftnew~=ntokleft && ntokleftnew>0
        msgboxText =  sprintf('Error: %s cannot operate with mixed "%s" and "n%s" at the left side of formulas.', funcname, exp03, exp03);
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
else
        msgboxText =  sprintf('Error: %s could not find any relationship between equations and the window on the right (%ss).', funcname, exp03);
        tittle = sprintf('ERPLAB: %s() error:', funcname);
        errorfound(msgboxText, tittle);
        return
end
