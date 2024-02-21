% PURPOSE  : 	Averages bin-based ERPsets (grand average)
%
% FORMAT   :
%
% ERP = pop_gaverager( ALLERP , Parameters);
%
%
% INPUTS   :
%
% ALLERP            - structure array of ERP structures (ERPsets)
%                     To read the ERPset from a list in a text file,
%                     replace ALLERP by the whole filename.
%
% The available parameters are as follows:
%
% 'Erpsets'         - index(es) pointing to ERP structures within ALLERP (only valid when ALLERP is specified)
% 'Weighted'        - 'on' means apply weighted-average, 'off' means classic average.
% 'SEM'             - Get standard error of the mean. 'on' or 'off'
% 'ExcludeNullBin'  - Exclude any null bin from non-weighted averaging (Bin that has zero "epochs" when averaged)
% 'Warning'         - Warning 'on' or 'off'
% 'Criterion'       - Max allowed mean artifact detection proportion
% 'DQ_Flag'         - Data Quality options 'on' or 'off'
% 'DQ_Spec'         - Structure array of Data Quality specifications.
%
% OUTPUTS  :
%
% ERP               - data structure containing the average of all specified datasets.
%
%
% EXAMPLE  :
%
% ERP = pop_gaverager( ALLERP , 'Erpsets',1:4, 'Criterion',100, 'SEM',...
% 'on', 'Warning', 'on', 'Weighted', 'on' );
%
% or
%
% ERP = pop_gaverager('C:\Users\Work\Documents\MATLAB\ERP_List.txt', 'Criterion',100,...
% 'SEM', 'on', 'Warning', 'on', 'Weighted', 'on');
%
%
% See also grandaveragerGUI.m gaverager.m pop_averager.m averager.m
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
% Copyright � 2007 The Regents of the University of California
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
%
% Thanks to Pierre Jolicoeur and Pia Amping for warning us about
% pop_gaverager when working with ERPsets that contains bin(s) with 0 segments.
%

function [ERP, erpcom] = pop_gaverager(ALLERP, varargin)
erpcom = '';
ERP    = preloadERP;
if nargin<1
    help pop_gaverager
    return
end
if nargin==1  % GUI
    if ~iscell(ALLERP) && ~ischar(ALLERP)
        if isstruct(ALLERP)
            iserp = iserpstruct(ALLERP(1));
            if ~iserp
                ALLERP = [];
            end
            actualnset = length(ALLERP);
        else
            ALLERP = [];
            actualnset = 0;
        end
        
        def  = erpworkingmemory('pop_gaverager');
        if isempty(def)
            def = { actualnset 0 '' 100 0 1 1};
        else
            def{1}=actualnset;
        end
        if isnumeric(def{3}) && ~isempty(ALLERP)
            if max(def{3})>length(ALLERP)
                def{3} = def{3}(def{3}<=length(ALLERP));
            end
            if isempty(def{3})
                def{3} = 1;
            end
        end
        
        %
        % Open Grand Average GUI
        %
        answer = grandaveragerGUI(def);
        
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        
        optioni    = answer{1}; %1 means from a filelist, 0 means from erpsets menu
        erpset     = answer{2};
        artcrite   = answer{3}; % max percentage of rej to be included in the gaverage
        wavg       = answer{4}; % 0;1
        excnullbin = answer{5}; % 0;1
        stderror   = answer{6}; % 0;1
        jk         = answer{7}; % 0;1
        jkerpname  = answer{8}; % erpname for JK grand averages
        jkfilename = answer{9}; % filename for JK grand averages
        dq_option  = answer{10}; % data quality combine option. 0 - off, 1 - on/default, 2 - on/custom
        dq_spec    = answer{11}; % data quality custom combine options
        
        if optioni==1 % from files
            filelist    = erpset;
            disp(['pop_gaverager(): For file-List, user selected ', filelist])
            ALLERP = {ALLERP, filelist}; % truco
        else % from erpsets menu
            %erpset  = erpset;
        end
        
        def = {actualnset, optioni, erpset, artcrite, wavg, excnullbin, stderror};
        erpworkingmemory('pop_gaverager', def);
        if stderror==1
            stdsstr = 'on';
        else
            stdsstr = 'off';
        end
        if excnullbin==1
            excnullbinstr = 'on'; % exclude null bins.
        else
            excnullbinstr = 'off';
        end
        if wavg==1
            wavgstr = 'on';
        else
            wavgstr = 'off';
        end
        if jk==1
            %
            % Jackknife
            %
            [ALLERP, erpcom]  = pop_jkgaverager(ALLERP, 'Erpsets', erpset, 'Criterion', artcrite,...
                'SEM', stdsstr, 'Weighted', wavgstr, 'Erpname', jkerpname, 'Filename', jkfilename,...
                'DQ_flag',dq_option,'DQ_spec',dq_spec,'Warning', wavgstr);
            
            assignin('base','ALLERP', ALLERP);  % save to workspace
            updatemenuerp(ALLERP); % add a new erpset to the erpset menu
        else
            %
            % Somersault
            %
            %[ERP erpcom]  = pop_gaverager(ALLERP, 'Erpsets', erpset, 'Loadlist', filelist,'Criterion', artcrite,...
            %        'SEM', stdsstr, 'Weighted', wavgstr, 'Saveas', 'on');
            [ERP, erpcom]  = pop_gaverager(ALLERP, 'Erpsets', erpset,'Criterion', artcrite, 'SEM', stdsstr,...
                'ExcludeNullBin', excnullbinstr,'Weighted', wavgstr, 'Saveas', 'on',...
                'DQ_flag',dq_option,'DQ_spec',dq_spec,'Warning', wavgstr, 'History', 'gui');
        end
        pause(0.1)
        return
    else
        fprintf('pop_gaverager() was called using a single (non-struct) input argument.\n\n');
    end
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
% option(s)
p.addParamValue('ERPindex', []);               % same as Erpsets
p.addParamValue('Erpsets', []);
p.addParamValue('Criterion', 100, @isnumeric); %  0-100; threshold of artifacts, in %, for delivering a warning
p.addParamValue('Weighted', 'off', @ischar);   % 'on', 'off'
p.addParamValue('SEM', 'off', @ischar);        % 'on', 'off'
p.addParamValue('ExcludeNullBin', 'on', @ischar); % exclude any null bin from the averaging
p.addParamValue('Saveas', 'off', @ischar);     % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);    % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.addParamValue('DQ_flag',1,@isnumeric); % data quality combine option. 0 - off, 1 - on/default, 2 - on/custom

