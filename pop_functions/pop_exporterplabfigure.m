% PURPOSE  :	Export open plotted figure to pdf
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

function [ERP, erpcom] = pop_exporterplabfigure(ERP, varargin)
erpcom = '';
if nargin<1
        help pop_fig2pdf
        return
end
if nargin==1
        
        def  = erpworkingmemory('pop_exporterplabfigure');
        if isempty(def)
                def = {{'ERP_figure' 'Scalp_figure'}, 'saveas', [], 'pdf', 300};
        end
        
        %
        % Call GUI
        %
        answer = fig2pdfGUI(def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        figtag     = answer{1};
        saveasmode = answer{2};
        filepath   = answer{3};
        fileformat = answer{4};
        resolution = answer{5};        
        
        nft = length(figtag);
        find_erplabfigure = [];
        
        for k=1:nft
                find_erplabfigure   = [find_erplabfigure; findobj('Tag', figtag{k})]; 
        end        
        if isempty(find_erplabfigure)
                msgboxText = 'pop_exporterplabfigure could not find any figure having the specified tag(s)\n';
                etitle = 'ERPLAB: pop_exporterplabfigure inputs';
                errorfound(sprintf(msgboxText), etitle);
                return
        end
        
%         if fileformat==1
%                 fformat = 'pdf';
%         elseif fileformat==2
%                 fformat = 'edf';
%         elseif fileformat==3
%                 fformat = 'jpg';
%         elseif fileformat==4
%                 fformat = 'tiff';
%         else
%                 fformat = 'pdf';
%         end
        if isempty(filepath)
                filepath = cd;
        end
        
        erpworkingmemory('pop_exporterplabfigure', { figtag, saveasmode, filepath, fileformat, resolution });
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_exporterplabfigure(ERP, 'Tag', figtag, 'SaveMode', saveasmode, 'Filepath', filepath, 'Format', fileformat,...
                'Resolution', resolution, 'History', 'gui');
        return        
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
% options
p.addParamValue('Tag', '');
p.addParamValue('SaveMode', 'saveas', @ischar);
p.addParamValue('Filepath', cd, @ischar);
p.addParamValue('Format', 'pdf', @ischar);
p.addParamValue('Resolution', 300, @isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERP, varargin{:});

figtag     = p.Results.Tag;
saveasmode = p.Results.SaveMode;
filepath   = p.Results.Filepath;
fileformat = p.Results.Format;
resolution = p.Results.Resolution;

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end

%
% subroutine
%
ERP = erplabfig2pdf(ERP, figtag, saveasmode, filepath, fileformat, resolution);

%
% History
%
skipfields = {'ERP', 'History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_exporterplabfigure( %s ', inputname(1), inputname(1));
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        if ischar([fn2res{:}])
                                                fn2resstr = sprintf('''%s'' ', fn2res{:});
                                        else
                                                fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        end
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                if strcmpi(fn2com,'Criterion')
                                        if p.Results.Criterion<100
                                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                        end
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);

%
% Completion statement
%
msg2end

% get history from script
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
        otherwise %off or none
                erpcom = '';
end
return