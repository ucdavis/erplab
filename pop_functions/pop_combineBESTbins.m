% PURPOSE  : Combine bins within a BEST file. Outputs BEST file with
%           combined bin appended at the end of BESTset. 
%
% FORMAT   :
%
% >>   [BEST] = pop_combineBESTbins(BEST,parameters);
%
% INPUTS   :
%
%         BEST       - input BEST dataset
%
% The available input parameters are as follows:
%
%        'bins_to_combine' 	   - Cell array of bins to combine where each
%                                 element is a set of bin indexes.
%        'bin_labels'          - Cell array of bin description names for
%                                   each newly combined bin. 
%                                   Length of cellarray must equal 'bins_to_combine' 
%
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
% [BEST] = pop_combineBESTbins(BEST,'bins_to_combine',{[1,2,3],[4,5,6]}, ...
% 'bin_labels',{'Combined bins 1,2,3','Combined bins 4,5,6'}); 
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

function [BEST] = pop_combineBESTbins(BEST,varargin) 
com = '';

BEST = preloadBEST;

if nargin < 1
    help pop_combineBESTbins
    return
end


if nargin == 1 %open GUI
    currdata = evalin('base','CURRENTBEST'); 
    
    if currdata == 0 
        msgboxText =  'pop_combineBESTbins() error: cannot work an empty dataset!!!';
        title      = 'ERPLAB: No data';
        errorfound(msgboxText, title);
        return
        
    end
    
    def = erpworkingmemory('pop_combineBESTbins()'); 
    
    if isempty(def)
        def = {{[0]},{'none'}}; 
        
    end
    
    app = feval('combinebestbinsGUI',BEST,currdata,def); 
    waitfor(app,'FinishButton',1); 
    
    
end 
    
    
    
    
    



return
