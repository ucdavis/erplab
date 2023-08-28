% PURPOSE: add white/pink/line noise to EEG/ERP data with specific
% channels. Different types of noise are also allowed to add simultaneously.
%
% FORMAT:
%
% [ERPOUT cherror] = chaddnoise(EEGin,EEGout,formula,errormsgtype,warningme)
% However syntax is chaddnoise(formula) in eegchanoperator.
%
% INPUT:
%
% EEGin           - input dataset
% EEGout          - output dataset (for recursiveness...)
% formula         - algebraic expression for the (virtual) reference channel
% warningme       - display warnings. 1 yes; 0 no
% errormsgtype    - 1-use popup on error messages, 0-error in red at
%                   command window
%
%
% OUTPUT
%
% ERPout          - re-referenced dataset or erpset
% cherror         - error checking. 0 means no error; 1 means error found
%
%

% EXAMPLE  :
%
% 1. [EEGout cherror] = chaddnoise(EEGin,EEGout,'nch1 = ch1 + 2*whitenoise(1)'); for whitenoise
% 2. [EEGout cherror] = chaddnoise(EEGin,EEGout,'nch1 = ch1 + 2*pinknoise(1)'); for pinknoise

% 3. [EEGout cherror] = chaddnoise(EEGin,EEGout,"nch1 = ch1 + 2*linenoise(10,'fixed',60)");
%    Setting for linenoise, 10 is used to generage 10Hz signal; 60 is phase shifting that will be fixed across trials or bins.

%    Using 'random' instead of 'fixed' if you want to set phase shifting across trials/bins
%    [EEGout cherror] = chaddnoise(EEGin,EEGout,"nch1 = ch1 + 2*linenoise(10,'random',1)"); Note that 1 is the seed that is used to generate phase randomly
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang and Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Apr 2023

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

function  [EEGout cherror] = chaddnoise(EEGin,EEGout,formula,errormsgtype,warningme)
cherror = 0;

if nargin<3
    help chaddnoise;
    return;
end
if nargin<4
    errormsgtype =1;
    warningme=0;
end

if nargin<5
    warningme=0;
end

if ~iserpstruct(EEGin) && ~iseegstruct(EEGin)
    error('EEGin says: chaddnoise() only works with ERP and EEG structure.')
end
if iseegstruct(EEGin)  % EEG
    ntrial    = EEGin.trials;
    nchan     = EEGin.nbchan;
    datafield = 'data';
    EEGinaux = [];
    ntrial    = EEGin.trials;
else  % ERP
    ntrial    = EEGin.nbin;
    nchan     = EEGin.nchan;
    datafield = 'bindata';
    EEGinaux = buildERPstruct([]);
    ntrial = EEGin.nbin;
end
% add a dot for .*, ./ and .^ operations
expression = regexprep(formula, '([*/^])', '','ignorecase');%%remove * or ^
formula = regexprep(formula, '([*/^])', '','ignorecase');%%remove * or ^
% looking for eraser command
[materase] = regexpi(expression, '[n]*ch[an]*\d+\s*=\s*\[\]', 'match');

%
% looking for label
%
% EEGin = EEGin;
[matlabel, toklabel]    = regexpi(expression, '\s*label\s*\=*\s*(.*)', 'match', 'tokens');
if ~isempty(toklabel) && ~isempty(EEGin.chanlocs)
    newlabel   = toklabel{:}{1};
    
    %
    % erase label from expression
    %
    expression = strrep(expression, matlabel{:}, '');
elseif isempty(toklabel) && ~isempty(EEGin.chanlocs)
    newlabel   = 'no_label';
end


%
% Add noise (line,pink, and white)?
%
toklinenoise = regexpi(expression, 'linenoise', 'match','ignorecase');
tokwhitenoise = regexpi(expression, 'whitenoise', 'match','ignorecase');
tokpinknoise = regexpi(expression, 'pinknoise', 'match','ignorecase');

NoiseFlagline = [];
NoiseFlagwhite = [];
NoiseFlagpink = [];
if ~isempty(toklinenoise)
    NoiseFlagline = 1;
end
if ~isempty(tokwhitenoise)
    NoiseFlagwhite = 1;
end
if  ~isempty(tokpinknoise)
    NoiseFlagpink = 1;
end

