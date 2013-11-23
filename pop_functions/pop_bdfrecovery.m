% PURPOSE  : 	To recover bin descriptor file from EEG or ERP
%
% FORMAT   :
%
% pop_bdfrecovery(data)
%
% EXAMPLE  :
%
% pop_bdfrecovery(EEG)    (save as GUI will appear)
%
% Or
%
% pop_bdfrecovery(ERP)    (save as GUI will appear)
%
% INPUTS   :
%
% Data          - EEG- if recovering bin descriptor file from EEG
%               - ERP- if recovering bin descriptor file from ERP
%
% OUTPUTS  :
%
% Text file with bin descriptor file saved in it.
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

function [ERPLAB, erpcom] = pop_bdfrecovery(ERPLAB, varargin)
erpcom='';
if nargin<1
        help pop_bdfrecovery
        return
end
if isobject(ERPLAB) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if isempty(ERPLAB)
        msgboxText =  'No dataset/erpset was found!';
        title_msg  = 'ERPLAB: pop_erplindetrend() error:';
        errorfound(msgboxText, title_msg);
        return
else
        if iserpstruct(ERPLAB)
                strstruct = 'ERP';
        else
                strstruct = 'EEG';
        end
end
if length(ERPLAB)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        title = 'ERPLAB: multiple inputs';
        errorfound(msgboxText, title);
        return
end
if isfield(ERPLAB, 'EVENTLIST')
        if isfield(ERPLAB.EVENTLIST, 'bdf')
                if isempty(ERPLAB.EVENTLIST(1).bdf)
                        msgboxText =  [strstruct '.EVENTLIST.bdf structure is empty!'];
                        title = 'ERPLAB: pop_bdfrecovery() error';
                        errorfound(msgboxText, title);
                        return
                end
                if isfield(ERPLAB.EVENTLIST(1).bdf, 'expression')
                        if isempty([ERPLAB.EVENTLIST(1).bdf.expression])
                                msgboxText =  [strstruct '.EVENTLIST.bdf structure is empty!'];
                                title = 'ERPLAB: pop_bdfrecovery() error';
                                errorfound(msgboxText, title);
                                return
                        end
                else
                        msgboxText = [strstruct '.EVENTLIST.bdf.expression\n structure was not found!'];
                        title = 'ERPLAB: pop_bdfrecovery() error';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        else
                msgboxText = [strstruct '.EVENTLIST.bdf structure was not found!'];
                title = 'ERPLAB: pop_bdfrecovery() error';
                errorfound(msgboxText, title);
                return
        end
else
        msgboxText = [strstruct '.EVENTLIST structure was not found!'];
        title = 'ERPLAB: pop_bdfrecovery() error';
        errorfound(msgboxText, title);
        return
end
if nargin==1
        
        %
        % Save ascii file
        %
        bdfnamefull = ERPLAB.EVENTLIST(1).bdfname;
        [pathbdf, bdfname, extbdf] = fileparts(bdfnamefull);
        [filenamei, pathname, findex] = uiputfile({'*.txt';'*.*'},...
                'Save bin descriptor file as', [bdfname '.txt']);
        if isequal(filenamei,0)
                disp('User selected Cancel')
                return
        else
                [pathx, filename, ext] = fileparts(filenamei);
                
                if ~strcmpi(ext,'.txt') && ~isempty(ext)
                        ext = '.txt';
                end
                filename = [filename ext];
                fname    = fullfile(pathname, filename);
        end
        
        %
        % Somersault
        %
        [ERPLAB, erpcom] = pop_bdfrecovery(ERPLAB, 'Filename', fname, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERPLAB');
% option(s)
p.addParamValue('Filename', '', @ischar); % erpset index or input file
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERPLAB, varargin{:});

fname   = p.Results.Filename;
if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
nbin = ERPLAB.EVENTLIST(1).nbin;
fid_rt  = fopen(fname, 'w');
for i=1:nbin
        fprintf(fid_rt, 'bin %g\n',i);
        fprintf(fid_rt, '%s\n', ERPLAB.EVENTLIST(1).bdf(i).description);
        fprintf(fid_rt, '%s\n', ERPLAB.EVENTLIST(1).bdf(i).expression);
        fprintf(fid_rt, '\n');
end

fclose(fid_rt);
disp(['A recovered bin descriptor file was saved at <a href="matlab: open(''' fname ''')">' fname '</a>'])
% erpcom = sprintf('pop_bdfrecovery(%s);', inputname(1));

%
% History
%
skipfields = {'ERPLAB', 'History'};
fn     = fieldnames(p.Results);
if iserpstruct(ERPLAB)
        inpnamex = 'ERP';
else
        inpnamex = 'EEG';
end
erpcom = sprintf( '%s = pop_bdfrecovery( %s ', inpnamex, inpnamex );
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        if ischar([fn2res{:}])
                                                fn2resstr = sprintf('''%s'' ', fn2res{:});
                                        else
                                                fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        end
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                if strcmpi(fn2com,'Criterion')
                                        if p.Results.Criterion<100
                                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                        end
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);
if iseegstruct(ERPLAB)
        % get history from script. EEG
        switch shist
                case 1 % from GUI
                        erpcom = sprintf('%s %% GUI: %s', erpcom, datestr(now));
                        %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
                        displayEquiComERP(erpcom);
                case 2 % from script
                        ERPLAB = erphistory(ERPLAB, [], erpcom, 1);
                case 3
                        % implicit
                otherwise %off or none
                        erpcom = '';
        end        
else
        % get history from script. ERP
        switch shist
                case 1 % from GUI
                        displayEquiComERP(erpcom); 
                case 2 % from script
                        ERPLAB = erphistory(ERPLAB, [], erpcom, 1);
                case 3
                        % implicit 
                otherwise %off or none
                        erpcom = '';
        end
end


%
% Completion statement
%
msg2end
return