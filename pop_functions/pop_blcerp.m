% PURPOSE : 	Removes ERP baseline
% 
% FORMAT  : 
%
% ERP = pop_blcerp(ERP, blc)
%
% ERP     -  ERPLAB structure
% blc     - window for baseline correction in msec  or either a string like 'pre', 'post', or 'all'
%           (strings with the baseline interval also works. e.g. '-300 100')
%
% Example :
% >> ERP = pop_blcerp( ERP , [-200 800],  [-100 0]);
% >> ERP = pop_blcerp( ERP , [-200 800],  '-100 0');
% >> ERP = pop_blcerp( ERP , [-400 2000],  'post');
%
% INPUTS  :
% 
% ERP     -  ERPLAB structure
% blc     -  window for baseline correction in msec or either a string like 	
%            'none', 'pre', 'post', or 'whole'
%  
% OUTPUTS :
% 
% - updated (output) ERPset
%
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

function [ERP, erpcom] = pop_blcerp(ERP, varargin)
erpcom = '';
if nargin < 1
        help pop_blcerp
        return
end
datatype = checkdatatype(ERP);
%
% Gui is working...
%
if nargin==1
      title_msg  = 'ERPLAB: pop_blcerp() error:';
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
              msgboxText =  'Cannot baseline Power Spectrum waveforms. Sorry';
              errorfound(msgboxText, title_msg);
              return
        end
        
        titlegui = 'Baseline Correction';
        answer = blcerpGUI(ERP, titlegui );  % open GUI
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        blcorr = answer{1};
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_blcerp(ERP, 'Baseline', blcorr, 'Saveas', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
% option(s)
p.addParamValue('Baseline', 'pre'); % erpset index or input file
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERP, varargin{:});

if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end
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
if ischar(blcorr)
      if ~ismember_bc2(lower(blcorr),{'all' 'pre' 'post' 'none'})            
            internum = str2double(blcorr);            
            if length(internum) ~=2
                  msgboxText = ['pop_blcerp will not be performed.\n'...
                                'Check out your baseline correction values'];
                  title =  'ERPLAB: pop_blcerp() base line';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
            if internum(1)>=internum(2)|| internum(1)>ERP.xmax || internum(2)<ERP.xmin
                  msgboxText = ['pop_blcerp will not be performed.\n'...
                                'Check out your baseline correction values'];
                  title =  'ERPLAB: pop_blcerp() base line';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
            
            BLC  = internum; % msecs
            blcorrcomm = ['[' blcorr ']'];
      else            
            if strcmpi(blcorr,'pre')
                  BLC  = kktime*[ERP.xmin 0]; % msecs
                  blcorrcomm = ['''' blcorr ''''];
                  BLCp1 = 1;
                  BLCp2 = find(ERP.times==0);
                  
            elseif strcmpi(blcorr,'post')
                  BLC  = kktime*[0 ERP.xmax];  % msecs
                  blcorrcomm = ['''' blcorr ''''];
                  BLCp1 = find(ERP.times==0);
                  BLCp2 = ERP.pnts;                  
            elseif strcmpi(blcorr,'all')
                  BLC  = kktime*[ERP.xmin ERP.xmax]; % msecs
                  blcorrcomm = ['''' blcorr ''''];
                  BLCp1 = 1;
                  BLCp2 = ERP.pnts;
            else
                  BLC  = [];
                  blcorrcomm = '''none''';
            end
      end      
else
      if length(blcorr)~=2
            error('ERPLAB says:  pop_blcerp will not be performed. Check your parameters.')
      end
      if blcorr(1)>=blcorr(2)|| blcorr(1)>ERP.xmax*kktime || blcorr(2)<ERP.xmin*kktime
            error('ERPLAB says:  pop_blcerp will not be performed. Check your parameters.')
      end
      BLC  = blcorr;
      blcorrcomm = ['[' num2str(blcorr) ']']; % msecs      
      [BLCp1, BLCp2, checkw] = window2sample(ERP, BLC, ERP.srate);      
end

ERPaux = ERP; % original ERP
nbin = ERP.nbin;

%
% baseline correction  01-14-2009
%
if ~isempty(BLC)
      
      %
      % Baseline correction
      %
      fprintf('Removing baseline...\n');      
      for i=1:nbin
            meanv = mean(ERP.bindata(:,BLCp1:BLCp2,i), 2);
            ERP.bindata(:,:,i) = ERP.bindata(:,:,i) - repmat(meanv,1,ERP.pnts);    % fast baseline removing
      end      
      fprintf('\nBaseline correction was performed at [%s] \n\n', num2str(BLC));
else
      fprintf('\n\nWarning: No baseline correction was performed\n\n');
end

ERP.saved  = 'no';
% erpcom = sprintf('%s = pop_blcerp( %s, %s);', inputname(1), inputname(1), blcorrcomm);

%
% History
%
skipfields = {'ERP', 'History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_blcerp( %s ', inputname(1), inputname(1) );
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
