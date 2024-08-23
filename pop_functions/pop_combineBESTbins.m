% PURPOSE  : Combine bins within a BEST file. Outputs BEST file with
%           combined bin appended at the end of BESTset.
%
% FORMAT   :
%
% >>   [BEST] = pop_combineBESTbins(BEST,parameters);
%
% INPUTS   :
%
%         BEST       - input BEST dataset
%
% The available input parameters are as follows:
%
%        'bins_to_combine' 	   - Cell array of bins to combine where each
%                                 element is a set of bin indexes from BEST.
%        'bin_labels'          - Cell array of bin description names for
%                                   each newly combined bin.
%                                   Length of cellarray must equal 'bins_to_combine'
%
%        'SaveAs'      -  (optional) open GUI for saving BESTset.
%                           'on'/'off' (Default: off)
%                           - (if "off", will not update in BESTset menu)
%                           - if scripting, use "off" and pop_savemybest()
%
% OUTPUTS  :
%
% BEST           -  output BEST structure
%
% EXAMPLE  :
%
% [BEST] = pop_combineBESTbins(BEST,'bins_to_combine',{[1,2,3],[4,5,6]}, ...
% 'bin_labels',{'Combined bins 1,2,3','Combined bins 4,5,6'});
%
% See also: pop_savemybest.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons and Steven J Luck.
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

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

function [ALLBEST] = pop_combineBESTbins(ALLBEST,BESTArray, varargin);
com = '';

%preload BEST
BEST = preloadBEST;

if nargin < 1
    help pop_combineBESTbins
    return
end
if nargin < 2
    BESTArray = evalin('base','CURRENTBEST');
    if BESTArray == 0
        msgboxText =  'pop_combineBESTbins() error: cannot work an empty dataset!!!';
        title      = 'ERPLAB: No data';
        errorfound(msgboxText, title);
        return
    end
end

if isempty(BESTArray) || any(BESTArray(:)>length(ALLBEST))|| any(BESTArray(:)<1)
    msgboxText =  ['pop_combineBESTbins() error: The current beset should be between 1 and',32,num2str(length(ALLBEST))];
    title      = 'ERPLAB: error';
    errorfound(msgboxText, title);
    return
end

if numel(BESTArray)>1
    msgwrng = f_check_bestsets(ALLBEST,BESTArray);
    if ~isempty(msgwrng)
        title      = 'ERPLAB: pop_combineBESTbins() error';
        errorfound(msgwrng, title);
        return
    end
end


if nargin <3 %open GUI
    def = erpworkingmemory('pop_combineBESTbins');

    if isempty(def)
        def = {{[]},{[]}};
        %1 binindex(s) from old BEST that will create new BEST
        %2 binlabel(s) from oldBEST taht will create new BEST

    end


    app = feval('combinebestbinsGUI',ALLBEST,BESTArray,def);
    waitfor(app,'FinishButton',1);

    try
        res = app.output;
        app.delete; %delete app from view
        pause(0.5); %wait for app to leave
    catch
        disp('User selected Cancel')
        return
    end


    BEST = res{1};
    nbins = res{2}.bini;
    nlabels = res{2}.labels;

    def = {nbins,nlabels};
    erpworkingmemory('pop_combineBESTbins',def);

    [ALLBEST] = pop_combineBESTbins(ALLBEST,BESTArray, 'bins_to_combine',nbins,'bin_labels',nlabels, ...
        'Saveas','on', 'History','gui');

    pause(0.1);
    return

end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLBEST');
p.addRequired('BESTArray');

% p.addParamValue('BESTArray', 1,@isnumeric); % erpset index or input file (default: first BESTset in ALLBEST)
p.addParamValue('bins_to_combine',{}); %array of channel indicies (def: all channels)
p.addParamValue('bin_labels',{});
p.addParamValue('Saveas','off');
p.addParamValue('History','script');


% Parsing
p.parse(ALLBEST,BESTArray, varargin{:});

idx_bestset = p.Results.BESTArray;
new_bins = p.Results.bins_to_combine;
new_labels = p.Results.bin_labels;



if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
end


if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end


