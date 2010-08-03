% Usage:
% >> [Amp Lat] = pop_geterpvalues(ALLERP, latency, binArray, chanArray, options)
%
%
% ALLERP            - Structure containing ERPsets. If Erpsets are read from a list within a text file then ALLERP = ''
% latency           - latency or latencies to get values, in msec. E.g. [80 120]
% binArray          - indices of bins to be measured. E.g. [1:5 10 14]
% chanArray         - indices of channels to be measured. E.g. [3:32]
%
%  'Erpsets'        -      default = 1,  indices of erpsets to be measured if ALLERP contains Erpsets.
%                                        If ALLERP='' then Erpsets must be the name of the file containing the list of erpsets
%  'Measure'        -      default = 'instabl',  Type of measurement:
%                                         'instabl'   - finds the relative-to-baseline instantaneous value at the specified latency.
%                                         'peakampbl' - finds the relative-to-baseline peak value between two latencies.
%                                         'peaklatbl' - latency value corresponding to a (local) peak of amplitude
%                                         'meanbl'    - calculates the relative-to-baseline mean amplitude value between two latencies.
%                                         'errorbl'   - mean standard deviation of amplitude (if any) between 2 latencies. (Reserved to Rick Addante)
%                                         'area'      - calculates the area under the curve value between two latencies.
%                                         '50arealat' - latency value corresponding to the 50% of the area between 2 latencies (under construction)
%                                         'areaz'   calculates the area under the curve value. Lower and upper limit of integration
%                          are automatically found starting with a seed latency.
%
%                In case you do not specify any of these options will have 2 situations:
%                1) you specify just one latency -> VALUES will only contain the instantaneous value at
%                   that latency. Or,
%                2) you specify two latencies    -> geterpvalues will use op = 'mean' by default
%  'Component'      -      default = 1,                   (under construction)
%  'Resolution'     -      default = 3,                   Number of decimal digits to be written at the text file for outputs.
%  'Baseline'       -      default = 'pre',               Baseline for the measured values. This is a mean value that will be substracted from your measurements.
%
%                                         'none'        - no baseline.
%                                         'pre'         - mean value of the pre-stimulus interval will be substracted from the measurements.
%                                         'post'        - mean value of the post-stimulus interval will be substracted from the measurements
%                                         'whole'/'all' - mean value of the whole interval will be substracted from the measurements
%                                         custom        - mean value of a custom interval, in msec, will be substracted from the measurements. e.g  [-100 200]
%
%  'Binlabel'       -      default = 'off',               if 'on' label of measured value will be the bin description of your bins, otherwise it will be the bin number.
%  'Peakpolarity'   -      default = 'positive',          capture positive or negative (local) peak
%  'Neighborhood'   -      default = 0,                   number of points (N samples) on one side of the tested sample.
%                                                         A local peak is a sample value which is greater that the average of the N points on its left AND
%                                                         greater than the average of the N points on its right.
%  'Peakreplace'    -      default = 'NaN',               If (local) peak is not found, its value could be replaced by a 'NaN' or the value of the absolute peak ('absolute')
%  'Warning'        -      default = 'off',               Warning messages turned 'on' or 'off'
%  'Filename'       -      default = 'tempofile.txt',     Output text (or .xls for Windows) with the measured values.
%
%
% ( ALLERP, [ 0 200], [ 1 2],1:16 , 'Baseline', 'pre', 'Component',1, 'Erpsets', '/Users/javlopez/Desktop/Tutorial/S1/a3list.txt', 'Filename', '/Users/javlopez/Desktop/Tutorial/S1/sar_value.txt', 'Measure', 'meanbl', 'Peakpolarity', 'positive', 'Peakreplace', 'NaN', 'Resolution',3, 'Warning', 'on' );
%
% OUTPUTS
%
% text file  - text file containing  values.
%
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

function [Amp Lat erpcom] = pop_geterpvalues(ALLERP, latency, binArray, chanArray, varargin)

erpcom = '';
Amp = [];
Lat = [];

if nargin<1
      help pop_geterpvalues
      return
end

