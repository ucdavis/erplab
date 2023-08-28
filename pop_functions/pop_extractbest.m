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
%        'BandPass'    -  If desired, bandpass filtering: [Low_edge_freq High_edge_freq], e.g [8 12];
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
%        'ApplyBP', cmk_bp, 'Bandpass', bpfreq);
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


function [BEST] = pop_extractbest(ALLEEG,varargin)
com= '';

BEST = preloadBEST; 


if nargin<1
    help pop_extractBEST
    return
end

if isobject(ALLEEG)
    whenEEGisanObject
    return
end
   

if nargin ==1 %GUI case, ALLEEG is input
    
    currdata = evalin('base', 'CURRENTSET'); %obtain currently loaded set's index
    
    if currdata==0
        msgboxText =  'pop_extractBEST() error: cannot work an empty dataset!!!';
        title      = 'ERPLAB: No data';
        errorfound(msgboxText, title);
        return
    end

    serror = erplab_eegscanner(ALLEEG(currdata),'pop_extractBEST', 2,0,1,0,1); %requires epoch & event list
    

    if serror
        % need to create error checker if 
        %1: not epoched
        %2: no eventlist (for bin descriptions)
        return
    end
    
    % create working memory
    def  = erpworkingmemory('pop_extractBEST');
    
    nbins = ALLEEG(currdata).EVENTLIST.nbin;

    
    if isempty(def) 
        def = {1:nbins,0,{'',''},1,1}; 

        %1: choose all bins (Def)
        %2: apply freq- transform (1 yes 0 no); 
        %3: bandpass freqs
        %4: include into epochs (def 1: exclude AD flagged epochs)
        %5: exclude epochs with boundary events (def 1:YES, exclude) 
    end
    
    
    
    
    %Call GUIs
    
    %subroutine: binselector 
    % using APP DESIGNER: 
    % cludgy of using a GUI app with output

    %bins_to_use = binselectorGUI(ALLEEG,currdata); %typical way  
    app = feval('binselectorGUI', ALLEEG, currdata, def); %cludgy way
    waitfor(app, 'FinishButton',1); 
    
    %outputs & delete gui
    try
        res = app.output; 
    catch
        disp('User canceled');
        return
    end
    bins_to_use = app.output{1}; %selected bins
    cmk_bp = double(app.output{2}); %apply bandpass?
    bpfreq = cell2mat(app.output{3}); %bandpass frequncies
    artcrite = double(app.output{4}); 
    exclude_be = app.output{5}; 

    if cmk_bp == 0
        bpfreq = [];
    end
    
    app.delete; %delete app/app_object from view
    
    %set working memeory
    erpworkingmemory('pop_extractBEST',res);
    
    
    if isempty(bins_to_use)
        disp('User selected Cancel')
        return
    end
%     
%     if ~isempty(bpfreq)
%         bpfreq = str2num(bpfreq); 
%     end
    
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
    
    %
    % Somersault
    %
    
%     pop_extractBEST(ALLEEG,'DSindex',currdata,'Bins',bins_to_use,...
%         'ApplyBP', cmk_bp, 'Bandpass', bpfreq, 'Filename', filename_empty, 'Filepath', filepath_empty);

    [BEST] = pop_extractbest(ALLEEG,'DSindex',currdata,'Bins',bins_to_use,...
        'Criterion', crit, 'ExcludeBoundary',excbound,  ... 
        'Bandpass', bpfreq,'Saveas', 'on','History','gui');
    
    pause(0.1)
    return
    

end


%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
% input(s)
p.addRequired('ALLEEG', @isstruct);
% option(s)
p.addParamValue('DSindex', 1,@isnumeric); %defaults to 1 
p.addParamValue('Bins', [], @isnumeric);
%p.addParamValue('ApplyBP', 0, @isnumeric);
p.addParamValue('Bandpass', [], @isnumeric);
p.addParamValue('Criterion','good',@ischar);
p.addParamValue('ExcludeBoundary','on',@ischar); 
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History','script',@ischar); 


p.parse(ALLEEG, varargin{:}); 

setindex = p.Results.DSindex; 
bin_ind = p.Results.Bins;
%bandpass_on = p.Results.ApplyBP; 
bandpass_freq = p.Results.Bandpass; 
artcrite = p.Results.Criterion; 
exclude_be = p.Results.ExcludeBoundary; 

if isempty(bin_ind) 
    %if no bins input, then use all bins 
    bin_ind = 1:(ALLEEG.EVENTLIST.nbin); 
end
    


if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
end

if strcmpi(artcrite,'all')
    artif = 0; 
elseif strcmpi(artcrite,'good')
    artif = 1;
elseif strcmpi(artcrite,'bad')
    artif = 2;
end

if strcmpi(exclude_be,'on')
    excbound = 1; 
elseif strcmpi(exclude_be,'off')
    excbound = 2;
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



%main EEG struct
EEG2 = ALLEEG(setindex);
fs_original = EEG2.srate; % need original FS (for frequency transformation)


