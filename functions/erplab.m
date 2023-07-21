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
                erp_check = 0;
                best_check = 0;
                mvpc_check = 0; 
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
                        %return
                        erp_check = 1; 
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
                
                %% BESTsets

                try
                    ALLBEST   = evalin('base', 'ALLBEST');
                catch
                    ALLBEST = [];
                end
                try
                    BEST   = evalin('base', 'BEST');
                catch
                    BEST =[];
                end
                if isempty(ALLBEST) &&  isempty(BEST)
                    %return
                    best_check = 1; 
                elseif isempty(ALLBEST) &&  ~isempty(BEST)
                    ALLBEST = BEST;
                    CURRENTBEST =1;
                    assignin('base','CURRENTBEST', CURRENTBEST);  % save to workspace
                    assignin('base','ALLBEST', ALLBEST);  % save to workspace
                else
                    try
                        CURRENTBEST   = evalin('base', 'CURRENTBEST');
                        if CURRENTBEST<=0 || isempty(CURRENTBEST)
                            CURRENTBEST=1;
                        end
                    catch
                        CURRENTBEST  = 1;
                    end
                    nbest = length(ALLBEST);
                    if CURRENTBEST<=nbest
                        option = 1;
                    end
                    assignin('base','ALLBEST', ALLBEST);  % save to workspace
                    assignin('base','CURRENTBEST', CURRENTBEST);  % save to workspace
                end

                %% MVPC sets

                try
                    ALLMVPC   = evalin('base', 'ALLMVPC');
                catch
                    ALLMVPC = [];
                end
                try
                    MVPC   = evalin('base', 'MVPC');
                catch
                    MVPC =[];
                end
                if isempty(ALLMVPC) &&  isempty(MVPC)
                    %return
                    mvpc_check = 1; 
                elseif isempty(ALLMVPC) &&  ~isempty(MVPC)
                    ALLMVPC = MVPC;
                    CURRENTMVPC =1;
                    assignin('base','CURRENTMVPC', CURRENTMVPC);  % save to workspace
                    assignin('base','ALLMVPC', ALLMVPC);  % save to workspace
                else
                    try
                        CURRENTMVPC   = evalin('base', 'CURRENTMVPC');
                        if CURRENTMVPC<=0 || isempty(CURRENTMVPC)
                            CURRENTMVPC=1;
                        end
                    catch
                        CURRENTMVPC  = 1;
                    end
                    nmvpc = length(ALLMVPC);
                    if CURRENTMVPC<=nmvpc
                        option = 1;
                    end
                    assignin('base','ALLMVPC', ALLMVPC);  % save to workspace
                    assignin('base','CURRENTMVPC', CURRENTMVPC);  % save to workspace
                end

                
                if erp_check == 0  
                    eeglab redraw
                    pause(0.1)
                    updatemenuerp(ALLERP, option);
                end
                
               % redraws = 0; %since eeglab can't identify these data yet
                if best_check == 0
                    eeglab redraw
                  %  redraws = 1; 
                    pause(0.1)
                    updatemenubest(ALLBEST,option); 
                end

                if mvpc_check == 0
%                     if redraws == 0
%                         eeglab redraw
%                     end
                    eeglab redraw
                    pause(0.1)
                    updatemenumvpc(ALLMVPC,option);

                end

        case 'amnesia'
                erplabamnesia
        case 'freedom'
                erpworkingmemory('freedom', 1);
        case 'restriction'
                erpworkingmemory('freedom', 0);
        otherwise
                disp('erplab argument not recognized.')
end