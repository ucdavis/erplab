%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
%
% Bin Operations:
%
% The ‘Bin Operations’ function allows you to compute new bins that are linear
% combinations of the bins in the current ERP structure.  For example, you can
% average multiple bins together, and you can compute difference waves.  It operates in the same manner as Channel Operations.  That is, you create equations that look like this: “bin6 = 0.5*bin3 – 0.5*bin2”.  This is like a simplified version of the erpmanip program in ERPSS.  We will eventually create a more sophisticated version that has the same power as erpmanip.
%
% Your bins are stored in a Matlab structure named ERP, at bindata field
% (ERP.binvg). This field has 3 dimensions:
%
%    row        =   channels
%    column     =   points (signal)
%    depth      =   bin's slot (bin index).
%
% So, the depth dimension will increase as you define a new bin, correctly
% numbered (sorted).   To create a new bin you have simply to use an algebraic expression for that bin.
%
% Example (GUI):
%
% Currently you have 4 bins created, and now you need to create a new bin
% (bin 5) with the difference between bin 2 and 4. So, you should go to Bin
% Operation, at the ERPLAB menu, and this will pop up a new GUI. At the editing window enter the next simple expression:
%
% bin5 = bin2 - bin4  label Something Important
%
% and press RUN.
%
% Note1: You can also write in a short style expression: b5 = b2 - b4.
%
% For label setting you could use : ...label Something Important  or
% ....label = Something Important
%
% If you do not define a label, binoperator will use a short expression of
% the current formula as a label,  BIN5: B2-B4
%
% In case you need to create more than one new bin, you will need to enter
% a carriage return at the end of each expression (formula) as you are writing
% a list of algebraic expressions.
%
% Example (GUI):
%
% b5 = b2 - b4   label bla-bla
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
% it more than one time. Use EXPORT & IMPORT buttons for this,
% respectively.
%
% Example for a command line
%
% >> pop_binoperator( ERP, {  'b38 = b7-b8 label hot 5'  }, 0);
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

function [ERP erpcom] = pop_binoperator(ERP, formulas)

erpcom = '';

if nargin < 1
        help(sprintf('%s', mfilename))
        return
end
if nargin >2
        error('ERPLAB says:  Error, too many inputs')
end
if isempty(ERP)
        msgboxText{1} =  'pop_binoperator cannot operate an empty ERP dataset';
        title = sprintf('ERPLAB: %s() error:', mfilename);
        errorfound(msgboxText, title);
        return
end
if ~isfield(ERP, 'bindata')
        msgboxText{1} =  'pop_binoperator cannot operate an empty ERP dataset';
        title = sprintf('ERPLAB: %s() error:', mfilename);
        errorfound(msgboxText, title);
        return
end
if isempty(ERP.bindata)
        msgboxText{1} =  'pop_binoperator cannot operate an empty ERP dataset';
        title = sprintf('ERPLAB: %s() error:', mfilename);
        errorfound(msgboxText, title);
        return
end
if nargin==1
        
        answer = binoperGUI(ERP);   % call a GUI*
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        formulas = answer{1};
else

        %
        % no warnings about existing bins
        %
        erpworkingmemory('wbmsgon',0)
end
if iscell(formulas)
        formulaArray = formulas';
        opcom = 1; % ---> cell array with formulas
