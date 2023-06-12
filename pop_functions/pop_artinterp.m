% PURPOSE  : Interpolating marked epochs based on flags.
%
% FORMAT   :
%
% >> EEG = pop_artinterp(EEG, parameters);
%
% INPUTS   :
%
% EEG           - input dataset
% 
%         [EEG, com] = pop_artinterp(EEG, 'FlagToUse', replaceFlag, 'InterpMethod', interpolationMethod, ...
%                 'ChanToInterp', replaceChannelInd, ...
%                 'ChansToIgnore', ignoreChannels);
%
% The available parameters are as follows:
%
%        'FlagToUse' 	- Flag used to filter epochs by prior to
%                       interpolation. Epochs must be flagged prior to
%                       using this function.
%        'InterpMethod' - [string] method used for interpolation (default is 'spherical').
%                       'invdist'/'v4' uses inverse distance on the scalp
%                       'spherical' uses superfast spherical interpolation.
%        'ChanToInterp'  - [integer] Index of channel to interpolate. 
%        'ChansToIgnore' - [integer array] Do not include these electrodes
%                          as input for interpolation.
%        'InterpAnyChan'    - default = 0; If 1, all channels that are flagged with artifacts
%                           will be interpolated IF no more than THRESHOLD
%                           percent of channels are flagged
%        'Threshold'    - default = 10%; if greater than X% of channels are flagged, 
%        then interpolation routine will NOT work for that epoch 
%
%
% OUTPUTS  :
%
% EEG           - updated output dataset
%
% EXAMPLE  :
%
% EEG  = pop_artstep( EEG , 'FlagToUse',  7, 'InterpMethod',  'spherical, 'ChanToInterp', 4, 'ChansToIgnore', [7,9]);
%
%
% See also pop_erplabInterplateElectrodes erplab_interpolateElectrodes artifactinterpGUI.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2021

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

function [EEG, com] = pop_artinterp(EEG, varargin)
com = '';
if nargin<1
        help pop_artinterp
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        serror = erplab_eegscanner(EEG, 'pop_artinterp', 2, 0, 1, 2, 1);
        if serror
              return
        end
        
        dlg_title = {'Interpolate Flagged Artifact Epochs'};

        %defaults 
        defx = {0, 'spherical',[],[],[],0,10}; 
        %first pos: no previous flag selected
        %second pos: no previous method selected (default to 'spherical')
        %third pos: no prev electrode selected (should agree with fourth pos)
        %fourth pos: no prev "channel-label" selected (should agree with third pos)
        %fifth pos: no prev "channels" to ignore
        %sixth pos: set to 0 = "interpolate only one" electrode option
        %seventh pos: set to 10% default threshold (of artifacts across
        %   electrode) for 'any electrode interpolation' option
        %eigth pos: set [] default, for measurment channel rule 

        %take previously selected electrodes and flags used from previous
        % artinterp() usage? 
        def = erpworkingmemory('pop_artinterp');     
        
        if isempty(def)
                def = defx;
        else    
                %make sure that electrode number exists in current list of
                %available channels
                %def{1} = def{1}(ismember_bc2(def{1},1:EEG(1).nbchan));
                def{3} = def{3}(ismember_bc2(def{3},1:EEG(1).nbchan));
        end
        
        try
                chanlabels = {EEG(1).chanlocs.labels}; %only works on single datasets
        catch
                chanlabels = [];
        end
        
        
        
        histoflags = summary_rejectflags(EEG);
        
        %check currently activated flags
        flagcheck = sum(histoflags); 
        active_flags = (flagcheck>1);
        
       % def{end} = active_flags; 
        
        
        %
        % Call GUI
        %
        answer = artifactinterpGUI(dlg_title, def, defx, chanlabels, active_flags);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        replaceFlag =  answer{1};
        interpolationMethod      =  answer{2};
        replaceChannelInd     =  answer{3};
        replaceChannelLabel     =  answer{4};
        ignoreChannels  =  unique_bc2(answer{5}); % avoids repeted channels
        many_electrodes = answer{6};
        threshold_perc = answer{7};
       % measurement_chan = answer{8}; 
        
       % displayEEG       =  answer{6}; %no display EEG for now
       % viewer     =  answer{end}; %no viewer for Now 
        
        viewer = 0; % no viewer 
        if viewer
                viewstr = 'on';
        else
                viewstr = 'off';
        end
        if ~isempty(find(replaceFlag<1 | replaceFlag>16, 1))
                msgboxText{1} =  'ERROR, flag cannot be greater than 16 nor lesser than 1';
                title = 'ERPLAB: Flag input';
                errorfound(msgboxText, title);
                return
        end
        erpworkingmemory('pop_artinterp', {answer{1} answer{2} answer{3} answer{4} answer{5} ...
            answer{6}, answer{7}});
        
        if length(EEG)==1
                EEG.setname = [EEG.setname '_arInterp']; %suggest a new name
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_artinterp(EEG, 'FlagToUse', replaceFlag, 'InterpMethod', interpolationMethod, ...
                'ChanToInterp', replaceChannelInd, 'ChansToIgnore', ignoreChannels, ...
                'InterpAnyChan', many_electrodes, 'Threshold',threshold_perc,...
                 'Review', viewstr, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');

t1 = single(EEG(1).xmin*1000);
t2 = single(EEG(1).xmax*1000);
%p.addParamValue('Twindow', [t1 t2], @isnumeric);
%p.addParamValue('Channels', 1:EEG(1).nbchan, @isnumeric); %all channels
p.addParamValue('FlagToUse', 0, @isnumeric); 
p.addParamValue('InterpMethod', 'spherical', @ischar); 
p.addParamValue('ChanToInterp', 0, @isnumeric); %%%%%%%%%%%%% <<<<
%p.addParamValue('ChanLabel', 'none', @ischar);
p.addParamValue('ChansToIgnore', [], @isnumeric); 
p.addParamValue('InterpAnyChan', 0,@isnumeric);
p.addParamValue('Threshold', 10, @isnumeric); %percentage value 
%p.addParamValue('MeasurementChanIdx',[],@isnumeric); 
p.addParamValue('Review', 'off', @ischar); % to open a window with the marked epochs
%p.addParamValue('Flag', 1, @isnumeric); %param for things to-be flagged
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

replaceFlag =  p.Results.FlagToUse;
interpolationMethod      =  p.Results.InterpMethod;
replaceChannelInd = p.Results.ChanToInterp; 
%replaceChannelLabel     =  p.Results.ChanLabel;
ignoreChannels  =  p.Results.ChansToIgnore; 
many_electrodes = p.Results.InterpAnyChan; 
threshold_perc = p.Results.Threshold; 
%meas_chan = p.Results.MeasurementChanIdx; 
%flag       =  p.Results.Flag;
displayEEG = p.Results.Review; 



if strcmpi(p.Results.Review, 'on')% to open a window with the marked epochs
        eprev = 1;
else
        eprev = 0;
end
if ~isempty(find(ignoreChannels<1 | ignoreChannels>EEG(1).nbchan, 1))
        error('ERPLAB says: error at pop_artstep(). Channel indices cannot be greater than EEG.nbchan')
end
if ~isempty(find(replaceFlag<1 | replaceFlag>16, 1))
        error('ERPLAB says: error at pop_artstep(). Flag cannot be greater than 16 or lesser than 1')
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

%
% process multiple datasets. Updated August 23, 2013 JLC
%
% if length(EEG) > 1
%         options1 = {'Twindow', p.Results.Twindow, 'Threshold', p.Results.Threshold, 'Windowsize', p.Results.Windowsize,...
%                 'Windowstep', p.Results.Windowstep, 'Channel', p.Results.Channel, 'Flag', p.Results.Flag,...
%                 'Review', p.Results.Review, 'History', 'gui'};
%         [ EEG, com ] = eeg_eval( 'pop_artstep', EEG, 'warning', 'on', 'params', options1);
%         return;
% end

% chArraystr = vect2colon(chanArray);




%% first, index the epochs to interpolate based on the flag used 
ntrial  = EEG.trials; %number of original trials 
oldflag = zeros(1,ntrial); 

for i = 1:ntrial
    
    if length(EEG.epoch(i).eventlatency) == 1
        flagx = [EEG.epoch(i).eventflag]; 
        
        if iscell(flagx) 
            flagx = cell2mat(flagx)
        end
        
        oldflag(i) = flagx;

    elseif length(EEG.epoch(i).eventlatency) > 1
         indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0,1,'first');% catch zero-time locked type   
         oldflag(i)   = EEG.epoch(i).eventflag{indxtimelock};

    end
    
    
end

% filter oldflag by specified flag

flagbit = bitshift(1,0:15);
flagged_epochs = bitand(flagbit(replaceFlag), oldflag); 
epoch_ind = find(flagged_epochs); %list of index of epochs, filtered by specified flag, to interpolate

%% interpolate only the epochs with the specified flag 
N_interpolate = numel(epoch_ind);



for e = 1:N_interpolate
    
    tmpEEG = EEG; %temp EEG struct 
    
       
    tmpEEG.data = tmpEEG.data(:,:,epoch_ind(e)); %index current epoch
    tmpEEG.trials = 1; %update temp single trial EEG struct 
    all_chans = EEG.reject.rejmanualE(:,epoch_ind(e)); 
    
    ignoreChannelsE = ignoreChannels;
    chanlocs = tmpEEG.chanlocs; 
    
    %skip epoch if the channel to be interpolated is itself a not-real
    %channel (i.e. no theta information)
    nonemptychans = find(~cellfun('isempty', { chanlocs.theta }));
    
    
    
    if many_electrodes == 1
        
        
        
        chans_to_interp = find(all_chans)';
  
        %skip channels to be interpolated is itself a not-real
        %channel (i.e. no theta information)
        
        [~,chan_ind ] = intersect_bc(chans_to_interp,nonemptychans);    
        chans_to_interp2 = chans_to_interp(chan_ind); 
        
        if isempty(chans_to_interp2)
            
            fprintf('\nSkipping epoch #%s since the channel(s) #%i to be interpolated are not real channels (no channel location theta info)', ...
                num2str(epoch_ind(e)), chans_to_interp);
            
            continue
        end
            
   
        
        %fix redundancies between chan_to_interp & ignore channels
        if any(ismember(chans_to_interp,ignoreChannels))
            %ignoreChannelsE = setdiff(ignoreChannelsE, chans_to_interp);
            chans_to_interp = setdiff(chans_to_interp,ignoreChannelsE);
        end
        
        %adjust bad channel count with updated ignored channels
        
        total_chans = numel(all_chans) - numel(ignoreChannelsE);
        
        
        if sum(all_chans)/(total_chans) >= (threshold_perc/100)
            
            fprintf('\nSkipping epoch #%s by flag %s since amount of channels with artifact threshold %i percent exceeded\n', ...
                num2str(epoch_ind(e)),num2str(replaceFlag), threshold_perc);
            
            continue
            
        else
            
            
            
            fprintf('\nInterpolating epoch #%s by flag %s \n', num2str(epoch_ind(e)), ...
                num2str(replaceFlag));
            
            fprintf('\nFlag for epoch %s has been reset in EEG.rejmanual \n', num2str(epoch_ind(e)));
            
            %interpolate
            tmpEEG = erplab_interpolateElectrodes(tmpEEG, chans_to_interp, ...
                ignoreChannelsE,interpolationMethod);
            
            %reset flag at EEG.reject.manual
            EEG.reject.rejmanual(epoch_ind(e)) = 0;
            
            
            
            
        end

        
        
    else
        %one electrode case
        
        %skip channels to be interpolated is itself a not-real
        %channel (i.e. no theta information)       
        [~,chan_ind ] = intersect_bc(replaceChannelInd,nonemptychans);    
        replaceChannelInd2 = replaceChannelInd(chan_ind); 
        
        if isempty(replaceChannelInd2)
            fprintf('\nSkipping epoch #%s since the channel(s) #%i to be interpolated are not real channels (no channel location theta info)', ...
                num2str(epoch_ind(e)), replaceChannelInd);
            continue
        end
            
        
        %fix redundancies between chan_to_interp & ignore channels
        if ismember(replaceChannelInd,ignoreChannels)
            ignoreChannelsE = setdiff(ignoreChannels, replaceChannelInd);
        end
        
        %fix ignoreChannels to not include channels that are bad (unless it's the chosen channel)!
        include_to_ignore = double(find(all_chans)');
        
        
        if replaceChannelInd ~= include_to_ignore
            ignoreChannelsE = cat(2,ignoreChannelsE, include_to_ignore);
        end
        
         %adjust bad channel count with updated ignored channels
        total_chans = numel(all_chans) - numel(ignoreChannelsE);  
        
 
        if sum(all_chans)/(total_chans) >= (threshold_perc/100)
            
            fprintf('\nSkipping epoch #%s by flag %s since amount of channels with artifact threshold %i percent exceeded\n', ...
                num2str(epoch_ind(e)),num2str(replaceFlag), threshold_perc);
            
            continue
            
        else
            
            fprintf('\nInterpolating epoch #%s by flag %s \n', num2str(epoch_ind(e)), ...
                num2str(replaceFlag));
            
            fprintf('\nFlag for epoch %s has been reset in EEG.rejmanual \n', num2str(epoch_ind(e)));

            
            tmpEEG = erplab_interpolateElectrodes(tmpEEG, replaceChannelInd, ...
                ignoreChannelsE,interpolationMethod);
            
            %reset flag at EEG.reject.manual
            EEG.reject.rejmanual(epoch_ind(e)) = 0;
        end
        
    end

    
    %re-add interpolated temp EEG epoch into original EEG
    EEG.data(:,:,epoch_ind(e)) = tmpEEG.data; 

end

% transfer the EEG.reject artifact marks to EVENTLIST
EEG = pop_syncroartifacts(EEG, 'Direction','eeglab2erplab'); % GUI: 30-May-2023 21:02:55


fprintf('\n');

if N_interpolate == 0
    warning('No epochs were actually flagged, so no epochs were interpolated!');
    
else
    
    % performance
    % perreject = nnz(interARcounter)/ntrial*100;
    % fprintf('pop_artstep() rejected a %.1f %% of total trials.\n', perreject);
    % fprintf('\n');
    % pop_summary_AR_eeg_detection(EEG, ''); % show table at the command window
    
    
    EEG = eeg_checkset( EEG );
    skipfields = {'EEG', 'Review', 'History'};
    fn  = fieldnames(p.Results);
    com = sprintf( '%s  = pop_artinterp( %s ', inputname(1), inputname(1));
    if many_electrodes
        idx= strcmp(fn,'ChanToInterp');
        fn(idx) = []; 
    end
        
    
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
end
%
% Completion statement
%
msg2end
return