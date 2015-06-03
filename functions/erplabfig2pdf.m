% PURPOSE  :	subroutine of pop_exporterplabfigure.m
%
% FORMAT   :
%
% ERP = erplabfig2pdf(ERP, figtag, saveasmode, filepath, fileformat, resolution)
%
% INPUTS   : NOTE: The plotted figure from ERPLAB must be open.
%
% ERP            - input ERPset
% figtag         - string.   Figure's tag to be included for exporting. E.g. 'ERP_figure', 'Scalp_figure', or custom
% saveasmode     - string.   Mode for saving exported figure:
%                            -'saveas' means open a popup window for saving each open
%                            figure.
%                           -'auto' means automatically save all open figures (specified by Tag) using the figure's
%                            name
%                           - or just enter the name of the figure. e.g. 'alphamap.pdf'
% filepath       - string.   When using 'SaveMode' 'auto', specifies "where" to save the figures.
% fileformat     - string.   'pdf', 'edf', 'jpg', ot 'tiff'
% resolution     - numeric.  Integer value of dots per inch (dpi). E.g. 300
%
%
% See also pop_exporterplabfigure.m, erplab_print2file.m, pop_fig2pdf.m
%
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

function ERP = erplabfig2pdf(ERP, figtag, saveasmode, filepath, fileformat, resolution)
if nargin<1
    help erplabfig2pdf
    return
end
if nargin<5
    resolution = 600; %dpi
end
if nargin<5
    fileformat = 'pdf';
end
if nargin<4
    filepath = cd;
end
if nargin<3
    saveasmode = 'saveas';
end
if ~iscell(figtag)
    if ~ischar(figtag)
        error('erplabfig2pdf: figtag must be a cell string.')
    end
    figtag = cellstr(figtag);
end
nft = length(figtag);

% strmatlabversion = regexp(version,'(R\d*[ab]*)', 'match'); % Matlab's version
NumMatver = str2num(char(regexp(version, '^\d*\.\d*', 'match'))); % Matlab's version

