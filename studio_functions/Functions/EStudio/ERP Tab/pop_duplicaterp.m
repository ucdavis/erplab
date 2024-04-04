% PURPOSE:  pop_duplicaterp.m
%           duplicate ERPset
%

% FORMAT:
% [ERP, erpcom] = pop_duplicaterp( ERP, 'ChanArray',ChanArray, 'BinArray',BinArray,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ERP           -ERP structure
%ChanArray   -index(es) of channels
%BinArray     -index(es) of bins



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec. 2024




function [ERP, erpcom] = pop_duplicaterp(ERP, varargin)
erpcom = '';

if nargin < 1
    help pop_duplicaterp
    return
end
if isempty(ERP)
    msgboxText =  'Cannot duplicate an empty erpset';
    title = 'ERPLAB: pop_duplicaterp() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ERP(1).bindata)
    msgboxText =  'Cannot duplicate an empty erpset';
    title = 'ERPLAB: pop_duplicaterp() error';
    errorfound(msgboxText, title);
    return
end

datatype = checkdatatype(ERP(1));
if ~strcmpi(datatype, 'ERP')
    msgboxText =  'Cannot duplicate Power Spectrum waveforms!';
    title = 'ERPLAB: pop_duplicaterp() error';
    errorfound(msgboxText, title);
    return
end

if length(ERP)>1
    msgboxText =  'Cannot duplicate multiple ERPsets!';
    title = 'ERPLAB: pop_duplicaterp() error';
    errorfound(msgboxText, title);
    return
end
if nargin==1
    
    def   = erpworkingmemory('pop_duplicaterp');
    if isempty(def)
        def = {[],[]};
    end
    BinArray = def{1};
    ChanArray =def{2};
    
    def =  f_ERP_duplicate(ERP,BinArray,ChanArray);
    if isempty(def)
        return;
    end
    ChanArray = def{2};
    BinArray = def{1};
    erpworkingmemory('pop_duplicaterp',def);
    %
    % Somersault
    %
    [ERP, erpcom] = pop_duplicaterp( ERP, 'ChanArray',ChanArray, 'BinArray',BinArray,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
% option(s)
p.addParamValue('ChanArray', [],@isnumeric);
p.addParamValue('BinArray', [], @isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, varargin{:});

ChanArray = p.Results.ChanArray;
if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<=0)
    ChanArray = [1:ERP.nchan];
end

BinArray= p.Results.BinArray;
BinArray = unique(BinArray);
if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<=0)
    BinArray = [1:ERP.nbin];
end


ERP.bindata = ERP.bindata(ChanArray,:,BinArray);
if ~isempty(ERP.binerror)
    ERP.binerror = ERP.binerror(ChanArray,:,BinArray);
end
try
    ERP.ntrials.accepted  = ERP.ntrials.accepted(BinArray);
    ERP.ntrials.rejected = ERP.ntrials.rejected(BinArray);
    ERP.ntrials.invalid = ERP.ntrials.invalid(BinArray);
    ERP.ntrials.arflags = ERP.ntrials.arflags(BinArray,:);
catch
end
ERP.nbin = numel(BinArray);
ERP.nchan = numel(ChanArray);
ERP.chanlocs = ERP.chanlocs(ChanArray);
for Numofbin = 1:numel(BinArray)
    Bindescr{Numofbin}  = ERP.bindescr{BinArray(Numofbin)};
end
ERP.bindescr = Bindescr;

%%---------------------empty eventlist-------------------------------------
ERP.EVENTLIST = [];

%%---------------------dataquality-----------------------------------------
try
   for ii = 1:3
      if ~isempty( ERP.dataquality(ii).data)
         ERP.dataquality(ii).data = ERP.dataquality(ii).data(ChanArray,:,BinArray);  
      end
   end
catch 
end

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


ERP.saved  = 'no';

%
% History
%

skipfields = {'ERP', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_duplicaterp( %s ', inputname(1), inputname(1) );
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
% Save ERPset from GUI
%
if issaveas
    [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');
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