if nargin==1  % GUI
      
      if isstruct(ALLERP)
            cond1 = iserpstruct(ALLERP(1));
            
            if ~cond1
                  ALLERP = [];
            end
      else
            ALLERP = [];
      end
      
      def  = erpworkingmemory('pop_geterpvalues');
      
      if isempty(def)
            if isempty(ALLERP)
                  inp1 = 1; %from hard drive
                  erpset = [];
            else
                  inp1 = 0; %from hard drive
                  erpset = 1:length(ALLERP);
            end
            def = {inp1 erpset '' 0 1 1 'instabl' 1 3 'pre' 0 1 0 0 0 0};
      end
      
      instr     = geterpvaluesGUI2(ALLERP, def);% open a GUI
      
      if isempty(instr)
            disp('User selected Cancel')
            return
      end
      
      optioni   = instr{1}; %1 means from hard drive, 0 means from erpsets menu
      erpset    = instr{2};
      fname     = instr{3};
      latency   = instr{4};
      binArray  = instr{5};
      chanArray = instr{6};
      op        = instr{7}; % option: type of measurement ---> instabl, meanbl, peakampbl, peaklatbl, area, areaz, or errorbl.
      coi       = instr{8};
      dig       = instr{9};
      %measu     = instr{10};% include late? (1:yes or 0:no)
      blc       = instr{10};
      binlabop  = instr{11}; % 0: bin number as bin label, 1: bin descriptor as bin label for table.
      polpeak   = instr{12}; % local peak polarity
      sampeak   = instr{13}; % number of samples (one-side) for local peak detection criteria
      localop   = instr{14}; % 1 abs peak , 0 Nan
      send2ws   = instr{15}; % send measurements to workspace
      appfile   = instr{16};
      foutput   = instr{17};
      
      if optioni==1 % from files
            filelist    = erpset;
            disp(['pop_geterpvalues(): For file-List, user selected ', filelist])
            fid_list    = fopen( filelist );
            inputfnamex = textscan(fid_list, '%[^\n]','CommentStyle','#');
            inputfname  = cellstr(char(inputfnamex{:}));
            fclose(fid_list);
            nfile      = length(inputfname);
      else % from erpsets
            nfile        = length(erpset);
            erpsetArray  = erpset;
      end
      
      if strcmpi(fname,'no_save.no_save')
            fnamer = '';
      else
            fnamer = fname;
      end
      
      if send2ws
            s2ws = 'on'; % send to workspace
      else
            s2ws = 'off';
      end
      
      erpworkingmemory('pop_geterpvalues', {optioni, erpset, fnamer, latency,...
            binArray, chanArray, op, coi, dig, blc, binlabop, polpeak,...
            sampeak, localop, send2ws, foutput});
      
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
      if localop==0
            localopstr = 'NaN';
      else
            localopstr = 'absolute';
      end
      if appfile
            appfstr = 'on';
      else
            appfstr = 'off';
      end
      if foutput
            foutputstr = 'measurement';
      else
            foutputstr = 'erpset';
      end
      
      [Amp Lat erpcom] = pop_geterpvalues(ALLERP, latency, binArray, chanArray,...
            'Erpsets', erpset, 'Measure', op, 'Component', coi, 'Resolution',...
            dig, 'Baseline', blc, 'Binlabel', binlabopstr, 'Peakpolarity',...
            polpeakstr, 'Neighborhood', sampeak, 'Peakreplace', localopstr,...
            'Filename', fname, 'Warning','on', 'SendtoWorkspace', s2ws, 'Append', appfstr, 'Foutput', foutputstr);
      
      pause(0.1)
      return
