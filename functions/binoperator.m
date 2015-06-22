% PURPOSE: subroutine for pop_binoperator
%          Bin Operations functions allow you to compute new bins through algebraic expressions
%          running over bins in the current ERP structure.
%
% FORMAT:
%
% [ERPout conti cancelop]= binoperator(ERPin, ERPout, expression)
%
%
% Inputs:
%
%   ERPin        - current ERPset
%   ERPout       - output ERPset
%   expression   - formula(s) for creating/changing bins
%
%
% Output
%
%   ERPout       - output ERPset
%   conti        - continue bin processing. 1 continue; 0 abort
%   cancelop     - cancel all. 1 yes; 0 no
%
% EXAMPLES
%
% You can average multiple bins together, and you can compute difference waves.
% It operates in the same manner as Channel Operations.
% That is, you create equations that look like this:
%
% bin6 = 0.5*bin3 +– 0.5*bin2”
%
% Your bins are stored in a Matlab structure named ERP, at bindata field (ERP.binvg). This field has 3 dimensions:
%
%      row          =   channels
%      column       =   points (signal)
%      depth        =   bin's slot (bin index).
%
% So, the depth dimension will increase as you define a new, correctly numbered (sorted) bin.
% To create a new bin you have to simply use an algebraic expression for that bin.
%
% Example 1:
%
% Currently you have 4 bins created, and now you need to create a new bin
% (bin 5) with the difference between bin 2 and 4. So, you should go to Bin
% Operation, at the ERPLAB menu, and this will pop up a new GUI. At the editing
% window enter the next simple expression:
%
% bin5 = bin2 - bin4  label Something Important
%
% and press RUN.
%
% Note1: You can also write in a short style expression:
%
% b5 = b2 - b4.
%
% For label setting you could use :
%
% ...label Something Important  or
% ....label = Something Important
%
% If you do not define a label, binoperator will use a short expression of
% the current formula as a label,  BIN5: B2-B4
%
% In case you need to create more than one new bin, you will need to enter
% a carriage return at the end of each expression (formula) as you are writing
% a list of algebraic expressions.
%
% Example 2:
%
% b5 = b2 - b4   label difference
% b6 = (b1+b3)/2 label= attended   or     b6 = 0.5*b1 + 0.5*b3 ...
% b7 = abs(b5)   label rectified   or     b7 = sqrt(b5^2) ...
%
% and press RUN.
%
% Note 2: You already realized you can use bins just predefined in your list,
% so be cautious with this predefinition to avoid mistakes in long lists.
%
% Note 3: Also you can use more complex expressions as this:
% bin8 = (b1+b2)/2 - (b3+b4)/2
% or, eventually, something much weirder as this    b9 = sqrt(b2^2 + b3^2)
%
% Finally, you can save and load your formulas in order to avoid to rewrite
% it more than one time. Use EXPORT & IMPORT buttons for this, respectively.
%
%
% See also pop_binoperator.m
%
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

function [ERPout, conti, cancelop] = binoperator(ERPin, ERPout, expression, wbmsgon, errormsgtype)
if nargin<1
        help binoperator
        return
end
if nargin<5
        errormsgtype = 0; % display error in red at command window (1 means popup error window)
end
if nargin<4
        wbmsgon = 0; % warning off
end
if isempty(ERPin.chanlocs)
        for e=1:ERPin.nchan
                ERPin.chanlocs(e).labels = ['Ch' num2str(e)];
        end
end
if isempty(ERPin.ntrials.arflags) % Sep 27, 2013
        ERPin.ntrials.arflags   = zeros(ERPin.nbin, 8); %JLC
end

conti    = 1;
cancelop = 0;

% add a dot for .*, ./ and .^ operations
expression = regexprep(expression, '([*/^])', '.$1','ignorecase');
% looking for eraser command
[mater]    = regexpi(expression, '[n]*b[in]*\d+\s*=\s*\[\]', 'match');

