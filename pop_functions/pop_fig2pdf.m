% PURPOSE  :	Export plotted figure to pdf
%
% FORMAT   :
%
% pop_fig2pdf(fullname);
%
% INPUTS   : NOTE: The plotted figure from ERPLAB must be open.
%
% Fullname     - Pathname and filename, with .pdf extension
%
% OUTPUTS  :
% .pdf         - PDF
%
% EXAMPLE  :
% pop_fig2pdf('C:\Users\etfoo\Desktop\S1\Figure_2_S1_ERPs.pdf');
%
% See also save2pdf.m
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

function [erpcom] = pop_fig2pdf(filenameAll)
erpcom = '';
find1 = findobj('Tag','Plotting_ERP');
if ~isempty(find1)
        for f=1:length(find1)
                fig1    = figure(find1(f));
                namefig = regexp(get(fig1,'Name'),'<<(.*)?>>', 'tokens');
                namefig = char(namefig{:});
                filterIndex = 0;
                
                if nargin<1                        
                        [filename, pathname, filterIndex] = uiputfile({'*.pdf';'*.eps'},...
                                'Save Current Figure as',...
                                ['Figure_' num2str(find1(f)) '_' namefig]);
                        
                        if isequal(filename,0)
                                disp('User selected Cancel')
                                return
                        else
                                [pt,fn,ext] = fileparts(filename);
                                
                                if isempty(ext)
                                        if  filterIndex==1
                                                ext = '.pdf';
                                        elseif  filterIndex==2
                                                ext = 'eps';
                                        end
                                        filename = [filename ext;];
                                elseif ~strcmp(ext,'.pdf') && ~strcmp(ext,'.eps')
                                        if  filterIndex==1
                                                ext2 = '.pdf';
                                        elseif  filterIndex==2
                                                ext2 = 'eps';
                                        end
                                        
                                        filename = [filename ext ext2;];
                                end
                                filenameAll = fullfile(pathname, filename);
                        end
                else
                        [pt,fn,ext] = fileparts(filenameAll);
                        if strcmp(ext,'.pdf') || strcmp(ext,'')
                                filterIndex=1;
                        elseif strcmp(ext,'.eps')
                                filterIndex=2;
                        else
                                error(['ERPLAB says: pop_fig2pdf cannot work with file extension ' ext])
                        end
                end
                if  filterIndex==1
                        %
                        % Creates pdf.
                        % Thanks to Gabe Hoffmann, gabe.hoffmann@gmail.com
                        save2pdf(filenameAll,fig1,300)
                        disp(['For saving a .pdf file, user selected '  filenameAll])
                        
                elseif  filterIndex==2
                        saveas(fig1, filenameAll, 'epsc');
                        disp(['For saving a .eps file, user selected '  filenameAll])
                end
        end
end

find2 = findobj('Tag','Scalp');

if ~isempty(find2)
        for f=1:length(find2)
                fig2    = figure(find2(f));
                namefig = regexp(get(fig2,'Name'),'<<(.*)?>>', 'tokens');
                namefig = char(namefig{:});
                filterIndex = 0;
                
                if nargin<1
                        [filename, pathname, filterIndex] = uiputfile({'*.pdf';'*.eps'},...
                                'Save Current Figure as',...
                                ['Figure_' num2str(find2(f)) '_' namefig]);
                        if isequal(filename,0)
                                disp('User selected Cancel')
                                return
                        else
                                [pt,fn,ext] = fileparts(filename);
                                
                                if isempty(ext)                                        
                                        if  filterIndex==1
                                                ext = '.pdf';
                                        elseif  filterIndex==2
                                                ext = 'eps';
                                        end
                                        
                                        filename = [filename ext;];
                                        
                                elseif ~strcmp(ext,'.pdf') && ~strcmp(ext,'.eps')
                                        if  filterIndex==1
                                                ext2 = '.pdf';
                                        elseif  filterIndex==2
                                                ext2 = 'eps';
                                        end
                                        filename = [filename ext ext2;];
                                end
                                
                                filenameAll = fullfile(pathname, filename);
                        end
                else
                        [pt,fn,ext] = fileparts(filenameAll);
                        
                        if strcmp(ext,'.pdf') || strcmp(ext,'')
                                filterIndex=1;
                        elseif strcmp(ext,'.eps')
                                filterIndex=2;
                        else
                                error(['ERPLAB says: pop_fig2pdf cannot work with file extension ' ext])
                        end
                end
                if  filterIndex==1
                        %
                        % Creates pdf.
                        % Thanks to Gabe Hoffmann, gabe.hoffmann@gmail.com
                        save2pdf(filenameAll,fig2,300)
                        disp(['For saving a .pdf file, user selected '  filenameAll])
                        
                elseif  filterIndex==2
                        saveas(fig1, filenameAll, 'epsc');
                        disp(['For saving a .eps file, user selected '  filenameAll])
                end
        end
end
if isempty(find1) && isempty(find2)
        msgboxText =  'There is not plotted figure from ERPLAB, currently';
        title = 'ERPLAB: pop_fig2pdf() Error';
        errorfound(msgboxText, title);
        return
end

erpcom = sprintf( 'pop_fig2pdf(''%s'');', filenameAll);

%
% Completion statement
%
msg2end
return