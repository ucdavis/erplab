% Usage:
% ERP = pop_blcerp(ERP, trange, blc)
%
% ERP     -  ERPLAB structure
% trange  - window for epoching in msec
% blc     - window for baseline correction in msec  or either a string like 'pre', 'post', or 'all'
%           (strings with the baseline interval also works. e.g. '-300 100')
%
% Example:
% >> ERP = pop_blcerp( ERP , [-200 800],  [-100 0]);
% >> ERP = pop_blcerp( ERP , [-200 800],  '-100 0');
% >> ERP = pop_blcerp( ERP , [-400 2000],  'post');
%
% pop_blcerp() - interactively epoch bin-based trials
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
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

function [ERP erpcom] = pop_blcerp(ERP, blc)

erpcom = '';
fprintf('pop_blcerp : START\n');

if nargin < 1
      help pop_blcerp
      return
end

if isempty(ERP)
      msgboxText{1} =  'cannot work with an empty erpset!';
      title = 'ERPLAB: pop_blcerp() error';
      errorfound(msgboxText, title);
      return
end

if isempty(ERP.bindata)
      msgboxText{1} =  'cannot work with an empty erpset!';
      title = 'ERPLAB: pop_blcerp() error';
      errorfound(msgboxText, title);
      return
end

%
% Gui is working...
%
nvar = 2;
if nargin <nvar
      
      titlegui = 'Baseline Correction';
      answer = blcerpGUI(ERP, titlegui );  % open GUI
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      blcorr     =  answer{1};
      
else   % without Gui
      blcorr   = blc;
end

if ischar(blcorr)
      
      if ~ismember(lower(blcorr),{'all' 'pre' 'post' 'none'})
            
            internum = str2double(blcorr);
            
            if length(internum)  ~=2
                  msgboxText{1} =  'pop_blcerp will not be performed.';
                  msgboxText{2} =  'Check out your baseline correction values';
                  title        =  'ERPLAB: pop_blcerp() base line';
                  errorfound(msgboxText, title);
                  return
            end
            if internum(1)>=internum(2)|| internum(1)>ERP.xmax || internum(2)<ERP.xmin
                  msgboxText{1} =  'pop_blcerp will not be performed.';
                  msgboxText{2} =  'Check out your baseline correction values';
                  title        =  'ERPLAB: pop_blcerp() base line';
                  errorfound(msgboxText, title);
                  return
            end
            
            BLC  = internum; % msecs
            blcorrcomm = ['[' blcorr ']'];
      else
            
            if strcmpi(blcorr,'pre')
                  BLC  = 1000*[ERP.xmin 0]; % msecs
                  blcorrcomm = ['''' blcorr ''''];
                  BLCp1 = 1;
                  BLCp2 = find(ERP.times==0);
                  
            elseif strcmpi(blcorr,'post')
                  BLC  = 1000*[0 ERP.xmax];  % msecs
                  blcorrcomm = ['''' blcorr ''''];
                  BLCp1 = find(ERP.times==0);
                  BLCp2 = ERP.pnts;
                  
            elseif strcmpi(blcorr,'all')
                  BLC  = 1000*[ERP.xmin ERP.xmax]; % msecs
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
      if blcorr(1)>=blcorr(2)|| blcorr(1)>ERP.xmax*1000 || blcorr(2)<ERP.xmin*1000
            error('ERPLAB says:  pop_blcerp will not be performed. Check your parameters.')
      end
      BLC  = blcorr;
      blcorrcomm = ['[' num2str(blcorr) ']']; % msecs
      
      [BLCp1 BLCp2 checkw] = window2sample(ERP, BLC, ERP.srate);
      
end

nbin      = ERP.nbin;

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

if nargin==1
      
      [ERP issave]= pop_savemyerp(ERP,'gui','erplab');
      
      if issave
            % generate text command
            erpcom = sprintf('%s = pop_blcerp( %s, %s);', inputname(1), inputname(1), blcorrcomm);
            try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
            return
      else
            disp('Warning: Your ERP structure has not yet been saved')
            disp('user canceled')
            return
      end
end
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
