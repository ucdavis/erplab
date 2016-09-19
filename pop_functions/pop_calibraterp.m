
% *** This function is part of ERPLAB Toolbox ***
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

function [ERP, erpcom] = pop_calibraterp(ERP, ERPcal, varargin)
erpcom = '';
fprintf('pop_calibraterp : START\n');
if nargin < 1
      help pop_calibraterp
      return
end
datatype = checkdatatype(ERP(1));
%
% Gui is working...
%
if nargin==1
      title_msg  = 'ERPLAB: pop_calibraterp() error:';
      if isempty(ERP)
            ERP = preloadERP;
            if isempty(ERP)
                  msgboxText =  'No ERPset was found!';
                  errorfound(msgboxText, title_msg);
                  return
            end
      end
      if isempty(ERP.bindata)
            msgboxText =  'cannot work with an empty erpset!';
            errorfound(msgboxText, title_msg);
            return
      end
      if ~strcmpi(datatype, 'ERP')
            msgboxText =  'Cannot calibrate Power Spectrum waveforms. Sorry';
            errorfound(msgboxText, title_msg);
            return
      end
      
      def  = erpworkingmemory('pop_calibraterp');
      if isempty(def)
            def = {0, 1, 10, [0 300]};
      end
      %handles.output = {erpinput, calbin, calval, calwin};
      
      answer = calibrateGUI(def);  % open GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      erpinput = answer{1};
      calbin   = answer{2};
      calval   = answer{3};
      calwin   = answer{4};
      
      if ~ischar(erpinput)
            if erpinput==0
                  ERPcal = ERP;
            elseif erpinput>0
                  ALLERP = evalin('base', 'ALLERP');
                  ERPcal = ALLERP(erpinput);
            end
      else
            [fpath, fname, fext] = fileparts(erpinput);
            L   = load(fullfile(fpath, [fname fext]), '-mat');
            ERPcal = L.ERP;
      end
      if ERPcal.nchan~=ERP.nchan
            msgboxText =  'Calibration ERPset must have the same amount of channels than the ERPset to be calibrated.';
            title_msg  = 'ERPLAB: pop_calibraterp() error:';
            errorfound(msgboxText, title_msg);
            return
      end
      erpworkingmemory('pop_calibraterp', { erpinput, calbin, calval, calwin });
      
      %
      % Somersault
      %
      [ERP, erpcom] = pop_calibraterp(ERP, erpinput, 'CalBin', calbin, 'CalWindow', calwin, 'CalValue', calval, 'Measurement', 'mean', 'Saveas', 'on', 'History', 'gui');
      return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('ERPcal');
% option(s)
p.addParamValue('CalWindow', []); % erpset index or input file
p.addParamValue('Measurement', 'mean', @ischar); % 'on', 'off'
p.addParamValue('CalValue', 'script', @isnumeric); % history from scripting
p.addParamValue('CalBin', 1, @isnumeric); % history from scripting
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting

% p.addParamValue('CalChannel', 'all'); % history from scripting
p.parse(ERP, ERPcal, varargin{:});

calwin   = p.Results.CalWindow;
calval   = p.Results.CalValue;
calbin   = p.Results.CalBin;

switch p.Results.Measurement
      case 'mean'
            calmea = 0;
      case 'ppeak'
            calmea = 1;
      case 'npeak'
            calmea = 2;
      case 'rms'
            calmea = 3;
      otherwise
            calmea = 0;
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
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
      issaveas  = 1;
else
      issaveas  = 0;
end
if isempty(ERP)
      msgboxText =  'ERPLAB says: ERP is empty!';
      error(msgboxText);
end
if ischar(ERP)
      if exist(ERP, 'file')~=2
            msgboxText =  'ERPLAB says: ERPset file does not exist!';
            error(msgboxText);
      end
      [fpath, fname, fext] = fileparts(ERP);
      L   = load(fullfile(fpath, [fname fext]), '-mat');
      ERP = L.ERP;
end
if ~ischar(ERPcal)
      if ERPcal==0
            ERPcalx = ERP;
            ERPcalstr = inputname(1);
      elseif ERPcal>0
            ALLERP = evalin('base', 'ALLERP');
            ERPcalx = ALLERP(ERPcal);
            ERPcalstr = sprintf('ALLERP(%g)', ERPcal);
      end
else
      if exist(ERPcal, 'file')~=2
            msgboxText =  'ERPLAB says: ERPset file does not exist!';
            error(msgboxText);
      end
      [fpath, fname, fext] = fileparts(ERPcal);
      L   = load(fullfile(fpath, [fname fext]), '-mat');
      ERPcalx = L.ERP;
      ERPcalstr =  sprintf('''%s''', ERPcal);
end

if ERPcalx.nchan~=ERP.nchan
      msgboxText =  'ERPLAB says: Calibration ERPset must have the same amount of channels than the ERPset to be calibrated.';
      error(msgboxText);
