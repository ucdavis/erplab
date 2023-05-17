% PURPOSE  : 	Import ERP from ERPSS Text file format
%
% FORMAT   :
%
% ERP = pop_importerpss_studio(parameters);
%
% The available parameters are as follows:
%
%    'Filename'     - ERPSS Text file
%    'Format'       - 'explicit'/'implicit'
%    'Pointat'      - 'col'/'row'
%    'Saveas'       - 'on'/'off'
%
% EXAMPLE 1  : Load a single ERPset
%
% ERP = pop_importerpss_studio('Filename', {'/Users/etfoo/Documents/MATLAB/ERP_ERPSS_test.txt'}, 'Format', 'implicit', 'Pointat', 'row');
%
% EXAMPLE 2  : Load two ERPsets (ALLERP will store both; ERP will store the last one)
%
% [ ERP ALLERP ]  = pop_importerpss_studio('Filename', {'/Users/etfoo/Documents/MATLAB/ERP_ERPSS_test1.txt' '/Users/etfoo/Documents/MATLAB/ERP_ERPSS_test2.txt'},...
%                                                'Format', 'implicit', 'Pointat', 'row');
%
%
% OUTPUTS  :
%
% ERP and/or ALLERP
%
%
% See also importERPSS_GUI.m importerpss2.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Eric Foo & Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009 & 2022

