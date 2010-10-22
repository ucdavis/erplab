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

function handles = painterplab(handles, type)

if nargin<2
      type = 0;
end
if type==0
      %
      % Color GUI
      %
      ColorB = erpworkingmemory('ColorB');
      ColorF = erpworkingmemory('ColorF');
elseif type==1
      ColorB = [1 0.9 0.3];
      ColorF = [0 0 0];
end
if isempty(ColorB)
      ColorB = [0.83 0.82 0.79];
end
if isempty(ColorF)
      ColorF = [0 0 0];
end

filedsn = fieldnames(handles);

for j=1:length(filedsn)
      
      mstr = regexp(filedsn{j},'^nbin|^edit|^listbox|^EEG|^ERP|togglebutton_summary|^pushbutton|totline|indxline|Plotting_ERP|Scalp|counterchanwin|counterbinwin','match');
      
      if isempty(mstr)
            
            %filedsn{j}
            num = handles.(filedsn{j});
            
            if ~iscell(num) && ~isstruct(num)
                  if num~=1
                        try
                              set(num, 'BackgroundColor', ColorB)
                        catch
                              try
                                    set(num, 'Color', ColorB)
                              catch
                              end
                        end
                        
                        try
                              set(num, 'ForegroundColor', ColorF)
                        catch
                              
                        end
                  end
            end
      end
end