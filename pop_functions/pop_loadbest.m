% PURPOSE  : 	Loads BESTset(s)
%
% FORMAT   :
%
% BEST = pop_loadbest(parameters);
%
% PARAMETERS     :
%
% 'filename'        - BESTset filename
% 'filepath'        - BESTset's filepath
% 'Warning'         - 'on'/'off'(Def)
% 'UpdateMainGui'   - 'on'/'off'(Def)
%
%
% OUTPUTS  :
%
% BEST	- output BESTset
%
%
% Example :
%
% BEST = pop_loadbest( 'filename', 'Face_Emotion_302_ICA_removed.best', 'filepath',...
% pwd); 


% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

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



function [BEST, ALLBEST] = pop_loadbest(varargin)
BEST = preloadBEST; 
try 
    ALLBEST = evalin('base', 'ALLBEST');
    preindex = length(ALLBEST); 
    
catch 
    disp('WARNING: ALLBEST structure was not found. ERPLAB will create an empty one.')
    ALLBEST = [];
    %ALLERP   = buildERPstruct([]);
    preindex = 0;

end

if nargin <1 
    help pop_loadbest
    
    return
    
end


if nargin == 1
        filename = varargin{1};
        if strcmpi(filename,'workspace')
                filepath = '';
        else
                if isempty(filename)
                        [filename, filepath] = uigetfile({'*.best','BEST (*.best)'},...
                                'Load BEST','MultiSelect', 'on');
                        if isequal(filename,0)
                                disp('User selected Cancel')
                                return
                        end
                        
                        %
                        % test current directory
                        %
                        %changecd(filepath) % Steve does not like this...
                else
                        filepath = cd;
                end
        end
        
        %
        % Somersault
        %
        
        [BEST, ALLBEST] = pop_loadbest('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'on','History','gui');
        return
    
    
    
end


% parsing inputs
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('filename', '');
p.addParamValue('filepath', '', @ischar);
p.addParamValue('overwrite', 'off', @ischar);
p.addParamValue('Warning', 'off', @ischar);
%p.addParamValue('multiload', 'off', @ischar); % ERP stores ALLERP's contain (ERP = ...), otherwise [ERP ALLERP] = ... must to be specified.
p.addParamValue('UpdateMainGui', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(varargin{:});

filename = strtrim(p.Results.filename);
filepath = strtrim(p.Results.filepath);

if strcmpi(filename,'workspace')
        filepath = '';
        nfile = 1;
        loadfrom = 0;  % load from workspace
else
        loadfrom = 1; % load from: 1=hard drive; 0=workspace
end

if strcmpi(p.Results.Warning,'on')
        popupwin = 1;
else
        popupwin = 0;
end
if strcmpi(p.Results.UpdateMainGui,'on')
        updatemaingui = 1;
else
        updatemaingui = 0;
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

% if strcmpi(p.Results.multiload,'on')
%         multiload = 1;
% else
%         multiload = 0;
% end

if loadfrom==1
        if iscell(filename)
                nfile      = length(filename);
                inputfname = filename;
        else
                nfile = 1;
                inputfname = {filename};
        end
else
        inputfname = {'workspace'};
end


inputpath = filepath;
errorf    = 0; % no error found, by default
conti     = 1; % continue?  1=yes; 0=no
% if strcmpi(p.Results.overwrite,'on')||strcmpi(p.Results.overwrite,'yes')
%     ovatmenu = 1;
% else
%     ovatmenu = 0;
% end


for i=1:nfile
        if loadfrom==1
            fullname = fullfile(inputpath, inputfname{i});
            fprintf('Loading %s\n', fullname);
            L   = load(fullname, '-mat');
            BEST = L.BEST; 
%             if i == 1
%                 BEST = L.BEST;
%             else
%                 BEST(i) = L.BEST;
%             end
        else
            BEST = evalin('base', 'BEST');
        end
        
        %
        % Skipping all "checking" features for now
        % - see pop_loaderp() for "checking ERP" routine
        %
        
        if i == 1 && isempty(ALLBEST) 
           ALLBEST = BEST;  
           
        else
           ALLBEST(i+preindex) = BEST; 
            
            
        end
        
        
end

if conti==0
        return
end

% if nargout==1 && multiload==1
%         BEST = ALLBEST;
% end

if nfile==1
        outv = 'BEST';
else
        outv = '[BEST ALLBEST]';
end





%% see line 280 in pop_loaderp
if updatemaingui % update erpset menu at main gui
    assignin('base','ALLBEST',ALLBEST);  % save to workspace
    updatemenubest(ALLBEST); % add a new bestset to the bestset menu
end

fn         = fieldnames(p.Results);
bestcom     = sprintf( '%s = pop_loadbest(', outv);
skipfields = {'UpdateMainGui', 'Warning','History','overwrite'};

for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if iscell(fn2res) % 10-21-11
            nc = length(fn2res);
            xfn2res = sprintf('{''%s''', fn2res{1} );
            for f=2:nc
                xfn2res = sprintf('%s, ''%s''', xfn2res, fn2res{f} );
            end
            fn2res = sprintf('%s}', xfn2res);
        else
            if ~strcmpi(fn2res,'off') %&& ~strcmpi(fn2res,'on')
                fn2res = ['''' fn2res ''''];
            end
        end
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    if q==1
                        bestcom = sprintf( '%s ''%s'', %s', bestcom, fn2com, fn2res);
                    else
                        bestcom = sprintf( '%s, ''%s'', %s', bestcom, fn2com, fn2res);
                    end
                end
            else
                bestcom = sprintf( '%s, ''%s'', %s', bestcom, fn2com, vect2colon(fn2res,'Repeat','on'));
            end
        end
    end
end
bestcom = sprintf( '%s );', bestcom);

switch shist
        case 1 % from GUI
                displayEquiComERP(bestcom);
        case 2 % from script
                %ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
                % ERP = erphistory(ERP, [], erpcom, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
               % erpcom = '';
                return
end


prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end


return