function [ERP, ALLERP, erpcom] = pop_importerpss_studio(varargin)
erpcom   = '';
ERP      = preloadERP;
errorf   = 0;
ALLERP   = preloadALLERP;
preindex = length(ALLERP);
if nargin<1
    
    %
    % call GUI
    %
    answer = importERPSS_GUI; %(gui was modified)
    
    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    
    fname      = answer{1}; % filename (+ whole path)
    dformat    = answer{2}; % data format
    dtranspose = answer{3}; % transpose data  (Fixed)
    
    if dformat==0
        dformatstr = 'explicit'; % points at columns
    else
        dformatstr = 'implicit'; % points at rows
    end
    if dtranspose==0
        orienpoint = 'column';   % points at columns
    else
        orienpoint = 'row';      % points at rows
    end
    
    %
    % Somersault
    %
    [ERP, ALLERP, erpcom] = pop_importerpss_studio('Filename', fname, 'Format', dformatstr, 'Pointat', orienpoint, 'History', 'gui');
    pause(0.1);
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% option(s)
p.addParamValue('Filename', '');
p.addParamValue('Format', 'explicit', @ischar);
p.addParamValue('Pointat', 'col', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(varargin{:});

filename = p.Results.Filename;

if strcmpi(p.Results.Format, 'explicit');
    dformat = 0;
else
    dformat = 1;
end
if ismember_bc2({lower(p.Results.Pointat)}, {'col','column','columns'});
    dtranspose = 0;
elseif ismember_bc2({lower(p.Results.Pointat)}, {'row','rows'});
    dtranspose = 1;
else
    error('ERPLAB says: ?')
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
if iscell(filename) % filename fixed. JLC
    nfile      = length(filename);
else
    nfile = 1;
    filename = cellstr(filename);
end
auxALLERP = ALLERP;
ERPaux    = ERP;

%
% load ERPsets(s)
%
fprintf('\n');
for i=1:nfile
    try
        fname = filename{i}; % pointer "i" fixed. JLC
        fprintf('%g) Importing ''%s'' into ERPLAB...Please wait...\n', i, fname);
        
        %
        % subroutine
        %
        [ERP, serror] = importerpss2(fname, dformat, dtranspose);
        
        try%Remove the bin with Caliration GH 2022
            if strcmp(ERP.bindescr{1},'Calibration')
                for Numofbin =2:ERP.nbin
                    Bindescr{Numofbin-1} = ERP.bindescr{Numofbin};
                end
                ERP.bindescr =Bindescr;
                ERP.nbin = ERP.nbin-1;
                ERP.bindata = ERP.bindata(:,:,[2:end]);
            end
        catch
            ERP =ERP;
        end
        
        if serror
            break
        end
    catch %#ok<*CTCH>
        serror =1;
        break
    end
    checking = checkERP(ERP);
    try
        if checking
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                try
                    ALLERPCOM = evalin('base', 'ALLERPCOM');
                catch
                    ALLERPCOM =[];
                end
                Answer = f_ERP_save_single_file(ERP.erpname,ERP.filename,length(ALLERP)+1);
                
                if isempty(Answer)
                    beep;
                    disp('User selected cancel!!!');
                    return;
                end
                if ~isempty(Answer{1})
                    ERP.erpname = char(Answer{1});
                end
                try
                    if ~isempty(Answer{2})
                        fileName_full = Answer{2};
                        [pathstr, file_name, ext] = fileparts(fileName_full);
                        
                        if strcmp(pathstr,'')
                            pathstr = cd;
                        end
                        ERP.filename = [file_name,'.erp'];
                        ERP.filepath = pathstr;
                        %%----------save the current sdata as--------------------
                        [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                        [~, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
                    else
                        ERP.filename = ERP.erpname;
                        %                         ERP =ERP;
                    end
                catch
                    beep;
                    disp('There exists error when save current ERP in pop_importerpss_studio()');
                    return;
                end%%End changed by Guanghui
                
                if i==1 && isempty(ALLERP)
                    ALLERP = buildERPstruct([]); %#ok<NASGU>
                    ALLERP = ERP;
                else
                    ALLERP(i+preindex) = ERP;
                end
                assignin('base','ALLERP',ALLERP);  % save to workspace
                %                 updatemenuerp(ALLERP);
            catch
                beep;
                disp('There exists error when save current ERP in pop_importerpss_studio()');
                return;
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             if i==1 && isempty(ALLERP);
            %                 ALLERP1 = buildERPstruct([]); %#ok<NASGU>
            %                 ALLERP = ERP;
            %             else
            %                 ALLERP(i+preindex) = ERP;
            %             end
        else
            errorf = 1;
            break
        end
    catch %#ok<CTCH>
        errorf = 1; % fatal error
        break
    end
end
if serror
    msgboxText = ['Oops! Something went wrong reading your file.\n'...
        'Please verify the ascii file or double check your settings for importing.'];
    title = 'ERPLAB: pop_importerpss_studio() inputs';
    errorfound(sprintf(msgboxText), title);
    ALLERP = auxALLERP;
    ERP    = ERPaux;
    return
elseif errorf
    msgboxText = ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
        'Please, try upgrading your ERP structure.'];
    title = 'ERPLAB: pop_importerpss_studio() Error';
    errorfound(sprintf(msgboxText, ERP.filename), title);
    ALLERP = auxALLERP;
    ERP    = ERPaux;
    return
end
fprintf('\n');

if shist==1 % update erpset menu at main gui. JLC. For Antigona M.
    assignin('base','ALLERP',ALLERP);  % save to workspace
    %     updatemenuerp(ALLERP);             % add a new erpset to the erpset menu
end

%
% Completion statement
%
% msg2end

%
% History
%
skipfields = {'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( ' ERP = pop_importerpss_studio(');
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
erpcom = strrep(erpcom, '(,','(');
% if issaveas
%       [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
%       if issave>0
%             % generate text command
%             if issave==2
%                   erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
%                   msgwrng = '*** Your ERPset was saved on your hard drive.***';
%             else
%                     msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
%             end
%             fprintf('\n%s\n\n', msgwrng)
%             try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
%       else
%               ALLERP  = auxALLERP;
%               ERP     = ERPaux;
%               msgwrng = 'ERPLAB Warning: Your changes were not saved';
%               try cprintf([1 0.52 0.2], '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
%       end

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
%
% Completion statement
%
msg2end
return