% Set up default struct for GAv DQ combo methods
GAv_combo_defaults.measures = [1, 2, 3]; % Use first 3 DQ measures
GAv_combo_defaults.methods = [2, 2, 2]; % Use the 2nd combo method, Root-Mean Square, for each
GAv_combo_defaults.measure_names = {'Baseline Measure - SD';'Point-wise SEM'; 'aSME'};
GAv_combo_defaults.method_names = {'Pool ERPSETs, GrandAvg mean','Pool ERPSETs, GrandAvg RMS'};
GAv_combo_defaults.str = {'Baseline Measure - SD, GrandAvg RMS';'Point-wise SEM, GrandAvg RMS'; 'aSME GrandAvg RMS'};

p.addParamValue('DQ_spec',GAv_combo_defaults);

p.parse(ALLERP, varargin{:});

% Arrange input for gaverager, and check sets seem valid
erpset = p.Results.Erpsets;

if isempty(erpset)
    erpset = p.Results.ERPindex;
end
cond1 = iserpstruct(ALLERP);
if isempty(erpset) && cond1
    error('ERPLAB says: "Erpsets" parameter was not specified.')
end
cond2 = isnumeric(erpset);
lista = '';
if cond1 && cond2     % either from GUI or script, when ALLERP exist and erpset indices were specified
    nfile   = length(erpset);
    optioni = 0;  % from erpset menu or ALLERP struct
else
    optioni  = 1; % from file
    filelist = '';
    if iscell(ALLERP)             % from the GUI, when ALLERP exist and user picks a list up as well
        filelist = ALLERP{2};
        ALLERP   = ALLERP{1};
    elseif ischar(ALLERP)         % from script, when user picks a list.
        filelist = ALLERP;
    else
        error('ERPLAB says: "Erpsets" parameter is not valid.')
    end
    if ~iscell(filelist) && ~isempty(filelist)
        if exist(filelist, 'file')~=2
            error('ERPLAB:error', 'ERPLAB says: File %s does not exist.', filelist)
        end
        disp(['For file-List, user selected ', filelist])
        
        %
        % open file containing the erp list
        %
        fid_list = fopen( filelist );
        formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
        lista    = formcell{:};
        lista    = strtrim(lista); % this fixes the bag described by Darren Tanner and Katherine Stavropoulos
        nfile    = length(lista);
        fclose(fid_list);
    else
        error('ERPLAB says: error at pop_appenderp(). Unrecognizable input ')
    end
end

