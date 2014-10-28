%
% Under construction...Sorry.
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

function [EEG, com] = pop_artsacc(EEG, varargin)
com = '';
if nargin<1
        help pop_artsacc
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        serror = erplab_eegscanner(EEG, 'pop_artsacc', 2, 0, 1, 2, 1);
        if serror
                return
        end
        prompt = {'Test period (start end) [ms]', 'Voltage Threshold [uV]', 'Moving Windows Full Width [ms]',...
                'Window Step (ms)','Channel(s)'};
        dlg_title = 'Step Function';
        defx = {[EEG.xmin*1000 EEG.xmax*1000] 100 200 50 [1:EEG.nbchan] 0};
        def = erpworkingmemory('pop_artsacc');
        
        if isempty(def)
                def = defx;
        else
                if def{1}(1)<EEG.xmin*1000
                        def{1}(1) = single(EEG.xmin*1000);
                end
                if def{1}(2)>EEG.xmax*1000
                        def{1}(2) = single(EEG.xmax*1000);
                end
                
                def{5} = def{5}(ismember_bc2(def{5},1:EEG.nbchan));
        end
        try
                chanlabels = {EEG.chanlocs.labels};
        catch
                chanlabels = [];
        end
        
        %
        % Call GUI
        %
        answer = artifactmenuGUI(prompt, dlg_title, def, defx, chanlabels);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        testwindow =  answer{1};
        ampth      =  answer{2};
        durartifact=  answer{3};
        chanArray  =  unique_bc2(answer{4}); % avoids repeted channels
        flag       =  answer{5};
        viewer     =  answer{end};
        
        if viewer
                viewstr = 'on';
        else
                viewstr = 'off';
        end
        if ~isempty(find(flag<1 | flag>16, 1))
                msgboxText =  'ERROR, flag cannot be greater than 16 nor lesser than 1';
                title = 'ERPLAB: Flag input';
                errorfound(msgboxText, title);
                return
        end
        erpworkingmemory('pop_artsacc', {answer{1} answer{2} answer{3} answer{4} answer{5}});
        EEG.setname = [EEG.setname '_ar']; %suggest a new name
        
        %
        % Somersault
        %
        [EEG, com] = pop_artsacc(EEG, 'Twindow', testwindow, 'Threshold', ampth,...
                'Durar', durartifact, 'Channel', chanArray, 'Flag', flag, 'Review', viewstr, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
t1 = single(EEG.xmin*1000);
t2 = single(EEG.xmax*1000);
p.addParamValue('Twindow', [t1 t2], @isnumeric);
p.addParamValue('Threshold', 50, @isnumeric);
p.addParamValue('Durar', 200, @isnumeric); % artifact duration
p.addParamValue('Channel', 1:EEG.nbchan, @isnumeric);
p.addParamValue('Flag', 1, @isnumeric);
p.addParamValue('Review', 'off', @ischar); % to open a window with the marked epochs
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

testwindow  =  p.Results.Twindow;
ampth       =  p.Results.Threshold;
durartifact =  p.Results.Durar;
chanArray   =  p.Results.Channel; % avoids repeated channels
flag        =  p.Results.Flag;

if strcmpi(p.Results.Review, 'on')% to open a window with the marked epochs
        eprev = 1;
else
        eprev = 0;
end
if ~isempty(find(chanArray<1 | chanArray>EEG.nbchan, 1))
        error('ERPLAB says: error at pop_artsacc(). Channel indices cannot be greater than EEG.nbchan')
end
if ~isempty(find(flag<1 | flag>16, 1))
        error('ERPLAB says: error at pop_artsacc(). Flag cannot be greater than 16 or lesser than 1')
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
if length(ampth)>1
        error('ERPLAB says: you must enter 1 value for peak-to-peak Voltage threshold')
end

fs       = EEG.srate;
nch      = length(chanArray);
ntrial   = EEG.trials;
%winpnts  = floor(winms*fs/1000);
%stepnts  = floor(stepms*fs/1000);
durartsam = floor(durartifact*fs/1000); % duration of the artifact in samples

% if stepnts<1
%         error('ERPLAB says: The minimun step value should be equal to the sampling period (1/fs msec).')
% end

[p1, p2, checkw] = window2sample(EEG, testwindow, fs);

if checkw==1
        error('pop_artsacc() error: time window cannot be larger than epoch.')
elseif checkw==2
        error('pop_artsacc() error: too narrow time window')
end

epochwidth = p2-p1+1; % choosen epoch width in number of samples

if nch>EEG.nbchan
        error('ERPLAB says: pop_artsacc() number of tested channels cannot be greater than total.')
end

% if winpnts>epochwidth
%         error('pop_artstep() error: time window cannot be larger than epoch')
% elseif winpnts<2
%         error('pop_artstep() error: too narrow time window')
% end

if isempty(EEG.reject.rejmanual)
        EEG.reject.rejmanual  = zeros(1,ntrial);
        EEG.reject.rejmanualE = zeros(EEG.nbchan, ntrial);
end

interARcounter = zeros(1,ntrial); % internal counter, for statistics

fprintf('channel #\n ');

%
% Tests RT info
%
isRT = 1; % there is RT info by default
if ~isfield(EEG.EVENTLIST.bdf, 'rt')
        isRT = 0;
else
        valid_rt = nnz(~cellfun(@isempty,{EEG.EVENTLIST.bdf.rt}));
        if valid_rt==0
                isRT = 0;
        end
end
countsam = 20;

for ch=1:nch
        fprintf('%g ',chanArray(ch));
        for i=1:ntrial;
                for j=p1:p2-1
                        
                        w1  = EEG.data(chanArray(ch), j,i);
                        w2  = EEG.data(chanArray(ch), j+1 ,i);
                        vs  = w1- w2;
                        
                        if abs(vs)>=ampth && j>p1
                                if sign(vs)==signpre
                                        if countsam>=durartsam
                                                interARcounter(i) = 1;      % internal counter, for statistics
                                                
                                                %
                                                % subroutine
                                                %
                                                % flaf 1 is obligatory
                                                [EEG, errorm]= markartifacts(EEG, flag, chanArray, ch, i, isRT);
                                                if errorm==1
                                                        error(['ERPLAB says: There was not latency at the epoch ' num2str(i)])
                                                elseif errorm==2
                                                        error('ERPLAB says: invalid flag (0<=flag<=16)')
                                                end
                                                
                                                break
                                        else
                                                countsam =countsam + 1;
                                        end
                                        signpre = sign(vs);
                                end
                        elseif abs(vs)>=ampth && j==p1
                                signpre  = sign(vs);
                                countsam = 1;
                        end
                end
        end
end
fprintf('\n');

% performance
perreject = nnz(interARcounter)/ntrial*100;
fprintf('pop_artsacc() rejected a %.1f %% of total trials.\n', perreject);
fprintf('\n');
pop_summary_AR_eeg_detection(EEG, ''); % show table at the command window
EEG = eeg_checkset( EEG );

if eprev==1
        namefig = 'Step-like artifacts view';
        pop_plotepoch4erp(EEG, namefig)
end

% flagstr = vect2colon(flag);

% com = sprintf( '%s = pop_artstep( %s, %s, %s, %s, %s, %s, %s);', ...
%         inputname(1), inputname(1), testwindow, num2str(ampth), num2str(winms),...
%         num2str(stepms), chArraystr, flagstr);
%
skipfields = {'EEG', 'Review', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_artsacc( %s ', inputname(1), inputname(1));
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

% get history from script
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