% PURPOSE  : subroutine for pop_erpchanoperator.m
%            Creates and modifies a channel using any algebraic expression (MATLAB arithmetic operators) 
%
% FORMAT   :
%
% [ERPout conti] = erpchanoperator(ERPin, ERPout, expression)
%
% INPUTS   :
%
%   ERPin        - current ERPset
%   ERPout       - output ERPset
%   expression   - formula for creating/changing channel
%
%
% OUTPUTS
%
%   ERPout       - output ERPset
%   conti        - continue channel processing. 1 continue; 0 abort
%
%
% EXAMPLE  :
%
% ERP = erpchanoperator( ERPin, ERP, 'ch71=ch66-ch65 label HEOG' )
%
%
% See also pop_erpchanoperator.m chanoperGUI.m
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

function [ERPout conti] = erpchanoperator(ERPin, ERPout, expression, wchmsgon)
conti      = 1;
newlabel   = [];
if nargin<1
        help erpchanoperator
        return
end
if nargin<4
        wchmsgon =1;
end

%
% Delete chans?
%
[materase] = regexpi(expression, '[n]*ch[an]*\d+\s*=\s*\[\]', 'match');
tokdelchan = regexpi(expression, '\s*delerpchan\((.*)?\)', 'tokens','ignorecase');

if ~isempty(tokdelchan)
        chdelop    = tokdelchan{1}{1};
        chdelop    = regexprep(chdelop,'[n]*ch[an]*','','ignorecase');
        chdelop    = regexprep(chdelop,'\[|\]','','ignorecase');
        chdelop    = regexprep(chdelop,',',' ');
        rewroteop  = ['ERPout = delerpchan(ERPin, [' chdelop '])'];        
        eval([rewroteop ';'])
        return
end

%
% Reref chans?
%
tokreref = regexpi(expression, '\s*chreref\((.*)?\)', 'tokens','ignorecase');