if isempty(mater)
        eraser = 0;
else
        eraser = 1;
        %
        % Temporary constraint for bin erasing
        %
        msgboxText =  'Oops! Sorry, you cannot perform the requested operation in this version.';
        if errormsgtype
                tittle = 'ERPLAB: binoperator() Error';
                errorfound(msgboxText, tittle);
                conti = 0; % No more bin processing...
                cancelop = 1;
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText])
        end
end

%
% looking for label
%
[matlabel, toklabel] = regexpi(expression, '\s+label\s*\=*\s*(.*)', 'match', 'tokens');

if ~isempty(toklabel)
        shortexp = toklabel{:}{1};
        
        %
        % erase label from expression
        %
        expression = strrep(expression, matlabel{:}, '');
else
        shortexp = upper(regexprep(expression, '.*=\>', '')); % capture right side of formula as a description...
end

orinchan = ERPin.nchan;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change bin label?
%
tokblab  = regexpi(expression, '\s*changebinlabel(\s*b[in]*(\d+)\s*[,]\s*(.*)\s*[)]', 'tokens','ignorecase');

if ~isempty(tokblab)
        ba     = str2num(tokblab{:}{1});
        blabel = regexprep(tokblab{:}{2},'['']|["]','');
        blabel = strtrim(blabel);
        [ERPout, conti] = changebinlabel(ERPin, ba, blabel);
        return
end

%
% swap bindata?
%
tokdata  = regexpi(expression, 'swapbindata(\s*b[in]*(\d+)([@].+)*\s*[,]\s*b[in]*(\d+)([@].+)*\s*[)]', 'tokens','ignorecase');

if ~isempty(tokdata)
        ba  = str2num(tokdata{:}{1});
        cha = regexprep(tokdata{:}{2},'@',''); %":" was replaced by "@"
        if strcmp(cha,'')
                cha = [];
        else
                cha = str2num(cha);
                if isempty(cha)
                        cha = evalin('base', 'cha'); % takes value from the workspace
                end
        end
        bb  = str2num(tokdata{:}{3});
        chb = regexprep(tokdata{:}{4},'@','');
        if strcmp(chb,'')
                chb = [];
        else
                chb = str2num(chb);
                if isempty(chb)
                        chb = evalin('base', 'chb');% takes value from the workspace
                end
        end
        [ERPout, conti] = swapbindata(ERPin, ba, bb, cha, chb);
        return
end

%
% swap binlabel?
%
toklabel = regexpi(expression, 'swapbinlabel(\s*b[in]*(\d+)\s*[,]\s*b[in]*(\d+)\s*[)]', 'tokens','ignorecase');

if ~isempty(toklabel)
        ba = str2num(toklabel{:}{1});
        bb = str2num(toklabel{:}{2});
        [ERPout, conti] = swapbinlabel(ERPin, ba,bb);
        return
end

%
% weight-averaged bins?
%
iswavebin = 0;
tokwave = regexpi(expression, '[n]*b[in]*(\d+)\s*=\s*wavgbin(.*)', 'tokens','ignorecase');

if ~isempty(tokwave)
        newb   = str2num(tokwave{1}{1});
        binop  = tokwave{1}{2};
        binop  = regexprep(binop,'[n]*b[in]*','','ignorecase');
        binop  = regexprep(binop,'\s+:\s+',':');
        binop  = regexprep(binop,'\(|\)','');
        bop    = str2num(binop);
        binpos = [newb bop];
        iswavebin = 1;
        [CHANSP{1:length(binpos)}] = deal(1:ERPin.nchan);
end

%
% classic averaged bins?
%
isavebin = 0;
tokave = regexpi(expression, '[n]*b[in]*(\d+)\s*=\s*avgbin(.*)', 'tokens','ignorecase');

