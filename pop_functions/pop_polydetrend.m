% PURPOSE: interactively detrends an EEG dataset, using polydetrend.
%
%
% FORMAT:
%
% EEG = pop_ERPLAB_polydetrend( EEG, window)
%
% Graphical interface:
%
%   "Window" - [edit box] minimun time window (in sec) to represent the
%                         mean of DC behaviour (into the window).
%                         Row data will divided per this window, generating
%                         a joint of points over which a polynomial will be
%                         calculated.
%                         Applying the same vector of time to polynomial we
%                         will get the full DC behavior per channel. The
%                         last one is subtracted from each channel finally.
%
% Inputs:
%
%   EEG       - input dataset
%   window    - minimun time window (in sec)
%
%
% Outputs:
%
%   EEG       - output dataset
%
%
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

function [EEG, com] = pop_polydetrend(EEG, varargin)

com = '';
if exist('filtfilt','file') ~= 2
        error('Warning: cannot find the signal processing toolbox')
end
if nargin < 1
        help pop_polydetrend
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        for hh=1:length(EEG)
                if isempty(EEG(hh).data)
                        msgboxText =  'No dataset';
                        tittle = 'ERPLAB: pop_polydetrend';
                        errorfound(msgboxText, tittle);
                        return
                end
                if ~isempty(EEG(hh).epoch)
                        msgboxText =  'pop_polydetrend has been tested for continuous data only';
                        tittle = 'ERPLAB: pop_polydetrend';
                        errorfound(msgboxText, tittle);
                        return
                end
        end
        
        def  = erpworkingmemory('pop_polydetrend');
        if isempty(def)
                def = {1 1 5000 2500};
        end
        chanlocs = EEG(1).chanlocs;
        
        %
        % Call GUI
        %
        answer = polydetrendGUI(def, chanlocs);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        pmethod   = answer{1};   % 1=spline, 1=Savitzky-Golay
        chanArray = answer{2};   % channels
        windowms  = answer{3};   % window width (ms)
        stepms    = answer{4};   % window step (ms)
        
        erpworkingmemory('pop_polydetrend', {pmethod, chanArray, windowms, stepms});
        
        if pmethod== 1
                pmethodstr = 'spline';
        elseif pmethod==2
                pmethodstr = 'Savitzky';
        else
                error('Unknown pmethod')
        end        
        if length(EEG)==1
                EEG.setname = [EEG.setname '_pd']; % suggested name (si queris no mas!)
        end
        
        %
        % Somersault
        %
        [EEG, com]  = pop_polydetrend(EEG, 'Method', pmethodstr, 'Channels', chanArray,...
                'Windowsize', windowms, 'Windowstep', stepms, 'History', 'gui');
        pause(0.1)
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG', @isstruct);
% option(s)
p.addParamValue('Method', 'spline', @ischar);   %spline=1, Savitzky=2
p.addParamValue('Channels', 1, @isnumeric);
p.addParamValue('Windowsize', 5000, @isnumeric);
p.addParamValue('Windowstep', 250, @isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(EEG, varargin{:});

%1=spline, 1=Savitzky-Golay
if strcmp(p.Results.Method, 'spline')
        pmethod = 1;
elseif strcmp(p.Results.Method, 'Savitzky')
        pmethod =2;
else
        error('Unknown pmethod')
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
chanArray = p.Results.Channels;        %channels
windowms  = p.Results.Windowsize;      %window width (ms)
stepms    = p.Results.Windowstep;
windowpnts = round((windowms/1000) * (EEG(1).srate));
stepnts    = round((stepms/1000) * (EEG(1).srate));
windowsec  = windowms/1000;
if windowsec<1 || windowsec>EEG(1).xmax/3
        fprintf('\nError: Window width cannot be lesser than 1 sec, nor\n');
        fprintf('as high as to get less than 3 windows from your dataset,\n\n');
end

%
% process multiple datasets. Updated August 23, 2013 JLC
%
if length(EEG) > 1        
        options1 = {'Method', p.Results.Method, 'Channels', p.Results.Channels,'Windowsize', p.Results.Windowsize,...
                'Windowstep', p.Results.Windowstep, 'History', 'gui'};
        [ EEG, com ] = eeg_eval( 'pop_polydetrend', EEG, 'warning', 'on', 'params',options1);
        return
end

%
% Subroutine
%
fprintf('Polynomially detrending data...Please wait...\n');
EEG = polydetrend(EEG, windowpnts, stepnts, chanArray, pmethod);

%
% Generate equivalent command (for history)
%
skipfields = {'EEG','History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_polydetrend( %s ', inputname(1), inputname(1));
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no') && ~strcmpi(fn2res,'none')
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
                return
end

%
% Completion statement
%
msg2end
return
