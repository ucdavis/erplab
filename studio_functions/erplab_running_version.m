% PURPOSE :




function erplab_running_version(varargin)
erpcom = '';
if nargin < 1
    help erplab_running_version
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;

p.addParamValue('version', []); % erpset index or input file
p.addParamValue('tooltype', ''); % 'on', 'off'

p.parse(varargin{:});

if ~isempty(p.Results.tooltype)
    erplab_session_state('set', 'tooltype', p.Results.tooltype);
end

if ~isempty(p.Results.version)
    erplab_session_state('set', 'version', p.Results.version);
end

% erpcom = char(strcat());

fn     = fieldnames(p.Results);
erpcom = sprintf( '%s erplab_running_version( %s ', inputname(1), inputname(1) );

for q=1:length(fn)
    
    fn2com = fn{q};
    fn2res = p.Results.(fn2com);
    if ~isempty(fn2res)
        if ischar(fn2res)
            
            erpcom = sprintf( '%s ''%s'', ''%s''', erpcom, fn2com, fn2res);
        else
            if isnumeric(fn2res)
                fn2resstr = char(num2str(fn2res));
                fnformat = '%s';
                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
            end
            
        end
    end
    
end

erpcom = sprintf( '%s );', erpcom);
ALLERPCOM = [];
if isempty(ALLERPCOM)
    ALLERPCOM{1} = erpcom;
else
    ALLERPCOM{length(ALLERPCOM)+1} = erpcom; 
end

assignin('base','ALLERPCOM',ALLERPCOM);

assignin('base','ERPCOM',erpcom);%Send the history to Matlab workspace
% get history from script. ERP

displayEquiComERP(erpcom);

return