if ~isempty(tokave)
        newb   = str2num(tokave{1}{1});
        binop  = tokave{1}{2};
        binop  = regexprep(binop,'[n]*b[in]*','','ignorecase');
        binop  = regexprep(binop,'\s+:\s+',':');
        binop  = regexprep(binop,'\(|\)','');
        bop    = str2num(binop);
        binpos = [newb bop];
        isavebin = 1;
        [CHANSP{1:length(binpos)}] = deal(1:ERPin.nchan);
end

%
% harmonic mean of bins?
%
isharmbin = 0;
tokhm = regexpi(expression, '[n]*b[in]*(\d+)\s*=\s*harmmeanbin(.*)', 'tokens','ignorecase');

if ~isempty(tokhm)
        newb   = str2num(tokhm{1}{1});
        binop  = tokhm{1}{2};
        binop  = regexprep(binop,'[n]*b[in]*','','ignorecase');
        binop  = regexprep(binop,'\s+:\s+',':');
        binop  = regexprep(binop,'\(|\)','');
        bop    = str2num(binop);
        binpos = [newb bop];
        isharmbin = 1;
        [CHANSP{1:length(binpos)}] = deal(1:ERPin.nchan);
end

%
% median of bins?
%
ismedianbin = 0;
tokmed = regexpi(expression, '[n]*b[in]*(\d+)\s*=\s*medianbin(.*)', 'tokens','ignorecase');

if ~isempty(tokmed)
        newb   = str2num(tokmed{1}{1});
        binop  = tokmed{1}{2};
        binop  = regexprep(binop,'[n]*b[in]*','','ignorecase');
        binop  = regexprep(binop,'\s+:\s+',':');
        binop  = regexprep(binop,'\(|\)','');
        bop    = str2num(binop);
        binpos = [newb bop];
        ismedianbin = 1;
        [CHANSP{1:length(binpos)}] = deal(1:ERPin.nchan);
end

%
% std of bins?
%
isstdbin = 0;
tokstd = regexpi(expression, '[n]*b[in]*(\d+)\s*=\s*stdbin(.*)', 'tokens','ignorecase');

if ~isempty(tokstd)
        newb   = str2num(tokstd{1}{1});
        binop  = tokstd{1}{2};
        binop  = regexprep(binop,'[n]*b[in]*','','ignorecase');
        binop  = regexprep(binop,'\s+:\s+',':');
        binop  = regexprep(binop,'\(|\)','');
        bop    = str2num(binop);
        binpos = [newb bop];
        isstdbin = 1;
        [CHANSP{1:length(binpos)}] = deal(1:ERPin.nchan);
end

%
% zscore of bins?
%
iszsbin = 0;
tokzsc = regexpi(expression, '[n]*b[in]*(\d+)\s*=\s*zscorebin(.*)', 'tokens','ignorecase');

if ~isempty(tokzsc)
        newb   = str2num(tokzsc{1}{1});
        binop  = tokzsc{1}{2};
        binop  = regexprep(binop,'[n]*b[in]*','','ignorecase');
        binop  = regexprep(binop,'\s+:\s+',':');
        binop  = regexprep(binop,'\(|\)','');
        bop    = str2num(binop);
        binpos = [newb bop];
        iszsbin = 1;
        [CHANSP{1:length(binpos)}] = deal(1:ERPin.nchan);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% looking for bin indexes
%
[mat, tok] = regexpi(expression, '[n]*b[in]*(\d+)([@]\w+)*', 'match', 'tokens','ignorecase');

