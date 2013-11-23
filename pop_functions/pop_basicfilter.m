% PURPOSE  : Filters EEG data
%
% FORMAT   :
%
% EEG = pop_basicfilter( EEG, chanArray, parameters );
%
% INPUTS   :
%
% EEG           - input dataset
% chanArray     - channel index(es) where the filter will be applied.
%
% The available parameters are as follows:
%
%     'Filter'      - 'bandpass'- Band pass.
%                     'lowpass' - Low pass (attenuate high frequency).
%                     'highpass'- High pass (attenuate low frequency.
%                     'PMnotch' - stop-band Parks-McClellan Notch.
%     'Design'      - type of filter. 'butter' = IIR Butterworth,'fir'= windowed FIR
%     'Cutoff'      - lower cutoff (high-pass) pass and higher cuttof (low-pass) in the format [lower higher]
%     'Order'       - length of the filter in points {default 3*fix(srate/locutoff)}
%     'RemoveDC'    - remove mean value (DC offset) before filtering. 'on'/'off'
%     'Boundary'    - specify boundary event code. e.g 'boundary'
%
%
% OUTPUTS  :
%
% EEG           - updated output dataset
%
% EXAMPLE  :
%
% ERP = pop_averager(ALLEEG, 'Criterion', 'good', 'DSindex', 19, 'Stdev', 'on');
%
%
% See also averagerGUI.m averager.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon and Steven Luck
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
%
% Bugs:
% # 1: May 1, 2012. Command for history fixed. Thanks Vaughn R. Steele

function [EEG, com] = pop_basicfilter( EEG, chanArray, varargin)
com = '';
if exist('filtfilt','file') ~= 2
        msgboxText =  'cannot find the signal processing toolbox';
        title = 'ERPLAB: pop_basicfilter() error';
        errorfound(msgboxText, title);
        return
end
if nargin < 1
        help pop_basicfilter
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'cannot filter an empty dataset';
                title = 'ERPLAB: pop_basicfilter() error';
                errorfound(msgboxText, title);
                return
        end
        if iserpstruct(EEG(1)) % for erpset
                nchan = EEG(1).nchan;
        else
                nchan = EEG(1).nbchan;
        end
        
        defx = {0 30 2 1:nchan 1 'butter' 0 []};
        def  = erpworkingmemory('pop_basicfilter');
        
        if isempty(def) && isempty(EEG(1).epoch) % continuos
                def = defx;
                def{end} = 'boundary';
        elseif isempty(def) && ~isempty(EEG(1).epoch) % epoched
                def = defx;
        else % got memory!
                def{4} = def{4}(ismember_bc2(def{4},1:nchan));
        end
        
        %
        % Opens a GUI
        %
        answer = basicfilterGUI2(EEG(1), def);
        
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
        boundary    = answer{8};
        
        if filterallch
                chanArray = 1:nchan;
        end
        erpworkingmemory('pop_basicfilter', answer(:)');
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
        if length(EEG)==1
                EEG.setname = [EEG.setname '_filt'];
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_basicfilter( EEG, chanArray, 'Filter',ftype, 'Design',  fdesign, 'Cutoff', cutoff, 'Order', filterorder,...
                'RemoveDC', rdc, 'Boundary', boundary, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG', @isstruct);
p.addRequired('chanArray', @isnumeric);
% option(s)
p.addParamValue('Filter', 'lowpass',@ischar);
p.addParamValue('Design', 'butter', @ischar);
p.addParamValue('Cutoff', 30, @isnumeric);
p.addParamValue('Order', 2, @isnumeric);
p.addParamValue('RemoveDC', 'off', @ischar);
p.addParamValue('Boundary', 'boundary');
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, chanArray, varargin{:});

filtp   = p.Results.Filter;
fdesign = p.Results.Design;
filco   = p.Results.Cutoff;

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
boundary    = p.Results.Boundary;
if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if ischar(fdesign)
        [ax, tt] = ismember_bc2({lower(fdesign)},{'butter' 'fir' 'notch'});
else
        [ax, tt] = ismember_bc2(fdesign,[0 1 2]);
end
if tt>0
        fdesignnum = tt-1;  % 0=butter, 1=fir, 2=notch
else
        error('ERPLAB says: Unrecognizable filter type. See help pop_basicfilter')
end

numchan = length(chanArray);
iserrch = 0;

if iserpstruct(EEG(1)) % for erpset
        if numchan>EEG(1).nchan
                iserrch = 1;
        end
elseif iseegstruct(EEG(1))
        if numchan>EEG(1).nbchan
                iserrch = 1;
        end
else
        msgboxText =  'Unknow data structure.\npop_basicfilter() only works with EEGLAB and ERPLAB structures.';
        title = 'ERPLAB: pop_basicfilter() error:';
        errorfound(sprintf(msgboxText), title);
        return
end
if iserrch
        msgboxText =  'You do not have such amount of channels in your data!';
        title = 'ERPLAB: basicfilter() error:';
        errorfound(msgboxText, title);
        return
end
if locutoff == 0 && hicutoff == 0
        msgboxText =  'I beg your pardon?';
        title = 'ERPLAB: basicfilter() !';
        errorfound(msgboxText, title);
        return
end

%
% process multiple datasets. Updated August 23, 2013 JLC
%
if length(EEG) > 1
        options1 = {chanArray, 'Filter',p.Results.Filter, 'Design',  p.Results.Design, 'Cutoff', p.Results.Cutoff, 'Order', p.Results.Order,...
                'RemoveDC', p.Results.RemoveDC, 'Boundary', p.Results.Boundary, 'History', 'gui'};
        [ EEG, com ] = eeg_eval( 'pop_basicfilter', EEG, 'warning', 'on', 'params', options1);
        return;
end

%
% subroutine
%
options2     = { chanArray, locutoff, hicutoff, filterorder, fdesignnum, remove_dc, boundary };
[EEG, ferror] = basicfilter( EEG, options2{:});

%
% check for filter errors
%
if ferror==1
        msgwrng = '*** Warning: Filtering process has been terminated.***';
        mcolor = [1 0.52 0.2];
        try cprintf(mcolor, '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
        return
end
EEG.icaact = [];

%
% Generate equivalent command (for history)
%
skipfields = {'EEG', 'chanArray', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_basicfilter( %s, %s ', inputname(1), inputname(1), vect2colon(chanArray)); % Bug #1
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                        end
                end
        end
end
com = sprintf( '%s );', com);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return