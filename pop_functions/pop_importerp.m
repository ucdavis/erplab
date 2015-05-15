% PURPOSE  : 	Import averaged ERP(s) from different file formats
%
% FORMAT   :
%
% EEG = pop_importerp(options);
%
% Options   :
%
% 'Filename'       - filename to load
% 'Filepath'       - file's path
% 'Filetype'       - file format: 'txt','.txt','text','.asc','asc','ascii',
%                    or 'avg','.avg','neuro','neuroscan'. Default 'text'
% 'Time'           - if time values are include in the file use 'on'.
%                    Deafult is 'off'
% 'Timeunit'       - time unit. Default milliseconds (1E-3)
% 'Elabel'         - if electrode labels are include in the file use 'on'.
%                    Deafult is 'off'
% 'Pointat'        - where are the sample points? at the 'rows' or
%                    'columns'. Default 'columns'
% 'Srate'          - sample rate. Default 1000
% 'Xlim'           - ERP's time window. Default [-200 800]
%
%
% OUTPUT  :
%
%
% ERP              - new ERPset
%
%
% Using the GUI.
% You will have to select various options.
%
% If in ERPSS format- no options need to be selected
%
% If in Universal text format
%       1.  Check box for electrode labels exist
%           Option 1: Points oriented as rows & electrodes oriented as columns
%           (in the text file)
%           Option 2: Points oriented as columns & electrodes oriented as rows
%           (in the text file)
%       2.  Check box for time values exist
%           - Time is in seconds or milliseconds
%           - Sampling rate
%           - Time range
%
% EXAMPLE  :
%
% ERP = pop_importerp( 'Filename', {'s2.txt' }, 'Filepath', {'/Users/javlopez/Desktop/ASCII' }, 'Filetype', {'text' }, 'Pointat',...
% 'column', 'Srate',  1000, 'Xlim', [ 0 1000] );
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
%
%
% Last update: April 22, 2015. JLC

