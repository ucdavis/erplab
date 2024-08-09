% PURPOSE  : Create BEST (.mat) file for the loaded subject bin-epoched (.set) file for decoding analyses.
%
% FORMAT   :
%
% >>   [BEST] = pop_extractBEST(ALLEEG,parameters);
%
% INPUTS   :
%
%         EEG or ALLEEG       - input EEG dataset
%
% The available input parameters are as follows:
%
%        'DSindex' 	   - dataset index when dataset are contained within the ALLEEG structure.
%                          For a single bin-epoched dataset using EEG structure this value must be equal to 1 or
%                          left unspecified.
%        'Bins'        -    Bin index array as indicated in binlister file. Example: [1:4]
%                            - If not supplied, all bins will be included
%                            in BESTset.
%        'Criterion'   - Inclusion/exclusion of marked epochs during
%                           artifact detection:
% 		                   'all'   - include all epochs (ignore artifact detections)
% 		                   'good'  - exclude epochs marked during artifact detection
% 		                   'bad'   - include only epochs marked with artifact rejection
%                           Default: 'good';
%        'ExcludeBoundary' - exclude epochs having boundary events.
%                           'on'(def)/'off'
%        'BandPass'    -  If desired, bandpass filtering + Hilbert Transform: [Low_edge_freq High_edge_freq], e.g [8 12]; 
%        'PowerTransform' - Same as BandPass option (bandpass filter + Hilbert Transform)
%
%        'SaveAs'      -  (optional) open GUI for saving BESTset. Not
%                       useful if scripting; use separate call to pop_savemybest().
%                           'on'/'off' (Default: off)
%                           - (if "off", will not update in BESTset menu)
%
% OUTPUTS  :
%
% BEST           -  output BEST structure
%
% EXAMPLE  :
%
% [BEST] = pop_extractBEST(ALLEEG,'DSindex',currdata,'Bins',bins_to_use,'ApplyFS', cmk_fs, ...
%        'ApplyBP', cmk_bp, 'Power Transform', [8 12]);
%
% See also: pop_savemybest.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons and Steven J Luck.
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

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


