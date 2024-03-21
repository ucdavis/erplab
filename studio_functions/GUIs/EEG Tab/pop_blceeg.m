% PURPOSE : 	Removes epoched EEG baseline
%
% FORMAT  :
%
% EEG = pop_blceeg(EEG, blc)
%
% EEG     -  EEGLAB structure
% blc     - window for baseline correction in msec  or either a string like 'pre', 'post', or 'all'
%           (strings with the baseline interval also works. e.g. '-300 100')
%
% Example :
% >> EEG = pop_blceeg( EEG , [-200 800],  [-100 0]);
% >> EEG = pop_blceeg( EEG , [-200 800],  '-100 0');
% >> EEG = pop_blceeg( EEG , [-400 2000],  'post');
%
% INPUTS  :
%
% EEG     -  EEGLAB structure
% blc     -  window for baseline correction in msec or either a string like
%            'none', 'pre', 'post', or 'whole'
%
% OUTPUTS :
%
% - updated (output) EEGset
%
% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% EStudio Toolbox
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu


function [EEG, LATCOM] = pop_blceeg(EEG, varargin)
LATCOM = '';
if nargin < 1
    help pop_blceeg
    return
end
%
% Gui is working...
%
if nargin==1
    title_msg  = 'EStudio: pop_blceeg() error:';
    if isempty(EEG)
        if isempty(EEG)
            msgboxText =  'No EEGset was found!';
            errorfound(msgboxText, title_msg);
            return
        end
    end
    if isempty(EEG.data)
        msgboxText =  'cannot work with an empty EEGset!';
        errorfound(msgboxText, title_msg);
        return
    end
    
    if EEG.trials ==1
        msgboxText =  'cannot work with a continous EEGset!';
        errorfound(msgboxText, title_msg);
    end
    
    titlegui = 'Baseline Correction for EEGset';
    answer = blcerpGUI(EEG, titlegui );  % open GUI
    
    if isempty(answer)
        return
    end
    blcorr = answer{1};
    
    %
    % Somersault
    %
    [EEG, LATCOM] = pop_blceeg(EEG, 'Baseline', blcorr, 'Saveas', 'off', 'History', 'gui');
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
p.addParamValue('Baseline', 'pre'); % EEGset index or input file
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(EEG, varargin{:});



kktime = 1000;

blcorr   = p.Results.Baseline;
if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
end


title_msg  = 'EStudio: pop_blceeg() error:';

if isempty(EEG.data)
    msgboxText =  'cannot work with an empty EEGset!';
    errorfound(msgboxText, title_msg);
    return
end

if EEG.trials ==1
    msgboxText =  'cannot work with a continous EEGset!';
    errorfound(msgboxText, title_msg);
end



if ischar(blcorr)
    if ~ismember_bc2(lower(blcorr),{'all' 'pre' 'post' 'none'})
        internum = str2double(blcorr);
        if length(internum) ~=2
            msgboxText = ['pop_blceeg will not be performed.\n'...
                'Check out your baseline correction values'];
            title =  'EStudio: pop_blceeg() base line';
            errorfound(sprintf(msgboxText), title);
            return
        end
        if internum(1)>=internum(2)|| internum(1)>EEG.xmax || internum(2)<EEG.xmin
            msgboxText = ['pop_blceeg will not be performed.\n'...
                'Check out your baseline correction values'];
            title =  'EStudio: pop_blceeg() base line';
            errorfound(sprintf(msgboxText), title);
            return
        end
        
        BLC  = internum; % msecs
        blcorrcomm = ['[' blcorr ']'];
    else
        if strcmpi(blcorr,'pre')
            BLC  = kktime*[EEG.xmin 0]; % msecs
            blcorrcomm = ['''' blcorr ''''];
            BLCp1 = 1;
            %                   BLCp2 = find(EEG.times==0);
            [xxx, BLCp2, latdiffms] = closest(EEG.times, 0);%%%GH 2022
        elseif strcmpi(blcorr,'post')
            BLC  = kktime*[0 EEG.xmax];  % msecs
            blcorrcomm = ['''' blcorr ''''];
            %                   BLCp1 = find(EEG.times==0);
            [xxx, BLCp1, latdiffms] = closest(EEG.times, 0);%%GH 2022
            BLCp2 = EEG.pnts;
        elseif strcmpi(blcorr,'all')
            BLC  = kktime*[EEG.xmin EEG.xmax]; % msecs
            blcorrcomm = ['''' blcorr ''''];
            BLCp1 = 1;
            BLCp2 = EEG.pnts;
        else
            BLC  = [];
            blcorrcomm = '''none''';
        end
    end
else
    if length(blcorr)~=2
        error('EStudio says:  pop_blceeg will not be performed. Check your parameters.')
    end
    if blcorr(1)>=blcorr(2)|| blcorr(1)>EEG.xmax*kktime || blcorr(2)<EEG.xmin*kktime
        error('EStudio says:  pop_blceeg will not be performed. Check your parameters.')
    end
    BLC  = blcorr;
    blcorrcomm = ['[' num2str(blcorr) ']']; % msecs
    [BLCp1, BLCp2, checkw] = window2sample(EEG, BLC, EEG.srate);
end

EEGaux = EEG; % original EEG
ntrial = EEG.trials;

%
% baseline correction
%
if ~isempty(BLC)
    
    %
    % Baseline correction
    %
    fprintf('Removing baseline...\n');
    for i=1:ntrial
        meanv = mean(EEG.data(:,BLCp1:BLCp2,i), 2);
        EEG.data(:,:,i) = EEG.data(:,:,i) - repmat(meanv,1,EEG.pnts);    % fast baseline removing
    end
    fprintf('\nBaseline correction was performed at [%s] \n\n', num2str(BLC));
else
    fprintf('\n\nWarning: No baseline correction was performed\n\n');
end

EEG.saved  = 'no';
% LATCOM = sprintf('%s = pop_blceeg( %s, %s);', inputname(1), inputname(1), blcorrcomm);

%
% History
%
skipfields = {'EEG', 'History'};
fn     = fieldnames(p.Results);
LATCOM = sprintf( '%s = pop_blceeg( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    LATCOM = sprintf( '%s, ''%s'', ''%s''', LATCOM, fn2com, fn2res);
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
                        LATCOM = sprintf( ['%s, ''%s'', ' fnformat], LATCOM, fn2com, fn2resstr);
                    end
                else
                    LATCOM = sprintf( ['%s, ''%s'', ' fnformat], LATCOM, fn2com, fn2resstr);
                end
            end
        end
    end
end
LATCOM = sprintf( '%s );', LATCOM);
if issaveas
    [EEG, issave, LATCOM_save] = pop_savemyEEG(EEG,'gui','EEGlab', 'History', 'implicit');
end
% get history from script. EEG
switch shist
    case 1 % from GUI
        displayEquiComERP(LATCOM);
    case 2 % from script
        EEG = eegh(LASTCOM, EEG);
    case 3
        % implicit
    otherwise %off or none
        LATCOM = '';
end

%
% Completion statement
%
msg2end
return