else
      p = inputParser;
      p.FunctionName  = mfilename;
      p.CaseSensitive = false;
      p.addRequired('ALLERP');
      p.addRequired('latency',  @isnumeric);
      p.addRequired('binArray', @isnumeric);
      p.addRequired('chanArray',@isnumeric);
      
      p.addParamValue('Erpsets', 1); % erpset index or input file
      p.addParamValue('Measure', 'instabl', @ischar);
      p.addParamValue('Component', 1, @isnumeric);
      p.addParamValue('Resolution', 3, @isnumeric);
      p.addParamValue('Baseline', 'pre');
      p.addParamValue('Binlabel', 'off', @ischar);
      p.addParamValue('Peakpolarity', 'positive', @ischar); % normal | reverse
      p.addParamValue('Neighborhood', 0, @isnumeric);
      p.addParamValue('Peakreplace', 'NaN');
      p.addParamValue('Warning', 'off', @ischar);
      p.addParamValue('Filename', 'tempofile.txt', @ischar); %output file
      p.addParamValue('Append', 'off', @ischar); %output file
      p.addParamValue('Foutput', 'measurement', @ischar); %output format
      
      p.addParamValue('SendtoWorkspace', 'off', @ischar);
      
      try
            p.parse(ALLERP, latency, binArray, chanArray, varargin{:});
            
            erpsetArray  = p.Results.Erpsets;
            cond1 = iserpstruct(ALLERP);
            cond2 = isnumeric(erpsetArray);
            
            if cond1 && cond2
                  erpsetArray  = p.Results.Erpsets;
                  nfile        = length(erpsetArray);
                  optioni      = 0; % from erpset menu or ALLERP struct
            else
                  if ischar(erpsetArray)
                        filelist = p.Results.Erpsets;
                        disp(['erp_gaverager(): For file-List, user selected ', filelist])
                        fid_list    = fopen( filelist );
                        inputfnamex = textscan(fid_list, '%[^\n]','CommentStyle','#');
                        inputfname  = cellstr(char(inputfnamex{:}));
                        nfile       = length(inputfname);
                        fclose(fid_list);
                        optioni     = 1; % from file
                  else
                        error('ERPLAB says: error at pop_geterpvalues(). Unrecognizable input ')
                  end
            end
            
            fname    = p.Results.Filename;
            localrep = p.Results.Peakreplace;
            
            if ischar(localrep)
                  
                  lr = str2num(localrep);
                  
                  if isempty(lr)
                        if strcmpi(localrep,'absolute')
                              localop = 1;
                        else
                              error(['ERPLAB says: Unrecognizable input ' localrep])
                        end
                  else
                        if isnan(lr)
                              localop = 0;
                        else
                              error(['ERPLAB says: Unrecognizable input ' localrep])
                        end
                  end
            else
                  if isnan(localrep)
                        localop = 0;
                  else
                        error(['ERPLAB says: Unrecognizable input ' num2str(localrep(1))])
                  end
            end
            
            sampeak     = p.Results.Neighborhood;
            
            if strcmpi(p.Results.Peakpolarity, 'positive')
                  polpeak = 1; % positive
            elseif strcmpi(p.Results.Peakpolarity, 'negative')
                  polpeak = 0;
            else
                  error(['ERPLAB says: Unrecognizable input ' p.Results.Peakpolarity]);
            end
            if strcmpi(p.Results.Binlabel, 'on')
                  binlabop = 1; % bin descriptor as bin label for table
            elseif strcmpi(p.Results.Binlabel, 'off')
                  binlabop = 0; % bin# as bin label for table
            else
                  error(['ERPLAB says: Unrecognizable input ' p.Results.Binlabel]);
            end
            
            blc  = p.Results.Baseline;
            dig  = p.Results.Resolution;
            coi  = p.Results.Component;
            op   = p.Results.Measure;
            
            if strcmpi(op, 'instabl')
                  if length(latency)~=1
                        error(['ERPLAB says: ' op ' only needs 1 latency value.'])
                  end
            else
                  if length(latency)~=2
                        error(['ERPLAB says: ' op ' needs 2 latency values.'])
                  else
                        if latency(1)>=latency(2)
                              msgboxText{1} =  'For latency range, lower time limit must be on the left. ';
                              msgboxText{2} =  'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.';
                              title = 'ERPLAB: pop_geterpvalues() inputs';
                              errorfound(msgboxText, title);
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
            
            if strcmpi(p.Results.Append, 'on')
                  appendfile = 1;
            else
                  appendfile = 0;
            end
            if strcmpi(p.Results.Foutput, 'measurement')
                  foutput = 1;
            else
                  foutput = 0;
            end
      catch
            serr = lasterror;
            msgboxText{1} =  'Please, check your inputs: ';
            msgboxText{2} =  serr.message;
            tittle = 'ERPLAB: pop_geterpvalues() error:';
            errorfound(msgboxText, tittle);
            return
      end
      
      if ~ismember({op}, {'instabl', 'peakampbl', 'peaklatbl', 'meanbl',...
                  'errorbl',  'area',  '50arealat', 'areaz'} )
            msgboxText =  [op ' is not a valid option for pop_geterpvalues!'];
            title = 'ERPLAB: pop_geterpvalues wrong inputs';
            errorfound(msgboxText, title);
            return
      end
end

