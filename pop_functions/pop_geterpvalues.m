% PURPOSE  :	Measures values from ERPset data (Instantaneous amplitude, mean amplitude, peak amplitude, etc.)
%
% FORMAT   :
%
% pop_geterpvalues(ALLERP, latency, binArray, chanArray, parameters);
%
% or
%
% pop_geterpvalues(filename, latency, binArray, chanArray, parameters);
%
%
% INPUTS   :
%
% ALLERP        - structure array of ERP structures (ERPsets)
%                 To read the ERPset from a list in a text file,
%                 replace ALLERP by the whole filename.
% latency       - one or two latencies in msec. e.g. [80 120]
% binArray      - index(es) of bin(s) from which values will be extracted. e.g. 1:5
% chanArray     - index(es) of channel(s) from which values will be extracted. e.g. [10 2238 39 40]
%
%
% The available parameters are as follows:
%
% 'Erpsets'         - erpset index(ices) from which values will be extracted. e.g. 5:15 (only valid when ALLERP is specified)
% 'Measure'         - type of measurement (see below)
% 'Resolution'      - number of digit for values
% 'Baseline'        - time window for baseline the measured values.
% 'Binlabel'        - {'on'/'off'} include bin label in each measurement
% 'Peakpolarity'    - {'positive'/'negative'} | peak polarity for peak detection.
% 'Neighborhood'    - number of points, in each side, for comparing the local peak value.
%                     Local peak value must reach the following two criteria:(i) be larger than both adjacent points, and (ii) be larger
%                     than the average of the two adjacent neighborhood (specified by "Neighborhood")
%
% 'Peakreplace'     - in case local peak is not found replace the output by the absolute peak value (absolute) or a not-a-number value (NaN).
% 'Fracreplace'     - in case fractional local peak is not found replace the output by the absolute fractional peak value (absolute) or a not-a-number value (NaN).
% 'Warning'         - {'on'/'off'} show warning popup window
% 'Filename'        - name of text file for output. e.g. 'S03_N100_peak.txt'
% 'Append'          -
% 'Afraction'       - fractional percent for getting fractional area latency
% 'FileFormat'      - output format
% 'SendtoWorkspace' - {'on'/'off'} send values to workspace (matrix)
% 'Viewer'          - open viewer
% 'Mlabel'          - include a measurement label
% 'Peakonset'       - 1 indicates finding the pre-peak onset for measuring fractional amplitude, 2 indicates finding the post-peak offset
%
%
%
% Example  :
%
% pop_geterpvalues( ALLERP, 0, 1, 1, 'Baseline', 'pre', 'Erpsets', 1,...
% 'Filename', 'test.txt', 'FileFormat', 'erpset', 'Fracreplace', 'NaN',...
% 'IncludeLat', 'no', 'Measure', 'instabl', 'Resolution', 3, 'Warning', 'on' );
%
%
% The value for the parameter 'Measure' can be either of the following:
%
% 'instabl'     - finds the relative-to-baseline instantaneous value at the specified latency.
% 'meanbl'      - calculates the relative-to-baseline mean amplitude value between two latencies.
% 'peakampbl'   - finds the relative-to-baseline peak (or valley) value between two latencies.
% 'peaklatbl'   - finds the time at which the relative-to-baseline peak (or valley) value between two latencies occurs.
% 'area'        - calculates the area under the curve value between two latencies.
% 'areaz'       - calculates the area under the curve value. Lower and upper
%                 limit of integration area automatically found with a user
%                 defined "seed" latency. Seed latency is located between the
%                 zero-crossing points, which erplab will calculate.
%
%
% See also geterpvaluesGUI2.m geterpvalues.m, exportvalues2xls.m, exportvaluesV2.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
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
% BUGs and Improvements :
% ----------------------
% Measurement label option included. Suggested by Paul Kieffaber
% Local peak bug (when multiple peaks) fixed. Thanks Tanya Zhuravleva

function [ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP, latency, binArray, chanArray, varargin)
erpcom = '';
Amp = [];
Lat = [];
if nargin<1
        help pop_geterpvalues
        return