end
if ischar(calwin)
      if ~ismember_bc2(lower(calwin),{'all' 'pre' 'post' 'none'})
            internum = str2double(calwin);
            if length(internum) ~=2
                  msgboxText = ['pop_calibraterp will not be performed.\n'...
                        'Check out your baseline correction values'];
                  title =  'ERPLAB: pop_calibraterp() base line';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
            if internum(1)>=internum(2)|| internum(1)>ERPcalx.xmax || internum(2)<ERPcalx.xmin
                  msgboxText = ['pop_calibraterp will not be performed.\n'...
                        'Check out your baseline correction values'];
                  title =  'ERPLAB: pop_calibraterp() base line';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
            
            CWIN  = internum; % msecs
            %calwincomm = ['[' calwin ']'];
      else
            if strcmpi(calwin,'pre')
                  CWIN  = 1000*[ERPcalx.xmin 0]; % msecs
                  %calwincomm = ['''' calwin ''''];
                  CWINp1 = 1;
                  CWINp2 = find(ERPcalx.times==0);
            elseif strcmpi(calwin,'post')
                  CWIN  = 1000*[0 ERPcalx.xmax];  % msecs
                  %calwincomm = ['''' calwin ''''];
                  CWINp1 = find(ERPcalx.times==0);
                  CWINp2 = ERPcalx.pnts;
            elseif strcmpi(calwin,'all')
                  CWIN  = 1000*[ERPcalx.xmin ERPcalx.xmax]; % msecs
                  %calwincomm = ['''' calwin ''''];
                  CWINp1 = 1;
                  CWINp2 = ERPcalx.pnts;
            else
                  CWIN  = [];
                  %calwincomm = '''none''';
            end
      end
else
      if length(calwin)~=2
            error('ERPLAB says:  pop_calibraterp will not be performed. Check your parameters.')
      end
      if calwin(1)>=calwin(2)|| calwin(1)>ERPcalx.xmax*1000 || calwin(2)<ERPcalx.xmin*1000
            error('ERPLAB says:  pop_calibraterp will not be performed. Check your parameters.')
      end
      CWIN  = calwin;
      %calwincomm = ['[' num2str(calwin) ']']; % msecs
      [CWINp1, CWINp2, checkw] = window2sample(ERPcalx, CWIN, ERPcalx.srate);
end

ERPaux = ERP; % original ERP
nbin = ERP.nbin;

%
% ERP calibration
%
% sqrt(mean(datap(:,latArray(ilat,1):latArray(ilat,2)).^2, 2));

if ~isempty(CWIN)
      fprintf('Calibrating ERPs...\n');
      switch calmea
            case 0 % mean
                  meaval = mean(ERPcalx.bindata(:,CWINp1:CWINp2, calbin), 2);
            case 1 % positive peak (max)
                  meaval = max(ERPcalx.bindata(:,CWINp1:CWINp2, calbin));
            case 2 % negative peak (min)
                  meaval = min(ERPcalx.bindata(:,CWINp1:CWINp2, calbin));
            case 3 % rms value
                  meaval = sqrt(mean(ERPcalx.bindata(:,CWINp1:CWINp2, calbin).^2, 2));
            otherwise % mean
                  meaval = mean(ERPcalx.bindata(:,CWINp1:CWINp2, calbin), 2);
      end
      
      %
      % Prepare List of current Channels
      %
      listch={[]};
      nchan = ERP.nchan;
      if isempty(ERP.chanlocs)
            for ee=1:nchan
                  listch{ee} = ['Ch' num2str(ee)];
            end
      else
            listch = {ERP.chanlocs.labels};
      end
      for pp=1:nchan
            fprintf('Calibration factor for %s is %.4f\n', listch{pp}, calval./meaval(pp));
      end
      Kcali = repmat(calval./meaval,1,ERP.pnts);
      for ii=1:nbin
            ERP.bindata(:,:,ii) = ERP.bindata(:,:,ii).*Kcali;    % fast correction
      end
      fprintf('\nValue for calibration was taken from [%s] ms \n\n', num2str(CWIN));
else
      fprintf('\n\nWarning: No calibration was performed\n\n');
end

ERP.saved  = 'no';
% erpcom = sprintf('%s = pop_calibraterp( %s, %s);', inputname(1), inputname(1), calwincomm);

%
% History
%
skipfields = {'ERP', 'ERPcal', 'History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_calibraterp( %s, %s ', inputname(1), inputname(1), ERPcalstr );
for q=1:length(fn)
      fn2com = fn{q};
      if ~ismember_bc2(fn2com, skipfields)
            fn2res = p.Results.(fn2com);
            if ~isempty(fn2res)
                  if ischar(fn2res)
                        if ~strcmpi(fn2res,'off')
                              erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
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
                                    erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                              end
                        else
                              erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                        end
                  end
            end
      end
end
erpcom = sprintf( '%s );', erpcom);
if issaveas
      [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
      if issave>0
            % generate text command
            if issave==2
                  erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                  msgwrng = '*** Your ERPset was saved on your hard drive.***';
            else
                  msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
            end
            fprintf('\n%s\n\n', msgwrng)
            try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      else
            ERP = ERPaux;
            msgwrng = 'ERPLAB Warning: Your changes were not saved';
            try cprintf([1 0.52 0.2], '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
      end
end
% get history from script. ERP
switch shist
      case 1 % from GUI
            displayEquiComERP(erpcom);
      case 2 % from script
            ERP = erphistory(ERP, [], erpcom, 1);
      case 3
            % implicit
      otherwise %off or none
            erpcom = '';
end

%
% Completion statement
%
msg2end
return