if ischar(blc)
      blcorrstr = [''''  blc '''' ];
else
      blcorrstr = ['[' num2str(blc) ']'];
end

[pathtest, filtest, ext, versn] = fileparts(fname);

if isempty(filtest)
      error('File name is empty.')
end

if strcmpi(ext,'.xls')
      
      if ispc
            exceloption = 1;
            fprintf('\nOutput will be a Microsoft Excel spreadsheet file')
            warning off MATLAB:xlswrite:AddSheet
            if strcmp(pathtest,'')
                  pathtest = cd;
                  fname = fullfile(pathtest, [filtest ext]);
            end
      else
            fprintf('\nWARNING:\n')
            
            title      = 'ERPLAB: WARNING, pop_geterpvalues() export to Excel' ;
            question{1} = 'The full functionality of XLSWRITE depends on the ability';
            question{2} = 'to instantiate Microsoft Excel as a COM server.';
            question{3} = 'COM is a technology developed for Windows platforms and,';
            question{4} = 'at the current ERPLAB version,  is not available for non-Windows machines';
            question{5} ='';
            question{6} = 'Do you want to continue anyway with a text file instead?';
            
            button = askquest(question, title);
            
            if ~strcmpi(button,'yes')
                  disp('User selected Cancel')
                  return
            end
            
            if strcmp(pathtest,'')
                  pathtest = cd;
            end
            
            ext   = '.txt';
            fname = fullfile(pathtest, [filtest ext]);
            fprintf('\nOutput file will have extension %s\n', ext)
            
            exceloption = 0;
            
      end
      
      send_to_file = 1;
      
elseif strcmpi(ext,'.no_save')
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
      
      fprintf('\nOutput file will have extension %s\n', ext)
      send_to_file = 1;
end

fprintf('\nBaseline correction = %s will be used for measurements\n\n', blcorrstr)
conti = 1;
Amp = zeros(length(binArray), length(chanArray), nfile);

for k=1:nfile
      
      if optioni==1 % from files
            filex = load(inputfname{k}, '-mat');
            ERP   = filex.ERP;
      else          % from erpsets
            ERP = ALLERP(erpsetArray(k));
      end
      
      [ERP conti serror] = olderpscan(ERP, menup);
      
      if conti==0
            break
      end
      if serror ==1
            kindex = k;
            kname  = ERP.erpname;
            break
      end
      if k==1
            n1bin = ERP.nbin;
            n1bdesc = ERP.bindescr;
      else
            if ERP.nbin~=n1bin
                  serror = 2;
                  break
            end
            if ismember(0,ismember(lower(ERP.bindescr), lower(n1bdesc))) % May 25, 2010
                  serror = 3;
                  break
            end
      end
      
      A  = geterpvalues(ERP, latency, binArray, chanArray, op, blc, coi, polpeak, sampeak, localop);
      
      if isempty(A)
            return
      end
      
      if send_to_file
            if exceloption
                  exportvalues2xls(ERP, {A}, binArray,chanArray, 0, op, fname, k+appendfile)
            else
                  exportvaluesV2(ERP, {A}, binArray,chanArray, 0, dig, op, fname, k+appendfile, binlabop, foutput)
            end
            prew = 'Additionally, m';
      else
            prew = 'M';
      end
      
      Amp(:,:,k) = A;  % bin x channel x erpset
end

%
% Send measurements to workspace (from GUI)
%
if send2ws
      assignin('base','ERP_MEASURES', Amp);
      fprintf('%seasured values were sent to Workspace as ERP_MEASURES.\n', prew)
end

if conti==0
      return
end

if serror ==1
      msgboxText =  sprintf('A problem was found at ERPset %s (%gth).', kname, kindex);
      title = 'ERPLAB: pop_geterpvalues';
      errorfound(msgboxText, title);
      return
end

if serror ==2
      msgboxText{1} =  'Number of bins is different across datasets .';
      msgboxText{2} =  'You must use ERPset related to the same experiment.';
      title = 'ERPLAB: pop_geterpvalues';
      errorfound(msgboxText, title);
      return
end

if serror ==3
      msgboxText{1} =  'The bin description set among datasets is different.';
      msgboxText{2} =  'You must use ERPset related to the same experiment.';
      title = 'ERPLAB: pop_geterpvalues';
      errorfound(msgboxText, title);
      return
end

%
% History command
%
binArraystr  = vect2colon(binArray);
chanArraystr = vect2colon(chanArray);
latencystr   = vect2colon(latency);

if isstruct(ALLERP)
      DATIN =  inputname(1);
else
      DATIN = ['''' ALLERP ''''];
end

skipfields = {'ALLERP', 'latency', 'binArray','chanArray', 'Component'};

if ~ismember({op}, {'peakampbl', 'peaklatbl'})
      skipfields = [skipfields {'Neighborhood', 'Peakpolarity', 'Peakreplace'}];
end

if strcmpi(fname,'no_save.no_save') || strcmpi(fname,'tempofile.txt')
      skipfields = [skipfields {'Filename'}];
end

fn = fieldnames(p.Results);
erpcom = sprintf( '[Amp Lat] = pop_geterpvalues( %s, %s, %s, %s ',  DATIN, latencystr, binArraystr, chanArraystr);

for q=1:length(fn)
      fn2com = fn{q};
      if ~ismember(fn2com, skipfields)
            fn2res = p.Results.(fn2com);
            if ~isempty(fn2res)
                  if ischar(fn2res)
                        if ~strcmpi(fn2res,'off')
                              erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                        end
                  else
                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                  end
            end
      end
end
erpcom = sprintf( '%s );', erpcom);
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