end
if nargin==1  % GUI
        if isstruct(ALLERP)
                if ~iserpstruct(ALLERP(1));
                        ALLERP = [];
                        nbinx  = 1;
                        nchanx = 1;
                else
                        nbinx  = ALLERP(1).nbin;
                        nchanx = ALLERP(1).nchan;
                end
        else
                ALLERP = [];
                nbinx = 1;
                nchanx = 1;
        end
        cerpi = evalin('base', 'CURRENTERP'); % current erp index
        def   = erpworkingmemory('pop_geterpvalues');
        if isempty(def)
                if isempty(ALLERP)
                        inp1   = 1; %from hard drive
                        erpset = [];
                else
                        inp1   = 0; %from erpset menu
                        erpset = 1:length(ALLERP);
                end
                
                def = {inp1 erpset '' 0 1:nbinx 1:nchanx 'instabl' 1 3 'pre' 0 1 5 0 0.5 0 0 0 '' 0 1};
        else
                if ~isempty(ALLERP)
                        if isnumeric(def{2}) % JavierLC 11-17-11
                                [uu, mm] = unique_bc2(def{2}, 'first');
                                erpset_list_sorted   = [def{2}(sort(mm))];
                                %def{2}   = def{2}(def{2}<=length(ALLERP));
                                % non-empty check, axs jul17
                                erpset_list = erpset_list_sorted(erpset_list_sorted<=length(ALLERP));
                                if isempty(erpset_list)
                                     % if nothing in list, just go with current
                                     def{2} = cerpi;
                                else
                                    % use JLC's sorting, iff not empty
                                    def{2} = erpset_list;
                                end
                                
                        end
                end
        end
        
        %
        % call GUI
        %
        instr = geterpvaluesGUI2(ALLERP, def, cerpi);% open a GUI
        
        if isempty(instr)
                disp('User selected Cancel')
                return
        end
        
        optioni    = instr{1}; %1 means from hard drive, 0 means from erpsets menu
        erpset     = instr{2};
        fname      = instr{3};
        latency    = instr{4};
        binArray   = instr{5};
        chanArray  = instr{6};
        moption    = instr{7}; % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
        coi        = instr{8};
        dig        = instr{9};
        blc        = instr{10};
        binlabop   = instr{11}; % 0: bin number as bin label, 1: bin descriptor as bin label for table.
        polpeak    = instr{12}; % local peak polarity
        sampeak    = instr{13}; % number of samples (one-side) for local peak detection criteria
        locpeakrep = instr{14}; % 1 abs peak , 0 Nan
        frac       = instr{15};
        fracmearep = instr{16}; % 1 zero , 0 Nan. Fractional area latency replacement
        send2ws    = instr{17}; % send measurements to workspace
        appfile    = instr{18}; % 1 means append file  (it wont get into wmemory), 3 means call filter GUI
        foutput    = instr{19};
        mlabel     = instr{20};
        inclate    = instr{21}; % include used latency values for measurements like mean, peak, area...
        intfactor  = instr{22};
        viewmea    = instr{23}; % viewer
        peak_onset = instr{24}; % 1 for 
        
        if optioni==1 % from files
                filelist    = erpset;
                disp(['pop_geterpvalues(): For file-List, user selected ', filelist])
                fid_list    = fopen( filelist );
                inputfnamex = textscan(fid_list, '%[^\n]','CommentStyle','#');
                inputfname  = cellstr(char(inputfnamex{:}));
                fclose(fid_list);
                ALLERP = {ALLERP, filelist}; % truco
        elseif optioni==2 % from current erpset (single)
                erpset  = cerpi;
        else % from erpsets menu
                %erpset  = erpset;
        end
        if strcmpi(fname,'no_save.no_save') %|| strcmpi(fname,'no_save.viewer')
                fnamer = '';
        else
                fnamer = fname;
        end
        if send2ws
                s2ws = 'on'; % send to workspace
        else
                s2ws = 'off';
        end
        if viewmea
                vmstr = 'on'; % open viewer
        else
                vmstr = 'off';
        end
        
        erpworkingmemory('pop_geterpvalues', {optioni, erpset, fnamer, latency,...
                binArray, chanArray, moption, coi, dig, blc, binlabop, polpeak,...
                sampeak, locpeakrep, frac, fracmearep, send2ws, foutput, mlabel,...
                inclate, intfactor, peak_onset});
        
        if binlabop==0
                binlabopstr = 'off';
        else
                binlabopstr = 'on';
        end
        if polpeak==0
                polpeakstr = 'negative';
        else
                polpeakstr = 'positive';
        end
        if locpeakrep==0
                locpeakrepstr = 'NaN';
        else
                locpeakrepstr = 'absolute';
        end
        if fracmearep==0 % Fractional area latency replacement
                fracmearepstr = 'NaN';
        else
                if ismember_bc2({moption}, {'fareatlat', 'fninteglat','fareaplat','fareanlat'})
                        fracmearepstr = 'errormsg';
                else
                        fracmearepstr = 'absolute';
                end
        end
        if appfile
                appfstr = 'on';
        else
                appfstr = 'off';
        end
        if foutput % 1 means "long format"; 0 means "wide format"
                foutputstr = 'long';
        else
                foutputstr = 'wide';
        end
        if inclate
                inclatestr = 'yes';
        else
                inclatestr = 'no';
        end
        
        %
        % Somersault
        %
        
        %latency, binArray, chanArray, erpset, moption, coi, dig, blc, binlabopstr, polpeakstr, sampeak, locpeakrepstr, fname, s2ws, appfstr, foutputstr, frac, mlabel, fracmearepstr, inclatestr, intfactor, vmstr
        
        [ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP, latency, binArray, chanArray, 'Erpsets', erpset, 'Measure',...
                moption, 'Component', coi, 'Resolution', dig, 'Baseline', blc, 'Binlabel', binlabopstr, 'Peakpolarity',...
                polpeakstr, 'Neighborhood', sampeak, 'Peakreplace', locpeakrepstr, 'Filename', fname, 'Warning','on',...
                'SendtoWorkspace', s2ws, 'Append', appfstr, 'FileFormat', foutputstr,'Afraction', frac, 'Mlabel', mlabel,...
                'Fracreplace', fracmearepstr,'IncludeLat', inclatestr, 'InterpFactor', intfactor, 'Viewer', vmstr,...
                'PeakOnset',peak_onset,'History', 'gui');
        
        pause(0.1)
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
p.addRequired('latency',  @isnumeric);
p.addRequired('binArray', @isnumeric);
p.addRequired('chanArray',@isnumeric);
% option(s)
p.addParamValue('Erpsets', 1); % erpset index or input file
p.addParamValue('Measure', 'instabl', @ischar);
p.addParamValue('Component', 0, @isnumeric); % overlapped component ignored
p.addParamValue('Resolution', 3, @isnumeric);
p.addParamValue('Baseline', 'pre');
p.addParamValue('Binlabel', 'off', @ischar);
p.addParamValue('Peakpolarity', 'positive', @ischar);
p.addParamValue('Neighborhood', 0, @isnumeric);
p.addParamValue('Peakreplace', 'NaN');
p.addParamValue('Fracreplace', 'NaN');
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('Filename', 'tempofile.no_save', @ischar); %output file
p.addParamValue('Append', 'off', @ischar);      %
p.addParamValue('Afraction', 0.5, @isnumeric);  %
p.addParamValue('FileFormat', 'long', @ischar); %output format
p.addParamValue('IncludeLat', 'off', @ischar);  %
p.addParamValue('SendtoWorkspace', 'off', @ischar);
p.addParamValue('Mlabel', '', @ischar);
p.addParamValue('InterpFactor', 1, @isnumeric);
p.addParamValue('Viewer', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.addParamValue('PeakOnset',1,@isnumeric);

% Parsing
p.parse(ALLERP, latency, binArray, chanArray, varargin{:});

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
% Measurement types
%
meacell = {'instabl', 'meanbl', 'peakampbl', 'peaklatbl', 'fpeaklat',...
        'areat', 'areap', 'arean','areazt','areazp','areazn','fareatlat',...
        'fareaplat','fninteglat','fareanlat', 'ninteg','nintegz' };

measurearray = {'Instantaneous amplitude','Mean amplitude between two fixed latencies',...
        'Peak amplitude','Peak latency','Fractional Peak latency',...
        'Numerical integration/Area between two fixed latencies',...
        'Numerical integration/Area between two (automatically detected) zero-crossing latencies'...
        'Fractional Area latency', ''};

%
% Get inputs
%
erpsetArray  = p.Results.Erpsets;
cond1 = iserpstruct(ALLERP);
cond2 = isnumeric(erpsetArray);
if isempty(latency)
        latency = 0;
end
if cond1 && cond2 % either from GUI or script, when ALLERP exist and erpset indices were specified        
        if isempty(erpsetArray)
                erpsetArray =1:length(ALLERP);
        elseif erpsetArray==0
                try
                        erpsetArray = evalin('base', 'CURRENTERP'); % current erp index
                catch
                        erpsetArray = length(ALLERP);
                end
                
        end
        nfile     = length(erpsetArray);
        optioni   = 0; % from erpset menu or ALLERP struct
        
        if isempty(binArray) % JLC
                binArray = 1:min([ALLERP(erpsetArray).nbin]);
        end
        if isempty(chanArray)
                chanArray = 1:min([ALLERP(erpsetArray).nchan]);
        end
else
        filelist = '';
        optioni  = 1; % from file
        if iscell(ALLERP) % from the GUI, when ALLERP exist and user picks a list up as well
                filelist = ALLERP{2};
                ALLERP   = ALLERP{1};
        elseif ischar(ALLERP) % from script, when user picks a list.
                filelist = ALLERP;
        end
        if isempty(binArray) % JLC
                binArray = 1;
        end
        if isempty(chanArray)
                chanArray = 1;
        end
        if ~iscell(filelist) && ~isempty(filelist)
                disp(['For file-List, user selected ', filelist])
                fid_list    = fopen( filelist );
                inputfnamex = textscan(fid_list, '%[^\n]','CommentStyle','#');
                inputfname  = cellstr(char(inputfnamex{:}));
                nfile       = length(inputfname);
                fclose(fid_list);
        elseif ~isempty(filelist) && iscell(filelist)
                inputfname = filelist;
                nfile      = length(inputfname);                
        else
                error('ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ')
        end
        if isempty(erpsetArray)
                erpsetArray =1:nfile;
        elseif erpsetArray==0
                try
                        erpsetArray = evalin('base', 'CURRENTERP'); % current erp index
                catch
                        erpsetArray = nfile;
                end
                
        end
end

fname    = p.Results.Filename;
localrep = p.Results.Peakreplace;
fraclocalrep = p.Results.Fracreplace;
frac     = p.Results.Afraction; % for fractional area latency, any value from 0 to 1
mlabel   = p.Results.Mlabel; % label for measurement
mlabel   = strtrim(mlabel);
mlabel   = strrep(mlabel, ' ', '_');

if ~isempty(frac)
        if frac<0 || frac>1
                error('ERPLAB says: error at pop_geterpvalues(). Fractional area value must be between 0 and 1')
        end
end
if ischar(localrep)
        lr = str2num(localrep);
        if isempty(lr)
                if strcmpi(localrep,'absolute')
                        locpeakrep = 1;
                else
                        error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' localrep])
                end
        else
                if isnan(lr)
                        locpeakrep = 0;
                else
                        error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' localrep])
                end
        end
else
        if isnan(localrep)
                locpeakrep = 0;
        else
                error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' num2str(localrep(1))])
        end
end
if ischar(fraclocalrep)
        flr = str2num(fraclocalrep);
        if isempty(flr)
                if strcmpi(fraclocalrep,'absolute')
                        fracmearep = 1;
                elseif strcmpi(fraclocalrep,'error') || strcmpi(fraclocalrep,'errormsg')
                        fracmearep = 2; % shows error message. Stop measuring.
                else
                        error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' fraclocalrep])
                end
        else
                if isnan(flr)
                        fracmearep = 0;
                else
                        error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' fraclocalrep])
                end
        end
else
        if isnan(fraclocalrep)
                fracmearep = 0;
        else
                error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' num2str(fraclocalrep(1))])
        end
end

sampeak = p.Results.Neighborhood; % samples around the peak

if strcmpi(p.Results.Peakpolarity, 'positive')
        polpeak = 1; % positive
elseif strcmpi(p.Results.Peakpolarity, 'negative')
        polpeak = 0;
else
        error(['ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ' p.Results.Peakpolarity]);
end
if strcmpi(p.Results.Binlabel, 'on')
        binlabop = 1; % bin descriptor as bin label for table
elseif strcmpi(p.Results.Binlabel, 'off')
        binlabop = 0; % bin# as bin label for table
else
        error(['ERPLAB says: Unrecognizable input ' p.Results.Binlabel]);
end

blc     = p.Results.Baseline;
dig     = p.Results.Resolution;
coi     = p.Results.Component;
moption = lower(p.Results.Measure);

peak_onset = p.Results.PeakOnset;

if isempty(moption)
        error('ERPLAB says: User must specify a type of measurement.')
end
if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'});
        if length(latency)~=1
                error(['ERPLAB says: ' moption ' only needs 1 latency value.'])
        end
else
        if length(latency)~=2
                error(['ERPLAB says: ' moption ' needs 2 latency values.'])
        else
                if latency(1)>=latency(2)
                        msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                        title = 'ERPLAB: pop_geterpvalues() inputs';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        end
end
if strcmpi(p.Results.Warning, 'on')
        menup = 1; % enable warning message
else
        menup = 0;
end
if strcmpi(p.Results.SendtoWorkspace, 'on')
        send2ws = 1; % send to workspace
else
        send2ws = 0;
end
if strcmpi(p.Results.Viewer, 'on')
        viewmea = 1; % open viewer
else
        viewmea = 0;
end
if strcmpi(p.Results.Append, 'on')
        appendfile = 1;
else
        appendfile = 0;
end
if strcmpi(p.Results.FileFormat, 'long')
        foutput = 1; % 1 means "long format"; 0 means "wide format"
else
        foutput = 0;
end
if strcmpi(p.Results.IncludeLat, 'yes') || strcmpi(p.Results.IncludeLat, 'on')
        inclate = 1;
else
        inclate = 0;
end

intfactor = p.Results.InterpFactor;

if ~ismember_bc2({moption}, meacell);
        msgboxText =  [moption ' is not a valid option for pop_geterpvalues!'];
        if shist == 1; % gui
                title = 'ERPLAB: pop_geterpvalues wrong inputs';
                errorfound(msgboxText, title);
                return
        else
                error(msgboxText)
        end
end
if ischar(blc)
        blcorrstr = [''''  blc '''' ];
else
        blcorrstr = ['[' num2str(blc) ']'];
end
if ~viewmea
        [pathtest, filtest, ext] = fileparts(fname);
        
        if isempty(filtest)
                error('File name is empty.')
        end
        if strcmpi(ext,'.xls')
                fprintf('\nWARNING:\n');
                title    = 'ERPLAB: WARNING, pop_geterpvalues() export to Excel' ;
                question = ['Sorry. Export to Excel  is not longer supported by ERPLAB.\n\n'...
                        'Do you want to continue anyway using a text file instead?'];
                button = askquest(sprintf(question), title);
                
                if ~strcmpi(button,'yes')
                        disp('User selected Cancel')
                        return
                end
                if strcmp(pathtest,'')
                        pathtest = cd;
                end
                ext   = '.txt';
                fname = fullfile(pathtest, [filtest ext]);
                fprintf('\nOutput file will have extension %s\n', ext);
                exceloption = 0;                
                send_to_file = 1;               
                %                 if ispc
                %                         exceloption = 1;
                %                         fprintf('\nOutput will be a Microsoft Excel spreadsheet file');
                %                         warning off MATLAB:xlswrite:AddSheet
                %                         if strcmp(pathtest,'')
                %                                 pathtest = cd;
                %                                 fname = fullfile(pathtest, [filtest ext]);
                %                         end
                %                 else
                %                         fprintf('\nWARNING:\n');
                %                         title    = 'ERPLAB: WARNING, pop_geterpvalues() export to Excel' ;
                %                         question = ['The full functionality of XLSWRITE depends on the ability '...
                %                                 'to instantiate Microsoft Excel as a COM server.\n\n'...
                %                                 'COM is a technology developed for Windows platforms and, '...
                %                                 'at the current ERPLAB version,  is not available for non-Windows machines\n\n'...
                %                                 'Do you want to continue anyway with a text file instead?'];
                %                         button = askquest(sprintf(question), title);
                %
                %                         if ~strcmpi(button,'yes')
                %                                 disp('User selected Cancel')
                %                                 return
                %                         end
                %                         if strcmp(pathtest,'')
                %                                 pathtest = cd;
                %                         end
                %                         ext   = '.txt';
                %                         fname = fullfile(pathtest, [filtest ext]);
                %                         fprintf('\nOutput file will have extension %s\n', ext);
                %                         exceloption = 0;
                %                 end
                %                 send_to_file = 1;
        elseif strcmpi(ext,'.no_save')
                send_to_file = 0;
        elseif strcmpi(ext,'.viewer') % temporary
                send_to_file = 0;
        else
                exceloption = 0;
                if strcmp(pathtest,'')
                        pathtest = cd;
                end
                if ~strcmpi(ext,'.txt')&& ~strcmpi(ext,'.dat')
                        ext = '.txt';
                        fname = fullfile(pathtest, [filtest ext]);
                end
                fprintf('\nOutput file will have extension %s\n', ext);
                send_to_file = 1;
        end
else
        send_to_file = 0;
end
fprintf('\nBaseline period = %s will be used for measurements\n\n', blcorrstr);

if optioni==1 % from files
        erpsetArray = 1:nfile; % JLC. Sept 2012
end

conti = 1;
Lat   = {[]};

for k=1:nfile
        if optioni==1 % from files
                filex = load(inputfname{k}, '-mat');
                ERP   = filex.ERP;
                [ERP, conti, serror] = olderpscan(ERP, menup);
                if viewmea==1 && conti==1 && serror==0
                        if k==1
                                ALLERPX = buildERPstruct([]); % auxiliar ALLERP
                        end
                        ALLERPX(k) = ERP;
                end
        else          % from erpsets
                ERP = ALLERP(erpsetArray(k));
                [ERP, conti, serror] = olderpscan(ERP, menup);
        end
        if conti==0
                break
        end
        if serror ==1
                kindex = k;
                kname  = ERP.erpname;
                break
        end
        if k==1
                n1bin   = ERP.nbin;
                n1chan  = ERP.nchan;
                n1bdesc = ERP.bindescr;
                
                if isempty(binArray) % JLC
                        binArray = 1:n1bin;
                end
                if isempty(chanArray)
                        chanArray = 1:n1chan;
                end
                Amp = zeros(length(binArray), length(chanArray), nfile);                
        else
                if ERP.nbin~=n1bin
                        serror = 2;
                        break
                end
                if ismember_bc2(0,ismember(lower(ERP.bindescr), lower(n1bdesc))) % May 25, 2010
                        serror = 3;
                        break
                end
        end
        
        datatype = checkdatatype(ERP);
        if ~strcmpi(datatype, 'ERP') && ismember(moption, {'areazt','areazp','areazn', 'nintegz'}  )
                error('This type of measurement (automatic area/integration) is not allowed for Power Spectrum data ');                
        end
        
        %
        % subroutine
        %
        %
        % Get measurements
        %
        fprintf('Taking measurements across ERPset #%g...\n', erpsetArray(k))
        
        if inclate || viewmea % JLC. Sept 2012
                [A, lat4mea]  = geterpvalues(ERP, latency, binArray, chanArray, moption, blc, coi, polpeak, sampeak, locpeakrep, frac, fracmearep, intfactor,peak_onset);
        else
                %ERP, latency, binArray, chanArray, moption, blc, coi, polpeak, sampeak, locpeakrep, frac, fracmearep, intfactor
                A = geterpvalues(ERP, latency, binArray, chanArray, moption, blc, coi, polpeak, sampeak, locpeakrep, frac, fracmearep, intfactor,peak_onset);
                lat4mea = [];
        end
        
        %
        %
        %  en vez de abortar la lectura de valores debido a un error, es mejor llenar con NAN y seguir midiendo la sgte medida....
        %  Cambiar los "breaks"!
        %
        
        if isempty(A) && viewmea==0
                errmsg = 'Empty outcome.';
                serror = 4;
                break
        elseif ischar(A) && viewmea==0
                errmsg = A;
                serror = 4;
                break
        elseif (isempty(A) || ischar(A)) && viewmea==1
                if isempty(lat4mea)
                        A = NaN(length(binArray), length(chanArray)); % for viewer, when measurement was not possible.
                        lat4mea = {latency(1)};
                else
                        errmsg = A;
                        serror = 4;
                        break
                end
                %lat4mea = {};
                %[lat4mea{1:length(binArray),1:length(chanArray)}] = deal(latency); % specified latency(ies) for getting measurements.
                %lat4mea = {latency(1)};
        end
        
        %
        % Store values
        %
        Amp(:,:,k) = A; % bin x channel x erpset
        Lat{:,:,k} = lat4mea;  % bin x channel x erpset
        
        if send_to_file && ~viewmea
                if exceloption
                        %
                        % Excel
                        %
                        exportvalues2xls(ERP, {A}, binArray,chanArray, 0, moption, fname, k+appendfile)
                else
                        %
                        % Text
                        %
                        % (ERP, values, binArray, chanArray, fname, dig, ncall, binlabop, formatout, mlabel, lat4mea)
                        exportvaluesV2(ERP, {A}, binArray, chanArray, fname, dig, k+appendfile, binlabop, foutput, mlabel, lat4mea)
                end
                
                prew = 'Additionally, m';
        else
                prew = 'M';
        end
end

%
% Errors
%
if conti==0
        return
end
if serror~=0
        switch serror
                case 1
                        msgboxText =  sprintf('A problem was found at ERPset %s (%gth).', kname, kindex);
                case 2
                        msgboxText = ['Number of bins is different across datasets .\n'...
                                'You must use ERPset related to the same experiment.'];
                case 3
                        msgboxText = ['The bin description set among datasets is different.\n'...
                                'You must use ERPset related to the same experiment.'];
                case 4
                        msgboxText = errmsg ;
                otherwise
                        msgboxText = 'Sorry, something went wrong.';
        end
        if shist == 1; % gui
                tittle = 'ERPLAB: geterpvalues() error:';
                errorfound(sprintf(msgboxText), tittle);
                [ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP);
                pause(0.1)
                return
        else
                error('Error:measurements', msgboxText)
        end
end

%
% Send measurements to workspace (from GUI)
%
if send2ws==1
        assignin('base','ERP_MEASURES', Amp);
        fprintf('\n%seasured values were sent to Workspace as ERP_MEASURES.\n', prew);
end

%
% Open Viewer ********
%
if viewmea==1
        comme = '';
        switch moption
                case 'instabl'
                        moptionstr = measurearray{1};
                case 'meanbl'
                        moptionstr = measurearray{2};
                case 'peakampbl'
                        moptionstr = measurearray{3};
                        if polpeak
                                comme = ', positive';
                        else
                                comme = ', negative';
                        end
                case 'peaklatbl'
                        moptionstr = measurearray{4};
                        if polpeak
                                comme = ', positive';
                        else
                                comme = ', negative';
                        end
                case 'fpeaklat'
                        moptionstr = measurearray{5};
                        if polpeak
                                comme = ', positive';
                        else
                                comme = ', negative';
                        end
                case {'areat', 'areap', 'arean', 'ninteg'}
                        moptionstr = measurearray{6};
                        if strcmpi(moption, 'areat')
                                comme = ', total';
                        elseif strcmpi(moption, 'areap')
                                comme = ', positive';
                        elseif strcmpi(moption, 'arean')
                                comme = ', negative';
                        else
                                comme = '. Integral';
                        end
                case {'areazt','areazp','areazn', 'nintegz'}                        
                        moptionstr = measurearray{7};
                        if strcmpi(moption, 'areazt')
                                comme = ', total';
                        elseif strcmpi(moption, 'areazp')
                                comme = ', positive';
                        elseif strcmpi(moption, 'areazn')
                                comme = ', negative';
                        else
                                comme = '. Integral';
                        end
                case {'fareatlat', 'fareaplat','fninteglat','fareanlat', }
                        moptionstr = measurearray{8};
                        if strcmpi(moption, 'fareatlat')
                                comme = ', total';
                        elseif strcmpi(moption, 'fareaplat')
                                comme = ', positive';
                        elseif strcmpi(moption, 'fareanlat')
                                comme = ', negative';
                        else
                                comme = '. Integral';
                        end
                otherwise
                        return
        end
        
        moptionstr  = [moptionstr comme];
        moreoptions = {blc, moption, moptionstr, dig, coi, polpeak, sampeak, locpeakrep, frac, fracmearep, intfactor};
        
        %
        % Call Viewer GUI
        %
        if optioni==1 % from files
                mout = meaviewerGUI(ALLERPX, {Amp, Lat, binArray, chanArray, erpsetArray, latency, moreoptions});
                clear ALLERPX  % auxiliar ALLERP
        else
                mout = meaviewerGUI(ALLERP, {Amp, Lat, binArray, chanArray, erpsetArray, latency, moreoptions});
        end
        if ~isempty(mout) && iscell(mout)
                %try
                latfromviewer = mout{2};
                %catch
                %end
                if ~isempty(latfromviewer)
                        
                        if isnan(latfromviewer)% when viewer is open from plotted figure
                                return
                        end
                        
                        def    = erpworkingmemory('pop_geterpvalues');
                        def{4} = latfromviewer;
                        erpworkingmemory('pop_geterpvalues', def);
                end
                [ALLERP, Amp, Lat, erpcom] = pop_geterpvalues(ALLERP);
                pause(0.1)
                return
        elseif isnan(mout) % when viewer is open from plotted figure
                return
        else
                disp('User selected Cancel')
                return
        end
end


if send_to_file
    disp(['An output file with your measuring work was create at <a href="matlab: open(''' fname ''')">' fname '</a>'])
end


%
% Completion statement
%
msg2end

%
% Command history
%
binArraystr  = vect2colon(binArray);
chanArraystr = vect2colon(chanArray);
latencystr   = vect2colon(latency);
skipfields = {'ALLERP', 'latency', 'binArray','chanArray', 'Component', 'Warning','History'};

if isstruct(ALLERP) && optioni~=1 % from files
        if length(erpsetArray)==1 && erpsetArray==1
                DATIN = 'ERP';
                skipfields = [skipfields, 'Erpsets'];
        else
                DATIN =  inputname(1);
        end
else
        %DATIN = ['''' ALLERP ''''];
        DATIN = sprintf('''%s''', filelist);
        skipfields = [skipfields, 'Erpsets'];
end
if ~ismember_bc2({moption}, {'peakampbl', 'peaklatbl', 'fpeaklat'}) % JLC. 08/22/13
        skipfields = [skipfields {'Neighborhood', 'Peakpolarity', 'Peakreplace'}];
end
if strcmpi(fname,'no_save.no_save') || strcmpi(fname,'tempofile.txt')
        skipfields = [skipfields {'Filename'}];
end
fn     = fieldnames(p.Results);
erpcom = sprintf( 'ALLERP = pop_geterpvalues( %s, %s, %s, %s ',  DATIN, latencystr, binArraystr, chanArraystr);
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        else
                                erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                for i=1:length(ALLERP)
                        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
                end
        case 3
                % implicit
                %for i=1:length(ALLERP)
                %        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
                %end
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end
return
