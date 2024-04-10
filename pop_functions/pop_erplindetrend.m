% PURPOSE  : 	Remove linear trends from each bin of an ERPset
%
% FORMAT   :
%
% ERP = pop_erplindetrend( ERP,'Baseline',  detwindow );
%
% INPUTS   :
%
% ERP           - input ERPset
% Interval      - time window to estimate the trend. This trend will be subtracted from the whole epoch.
%                 'pre'- [-200 0], 'post'-[0 798], 'whole'-[-200 798]
%
% OUTPUTS  :
%
% ERP           - (updated) output ERPset
%
%
% EXAMPLE  :
% ERP = pop_erplindetrend( ERP, 'Baseline', 'post');
% ERP = pop_erplindetrend( ERP,'Baseline',  '0 798');
% ERP = pop_erplindetrend( ERP, 'Baseline', [0 798]);
%
% See also blcerpGUI.m lindetrend.m
%
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

function [ERP, erpcom] = pop_erplindetrend( ERP, varargin)
erpcom = '';
if nargin < 1
    help pop_erplindetrend
    return
end
if isfield(ERP(1), 'datatype')
    datatype = ERP.datatype;
else
    datatype = 'ERP';
end
if nargin==1
    title_msg  = 'ERPLAB: pop_erplindetrend() error:';
    if isempty(ERP)
        ERP = preloadERP;
        if isempty(ERP)
            msgboxText =  'No ERPset was found!';
            
            errorfound(msgboxText, title_msg);
            return
        end
    end
    if ~strcmpi(datatype, 'ERP')
        msgboxText =  'Cannot detrend Power Spectrum waveforms. Sorry';
        errorfound(msgboxText, title_msg);
        return
    end
    def  = erpworkingmemory('pop_erplindetrend');
    if isempty(def)
        def = {'pre'};
    end
    
    %
    % Call GUI
    %
    titlegui = 'Linear Detrend';
    answer = blcerpGUI(ERP, titlegui, def);
    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    detwindow = answer{1};
    erpworkingmemory('pop_erplindetrend', detwindow);
    ChanArray = answer{2};
    BinArray = answer{3};
    %
    % Somersault
    %
    [ERP, erpcom] = pop_erplindetrend(ERP,'Baseline',  detwindow,'ChanArray',ChanArray,...
        'BinArray',BinArray, 'Warning', 'on', 'Saveas', 'on','ErrorMsg', 'popup', 'History', 'gui');
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
p.addParamValue('Baseline', 'pre');
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('ChanArray', [], @isnumeric);
p.addParamValue('BinArray', [], @isnumeric);
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('ErrorMsg', 'cw', @ischar); % cw = command window
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, varargin{:});

if strcmpi(p.Results.Warning,'on')
    wchmsgon = 1;
else
    wchmsgon = 0;
end
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
if strcmpi(p.Results.ErrorMsg,'popup')
    errormsgtype = 1; % open popup window
else
    errormsgtype = 0; % error in red at command window
end


ChanArray = p.Results.ChanArray;
if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
    ChanArray = [1:ERP.nchan];
end


BinArray = p.Results.BinArray;
if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
    BinArray = [1:ERP.nbin];
end
detwindow   = p.Results.Baseline;

if ischar(detwindow)
    if ~strcmpi(detwindow,'all') && ~strcmpi(detwindow,'pre') && ~strcmpi(detwindow,'post') && ~strcmpi(detwindow,'none')
        internum = str2num(detwindow);
        if length(internum)~=2
            msgboxText = 'Wrong interval. Linear detrending will not be performed.';
            title = 'ERPLAB: pop_erplindetrend() error';
            errorfound(msgboxText, title);
            return
        end
        detwindowstr = ['[ ' num2str(internum) ' ]'];
    else
        detwindowstr = ['''' detwindow ''''];
    end
else
    if length(detwindow)~=2
        msgboxText = 'Wrong interval. Linear detrending will not be performed.';
        title = 'ERPLAB: pop_erplindetrend() error';
        errorfound(msgboxText, title);
        return
    end
    detwindowstr = ['[ ' num2str(detwindow) ' ]'];
end

ERPaux = ERP;

%
% subroutine
%
ERP = lindetrend( ERP, detwindow);


ChanArrayleft = setdiff([1:ERP.nchan],ChanArray);%% channles are not for baseline correction
if ~isempty(ChanArrayleft)
    ERP.bindata(ChanArrayleft,:,:)  = ERPaux.bindata(ChanArrayleft,:,:);
end


BinArrayleft = setdiff([1:ERP.nbin],BinArray);%% channles are not for baseline correction
if ~isempty(BinArrayleft)
    ERP.bindata(:,:,BinArrayleft)  = ERPaux.bindata(:,:,BinArrayleft);
end


%
% Completion statement
%
msg2end
ERP.saved = 'no';


skipfields = {'ERP', 'History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_erplindetrend( %s ', inputname(1), inputname(1) );
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


if issaveas
    [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'off');
    if issave>0
        if issave==2
            erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your ERPset was saved on your hard drive.***';
            mcolor = [0 0 1];
        else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
            mcolor = [1 0.52 0.2];
        end
    else
        ERP = ERPaux;
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
        mcolor = [1 0.22 0.2];
    end
    try cprintf(mcolor, '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
end
% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        ERP = erphistory(ERP, [], erpcom, 1);
    case 3
        % implicit
        %ERP = erphistory(ERP, [], erpcom, 1);
        %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
    otherwise %off or none
        erpcom = '';
end
return

