% PURPOSE  : 	Append (join) ERPsets
%
% FORMAT   :
%
% ERP = pop_appenderp(ALLERP, 'Erpsets', indices, 'Prefixes', prefixes)
%
% or
%
% ERP = pop_appenderp('C:\Users\Work\Documents\MATLAB\ERP_List.txt', 'Erpsets', indices, 'Prefixes', prefixes);
%
%
% EXAMPLE :
%
% ERP = pop_appenderp(ALLERP, 'Erpsets', [2 3], 'Prefixes', {'Control', 'ADHD'});
% ERP = pop_appenderp('C:\Users\Work\Documents\MATLAB\ERP_List.txt', 'Prefixes', {'Control', 'ADHD'});
%
%
% INPUTS     :
%
% ALLERP       - structure array of ERP structures (ERPsets).
%                To read the ERPset from a list in a text file, replace ALLERP by the whole filename.
% 'Erpsets'    - index(es) pointing to ERP structures within ALLERP (only valid when ALLERP is specified)
% 'Prefixes'   - label concatenated at the beggining of each bin descriptor
%                in order to identify each appended ERPset.
%
%
% OUTPUTS :
%
% -ERP       - Output new appended ERPset
%
% See also pop_binoperator pop_blcerp
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

function [ERP, erpcom] = pop_appenderp(ALLERP,varargin)
erpcom = '';
ERP      = preloadERP;
ERPaux = ERP;
if nargin<1
        help pop_appenderp
        return
