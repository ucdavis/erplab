% PURPOSE  :	Filters ERP data
%
% FORMAT   :
%
% ERP = pop_filterp(ERP,  chanArray, parameters)
%
%
% INPUTS   :
%
% ERP        - input ERPset
% chanArray  - channel(s) to filter
%
% The available parameters are as follows:
%
% 'Cutoff'   - cutoff frequencies [highpass lowpass]
% 'Order'    - length of the filter in points {default 3*fix(srate/locutoff)}
% 'Design'   - type of filter. 'butter'=IIR Butterworth,'fir'=windowed linear-phase FIR; 'notch'=PM Notch
% 'Filter'   - 'bandpass'= band-pass; 'lowpass'=Low pass (attenuate high frequency).
%              'highpass'= high-pass (attenuate low frequency)
%              'PMnotch' = (stop-band) Parks-McClellan Notch.
% 'RemoveDC' - remove mean value (DC offset) before filtering. 'on'/'off'
%
%
% OUTPUTS  :
%
% ERP        - filtered ERPset
%
%
% EXAMPLE  :
%
% ERP = pop_filterp( ERP, 1:16 , 'Cutoff', [ 0.1 124.5], 'Design', 'butter', 'Filter', 'bandpass', 'Order', 2 );
%
%
% See also basicfilterGUI2 filterp.m
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

function [ERP, erpcom] = pop_filterp(ERP,  chanArray, varargin)
erpcom = '';
if exist('filtfilt','file')~= 2
    msgboxText =  'Cannot find the signal processing toolbox';
    title = 'ERPLAB: pop_filterp() error';
    errorfound(msgboxText, title);
    return
end
if nargin < 1
    help pop_filterp
    return
end
if isempty(ERP)
    msgboxText =  'Cannot filter an empty erpset';
    title = 'ERPLAB: pop_filterp() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ERP(1).bindata)
    msgboxText =  'Cannot filter an empty erpset';
    title = 'ERPLAB: pop_filterp() error';
    errorfound(msgboxText, title);
    return