function [ERP, erpcom] = pop_importerp(varargin)
erpcom = '';
ERP    = preloadERP;
if nargin<1
        def  = erpworkingmemory('pop_importerp');
        
        if isempty(def)
                def = {'','','',0,1,0,0,1000,[-200 800]};
        end
        %
        % Call GUI
        %
        getlista = importerpGUI(def);
        
        if isempty(getlista)
                disp('User selected Cancel')
                return
        end
        
        filename    = getlista{1};
        filepath    = getlista{2};
        ftype       = getlista{3};
        includetime = getlista{4};
        timeunit    = getlista{5};
        elabel      = getlista{6};
        transpose   = getlista{7};
        fs          = getlista{8};
        xlim        = getlista{9};
        
        erpworkingmemory('pop_importerp', {filename, filepath, ftype,includetime,timeunit,elabel,transpose,fs,xlim});
        
        filetype = {'text'};
        if includetime==0
                inctimestr = 'off';
        else
                inctimestr = 'on';
        end
        if elabel==0
                elabelstr = 'off';
        else
                elabelstr = 'on';
        end
        if transpose==0
                orienpoint = 'column'; % points at columns
        else
                orienpoint = 'row';    % points at rows
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_importerp('Filename', filename, 'Filepath', filepath, 'Filetype', filetype, 'Time', inctimestr,...
                'Timeunit', timeunit, 'Elabel', elabelstr, 'Pointat', orienpoint, 'Srate', fs, 'Xlim', xlim, 'Saveas', 'on',...
                'History', 'gui');
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
p.addParamValue('Filename', {''}, @iscell);
p.addParamValue('Filepath', {''}, @iscell);
p.addParamValue('Filetype', {'text'}, @iscell);
p.addParamValue('Time', 'off', @ischar);
p.addParamValue('Timeunit', 1E-3, @isnumeric);   % milliseconds by default
p.addParamValue('Elabel', 'off', @ischar);
p.addParamValue('Pointat', 'column', @ischar);
p.addParamValue('Srate', 1E3, @isnumeric);
p.addParamValue('Xlim', [-200 800], @isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(varargin{:});

filename = p.Results.Filename;
filepath = p.Results.Filepath;
filetype = p.Results.Filetype;

if strcmpi(p.Results.Time, 'on');
        includetime = 1;
else
        includetime = 0;
end
if ismember_bc2({lower(p.Results.Pointat)}, {'col','column','columns'});
        transpose = 1;
elseif ismember_bc2({lower(p.Results.Pointat)}, {'row','rows'});
        transpose = 0;
else
        error('ERPLAB says: ?')
end
if strcmpi(p.Results.Elabel, 'on');
        elabel = 1;
else
        elabel = 0;
end

timeunit = p.Results.Timeunit;

if includetime==1
        fs   = [];
        xlim = [];
else
        fs   = p.Results.Srate;
        xlim = p.Results.Xlim;
end
if strcmpi(p.Results.Saveas, 'on');
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
if ~iscell(filename)
        filename = cellstr(filename);
end
if ~iscell(filetype)
        filetype = cellstr(filetype);
end

nfile = length(filename);
npath = length(filepath);
nftyp = length(filetype);

if nftyp==1 && nfile>1
        filetype = repmat(filetype,1,nfile);
end
if npath~=1 && npath~=nfile
        error('ERPLAB says: filename and filepath are uneven.')
else
        if npath==1 && nfile>1
                filepath = repmat(filepath,1,nfile);
        end
end

uftype  = unique_bc2(filetype);
nuftype = length(uftype);

if nuftype==1
        if ismember_bc2({lower(char(uftype))}, {'txt','.txt','text','.asc','asc','ascii'});   %filetype==1
            
                [ERPx, serror] = asc2erp(filename, filepath, transpose, includetime, elabel, timeunit, fs, xlim);
                
                if serror==1
                        msgboxText =  ['Something went wrong\n'...
                                'Please, verify the file format.\n\n'...
                                'For text file, please check the organization of the data values,\n'...
                                'for instance, channels x points or points x channels,\n'...
                                'as well as the presence of both time values and electrode labels.'];
                        title = 'ERPLAB: pop_importerp few inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                if serror==2
                        msgboxText ='The specified sample rate is more than 10%% off from the computed sample rate.\n';
                        title = 'ERPLAB: pop_importerp few inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                if serror==3
                        msgboxText ='The specified sample rate is more than 10%% off from the computed sample rate.\n';
                        title = 'ERPLAB: pop_importerp sample rate';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        elseif ismember_bc2({lower(char(uftype))}, {'avg','.avg','neuro','neuroscan'}); %filetype==2
                ERPx = neuro2erp(filename, filepath);
        else
                error('wrong data format for importing')
        end
else
        for i=1:nfile
                if ismember_bc2({lower(filetype{i})}, {'txt','.txt','text','.asc','asc','ascii'});   %filetype==1
                        
                        %
                        % subroutine
                        %
                        [ALLERPX(i), serror]= asc2erp(filename(i), filepath(i), transpose, includetime, elabel, timeunit, fs, xlim);
                        
                        if serror==1
                                msgboxText =  ['Something went wrong\n'...
                                        'Please, verify the file format.\n\n'...
                                        'For text file, please check the organization of the data values,\n'...
                                        'for instance, channels x points or points x channels,\n'...
                                        'as well as the presence of both time values and electrode labels.'];
                                title = 'ERPLAB: pop_importerp few inputs';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                        if serror==2
                                msgboxText ='The specified sample rate is more than 10%% off from the computed sample rate.\n';
                                title = 'ERPLAB: pop_importerp few inputs';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                elseif ismember_bc2({lower(filetype{i})}, {'avg','.avg','neuro','neuroscan'}); %filetype==2
                        ALLERPX(i) = neuro2erp(filename(i), filepath(i));
                else
                        error('wrong data format for importing')
                end
        end
        
        %
        % subroutine
        %
        [ERPx, serror] = appenderp(ALLERPX,1:nfile);
        clear ALLERPX
        
        if serror==1
                msgboxText =  'Your ERPs do not have the same amount of channels!';
                title = 'ERPLAB: pop_appenderp() error:';
                errorfound(msgboxText, title);
                return
        elseif serror==2
                msgboxText =  'Your ERPs do not have the same amount of points!';
                title = 'ERPLAB: pop_appenderp() error:';
                errorfound(msgboxText, title);
                return
        end
end
fn     = fieldnames(p.Results);
erpcom = 'ERP = pop_importerp(';

if strcmp(filetype{1}, 'neuroscan')
        skipfields = {'ALLERP', 'Saveas', 'Time', 'Timeunit', 'Elabel', 'Pointat', 'Srate', 'Srate', 'Xlim', 'Saveas','History'};
else
        skipfields = {'ALLERP', 'Saveas', 'History'};
end
w=1;
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        if w==1
                                                erpcom = sprintf( '%s ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                        else
                                                erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                        end
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
                                if w==1
                                        erpcom = sprintf( ['%s ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
                w=w+1;
        end
end
erpcom = sprintf( '%s );', erpcom);
erpcom = regexprep(erpcom, '(\s*,','(');
if issaveas==1
        %[ERPx issave] = pop_savemyerp(ERPx,'gui','erplab');
        [ERPx, issave, erpcom_save] = pop_savemyerp(ERPx,'gui','erplab', 'History', 'off');
        
        if issave>0               
                if issave==2
                        erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                        msgwrng = '*** Your ERPset was saved on your hard drive.***';
                else
                        msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
                end
                fprintf('\n%s\n\n', msgwrng)
                
                msg2end
        else
                disp('Warning: Your ERP structure has not yet been saved')
                disp('user canceled')
                return
        end
end
ERP = ERPx; % JLC.

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
                return
end
%
% Completion statement
%
msg2end
return