if ~isempty(bandpass_freq)
    nElectrodes = EEG2.nbchan;
    filtData = nan(EEG2.trials, EEG2.nbchan,EEG2.pnts); 
    unfiltData = permute(EEG2.data,[3 1 2]); 
    
    for c = 1:nElectrodes
        
        filtData(:,c,:) =abs(hilbert(eegfilt(squeeze(unfiltData(:,c,:)),fs_original,bandpass_freq(1,1),bandpass_freq(1,2))')').^2;   %Instantaneous power
    end
    

end


%Obtain indexed EEGSET
% Thanks to AXS, adapted binepEEG_to_binorgEEG.m code following:

dim_data = numel(size(EEG2.data));
if dim_data ~= 3
    msgboxText =  'pop_extractBEST() error: cannot work on continuous data!  Please ensure data is epoched (not continuous)';
    title      = 'ERPLAB: No data';
    errorfound(msgboxText, title);
    %error('binepEEG_to_binorgEEG works on bin-epoched EEG. Please ensure data is epoched (not continuous) and has bin labels');
end


% Prepare info for averager call
% Excludes epochs marked with artifacts and that contains boundary events
stderror = 1; apod = []; nfft = []; dcompu = 1; avgText =0;  

% Call ERP Averager subfunction, populating the epoch_list
[ERP2, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname,epoch_list] = averager(EEG2, artif, stderror, excbound, dcompu, nfft, apod, avgText);

if ~isempty(bandpass_freq) %if bandpassed, add filtered data to EEG2
    
    filtData = permute(filtData,[2 3 1]); 
    EEG2.data = filtData; 
    
end


% Create BEST structure fields from .set file data (subroutine)
BEST = buildBESTstruct(EEG2); %BIN-EPOCHED SINGLE TRIAL (BEST)
nbin = BEST.nbin; 

% Prepare binorg data structure
for bin = 1:nbin
    
    BEST.binwise_data(bin).data = EEG2.data(:,:,epoch_list(bin).good_bep_indx);
    BEST.n_trials_per_bin(bin) = numel(epoch_list(bin).good_bep_indx);
    
end

%output only the selected bins 
BEST.binwise_data = BEST.binwise_data([bin_ind]); 
BEST.n_trials_per_bin = BEST.n_trials_per_bin([bin_ind]); 
BEST.bindesc = BEST.bindesc([bin_ind]);
BEST.original_bin = BEST.original_bin([bin_ind]); 
BEST.nbin = length(bin_ind); 

%
% History
%
skipfields = {'ALLEEG', 'Saveas','Warning','History'};
if isempty(bandpass_freq) == 1 % ERP
    skipfields = [skipfields 'Bandpass'];
end
% if isfield(p.Results,'DQ_spec') == 0 || isempty(p.Results.DQ_spec)
%     skipfields = [skipfields 'DQ_spec'];  % skip DQ spec in History if it was absent
% elseif isfield(p.Results.DQ_spec(1),'comments') && numel(p.Results.DQ_spec(1).comments) >= 1
%         if strcmpi(p.Results.DQ_spec(1).comments{1},'defaults')
%             skipfields = [skipfields 'DQ_spec'];  % skip DQ spec in History if default was used
%         end
% end
fn      = fieldnames(p.Results);
explica = 0;
if length(setindex)==1 && setindex(1)==1
    inputvari  = 'EEG'; % Thanks to Felix Bacigalupo for this suggestion. Dic 12, 2011
    skipfields = [skipfields 'DSindex']; % SL
else
    if length(setindex)==1
        explica   = 1;
    end
    inputvari = inputname(1);
end
bestcom = sprintf( 'BEST = pop_extractbest( %s ', inputvari);
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    bestcom = sprintf( '%s, ''%s'', ''%s''', bestcom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    if all(cellfun(@isnumeric, fn2res))
                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                    else
                        fn2resstr = '';
                        for kk=1:length(fn2res)
                            auxcont = fn2res{kk};
                            if ischar(auxcont);
                                fn2resstr = [fn2resstr '''' auxcont ''''];
                            else
                                fn2resstr = [fn2resstr ' ' vect2colon(auxcont, 'Delimiter', 'on')];
                            end                            
                        end
                    end
                    fnformat = '{%s}';
                elseif isnumeric(fn2res)
                    fn2res = mat2colon(fn2res);  
                    fn2resstr = num2str(fn2res); fnformat = '%s';
                elseif isstruct(fn2res)
                    fn2resstr = 'DQ_spec_structure'; fnformat = '%s';
                else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                
%                 if strcmpi(fn2com,'DSindex') || strcmpi(fn2com,'Bins') || strcmpi(fn2com,'Bandpass')
%                     bestcom = sprintf( ['%s, ''%s'', [', fnformat,']'], bestcom, fn2com, fn2resstr);
%                 else
                bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
%                 end
                
                %bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
            end
        end
    end
end
bestcom = sprintf( '%s );', bestcom);



switch shist
    case 1 % from GUI
        % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        displayEquiComERP(bestcom);
        if explica
            try
                cprintf([0.1333, 0.5451, 0.1333], '%%IMPORTANT: For pop_extractbest, you may use EEG instead of ALLEEG, and remove "''DSindex'',%g"\n',setindex);
            catch
                fprintf('%%IMPORTANT: For pop_extractbest, you may use EEG instead of ALLEEG, and remove ''DSindex'',%g:\n',setindex);
            end
        end
    case 2 % from script
       % ERP = erphistory(ERP, [], bestcom, 1);
    case 3
        % implicit
    otherwise % off or none
        bestcom = '';
end

%
% Save BESTset
%

if issaveas
    [BEST, issave] = pop_savemybest(BEST,'gui','erplab');
    if issave>0
        if issave==2
          %  erpcom  = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your BESTset was saved on your hard drive.***';
        else
            msgwrng = '*** Warning: Your BESTset was only saved on the workspace.***';
        end
    else
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end


msg2end
return