for k=1:nft
    find_erplabfigure   = findobj('Tag', figtag{k});
    % find_erplabfigure   = findobj('Tag','ERP_figure');
    % find_SCALP = findobj('Tag','Scalp_figure');
    % find_erplabfigure = findobj('Tag','Plotting_ERP');
    %     if strcmpi(saveasmode, 'saveascurrent')
    %         find_erplabfigure = find_erplabfigure(1);
    %     end
    
    %if isempty(find_erplabfigure)
    %    find_erplabfigure = 0;
    %end
    %if find_erplabfigure>0
    if ~isempty(find_erplabfigure)
        nferpfig = length(find_erplabfigure);
        msgboxText =  'erplabfig2pdf found %g figure(s) having a "%s" tag\n';
        fprintf(msgboxText, nferpfig,figtag{k});
        if strcmpi(saveasmode, 'saveascurrent')
            find_erplabfigure = find_erplabfigure(1);
            if nferpfig>1
                msgboxText =  'However, since ''saveascurrent'' was set only the current figure will be converted.\n';
                fprintf(msgboxText);
            end
            nferpfig = 1;
        end
        for f=1:nferpfig
            fig1    = figure(find_erplabfigure(f));
            namefig = regexp(get(fig1,'Name'),'<<(.*)?>>', 'tokens');
            namefig = char(namefig{:});
            filterIndex = 0;            
            if strcmpi(saveasmode, 'saveas') || strcmpi(saveasmode, 'saveascurrent')
                
                %find_erplabfigure(f)
                if NumMatver<8.4 % old Matlabs. JLC
                    erpfignumber = num2str(find_erplabfigure(f));
                else % Matlab's new Graphics System (figures handles are no longer numbers...)
                    erpfignumber = find_erplabfigure(f).Number;
                end
                
                [filename, pathname, filterIndex] = uiputfile({'*.pdf';'*.eps';'*.jpg';'*.tiff'},...
                    'Save Current Figure as',...
                    ['Figure_' erpfignumber '_' namefig]);
                
                if isequal(filename,0)
                    disp('User selected Cancel')
                    return
                else
                    [pt,fn,ext] = fileparts(filename);                    
                    fn = strtrim(fn);
                    fn = regexprep(fn,'\W*','_'); % replace in between white space(s) by a single '_'. JLC
                    
                    %if isempty(ext) || (~strcmp(ext,'.pdf') && ~strcmp(ext,'.eps') && ~strcmp(ext,'.jpg')&& ~strcmp(ext,'.tiff'))
                    if  filterIndex==1
                        ext = '.pdf';
                    elseif  filterIndex==2
                        ext = '.eps';
                    elseif  filterIndex==3
                        ext = '.jpg';
                    elseif  filterIndex==4
                        ext = '.tiff';
                    end
                    filename = [fn ext;];
                    %end                    
                    
                    if ismember(pathname, {'\','/'})  % i.e. when pointig to 'Macintosh'
                        if ispc
                            userdir = winqueryreg('HKEY_CURRENT_USER',...
                                ['Software\Microsoft\Windows\CurrentVersion\' ...
                                'Explorer\Shell Folders'],'Personal');                            
                        else
                            userdir = char(java.lang.System.getProperty('user.home'));                      
                        end
                        pathname = fullfile(userdir, 'Desktop'); % i.e. when pointig to 'Macintosh'
                    end
                    filenameAll = fullfile(pathname, filename);
                end
            else % auto save or input name argument
                if strcmpi(saveasmode, 'auto')
                    filenameAll = fullfile(filepath, namefig);
                else
                    filenameAll = fullfile(filepath, saveasmode);
                end
                if strcmpi(fileformat,'pdf')
                    [pt,fn,ext] = fileparts(filenameAll);
                    filenameAll = fullfile(pt, [fn '.pdf']);
                    filterIndex = 1;
                elseif strcmpi(fileformat,'eps')
                    [pt,fn,ext] = fileparts(filenameAll);
                    filenameAll = fullfile(pt, [fn '.eps']);
                    filterIndex = 2;
                elseif strcmpi(fileformat,'jpg')
                    [pt,fn,ext] = fileparts(filenameAll);
                    filenameAll = fullfile(pt, [fn '.jpg']);
                    filterIndex = 3;
                elseif strcmpi(fileformat,'tiff')
                    [pt,fn,ext] = fileparts(filenameAll);
                    filenameAll = fullfile(pt, [fn '.tiff']);
                    filterIndex = 4;
                else
                    error('ERPLAB says: erplabfig2pdf cannot recognize file format')
                end
                
                % in case file already exist, add a numeric suffix
                if exist(filenameAll, 'file')==2
                    [pt,fn,ext] = fileparts(filenameAll);
                    gonext = 2;
                    while gonext>0 && gonext<10000
                        tryfname = fullfile(pt, [fn '_' num2str(gonext) ext]);
                        if exist(tryfname, 'file')==2
                            gonext = gonext+1;
                        else
                            filenameAll = tryfname;
                            gonext = 0;
                        end
                    end
                end
            end
            if  filterIndex==1 % PDF
                %
                % Creates pdf.
                % Thanks to Gabe Hoffmann, gabe.hoffmann@gmail.com
                %save2pdf(filenameAll,fig1,resolution)
                erplab_print2file(filenameAll, 'pdf', fig1, resolution)
                disp(['For saving a .pdf file, user selected '  filenameAll])
            elseif  filterIndex==2 % EPS
                %saveas(fig1, filenameAll, 'epsc');
                %print(fig1,'-depsc','-tiff',['-r' num2str(resolution)],filenameAll)
                erplab_print2file(filenameAll, 'eps', fig1, resolution)
                disp(['For saving a .eps file, user selected '  filenameAll])
            elseif  filterIndex==3 % JPG
                %print(fig1,'-djpeg',['-r' num2str(resolution)], filenameAll)
                erplab_print2file(filenameAll, 'jpeg', fig1, resolution)
                disp(['For saving a .jpg file, user selected '  filenameAll])
            elseif  filterIndex==4 % TIFF
                %print(fig1,'-dtiff',['-r' num2str(resolution)], filenameAll)
                erplab_print2file(filenameAll, 'tiff', fig1, resolution)
                disp(['For saving a .tiff file, user selected '  filenameAll])
            else
                error('invalid format.')
            end
        end
    else
        msgboxText =  'erplabfig2pdf could not find any figure having a "%s" tag\n';
        fprintf(msgboxText, figtag{k});
    end
end
return