if ~isempty(tokreref)
        chdelop   = tokreref{1}{1};        
        [sep1 u2] = regexp(strtrim(chdelop), ',','match','split');
        nu2 = length(u2);
        formref  =   u2{1};
        exclchan = [];
        
        for uu=1:length(u2)-1
              exclchan(uu) = str2num(u2{uu+1});
        end        
        if isempty(exclchan)
              rewroteop  = ['ERPout = chreref(ERPin, ''' formref ''')'];
        else
              exclchanstr = vect2colon(exclchan);
              rewroteop   = ['ERPout = chreref(ERPin, ''' formref ''','  exclchanstr ' )'];
        end        
        eval([rewroteop ';'])
        return
end
% add a dot for .*, ./ and .^ operations
expression = regexprep(expression, '([*/^])', '.$1','ignorecase');

%
% looking for label
%
[matlabel toklabel]  = regexpi(expression, '\s*label\s*\=*\s*(.*)', 'match', 'tokens');
if ~isempty(toklabel) && ~isempty(ERPin.chanlocs)
        newlabel  = toklabel{:}{1};
        
        %
        % erase label from expression
        %
        expression = strrep(expression, matlabel{:}, '');
        
elseif isempty(toklabel) && ~isempty(ERPin.chanlocs)
        newlabel   = 'no_label';
end

%
% Averaged chans?
%
tokavgchan = regexpi(expression, '\s*avgchan\(s*(.*?)s*\)', 'tokens','ignorecase'); % JLC 9/11/12

if ~isempty(tokavgchan)
        chavgop    = tokavgchan{1}{1};
        chavgop    = regexprep(chavgop,'[n]*ch[an]*','','ignorecase');
        chavgop    = regexprep(chavgop,',',' ');
        rewroteop  = ['avgchan(ERPin, [' chavgop '])'];
        expression = regexprep(expression,'\s*avgchan\(s*.*?s*\)', rewroteop, 'ignorecase'); %JLC. Sept 2012
end

%
% MGFP chans?
%
tokmgfpchan = regexpi(expression, '\s*mgfperp\((.*)?\)', 'tokens','ignorecase');

if ~isempty(tokmgfpchan)
        chmgfpop   = tokmgfpchan{1}{1};
        chmgfpop   = regexprep(chmgfpop,'[n]*ch[an]*','','ignorecase');
        chmgfpop   = regexprep(chmgfpop,',',' ');
        rewroteop  = ['mgfperp(ERPin, [' chmgfpop '])'];
        expression = regexprep(expression,'mgfperp(.*)', rewroteop, 'ignorecase');
end
if isempty(materase)
        
        % looking for ":"
        matint = regexpi(expression, ':ch[an]*', 'match');
        
        if ~isempty(matint)
                error('ERPLAB says: errot at erpchanoperator(). Interval of channels are allowed only for deleting process. Example, ch23:ch30=[]')
        end
        
        %
        % looking for the channel indices
        %
        [mat tok] = regexpi(expression, '[n]*ch[an]*(\d+)', 'match', 'tokens');
        
        if isempty(mat) %&& isavgchan == 0
                
                %
                % ONLY for variable setting (no chans)  ---> send to workspace
                %
                
                %
                % Matlab 7.3 and higher %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                [expspliter formulasp] = regexp(strtrim(expression), '=','match','split');
                leftsize  =   formulasp{1};
                
                [mater tok2]  = regexpi(leftsize, '(\w+)', 'match', 'tokens');
                
                if isempty(mater)
                        error(['ERPLAB says: errot at erpchanoperator(). Formula ' expression ' contains errors.'])
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
                msgboxText= 'Channel indices were not found.';
                title = 'ERPLAB: erpchanoperator() error:';
                errorfound(msgboxText, title);
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
                        [tf(tk), realchanpos(tk)] = ismember_bc2(chanpos(tk), 1:ERPin.nchan);
                else
                        [tf(1), realchanpos(1)] = ismember_bc2(chanpos(1), 1:ERPout.nchan);
                end
        end
        
        %
        % Check right side
        %
        nonexistingchanpos = find([realchanpos(2:end)]==0);
        
        if ~isempty(nonexistingchanpos)
                msgboxText =  ['Error: Channel(s) [%s] does not exist!\n'...
                               'Only use channels from the list on the right'];
                title = 'ERPLAB: erpchanoperator() error:';
                errorfound(sprintf(msgboxText, num2str(chanpos(nonexistingchanpos+1))), title);
                conti = 0; % No more bin processing...
                return
        end        
        if length(realchanpos(2:end))==1 && strcmp(newlabel, 'no_label')
                newlabel = ERPin.chanlocs(realchanpos(2)).labels;
        end
        
        newchan = chanpos(1);  %this is the formula's left side channel index.
        eraser  = 0;        
else
        %
        % Test nchan sintax (for erasing!?)
        %
        [nchanerase] = regexpi(expression, 'nch[an]*', 'match');
        
        if ~isempty(nchanerase)
                msgboxText=  'You cannot delete a channel using "nchan" sintax';
                title = 'ERPLAB: erpchanoperator() error:';
                errorfound(msgboxText, title);
                conti = 0;
                return
        end
        
        msgboxText=  'For channel deleting, use delerpchan() instead.';
        title = 'ERPLAB: erpchanoperator() error:';
        errorfound(msgboxText, title);
        conti = 0;
        return
end

%
%  Test New Channel
%
lastslot = ERPout.nchan;

if isempty(lastslot)
        lastslot= 0;
end
if tf(1) && newchan(1)>=1        
        if ~eraser
                
                %
                % Gui memory
                %
                %wchmsgon = erpworkingmemory('wchmsgon');
                
                %if isempty(wchmsgon)
                %        wchmsgon = 1;
                %        erpworkingmemory('wchmsgon',1);
                %end                
                if wchmsgon==0
                        button = 'yes';
                else
                        question = ['Channel %g already exist!\n\n'...
                                   'Would you like to overwrite it?'];
                        title    = 'ERPLAB: Overwriting Channel Confirmation';
                        button   = askquest(sprintf(question, newchan), title);
                end                
                if strcmpi(newlabel,'no_label')
                        newlabel = ERPin.chanlocs(newchan).labels; % keep the original label. Bug fixed. Thanks Pia Amping!
                end                
        else
                question = ['Channel %g will be erased!\n\n'...
                            'Are you completely sure about this?'];
                title    = 'ERPLAB: Channel Erasing Confirmation';
                button   = askquest(sprintf(question, newchan), title);
        end
        if strcmpi(button,'no')
                confirma = 0;
                conti    = 0;
                disp(['Channel ' num2str(newchan) ' was not modified'])
                
        elseif strcmpi(button,'yes')
                confirma = 1;
                fprintf(['\nWARNING: Channel ' num2str(newchan) ' was overwritten.\n\n'])
        else
                disp('User selected Cancel')
                conti = 0;
                return
        end        
elseif (~tf(1) && newchan(1)>=1 && newchan(1) <= lastslot+1)        
        confirma = 1;  % Everything is ok!
        realchanpos(1) = lastslot+1;
else
        msgboxText =  ['Channel %g is out of order!\n\n'...
                       '"chan" equations must be define in ascending order.\n'...
                       '"nchan" equations must be define in ascending order, from 1 to the highest channel.'];
        title = 'ERPLAB: erpchanoperator:';
        errorfound(sprintf(msgboxText, newchan), title);
        conti = 0; % No more bin processing...
        return
end
if confirma        
        try
                newexp = regexprep(expression, '[n]*ch[an]*(\d+)', 'chan(@$1)','ignorecase');
                
                for p = 1:nindices
                        newexp = regexprep(newexp, '@\d+', num2str(realchanpos(p)),'ignorecase','once');
                end                
                if ~eraser                        
                        nbin = ERPin.nbin;                        
                        newexp = regexprep(newexp, '[n]*chan\((\d+)\)', 'ERPin.bindata($1,:, 1:nbin)','ignorecase');
                        newexp = regexprep(newexp, 'ERPin\.bindata\((.*)?\)\s*=', 'ERPout.bindata($1) = ','ignorecase');
                        
                        %
                        % Evaluate final expression
                        %
                        eval([newexp ';']);
                        
                        %
                        % New Label
                        %
                        if ~isempty(newlabel)
                                ERPout.chanlocs(realchanpos(1)).labels = newlabel;
                        end
                        if ~isempty(ERPin.binerror)
                            % Bug fixed. Johanna. Sept 11, 2014
                            try
                                ERPout.binerror(newchan,:,:)= zeros(1,ERPin.pnts, nbin);
                            catch
                                ERPout.binerror = [];
                            end
                        end

                        ERPout.nchan = size(ERPout.bindata, 1);
                        disp(['Channel ' num2str(newchan) ' was  created'])
                else
                        ERPout.bindata(newchan,:,:) = [];
                        ERPout.binerror(newchan,:,:)= [];
                        ERPout.nchan = size(ERPout.bindata, 1);
                        labaux = {ERPin.chanlocs.labels};
                        labaux{newchan}=[];
                        indxl = ~cellfun(@isempty, labaux);
                        labelout = labaux(indxl);
                        [ERPout.chanlocs(1:ERPout.nchan).labels] = labelout{:};
                        disp(['Channel ' num2str(newchan) ' was  erased'])
                end
        catch                
                serr = lasterror;
                msgboxText =  ['Please, check your formula:\n'...
                  expression '\n' serr.message];
                title = 'ERPLAB: erpchanoperator() error:';
                errorfound(sprintf(msgboxText), title);
                conti = 0;
                return
        end
end
