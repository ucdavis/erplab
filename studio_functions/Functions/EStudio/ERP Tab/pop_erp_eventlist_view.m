% PURPOSE:  pop_erp_eventlist_view.m
%           display eventlist

% FORMAT:
% [ALLERP, erpcom] = pop_erp_eventlist_view( ALLERP, 'ERPArray',ERPArray,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLERP           -ALLERP structure
%ERPArray         -index(es) of eegsets



% *** This function is part of ALLERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% May 2024




function [ALLERP, erpcom] = pop_erp_eventlist_view(ALLERP, varargin)
erpcom = '';

if nargin < 1
    help pop_erp_eventlist_view
    return
end
if isempty(ALLERP)
    msgboxText =  'Cannot handle an empty EEGset';
    title = 'ERPLAB: pop_erp_eventlist_view() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLERP(1))
    msgboxText =  'Cannot handle an empty EEGset';
    title = 'ERPLAB: pop_erp_eventlist_view() error';
    errorfound(msgboxText, title);
    return
end



if nargin==1
    ERPArray = [1:length(ALLERP)];
    [ALLERP, erpcom] = pop_erp_eventlist_view( ALLERP, 'ERPArray',ERPArray,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
% option(s)
p.addParamValue('ERPArray', [],@isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLERP, varargin{:});


ERPArray = p.Results.ERPArray;

if isempty(ERPArray) || any(ERPArray(:)>length(ALLERP)) || any(ERPArray(:)<1)
    ERPArray = [1:length(ALLERP)];
end


feval("ERP_evenlist_gui",ALLERP(ERPArray));


if strcmpi(p.Results.Saveas,'on')
    issaveas = 1;
else
    issaveas = 0;
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




%
% History
%

skipfields = {'ALLERP', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_erp_eventlist_view( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                end
            else
                erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

%
% Save ALLERPset from GUI
%
if issaveas
    for ii = 1:length(ALLERP)
        ERP = ALLERP(ii);
        [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');
        if issave>0
            %                 erpcom = sprintf( '%s = pop_filterp( %s, %s, %s, %s, %s, ''%s'', %s);', inputname(1), inputname(1),...
            %                         chanArraystr, num2str(locutoff), num2str(hicutoff),...
            %                         num2str(filterorder), lower(fdesign), num2str(remove_dc));
            %                 erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            if issave==2
                erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                msgwrng = '*** Your ERPset was saved on your hard drive.***';
                %mcolor = [0 0 1];
            else
                msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
                %mcolor = [1 0.52 0.2];
            end
        else
            %             ERP = ERPaux;
            msgwrng = 'ERPLAB Warning: Your changes were not saved';
            %mcolor = [1 0.22 0.2];
        end
        try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
    end
end


% get history from script. ALLERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for i=1:length(ERPArray)
            ALLERP(ERPArray(i)) = erphistory(ALLERP((ERPArray)), [], erpcom, 1);
        end
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return