else
        if isnumeric(formulas)
                error('ERPLAB says:  Error, formulas must be a cell string or a filename')
        end
        if strcmp(formulas,'')
                error('ERPLAB says:  Error, formulas were not found.')
        end
        
        disp(['For list of formulas, user selected  <a href="matlab: open(''' formulas ''')">' formulas '</a>'])
        
        fid_formulas = fopen( formulas );
        formulaArray = textscan(fid_formulas, '%[^\n]', 'CommentStyle','#', 'whitespace', '');
        formulaArray = strtrim(cellstr(formulaArray{:})');
        fclose(fid_formulas);
        
        if isempty(formulaArray)
                error('ERPLAB says:  Error, file was empty. No formulas were found.')
        end
        
        opcom = 2; % ---> filename where formulas are described.
end

ERP_tempo = ERP;

%
% Check formulas
%
[option recall goeson] = checkformulas(formulaArray, mfilename);
nformulas  = length(formulaArray);

if recall  && nargin==1
        [ERP erpcom] = pop_binoperator(ERP); % try again...
        return
end

if option==1
        ERPin = ERP;
        % New empty ERP
        ERPout= builtERPstruct([]);
else
        ERPin = ERP;
        ERPout= ERPin;
end

h=1;

while h<=nformulas && goeson
        
        expr = formulaArray{h};
        tokcommentb  = regexpi(formulaArray{h}, '^#', 'match');  % comment
        
        if isempty(tokcommentb)
                
                [ERPout conti cancelop] = binoperator(ERPin, ERPout, expr);
                
                if cancelop && nargin==1
                        recall = 1;
                        break
                end
                
                if conti==1
                        
                        if isempty(ERPout)
                                error(' ERPLAB says: something is wrong...')
                        end
                        
                        if ~option
                                
                                test = checkchannel(ERPout, ERPin);
                                
                                if test==0
                                        ERPin = ERPout; % recursive
                                else
                                        if test==1
                                                bann = 'Number';
                                        else
                                                bann = 'Label';
                                        end
                                        
                                        title = 'ERPLAB: Create a new ERP';
                                        question  = cell(1);
                                        question{1} = [bann ' of channels are different for this bin!'];
                                        question{2} = 'You must save it as a new ERP. Please, use "nbin" sintax instead.';
                                        question{3} = ' Would you like to try again?';
                                        
                                        button = askquest(question, title);
                                        
                                        if strcmpi(button,'yes')
                                                disp('User selected Cancel')
                                                recall = 1;
                                                break
                                        else
                                                goeson = 0;
                                        end
                                end
                        end
                end
        end
        h = h + 1;
end

if ~isfield(ERPout, 'binerror')
        ERPout.binerror = [];
end
if ~goeson
        ERP = ERP_tempo; % recover unmodified ERP
        disp('Warning: Your ERP structure has not yet been saved')
        disp('user canceled')
        return
end
if recall  && nargin==1
        ERP = ERP_tempo;
        [ERP erpcom] = pop_binoperator(ERP); % try again...
        return
end
if option==1
        ERPout.workfiles = ERPin.workfiles;
        ERPout.xmin      = ERPin.xmin;
        ERPout.xmax      = ERPin.xmax;
        ERPout.times     = ERPin.times;
        ERPout.pnts      = ERPin.pnts;
        ERPout.srate     = ERPin.srate;
        ERPout.isfilt    = ERPin.isfilt;
        ERPout.ref       = ERPin.ref;
        ERPout.EVENTLIST = ERPin.EVENTLIST;
end

ERP = ERPout;

if nargin<2 && option==1  % only for GUI and nbins
        [ERP issave]= pop_savemyerp(ERP,'gui','erplab');
elseif nargin<2 && option==0  % only for GUI and bins ---> overwrite
        [ERP issave]= pop_savemyerp(ERP, 'gui', 'erplab', 'overwriteatmenu', 'yes');
else
        issave =1;
end

if issave
        if opcom==1
                erpcom = sprintf('%s = pop_binoperator( %s, { ', inputname(1), inputname(1));
                for j=1:nformulas;
                        erpcom = sprintf('%s ''%s''  ', erpcom, formulaArray{j} );
                end;
                erpcom = sprintf('%s });', erpcom);
        else
                erpcom = sprintf('%s = pop_binoperator( %s, ''%s'');', inputname(1), inputname(1),...
                        formulas);
        end
        try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
        return
else
        ERP = ERP_tempo; % recover unmodified ERP
        disp('Warning: Your ERP structure has not yet been saved')
        disp('user canceled')
        return
end