%filelist    = p.Results.Loadlist;
artcrite    = p.Results.Criterion;

if ismember_bc2({p.Results.SEM}, {'on','yes'})
    stderror = 1;
else
    stderror = 0;
end
if ismember_bc2({p.Results.ExcludeNullBin}, {'on','yes'})
    exclunullbin = 1;
else
    exclunullbin = 0;
end
if ismember_bc2({p.Results.Weighted}, {'on','yes'})
    wavg = 1;
else
    wavg = 0;
end
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas = 1;
else
    issaveas = 0;
end
if ismember_bc2({p.Results.Warning}, {'on','yes'})
    warn = 1;
else
    warn = 0;
end
if iserpstruct(ALLERP);
    if isempty(erpset) && isempty(filelist)
        error('ERPLAB:pop_gaverager', '\nERPLAB says: Erpsets is empty')
    end
else
    if isempty(filelist)
        error('ERPLAB:pop_gaverager', '\nERPLAB says: Loadlist is empty (ALLERP is empty as well...)\n')
    end
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


% check DQ - are all requested measures present?
DQ_flag = p.Results.DQ_flag;
% If loading from text file list, load the ERPs back in to Temp-ALLERP
if optioni==1  && DQ_flag % if from text file
    try % try loading, report if error, and drop dq
        for s = 1:nfile
            %fprintf('Loading %s...\n', lista{s});
            
            ERPTX = load(lista{s}, '-mat');
            TALLERP(s) = ERPTX.ERP;
            
        end
    catch
        warning('Data quality measures not found in all these ERPsets. Setting DQ_flag = 0');
        DQ_flag = 0;
    end
end
if DQ_flag
    DQ_spec = p.Results.DQ_spec;
    try
        if optioni==0   % if not loaded from text file list
            DQ_ok = check_DQ_measures(ALLERP(erpset),DQ_spec.measure_names(DQ_spec.measures));
        else
            DQ_ok = check_DQ_measures(TALLERP,DQ_spec.measure_names(DQ_spec.measures));
        end
        
    catch
        DQ_ok = 0;
    end
    if DQ_ok==0
        warning('Issue with Grand Averager DQ specification?')
        DQ_spec = [];
    end
else
    DQ_spec = [];
end




%
% subroutine
%
ERPaux = ERP;
[ERP, serror, msgboxText ] = gaverager(ALLERP, lista, optioni, erpset, nfile, wavg, stderror, artcrite, exclunullbin, warn, DQ_spec);

if serror>0
    title = 'ERPLAB: gaverager() Error';
    errorfound(msgboxText, title);
    return
end

% ! Verificar que cada archivo en lista{j} exista
% Verify that each file in the list exists

%
% Completion statement
%
msg2end

% Construct the History string
% load with the appropriate input args
skipfields = {'ALLERP', 'Saveas', 'Warning','History'};
if isstruct(ALLERP) && optioni~=1 % from files
    DATIN =  inputname(1);
else
    %DATIN = ['''' ALLERP ''''];
    DATIN = sprintf('''%s''', filelist);
    skipfields = [skipfields, 'Erpsets'];
end
if isfield(p.Results,'DQ_spec') == 0 || isempty(p.Results.DQ_spec)
    skipfields = [skipfields 'DQ_spec'];  % skip DQ spec in History if it was absent
end
fn     = fieldnames(p.Results);
erpcom = sprintf( 'ERP = pop_gaverager( %s ', DATIN);
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        % Examine the variable type for the argument used, load that in to
        % the History string appropriately
        arg_value_here = fn2res;
        if isempty(arg_value_here)
            write_this_one = 0;
        else
            if ischar(arg_value_here)
                if strcmpi(fn2res,'off')
                    write_this_one = 0;
                end
            else
                write_this_one = 1;
            end
        end
        
        if write_this_one  % if an argument value is not empty
            
            if ischar(fn2res)
                fnformat = '%s'; fn2resstr = fn2res;
            elseif isnumeric(fn2res)
                fn2resstr = num2str(fn2res); fnformat = '%s';
            elseif isstruct(fn2res)
                fn2resstr = 'DQ_spec_structure'; fnformat = '%s';
            elseif iscell(fn2res)
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
                if strcmpi(fn2com,'Erpsets') %ams fixed for Erpsets str
                    erpcom = sprintf( ['%s, ''%s'', [', fnformat,']'], erpcom, fn2com, fn2resstr);
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
        ERP = ERPaux;
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end
% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        ERP = erphistory(ERP, [], erpcom, 1);
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return