%% bin-combiner routine
ALLBEST_old = ALLBEST;
for Numofbest = 1:numel(BESTArray)
    ALLBEST(length(ALLBEST)+1) = combineBESTbins(ALLBEST_old(BESTArray(Numofbest)), new_bins, new_labels);
    BESTArray_new(Numofbest)= length(ALLBEST);
end
%
% History
%
skipfields = {'ALLBEST', 'BESTArray','Saveas','Warning','History'};


fn      = fieldnames(p.Results);
explica = 0;
if length(idx_bestset)==1 && idx_bestset(1)==1
    inputvari  = 'BEST'; % Thanks to Felix Bacigalupo for this suggestion. Dic 12, 2011
    skipfields = [skipfields 'ALLBEST' 'BESTArray']; % SL
else
    if length(idx_bestset)==1
        explica   = 1;
    end
    inputvari = inputname(1);
end
bestarraystr = vect2colon(BESTArray);
bestcom = sprintf( 'ALLBEST = pop_combineBESTbins( %s,%s ', inputvari,bestarraystr);

% Iterate through each field name
% Loop through each field name
for q = 1:length(fn)
    fn2com = fn{q};  % Current field name
    if ~ismember_bc2(fn2com, skipfields)  % If not in skipfields
        fn2res = p.Results.(fn2com);  % Get the result for the current field
        if ~isempty(fn2res)
            if ischar(fn2res)  % If it's a character array
                if ~strcmpi(fn2res, 'off')
                    bestcom = sprintf('%s, ''%s'', ''%s''', bestcom, fn2com, fn2res);
                end
            elseif iscell(fn2res)  % If it's a cell array
                fn2resstr = '';  % Initialize temporary storage
                for kk = 1:numel(fn2res)
                    auxcont = fn2res{kk};  % Extract the cell content
                    if isnumeric(auxcont)  % If it's a numeric array
                        formattedArray = sprintf('[%s]', sprintf('%d ', auxcont));  % Format with brackets
                        formattedArray = strtrim(formattedArray);  % Trim spaces at the ends
                        fn2resstr = [fn2resstr formattedArray ', '];  % Add comma
                    elseif ischar(auxcont)  % If it's a string
                        fn2resstr = [fn2resstr '''' auxcont ''', '];  % Add quotes and comma
                    end
                end
                fn2resstr = fn2resstr(1:end - 2);  % Remove trailing comma and space
                bestcom = sprintf('%s, ''%s'', {%s}', bestcom, fn2com, fn2resstr);  % Append to bestcom
            elseif isnumeric(fn2res)  % If it's a numeric array
                formattedArray = sprintf('[%s]', sprintf('%d ', fn2res));  % Format with brackets
                formattedArray = strtrim(formattedArray);  % Trim spaces
                bestcom = sprintf('%s, ''%s'', %s', bestcom, fn2com, formattedArray);  % Append
            end
        end
    end
end

% Add closing parenthesis and semicolon to the final string
bestcom = sprintf('%s )', bestcom);

% Execute or display the final command
eegh(bestcom);

%% save function

if issaveas
    for Numofbest = 1:numel(BESTArray_new)
        BEST= ALLBEST(BESTArray_new(Numofbest));
        [BEST, issave] = pop_savemybest(BEST,'gui','erplab');
        ALLBEST(BESTArray_new(Numofbest)) = BEST;
    end


    if issave>0
        if issave==2
            %erpcom  = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your BESTset was saved on your hard drive.***';
        else
            msgwrng = '*** Warning: Your BESTset was only saved on the workspace.***';
        end
    else
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end

switch shist
    case 1 % from GUI
        % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        displayEquiComERP(bestcom);
        if explica
            try
                cprintf([0.1333, 0.5451, 0.1333], '%%IMPORTANT: For pop_combineBESTbins, you may use BEST instead of ALLBEST, and remove "''BESTArray'',%g"\n',idx_bestset);
            catch
                fprintf('%%IMPORTANT: For pop_combineBESTbins, you may use BEST instead of ALLBEST, and remove ''BESTArray'',%g:\n',idx_bestset);
            end
        end
    case 2 % from script
        % ERP = erphistory(ERP, [], bestcom, 1);
    case 3
        % implicit
    otherwise % off or none
        bestcom = '';
end

return
