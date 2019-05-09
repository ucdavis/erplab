% FORMAT:
% 
% erplab(option)
% 
% option:
% 
% help          : open ERPLAB TOOLBOX USER'S MANUAL
% manual        : open ERPLAB TOOLBOX USER'S MANUAL
% tuto/tutorial : open ERPLAB TOOLBOX USER'S TUTORIAL
% script        : open ERPLAB TOOLBOX USER'S SCRIPT TUTORIAL
% redraw        : updates ERPset(s) on the GUI
% amnesia       : wipeouts ERPLAB's memory
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

function erplab(dosomething)

% I know, it is not the most elegant function I've written so far...
if nargin<1
        help erplab
        return
end
switch lower(dosomething)
        case {'help','manual'}
                pop_erphelp;
        case {'tuto','tutorial'}
                pop_erphelptut;
        case 'script'
                pop_erphelpscript;
        case 'redraw'
                option = 0;
                try
                        ALLERP   = evalin('base', 'ALLERP');
                catch
                        ALLERP = [];
                end
                try
                        ERP   = evalin('base', 'ERP');
                catch
                        ERP =[];
                end
                if isempty(ALLERP) &&  isempty(ERP)
                        return
                elseif isempty(ALLERP) &&  ~isempty(ERP)
                        ALLERP = ERP;
                        CURRENTERP =1;
                        assignin('base','CURRENTERP', CURRENTERP);  % save to workspace
                        assignin('base','ALLERP', ALLERP);  % save to workspace
                else
                        try
                                CURRENTERP   = evalin('base', 'CURRENTERP');
                                if CURRENTERP<=0 || isempty(CURRENTERP)
                                        CURRENTERP=1;
                                end
                        catch
                                CURRENTERP  = 1;
                        end
                        nerp = length(ALLERP);
                        if CURRENTERP<=nerp
                                option = 1;
                        end
                        %ALLERP(CURRENTERP) = ERP;
                        assignin('base','ALLERP', ALLERP);  % save to workspace
                        assignin('base','CURRENTERP', CURRENTERP);  % save to workspace
                end
                eeglab redraw
                pause(0.1)
                updatemenuerp(ALLERP, option);
        case 'amnesia'
                erplabamnesia
        case 'freedom'
                erpworkingmemory('freedom', 1);
        case 'restriction'
                erpworkingmemory('freedom', 0);
        otherwise
                disp('erplab argument not recognized.')
end