if isempty(mat) && iswavebin== 0 &&  isavebin== 0 && isharmbin== 0 && ismedianbin== 0 && isstdbin== 0 && iszsbin== 0
        
        %
        %
        % Matlab expression (no bin definition)
        % The outcome will be sent to workspace
        %
        
        %
        % Matlab 7.3 and higher %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        [expspliter, formulasp] = regexp(strtrim(expression), '=','match','split');
        leftsize  =   formulasp{1};
        
        [mater, tok2]  = regexpi(leftsize, '(\w+)', 'match', 'tokens');
        
        if isempty(mater)
                msgboxText = 'ERPLAB says: error at binoperator(). Formula %s contains errors.';
                if errormsgtype
                        tittle = 'ERPLAB: binoperator() Error';
                        errorfound(sprintf(msgboxText, expression), tittle);
                        conti = 0; % No more bin processing...
                        cancelop = 1;
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText], expression)
                end
        end        
        
        %
        % Sends to workspace your channel definition
        %
        eval(expression)
        
        for j=1:length(mater)
                outvar = char(tok2{j});
                assignin('base', outvar, eval(outvar));
        end
        
        conti = 0;
        return
else
        if iswavebin==0  &&  isavebin== 0 && isharmbin== 0 && ismedianbin== 0 && isstdbin== 0 && iszsbin== 0
                ntok       = size(tok,2);
                binpos     = zeros(1,ntok);
                chspec     = {[]};
                lengthchan = zeros(1,ntok);
                CHANSP     = {[]};
                
                for tk=1:ntok
                        % contains index of  bins in the formula
                        binpos(tk) = str2double(tok{1,tk}{1,1});
                        
                        % contains chan spec per bin in the formula
                        chspec{tk} = char(tok{1,tk}{1,2});
                        chspec{tk} = regexprep(chspec{tk}, '@', ''); % ":" was replaced by "@"
                        
                        if tk>1
                                %
                                % Test right size
                                %
                                if strcmpi(chspec{tk},'')
                                        %
                                        % All channels per bin, by default
                                        %
                                        CHANSP{tk} = 1:ERPin.nchan;
                                else
                                        %
                                        % look for channels defined at workspace (usually for getting contra/ipsi waveforms)
                                        %
                                        CHANSP{tk} = evalin('base', chspec{tk}); % takes value from the workspace
                                end
                                lengthchan(tk) = length(CHANSP{tk});
                                [tf(tk), realbinpos(tk)]= ismember_bc2(binpos(tk), 1:ERPin.nbin);
                        else
                                %
                                % Test left size
                                %
                                [tf(1), realbinpos(1)]= ismember_bc2(binpos(1), 1:ERPout.nbin);
                        end
                end
                
                %
                % Test amount of defined channels (contra & ipsi bins, for instance)
                %
                [unilengthch, a, indexx] = unique_bc2(lengthchan(2:end), 'first');
                
                if ~isempty(indexx)
                        
                        loc = find(indexx>1, 1);
                        
                        if isempty(loc)
                                CHANSP{1} = 1:unilengthch;
                        else
                                msgboxText =  ['Number of channels is different! Please check bin(s): ' num2str(binpos(loc+1))];
                                tittle = 'ERPLAB: binoperator Error';
                                errorfound(msgboxText, tittle);
                                conti = 0; % No more bin processing...
                                return
                        end
                else
                        CHANSP{2} = []; % there is no bins on the right side...
                end
        else
                %
                % a special function is being used...
                %
                ntok = length(binpos);
                for tk=1:ntok
                        if tk>1
                                %
                                % Test right size
                                %
                                [tf(tk), realbinpos(tk)]= ismember_bc2(binpos(tk), 1:ERPin.nbin);
                        else
                                %
                                % Test left size
                                %
                                [tf(1), realbinpos(1)]= ismember_bc2(binpos(1), 1:ERPout.nbin);
                        end
                end
        end
        
        %
        % Check right side
        %
        nonexistingbinpos = find([realbinpos(2:end)]==0);
        
        if ~isempty(nonexistingbinpos)              
                msgboxText =  ['Error: Bin(s) [%s] does not exist!\n'...
                        'Only use bins from the list on the right'];
                if errormsgtype
                        tittle = 'ERPLAB: binoperator() Error';
                        errorfound(sprintf(msgboxText, num2str(binpos(nonexistingbinpos+1))), tittle);
                        conti = 0; % No more bin processing...
                        cancelop = 1;
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText], num2str(binpos(nonexistingbinpos+1)))
                end
        end
        
        %
        % Prepares new channel labels
        %
        nchansp = length(CHANSP{2});
        LABEL = {[]};
 %    
        for c=1:nchansp                
                labeltemp = {[]};
                labelsch  = {[]};
                
                for d=1:ntok-1
                        labelsch{c,d} = ERPin.chanlocs(CHANSP{d+1}(c)).labels;
                end
                
                %labeltemp = unique_bc2(labelsch(c,:))
                labeltemp = labelsch(c,:); % to allow pairing middle line channels: e.g. Cz/Cz
                
                if length(labeltemp)>1
                        deflabel = '';
                        
                        for m=1:length(labeltemp)
                                deflabel = [deflabel '/' labeltemp{1,m}]; % for contra ipsi
                        end
                        
                        match_expr = '(^\w)(\w*)(\w$)';
                        replace_expr1 = '$118$3';
                        deflabel = regexprep(deflabel, '^\/|\/$', '');
                else
                        deflabel = labeltemp{1,1};
                end
                LABEL{c} = deflabel;
        end
