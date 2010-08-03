% Usage (For using with EEGLAB/ERPLAB Gui only)
%
% >> [ERP issave ]= pop_savemyerp(ERP)
%
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

%function [ERP issave erpcom] = pop_savemyerp2(ERP, overw, w2hd)
function [ERP issave erpcom] = pop_savemyerp(ERP, varargin)

%
% saves current ERP  to memory (menu) and to hard drive
%
issave = 0;
erpcom ='';

if nargin<1
      help pop_savemyerp
      return
end

try
      % parsing inputs
      p = inputParser;
      p.FunctionName  = mfilename;
      p.CaseSensitive = false;
      p.addRequired('ERP');
      p.addParamValue('erpname', '', @ischar);
      p.addParamValue('filename', '', @ischar);
      p.addParamValue('gui', 'no', @ischar); % or 'save' or 'saveas' or 'erplab'
      p.addParamValue('overwriteatmenu', 'no', @ischar);
      p.parse(ERP, varargin{:});
      
      if isempty(ERP)
            msgboxText{1} =  'Error: pop_savemyerp cannot save an empty ERP dataset';
            title = 'ERPLAB: pop_savemyerp() error:';
            errorfound(msgboxText, title);
            return
      end
      if ~iserpstruct(ERP)
            msgboxText{1} =  'Error: pop_savemyerp only works with a valid ERP structure';
            title = 'ERPLAB: pop_savemyerp() error:';
            errorfound(msgboxText, title);
            return
      end
      if ~isfield(ERP, 'bindata')
            msgboxText{1} =  'Error: pop_savemyerp cannot save an empty ERP dataset';
            title = 'ERPLAB: pop_savemyerp() error:';
            errorfound(msgboxText, title);
            return
      end
      if isempty(ERP.bindata)
            msgboxText{1} =  'Error: pop_savemyerp cannot save an empty ERP dataset';
            title = 'ERPLAB: pop_savemyerp() error:';
            errorfound(msgboxText, title);
            return
      end
      
      fullfilename = strtrim(p.Results.filename); % with full path
      
      erpname  = p.Results.erpname;
      
      if isempty(erpname)
            erpname = ERP.erpname;
      end
      
      overw  = p.Results.overwriteatmenu;
      
      if strcmpi(overw,'yes')
            overw = 1;   %
      else
            overw = 0;   %
      end
      
      if strcmpi(p.Results.gui,'erplab')
            
            if ~overw
                  answer = savemyerpGUI(erpname, fullfilename, 0); % open GUI to save erpset
                  
                  if isempty(answer)
                        disp('User selected Cancel')
                        return
                  end
                  
                  erpname  = answer{1};
                  
                  if isempty(erpname)
                        disp('User selected Cancel') % change
                        return
                  end
                  
                  fullfilename = answer{2};
                  overw        = answer{3}; % over write in memory? 1=yes
            else
                  erpname = ERP.erpname;
                  fullfilename = '';
            end
            
            ERP.erpname = erpname;
            
            ERP.filename = '';
            ERP.filepath = '';
            ERP.saved    = 'no';
            
            modegui = 0;
            
      elseif strcmpi(p.Results.gui,'save')
            
            if isempty(ERP.filename)
                  modegui = 2; % open a "save as" window to save
                  fullfilename = p.Results.filename;
            else
                  modegui = 1;
                  fullfilename = fullfile(ERP.filepath, ERP.filename);
            end
            
            overw = 1;
            
      elseif strcmpi(p.Results.gui,'saveas')
            
            modegui = 2; % open a "save as" window to save
            
            if isempty(fullfilename)
                  fullfilename = fullfile(ERP.filepath, ERP.filename);
            end
            
            overw = 1;
      else
            modegui = 3;
            
            if isempty(fullfilename)
                  fullfilename = fullfile(ERP.filepath, ERP.filename);
            end
            
            if isempty(fullfilename)
                  error('ERPLAB says: You must specify a filename (path included) to save your ERPset.')
            end
            
            if isempty(erpname)
                  erpname = ERP.erpname;
            else
                  ERP.erpname = erpname;
            end
            
            if isempty(erpname)
                  error('ERPLAB says: You must specify an erpname to save your ERPset.')
            end
      end
      
      if modegui==0  % save as from erplab gui
            
            if ~isempty(fullfilename)
                  
                  disp(['Saving ERP at ' fullfilename '...'] )
                  [ERP serror] = saveERP(ERP, fullfilename, 0);
                  
                  if serror==1
                        return
                  end
            end
            
            checking = checkERP(ERP);
            
      elseif modegui==1 % save directly
            
            disp(['Saving ERP at ' fullfilename '...'] )
            [ERP serror] = saveERP(ERP, fullfilename, 0);
            
            if serror==1
                  return
            end
            
            checking = checkERP(ERP);
            
      elseif modegui==2 % save as window
            
            disp(['Saving ERP at ' fullfilename '...'] )
            [ERP serror] = saveERP(ERP, fullfilename, 1);
            
            if serror==1
                  return
            end
            
            checking = checkERP(ERP);
            
      elseif modegui==3 % save from scripting
            
            if ~isempty(fullfilename)
                  
                  disp(['Saving ERP at ' fullfilename '...'] )
                  [ERP serror] = saveERP(ERP, fullfilename, 0);
                  
                  checking = checkERP(ERP);
                  
                  if serror==1 || checking==0
                        error('ERPLAB says: An error occured during saving.')
                  end
            end
            
            try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
            return
      else
            error('ERPLAB says: Oops! error at pop_savemyerp()')
      end
      
      if overw
            if checking
                  ALLERP     = evalin('base', 'ALLERP');
                  CURRENTERP = evalin('base', 'CURRENTERP');
                  ALLERP(CURRENTERP) = ERP;
                  assignin('base','ALLERP',ALLERP);  % save to workspace
                  updatemenuerp(ALLERP,1) % overwrite
            else
                  issave = 0;
                  return
            end
      else
            if checking
                  pop_loaderp('workspace');
            else
                  issave = 0;
                  return
            end
      end
      
      issave = 1;
      
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      erpcom = sprintf('%s = pop_savemyerp(%s', inputname(1), inputname(1));
      
      if strcmp(p.Results.erpname,'')
            erpcom = sprintf('%s, ''erpname'', ''%s''', erpcom, erpname);
      end
      if strcmp(p.Results.filename,'')
            erpcom = sprintf('%s, ''filename'', ''%s''', erpcom, fullfilename);
      end
      if ~strcmp(p.Results.gui,'')
            erpcom = sprintf('%s, ''gui'', ''%s''', erpcom, p.Results.gui);
            
      end
      if strcmp(p.Results.overwriteatmenu,'yes')
            erpcom = sprintf('%s, ''overwriteatmenu'', ''yes''', erpcom);
      end
      erpcom = sprintf('%s);', erpcom);      
      return
catch
      serr = lasterror;
      msgboxText{1} =  'ERPLAB found and error at: ';
      msgboxText{2} =  '';
      msgboxText{3} =  serr.message;
      title = 'ERPLAB: pop_savemyerp() error:';
      errorfound(msgboxText, title);
      erpcom = '';
      return
end