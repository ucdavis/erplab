function [ERP, erpcom] = pop_saveERPhistory(ERP, filename, varargin)
erpcom = '';
if nargin < 1
        help pop_saveERPhistory
        return
end
if nargin==1
        if ~isfield(ERP, 'history')
                msgboxText = 'ERP.history was not found!';
                title = 'ERPLAB: pop_saveERPhistory() error';
                errorfound(sprintf(msgboxText), title);
                return
        end
        
        %
        % Save OUTPUT file
        %
        [fname, pathname] = uiputfile({...
                '*.m','MATLAB File (*.m)';...
                '*.txt','Text (*.txt)';...
                '*.*',  'All Files (*.*)'},...
                'Save current ERPset command history as');
        
        if isequal(fname,0)
                disp('User selected Cancel')
                return
        else
                [xpath, fname, ext] = fileparts(fname);
                
                if isempty(ext)
                        ext = '.m';
                end
                
                fname  = [fname ext];
                filename = fullfile(pathname, fname);
                disp(['For EVENTLIST output user selected ', filename])
        end
        %
        % Somersault
        %
        [ERP, erpcom] = pop_saveERPhistory(ERP, filename, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('filename', @ischar);
% option(s)
% p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERP, filename, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
% if ismember_bc2({p.Results.Saveas}, {'on','yes'})
%         saveas  = 1;
% else
%         saveas  = 0;
% end

if isempty(filename)
        msgboxText = 'ERPLAB says: Invalid file name!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
elseif ~isempty(filename) && ~ischar(filename)
        msgboxText = 'ERPLAB says: Invalid file name!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);end
if ~isfield(ERP, 'history')
        msgboxText = 'ERPLAB says: ERP.history was not found!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end

%
% Save ERP.history
%
erpcomArray = ERP.history;
fid = fopen(filename, 'w');
if fid == -1
        error('ERPLAB says: error creating the file');
end;

fprintf(fid, '%% ERPLAB history file generated on %s\n', date);
fprintf(fid, '%% ---------------------------------------------\n');

if ~iscell(erpcomArray)
        erpcomArray = cellstr(erpcomArray);
end
erpcomArray = regexprep(erpcomArray, 'EEG\s*=\s*eeg_checkset\(\s*EEG\s*\);','');
fprintf('Saving %s command history...\n', ERP.erpname);
for k = 1:length(erpcomArray)
        fprintf(fid, '%s\n', erpcomArray{k});
end;
fclose(fid);
erpcom = sprintf('%s = pop_saveERPhistory(%s, ''%s'');', inputname(1), inputname(1), filename);
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