end
datatype = checkdatatype(ERP(1));
if nargin==1
    if ~strcmpi(datatype, 'ERP')
        msgboxText =  'Cannot filter Power Spectrum waveforms!';
        title = 'ERPLAB: pop_filterp() error';
        errorfound(msgboxText, title);
        return
    end
    nchan = ERP.nchan;
    defx = {0 30 2 1:nchan 1 'butter' 0 []};
    def  = erpworkingmemory('pop_filterp');
    
    if isempty(def)
        def = defx;
    else
        def{4} = def{4}(ismember_bc2(def{4},1:nchan));
    end
    
    %
    % Opens a GUI
    %
    answer = basicfilterGUI2(ERP, def);
    
    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    
    locutoff    = answer{1}; % for high pass filter
    hicutoff    = answer{2}; % for low pass filter
    filterorder = answer{3};
    chanArray   = answer{4};
    filterallch = answer{5};
    fdesign     = answer{6};
    remove_dc   = answer{7};
    
    if filterallch
        chanArray = 1:nchan;
    end
    
    erpworkingmemory('pop_filterp', answer(:)');
    
    if remove_dc==1
        rdc = 'on';
    else
        rdc = 'off';
    end
    if ~strcmpi(fdesign, 'notch') && locutoff==0 && hicutoff>0  % Butter (IIR) and FIR
        ftype = 'lowpass';
        cutoff = hicutoff;
    elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff==0 % Butter (IIR) and FIR
        ftype = 'highpass';
        cutoff = locutoff;
    elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff>0 && locutoff<hicutoff% Butter (IIR) and FIR
        ftype = 'bandpass';
        cutoff = [locutoff hicutoff];
    elseif ~strcmpi(fdesign, 'notch') && locutoff>0 && hicutoff>0 && locutoff>hicutoff% Butter (IIR) and FIR
        ftype = 'simplenotch';
        cutoff = [locutoff hicutoff];
    elseif ~strcmpi(fdesign, 'notch') && locutoff==0 && hicutoff==0 % Butter (IIR) and FIR
        msgboxText =  'I beg your pardon?';
        title = 'ERPLAB: basicfilter() !';
        errorfound(msgboxText, title);
        return
    elseif strcmpi(fdesign, 'notch') && locutoff==hicutoff % Parks-McClellan Notch
        ftype = 'PMnotch';
        cutoff = hicutoff;
    else
        error('ERPLAB says: Invalid type of filter ')
    end
    
    %
    % Somersault
    %
    [ERP, erpcom] = pop_filterp( ERP, chanArray, 'Filter',ftype, 'Design',  fdesign, 'Cutoff', cutoff, 'Order', filterorder, 'RemoveDC', rdc,...
        'Saveas', 'on', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('chanArray', @isnumeric);
% option(s)
p.addParamValue('Filter', 'lowpass',@ischar);
p.addParamValue('Design', 'butter', @ischar);
p.addParamValue('Cutoff', 30, @isnumeric);
p.addParamValue('Order', 2, @isnumeric);
p.addParamValue('RemoveDC', 'off', @ischar);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, chanArray, varargin{:});

filtp   = p.Results.Filter;
fdesign = p.Results.Design;
filco   = p.Results.Cutoff;

if ~strcmpi(datatype, 'ERP')
        msgboxText =  'Cannot filter Power Spectrum waveforms!';
        error(msgboxText);
end
if strcmpi(filtp, 'lowpass')
    if length(filco)~=1
        error('ERPLAB says: For lowpass filter,  ONE cutoff value is requiered.')
    end
    locutoff    = 0; % for high pass filter
    hicutoff    = filco; % for low pass filter
elseif strcmpi(filtp, 'highpass')
    if length(filco)~=1
        error('ERPLAB says: For highpass filter,  ONE cutoff value is requiered.')
    end
    locutoff    = filco; % for high pass filter
    hicutoff    = 0; % for low pass filter
elseif strcmpi(filtp, 'bandpass')
    if length(filco)~=2
        error('ERPLAB says: For bandpass filter,  TWO cutoff values are requiered.')
    end
    locutoff    = filco(1); % for high pass filter
    hicutoff    = filco(2); % for low pass filter
elseif strcmpi(filtp, 'simplenotch')
    if length(filco)~=2
        error('ERPLAB says: For simple notch filter,  TWO cutoff values are requiered.')
    end
    locutoff    = filco(1); % for high pass filter
    hicutoff    = filco(2); % for low pass filter
elseif strcmpi(filtp, 'PMnotch')
    if length(filco)~=1
        error('ERPLAB says: For Parks-McClellan notch (PMnotch) filter,  ONE cutoff value is requiered.')
    end
    locutoff    = filco; % for high pass filter
    hicutoff    = filco; % for low pass filter
else
    error('ERPLAB says: Invalid type of filter. (Valid options: ''lowpass'', ''highpass'', ''bandpass'', ''simplenotch'', ''PMnotch'' )')
end
filterorder = p.Results.Order;
if strcmpi(p.Results.RemoveDC, 'on')
    remove_dc   = 1;
else
    remove_dc   = 0;
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
if mod(filterorder,2)~=0
    error('ERPLAB says: filter order must be an even number because of the forward-reverse filtering.')
end
if ERP.pnts <= 3*filterorder
    msgboxText{1} =  'The length of the data must be more than three times the filter order.';
    title = 'ERPLAB: pop_filterp() & filtfilt constraint';
    errorfound(msgboxText, title);
    return
end
numchan = length(chanArray);
iserrch = 0;
if iserpstruct(ERP)
    if numchan>ERP.nchan
        iserrch = 1;
    end
else
    msgboxText =  ['Unknow data structure.\n'...
        'pop_filterp() only works with ERP structure.'];
    title = 'ERPLAB: pop_filterp() error:';
    errorfound(sprintf(msgboxText), title);
    return
end
if iserrch
    msgboxText =  'You do not have such amount of channels in your data!';
    title = 'ERPLAB: pop_filterp() error:';
    errorfound(msgboxText, title);
    return
end
[ax, tt] = ismember_bc2(lower(fdesign),{'butter' 'fir' 'notch'});
if tt>0
    fdesignnum = tt-1;
else
    error('ERPLAB says: Unrecognizable filter type. See help pop_filterp')
end
if locutoff == 0 && hicutoff == 0
    disp('I beg your pardon?')
    return
end

%
% subroutine
%
options = { chanArray, locutoff, hicutoff, filterorder, fdesignnum, remove_dc};
ERPaux  = ERP; % store original ERP
ERP     = filterp(ERP, options{:});
ERP.saved  = 'no';

if ~isfield(ERP, 'binerror')
    ERP.binerror = [];
end

%
% History
%
%
% Completion statement
%
msg2end

%
% History
%
chanArraystr = vect2colon(chanArray);
skipfields = {'ERP', 'chanArray', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_filterp( %s, %s ', inputname(1), inputname(1), chanArraystr);
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
                    fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                    fnformat = '{%s}';
                else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
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
        ERP = ERPaux;
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
        %mcolor = [1 0.22 0.2];
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