%
        
        % erase chan spec from expression
        expression = regexprep(expression, '[@]\w*', ''); %":" was replaced by "@"
        %this is "the whished bin" index,
        newbin     = binpos(1);
        
        %
        %  Test New Bin
        %
        lastslot = ERPout.nbin;
        
        if tf(1) && newbin>=1
                if ~eraser
                        %
                        % Gui memory
                        %
                        %wbmsgon = erpworkingmemory('wbmsgon');
                        %if isempty(wbmsgon)
                        %      wbmsgon = 1;
                        %      erpworkingmemory('wbmsgon',1);
                        %end
                        if wbmsgon==0
                                button = 'yes';
                        else
                                question = ['Bin ' num2str(newbin) ' already exist!\n'...
                                        'Would you like to overwrite?'];
                                tittle      = 'ERPLAB: binoperator, Overwriting Confirmation';
                                button      = askquest(sprintf(question), tittle, 'Yes');
                        end
                else
                        if wbmsgon==0
                                button = 'yes';
                        else
                                question = ['Bin ' num2str(newbin) ' will be erased!\n'...
                                        'Are you completely sure about this?'];
                                tittle = 'ERPLAB: binoperator, Bin Erasing Confirmation';
                                button =askquest(sprintf(question), tittle);
                        end
                        
                end
                if strcmpi(button,'no')
                        confirma = 0;
                        disp(['Bin ' num2str(newbin) ' was not modified'])
                        cancelop = 1;
                        return
                elseif strcmpi(button,'yes')
                        confirma = 1;
                        fprintf(['\nWARNING: Bin ' num2str(newbin) ' was overwriten.\n\n'])
                else
                        disp('User selected Cancel')
                        conti = 0; % No more bin processing...
                        cancelop = 1;
                        return
                end
                
        elseif (~tf(1) && newbin>=1 && newbin<=lastslot+1)
                confirma = 1;  % Everything is ok!
                realbinpos(1) = lastslot+1;
        else
                msgboxText =  ['Error: Bin %g is out of order!\n\n'...
                        '(i) "bin" equations must be define in ascending order.\n'...
                        '(ii) "nbin" equations must be define in ascending order, from 1 to the highest bin.'];
                if errormsgtype
                        tittle = 'ERPLAB: binoperator() Error';
                        errorfound(sprintf(msgboxText, newbin), tittle);
                        conti = 0; % No more bin processing...
                        cancelop = 1;
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText], newbin);
                end
        end
        if confirma
                try
                        newexp = regexprep(expression, '[n]*b[in]*(\d+)', 'bin(@$1)','ignorecase');                        
                        for p = 1:ntok
                                newexp = regexprep(newexp, '@\d+', [num2str(realbinpos(p)) ':' num2str(p)],'ignorecase','once');
                        end
                        if iswavebin % only for waveraged bins
                                ERPout.bindata(:,:,newbin) = wavgbin(ERPin, binpos(2:end));
                        elseif isavebin % only for averaged bins
                                ERPout.bindata(:,:,newbin) = avgbin(ERPin, binpos(2:end));
                        elseif isharmbin % only for harmonic mean bins
                                ERPout.bindata(:,:,newbin) = harmmeanbin(ERPin, binpos(2:end));
                        elseif ismedianbin % only for median bins
                                ERPout.bindata(:,:,newbin) = medianbin(ERPin, binpos(2:end));
                        elseif isstdbin % only for std bins
                                ERPout.bindata(:,:,newbin) = stdbin(ERPin, binpos(2:end));
                        elseif iszsbin % only for zscore bins
                                ERPout.bindata(:,:,newbin) = zscorebin(ERPin, binpos(2:end));
                        else % for regular operations
                                newexp = regexprep(newexp, '[n]*bin\((\d+):(\d+)\)', 'ERPin.bindata(CHANSP{$2},:,$1)','ignorecase');
                                newexp = regexprep(newexp, 'ERPin\.bindata\((.*)?\)\s*=', 'ERPout.bindata($1) = ','ignorecase');
                                eval([newexp ';']);
                        end
                        if ~eraser
                                if isempty(ERPout.bindata) || isempty(binpos(2:end))
                                        error('ERPLAB says: error at binoperator(). Unknown')
                                end
                                
                                ERPout.bindescr{realbinpos(1)}  = shortexp;
                                ERPout.ntrials.accepted(newbin) = sum(ERPin.ntrials.accepted(binpos(2:end)));
                                ERPout.ntrials.rejected(newbin) = sum(ERPin.ntrials.rejected(binpos(2:end)));
                                ERPout.ntrials.invalid(newbin)  = sum(ERPin.ntrials.invalid(binpos(2:end)));
                                ERPout.ntrials.arflags(newbin, :) = sum(ERPin.ntrials.arflags(binpos(2:end),:),1);                                
                                newnchan     = length(CHANSP{1}); % new bin's number of channels
                                ERPout.nchan = newnchan;
                                
                                %here is the problem with the contra-lateral channel...                                
                                if orinchan~=newnchan
                                        ERPout.chanlocs = [];
                                        for s=1:ERPout.nchan
                                            %s
                                            %LABEL{s}
                                                ERPout.chanlocs(s).labels = LABEL{s};
                                        end
                                else
                                    disp('aqui')
                                        ERPout.chanlocs = ERPin.chanlocs;
                                end
                                
                                %
                                % Standard error
                                %
                                if ~isempty(ERPin.binerror)
                                        ERPout.binerror(CHANSP{1},:,newbin) = zeros(newnchan,ERPin.pnts, 1);
                                end                                
                                disp(['Bin ' num2str(newbin) ' was  mounted'])
                        else
                                %
                                % This option is disabled, temporary...
                                %
                                ERPout.bindescr(realbinpos(1)) = [];
                                disp(['Bin ' num2str(newbin) ' was  erased'])
                        end
                        
                        ERPout.nbin = size(ERPout.bindata,3);
                        ERPout.saved = 'no';
                catch
                        serr = lasterror;
                        msgboxText = sprintf('Please, check your formula: \n\n%s\n%s',...
                                expression, serr.message);                      
                        if errormsgtype
                                tittle = 'ERPLAB: binoperator() Error';
                                errorfound(sprintf(msgboxText), tittle);
                                conti = 0; % No more bin processing...
                                cancelop = 1;
                                return
                        else
                                error('prog:input', ['ERPLAB says: ' msgboxText]);
                        end
                end
        end
end