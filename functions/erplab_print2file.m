% Mofified version of the original SAVE2PDF of Gabe Hoffmann (gabe.hoffmann@gmail.com)
%
% Saves a figure as a properly cropped pdf, eps, jpeg, or tiff
%
%   save2pdf(FileName,handle,dpi)
%
%   - FileName: Destination to write the file to.
%   - handle:  (optional) Handle of the figure to write to a file.  If
%              omitted, the current figure is used.  Note that handles
%              are typically the figure number.
%   - dpi: (optional) Integer value of dots per inch (DPI).  Sets
%          resolution of output file.  Note that 150 dpi is the Matlab
%          default and this function's default, but 600 dpi is typical for
%          production-quality.
%
%   Saves figure as a file with margins cropped to match the figure size.

%   (c) Gabe Hoffmann, gabe.hoffmann@gmail.com
%   Written 8/30/2007
%   Revised 9/22/2007
%   Revised 1/14/2007
%   Revised 01/27/2008 Javier
%   modified and renamed by Javier Lopez-Calderon

function erplab_print2file(FileName, fformat, handle, dpi)

% Verify correct number of arguments
matlab_v = version('-release');
matlab_v = str2double(matlab_v(1:4));

if matlab_v > 2012
    narginchk(0,4)
else
    error(nargchk(0,4,nargin))
end

% If no handle is provided, use the current figure as default
if nargin<1
        [fileName,pathName] = uiputfile('*.pdf','Save to file:');
        if fileName == 0; return; end
        FileName = [pathName,fileName];        
        
        [fname, pathname, filterIndex] = uiputfile({'*.pdf';'*.eps';'*.jpg';'*.tiff'},'Save Current Figure as');
        
        if isequal(fname,0)
                disp('User selected Cancel')
                return
        else
                [pt,fn,ext] = fileparts(fname);
                
                if  filterIndex==1
                        fformat = 'pdf';
                elseif  filterIndex==2
                        fformat = 'eps';
                elseif  filterIndex==3
                        fformat = 'jpeg';
                elseif  filterIndex==4
                        fformat = 'tiff';
                end
                fname = [fn '.' fformat;];
                FileName = fullfile(pathname, fname);
        end
end
if nargin<2
        fformat = 'pdf';
end
if nargin<3
        handle = gcf;
end
if nargin<4
        dpi = 150;
end

% Backup previous settings
prePaperType  = get(handle,'PaperType');
prePaperUnits = get(handle,'PaperUnits');
preUnits      = get(handle,'Units');
prePaperPosition = get(handle,'PaperPosition');
prePaperSize  = get(handle,'PaperSize');

% Make changing paper type possible
set(handle,'PaperType','<custom>');

% Set units to all be the same
set(handle,'PaperUnits','inches');
set(handle,'Units','inches');

% Set the page size and position to match the figure's dimensions
paperPosition = get(handle,'PaperPosition');
position      = get(handle,'Position');
set(handle,'PaperPosition',[0,0,position(3:4)])
set(handle,'PaperSize',position(3:4))

fformat = strrep(fformat, '.','');
if strcmpi(fformat,'pdf')
        [pt,fn,ext] = fileparts(FileName);
        FileName = fullfile(pt, [fn '.pdf']);
elseif strcmpi(fformat,'eps')
        [pt,fn,ext] = fileparts(FileName);
        FileName = fullfile(pt, [fn '.eps']);
elseif strcmpi(fformat,'jpg') || strcmpi(fformat,'jpeg')
        [pt,fn,ext] = fileparts(FileName);
        FileName = fullfile(pt, [fn '.jpg']);
elseif strcmpi(fformat,'tiff')
        [pt,fn,ext] = fileparts(FileName);
        FileName = fullfile(pt, [fn '.tiff']);
else
        error('invalid file format')
end


% Save the pdf (this is the same method used by "saveas")
print(handle,sprintf('-d%s',fformat),FileName,sprintf('-r%d',dpi))

% Restore the previous settings
set(handle,'PaperType',prePaperType);
set(handle,'PaperUnits',prePaperUnits);
set(handle,'Units',preUnits);
set(handle,'PaperPosition',prePaperPosition);
set(handle,'PaperSize',prePaperSize);