end
if nargin==1 && ~ischar(ALLERP)  % GUI
        if isstruct(ALLERP)
                cond1 = iserpstruct(ALLERP(1));
                if ~cond1
                        ALLERP = [];
                end
        else
                ALLERP = [];
        end
        nloadedset = length(ALLERP);
        def  = erpworkingmemory('pop_appenderp');
        if isempty(def)
                if isempty(ALLERP)
                        inp1   = 1; %from hard drive
                        erpset = [];
                else
                        inp1   = 0; %from erpset menu
                        erpset = 1:length(ALLERP);
                end
                isprefix   = 0;
                prefixlist = '';
                def = {inp1 erpset prefixlist};
                %def = { erpset  prefixlist};
        else
                if ~isempty(ALLERP)
                        if isnumeric(def{2}) % JavierLC 11-17-11
                                [uu, mm] = unique_bc2(def{2}, 'first');
                                def{2}  = [def{2}(sort(mm))];
                        end
                end
        end
        
        %
        % Call GUI
        %
        answer = appenderpGUI(nloadedset, def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        optioni    = answer{1}; %1 means from hard drive, 0 means from erpsets menu
        erpset     = answer{2};
        prefixlist = answer{3};
        
        if optioni==1 % from files
                filelist = erpset;
                ALLERP   = {ALLERP, filelist}; % truco
        else % from erpsets menu
                %erpset  = erpset;
        end
        if isempty(prefixlist)
                prefixliststr   = 'off'; % do not include prefix
        elseif isnumeric(prefixlist)
                prefixliststr = 'erpname'; % use erpname instead
        else
                prefixliststr   = prefixlist; % include prefix from list
        end
        erpworkingmemory('pop_appenderp', { optioni, erpset, prefixlist });
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_appenderp(ALLERP, 'Erpsets', erpset, 'Prefixes', prefixliststr, 'Saveas', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
% options
p.addParamValue('Erpsets', 1); % erpset index or input file
p.addParamValue('Prefixes', []);
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ALLERP, varargin{:});

erpset   = p.Results.Erpsets;
prefixes = p.Results.Prefixes;

if isempty(erpset)
        error('ERPLAB says: ''Erpsets'' inputs is missing.')
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

cond1 = iserpstruct(ALLERP);
cond2 = isnumeric(erpset);

if cond1 && cond2 % either from GUI or script, when ALLERP exist and erpset indices were specified
        optioni      = 0; % from erpset menu or ALLERP struct
        indx = erpset;
        nerp = length(indx);
else
        optioni  = 1; % from file
        filelist = '';
        if iscell(ALLERP) % from the GUI, when ALLERP exist and user picks a list up as well
                filelist = ALLERP{2};
                ALLERP   = ALLERP{1};
        elseif ischar(ALLERP) % from script, when user picks a list.
                filelist = ALLERP;
        end
        if ~iscell(filelist) && ~isempty(filelist)
                disp(['For file-List, user selected ', filelist])
                
                %
                % open file containing the erp list
                %
                fid_list = fopen( filelist );
                formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
                lista    = formcell{:};
                nfile    = length(lista);
                fclose(fid_list);
        else
                error('ERPLAB says: error at pop_appenderp(). Unrecognizable input ')
        end
end
if ischar(prefixes)
        if strcmpi(prefixes, 'off')
                pfixes = [];
        else
                pfixes = prefixes;
        end
else
        pfixes = prefixes;
end
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
        issaveas  = 1;
else
        issaveas  = 0;
end
if optioni~=0
        errorerp = 0;
        if nfile>1
                numpoints = zeros(1,nfile);
                numchans  = zeros(1,nfile);
                chckdatatype = cell(1);
                nameerp   = {''};
                clear ALLERP
                
                for j=1:nfile
                        [pname, fname, ext] = fileparts(strtrim(lista{j}));
                        ALLERP(j) = pop_loaderp('filename', [fname ext], 'filepath', pname, 'History', 'off');
                        
                        numpoints(j)    = ALLERP(j).pnts;
                        numchans(j)     = ALLERP(j).nchan;
                        nameerp{j}      = ALLERP(j).erpname;
                        chckdatatype{j} = ALLERP(j).datatype;
                        clear ERP1
                end
                if errorerp
                        error('ERPLAB says: Loading ERP process has crashed....')
                else
                        if length(unique(numpoints))>1
                                fprintf('Detail:\n')
                                fprintf('-------\n')
                                for j=1:nfile
                                        fprintf('Erpset %s has %g points per bin\n', nameerp{j}, numpoints(j));
                                end
                                msgboxText = 'ERPsets have different number of points\n';
                                etitle = 'ERPLAB: appenderpGUI inputs';
                                errorfound(sprintf(msgboxText), etitle);
                                return
                        end
                        if length(unique(numchans))>1
                                fprintf('Detail:\n')
                                fprintf('-------\n')
                                for j=1:nfile
                                        fprintf('Erpset %s has %g channels\n', nameerp{j}, numchans(j));
                                end
                                msgboxText = 'ERPsets have different number of channel\n';
                                etitle = 'ERPLAB: appenderpGUI inputs';
                                errorfound(sprintf(msgboxText), etitle);
                                return
                        end
                        if length(unique(chckdatatype))>1
                                fprintf('Detail:\n')
                                fprintf('-------\n')
                                for j=1:nfile
                                        fprintf('Erpset %s has data type = %s\n', nameerp{j}, chckdatatype{j});
                                end
                                msgboxText = 'ERPsets have different data type\n';
                                etitle = 'ERPLAB: appenderpGUI inputs';
                                errorfound(sprintf(msgboxText), etitle);
                                return
                        end
                end
        else
                msgboxText = 'File is empty!\n';
                etitle = 'ERPLAB: appenderpGUI inputs';
                errorfound(sprintf(msgboxText), etitle);
                return
        end
        nerp = length(ALLERP);
        indx = 1:nerp;
end
nprefix = length(pfixes);
if ~isempty(pfixes) && iscell(pfixes)
        if nerp~=nprefix
                msgboxText =  'Error: prefixes must to be as large as indx';
                title = 'ERPLAB: pop_appenderp() error:';
                errorfound(msgboxText, title);
                ERP = ERPaux;
                return
        end
end

%
% subroutine
%
[ERP, serror] = appenderp(ALLERP,indx, pfixes);

if serror==0
        
        %
        % Completion statement
        %
        msg2end
        
        %
        % History
        %
        skipfields = {'ALLERP', 'Saveas', 'History'};
        if isstruct(ALLERP) && optioni~=1 % from files
                DATIN =  inputname(1);
        else
                DATIN = sprintf('''%s''', filelist);
                skipfields = [skipfields, 'Erpsets'];
        end
        fn     = fieldnames(p.Results);
        erpcom = sprintf( 'ERP = pop_appenderp( %s ', DATIN );
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
        
        %
        % Save ERPset
        %
        if issaveas
                [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
                if issave>0
                        if issave==2
                                erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                                msgwrng = '*** Your ERPset was saved on your hard drive.***';
                        else
                                msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
                        end
                else
                        msgwrng = 'ERPLAB Warning: Your changes were not saved';
                end
                try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
        end
elseif serror==1
        msgboxText =  'Your ERPs do not have the same amount of channels!';
        title = 'ERPLAB: pop_appenderp() error:';
        errorfound(msgboxText, title);
        ERP = ERPaux;
        return
elseif serror==2
        msgboxText =  'Your ERPs do not have the same amount of points!';
        title = 'ERPLAB: pop_appenderp() error:';
        errorfound(msgboxText, title);
        ERP = ERPaux;
        return
else
        msgboxText =  'Error: Your ERPs are not compatibles!';
        title = 'ERPLAB: pop_appenderp() error:';
        errorfound(msgboxText, title);
        ERP = ERPaux;
        return
end
% get history from script
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);               
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
        otherwise %off or none
                erpcom = '';
end
return
