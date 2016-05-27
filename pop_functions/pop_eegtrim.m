% PURPOSE: Remove leading and trailing (mostly noisy) data from a continuous EEG dataset.
%          Recommended before applying ICA.
%
%
% FORMAT:
% EEG = pop_eegtrim(EEG, pre, post)
% 
% INPUT
%
% EEG     - input dataset
% pre     - pre-stimulation window in ms (time left before the first event)
% post    - post-stimulation window in ms (time left after the last event)
% 
% 
% OUTPUT
%
% EEG     - trimmed continuous dataset ()
% 
% Author: Javier Lopez-Calderon & Johanna Kreither
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Dec 2013

function [EEG, com] = pop_eegtrim(EEG, pre, post, varargin)
com = '';
if nargin<1
        help pop_eegtrim
        return
end
if nargin==1
        serror = erplab_eegscanner(EEG, 'pop_creabasiceventlist', 2, 0, 0, 2, 2); % check for continuous dataset
        if serror
                return
        end
        def    = erpworkingmemory('pop_eegtrim');
        
        %
        % Call GUI
        %
        answer = gui_eegtrim(def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        pre  = answer{1};
        post = answer{2};
        
        erpworkingmemory('pop_eegtrim', {answer{1} answer{2}});
        if length(EEG)==1
                EEG.setname = [EEG.setname '_trim']; %suggest a new name
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_eegtrim(EEG, pre, post, 'History', 'gui');
        return        
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('pre');
p.addRequired('post');
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, pre, post, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end

t1   = EEG.event(1).latency;
if t1<=2
        t1   = EEG.event(2).latency;
end
t2   = EEG.event(end).latency;
if t2>=EEG.pnts-2
        t2   = EEG.event(end-1).latency;
end
pnts = EEG.pnts;
fs   = EEG.srate;
presam  = time2sample(1,pre, fs, 1);
postsam = time2sample(1,post, fs, 1);
pre1  = 1;
pre2  = t1-presam;
post1 = t2+postsam;
post2 = pnts;

if pre2<1
        error('There is not enough samples to keep the pre-stimulation window.')
end
if post1>pnts
        error('There is not enough samples to keep the post-stimulation window.')
end

% trimming
disp('Trimming data...')
EEG = eeg_eegrej( EEG, [pre1 pre2;post1 post2]);

skipfields = {'EEG', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_eegtrim( %s, %g, %g ', inputname(1), inputname(1), pre, post);
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