function [BEST, bestcom] = pop_extractbest(ALLEEG, varargin)
    bestcom = ''; % GH, June 2024

    BEST = preloadBEST;

    if nargin < 1
        help pop_extractBEST;
        return;
    end

    if isobject(ALLEEG)
        whenEEGisanObject;
        return;
    end

    if nargin == 1 % GUI case, ALLEEG is input
        currdata = evalin('base', 'CURRENTSET'); % obtain currently loaded set's index

        if currdata == 0
            msgboxText = 'pop_extractBEST() error: cannot work an empty dataset!!!';
            title = 'ERPLAB: No data';
            errorfound(msgboxText, title);
            return;
        end

        serror = erplab_eegscanner(ALLEEG(currdata), 'pop_extractBEST', 2, 0, 1, 0, 1); % requires epoch & event list

        if serror
            return;
        end

        % create working memory
        def = erpworkingmemory('pop_extractBEST');

        nbins = ALLEEG(currdata).EVENTLIST.nbin;

        if isempty(def)
            def = {1:nbins, 0, {'', ''}, 1, 1};
        end

        % Call GUIs
        app = feval('binselectorGUI', ALLEEG, currdata, def);
        waitfor(app, 'FinishButton', 1);

        try
            res = app.output;
        catch
            disp('User canceled');
            return;
        end

        bins_to_use = app.output{1}; % selected bins
        cmk_bp = double(app.output{2}); % apply bandpass?
        bpfreq = cell2mat(app.output{3}); % bandpass frequencies
        artcrite = double(app.output{4});
        exclude_be = app.output{5};

        if cmk_bp == 0
            bpfreq = [];
        end

        app.delete; % delete app/app_object from view

        erpworkingmemory('pop_extractBEST', res);

        if isempty(bins_to_use)
            disp('User selected Cancel');
            return;
        end

        if artcrite == 0
            crit = 'all';
        elseif artcrite == 1
            crit = 'good';
        elseif artcrite == 2
            crit = 'bad';
        end

        if exclude_be == 1
            excbound = 'on';
        else
            excbound = 'off';
        end

        [BEST] = pop_extractbest(ALLEEG, 'DSindex', currdata, 'Bins', bins_to_use, ...
            'Criterion', crit, 'ExcludeBoundary', excbound, ...
            'PowerTransform', bpfreq, 'Saveas', 'on', 'History', 'gui');

        pause(0.1);
        return;
    end

    % Parsing inputs
    p = inputParser;
    p.FunctionName = mfilename;
    p.CaseSensitive = false;
    p.addRequired('ALLEEG', @isstruct);
    p.addParamValue('DSindex', 1, @isnumeric); % defaults to 1
    p.addParamValue('Bins', [], @isnumeric);
    p.addParamValue('Bandpass', [], @isnumeric);
    p.addParamValue('PowerTransform', [], @isnumeric);
    p.addParamValue('Criterion', 'good', @ischar);
    p.addParamValue('ExcludeBoundary', 'on', @ischar);
    p.addParamValue('Saveas', 'off', @ischar);
    p.addParamValue('History', 'script', @ischar);
    p.addParamValue('Tooltype', 'erplab', @ischar); % GH, June 2024

    p.parse(ALLEEG, varargin{:});

    setindex = p.Results.DSindex;
    bin_ind = p.Results.Bins;
    freq_transform = p.Results.Bandpass;

    if isempty(freq_transform)
        freq_transform = p.Results.PowerTransform;
    end

    artcrite = p.Results.Criterion;
    exclude_be = p.Results.ExcludeBoundary;

    if isempty(bin_ind)
        bin_ind = 1:(ALLEEG.EVENTLIST.nbin);
    end

    if ismember_bc2({p.Results.Saveas}, {'on', 'yes'})
        issaveas = 1;
    else
        issaveas = 0;
    end

    Tooltype = p.Results.Tooltype; % GH, June 2024
    if isempty(Tooltype) % GH, June 2024
        Tooltype = 'erplab';
    end

    if strcmpi(artcrite, 'all')
        artif = 0;
    elseif strcmpi(artcrite, 'good')
        artif = 1;
    elseif strcmpi(artcrite, 'bad')
        artif = 2;
    end

    if strcmpi(exclude_be, 'on')
        excbound = 1;
    elseif strcmpi(exclude_be, 'off')
        excbound = 2;
    end

    if strcmpi(p.Results.History, 'implicit')
        shist = 3; % implicit
    elseif strcmpi(p.Results.History, 'script')
        shist = 2; % script
    elseif strcmpi(p.Results.History, 'gui')
        shist = 1; % gui
    else
        shist = 0; % off
    end

    EEG2 = ALLEEG(setindex);
    fs_original = EEG2.srate; % original FS (for frequency transformation)

    if ~isempty(freq_transform)
        nElectrodes = EEG2.nbchan;
        filtData = nan(EEG2.trials, EEG2.nbchan, EEG2.pnts);
        unfiltData = permute(EEG2.data, [3 1 2]);

        for c = 1:nElectrodes
            filtData(:, c, :) = abs(hilbert(eegfilt(squeeze(unfiltData(:, c, :)), fs_original, freq_transform(1), freq_transform(2))')').^2; % Instantaneous power
        end
    end

    dim_data = numel(size(EEG2.data));
    if dim_data ~= 3
        msgboxText = 'pop_extractBEST() error: cannot work on continuous data! Please ensure data is epoched (not continuous)';
        title = 'ERPLAB: No data';
        errorfound(msgboxText, title);
    end

    % Prepare info for averager call
    % Excludes epochs marked with artifacts and that contains boundary events
    stderror = 1; apod = []; nfft = []; dcompu = 1; avgText =0;

    [ERP2, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname, epoch_list] = averager(EEG2, artif, stderror, excbound, dcompu, nfft, apod, avgText);

    if ~isempty(freq_transform)
        filtData = permute(filtData, [2 3 1]);
        EEG2.data = filtData;
    end

    BEST = buildBESTstruct(EEG2); % BIN-EPOCHED SINGLE TRIAL (BEST)
    nbin = BEST.nbin;

    for bin = 1:nbin
        BEST.binwise_data(bin).data = EEG2.data(:, :, epoch_list(bin).good_bep_indx);
        BEST.n_trials_per_bin(bin) = numel(epoch_list(bin).good_bep_indx);
    end

    BEST.binwise_data = BEST.binwise_data([bin_ind]);
    BEST.n_trials_per_bin = BEST.n_trials_per_bin([bin_ind]);
    BEST.bindesc = BEST.bindesc([bin_ind]);
    BEST.original_bin = BEST.original_bin([bin_ind]);
    BEST.nbin = length(bin_ind);

    % History
    skipfields = {'ALLEEG', 'Saveas', 'Warning', 'History'};
    if isempty(freq_transform) == 1 % ERP
        skipfields = [skipfields, 'Bandpass', 'PowerTransform'];
    end

    fn = fieldnames(p.Results);
    explica = 0;
    if length(setindex) == 1 && setindex(1) == 1
        inputvari = 'EEG';
        skipfields = [skipfields, 'DSindex'];
    else
        if length(setindex) == 1
            explica = 1;
        end
        inputvari = inputname(1);
    end

    bestcom = sprintf('BEST = pop_extractbest( %s ', inputvari);
    for q = 1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
            fn2res = p.Results.(fn2com);
            if ~isempty(fn2res)
                if ischar(fn2res)
                    if ~strcmpi(fn2res, 'off')
                        bestcom = sprintf('%s, ''%s'', ''%s''', bestcom, fn2com, fn2res);
                    end
                else
                    if iscell(fn2res)
                        if all(cellfun(@isnumeric, fn2res))
                            fn2resstr = vect2colon(cell2mat(fn2res), 'Sort', 'on');
                        else
                            fn2resstr = '';
                            for kk = 1:length(fn2res)
                                auxcont = fn2res{kk};
                                if ischar(auxcont)
                                    fn2resstr = sprintf('%s''%s'' ', fn2resstr, auxcont);
                                end
                            end
                        end
                        bestcom = sprintf('%s, ''%s'', {%s}', bestcom, fn2com, fn2resstr);
                    elseif isnumeric(fn2res)
                        bestcom = sprintf('%s, ''%s'', %s', bestcom, fn2com, vect2colon(fn2res, 'Sort', 'on'));
                    end
                end
            end
        end
    end

    bestcom = sprintf('%s);', bestcom);
    if issaveas
        bestcom = sprintf('%s saveas;');
    end

    bestcom = sprintf('%s %% GUI: %s', bestcom, datestr(clock));
    bestcom = sprintf('%s %% Done!\n\n', bestcom);

    % End
    msg2end = 'A new BEST set was successfully created and loaded!';
    fprintf('\n%s\n', msg2end);

    if ~isempty(freq_transform)
        freq_msg = sprintf('Frequency transformation applied with cutoff frequencies: %0.2f-%0.2f Hz.', freq_transform(1), freq_transform(2));
        fprintf('%s\n', freq_msg);
    end
end