if isempty(NoiseFlagline)  &&  isempty(NoiseFlagwhite) && isempty(NoiseFlagpink)
    msgboxText= '\n Please define any one of linenoise, whitenoise, or pinknoise.\n';
    title = 'ERPLAB: chaddnoise() error:';
    %errorfound(msgboxText, title);
    if errormsgtype == 1
        errorfound(sprintf(msgboxText), title);
    else
        cprintf('red',msgboxText);
    end
    return;
end


if isempty(toklinenoise) && isempty(tokwhitenoise) && isempty(tokpinknoise)
    ischaddnoise = 1;
else
    ischaddnoise = 0;
end
if isempty(materase)
    
    % looking for ":"
    matint = regexpi(expression, ':ch[an]*', 'match');
    
    if ~isempty(matint)
        error('ERPLAB says: errot at chaddnoise(). Interval of channels is not allowed for deleting process.')
    end
    
    %
    % looking for channel indices
    %
    [mat tok] = regexpi(expression, '[n]*ch[an]*(\d+)', 'match', 'tokens');
    
    if isempty(mat) %&& isavgchan == 0
        
        %
        % ONLY for variable setting (no chans)  ---> send to workspace
        %
        
        %
        % Matlab 7.3 and higher %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        [expspliter, formulasp] = regexp(strtrim(expression), '=','match','split');
        leftsize  =   formulasp{1};
        
        [mater, tok2]  = regexpi(leftsize, '(\w+)', 'match', 'tokens');
        
        if isempty(mater)
            error(['ERPLAB says: errot at chaddnoise(). Formula ' expression ' contains errors.'])
        end
        
        %
        % Sends to workspace your channel definition
        %
        eval(expression)
        
        for j=1:length(mater)
            outvar = char(tok2{j});
            assignin('base', outvar, eval(outvar));
        end
        conti = 1;
        return
    end
    
    nindices  = size(tok,2);
    
    if nindices==0
        msgboxText= '\nChannel indices were not found.\n';
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(msgboxText, title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
    
    chanpos     = zeros(1,nindices);
    realchanpos = chanpos;
    tf = zeros(1,nindices);
    
    for tk=1:nindices
        
        %
        % indices of channels at the formula
        %
        chanpos(tk) = str2num(tok{1,tk}{1,1});
        
        if tk>1
            if iseegstruct(EEGin)
                [tf(tk), realchanpos(tk)] = ismember_bc2(chanpos(tk), 1:EEGin.nbchan);
            else
                [tf(tk), realchanpos(tk)] = ismember_bc2(chanpos(tk), 1:EEGin.nchan);
            end
        else
            if iseegstruct(EEGout)
                [tf(1), realchanpos(1)] = ismember_bc2(chanpos(1), 1:EEGout.nbchan);
            else
                [tf(1), realchanpos(1)] = ismember_bc2(chanpos(1), 1:EEGout.nchan);
            end
        end
    end
    
    %
    % Check right side
    %
    nonexistingchanpos = find([realchanpos(2:end)]==0);
    
    if ~isempty(nonexistingchanpos)
        msgboxText =  ['\nChannel(s) [%s] does not exist!\n'...
            'Only use channels from the list on the right \n'];
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(sprintf(msgboxText, num2str(chanpos(nonexistingchanpos+1))), title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText, num2str(chanpos(nonexistingchanpos+1))), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0; % No more bin processing...
        return
    end
    
    %
    % Keep label (temporary solution...)
    %
    if length(realchanpos(2:end))==1 && strcmp(newlabel, 'no_label')
        newlabel = EEGin.chanlocs(realchanpos(2)).labels;
    end
    
    newchan = chanpos(1);  %this is the formula's left side channel index.
    eraser  = 0;
    
    
else
    %
    % Test nchan sintax (for erasing!?)
    %
    [nchanerase] = regexpi(expression, 'nch[an]*', 'match');
    
    if ~isempty(nchanerase)
        msgboxText=  '\nYou cannot delete a channel using "nchan" sintax\n';
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(msgboxText, title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
    if ischaddnoise % (?)
        msgboxText =  '\nSorry. Adding noise is not yet available for this mode.\n';
        title = 'ERPLAB: chaddnoise() error:';
        %errorfound(msgboxText, title);
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
    
    %
    % look for channel index(ices)
    %
    [mat, tok] = regexpi(expression, 'ch[an]*(\d+)', 'match', 'tokens'); % looking for channel index
    nindices = size(tok,2);
    
    if nindices>2 || nindices<=1
        error('ERPLAB says: errot at chaddnoise(). Two elements of channel index are only included in the Eq. E.g, ch1 = ch1 + whitenoise(1) label FP1');
        
    end
    
    chanpos = zeros(1,nindices);
    
    for tk=1:nindices
        chanpos(tk) = str2double(tok{1,tk}{1,1});  % conteins index of channels in the formula
        [tf, realchanpos(tk)] = ismember_bc2(chanpos(tk), 1:EEGin.nbchan); %#ok<AGROW>
        
        if ~tf(tk)
            msgboxText=  ['\nChannel ' num2str(chanpos(tk)) ' does not  exist yet! \n'];
            title = 'ERPLAB: chaddnoise() error:';
            %errorfound(msgboxText, title)
            if errormsgtype == 1
                errorfound(sprintf(msgboxText), title);
            else
                cprintf('red',msgboxText);
            end
            conti = 0;
            return
        end
    end
    if tk>1
        newchan = chanpos(1):chanpos(2);
    else
        newchan = chanpos(1);
    end
    
    eraser = 1;
end

if isempty(realchanpos) || numel(realchanpos)~=2
    msgboxText = ['ERPLAB says:   Please check your formula:',expression,'.\n\n', ...
        'Two elements of channel index are only included,E.g, ch1 = ch1 + whitenoise(1) label FP1'];
    %      msgboxText =  ['\nPlease, check your formula: \n\n'...
    %             expression '\n' serr.message '\n'];
    title = 'ERPLAB: chaddnoise() error:';
    %errorfound(msgboxText, title)
    if errormsgtype == 1
        errorfound(sprintf(msgboxText), title);
    else
        cprintf('red',msgboxText);
    end
    conti = 0;
    return
end
%
%  Test New Channel
%
if iseegstruct(EEGout)
    lastslot = EEGout.nbchan;
else
    lastslot = EEGout.nchan;
end

if isempty(lastslot)
    lastslot= 0;
end
if tf(1) && newchan(1)>=1
    if ~eraser
        
        % %             %
        % %             % Gui memory
        % %             %
        % %             wchmsgon = erpworkingmemory('wchmsgon');
        % %
        % %             if isempty(wchmsgon)
        % %                   wchmsgon = 1;
        % %                   erpworkingmemory('wchmsgon',1);
        % %             end
        
        % %             if wchmsgon==0
        % %                   button = 'yes';
        % %             else
        % %                   question = ['Channel %s already exist!\n\n'...
        % %                               'Would you like to overwrite it?'];
        % %                   title    = 'ERPLAB: Overwriting Channel Confirmation';
        % %                   button   = askquest(sprintf(question, num2str(newchan)), title);
        % %             end
        
        if warningme==0
            button = 'yes';
        else
            question = ['Channel %s already exist!\n\n'...
                'Would you like to overwrite it?'];
            title    = 'ERPLAB: Overwriting Channel Confirmation';
            button   = askquest(sprintf(question, num2str(newchan)), title);
        end
        
        if strcmpi(newlabel,'no_label')
            newlabel = EEGin.chanlocs(newchan).labels; % keep the original label
        end
    else
        question = ['Channel %s will be erased!\n\n'...
            'Are you completely sure about this?'];
        title    = 'ERPLAB: Channel Erasing Confirmation';
        button   = askquest(sprintf(question, num2str(newchan)), title);
    end
    if strcmpi(button,'no')
        confirma = 0;
        conti = 0;
        disp(['Channel ' num2str(newchan) ' was not modified'])
    elseif strcmpi(button,'yes')
        confirma = 1;
        %fprintf(['\nWARNING: Channel ' num2str(newchan) ' was overwritten.\n\n'])
    else
        disp('User selected Cancel')
        conti = 0;
        return
    end
elseif (~tf(1) && newchan(1)>=1 && newchan(1) <= lastslot+1)
    confirma = 1;  % Everything is ok!
    realchanpos(1) = lastslot+1;
else
    msgboxText =  ['\nError: Channel ' num2str(newchan) ' is out of order!\n\n'...
        '"chan#" equations must be define in ascending order.\n\n'...
        '"nchan#" equations must be define in ascending order, from 1 to the highest channel. \n'];
    title = 'ERPLAB: chaddnoise:';
    %errorfound(sprintf(msgboxText), title);
    if errormsgtype == 1
        errorfound(sprintf(msgboxText), title);
    else
        cprintf('red',msgboxText);
    end
    conti = 0; % No more bin processing...
    return
end
if confirma
    try
        trialNum = ntrial;%EEGin.trials;
        sampleNum = EEGin.pnts;
        formula = regexprep(formula, '([\s])', '','ignorecase');
        %%-----------------------------------------------------------------
        %%---------------------------------white noise---------------------
        %%-----------------------------------------------------------------
        if ~isempty(NoiseFlagwhite)
            
            %             [mattypewhite toktypewhite] = regexpi(formula, '\s*[+-]?[\d+]*(whitenoise)', 'match','tokens');
            [mattypewhite toktypewhite] = regexpi(formula, '\s*[+-][\d+]?[\.?\d+]*(whitenoise)', 'match','tokens');%%Fixed GH, Jun 2023
            if isempty(mattypewhite) && isempty(toktypewhite)
                [mattypewhite toktypewhite] = regexpi(formula, '\s*[+-]?[\d+]*(whitenoise)', 'match','tokens');
            end
            if isempty(mattypewhite) || isempty(toktypewhite)
                msgboxText =  ['\nPlease, check your formula: \n\n'...
                    char(formula) '\n'];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                conti = 0;
                return
            end
            %Get the amplitude for noise signal
            AmpNoisewhite = str2num(regexprep(char(mattypewhite{1,1}), char(toktypewhite{1,1}), '','ignorecase'));
            if isempty(AmpNoisewhite)
                if strcmpi(regexprep(char(mattypewhite{1,1}), char(toktypewhite{1,1}), '','ignorecase'),'-')
                    AmpNoisewhite = -1;
                else
                    AmpNoisewhite = 1;
                end
            end
            WhiteNoiseedstr = regexpi(formula, ['\s*',char(toktypewhite{1,1}),'\((\d)?\)'], 'tokens','ignorecase');
            
            if isempty(WhiteNoiseedstr)
                Noiseedwhite = [];
            else
                Noiseedwhite = str2num(char(WhiteNoiseedstr{1,1}{1,1}));
            end
            if ~isempty(Noiseedwhite)
                if Noiseedwhite>=0
                    try
                        rng(Noiseedwhite,'twister');
                    catch
                        rng(0,'twister');
                    end
                end
            end
            Desiredwhitenoise =  randn(sampleNum,trialNum);%%white noise
            Desiredwhitenoise = reshape(Desiredwhitenoise,sampleNum*trialNum,1);
            if trialNum==1%%one trial
                Desiredwhitenoise = AmpNoisewhite*Desiredwhitenoise;
                Desiredwhitenoise = reshape(Desiredwhitenoise,sampleNum,trialNum);
                if trialNum==1
                    Desiredwhitenoise = reshape(Desiredwhitenoise,1,sampleNum);
                end
                EEGout.(datafield)(realchanpos(1),:,1:trialNum) = squeeze(EEGin.(datafield)(realchanpos(2),:,1:trialNum))+Desiredwhitenoise;
            else%%multiple trials or bins
                Desiredwhitenoise = reshape(Desiredwhitenoise,sampleNum,trialNum);
                for Numoftrial = 1:trialNum
                    Noisinglewhite = Desiredwhitenoise(:,Numoftrial);
                    
                    Noisinglewhite = AmpNoisewhite*Noisinglewhite;
                    Noisinglewhite = reshape(Noisinglewhite,1,sampleNum);
                    EEGout.(datafield)(realchanpos(1),:,Numoftrial) = squeeze(EEGin.(datafield)(realchanpos(2),:,Numoftrial))+Noisinglewhite;
                end
            end
        end
        
        
        
        %%-----------------------------------------------------------------
        %%---------------------------------pink noise----------------------
        %%-----------------------------------------------------------------
        if ~isempty(NoiseFlagpink)
            %             [mattypepink toktypepink] = regexpi(formula, '\s*[+-]?[\d+]*(pinknoise)', 'match','tokens');
            [mattypepink toktypepink] = regexpi(formula, '\s*[+-][\d+]?[\.?\d+]*(pinknoise)', 'match','tokens');%%Fixed GH, Jun 2023
            if isempty(mattypepink) && isempty(toktypepink)
                [mattypepink toktypepink] = regexpi(formula, '\s*[+-]?[\d+]*(pinknoise)', 'match','tokens');
            end
            if isempty(mattypepink) || isempty(toktypepink)
                msgboxText =  ['\nPlease, check your formula: \n\n'...
                    char(formula) '\n'];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                conti = 0;
                return
            end
            %Get the amplitude for noise signal
            AmpNoisepink = str2num(regexprep(char(mattypepink{1,1}), char(toktypepink{1,1}), '','ignorecase'));
            if isempty(AmpNoisepink)
                if strcmpi(regexprep(char(mattypepink{1,1}), char(toktypepink{1,1}), '','ignorecase'),'-')
                    AmpNoisepink = -1;
                else
                    AmpNoisepink = 1;
                end
            end
            PinkNoiseedstr = regexpi(formula, ['\s*',char(toktypepink{1,1}),'\((\d+)?\)'], 'tokens','ignorecase');
            
            if isempty(PinkNoiseedstr)
                Noiseedpink = [];
            else
                Noiseedpink = str2num(char(PinkNoiseedstr{1,1}{1,1}));
            end
            if ~isempty(Noiseedpink)
                if Noiseedpink>=0%% use the default generator to get noise
                    try
                        rng(Noiseedpink,'twister');
                    catch
                        rng(0,'twister');
                    end
                end
            end
            Desiredpinknoise = f_pinknoise(sampleNum*trialNum);
            Desiredpinknoise = reshape(Desiredpinknoise,sampleNum*trialNum,1);
            if trialNum==1%%one trial
                
                Desiredpinknoise = AmpNoisepink*Desiredpinknoise;
                Desiredpinknoise = reshape(Desiredpinknoise,sampleNum,trialNum);
                if trialNum==1
                    Desiredpinknoise = reshape(Desiredpinknoise,1,sampleNum);
                end
                EEGout.(datafield)(realchanpos(1),:,1:trialNum) = squeeze(EEGin.(datafield)(realchanpos(2),:,1:trialNum))+Desiredpinknoise;
            else%%multiple trials or bins
                Desiredpinknoise = reshape(Desiredpinknoise,sampleNum,trialNum);
                for Numoftrial = 1:trialNum
                    Noisinglepink = Desiredpinknoise(:,Numoftrial);
                    Noisinglepink = AmpNoisepink*Noisinglepink;
                    Noisinglepink = reshape(Noisinglepink,1,sampleNum);
                    EEGout.(datafield)(realchanpos(1),:,Numoftrial) = squeeze(EEGin.(datafield)(realchanpos(2),:,Numoftrial))+Noisinglepink;
                end
            end
        end
        
        
        %%-----------------------------------------------------------------
        %%---------------------------------line noise----------------------
        %%-----------------------------------------------------------------
        if ~isempty(NoiseFlagline)%%line noise
            
            splitStr = regexp(formula,'\=|+|-','split');
            for ii = 1:length(splitStr)
                toklinenoise = regexpi(splitStr{ii}, 'linenoise', 'match','ignorecase');
                if ~isempty(toklinenoise)
                    formulaNew = splitStr{ii};
                    break;
                end
            end
            try
                PoStr = strfind(formula,formulaNew);
                if ~isempty(PoStr)
                    if strcmpi(formula(PoStr-1),'-')
                        formula=  ['-',formulaNew ];
                    end
                end
            catch
                formula= formulaNew;
            end
            
            %             [mattypeline toktypeline] = regexpi(formula, '\s*[+-]?[\d+]*(linenoise)', 'match','tokens');
            
            [mattypeline toktypeline] = regexpi(formula, '\s*[+-][\d+]?[\.?\d+]*(linenoise)', 'match','tokens');%%fixed  by GH Jun 2023
            if isempty(mattypeline) && isempty(toktypeline)
                [mattypeline toktypeline] = regexpi(formula, '\s*[+-]?[\d+]*(linenoise)', 'match','tokens');
            end
            if isempty(mattypeline) || isempty(toktypeline)
                msgboxText =  ['\nPlease, check your formula: \n\n'...
                    char(formula) '\n'];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                conti = 0;
                return
            end
            %Get the amplitude for noise signal
            AmpNoise = str2num(regexprep(char(mattypeline{1,1}), char(toktypeline{1,1}), '','ignorecase'));
            if isempty(AmpNoise)
                if strcmpi(regexprep(char(mattypeline{1,1}), char(toktypeline{1,1}), '','ignorecase'),'-')
                    AmpNoise = -1;
                else
                    AmpNoise = 1;
                end
            end
            
            Periodconstr = regexpi(formula, ['\s*','linenoise','\((.*)?\)'], 'tokens','ignorecase');
            if isempty(Periodconstr)
                msgboxText =  ["\nPlease check Formula for line noise, the correct one likes, e.g., ch1 = ch1 + 2*linenoise(60,'fixed',90) label  FP1;"];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                return;
            end
            
            PeriodPhase = regexpi(Periodconstr{1,1}, '[\d.]+', 'match');%%get period and phaseshifting/seed
            
            if isempty(PeriodPhase)
                msgboxText =  ["\nPlease check Formula for line noise, the correct one likes, e.g., ch1 = ch1 + 2*linenoise(60,'fixed',90) label  FP1;"];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                return;
            end
            try
                PeriodValue = str2num(char(PeriodPhase{1,1}{1}));%% period
            catch
                PeriodValue = [];
            end
            
            if isempty(PeriodValue)
                msgboxText =  ["\nPlease check Formula for line noise, the correct one likes, e.g., ch1 = ch1 + 2*linenoise(60,'fixed',90) label  FP1;"];
                title = 'ERPLAB: chaddnoise() error:';
                if errormsgtype == 1
                    errorfound(sprintf(msgboxText), title);
                else
                    cprintf('red',msgboxText);
                end
                return;
            end
            
            [GenType,toktype] = regexpi(formula, '(fixed|random)', 'match','tokens');
            if isempty(GenType)
                isGenType  = 2;
            else
                if strcmpi(char(GenType),'fixed')
                    isGenType =1;%% fixed phase shifting
                else
                    isGenType  = 2;%% seed for generating phase randomly
                end
            end
            if isGenType==1
                try
                    PhaseShit = str2num(char(PeriodPhase{1,1}{2}));%%phase shifting
                catch
                    PhaseShit = 0;
                end
            else
                try
                    PhaseShit = str2num(char(PeriodPhase{1,1}{2}));%%phase shifting
                catch
                    PhaseShit =[];
                end
            end
            timeStart = EEGin.xmin;
            timeEnd = EEGin.xmax;
            
            Times = [timeStart:1/EEGin.srate:timeEnd];
            Desirednoise =[];
            if isGenType==1 %% fixed phase shifting mode
                PhaseShit = deg2rad(PhaseShit);%%Convert angles from degrees to radians.
                for Numoftrial = 1:trialNum
                    Desirednoise(:,Numoftrial) =  AmpNoise*sin(2*PeriodValue*pi*Times+PhaseShit);
                end
            else
                if ~isempty(PhaseShit)%% define one seed for "random" mode
                    PhaseShit = ceil(PhaseShit);
                    if PhaseShit<0
                        PhaseShit = 0;
                    end
                    try
                        rng(PhaseShit,'twister');
                    catch
                        rng(0,'twister');
                    end
                end
                Phasemtrial = rand(1,trialNum)*2*pi;
                for Numoftrial = 1:trialNum
                    Desirednoise(:,Numoftrial) =  AmpNoise*sin(2*PeriodValue*pi*Times+Phasemtrial(Numoftrial));
                end
                
            end
            if trialNum==1
                Desirednoise = reshape(Desirednoise,1,sampleNum);
            end
            EEGout.(datafield)(realchanpos(1),:,1:trialNum) = squeeze(EEGin.(datafield)(realchanpos(2),:,1:trialNum))+Desirednoise;
        end
        
        
        %
        % New Label
        %
        if ~isempty(newlabel)
            EEGout.chanlocs(realchanpos(1)).labels = newlabel;
        end
        if iseegstruct(EEGout)
            EEGout.nbchan = size(EEGout.data, 1);
            EEGout = eeg_checkset( EEGout );
            disp(['Channel ' num2str(newchan) ' was  created'])
            EEGout = update_rejEfields(EEGin,EEGout,realchanpos);  % update reject fields
        else
            EEGout.nchan = size(EEGout.bindata, 1);
            disp(['Channel ' num2str(newchan) ' was  created'])
        end
        
        if eraser && ~iseegstruct(EEGout)
            EEGout.bindata(newchan,:,:) = [];
            EEGout.binerror(newchan,:,:)= [];
            EEGout.nchan = size(EEGout.bindata, 1);
            labaux = {EEGin.chanlocs.labels};
            labaux{newchan}=[];
            indxl = ~cellfun(@isempty, labaux);
            labelout = labaux(indxl);
            [EEGout.chanlocs(1:EEGout.nchan).labels] = labelout{:};
            disp(['Channel ' num2str(newchan) ' was  erased'])
        end
        
    catch
        serr = lasterror;
        msgboxText =  ['\nPlease, check your formula: \n\n'...
            expression '\n' serr.message '\n'];
        title = 'ERPLAB: chaddnoise() error:';
        
        if errormsgtype == 1
            errorfound(sprintf(msgboxText), title);
        else
            cprintf('red',msgboxText);
        end
        conti = 0;
        return
    end
end