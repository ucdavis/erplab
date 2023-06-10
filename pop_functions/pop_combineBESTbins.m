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
%                                 element is a set of bin indexes from BEST.
%        'bin_labels'          - Cell array of bin description names for
%                                   each newly combined bin. 
%                                   Length of cellarray must equal 'bins_to_combine' 
%
%        'SaveAs'      -  (optional) open GUI for saving BESTset.
%                           'on'/'off' (Default: off)
%                           - (if "off", will not update in BESTset menu)
%                           - if scripting, use "off" and pop_savemybest() 
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

function [BEST] = pop_combineBESTbins(ALLBEST,varargin) 
com = '';

% try 
%     ALLBEST = evalin('base','ALLBEST');
% catch
%     disp('WARNING: ALLBEST structure was not found. ERPLAB will create an empty one')
%     ALLBEST = [];
% end

%preload BEST
% BEST = preloadBEST; 

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
    
    def = erpworkingmemory('pop_combineBESTbins'); 
    
    if isempty(def)
        def = {{[]},{[]}}; 
        %1 binindex(s) from old BEST that will create new BEST
        %2 binlabel(s) from oldBEST taht will create new BEST
        
    end
    
    
    
    
    app = feval('combinebestbinsGUI',ALLBEST,currdata,def); 
    waitfor(app,'FinishButton',1); 
    
    try
        res = app.output;
        app.delete; %delete app from view
        pause(0.5); %wait for app to leave
    catch
        disp('User selected Cancel')
        return
    end
    
    
    BEST = res{1};
    nbins = res{2}.bini;
    nlabels = res{2}.labels; 
    
    def = {nbins,nlabels}; 
    erpworkingmemory('pop_combineBESTbins',def); 
    
    [BEST] = pop_combineBESTbins(ALLBEST,'BESTindex',currdata, 'new_bins',nbins,'new_labels',nlabels, ...
        'Saveas','on'); 
    
    pause(0.1);
    return
    
end 
    
%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLBEST');
    

p.addParamValue('BESTindex', [1],@isnumeric); % erpset index or input file (default: first BESTset in ALLBEST)
p.addParamValue('bins_to_combine',{}); %array of channel indicies (def: all channels)
p.addParamValue('bin_labels',{}); 
p.addParamValue('Saveas','off'); 

% Parsing
p.parse(ALLBEST, varargin{:});

idx_bestset = p.Results.BESTindex;
new_bins = p.Results.bins_to_combine;
new_labels = p.Results.bin_labels;

%% choose BESTsets
if ~isempty(idx_bestset)  
    BEST = ALLBEST(idx_bestset) ; 
else
    BEST = ALLBEST(1); %just do the first one 
end
    
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
end


%% bin-combiner routine 

BEST = combineBESTbins(BEST, new_bins, new_labels); 


%% save function

if issaveas
    [BEST, issave] = pop_savemybest(BEST,'gui','erplab');
    if issave>0
        if issave==2
            %erpcom  = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your BESTset was saved on your hard drive.***';
        else
            msgwrng = '*** Warning: Your BESTset was only saved on the workspace.***';
        end
    else
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
end




return
