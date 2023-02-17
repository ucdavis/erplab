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
%                          For single bin-epoched dataset using EEG structure this value must be equal to 1 or
%                          left unspecified.
%        'Bins'        -    Bin index array as indicated in binlister file. Example: [1:4]
%        'ApplyFS'     -  If bandpass filtering, must be 1. Default = 0
%        'BandPass'    -  For bandpass filtering: [Low_edge_freq High_edge_freq], e.g [8 12];
%        'SaveAs'      -  (optional) open GUI for saving BESTset.
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

%load current MVPA
%MVPA = evalin('base', 'MVPA');  
    

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
        % need to create error checker if EVENTLIST is not found
        return
    end
    
    % need to create working memory for this feature? 
    % yes, for selecting the same bins as last time 
    def  = erpworkingmemory('pop_extractBEST');
    
    %instead of downsampling, resample as follow:
    % - check EEGstruct for "pnts"
    % - provide textbox for "every N [textbox] point" 
    % - calculate what that would be as a resampled value and show 
    % - e.g. "every 5th point" = 1/fs = 0.030 * 5 = 20ms 
    
    if isempty(def) 
        def = {1,0,{'',''}}; 
        %def = {1,0,[]}; 
        
        %1: choose bin1 only; 
        %2: apply freq- transform (1 yes 0 no); 
        %3: bandpass freqs
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
%     cmk_fs = app.output{2}; %apply resampling?
%     srate = app.output{3}; %resample value in terms of $ of sample steps
    cmk_bp = double(app.output{2}); %apply bandpass?
    bpfreq = cell2mat(app.output{3}); %bandpass frequncies
   % filename_empty = '' ;%ALLEEG(currdata).filename; 
   % filepath_empty = '' ;%ALLEEG(currdata).filepath; 
    
    
    app.delete; %delete app/app_object from view
    
    %set working memeory
    erpworkingmemory('pop_extractBEST',res);
    
    
    if isempty(bins_to_use)
        disp('User selected Cancel')
        return
    end
    
    if isempty(bpfreq)
        bpfreq = str2num(bpfreq); 
    end
    
    
    %
    % Somersault
    %
    
%     pop_extractBEST(ALLEEG,'DSindex',currdata,'Bins',bins_to_use,...
%         'ApplyBP', cmk_bp, 'Bandpass', bpfreq, 'Filename', filename_empty, 'Filepath', filepath_empty);

    [BEST] = pop_extractbest(ALLEEG,'DSindex',currdata,'Bins',bins_to_use,...
        'ApplyBP', cmk_bp, 'Bandpass', bpfreq, 'Saveas', 'on');
    
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
p.addParamValue('ApplyBP', 0, @isnumeric);
p.addParamValue('Bandpass', [], @isnumeric);
p.addParamValue('Saveas', 'off', @ischar); 
% p.addParamValue('Filename', [], @ischar); 
% p.addParamValue('Filepath', [], @ischar); 

p.parse(ALLEEG, varargin{:}); 

setindex = p.Results.DSindex; 
bin_ind = p.Results.Bins;
% fschange_on = p.Results.ApplyFS; 
% fs_newsteps = p.Results.SampleRate;
bandpass_on = p.Results.ApplyBP; 
bandpass_freq = p.Results.Bandpass; 
% filenamex = p.Results.Filename; 
% filepathx = p.Results.Filepath; 

if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
end

%main EEG struct
EEG2 = ALLEEG(setindex);
fs_original = EEG2.srate; % need original FS (for alpha transformation)


if bandpass_on == 1
    %delete(gcp); 
    %parpool; 
    %apply transform before any downsampling
    % low-pass filtering
    
    
    
    %filtData = nan(nTrials,nElectrodes,nTimes);
    nElectrodes = EEG2.nbchan;
    
    for c = 1:nElectrodes
        EEG2.data(c,:,:) =abs(hilbert(eegfilt(squeeze(EEG2.data(c,:,:)),fs_original,bandpass_freq(1,1),bandpass_freq(1,2))')').^2;   %Instantaneous power
    end
    
    
    
end


%check sampling rate and resample (if chosen **DEFUNCT**)
% if fschange_on == 1
%     
%     %change EEG2 fields to new resampled data
%     %samp_index = 1:fs_newsteps:EEG2.pnts;
%     %find 0 ms
%     zero_index = find(EEG2.times == 0); 
%     
%     samp_index_post = [zero_index:fs_newsteps:EEG2.pnts]; 
%     samp_index_pre = [zero_index-fs_newsteps:-4:1]; 
%     samp_index = sort([samp_index_pre samp_index_post]); 
%     EEG2.data = EEG2.data(:,samp_index,:); 
%     EEG2.xmax = EEG2.times(samp_index(end));
%     
%     npnts_old = EEG2.pnts;
%     fs = EEG2.srate;
%     samps = 1/fs; %granularity of data sample in ms
%     epochtime = (samps*npnts_old) * 1000 ; %ms
%     npnts_new = length(samp_index); 
%     EEG2.pnts = npnts_new; 
%     
%     new_FS = (npnts_new/epochtime * 1000); 
%     EEG2.srate = new_FS; 
%     
%     EEG2.times = EEG2.times(samp_index); 
%     
%     
%     
% end



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
artif = 1; stderror = 1; excbound = 1; apod = []; nfft = []; dcompu = 1; avgText =0;  

% Call ERP Averager subfunction, populating the epoch_list
[ERP2, EVENTLISTi, countbiORI, countbinINV, countbinOK, countflags, workfname,epoch_list] = averager(EEG2, artif, stderror, excbound, dcompu, nfft, apod, avgText);


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
% Save BESTset
%

if issaveas
    [BEST, issave] = pop_savemybest(BEST,'gui','erplab');
    if issave>0
        if issave==2
            %erpcom  = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your BESTset was saved on your hard drive.***';
        else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
        end
    else
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end


% %Save function
% 
% if isempty(filenamex) 
%     currFilename = EEG2.filename;
%     currFilepath = pwd;
%     %MVPA = pop_savemymvpa(MVPA,'fname', currFilename, 'fpath', currFilepath);
%     pop_savemybest(BEST,'fname', currFilename, 'fpath', currFilepath);
% else
%     currFilename = filenamex;
%     currFilepath = filepathx;
%     pop_savemybest(BEST,'fname', currFilename, 'fpath', currFilepath, 'modegui', 0);
% end

% [file_name, file_path] = uiputfile('*.mvpa','Please pick a path to save the MVPA dataset');
% write_file_path = [file_path file_name];
% save(write_file_path,'MVPA');
    
msg2end
return